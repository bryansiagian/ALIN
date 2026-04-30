import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/main.dart';

void main() {
  testWidgets('ALIN app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AlinApp()),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}