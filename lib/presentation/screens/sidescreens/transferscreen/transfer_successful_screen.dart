import 'package:fintechui/presentation/screens/profile/user_profile.dart';
import 'package:flutter/material.dart';

class TransferSuccessfulScreen extends StatefulWidget {
  final String? transferAmount;
  final String? recipientName;
  final String? recipientAccount;
  final String? recipientUid;
  final String? purpose;
  final String? transferFee;
  final String? cardType;

  const TransferSuccessfulScreen({
    super.key,
    this.transferAmount,
    this.recipientName,
    this.recipientAccount,
    this.recipientUid,
    this.purpose,
    this.transferFee,
    this.cardType,
  });

  @override
  State<TransferSuccessfulScreen> createState() =>
      _TransferSuccessfulScreenState();
}

class _TransferSuccessfulScreenState extends State<TransferSuccessfulScreen> {
  void _showReceiptDraggableSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 30,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.recipientName ?? "Unknown",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.recipientAccount ?? "Unknown",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12),
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Transaction Status: Sent",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '\$${widget.transferAmount ?? "0.00"}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(
                          text: ' USD',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Card Type",
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey[700])),
                      Text(widget.cardType ?? "Debit Card",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Transfer Fee",
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey[700])),
                      Text("\$${widget.transferFee ?? "0.00"}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Confirmation",
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const ProfilePage())),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, color: Colors.grey[600], size: 30),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.notification_add, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(
              "Transfer Successful",
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue),
            ),
            SizedBox(height: 10),
            Text(
              "Your money has been transferred successfully",
              style: TextStyle(fontSize: 17, color: Colors.grey[600]),
            ),
            Spacer(),
            Image.asset(
              'lib/images/succesful.png',
              width: 350,
              height: 300,
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () => _showReceiptDraggableSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Center(
                  child: Text(
                    "View Receipt",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
