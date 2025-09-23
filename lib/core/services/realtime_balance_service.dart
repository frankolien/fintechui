import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for managing real-time balance updates
class RealtimeBalanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  StreamSubscription<DocumentSnapshot>? _balanceSubscription;
  StreamSubscription<QuerySnapshot>? _transactionSubscription;
  
  // Stream controllers for real-time updates
  final StreamController<double> _balanceController = StreamController<double>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _transactionController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();
  
  // Getters for streams
  Stream<double> get balanceStream => _balanceController.stream;
  Stream<List<Map<String, dynamic>>> get transactionStream => _transactionController.stream;
  
  double _currentBalance = 0.0;
  List<Map<String, dynamic>> _currentTransactions = [];
  
  double get currentBalance => _currentBalance;
  List<Map<String, dynamic>> get currentTransactions => _currentTransactions;
  
  /// Initialize real-time listeners for the current user
  Future<void> initializeRealtimeUpdates() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    // Listen to balance changes
    _balanceSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final balance = (data['balance'] ?? 0.0).toDouble();
        _currentBalance = balance;
        _balanceController.add(balance);
        print('Real-time balance updated: ₦${balance.toStringAsFixed(2)}');
      }
    });
    
    // Listen to transaction history changes
    _transactionSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .limit(50) // Limit to last 50 transactions for performance
        .snapshots()
        .listen((snapshot) {
      final transactions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      _currentTransactions = transactions;
      _transactionController.add(transactions);
      print('Real-time transactions updated: ${transactions.length} transactions');
    });
  }
  
  /// Update balance in Firestore (this will trigger real-time updates)
  Future<void> updateBalance(double newBalance, {String? reason}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'balance': newBalance,
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastUpdateReason': reason ?? 'Balance update',
      });
      
      print('Balance updated to ₦${newBalance.toStringAsFixed(2)}');
    } catch (e) {
      print('Error updating balance: $e');
      rethrow;
    }
  }
  
  /// Add a transaction record (this will trigger real-time updates)
  Future<void> addTransaction({
    required String type, // 'credit', 'debit', 'transfer'
    required double amount,
    required String description,
    String? recipientEmail,
    String? recipientName,
    String? reference,
    Map<String, dynamic>? metadata,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      final transactionData = {
        'type': type,
        'amount': amount,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'userEmail': user.email,
        'status': 'completed',
        'reference': reference ?? _generateReference(),
        'metadata': metadata ?? {},
      };
      
      if (recipientEmail != null) {
        transactionData['recipientEmail'] = recipientEmail;
      }
      if (recipientName != null) {
        transactionData['recipientName'] = recipientName;
      }
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .add(transactionData);
      
      print('Transaction added: $type ₦${amount.toStringAsFixed(2)} - $description');
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }
  
  /// Process a payment and update balance in real-time
  Future<bool> processPayment({
    required String type,
    required double amount,
    required String description,
    String? recipientEmail,
    String? recipientName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Calculate new balance
      double newBalance = _currentBalance;
      if (type == 'credit') {
        newBalance += amount;
      } else if (type == 'debit' || type == 'transfer') {
        if (newBalance < amount) {
          throw Exception('Insufficient funds');
        }
        newBalance -= amount;
      }
      
      // Update balance
      await updateBalance(newBalance, reason: '$type transaction');
      
      // Add transaction record
      await addTransaction(
        type: type,
        amount: amount,
        description: description,
        recipientEmail: recipientEmail,
        recipientName: recipientName,
        metadata: metadata,
      );
      
      return true;
    } catch (e) {
      print('Error processing payment: $e');
      return false;
    }
  }
  
  /// Get current balance from Firestore
  Future<double> getCurrentBalance() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final balance = (doc.data()?['balance'] ?? 0.0).toDouble();
        _currentBalance = balance;
        return balance;
      }
      return 0.0;
    } catch (e) {
      print('Error getting current balance: $e');
      return 0.0;
    }
  }
  
  /// Get transaction history
  Future<List<Map<String, dynamic>>> getTransactionHistory({int limit = 50}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting transaction history: $e');
      return [];
    }
  }
  
  /// Generate a unique reference for transactions
  String _generateReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'TXN${timestamp}${random}';
  }
  
  /// Dispose resources
  void dispose() {
    _balanceSubscription?.cancel();
    _transactionSubscription?.cancel();
    _balanceController.close();
    _transactionController.close();
  }
}

/// Provider for RealtimeBalanceService
final realtimeBalanceServiceProvider = Provider<RealtimeBalanceService>((ref) {
  return RealtimeBalanceService();
});

/// Provider for current balance stream
final balanceStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(realtimeBalanceServiceProvider);
  return service.balanceStream;
});

/// Provider for transaction history stream
final transactionStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(realtimeBalanceServiceProvider);
  return service.transactionStream;
});
