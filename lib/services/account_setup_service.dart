import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to setup admin and couple accounts
class AccountSetupService {
  static final _client = Supabase.instance.client;

  /// Create or update admin and couple accounts
  static Future<AccountSetupResult> setupAllAccounts() async {
    final results = <String, dynamic>{};

    try {
      // Setup admin account
      final adminResult = await setupAccount(
        email: 'zolasoll7@gmail.com',
        password: 'zola2026',
        role: 'admin',
      );
      results['admin'] = adminResult;

      // Setup couple account
      final coupleResult = await setupAccount(
        email: 'aimemaboundou@gmail.com',
        password: 'francis2026',
        role: 'couple',
      );
      results['couple'] = coupleResult;

      return AccountSetupResult(
        success: true,
        message: 'All accounts setup successfully',
        details: results,
      );
    } catch (e) {
      return AccountSetupResult(
        success: false,
        message: 'Error setting up accounts: $e',
        details: results,
      );
    }
  }

  /// Setup a single account via edge function
  static Future<dynamic> setupAccount({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'setup-admin-accounts',
        body: {
          'email': email,
          'password': password,
          'role': role,
        },
      );

      final data = response.data is Map ? response.data as Map<String, dynamic> : <String, dynamic>{};
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Account setup completed',
        'userId': data['userId'],
      };
    } catch (e) {
      throw Exception('Failed to setup account $email: $e');
    }
  }

  /// Verify accounts are configured correctly
  static Future<AccountVerificationResult> verifyAccounts() async {
    try {
      final result = await _client
          .from('user_profiles')
          .select('id, user_id, role')
          .inFilter('role', ['admin', 'couple']);

      final adminCount = (result as List)
          .where((user) => user['role'] == 'admin')
          .length;
      final coupleCount = (result as List)
          .where((user) => user['role'] == 'couple')
          .length;

      final isValid = adminCount > 0 && coupleCount > 0;

      return AccountVerificationResult(
        success: isValid,
        adminConfigured: adminCount > 0,
        coupleConfigured: coupleCount > 0,
        totalAccounts: (result as List).length,
        details: result,
      );
    } catch (e) {
      return AccountVerificationResult(
        success: false,
        message: 'Error verifying accounts: $e',
        adminConfigured: false,
        coupleConfigured: false,
        totalAccounts: 0,
        details: [],
      );
    }
  }

  /// Get account info
  static Future<Map<String, dynamic>?> getAccountInfo(String email) async {
    try {
      final user = await _client
          .from('auth.users')
          .select('id, email')
          .eq('email', email)
          .maybeSingle();

      if (user == null) return null;

      final profile = await _client
          .from('user_profiles')
          .select('role')
          .eq('user_id', user['id'])
          .maybeSingle();

      return {
        'email': user['email'],
        'userId': user['id'],
        'role': profile?['role'] ?? 'unknown',
      };
    } catch (e) {
      return null;
    }
  }
}

/// Result of account setup
class AccountSetupResult {
  final bool success;
  final String message;
  final Map<String, dynamic> details;

  AccountSetupResult({
    required this.success,
    required this.message,
    required this.details,
  });

  @override
  String toString() => 'AccountSetupResult(success: $success, message: $message)';
}

/// Result of account verification
class AccountVerificationResult {
  final bool success;
  final bool adminConfigured;
  final bool coupleConfigured;
  final int totalAccounts;
  final List<dynamic> details;
  final String? message;

  AccountVerificationResult({
    required this.success,
    required this.adminConfigured,
    required this.coupleConfigured,
    required this.totalAccounts,
    required this.details,
    this.message,
  });

  bool get allConfigured => adminConfigured && coupleConfigured;

  @override
  String toString() =>
      'AccountVerificationResult(admin: $adminConfigured, couple: $coupleConfigured, total: $totalAccounts)';
}
