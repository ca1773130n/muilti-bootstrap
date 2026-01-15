import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

void main() {
  testWidgets('AppButton renders label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppButton(onPressed: null, child: Text('Continue')),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('AppTextField renders label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppTextField(label: 'Email')),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('LoadingIndicator renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoadingIndicator())),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
