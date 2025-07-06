import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'atm_card.dart';

class CardCarousel extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> _getCardsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      String username = snapshot.exists
          ? (snapshot.data()?['username'] ?? user.displayName ?? 'User')
          : user.displayName ?? 'User';

      double realBalance = snapshot.exists && snapshot.data()?['balance'] != null
          ? (snapshot.data()!['balance'] as num).toDouble()
          : 0.0;

      return [
        {
          'balance': realBalance,
          'number': '**** **** **** 8635',
          'holder': username,
          'color': Colors.blue.shade700,
        },
        {
          'balance': 2129.33,
          'number': '**** **** **** 5678',
          'holder': username,
          'color': Colors.red.shade700,
        },
        {
          'balance': 2323.32,
          'number': '**** **** **** 9012',
          'holder': username,
          'color': Colors.green.shade700,
        },
      ];
    }).handleError((error) {
      print('Error in cards stream: $error');
      return [
        {
          'balance': 0.0,
          'number': '**** **** **** 8635',
          'holder': 'User',
          'color': Colors.blue.shade700,
        },
        {
          'balance': 2129.33,
          'number': '**** **** **** 5678',
          'holder': 'User',
          'color': Colors.red.shade700,
        },
        {
          'balance': 2323.32,
          'number': '**** **** **** 9012',
          'holder': 'User',
          'color': Colors.green.shade700,
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getCardsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading cards',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          
          final cards = snapshot.data ?? [];
          
          if (cards.isEmpty) {
            return Center(
              child: Text(
                'No cards available',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          
          return ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return AtmCard(
                availableBalance: cards[index]['balance'],
                cardNumber: cards[index]['number'],
                cardHolder: cards[index]['holder'],
                cardColor: cards[index]['color'],
              );
            },
          );
        },
      ),
    );
  }
}