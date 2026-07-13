import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  User? _currentUser;
  String? _userRole; // 'guest', 'couple', 'admin'
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  String? get userRole => _userRole;
  bool get isAuthenticated => _currentUser != null;
  bool get isCouple => _userRole == 'couple';
  bool get isAdmin => _userRole == 'admin';
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthService() {
    _initAuthState();
  }

  Future<void> _initAuthState() async {
    _currentUser = _client.auth.currentUser;
    if (_currentUser != null) {
      await _loadUserRole();
    }
  }

  /// Sign in with email and password (for admin/couple)
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserRole();
        notifyListeners();
        return true;
      }

      _errorMessage = 'Identifiants incorrects';
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Auth error: $e');
      }
      _errorMessage = 'Identifiants incorrects';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send magic link for OTP authentication (for guests)
  Future<bool> sendMagicLink(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // First check if email exists in guests table
      final isGuest = await isGuestEmail(email);
      if (!isGuest) {
        _errorMessage = 'Cet email n\'est pas dans la liste des invités. Contactez les mariés.';
        notifyListeners();
        return false;
      }

      await _client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'mariage-pasteur://auth-callback',
      );

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Magic link error: $e');
      }
      _errorMessage = 'Erreur lors de l\'envoi du lien. Réessayez.';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if email exists in guests table
  Future<bool> isGuestEmail(String email) async {
    try {
      final response = await _client
          .from('guests')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return response != null;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking guest email: $e');
      }
      return false;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _currentUser = null;
      _userRole = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
    }
  }

  /// Load user role from user_profiles table
  Future<void> _loadUserRole() async {
    if (_currentUser == null) return;

    try {
      final response = await _client
          .from('user_profiles')
          .select('role')
          .eq('user_id', _currentUser!.id)
          .maybeSingle();

      _userRole = response?['role'] ?? 'guest';
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user role: $e');
      }
      // Default to guest if error
      _userRole = 'guest';
    }
  }

  /// Create user profile if doesn't exist
  Future<bool> ensureUserProfile() async {
    if (_currentUser == null) return false;

    try {
      // Check if profile exists
      final response = await _client
          .from('user_profiles')
          .select('id')
          .eq('user_id', _currentUser!.id)
          .maybeSingle();

      if (response == null) {
        // Create new profile with guest role
        await _client.from('user_profiles').insert({
          'user_id': _currentUser!.id,
          'role': 'guest',
        });
        _userRole = 'guest';
        notifyListeners();
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error ensuring user profile: $e');
      }
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? avatarUrl,
    String? role,
  }) async {
    if (_currentUser == null) return false;

    try {
      final updates = <String, dynamic>{};
      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }
      if (role != null) {
        updates['role'] = role;
      }

      await _client
          .from('user_profiles')
          .update(updates)
          .eq('user_id', _currentUser!.id);

      if (role != null) {
        _userRole = role;
      }
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      return false;
    }
  }

  /// Test helper: Set current user (for testing only)
  void _testSetCurrentUser(User? user) {
    _currentUser = user;
    _isLoading = false;
    notifyListeners();
  }

  /// Test helper: Set user role (for testing only)
  void _testSetRole(String role) {
    _userRole = role;
    notifyListeners();
  }
}
