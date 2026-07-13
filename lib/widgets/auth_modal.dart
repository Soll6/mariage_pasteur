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
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              'Identifiez-vous',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _getActionText(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (!_emailSent) ...[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Votre email',
                  border: const OutlineInputBorder(),
                  errorText: _errorMessage,
                  hintText: 'entrez votre email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendMagicLink,
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
                      : const Text('Recevoir un lien de connexion'),
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
            if (_errorMessage != null) ...[
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
    );
  }

  String _getActionText() {
    switch (widget.action) {
      case 'rsvp':
        return 'Pour confirmer votre présence, veuillez vous identifier.';
      case 'upload':
        return 'Pour ajouter une photo, veuillez vous identifier.';
      case 'comment':
        return 'Pour commenter, veuillez vous identifier.';
      default:
        return 'Pour continuer, veuillez vous identifier.';
    }
  }

  Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer un email valide.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _authService.sendMagicLink(email);

      if (!success) {
        setState(() {
          _isLoading = false;
          _errorMessage = _authService.errorMessage;
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _emailSent = true;
        _errorMessage = null;
      });
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
      _errorMessage = null;
    });
  }
}
