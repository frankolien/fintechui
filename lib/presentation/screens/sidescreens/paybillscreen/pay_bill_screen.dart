import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fintechui/core/services/transfer_service.dart';

class PayBillScreen extends StatefulWidget {
  const PayBillScreen({super.key});

  @override
  State<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends State<PayBillScreen> {
  String? selectedBill; // Track which bill is selected
 final TextEditingController _companyController = TextEditingController();
 final TextEditingController _referenceNumber = TextEditingController();
 final TextEditingController _passwordController = TextEditingController();

  final TransferService _transferService = TransferService();

  Future<bool> _verifyPassword(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    try {
      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildBillItem({
    required String billType,
    required String imagePath,
    required String title,
  }) {
    bool isSelected = selectedBill == billType;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(16),
        height: 66,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(imagePath),
                SizedBox(width: 30),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w500
                  ),
                )
              ],
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedBill = isSelected ? null : billType;
                });
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                  color: isSelected ? Colors.white : Colors.transparent,
                ),
                child: isSelected
                    ? Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white, 
                    width: 5, 
                  ),
                ),
                constraints: BoxConstraints(
                  minWidth: 1, // Size of the dot
                  minHeight: 1, // Size of the dot
                ),
              )
                    : null,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, TextInputType keyboardType,) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: TextFormField(
        obscureText: hintText.toLowerCase() == "password",
        inputFormatters: hintText.toLowerCase() == "password"
            ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
            : [],
        controller: controller,
        textInputAction: TextInputAction.next,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'Pay Bill',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: IconButton(
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
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Your bills",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 15),
            _buildBillItem(
              billType: "internet",
              imagePath: "lib/images/sss.png",
              title: "Internet Bill",
            ),
            _buildBillItem(
              billType: "electricity",
              imagePath: "lib/images/ssd.png",
              title: "Electricity Bill",
            ),
            _buildBillItem(
              billType: "water",
              imagePath: "lib/images/nnd.png",
              title: "Water Bill",
            ),
            _buildBillItem(
              billType: "others",
              imagePath: "lib/images/category.png",
              title: "Others",
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                  "Your bills",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ),
           Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildTextField(
              _companyController, 
              "Company Name", 
              TextInputType.text,),
              ),
           
               Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildTextField(
              _referenceNumber, 
              "Reference Number", 
              TextInputType.text,),
              ),
           
               Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildTextField(
              _passwordController, 
              "Password", 
              TextInputType.text,),
              ),
              SizedBox(height: 20),
              
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                   child: Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async{
                            if (_passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please enter your password')),
                              );
                              return;
                            }
                            bool valid = await _verifyPassword(_passwordController.text);
                            if(!valid) {
                              ScaffoldMessenger.of(context).showSnackBar( 
                                SnackBar(content: Text('Incorrect password')),
                              );
                              return;
                            }
                            //_showAmountModal(context);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color(0xFF5B7CFF)),
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16)),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            elevation: MaterialStateProperty.all(0),
                          ),
                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                 ),
          

          ],
        ),
      ),
    );
  }
}