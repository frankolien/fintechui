import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_service.dart';
import '../../core/services/enhanced_transfer_service.dart';

/// ViewModel for SignUp screen - manages registration state and business logic
class SignUpViewModel extends StateNotifier<SignUpState> {
  SignUpViewModel() : super(const SignUpState());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController cncController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isChecked = false;

  /// Whether password is obscured
  bool get obscurePassword => _obscurePassword;

  /// Whether terms are checked
  bool get isChecked => _isChecked;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    // State will be updated through Riverpod automatically
  }

  /// Toggle terms checkbox
  void toggleTermsCheckbox() {
    _isChecked = !_isChecked;
    // State will be updated through Riverpod automatically
  }

  /// Validate name field
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name is required";
    }
    if (value.length < 2) {
      return "Name must at least be 2 characters";
    }
    return null;
  }

  /// Validate email field
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "please enter a valid Email";
    }
    final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return "please enter a valid Email";
    }
    return null;
  }

  /// Validate phone number field
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Phone number is required";
    }
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    final cleanPhone = value.replaceAll(RegExp(r'[\s-()]'), '');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return "Please enter a valid phone number";
    }
    return null;
  }

  /// Validate password field
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  /// Sign up user
  Future<void> signUp() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Validate all fields first
      if (!_isChecked) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Please accept the terms and conditions',
        );
        return;
      }

      // Create user with Firebase Auth
      final authService = AuthService();
      final userService = UserService();
      final transferService = EnhancedTransferService();

      String authResult = await authService.signupUser(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (authResult == "success") {
        // Save user data to Firestore
        String userDataResult = await userService.saveUserData(
          email: emailController.text.trim(),
          username: nameController.text.trim(),
          fullName: fullNameController.text.trim(),
          phoneNumber: numberController.text.trim(),
        );

        if (userDataResult == "success") {
          state = state.copyWith(isLoading: false, isSuccess: true);
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: userDataResult,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: authResult,
        );
      }
      
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
    nameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    numberController.dispose();
    cncController.dispose();
    super.dispose();
  }
}

/// State class for SignUp screen
class SignUpState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const SignUpState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  SignUpState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Provider for SignUpViewModel
final signUpViewModelProvider = StateNotifierProvider<SignUpViewModel, SignUpState>((ref) {
  return SignUpViewModel();
});
