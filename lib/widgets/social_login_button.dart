import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import '../services/social_auth_service.dart';

class SocialLoginButton extends StatelessWidget {
  final SocialAuthService socialAuthService;
  final VoidCallback? onSignInSuccess;
  final VoidCallback? onSignInError;
  final String provider;

  const SocialLoginButton({
    super.key,
    required this.socialAuthService,
    this.onSignInSuccess,
    this.onSignInError,
    this.provider = 'google',
  });

  @override
  Widget build(BuildContext context) {
    switch (provider) {
      case 'google':
        return SignInButton(
          Buttons.GoogleDark,
          text: 'Continuer avec Google',
          onPressed: () async {
            final success =
                await socialAuthService.signInWithGoogle();
            if (success) {
              if (onSignInSuccess != null) {
                onSignInSuccess!();
              }
            } else {
              if (onSignInError != null) {
                onSignInError!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Erreur lors de la connexion Google. Veuillez réessayer.'),
                  ),
                );
              }
            }
          },
        );

      case 'facebook':
        return SignInButton(
          Buttons.Facebook,
          text: 'Continuer avec Facebook',
          onPressed: () {
            // Facebook sign-in would go here
            if (onSignInError != null) {
              onSignInError!();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'La connexion Facebook n\'est pas encore implémentée.'),
                ),
              );
            }
          },
        );

      case 'apple':
        return SignInButton(
          Buttons.Apple,
          text: 'Continuer avec Apple',
          onPressed: () async {
            final success =
                await socialAuthService.signInWithApple();
            if (success) {
              if (onSignInSuccess != null) {
                onSignInSuccess!();
              }
            } else {
              if (onSignInError != null) {
                onSignInError!();
              }
            }
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
