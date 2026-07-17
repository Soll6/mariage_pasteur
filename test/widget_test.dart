import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mariage_pasteur/screens/enveloppe_screen.dart';

void main() {
  testWidgets('splash transition renders destination content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SplashToHomeTransition(
            animation: AlwaysStoppedAnimation(0.5),
            child: const Text('Accueil'),
          ),
        ),
      ),
    );

    expect(find.text('Accueil'), findsOneWidget);
  });
}
