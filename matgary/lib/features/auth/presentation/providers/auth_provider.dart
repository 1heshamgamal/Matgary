import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth state enum
enum AuthState {
  /// Initial state
  initial,
  
  /// Authenticated state
  authenticated,
  
  /// Unauthenticated state
  unauthenticated,
  
  /// Error state
  error,
}

/// Auth provider state
class AuthProviderState {
  /// Current auth state
  final AuthState state;
  
  /// Current user
  final User? user;
  
  /// Error message
  final String? errorMessage;
  
  /// Constructor
  const AuthProviderState({
    this.state = AuthState.initial,
    this.user,
    this.errorMessage,
  });
  
  /// Copy with method
  AuthProviderState copyWith({
    AuthState? state,
    User? user,
    String? errorMessage,
  }) {
    return AuthProviderState(
      state: state ?? this.state,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Auth provider notifier
class AuthProviderNotifier extends StateNotifier<AuthProviderState> {
  /// Supabase client
  final SupabaseClient _supabaseClient;
  
  /// Constructor
  AuthProviderNotifier(this._supabaseClient) : super(const AuthProviderState()) {
    // Initialize auth state
    _initAuthState();
  }
  
  /// Initialize auth state
  Future<void> _initAuthState() async {
    final session = _supabaseClient.auth.currentSession;
    
    if (session != null) {
      state = state.copyWith(
        state: AuthState.authenticated,
        user: session.user,
      );
    } else {
      state = state.copyWith(
        state: AuthState.unauthenticated,
      );
    }
  }
  
  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        state = state.copyWith(
          state: AuthState.authenticated,
          user: response.user,
        );
      } else {
        throw Exception('Failed to sign in');
      }
    } catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
      throw e;
    }
  }
  
  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
        },
      );
      
      if (response.user != null) {
        // Create user profile
        await _supabaseClient.from('profiles').insert({
          'id': response.user!.id,
          'full_name': name,
          'email': email,
          'role': 'user',
        });
        
        state = state.copyWith(
          state: AuthState.authenticated,
          user: response.user,
        );
      } else {
        throw Exception('Failed to sign up');
      }
    } catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
      throw e;
    }
  }
  
  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      final response = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.matgary://login-callback',
      );
      
      if (!response) {
        throw Exception('Failed to sign in with Google');
      }
    } catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
      throw e;
    }
  }
  
  /// Sign in with Apple
  Future<void> signInWithApple() async {
    try {
      final response = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.matgary://login-callback',
      );
      
      if (!response) {
        throw Exception('Failed to sign in with Apple');
      }
    } catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
      throw e;
    }
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.matgary://reset-callback',
      );
    } catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
      throw e;
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      state = state.copyWith(
        state: AuthState.unauthenticated,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
      throw e;
    }
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthProviderNotifier, AuthProviderState>((ref) {
  return AuthProviderNotifier(Supabase.instance.client);
});