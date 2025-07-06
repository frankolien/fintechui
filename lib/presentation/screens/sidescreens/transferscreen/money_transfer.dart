// money_transfer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fintechui/core/services/transfer_service.dart';
import 'transfer_confirmation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecentTransfer {
  final Widget image;
  final String name;
  final String amount;

  RecentTransfer({
    required this.image,
    required this.name,
    required this.amount,
  });
}

class MoneyTransfer extends StatefulWidget {
  const MoneyTransfer({super.key});

  @override
  State<MoneyTransfer> createState() => _MoneyTransferState();
}

class _MoneyTransferState extends State<MoneyTransfer> {
  //to verify password 
  Future<bool> _verifyPassword (String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if(user ==null) return false;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    try {
      await user.reauthenticateWithCredential(cred);
      return true;
    } catch (e) {
      return false;
    }
  }

  final TransferService _transferService = TransferService();
  
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // State variables
  List<Map<String, dynamic>>_searchResults = [];
  Map<String, dynamic>? _selectedRecipient;
  bool _isSearching = false;
  bool _isPasswordVisible = true;
  String _enteredAmount = '';
  double _currentBalance = 0.0;

  final List<String> _quickAmounts = ["\$100", "\$150", "\$200"]; 
  int _selectedQuickAmount = -1;

  // Recent transfers (first 4 are mock, new ones will be added at the top)
  List<RecentTransfer> _recentTransfer = [
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
  void initState() {
    super.initState();
    _loadCurrentBalance();
  }

  Future<void> _loadCurrentBalance() async {
    try {
      final balance = await _transferService.getCurrentUserBalance();
      setState(() {
        _currentBalance = balance;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading balance: $e')),
      );
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _selectedRecipient = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _transferService.searchUsers(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching users: $e')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void quickAction(int index) {
    setState(() {
      _selectedQuickAmount = index;
      double currentAmount = double.tryParse(_amountController.text) ?? 0;
      double quickAmount = double.parse(_quickAmounts[index].substring(1));
      double newAmount = currentAmount + quickAmount;
      _amountController.text = newAmount.toStringAsFixed(0);
      _enteredAmount = _amountController.text;
    });
  }

  // Add recipient to recent transfers
  void _addToRecentTransfers(Map<String, dynamic> recipient, String amount) {
    setState(() {
      _recentTransfer.insert(
        0,
        RecentTransfer(
          image: CircleAvatar(
            child: Text(recipient['username'][0].toUpperCase()),
            backgroundColor: Colors.blue.shade100,
          ),
          name: recipient['username'],
          amount: "\$$amount",
        ),
      );
      // Optional: Limit to last 10
      if (_recentTransfer.length > 10) {
        _recentTransfer.removeLast();
      }
    });
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
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance Display
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\$${_currentBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search widget 
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
                  onChanged: _searchUsers,
                  decoration: InputDecoration(
                    hintText: "Search by username or email",
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    suffixIcon: _isSearching
                        ? Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),

            // Search Results
            if (_searchResults.isNotEmpty)
              Container(
                height: 100,
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    final isSelected = _selectedRecipient?['uid'] == user['uid'];
                    
                    return Card(
                      color: isSelected ? Colors.blue.shade50 : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(user['username'][0].toUpperCase()),
                        ),
                        title: Text(user['username']),
                        subtitle: Text(user['email']),
                        trailing: isSelected 
                            ? Icon(Icons.check_circle, color: Colors.blue)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedRecipient = user;
                          });
                        },
                      ),
                    );
                  },
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

            if (_selectedRecipient != null) ...[
              SizedBox(height: 16),
              // Make new transfer section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Transfer to ${_selectedRecipient!['username']}",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 8),
              // Form fields
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
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
          ],
        ),
      ),
    );
  }

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
        return _AmountModalContent(
          currentBalance: _currentBalance,
          selectedRecipient: _selectedRecipient,
          amountController: _amountController,
          quickAmounts: _quickAmounts,
          selectedQuickAmount: _selectedQuickAmount,
          purposeController: _purposeController,
          addToRecentTransfers: _addToRecentTransfers, // Pass the callback
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _purposeController.dispose();
    _passwordController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

// Modal content widget
class _AmountModalContent extends StatefulWidget {
  final double currentBalance;
  final Map<String, dynamic>? selectedRecipient;
  final TextEditingController amountController;
  final List<String> quickAmounts;
  final int selectedQuickAmount;
  final TextEditingController purposeController;
  final void Function(Map<String, dynamic>, String) addToRecentTransfers;

  const _AmountModalContent({
    required this.currentBalance,
    required this.selectedRecipient,
    required this.amountController,
    required this.quickAmounts,
    required this.selectedQuickAmount,
    required this.purposeController,
    required this.addToRecentTransfers,
  });

  @override
  State<_AmountModalContent> createState() => _AmountModalContentState();
}

class _AmountModalContentState extends State<_AmountModalContent> {
  String? amountError;
  int selectedQuickAmount = -1;

  @override
  void initState() {
    super.initState();
    selectedQuickAmount = widget.selectedQuickAmount;
  }

  @override
  Widget build(BuildContext context) {
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
                controller: widget.amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  setState(() {
                    amountError = null;
                    selectedQuickAmount = -1;
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
            if (amountError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                child: Text(
                  amountError!,
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
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
              children: widget.quickAmounts.map((amount) {
                int index = widget.quickAmounts.indexOf(amount);
                bool isSelected = selectedQuickAmount == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      double currentAmount = double.tryParse(widget.amountController.text) ?? 0;
                      double quickAmount = double.parse(amount.substring(1));
                      double newAmount = currentAmount + quickAmount;
                      widget.amountController.text = newAmount.toStringAsFixed(0);
                      selectedQuickAmount = index;
                      amountError = null;
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
                  if (widget.selectedRecipient == null) {
                    setState(() {
                      amountError = 'Please select a recipient';
                    });
                    return;
                  }
                  final amount = double.tryParse(widget.amountController.text);
                  if (amount == null || amount <= 0) {
                    setState(() {
                      amountError = 'Please enter a valid amount';
                    });
                    return;
                  }
                  if (amount > widget.currentBalance) {
                    setState(() {
                      amountError = 'Insufficient balance';
                    });
                    return;
                  }
                  // Add to recent transfers before navigating
                  widget.addToRecentTransfers(widget.selectedRecipient!, widget.amountController.text);

                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => TransferConfirmationScreen(
                      recipientName: widget.selectedRecipient!['username'],
                      recipientAccount: widget.selectedRecipient!['email'],
                      transferAmount: widget.amountController.text,
                      recipientUid: widget.selectedRecipient!['uid'],
                      purpose: widget.purposeController.text,
                    ),
                  ));
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
  }
}