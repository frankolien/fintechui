import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/wallet_funding_view_model.dart';
import '../../../core/services/real_banking_service.dart';
import '../../../core/services/paystack_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class UnifiedFundWalletScreen extends ConsumerStatefulWidget {
  const UnifiedFundWalletScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UnifiedFundWalletScreen> createState() => _UnifiedFundWalletScreenState();
}

class _UnifiedFundWalletScreenState extends ConsumerState<UnifiedFundWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final RealBankingService _bankingService = RealBankingService();
  final PaystackService _paystackService = PaystackService();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  Map<String, dynamic>? _paymentData;
  List<Map<String, dynamic>> _supportedBanks = [];
  String? _selectedBankCode;
  String _selectedFundingMethod = 'paystack'; // 'paystack' or 'bank'

  @override
  void initState() {
    super.initState();
    // Pre-fill email with current user's email
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email != null) {
      _emailController.text = user!.email!;
    }
    
    // Load supported banks
    _loadSupportedBanks();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      print('Error loading banks: $e');
    }
  }

  Future<void> _fundWallet() async {
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
          ? 'Wallet funding' 
          : _descriptionController.text.trim();

      print('🔍 Unified Fund Wallet: Starting funding with method: $_selectedFundingMethod');
      print('   Amount: $amount');
      print('   Email: $email');

      Map<String, dynamic> result;

      if (_selectedFundingMethod == 'paystack') {
        // Use Paystack wallet funding
        final walletFundingViewModel = ref.read(walletFundingViewModelProvider.notifier);
        await walletFundingViewModel.addMoneyToWallet(
          email,
          amount: amount,
          description: description,
        );
        
        final walletFundingState = ref.read(walletFundingViewModelProvider);
        result = {
          'success': true,
          'reference': walletFundingState.reference ?? '',
          'authorization_url': walletFundingState.authorizationUrl ?? '',
          'method': 'paystack',
        };
      } else {
        // Use Real Banking (Pay with Bank)
        result = await _bankingService.fundWalletFromBank(
          amount: amount,
          email: email,
          description: description,
          bankCode: _selectedBankCode,
        );
        result['method'] = 'bank';
      }

      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _isLoading = false;
            _successMessage = 'Payment initialized successfully!';
            _paymentData = result;
          });
          
          // Show appropriate instructions dialog
          final authUrl = result['authorization_url'] as String?;
          if (authUrl != null && authUrl.isNotEmpty) {
            if (result['method'] == 'bank') {
              _showBankPaymentInstructionsDialog(authUrl);
            } else {
              _showPaystackPaymentInstructionsDialog(authUrl);
            }
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = result['message'] ?? 'Failed to initialize payment';
          });
        }
      }
    } catch (e) {
      print('❌ Unified Fund Wallet: Payment failed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Provide more user-friendly error messages
          if (e.toString().contains('API keys are not configured')) {
            _errorMessage = 'Payment service not configured. Please contact support.';
          } else if (e.toString().contains('No user logged in')) {
            _errorMessage = 'Please log in to continue.';
          } else if (e.toString().contains('Amount must be greater than 0')) {
            _errorMessage = 'Please enter a valid amount.';
          } else {
            _errorMessage = 'Payment initialization failed. Please try again.';
          }
        });
      }
    }
  }

  void _showPaystackPaymentInstructionsDialog(String authorizationUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.payment, color: Colors.blue),
            SizedBox(width: 8),
            Text('Complete Payment'),
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
            const Text('1. Click "Open Paystack" below'),
            const Text('2. Complete payment with your card or bank'),
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
            child: const Text('Open Paystack'),
          ),
        ],
      ),
    );
  }

  void _showBankPaymentInstructionsDialog(String authorizationUrl) {
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

  Future<void> _verifyPayment() async {
    if (_paymentData?['reference'] == null) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });
    }

    try {
      print('🔍 Unified Fund Wallet: Starting verification for reference: ${_paymentData!['reference']}');
      
      // Try verification up to 3 times with delays
      bool verificationSuccessful = false;
      int attempts = 0;
      const maxAttempts = 3;
      
      while (!verificationSuccessful && attempts < maxAttempts) {
        attempts++;
        print('🔍 Verification attempt $attempts of $maxAttempts');
        
        try {
          if (_paymentData!['method'] == 'paystack') {
            // Verify Paystack payment
            final walletFundingViewModel = ref.read(walletFundingViewModelProvider.notifier);
            await walletFundingViewModel.verifyWalletFunding(_paymentData!['reference']);
          } else {
            // Verify bank payment
            await _bankingService.verifyBankPayment(_paymentData!['reference']);
          }
          verificationSuccessful = true;
        } catch (e) {
          print('❌ Verification attempt $attempts failed: $e');
          if (attempts < maxAttempts) {
            // Wait before retrying
            await Future.delayed(Duration(seconds: attempts * 2));
          } else {
            rethrow; // Re-throw the last error
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _successMessage = 'Payment verified! Your wallet has been funded.';
          _paymentData = null;
        });
      }
    } catch (e) {
      print('❌ Unified Fund Wallet: Verification failed after 3 attempts: $e');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Provide more user-friendly error messages
          if (e.toString().contains('abandoned')) {
            _errorMessage = 'Payment was not completed. Please try again.';
            _showAbandonedTransactionDialog();
          } else if (e.toString().contains('pending')) {
            _errorMessage = 'Payment is still processing. Please wait a moment and try again.';
          } else if (e.toString().contains('failed')) {
            _errorMessage = 'Payment failed. Please try again with a different payment method.';
          } else {
            _errorMessage = 'Payment verification failed. Please try again.';
          }
        });
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
              'Your payment was not completed. This usually happens when:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text('• Payment was not completed on the payment website'),
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
              _fundWallet();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Fund Wallet',
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
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      spreadRadius: 0,
                      blurRadius: 40,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.blue[600],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fund Your Wallet',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add money to your wallet using your preferred payment method',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment Mode Indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _paystackService.isLiveMode ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _paystackService.isLiveMode ? Colors.green[200]! : Colors.orange[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _paystackService.isLiveMode ? Icons.account_balance_wallet : Icons.science,
                          color: _paystackService.isLiveMode ? Colors.green[600] : Colors.orange[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _paystackService.isLiveMode 
                                ? '💰 LIVE MODE: Real money will be charged'
                                : '🧪 TEST MODE: No real money will be charged',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _paystackService.isLiveMode ? Colors.green[700] : Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_paystackService.isLiveMode) ...[
                      const SizedBox(height: 8),
                      Text(
                        'To activate live mode: Complete Paystack business verification and request live access.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Payment Method Selection
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFundingMethod = 'paystack';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedFundingMethod == 'paystack' 
                              ? Colors.blue[50] 
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedFundingMethod == 'paystack' 
                                ? Colors.blue[200]! 
                                : Colors.grey[200]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.payment,
                              color: _selectedFundingMethod == 'paystack' 
                                  ? Colors.blue[600] 
                                  : Colors.grey[600],
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Card/Bank',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _selectedFundingMethod == 'paystack' 
                                    ? Colors.blue[600] 
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Paystack',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFundingMethod = 'bank';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedFundingMethod == 'bank' 
                              ? Colors.green[50] 
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedFundingMethod == 'bank' 
                                ? Colors.green[200]! 
                                : Colors.grey[200]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_balance,
                              color: _selectedFundingMethod == 'bank' 
                                  ? Colors.green[600] 
                                  : Colors.grey[600],
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pay with Bank',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _selectedFundingMethod == 'bank' 
                                    ? Colors.green[600] 
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Direct Bank',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                hintText: 'Enter description',
                validator: (value) => null,
                prefixIcon: const Icon(Icons.note, color: Colors.grey),
              ),

              // Bank Selection (only for bank payment method)
              if (_selectedFundingMethod == 'bank') ...[
                const SizedBox(height: 16),
                const Text(
                  'Select Bank',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBankCode,
                      hint: const Text('Select a bank'),
                      isExpanded: true,
                      items: _supportedBanks.map((bank) {
                        return DropdownMenuItem<String>(
                          value: bank['code'],
                          child: Text(bank['name']),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedBankCode = value;
                        });
                      },
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

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
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[600],
                          ),
                        ),
                      ),
                    ],
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
                            'Payment Initialized',
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
                        'Please complete your payment, then click "Verify Payment" to update your wallet.',
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
                              onPressed: _isLoading ? null : _verifyPayment,
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
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Fund Wallet Button
              CustomButton(
                text: _isLoading ? 'Processing...' : 'Fund Wallet',
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_selectedFundingMethod == 'bank' && _selectedBankCode == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a bank'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        await _fundWallet();
                      },
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
