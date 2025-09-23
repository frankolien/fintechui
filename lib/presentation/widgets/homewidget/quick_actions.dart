import 'package:fintechui/presentation/screens/sidescreens/paybillscreen/pay_bill_screen.dart';
import 'package:fintechui/presentation/screens/sidescreens/transferscreen/money_transfer.dart';
import 'package:fintechui/presentation/screens/sidescreens/unified_fund_wallet_screen.dart';
import 'package:fintechui/presentation/screens/sidescreens/bank_transfer_screen.dart';
import 'package:flutter/material.dart';
class QuickAction {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onTap;

  QuickAction({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    this.onTap,
  });
}

class QuickActionsSection extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final List<QuickAction> quickActions = [
    QuickAction(
      title: 'Fund Wallet',
      icon: Icons.account_balance_wallet,
      backgroundColor: Colors.purple.shade100,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> const UnifiedFundWalletScreen()));
      },
    ),
    QuickAction(
      title: 'Money Transfer',
      icon: Icons.attach_money,
      backgroundColor: Colors.green.shade100,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> MoneyTransfer()));
      },
    ),
    QuickAction(
      title: 'Bank Transfer',
      icon: Icons.account_balance,
      backgroundColor: Colors.orange.shade100,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaystackBankTransferScreen(),
        ),
      ),
    ),
    QuickAction(
      title: 'Pay Bill',
      icon: Icons.receipt_long,
      backgroundColor: Colors.blue.shade100,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> PayBillScreen())),
    ),
  ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          height: 100, // height for horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: quickActions.length,
            itemBuilder: (context, index) {
              final action = quickActions[index];
              return Container(
                width: 110,
                margin: EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: action.onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: action.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            action.icon,
                            color: _getIconColor(action.backgroundColor),
                            size: 24,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          action.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getIconColor(Color backgroundColor) {
    if (backgroundColor == Colors.green.shade100) return Colors.green.shade700;
    if (backgroundColor == Colors.blue.shade100) return Colors.blue.shade700;
    if (backgroundColor == Colors.purple.shade100) return Colors.purple.shade700;
    if (backgroundColor == Colors.orange.shade100) return Colors.orange.shade700;
    if (backgroundColor == Colors.yellow.shade100) return Colors.yellow.shade700;
    return Colors.grey.shade700;
  }
}