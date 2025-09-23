import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/wallet_funding_view_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class WalletFundingScreen extends ConsumerStatefulWidget {
  const WalletFundingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletFundingScreen> createState() => _WalletFundingScreenState();
}

class _WalletFundingScreenState extends ConsumerState<WalletFundingScreen> {
  final _formKey = GlobalKey<FormState>();
  WalletFundingViewModel? _walletFundingViewModel;

  @override
  void initState() {
    super.initState();
    // Check for pending transactions when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _walletFundingViewModel = ref.read(walletFundingViewModelProvider.notifier);
      _walletFundingViewModel?.checkAndVerifyPendingTransactions();
    });
  }

  /// Show payment verification dialog
  void _showPaymentVerificationDialog() {
    final walletFundingState = ref.read(walletFundingViewModelProvider);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.payment, color: Colors.blue),
            SizedBox(width: 8),
            Text('Verify Payment'),
          ],
        ),
        content: const Text(
          'Please complete your payment on Paystack and then click "Verify Payment" to update your wallet balance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (walletFundingState.reference != null) {
                try {
                  await _walletFundingViewModel?.verifyWalletFunding(walletFundingState.reference!);
                  
                  // Close dialog first
                  Navigator.of(dialogContext).pop();
                  
                  // Show success message using the original context
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment verified! Your wallet has been funded.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    // Navigate back to home screen
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  // Close dialog and show error
                  Navigator.of(dialogContext).pop();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Verification failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Verify Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletFundingState = ref.watch(walletFundingViewModelProvider);
    final walletFundingViewModel = ref.read(walletFundingViewModelProvider.notifier);

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
          'Add Money to Wallet',
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
                    colors: [Color(0xFF456EFE), Color(0xFF6B73FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Fund Your Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add money to your wallet using Paystack payment gateway',
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
                controller: walletFundingViewModel.amountController,
                hintText: 'Enter amount (₦)',
                keyboardType: TextInputType.number,
                validator: walletFundingViewModel.validateAmount,
                prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
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
                controller: walletFundingViewModel.descriptionController,
                hintText: 'Add a note for this transaction',
                maxLines: 3,
                validator: (value) => null, // Optional field
              ),

              const SizedBox(height: 24),

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
                          'Payment Information',
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
                      '• Secure payment powered by Paystack\n'
                      '• Supports all major cards and bank transfers\n'
                      '• Instant wallet funding upon successful payment\n'
                      '• Minimum amount: ₦100',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Helpful instructions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'After completing payment on Paystack, click "Verify Payment" to update your wallet balance.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Fund Wallet Button
              CustomButton(
                text: walletFundingState.isLoading ? 'Processing...' : 'Fund Wallet',
                onPressed: walletFundingState.isLoading
                    ? null
                      : () async {
                        if (_formKey.currentState!.validate()) {
                          // Get user email from Firebase Auth
                          final user = FirebaseAuth.instance.currentUser;
                          final userEmail = user?.email ?? 'user@example.com';
                          await _walletFundingViewModel?.addMoneyToWallet(userEmail);
                        }
                      },
                isLoading: walletFundingState.isLoading,
              ),

              // Reset Button (show when funding is successful)
              if (walletFundingState.isSuccess || walletFundingState.isVerified)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _walletFundingViewModel?.resetState();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Fund Again'),
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
                ),

              const SizedBox(height: 16),

              // Error Message
              if (walletFundingState.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    walletFundingState.errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),

              // Success Message and Payment Link
              if (walletFundingState.isSuccess && walletFundingState.authorizationUrl != null)
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
                            walletFundingState.isVerified ? 'Payment Verified!' : 'Payment Initialized',
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
                        walletFundingState.isVerified 
                            ? 'Your wallet has been successfully funded!'
                            : 'Click the button below to complete your payment:',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!walletFundingState.isVerified) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final url = Uri.parse(walletFundingState.authorizationUrl!);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                                
                                // Show verification dialog after payment
                                _showPaymentVerificationDialog();
                              }
                            },
                            icon: const Icon(Icons.payment, size: 18),
                            label: const Text('Complete Payment'),
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
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: walletFundingState.isVerifying ? null : () async {
                              if (walletFundingState.reference != null) {
                                try {
                                  await _walletFundingViewModel?.verifyWalletFunding(walletFundingState.reference!);
                                  
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Payment verified! Your wallet has been funded.'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Verification failed: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            icon: walletFundingState.isVerifying 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.verified_user, size: 18),
                            label: Text(walletFundingState.isVerifying ? 'Verifying...' : 'Verify Payment'),
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
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
