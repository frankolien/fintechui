import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/bank_transfer_view_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class PaystackBankTransferScreen extends ConsumerStatefulWidget {
  const PaystackBankTransferScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PaystackBankTransferScreen> createState() => _PaystackBankTransferScreenState();
}

class _PaystackBankTransferScreenState extends ConsumerState<PaystackBankTransferScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load banks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bankTransferViewModelProvider.notifier).loadBanks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bankTransferState = ref.watch(bankTransferViewModelProvider);
    final bankTransferViewModel = ref.read(bankTransferViewModelProvider.notifier);

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
          'Transfer to Bank',
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
                      Icons.account_balance,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Bank Transfer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Transfer money directly to any Nigerian bank account',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bank Selection
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
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: bankTransferViewModel.selectedBankCode,
                    hint: const Text('Select a bank'),
                    isExpanded: true,
                    items: bankTransferViewModel.banks.map((bank) {
                      return DropdownMenuItem<String>(
                        value: bank['code'],
                        child: Text(bank['name']),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        final bank = bankTransferViewModel.banks.firstWhere(
                          (b) => b['code'] == value,
                        );
                        bankTransferViewModel.selectBank(value, bank['name']);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Account Number Input
              const Text(
                'Account Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: bankTransferViewModel.accountNumberController,
                      hintText: 'Enter account number',
                      keyboardType: TextInputType.number,
                      validator: bankTransferViewModel.validateAccountNumber,
                      prefixIcon: const Icon(Icons.account_balance_wallet, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: bankTransferState.isVerifyingAccount
                          ? null
                          : () async {
                              if (bankTransferViewModel.selectedBankCode != null &&
                                  bankTransferViewModel.accountNumberController.text.isNotEmpty) {
                                await bankTransferViewModel.verifyAccountNumber();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: bankTransferState.isVerifyingAccount
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Verify'),
                    ),
                  ),
                ],
              ),

              // Account Name Display (after verification)
              if (bankTransferState.isAccountVerified && bankTransferState.verifiedAccountName != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
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
                      Text(
                        'Account Name: ${bankTransferState.verifiedAccountName}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

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
                controller: bankTransferViewModel.amountController,
                hintText: 'Enter amount (₦)',
                keyboardType: TextInputType.number,
                validator: bankTransferViewModel.validateAmount,
                prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
              ),

              const SizedBox(height: 16),

              // Reason Input
              const Text(
                'Transfer Reason',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: bankTransferViewModel.reasonController,
                hintText: 'Enter reason for transfer',
                validator: bankTransferViewModel.validateReason,
                prefixIcon: const Icon(Icons.description, color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // Transfer Info
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
                          'Transfer Information',
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
                      '• Transfers are processed instantly\n'
                      '• Minimum transfer amount: ₦100\n'
                      '• Maximum transfer amount: ₦1,000,000\n'
                      '• Transfer fees may apply',
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

              // Transfer Button
              CustomButton(
                text: bankTransferState.isTransferring ? 'Processing...' : 'Transfer Money',
                onPressed: (bankTransferState.isTransferring || !bankTransferState.isAccountVerified)
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await bankTransferViewModel.transferToBank();
                        }
                      },
                isLoading: bankTransferState.isTransferring,
              ),

              const SizedBox(height: 16),

              // Error Message
              if (bankTransferState.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    bankTransferState.errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),

              // Success Message
              if (bankTransferState.isSuccess)
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
                            'Transfer Successful',
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
                        'Transfer Code: ${bankTransferState.transferCode}',
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
      ),
    );
  }
}
