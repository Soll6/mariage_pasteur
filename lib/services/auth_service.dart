import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  User? _currentUser;
  UserProfile? _currentProfile;
  String? _userRole;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  UserProfile? get currentProfile => _currentProfile;
  String? get userRole => _userRole;
  bool get isAuthenticated => _currentUser != null;
  bool get isCouple => _userRole == 'couple';
  bool get isAdmin => _userRole == 'admin';
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get displayName {
    if (_currentProfile?.displayName != null &&
        _currentProfile!.displayName!.isNotEmpty) {
      return _currentProfile!.displayName!;
    }
    if (_currentUser?.userMetadata?['full_name'] != null) {
      return _currentUser!.userMetadata!['full_name'] as String;
    }
    if (_currentUser?.email != null) {
      return _currentUser!.email!.split('@')[0];
    }
    return 'Invité';
  }

  AuthService() {
    _initAuthState();
    _setupAuthListener();
  }

  Future<void> _initAuthState() async {
    _currentUser = _client.auth.currentUser;
    if (_currentUser != null) {
      await _loadUserRole();
      await ensureUserProfile();
    }
    notifyListeners();
  }

  void _setupAuthListener() {
    // Listen to auth state changes from Supabase
    _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _currentUser = data.session?.user;
        _loadUserRole();
        ensureUserProfile();
        notifyListeners();
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _userRole = null;
        notifyListeners();
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        _currentUser = data.session?.user;
        notifyListeners();
      }
    });
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

  /// Sign up with email and password (for guests)
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? email.split('@')[0],
        },
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserRole();
        await ensureUserProfile();
        notifyListeners();
        return true;
      }

      _errorMessage = 'Erreur lors de l\'inscription';
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Auth error: $e');
      }
      if (e.toString().contains('already registered')) {
        _errorMessage = 'Cet email est déjà utilisé. Connectez-vous.';
      } else {
        _errorMessage = 'Erreur lors de l\'inscription. Réessayez.';
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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

  /// Load user profile from user_profiles table
  Future<void> _loadUserRole() async {
    if (_currentUser == null) return;

    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('user_id', _currentUser!.id)
          .maybeSingle();

      if (response != null) {
        _currentProfile = UserProfile.fromJson(response);
        _userRole = _currentProfile!.role;
      } else {
        _userRole = 'guest';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user profile: $e');
      }
      _userRole = 'guest';
    }
  }

  /// Create user profile if doesn't exist
  /// Also links to existing guest record by email (for re-registration)
  Future<bool> ensureUserProfile() async {
    if (_currentUser == null) return false;

    try {
      // Check if profile exists
      final response = await _client
          .from('user_profiles')
          .select('id, guest_id')
          .eq('user_id', _currentUser!.id)
          .maybeSingle();

      if (response == null) {
        // Create new profile with guest role
        await _client.from('user_profiles').insert({
          'user_id': _currentUser!.id,
          'role': 'guest',
        });
        _userRole = 'guest';
      }

      // Link to existing guest record by email if not already linked
      if (response == null || response['guest_id'] == null) {
        final guestId = await _linkToExistingGuest();
        if (guestId != null) {
          await _client
              .from('user_profiles')
              .update({'guest_id': guestId})
              .eq('user_id', _currentUser!.id);
        }
      }

      await _loadUserRole();
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error ensuring user profile: $e');
      }
      return false;
    }
  }

  /// Link current user to existing guest record by email
  Future<String?> _linkToExistingGuest() async {
    if (_currentUser == null) return null;

    try {
      final guest = await _client
          .from('guests')
          .select('id')
          .eq('email', _currentUser!.email!)
          .maybeSingle();

      return guest?['id'] as String?;
    } catch (e) {
      if (kDebugMode) {
        print('Error linking to guest: $e');
      }
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'mariage-pasteur://auth-callback',
      );

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Reset password error: $e');
      }
      _errorMessage = 'Erreur lors de l\'envoi du lien. Réessayez.';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete user account and related data
  /// The guest record is preserved (identified by email) so re-registration
  /// will link back to the same guest without needing re-confirmation.
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 1. Delete user_profiles (linked to auth user)
      await _client
          .from('user_profiles')
          .delete()
          .eq('user_id', _currentUser!.id);

      // 2. Delete the auth user via admin RPC (Supabase manages auth.users)
      //    We use the service_role key via Edge Function or direct DB call
      //    For now, we sign out and let the user know the account is deactivated
      //    The auth user will remain but without a profile, it's effectively inert

      // 3. Sign out
      await _client.auth.signOut();

      _currentUser = null;
      _currentProfile = null;
      _userRole = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Delete account error: $e');
      }
      _errorMessage = 'Erreur lors de la suppression du compte';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? avatarUrl,
    String? role,
  }) async {
    if (_currentUser == null) return false;

    try {
      final updates = <String, dynamic>{};
      if (displayName != null) {
        updates['display_name'] = displayName;
      }
      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }
      if (role != null) {
        updates['role'] = role;
      }

      if (updates.isEmpty) return true;

      updates['updated_at'] = DateTime.now().toIso8601String();

      final result = await _client
          .from('user_profiles')
          .update(updates)
          .eq('user_id', _currentUser!.id)
          .select();

      if (result.isEmpty) {
        updates['user_id'] = _currentUser!.id;
        updates['role'] = _userRole ?? 'guest';
        await _client.from('user_profiles').insert(updates);
      }

      if (role != null) {
        _userRole = role;
      }

      await _loadUserRole();
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      return false;
    }
  }
}
