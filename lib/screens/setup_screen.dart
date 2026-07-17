import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _client = Supabase.instance.client;
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _setupAccounts();
  }

  Future<void> _setupAccounts() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _isSuccess = false;
    });

    try {
      // Setup admin account
      await _setupAccount(
        email: 'zolasoll7@gmail.com',
        password: 'zola2026',
        role: 'admin',
      );

      // Setup couple account
      await _setupAccount(
        email: 'aimemaboundou@gmail.com',
        password: 'francis2026',
        role: 'couple',
      );

      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _message = '✅ Tous les comptes ont été configurés avec succès!\n\n'
            'Admin: zolasoll7@gmail.com\n'
            'Mot de passe: zola2026\n\n'
            'Couple: aimemaboundou@gmail.com\n'
            'Mot de passe: francis2026';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = '❌ Erreur: $e';
      });
    }
  }

  Future<void> _setupAccount({
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
      print('✅ $email setup: ${response.data}');
    } catch (e) {
      print('Error setting up $email: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration des Comptes'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Configuration en cours...'),
              ] else if (_isSuccess) ...[
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Retour à l\'accueil'),
                ),
              ] else ...[
                const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _setupAccounts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
