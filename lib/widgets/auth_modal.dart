import 'package:flutter/material.dart';
import '../services/auth_service.dart';


class AuthModal extends StatefulWidget {
  final String action; // 'rsvp', 'upload', 'comment'
  final VoidCallback onAuthenticated;

  const AuthModal({
    super.key,
    required this.action,
    required this.onAuthenticated,
  });

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;
  bool _isLoginMode = true; // true = login, false = register

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  _isLoginMode ? 'Connexion' : 'Inscription',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _getActionText(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                const SizedBox(height: 20),

                // Email/Password Form
                if (!_emailSent) ...[
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email_outlined),
                      errorText: _errorMessage,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleEmailAuth,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(_isLoginMode ? 'Se connecter' : "S'inscrire"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                        _errorMessage = null;
                      });
                    },
                    child: Text(
                      _isLoginMode
                          ? "Pas de compte ? S'inscrire"
                          : 'Déjà un compte ? Se connecter',
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.mark_email_read,
                    size: 64,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Un lien de connexion a été envoyé à votre email.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _resetForm,
                      child: const Text('Retour'),
                    ),
                  ),
                ],

                // Error message
                if (_errorMessage != null && _emailSent) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }



  String _getActionText() {
    switch (widget.action) {
      case 'rsvp':
        return 'Pour confirmer votre présence, connectez-vous ou inscrivez-vous.';
      case 'upload':
        return 'Pour ajouter une photo, connectez-vous ou inscrivez-vous.';
      case 'comment':
        return 'Pour commenter, connectez-vous ou inscrivez-vous.';
      case 'general':
        return 'Connectez-vous ou créez un compte pour accéder à votre espace invité.';
      default:
        return 'Pour continuer, connectez-vous ou inscrivez-vous.';
    }
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Le mot de passe doit contenir au moins 6 caractères.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool success;
      if (_isLoginMode) {
        success = await _authService.signIn(email: email, password: password);
      } else {
        success = await _authService.signUp(email: email, password: password);
      }

      if (!success) {
        setState(() {
          _isLoading = false;
          _errorMessage = _authService.errorMessage ?? 'Erreur lors de l\'authentification.';
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });

      widget.onAuthenticated();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur inattendue. Réessayez.';
      });
    }
  }



  void _resetForm() {
    setState(() {
      _emailSent = false;
      _emailController.clear();
      _passwordController.clear();
      _errorMessage = null;
    });
  }
}
