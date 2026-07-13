import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

/// Service pour l'authentification sociale via Google
class SocialAuthService {
  final SupabaseClient _client = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: 'YOUR_GOOGLE_CLIENT_ID',
    scopes: [
      'email',
      'profile',
    ],
  );

  static const String kGoogleProvider = 'google.com';

  /// Get current Google user
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _googleSignIn.currentUser != null;

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('Starting Google Sign In...');
      }

      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (kDebugMode) {
          print('Google Sign In cancelled');
        }
        return false;
      }

      if (kDebugMode) {
        print('Google user: ${googleUser.displayName}, ${googleUser.email}');
      }

      // Get the authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (googleAuth.idToken == null) {
        if (kDebugMode) {
          print('Google Sign In failed - idToken is null');
        }
        return false;
      }

      if (kDebugMode) {
        print('Got idToken: ${googleAuth.idToken!.substring(0, 20)}...');
      }

      // Sign in to Supabase with identity provider
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
      );

      if (response.user == null) {
        if (kDebugMode) {
          print('Supabase sign in failed');
        }
        return false;
      }

      if (kDebugMode) {
        print('Successfully signed in with Google to Supabase');
      }

      // Ensure user profile exists
      final userProfile = await _client
          .from('user_profiles')
          .select()
          .eq('user_id', response.user!.id)
          .maybeSingle();

      if (userProfile == null) {
        // Create new user profile
        await _client.from('user_profiles').insert({
          'user_id': response.user!.id,
          'email': googleUser.email,
          'display_name': googleUser.displayName,
          'avatar_url': googleUser.photoUrl,
          'role': 'guest',
          'provider': kGoogleProvider,
        });
      }

      return true;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Google Sign In error: $e');
      }
      return false;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _client.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
    }
  }

  /// Sign in with Apple (iOS only)
  Future<bool> signInWithApple() async {
    try {
      // Apple sign-in implementation would go here
      // Requires sign_in_with_apple package
      if (kDebugMode) {
        print('Apple Sign In not yet implemented');
      }
      return false;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Apple Sign In error: $e');
      }
      return false;
    }
  }
}
