import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';

// Auth state provider - tracks Supabase auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (event) => event.session?.user,
  );
});

// Current user provider - fetches the full user profile
// Converted to StateNotifier to support local updates (Stripe Setup)
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<AppUser?>>((ref) {
  return CurrentUserNotifier(ref);
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final Ref _ref;
  
  CurrentUserNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _ref.listen(authStateProvider, (previous, next) {
      if (next.value != null) {
        _fetchUserProfile(next.value!.id);
      } else {
        state = const AsyncValue.data(null);
      }
    });
  }

  Future<void> _fetchUserProfile(String userId) async {
    state = const AsyncValue.loading();
    try {
      // SIMULATION MODE: Return mock user
      await Future.delayed(const Duration(seconds: 1));
      state = AsyncValue.data(
        AppUser(
          id: userId,
          email: 'akash@fade.app',
          fullName: 'Akash Barber',
          userType: UserType.barber,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          stripeAccountId: null, // Default null to test gating
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Simulate updating stripe status locally
  void updateStripeStatus(bool connected) {
    if (state.value != null) {
      state = AsyncValue.data(
        state.value!.copyWith(
          stripeAccountId: connected ? 'acct_test_simulated_123' : null,
        ),
      );
    }
  }
}

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref _ref;
  final SupabaseClient _client = Supabase.instance.client;

  AuthService(this._ref);

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userType,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'user_type': userType,
      },
    );

    if (response.user != null) {
      // Create profile in profiles table
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'full_name': fullName,
        'user_type': userType,
      });

      // If user is barber, also create barber_profiles entry
      if (userType == 'barber') {
        await _client.from('barber_profiles').insert({
          'user_id': response.user!.id,
        });
      }
    }

    return response;
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.fadeapp.fade://login-callback',
    );
  }

  // Sign in with Apple
  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'com.fadeapp.fade://login-callback',
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Get current session
  Session? get currentSession => _client.auth.currentSession;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;
}