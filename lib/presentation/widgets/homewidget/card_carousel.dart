import 'package:flutter/material.dart';

import 'atm_card.dart';
class CardCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> cards = [
    {
      'balance': 4228.76,
      'number': '****  ****  ****  8635',
      'holder': 'Frank olien ',
      'color': Colors.blue.shade700,
    },
    {
      'balance': 2129.33,
      'number': '****  ****  ****  5678',
      'holder': 'Alice Smith',
      'color': Colors.red.shade700,
    },
    {
      'balance': 2323.32,
      'number': '****  ****  ****  9012',
      'holder': 'Robert Johnson',
      'color': Colors.green.shade700,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Fixed height for the carousel
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return AtmCard(
            availableBalance: cards[index]['balance'],
            cardNumber: cards[index]['number'],
            cardHolder: cards[index]['holder'],
            //color: cards[index]['color'],
          );
        },
      ),
    );
  }
}