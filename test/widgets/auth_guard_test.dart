import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mariage_pasteur/widgets/auth_guard.dart';

void main() {
  group('AuthGuard Tests', () {
    testWidgets('AuthGuard allows authorized users', (WidgetTester tester) async {
      // Basic test to ensure AuthGuard can be built
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthGuard(
              requiredRoles: ['admin'],
              child: Center(
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
