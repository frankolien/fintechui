import 'package:fintechui/presentation/screens/sidescreens/transferscreen/transfer_confirmation_screen.dart';
import 'package:fintechui/presentation/widgets/recent_transfer_card.dart';
import 'package:flutter/material.dart';

class MoneyTransfer extends StatefulWidget {
  const MoneyTransfer({super.key});

  @override
  State<MoneyTransfer> createState() => _MoneyTransferState();
}

class _MoneyTransferState extends State<MoneyTransfer> {
  void quickAction(int index) {
    setState(() {
      _selectedQuickAmount = index;
      double currentAmount = double.tryParse(_amountController.text) ?? 0;
      double quickAmount = double.parse(_quickAmounts[index].substring(1)); // Remove $ sign
      double newAmount = currentAmount + quickAmount;
      _amountController.text = newAmount.toStringAsFixed(0); // Remove decimal if whole number
      _enteredAmount = _amountController.text;
    });
  }

  bool _isPasswordVisible = true;
  String _enteredAmount = '';

  void enterAmount(String value) {
    setState(() {
      _enteredAmount = value;
      _amountController.text = value;
    });
  }

  // Controllers - Fixed: Using correct controllers for each field
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final List<String> _quickAmounts = ["\$100", "\$150", "\$200"]; 
  int _selectedQuickAmount = -1;

  final List<RecentTransfer> _recentTransfer = [
    RecentTransfer(
      image: Image.asset("lib/images/image_1.png"), 
      name: "Dr.kamal", 
      amount: "\$40.00"
    ),
    RecentTransfer(
      image: Image.asset("lib/images/image_2.png"), 
      name: "Jonathan", 
      amount: "\$26.45"
    ),
    RecentTransfer(
      image: Image.asset("lib/images/image_3.png"), 
      name: "Will hoper", 
      amount: "\$560.00"
    ),
    RecentTransfer(
      image: Image.asset("lib/images/apple.png"), 
      name: "David", 
      amount: "\$12.75"
    )
  ];

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _searchController.dispose();
    _nameController.dispose();
    _accountController.dispose();
    _mobileController.dispose();
    _purposeController.dispose();
    _passwordController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Money Transfer"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search widget 
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _searchController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Recent transfers section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Recent Transfers",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                itemCount: _recentTransfer.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(left: 16),
                    width: 135,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _recentTransfer[index].image,
                            SizedBox(height: 8),
                            Text(
                              _recentTransfer[index].name,
                              style: TextStyle(
                                fontSize: 13, 
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _recentTransfer[index].amount,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),
            SizedBox(height: 16),
            // Make new transfer section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Make new transfer",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 8),
            // Form fields - Fixed: Using correct controllers
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  // Name field
                  _buildTextField(_nameController, "Name", TextInputType.text),
                  SizedBox(height: 16),
                  
                  // Account Number field
                  _buildTextField(_accountController, "Enter Account Number", TextInputType.number),
                  SizedBox(height: 16),
                  
                  // Mobile Number field
                  _buildTextField(_mobileController, "Receiver's Mobile Number", TextInputType.phone),
                  SizedBox(height: 16),
                  
                  // Purpose field
                  _buildTextField(_purposeController, "Purpose of payment (Optional)", TextInputType.text),
                  SizedBox(height: 16),
                  
                  // Password field
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    width: double.infinity,
                    child: TextFormField(
                      obscureText: _isPasswordVisible,
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        hintText: "Password",                    
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey[500],
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.fingerprint,
                                color: Colors.grey[500],
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16), 
                  
                  // Continue button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showAmountModal(context);
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
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

//textformfield 
  Widget _buildTextField(TextEditingController controller, String hintText, TextInputType keyboardType) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: TextFormField(
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

  // Fixed modal bottom sheet
  void _showAmountModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Enter Amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 65,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF5B7CFF)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setModalState(() {
                            _enteredAmount = value;
                            _selectedQuickAmount = -1; // Reset quick selection
                          });
                        },
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5B7CFF),
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Amount',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ),
                    // Quick Actions
                    SizedBox(height: 24),
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _quickAmounts.map((amount) {
                        int index = _quickAmounts.indexOf(amount);
                        bool isSelected = _selectedQuickAmount == index;  
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              double currentAmount = double.tryParse(_amountController.text) ?? 0;
                              double quickAmount = double.parse(amount.substring(1)); // Remove $ sign
                              double newAmount = currentAmount + quickAmount;
                              _amountController.text = newAmount.toStringAsFixed(0);
                              _enteredAmount = _amountController.text;
                              _selectedQuickAmount = index;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? Color(0xFF5B7CFF) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected ? Border.all(color: Color(0xFF5B7CFF)) : null,
                            ),
                            child: Text(
                              amount,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    Spacer(),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          /*if (_nameController.text.isEmpty || 
                              _accountController.text.isEmpty || 
                              _amountController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please fill all fields'))
                            );
                            return;
                          }*/
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => TransferConfirmationScreen(
                              recipientName: _nameController.text,
                              recipientAccount: _accountController.text,
                              transferAmount: _amountController.text,
                            )
                          ));
                          // Handle transfer logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5B7CFF),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Confirm Transfer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}