import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/enhanced_transfer_service.dart';

/// ViewModel for Bank Transfer - manages transferring money to bank accounts
class BankTransferViewModel extends StateNotifier<BankTransferState> {
  BankTransferViewModel() : super(const BankTransferState());

  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  
  final EnhancedTransferService _transferService = EnhancedTransferService();
  
  String? _selectedBankCode;
  String? _selectedBankName;
  List<Map<String, dynamic>> _banks = [];

  /// Get selected bank code
  String? get selectedBankCode => _selectedBankCode;
  
  /// Get selected bank name
  String? get selectedBankName => _selectedBankName;
  
  /// Get banks list
  List<Map<String, dynamic>> get banks => _banks;

  /// Load banks from Paystack
  Future<void> loadBanks() async {
    state = state.copyWith(isLoadingBanks: true, errorMessage: null);

    try {
      print('🔍 Loading banks from Paystack...');
      
      // Get banks from Paystack API
      final paystackBanks = await _transferService.getSupportedBanks();
      print('📊 Paystack returned ${paystackBanks.length} banks');
      
      // Convert to our format and add some additional banks that might not be in Paystack's list
      final banks = <Map<String, String>>[];
      
      for (final bank in paystackBanks) {
        banks.add({
          'name': bank['name'] ?? 'Unknown Bank',
          'code': bank['code'] ?? '000',
        });
      }
      
      // Add additional banks that might not be in Paystack's list
      final additionalBanks = [
        // Note: OPay bank code 100022 is invalid according to Paystack API
        // We'll let Paystack API determine the correct codes
        {'name': 'PalmPay', 'code': '999991'},
        {'name': 'Kuda Bank', 'code': '50211'},
      ];
      
      // Add additional banks if they're not already in the list
      for (final additionalBank in additionalBanks) {
        if (!banks.any((bank) => bank['code'] == additionalBank['code'])) {
          banks.add(additionalBank);
          print('➕ Added additional bank: ${additionalBank['name']} (${additionalBank['code']})');
        }
      }
      
      print('📊 Total banks loaded: ${banks.length}');
      print('📊 Banks list: $banks');
      
      // Check if OPay is in the Paystack list
      final opayBank = banks.firstWhere(
        (bank) => bank['name']?.toLowerCase().contains('opay') == true,
        orElse: () => {'name': 'Not Found', 'code': '000'},
      );
      
      if (opayBank['name'] != 'Not Found') {
        print('✅ OPay found in Paystack list: ${opayBank['name']} (${opayBank['code']})');
      } else {
        print('❌ OPay not found in Paystack supported banks list');
        print('💡 This means OPay might not be supported by Paystack for account verification');
      }
      
      _banks = banks;
      state = state.copyWith(isLoadingBanks: false);
    } catch (e) {
      print('❌ Error loading banks from Paystack: $e');
      
      // Fallback to hardcoded list if Paystack fails
      print('🔄 Falling back to hardcoded bank list...');
      _banks = [
        {'name': 'Access Bank', 'code': '044'},
        {'name': 'Citibank Nigeria', 'code': '023'},
        {'name': 'Diamond Bank', 'code': '063'},
        {'name': 'Ecobank Nigeria', 'code': '050'},
        {'name': 'Fidelity Bank', 'code': '070'},
        {'name': 'First Bank of Nigeria', 'code': '011'},
        {'name': 'First City Monument Bank', 'code': '214'},
        {'name': 'Guaranty Trust Bank', 'code': '058'},
        {'name': 'Heritage Bank', 'code': '030'},
        {'name': 'Keystone Bank', 'code': '082'},
        {'name': 'Kuda Bank', 'code': '50211'},
        // Note: OPay code 100022 is invalid - removed until we get correct code
        {'name': 'PalmPay', 'code': '999991'},
        {'name': 'Polaris Bank', 'code': '076'},
        {'name': 'Providus Bank', 'code': '101'},
        {'name': 'Stanbic IBTC Bank', 'code': '221'},
        {'name': 'Standard Chartered Bank', 'code': '068'},
        {'name': 'Sterling Bank', 'code': '232'},
        {'name': 'Suntrust Bank', 'code': '100'},
        {'name': 'Union Bank of Nigeria', 'code': '032'},
        {'name': 'United Bank For Africa', 'code': '033'},
        {'name': 'VFD Microfinance Bank', 'code': '566'},
        {'name': 'Wema Bank', 'code': '035'},
        {'name': 'Zenith Bank', 'code': '057'},
      ];

      state = state.copyWith(isLoadingBanks: false);
    }
  }

  /// Select bank
  void selectBank(String bankCode, String bankName) {
    _selectedBankCode = bankCode;
    _selectedBankName = bankName;
    state = state.copyWith(selectedBank: bankName);
  }

  /// Validate account number
  String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "Account number is required";
    }
    
    if (value.length < 10) {
      return "Account number must be at least 10 digits";
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return "Account number must contain only numbers";
    }
    
    return null;
  }

  /// Validate account name
  String? validateAccountName(String? value) {
    if (value == null || value.isEmpty) {
      return "Account name is required";
    }
    
    if (value.length < 2) {
      return "Account name must be at least 2 characters";
    }
    
    return null;
  }

  /// Validate amount
  String? validateAmount(String? value) {
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
      return "Minimum transfer amount is ₦100";
    }
    
    return null;
  }

  /// Validate reason
  String? validateReason(String? value) {
    if (value == null || value.isEmpty) {
      return "Transfer reason is required";
    }
    
    if (value.length < 3) {
      return "Reason must be at least 3 characters";
    }
    
    return null;
  }

  /// Verify account number with bank
  Future<void> verifyAccountNumber() async {
    if (_selectedBankCode == null || accountNumberController.text.isEmpty) {
      state = state.copyWith(errorMessage: 'Please select a bank and enter account number');
      return;
    }

    print('🔍 Bank Transfer ViewModel: Starting account verification');
    print('🔍 Bank: ${_selectedBankName} (${_selectedBankCode})');
    print('🔍 Account Number: ${accountNumberController.text}');

    state = state.copyWith(isVerifyingAccount: true, errorMessage: null);

    try {
      // Use Paystack's resolve account API to verify the account
      final result = await _transferService.verifyBankAccount(
        accountNumber: accountNumberController.text,
        bankCode: _selectedBankCode!,
      );
      
      print('📊 Bank Transfer ViewModel: Verification result: $result');
      
      if (result['success'] == true) {
        final accountName = result['account_name'] ?? 'Unknown Account';
        accountNameController.text = accountName;
        
        print('✅ Bank Transfer ViewModel: Account verified successfully: $accountName');
        
        state = state.copyWith(
          isVerifyingAccount: false,
          isAccountVerified: true,
          verifiedAccountName: accountName,
        );
      } else {
        print('❌ Bank Transfer ViewModel: Verification failed: ${result['message']}');
        state = state.copyWith(
          isVerifyingAccount: false,
          errorMessage: result['message'] ?? 'Failed to verify account',
        );
      }
    } catch (e) {
      print('❌ Bank Transfer ViewModel: Verification error: $e');
      state = state.copyWith(
        isVerifyingAccount: false,
        errorMessage: 'Failed to verify account: $e',
      );
    }
  }

  /// Transfer money to bank account
  Future<void> transferToBank() async {
    if (_selectedBankCode == null) {
      state = state.copyWith(errorMessage: 'Please select a bank');
      return;
    }

    state = state.copyWith(isTransferring: true, errorMessage: null);

    try {
      final amount = double.parse(amountController.text);
      final accountNumber = accountNumberController.text;
      final accountName = accountNameController.text;
      final reason = reasonController.text;

      final result = await _transferService.transferToBank(
        accountNumber: accountNumber,
        bankCode: _selectedBankCode!,
        accountName: accountName,
        amount: amount,
        reason: reason,
      );

      if (result['success'] == true) {
        state = state.copyWith(
          isTransferring: false,
          isSuccess: true,
          transferCode: result['transfer_code'],
        );
      } else {
        state = state.copyWith(
          isTransferring: false,
          errorMessage: result['message'] ?? 'Transfer failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isTransferring: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reset state
  void resetState() {
    state = const BankTransferState();
    accountNumberController.clear();
    accountNameController.clear();
    amountController.clear();
    reasonController.clear();
    _selectedBankCode = null;
    _selectedBankName = null;
  }

  @override
  void dispose() {
    accountNumberController.dispose();
    accountNameController.dispose();
    amountController.dispose();
    reasonController.dispose();
    super.dispose();
  }
}

/// State class for Bank Transfer
class BankTransferState {
  final bool isLoadingBanks;
  final bool isVerifyingAccount;
  final bool isAccountVerified;
  final bool isTransferring;
  final bool isSuccess;
  final String? errorMessage;
  final String? selectedBank;
  final String? verifiedAccountName;
  final String? transferCode;

  const BankTransferState({
    this.isLoadingBanks = false,
    this.isVerifyingAccount = false,
    this.isAccountVerified = false,
    this.isTransferring = false,
    this.isSuccess = false,
    this.errorMessage,
    this.selectedBank,
    this.verifiedAccountName,
    this.transferCode,
  });

  BankTransferState copyWith({
    bool? isLoadingBanks,
    bool? isVerifyingAccount,
    bool? isAccountVerified,
    bool? isTransferring,
    bool? isSuccess,
    String? errorMessage,
    String? selectedBank,
    String? verifiedAccountName,
    String? transferCode,
  }) {
    return BankTransferState(
      isLoadingBanks: isLoadingBanks ?? this.isLoadingBanks,
      isVerifyingAccount: isVerifyingAccount ?? this.isVerifyingAccount,
      isAccountVerified: isAccountVerified ?? this.isAccountVerified,
      isTransferring: isTransferring ?? this.isTransferring,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedBank: selectedBank ?? this.selectedBank,
      verifiedAccountName: verifiedAccountName ?? this.verifiedAccountName,
      transferCode: transferCode ?? this.transferCode,
    );
  }
}

/// Provider for BankTransferViewModel
final bankTransferViewModelProvider = StateNotifierProvider<BankTransferViewModel, BankTransferState>((ref) {
  return BankTransferViewModel();
});
