// Updated AtmCard to accept color parameter
import 'package:flutter/material.dart';

class AtmCard extends StatelessWidget {
  final double availableBalance;
  final String cardNumber;
  final String cardHolder;
  final Color? cardColor;

  const AtmCard({
    Key? key,
    required this.availableBalance,
    required this.cardNumber,
    required this.cardHolder,
    this.cardColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the passed color or default gradient
    final List<Color> gradientColors = cardColor != null
        ? [
            cardColor!,
            cardColor!.withOpacity(0.8),
            cardColor!.withOpacity(0.6),
          ]
        : [
            Color(0xFF7B83FF),
            Color(0xFF5865FF),
            Color(0xFF4B57FF),
          ];

    return Container(
      width: 345,
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Available balance",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "\$ ${availableBalance.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Image.asset('lib/images/group.png')
            ],
          ),
          SizedBox(height: 10),
          Text(
            cardNumber,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 3,
            ),
          ),
          Row(
            children: [
              Text(
                'Valid from 10/25',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: 25),
              Text(
                'Valid Thru 10/30',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Holder',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    cardHolder,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Image.asset(
                'lib/images/verve.png',
                width: 36,
                height: 22,
              )
            ],
          )
        ],
      ),
    );
  }
}