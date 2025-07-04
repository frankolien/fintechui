import 'package:flutter/material.dart';

class TransferConfirmationScreen2 extends StatelessWidget {
final String? transferAmount;
final String? recipientName;
final String? recipientAccount;
final String? transferFee;
final String? cardType;

   TransferConfirmationScreen2({
    super.key,
    this.transferAmount,
    this.recipientName,
    this.recipientAccount,
    this.transferFee,
    this.cardType = 'Debit Card',
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Confirmation',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_outlined, color: Colors.black54),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Stack(
        children:[  
              Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Are you sure?",
              style: TextStyle(
                color: Color(0xFF5B7CFF),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "We care about your privacy. please make sure that you want to transfer the money.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 17,
                  //letterSpacing: 1
                ),
              ),
            ),

            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shadowColor: Colors.blue,
                elevation: 20,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    //color: Colors.grey[200],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  /*child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Transfer Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Recipient Name: $recipientName"),
                      Text("Recipient Account: $recipientAccount"),
                      Text("Transfer Amount: \$$transferAmount"),
                      Text("Transfer Fee: \$$transferFee"),
                      Text("Card Type: $cardType"),
                    ],
                  ),*/
                  child: Column(
                    children: [
                      SizedBox(height: 45),
                      Text(
                        recipientName ?? "Recipient Name",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        recipientAccount ?? "Recipient Account",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700]
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.pink[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Transaction Status: Pending",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.pink[300]
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    RichText(
                          text: TextSpan(
                            children: [
                TextSpan(
                  text: '\$$transferAmount',
                  style: TextStyle(
                    fontSize:  30 ,
                    fontWeight:   FontWeight.w500 ,
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
                        SizedBox(height:20),
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
                      "$cardType",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "SF Pro Text",
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ]
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
                      "\$$transferFee",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "SF Pro Text",
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ]
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){}, 
                  style: ElevatedButton.styleFrom(
                   backgroundColor: Color(0xFF5B7CFF),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: 
                  Text(
                    "Send Money",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
          
          Positioned(
            left: 152,
            top: 130,
            child: Card(
            
              shadowColor: Colors.blue,
              elevation: 5,
              child: CircleAvatar(
                radius:  40,
                backgroundColor: Colors.grey[100],
                    
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
      
        ]
      ),
    );
  }
}