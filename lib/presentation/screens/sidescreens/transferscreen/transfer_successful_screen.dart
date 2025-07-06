import 'package:fintechui/presentation/screens/homepage/home_page.dart';
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
   TransferSuccessfulScreen({
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
  State<TransferSuccessfulScreen> createState() => _TransferSuccessfulScreenState();
}

class _TransferSuccessfulScreenState extends State<TransferSuccessfulScreen> {
  void _showReceiptModal(
  BuildContext context, {
  required String recipientName,
  required String recipientAccount,
  required double transferAmount,
  required String cardType,
  required double transferFee,
}) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.46,
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 30,
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            SizedBox(height: 16),
            Text(
              recipientName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              recipientAccount,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Transaction Status: Sent",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[800],
                ),
              ),
            ),
            SizedBox(height: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '\$${transferAmount}',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: 'USD',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Card Type",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  cardType,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "SF Pro Text",
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transfer Fee",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  "\$${transferFee}",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "SF Pro Text",
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: Colors.white,
        leading: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const ProfilePage())),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Icon(Icons.person,color: Colors.grey[600],size: 30,)),
                ),
              ),
            ),
            Positioned(
              right: 8, // Adjust position as needed
              top: 8, // Adjust position as needed
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors
                        .white, // Optional: for a white border around the dot
                    width: 1, // Optional: border width
                  ),
                ),
                constraints: BoxConstraints(
                  minWidth: 12, // Size of the dot
                  minHeight: 12, // Size of the dot
                ),
              ),
            ),
          ],
        ),
        title: Text(
          "Confirmation",
          style: TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.w500
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.notification_add,color: Colors.grey[600],),
            ),
          )
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
             color: Colors.blue
           ),
         ),
         SizedBox(height: 10),
         Text(
           "Your money has been tranfered successfuly",
           style: TextStyle(
             fontSize: 17,
             color: Colors.grey[600],
           ),
              
         ),
         Spacer(), // Pushes the image to the center
         Image.asset(
           'lib/images/succesful.png',
           width: 367.8594055175781,
           height: 302,
         ),
         Spacer(), // Pushes the button down, but not to the very bottom
         Container(
           width: double.infinity,
           padding: EdgeInsets.symmetric(horizontal: 20),
           child: ElevatedButton(
             onPressed: () {
               _showReceiptModal(
                 context,
                 recipientName: widget.recipientName ?? "Unknown",
                 recipientAccount: widget.recipientAccount ?? "Unknown",
                 transferAmount: double.tryParse(widget.transferAmount ?? "0") ?? 0.0,
                 cardType: widget.cardType ?? "Debit Card",
                 transferFee: double.tryParse(widget.transferFee ?? "0") ?? 0.0,
               );
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.blue,
               padding: EdgeInsets.symmetric(horizontal: 50, vertical: 22),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(14),
               ),
             ),
             child: Text(
               "View Receipt",
               style: TextStyle(
                 fontSize: 20,
                 color: Colors.white,
               ),
             ),
           ),
         ),
         SizedBox(height: 30), // Adds space below the button
       ],
                ),
              ),
      
    );
  }
}
