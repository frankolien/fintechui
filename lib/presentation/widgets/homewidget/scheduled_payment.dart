import 'package:flutter/material.dart';

class ScheduledPayment extends StatelessWidget {
  static final List<Payment> payments =[
    Payment(
        title: "Netflix",
        icon: Image.asset('lib/images/netflix.png'),
        date: "12/04",
        amount: 1.00,
    ),
    Payment(
      title: "Paypal",
      icon: Image.asset('lib/images/paypal.png'),
      date: "14/07",
      amount: 3.50,
    ),
    Payment(
      title: "Spotify",
      icon: Image.asset('lib/images/spotify.png'),
      date: "13/03",
      amount: 1.00,
    ),
  ];
   ScheduledPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: payments.map((payment) =>
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: payment.icon,
            title: Text(
              payment.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Next payment: ${payment.date}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${payment.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
      ).toList(),
    );
  }
}



class Payment{
  final String title;
  final Image icon;
  final String date;
  final double amount;
  Payment({
    required this.title,
    required this.icon,
    required this.date,
    required this.amount,
  });

}