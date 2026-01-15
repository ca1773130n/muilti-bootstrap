import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('MyApp builds', (tester) async {
    Env.initialize(
      flavorValue: 'dev',
      apiBaseUrlValue: 'https://example.com',
      appNameValue: 'TestApp',
      enableLoggingValue: 'false',
    );

    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
