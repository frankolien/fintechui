// transfer_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize user balance when they first sign up
  Future<void> initializeUserBalance(String uid, String username, String email) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'username': username,
        'email': email,
        'balance': 0.0, // Start with zero balance
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to initialize user: $e');
    }
  }

  // Get current user's balance
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

  // Search for users by username or email
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

  // Transfer money between users
  Future<void> transferMoney({
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
      
      final recipientBalance = (recipientSnapshot.data()!['balance'] as num).toDouble();

      // Update balances
      batch.update(senderDoc, {'balance': senderBalance - amount});
      batch.update(recipientDoc, {'balance': recipientBalance + amount});

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

  // Get user's transaction history
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

  // Get user's current balance as a stream
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
}