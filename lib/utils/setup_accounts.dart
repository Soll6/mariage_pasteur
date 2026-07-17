import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper class to setup admin and couple accounts
class AccountSetup {
  static final _client = Supabase.instance.client;

  /// Setup admin and couple accounts
  /// This function should be called once to initialize the accounts
  static Future<void> setupAccounts() async {
    try {
      // Admin account
      await _setupAccount(
        email: 'zolasoll7@gmail.com',
        password: 'zola2026',
        role: 'admin',
      );

      // Couple account
      await _setupAccount(
        email: 'aimemaboundou@gmail.com',
        password: 'francis2026',
        role: 'couple',
      );

      print('✅ Admin and couple accounts setup successfully!');
    } catch (e) {
      print('❌ Error during account setup: $e');
      rethrow;
    }
  }

  static Future<void> _setupAccount({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Call the edge function to create/update account
      final response = await _client.functions.invoke(
        'setup-admin-accounts',
        body: {
          'email': email,
          'password': password,
          'role': role,
        },
      );

      print('✅ Account $email setup: ${response.data}');
    } catch (e) {
      print('❌ Error setting up $email: $e');
      rethrow;
    }
  }

  /// Verify that accounts are properly configured
  static Future<void> verifyAccounts() async {
    try {
      final users = await _client
          .from('user_profiles')
          .select('user_id, role')
          .inFilter('role', ['admin', 'couple']);

      print('✅ Account verification:');
      for (final user in users) {
        final role = user['role'];
        final userId = user['user_id'];
        print('  - $role: $userId');
      }
    } catch (e) {
      print('❌ Error verifying accounts: $e');
    }
  }
}
