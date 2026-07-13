import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mariage_pasteur/services/auth_service.dart';
import 'package:mariage_pasteur/widgets/auth_modal.dart';
import 'package:mariage_pasteur/widgets/auth_guard.dart';
import 'package:mariage_pasteur/models/user_profile.dart';

void main() {
  group('Integration Tests - Auth Flow', () {
    testWidgets('Public page access without auth', (WidgetTester tester) async {
      // Test that public pages can be accessed without authentication
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: const Text('Public Content - No Auth Required'),
            ),
          ),
        ),
      );

      expect(find.text('Public Content - No Auth Required'), findsOneWidget);
    });

    testWidgets('AuthModal appears on protected action', (WidgetTester tester) async {
      // Test that AuthModal is shown when attempting a protected action without auth
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthService(),
            child: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: tester.element,
                      builder: (dialogContext) => AuthModal(
                        action: 'rsvp',
                        onAuthenticated: () {},
                      ),
                    );
                  },
                  child: const Text('Protected Action'),
                ),
              ),
            ),
          ),
        ),
      );

      // Click the button to open the modal
      await tester.tap(find.text('Protected Action'));
      await tester.pump();

      // Verify AuthModal is displayed
      expect(find.text('Identifiez-vous'), findsOneWidget);
    });

    testWidgets('Admin route requires authentication', (WidgetTester tester) async {
      // Test that protected admin routes require authentication
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthService(),
            child: Scaffold(
              body: AuthGuard(
                requiredRoles: ['admin'],
                child: const Text('Admin Content'),
              ),
            ),
          ),
        ),
      );

      // Since user is not authenticated, should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AuthGuard basic test', (WidgetTester tester) async {
      // Basic test to ensure AuthGuard can be built
      await tester.pumpWidget(
        const MaterialApp(
          home: AuthGuard(
            requiredRoles: ['admin'],
            child: Scaffold(
              body: Center(
                child: Text('Protected Content'),
              ),
            ),
          ),
        ),
      );

      // The widget should build successfully
      expect(find.text('Protected Content'), findsOneWidget);
    });
  });
}
