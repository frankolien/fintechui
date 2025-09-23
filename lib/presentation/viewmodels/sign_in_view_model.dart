import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ViewModel for SignIn screen - manages authentication state and business logic
class SignInViewModel extends StateNotifier<SignInState> {
  SignInViewModel() : super(const SignInState());

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool _obscurePassword = true;

  /// Whether password is obscured
  bool get obscurePassword => _obscurePassword;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    // State will be updated through Riverpod automatically
  }

  /// Sign in user with email and password
  Future<void> loginUser() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Import your existing AuthService here
      // String result = await AuthService().loginUser(
      //   email: usernameController.text,
      //   password: passwordController.text,
      // );

      // For now, simulate the login process
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate success
      state = state.copyWith(isLoading: false, isSuccess: true);
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

/// State class for SignIn screen
class SignInState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const SignInState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  SignInState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Provider for SignInViewModel
final signInViewModelProvider = StateNotifierProvider<SignInViewModel, SignInState>((ref) {
  return SignInViewModel();
});
