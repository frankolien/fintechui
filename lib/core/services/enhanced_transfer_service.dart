import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'paystack_service.dart';
import 'realtime_balance_service.dart';

class EnhancedTransferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PaystackService _paystackService = PaystackService();
  final RealtimeBalanceService _realtimeBalanceService = RealtimeBalanceService();

  /// Add money to user's wallet via Paystack
  Future<Map<String, dynamic>> addMoneyToWallet({
    required double amount,
    required String email,
    String? description,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      if (amount <= 0) throw Exception('Amount must be greater than 0');

      // Generate unique reference
      final reference = _paystackService.generateReference();
      
      // Initialize Paystack transaction
      final paystackResponse = await _paystackService.initializeTransaction(
        email: email,
        amount: amount,
        reference: reference,
        metadata: {
          'user_id': currentUser.uid,
          'type': 'wallet_funding',
          'description': description ?? 'Wallet funding',
        },
      );

      // Save pending transaction to Firestore
      await _firestore.collection('pending_transactions').doc(reference).set({
        'reference': reference,
        'user_id': currentUser.uid,
        'email': email,
        'amount': amount,
        'type': 'wallet_funding',
        'description': description ?? 'Wallet funding',
        'status': 'pending',
        'paystack_response': paystackResponse,
        'created_at': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'reference': reference,
        'authorization_url': paystackResponse['data']['authorization_url'],
        'access_code': paystackResponse['data']['access_code'],
        'message': 'Transaction initialized successfully',
      };
    } catch (e) {
      throw Exception('Failed to add money to wallet: $e');
    }
  }

  /// Verify and complete wallet funding transaction
  Future<void> verifyWalletFunding(String reference) async {
    try {
      print('Starting verification for reference: $reference');
      
      // Get pending transaction
      final pendingDoc = await _firestore.collection('pending_transactions').doc(reference).get();
      if (!pendingDoc.exists) {
        print('Pending transaction not found for reference: $reference');
        throw Exception('Transaction not found');
      }

      final pendingData = pendingDoc.data()!;
      final userId = pendingData['user_id'] as String;
      final amount = (pendingData['amount'] as num).toDouble();
      
      print('Found pending transaction: User $userId, Amount: $amount');

      // Verify with Paystack
      print('Verifying with Paystack...');
      final verificationResponse = await _paystackService.verifyTransaction(reference);
      final status = verificationResponse['data']['status'];
      
      print('Paystack verification response status: $status');

      if (status == 'success') {
        print('Transaction successful! Updating balance...');
        
        // Transaction successful - update user balance using real-time service
        await _realtimeBalanceService.processPayment(
          type: 'credit',
          amount: amount,
          description: pendingData['description'] ?? 'Wallet funding',
          metadata: {
            'reference': reference,
            'paystack_data': verificationResponse['data'],
            'source': 'paystack',
          },
        );

        // Update pending transaction status
        await _firestore.collection('pending_transactions').doc(reference).update({
          'status': 'completed',
          'verified_at': FieldValue.serverTimestamp(),
          'paystack_verification': verificationResponse,
        });
        
        print('Wallet funding verification completed successfully!');
      } else {
        print('Transaction failed with status: $status');
        
        // Transaction failed
        await _firestore.collection('pending_transactions').doc(reference).update({
          'status': 'failed',
          'verified_at': FieldValue.serverTimestamp(),
          'paystack_verification': verificationResponse,
        });
        
        final errorMessage = verificationResponse['data']['gateway_response'] ?? 'Payment failed';
        throw Exception('Transaction failed: $errorMessage');
      }
    } catch (e) {
      print('Error verifying wallet funding: $e');
      throw Exception('Failed to verify wallet funding: $e');
    }
  }

  /// Transfer money to bank account via Paystack
  Future<Map<String, dynamic>> transferToBank({
    required String accountNumber,
    required String bankCode,
    required String accountName,
    required double amount,
    required String reason,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      if (amount <= 0) throw Exception('Amount must be greater than 0');

      // Check user balance
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) throw Exception('User not found');
      
      final currentBalance = (userDoc.data()!['balance'] as num).toDouble();
      if (currentBalance < amount) throw Exception('Insufficient balance');

      // Validate bank account details first
      print('Validating bank account: $accountNumber with bank code: $bankCode');
      final validationResponse = await _paystackService.validateBankAccount(
        accountNumber: accountNumber,
        bankCode: bankCode,
      );
      
      // Use the validated account name from Paystack
      final validatedAccountName = validationResponse['data']['account_name'] ?? accountName;
      print('Validated account name: $validatedAccountName');

      // Create transfer recipient with validated details
      final recipientResponse = await _paystackService.createTransferRecipient(
        type: 'nuban',
        name: validatedAccountName,
        accountNumber: accountNumber,
        bankCode: bankCode,
        description: 'Bank transfer recipient',
      );

      final recipientCode = recipientResponse['data']['recipient_code'];

      // Initiate transfer
      final transferResponse = await _paystackService.initiateTransfer(
        source: 'balance',
        amount: amount,
        recipient: recipientCode,
        reason: reason,
      );

      // Update user balance and create transaction record using real-time service
      await _realtimeBalanceService.processPayment(
        type: 'debit',
        amount: amount,
        description: reason,
        metadata: {
          'recipient_account': accountNumber,
          'recipient_bank': bankCode,
          'recipient_name': accountName,
          'paystack_transfer_code': transferResponse['data']['transfer_code'],
          'source': 'bank_transfer',
        },
      );

      return {
        'success': true,
        'transfer_code': transferResponse['data']['transfer_code'],
        'message': 'Transfer initiated successfully',
      };
    } catch (e) {
      throw Exception('Failed to transfer to bank: $e');
    }
  }

  /// Transfer money between app users
  Future<void> transferToUser({
    required String recipientUid,
    required double amount,
    required String description,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      if (amount <= 0) throw Exception('Amount must be greater than 0');

      // Use a batch write for atomic transaction
      final batch = _firestore.batch();

      // Get current user's document
      final senderDoc = _firestore.collection('users').doc(currentUser.uid);
      final senderSnapshot = await senderDoc.get();
      
      if (!senderSnapshot.exists) throw Exception('Sender not found');
      
      final senderBalance = (senderSnapshot.data()!['balance'] as num).toDouble();
      
      if (senderBalance < amount) throw Exception('Insufficient balance');

      // Get recipient's document
      final recipientDoc = _firestore.collection('users').doc(recipientUid);
      final recipientSnapshot = await recipientDoc.get();
      
      if (!recipientSnapshot.exists) throw Exception('Recipient not found');

      // Update sender's balance using real-time service
      await _realtimeBalanceService.processPayment(
        type: 'debit',
        amount: amount,
        description: 'Transfer to ${recipientSnapshot.data()!['username']}',
        recipientEmail: recipientSnapshot.data()!['email'],
        recipientName: recipientSnapshot.data()!['username'],
        metadata: {
          'recipientId': recipientUid,
          'transfer_type': 'user_to_user',
        },
      );

      // Update recipient's balance using real-time service
      await _realtimeBalanceService.processPayment(
        type: 'credit',
        amount: amount,
        description: 'Transfer from ${senderSnapshot.data()!['username']}',
        metadata: {
          'senderId': currentUser.uid,
          'transfer_type': 'user_to_user',
        },
      );

      // Create transaction record
      final transactionId = _firestore.collection('transactions').doc().id;
      batch.set(_firestore.collection('transactions').doc(transactionId), {
        'id': transactionId,
        'senderId': currentUser.uid,
        'senderUsername': senderSnapshot.data()!['username'],
        'recipientId': recipientUid,
        'recipientUsername': recipientSnapshot.data()!['username'],
        'amount': amount,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed',
      });

      // Add to sender's transaction history
      batch.set(
        _firestore.collection('users').doc(currentUser.uid).collection('transactions').doc(transactionId),
        {
          'id': transactionId,
          'type': 'sent',
          'amount': amount,
          'recipientId': recipientUid,
          'recipientUsername': recipientSnapshot.data()!['username'],
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
        },
      );

      // Add to recipient's transaction history
      batch.set(
        _firestore.collection('users').doc(recipientUid).collection('transactions').doc(transactionId),
        {
          'id': transactionId,
          'type': 'received',
          'amount': amount,
          'senderId': currentUser.uid,
          'senderUsername': senderSnapshot.data()!['username'],
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Transfer failed: $e');
    }
  }

  /// Get user's current balance
  Future<double> getCurrentUserBalance() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) throw Exception('User document not found');

      return (doc.data()!['balance'] as num).toDouble();
    } catch (e) {
      throw Exception('Failed to get balance: $e');
    }
  }

  /// Get user's transaction history
  Stream<List<Map<String, dynamic>>> getTransactionHistory() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Get user's current balance as a stream
  Stream<double> getBalanceStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0.0);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 0.0;
      return (snapshot.data()!['balance'] as num).toDouble();
    });
  }

  /// Check for pending wallet funding transactions that need verification
  Future<List<Map<String, dynamic>>> getPendingWalletFundingTransactions() async {
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
              transaction['type'] == 'wallet_funding' && 
              transaction['status'] == 'pending')
          .toList();

      return filteredTransactions;
    } catch (e) {
      print('Error getting pending transactions: $e');
      return [];
    }
  }

  /// Verify all pending wallet funding transactions
  Future<void> verifyAllPendingTransactions() async {
    try {
      final pendingTransactions = await getPendingWalletFundingTransactions();
      
      for (final transaction in pendingTransactions) {
        final reference = transaction['reference'] as String;
        try {
          await verifyWalletFunding(reference);
          print('Successfully verified transaction: $reference');
        } catch (e) {
          print('Failed to verify transaction $reference: $e');
          // Continue with other transactions even if one fails
        }
      }
    } catch (e) {
      print('Error verifying all pending transactions: $e');
      rethrow;
    }
  }

  /// Verify bank account details
  Future<Map<String, dynamic>> verifyBankAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      print('🔍 Enhanced Transfer Service: Verifying account $accountNumber with bank $bankCode');
      
      final validationResponse = await _paystackService.validateBankAccount(
        accountNumber: accountNumber,
        bankCode: bankCode,
      );
      
      print('✅ Enhanced Transfer Service: Validation successful: $validationResponse');
      
      return {
        'success': true,
        'account_name': validationResponse['data']['account_name'],
        'account_number': validationResponse['data']['account_number'],
        'bank_code': validationResponse['data']['bank_code'],
      };
    } catch (e) {
      print('❌ Enhanced Transfer Service: Validation failed: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get supported banks from Paystack
  Future<List<Map<String, dynamic>>> getSupportedBanks() async {
    try {
      print('🔍 Enhanced Transfer Service: Getting supported banks from Paystack...');
      final banks = await _paystackService.getSupportedBanks();
      print('📊 Enhanced Transfer Service: Retrieved ${banks.length} banks from Paystack');
      return banks;
    } catch (e) {
      print('❌ Enhanced Transfer Service: Error getting banks: $e');
      rethrow;
    }
  }

  /// Search for users by username or email
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      // Search by username
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + '\uf8ff')
          .limit(10)
          .get();

      // Search by email
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThan: query + '\uf8ff')
          .limit(10)
          .get();

      Set<String> seenIds = {};
      List<Map<String, dynamic>> users = [];

      // Combine results and remove duplicates
      for (var doc in [...usernameQuery.docs, ...emailQuery.docs]) {
        if (doc.id != currentUser.uid && !seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          users.add({
            'uid': doc.id,
            'username': doc.data()['username'],
            'email': doc.data()['email'],
          });
        }
      }

      return users;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}
