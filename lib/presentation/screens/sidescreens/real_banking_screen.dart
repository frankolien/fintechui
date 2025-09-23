import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/real_banking_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class RealBankingScreen extends ConsumerStatefulWidget {
  const RealBankingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RealBankingScreen> createState() => _RealBankingScreenState();
}

class _RealBankingScreenState extends ConsumerState<RealBankingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final RealBankingService _bankingService = RealBankingService();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  Map<String, dynamic>? _paymentData;
  List<Map<String, dynamic>> _supportedBanks = [];
  String? _selectedBankCode;

  @override
  void initState() {
    super.initState();
    _loadSupportedBanks();
    _checkPendingPayments();
    
    // Pre-fill email with current user's email
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email != null) {
      _emailController.text = user!.email!;
    }
    
    // Add listener to amount controller for fee calculation
    _amountController.addListener(() {
      setState(() {}); // Rebuild to show fee calculation
    });
  }

  Future<void> _loadSupportedBanks() async {
    try {
      final banks = await _bankingService.getSupportedBanks();
      if (mounted) {
        setState(() {
          _supportedBanks = banks;
        });
      }
    } catch (e) {
      print('Error loading supported banks: $e');
    }
  }

  Future<void> _checkPendingPayments() async {
    try {
      await _bankingService.verifyAllPendingBankPayments();
    } catch (e) {
      print('Error checking pending payments: $e');
    }
  }

  Future<void> _fundWalletFromBank() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
        _paymentData = null;
      });
    }

    try {
      final amount = double.parse(_amountController.text);
      final email = _emailController.text.trim();
      final description = _descriptionController.text.trim().isEmpty 
          ? 'Wallet funding from bank' 
          : _descriptionController.text.trim();

      print('🔍 Real Banking Screen: Initiating bank payment');
      print('   Amount: $amount');
      print('   Email: $email');
      print('   Bank Code: $_selectedBankCode');

      final result = await _bankingService.fundWalletFromBank(
        amount: amount,
        email: email,
        description: description,
        bankCode: _selectedBankCode,
      );

      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _isLoading = false;
            _successMessage = 'Bank payment initialized successfully!';
            _paymentData = result;
          });
          
          // Show detailed instructions dialog
          _showPaymentInstructionsDialog(result['authorization_url']);
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = result['message'] ?? 'Failed to initialize bank payment';
          });
        }
      }
    } catch (e) {
      print('❌ Real Banking Screen: Bank payment failed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _showPaymentInstructionsDialog(String authorizationUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.account_balance, color: Colors.blue),
            SizedBox(width: 8),
            Text('Complete Bank Payment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please follow these steps to complete your payment:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text('1. Click "Open Bank Website" below'),
            const Text('2. Complete payment on your bank\'s website'),
            const Text('3. Return to this app'),
            const Text('4. Click "Verify Payment" to update your wallet'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Important: Do not close the browser until payment is complete!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _paymentData = null;
                _successMessage = null;
              });
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final url = Uri.parse(authorizationUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Open Bank Website'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyBankPayment() async {
    if (_paymentData?['reference'] == null) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });
    }

    try {
      print('🔍 Real Banking Screen: Starting verification for reference: ${_paymentData!['reference']}');
      await _bankingService.verifyBankPayment(_paymentData!['reference']);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _successMessage = 'Bank payment verified! Your wallet has been funded.';
          _paymentData = null;
        });
      }
    } catch (e) {
      print('❌ Real Banking Screen: Verification failed: $e');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
        
        // Show specific guidance for abandoned transactions
        if (e.toString().contains('abandoned')) {
          _showAbandonedTransactionDialog();
        }
      }
    }
  }

  void _showAbandonedTransactionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Payment Not Completed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your bank payment was not completed. This usually happens when:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text('• Payment was not completed on the bank\'s website'),
            const Text('• Browser was closed before payment completion'),
            const Text('• Payment session expired'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No money was charged. You can safely try again.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _paymentData = null;
                _errorMessage = null;
                _successMessage = null;
              });
            },
            child: const Text('Start New Payment'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Retry with same data
              _fundWalletFromBank();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateFees(double amount) {
    return _bankingService.calculateBankPaymentFees(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Real Banking',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Real Banking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Transfer real money directly from your bank account',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Amount Input
              const Text(
                'Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _amountController,
                hintText: 'Enter amount (₦)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Amount is required";
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return "Please enter a valid amount";
                  }
                  if (amount <= 0) {
                    return "Amount must be greater than 0";
                  }
                  if (amount < 100) {
                    return "Minimum amount is ₦100";
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
              ),

              // Fee Calculation
              if (_amountController.text.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fee Breakdown',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Builder(
                        builder: (context) {
                          final amount = double.tryParse(_amountController.text) ?? 0;
                          if (amount == 0) return const SizedBox.shrink();
                          
                          final fees = _calculateFees(amount);
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Amount:', style: TextStyle(fontSize: 12)),
                                  Text('₦${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Fee (1.5%):', style: TextStyle(fontSize: 12)),
                                  Text('₦${fees['percentage_fee'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              if (fees['fixed_fee'] > 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Fixed Fee:', style: TextStyle(fontSize: 12)),
                                    Text('₦${fees['fixed_fee'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              const Divider(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text('₦${fees['total_amount'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Email Input
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  if (!value.contains('@')) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.email, color: Colors.grey),
              ),

              const SizedBox(height: 16),

              // Description Input
              const Text(
                'Description (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Add a note for this transaction',
                maxLines: 3,
                validator: (value) => null, // Optional field
              ),

              const SizedBox(height: 24),

              // Bank Selection
              if (_supportedBanks.isNotEmpty) ...[
                const Text(
                  'Select Bank (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBankCode,
                      hint: const Text('Choose your bank (optional)'),
                      isExpanded: true,
                      items: _supportedBanks.map((bank) {
                        return DropdownMenuItem<String>(
                          value: bank['code'],
                          child: Text(bank['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBankCode = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Payment Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Real Banking Information',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Transfer real money directly from your bank account\n'
                      '• Supported banks: GTBank, UBA, Zenith, Sterling, Fidelity, Kuda, ALAT\n'
                      '• Secure authentication via your bank\'s platform\n'
                      '• Instant wallet funding upon successful payment\n'
                      '• Fee: 1.5% + ₦100 (waived for amounts below ₦2,500)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Fund Wallet Button
              CustomButton(
                text: _isLoading ? 'Processing...' : 'Fund Wallet from Bank',
                onPressed: _isLoading ? null : _fundWalletFromBank,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 16),

              // Error Message
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),

              // Success Message and Payment Link
              if (_successMessage != null && _paymentData != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Bank Payment Initialized',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _successMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Reference: ${_paymentData!['reference']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please complete your payment on the bank\'s website, then click "Verify Payment" to update your wallet.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _verifyBankPayment,
                              icon: _isLoading 
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.verified_user, size: 18),
                              label: Text(_isLoading ? 'Verifying...' : 'Verify Payment'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : () {
                                setState(() {
                                  _paymentData = null;
                                  _errorMessage = null;
                                  _successMessage = null;
                                });
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Retry'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue[600],
                                side: BorderSide(color: Colors.blue[600]!),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Success Message (after verification)
              if (_successMessage != null && _paymentData == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
