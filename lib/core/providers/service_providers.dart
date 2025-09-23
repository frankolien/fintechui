import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_service.dart';
import '../../core/services/transfer_service.dart';

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for UserService
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// Provider for TransferService
final transferServiceProvider = Provider<TransferService>((ref) {
  return TransferService();
});
