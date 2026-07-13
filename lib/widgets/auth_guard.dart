import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AuthGuard extends StatelessWidget {
  final List<String> requiredRoles;
  final Widget child;

  const AuthGuard({
    super.key,
    required this.requiredRoles,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // Check if user is authenticated
    if (!authService.isAuthenticated) {
      // Redirect to admin login if not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/admin/login');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Check if user has the required role
    if (!requiredRoles.contains(authService.userRole)) {
      // Redirect based on role
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (authService.isCouple) {
          // Redirect couple to couple dashboard
          Navigator.of(context).pushReplacementNamed('/couple');
        } else {
          // Redirect guests to home
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Vous n\'avez pas les permissions nécessaires pour accéder à cette page.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return child;
  }
}
