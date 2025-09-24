import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/enhanced_transfer_service.dart';

/// ViewModel for Wallet Funding - manages adding money to wallet via Paystack
class WalletFundingViewModel extends StateNotifier<WalletFundingState> {
  WalletFundingViewModel() : super(const WalletFundingState());

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  final EnhancedTransferService _transferService = EnhancedTransferService();

  /// Validate amount field
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
      return "Minimum amount is ₦100";
    }
    
    return null;
  }

  /// Add money to wallet
  Future<void> addMoneyToWallet(String userEmail, {double? amount, String? description}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Use provided amount or fall back to controller
      final finalAmount = amount ?? double.parse(amountController.text);
      final finalDescription = description ?? (descriptionController.text.trim().isEmpty 
          ? 'Wallet funding' 
          : descriptionController.text.trim());

      final result = await _transferService.addMoneyToWallet(
        amount: finalAmount,
        email: userEmail,
        description: finalDescription,
      );

      if (result['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          authorizationUrl: result['authorization_url'] ?? '',
          reference: result['reference'] ?? '',
          accessCode: result['access_code'] ?? '',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['message'] ?? 'Failed to initialize payment',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Verify wallet funding transaction
  Future<void> verifyWalletFunding(String reference) async {
    state = state.copyWith(isVerifying: true, errorMessage: null);

    try {
      await _transferService.verifyWalletFunding(reference);
      state = state.copyWith(
        isVerifying: false,
        isVerified: true,
      );
      
      // Reset state after successful verification to allow new funding
      Future.delayed(const Duration(seconds: 2), () {
        resetState();
      });
    } catch (e) {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Check for pending transactions and verify them
  Future<void> checkAndVerifyPendingTransactions() async {
    try {
      final pendingTransactions = await _transferService.getPendingWalletFundingTransactions();
      
      if (pendingTransactions.isNotEmpty) {
        state = state.copyWith(
          errorMessage: 'Found ${pendingTransactions.length} pending transaction(s). Verifying...',
        );
        
        await _transferService.verifyAllPendingTransactions();
        
        state = state.copyWith(
          errorMessage: null,
          isVerified: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error checking pending transactions: $e',
      );
    }
  }

  /// Reset state
  void resetState() {
    state = const WalletFundingState();
    amountController.clear();
    descriptionController.clear();
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

/// State class for Wallet Funding
class WalletFundingState {
  final bool isLoading;
  final bool isSuccess;
  final bool isVerifying;
  final bool isVerified;
  final String? errorMessage;
  final String? authorizationUrl;
  final String? reference;
  final String? accessCode;

  const WalletFundingState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isVerifying = false,
    this.isVerified = false,
    this.errorMessage,
    this.authorizationUrl,
    this.reference,
    this.accessCode,
  });

  WalletFundingState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isVerifying,
    bool? isVerified,
    String? errorMessage,
    String? authorizationUrl,
    String? reference,
    String? accessCode,
  }) {
    return WalletFundingState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isVerifying: isVerifying ?? this.isVerifying,
      isVerified: isVerified ?? this.isVerified,
      errorMessage: errorMessage ?? this.errorMessage,
      authorizationUrl: authorizationUrl ?? this.authorizationUrl,
      reference: reference ?? this.reference,
      accessCode: accessCode ?? this.accessCode,
    );
  }
}

/// Provider for WalletFundingViewModel
final walletFundingViewModelProvider = StateNotifierProvider<WalletFundingViewModel, WalletFundingState>((ref) {
  return WalletFundingViewModel();
});
