import 'package:fintechui/core/models/bank_model.dart';
import 'package:fintechui/presentation/screens/sidescreens/paybillscreen/bank_payment_confirmation_screen.dart';
import 'package:fintechui/presentation/screens/sidescreens/transferscreen/transfer_confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AccountDetailsScreen extends StatefulWidget {
  final BankModel selectedBank;
  
  const AccountDetailsScreen({
    Key? key, required this.selectedBank,
    
  }) : super(key: key);

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  
  String _accountName = '';
  bool _isVerifyingAccount = false;
  bool _accountVerified = false;
  String _verificationError = '';
  
  final List<String> _quickAmounts = ['100', '150', '200'];
  String _selectedQuickAmount = '150';
  
  @override
  void initState() {
    super.initState();
    _accountNumberController.addListener(_onAccountNumberChanged);
    _amountController.text = '250.00';
  }

  void _onAccountNumberChanged() {
    final accountNumber = _accountNumberController.text;
    if (accountNumber.length == 10) {
      _verifyAccountNumber(accountNumber);
    } else {
      setState(() {
        _accountName = '';
        _accountVerified = false;
        _verificationError = '';
      });
    }
  }

  Future<void> _verifyAccountNumber(String accountNumber) async {
    setState(() {
      _isVerifyingAccount = true;
      _verificationError = '';
      _accountName = '';
      _accountVerified = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.paystack.co/bank/resolve?account_number=$accountNumber&bank_code=${widget.selectedBank.code}',
        ),
        headers: {
          'Authorization': 'Bearer sk_test_42e2eeb7eb475f0e0d9ff603087c071d39854b3a',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            _accountName = data['data']['account_name'];
            _accountVerified = true;
            _isVerifyingAccount = false;
          });
        } else {
          setState(() {
            _verificationError = data['message'] ?? 'Invalid account number';
            _isVerifyingAccount = false;
          });
        }
      } else {
        setState(() {
          _verificationError = 'Failed to verify account';
          _isVerifyingAccount = false;
        });
      }
    } catch (e) {
      setState(() {
        _verificationError = 'Network error occurred';
        _isVerifyingAccount = false;
      });
    }
  }

  void _selectQuickAmount(String amount) {
    setState(() {
      _selectedQuickAmount = amount;
      _amountController.text = '$amount.00';
    });
  }

  bool _isFormValid() {
    return _accountVerified && 
           _amountController.text.isNotEmpty &&
           double.tryParse(_amountController.text) != null &&
           double.parse(_amountController.text) > 0;
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Bank Transfer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              size: 20,
                              color: Colors.black54,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selected Bank Display
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: widget.selectedBank.color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.selectedBank.name.substring(0, 2).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.selectedBank.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'Code: ${widget.selectedBank.code}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        const Text(
                          'Add Account Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Account Number Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _accountNumberController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: const InputDecoration(
                                  hintText: 'Account Number',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Account Name Display
                            if (_isVerifyingAccount)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Verifying account...',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            if (_accountVerified)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _accountName,
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            if (_verificationError.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _verificationError,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Enter Amount Section
                        const Text(
                          'Enter Amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Amount Input Field
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '\$0.00',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 32,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Quick Amount Selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _quickAmounts.map((amount) {
                            final isSelected = _selectedQuickAmount == amount;
                            return GestureDetector(
                              onTap: () => _selectQuickAmount(amount),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue[50] : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? Colors.blue : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  '\$$amount',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.blue : Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Payment Purpose
                        const Text(
                          'Payment Purpose',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _purposeController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Purpose of payment (Optional)',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                
                // Continue Button
                Container(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
            


onPressed: _isFormValid()
    ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransferConfirmationScreenn(
              bank: widget.selectedBank,
              accountNumber: _accountNumberController.text,
              accountName: _accountName,
              amount: _amountController.text,
              purpose: _purposeController.text,
            ),
          ),
        );
      }
    : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


