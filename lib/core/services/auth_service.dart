/*import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final SupabaseClient _supabaseClient;

  AuthService() : _supabaseClient = Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize() async {
    await dotenv.load();
    await Supabase.initialize(
    );
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone': phone,
      },
    );

    return response;
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  // Get current user
  User? get currentUser => _supabaseClient.auth.currentUser;

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final response = await _supabaseClient
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return response;
  }

  // Update profile
  Future<void> updateProfile({
    String? name,
    String? phone,
  }) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _supabaseClient.from('profiles').update({
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // Stream to listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabaseClient.auth.onAuthStateChange;
}*/