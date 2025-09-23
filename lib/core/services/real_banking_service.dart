import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'paystack_service.dart';
import 'realtime_balance_service.dart';

/// Service for real banking operations using actual bank accounts
class RealBankingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PaystackService _paystackService = PaystackService();
  final RealtimeBalanceService _realtimeBalanceService = RealtimeBalanceService();

  /// Fund wallet directly from bank account using "Pay with Bank"
  Future<Map<String, dynamic>> fundWalletFromBank({
    required double amount,
    required String email,
    String? description,
    String? bankCode,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      if (amount <= 0) throw Exception('Amount must be greater than 0');

      // Generate unique reference
      final reference = _paystackService.generateReference();
      
      // Initialize bank payment (Pay with Bank)
      final paystackResponse = await _paystackService.initializeBankPayment(
        email: email,
        amount: amount,
        reference: reference,
        metadata: {
          'user_id': currentUser.uid,
          'type': 'bank_wallet_funding',
          'description': description ?? 'Wallet funding from bank',
          'bank_code': bankCode,
        },
      );

      // Save pending transaction to Firestore
      await _firestore.collection('pending_transactions').doc(reference).set({
        'reference': reference,
        'user_id': currentUser.uid,
        'email': email,
        'amount': amount,
        'type': 'bank_wallet_funding',
        'description': description ?? 'Wallet funding from bank',
        'status': 'pending',
        'payment_method': 'bank',
        'bank_code': bankCode,
        'paystack_response': paystackResponse,
        'created_at': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'reference': reference,
        'authorization_url': paystackResponse['data']['authorization_url'],
        'access_code': paystackResponse['data']['access_code'],
        'message': 'Bank payment initialized successfully',
        'payment_method': 'bank',
      };
    } catch (e) {
      throw Exception('Failed to fund wallet from bank: $e');
    }
  }

  /// Transfer money directly from bank account to another bank account
  Future<Map<String, dynamic>> transferFromBankToBank({
    required String senderEmail,
    required String recipientAccountNumber,
    required String recipientBankCode,
    required String recipientAccountName,
    required double amount,
    required String reason,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      if (amount <= 0) throw Exception('Amount must be greater than 0');

      // Generate unique reference
      final reference = _paystackService.generateReference();
      
      // Initialize bank payment for transfer
      final paystackResponse = await _paystackService.initializeBankPayment(
        email: senderEmail,
        amount: amount,
        reference: reference,
        metadata: {
          'user_id': currentUser.uid,
          'type': 'bank_to_bank_transfer',
          'recipient_account': recipientAccountNumber,
          'recipient_bank': recipientBankCode,
          'recipient_name': recipientAccountName,
          'reason': reason,
        },
      );

      // Save pending transfer to Firestore
      await _firestore.collection('pending_transfers').doc(reference).set({
        'reference': reference,
        'user_id': currentUser.uid,
        'sender_email': senderEmail,
        'recipient_account_number': recipientAccountNumber,
        'recipient_bank_code': recipientBankCode,
        'recipient_account_name': recipientAccountName,
        'amount': amount,
        'reason': reason,
        'type': 'bank_to_bank_transfer',
        'status': 'pending',
        'paystack_response': paystackResponse,
        'created_at': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'reference': reference,
        'authorization_url': paystackResponse['data']['authorization_url'],
        'access_code': paystackResponse['data']['access_code'],
        'message': 'Bank transfer initialized successfully',
      };
    } catch (e) {
      throw Exception('Failed to transfer from bank to bank: $e');
    }
  }

  /// Verify bank payment transaction
  Future<void> verifyBankPayment(String reference) async {
    try {
      print('🔍 Starting bank payment verification for reference: $reference');
      
      // Get pending transaction
      final pendingDoc = await _firestore.collection('pending_transactions').doc(reference).get();
      if (!pendingDoc.exists) {
        print('❌ Pending bank transaction not found for reference: $reference');
        throw Exception('Bank transaction not found');
      }

      final pendingData = pendingDoc.data()!;
      final userId = pendingData['user_id'] as String;
      final amount = (pendingData['amount'] as num).toDouble();
      final paymentMethod = pendingData['payment_method'] as String? ?? 'bank';
      
      print('📊 Found pending bank transaction: User $userId, Amount: $amount, Method: $paymentMethod');

      // Verify with Paystack
      print('🔍 Verifying bank payment with Paystack...');
      final verificationResponse = await _paystackService.verifyTransaction(reference);
      final status = verificationResponse['data']['status'];
      final gatewayResponse = verificationResponse['data']['gateway_response'];
      final message = verificationResponse['data']['message'];
      
      print('📊 Paystack bank payment verification response:');
      print('   Status: $status');
      print('   Gateway Response: $gatewayResponse');
      print('   Message: $message');
      print('   Full Response: $verificationResponse');

      if (status == 'success') {
        print('✅ Bank payment successful! Updating balance...');
        
        // Transaction successful - update user balance using real-time service
        await _realtimeBalanceService.processPayment(
          type: 'credit',
          amount: amount,
          description: pendingData['description'] ?? 'Bank wallet funding',
          metadata: {
            'reference': reference,
            'paystack_data': verificationResponse['data'],
            'source': 'bank_payment',
            'payment_method': paymentMethod,
            'bank_code': pendingData['bank_code'],
          },
        );

        // Update pending transaction status
        await _firestore.collection('pending_transactions').doc(reference).update({
          'status': 'completed',
          'verified_at': FieldValue.serverTimestamp(),
          'paystack_verification': verificationResponse,
        });
        
        print('✅ Bank payment verification completed successfully!');
      } else {
        print('❌ Bank payment failed with status: $status');
        
        // Transaction failed
        await _firestore.collection('pending_transactions').doc(reference).update({
          'status': 'failed',
          'verified_at': FieldValue.serverTimestamp(),
          'paystack_verification': verificationResponse,
        });
        
        // Provide more specific error messages based on status
        String errorMessage;
        switch (status) {
          case 'pending':
            errorMessage = 'Transaction is still pending. Please wait a moment and try again.';
            break;
          case 'failed':
            errorMessage = gatewayResponse ?? 'Bank payment failed. Please try again.';
            break;
          case 'abandoned':
            errorMessage = 'Transaction was abandoned. Please initiate a new payment.';
            break;
          default:
            errorMessage = 'Transaction was not completed. Status: $status';
        }
        
        throw Exception('Bank payment failed: $errorMessage');
      }
    } catch (e) {
      print('❌ Error verifying bank payment: $e');
      throw Exception('Failed to verify bank payment: $e');
    }
  }

  /// Get list of supported banks for "Pay with Bank"
  Future<List<Map<String, dynamic>>> getSupportedBanks() async {
    try {
      return await _paystackService.getSupportedBanks();
    } catch (e) {
      print('Error getting supported banks: $e');
      return [];
    }
  }

  /// Get user's bank payment history
  Future<List<Map<String, dynamic>>> getBankPaymentHistory() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      // Simplified query to avoid composite index requirement
      final querySnapshot = await _firestore
          .collection('pending_transactions')
          .where('user_id', isEqualTo: currentUser.uid)
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      // Filter in application code to avoid Firestore composite index
      final filteredTransactions = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .where((transaction) => transaction['payment_method'] == 'bank')
          .toList();

      return filteredTransactions;
    } catch (e) {
      print('Error getting bank payment history: $e');
      return [];
    }
  }

  /// Check for pending bank payments that need verification
  Future<List<Map<String, dynamic>>> getPendingBankPayments() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      // Simplified query to avoid composite index requirement
      final querySnapshot = await _firestore
          .collection('pending_transactions')
          .where('user_id', isEqualTo: currentUser.uid)
          .orderBy('created_at', descending: true)
          .limit(50) // Limit results for performance
          .get();

      // Filter in application code to avoid Firestore composite index
      final filteredTransactions = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .where((transaction) => 
              transaction['payment_method'] == 'bank' && 
              transaction['status'] == 'pending')
          .toList();

      return filteredTransactions;
    } catch (e) {
      print('Error getting pending bank payments: $e');
      return [];
    }
  }

  /// Verify all pending bank payments
  Future<void> verifyAllPendingBankPayments() async {
    try {
      final pendingPayments = await getPendingBankPayments();
      
      for (final payment in pendingPayments) {
        final reference = payment['reference'] as String;
        try {
          await verifyBankPayment(reference);
          print('Successfully verified bank payment: $reference');
        } catch (e) {
          print('Failed to verify bank payment $reference: $e');
          // Continue with other payments even if one fails
        }
      }
    } catch (e) {
      print('Error verifying all pending bank payments: $e');
      rethrow;
    }
  }

  /// Get bank payment fees information
  Map<String, dynamic> getBankPaymentFees() {
    return {
      'percentage_fee': 1.5, // 1.5% of transaction amount
      'fixed_fee': 100, // NGN 100 fixed fee
      'minimum_amount': 100, // Minimum NGN 100
      'fee_waiver_threshold': 2500, // Fee waived for transactions below NGN 2,500
      'maximum_fee': 2000, // Maximum fee capped at NGN 2,000
      'currency': 'NGN',
    };
  }

  /// Calculate bank payment fees for a given amount
  Map<String, dynamic> calculateBankPaymentFees(double amount) {
    final fees = getBankPaymentFees();
    final percentageFee = amount * (fees['percentage_fee'] / 100);
    final fixedFee = amount < fees['fee_waiver_threshold'] ? 0 : fees['fixed_fee'];
    final totalFee = percentageFee + fixedFee;
    final cappedFee = totalFee > fees['maximum_fee'] ? fees['maximum_fee'] : totalFee;
    
    return {
      'amount': amount,
      'percentage_fee': percentageFee,
      'fixed_fee': fixedFee,
      'total_fee': cappedFee,
      'total_amount': amount + cappedFee,
      'currency': 'NGN',
    };
  }
}
