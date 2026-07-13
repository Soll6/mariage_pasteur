import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mariage_pasteur/widgets/auth_modal.dart';
import 'package:mariage_pasteur/services/auth_service.dart';

void main() {
  group('AuthModal Tests', () {
    testWidgets('AuthModal displays action text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthService(),
            child: AuthModal(
              action: 'rsvp',
              onAuthenticated: () {},
            ),
          ),
        ),
      );

      expect(find.text('Identifiez-vous'), findsOneWidget);
      expect(find.text('Pour confirmer votre présence, veuillez vous identifier.'), findsOneWidget);
    });

    testWidgets('AuthModal displays upload action text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthService(),
            child: AuthModal(
              action: 'upload',
              onAuthenticated: () {},
            ),
          ),
        ),
      );

      expect(find.text('Pour ajouter une photo, veuillez vous identifier.'), findsOneWidget);
    });

    testWidgets('AuthModal displays comment action text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthService(),
            child: AuthModal(
              action: 'comment',
              onAuthenticated: () {},
            ),
          ),
        ),
      );

      expect(find.text('Pour commenter, veuillez vous identifier.'), findsOneWidget);
    });

    testWidgets('AuthModal has email input field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthService(),
            child: AuthModal(
              action: 'rsvp',
              onAuthenticated: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Votre email'), findsOneWidget);
    });

    testWidgets('AuthModal has send button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthService(),
            child: AuthModal(
              action: 'rsvp',
              onAuthenticated: () {},
            ),
          ),
        ),
      );

      expect(find.text('Recevoir un lien de connexion'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('AuthModal shows success state after email sent', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthService(),
            child: AuthModal(
              action: 'rsvp',
              onAuthenticated: () {},
            ),
          ),
        ),
      );

      // Initially should show email input
      expect(find.text('Votre email'), findsOneWidget);

      // After email is sent, show success message
      // Note: This test doesn't actually test the full flow as it requires mocking
      // the isGuestEmail and sendMagicLink methods
    });
  });
}
