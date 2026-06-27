import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pulseflow/main.dart';

void main() {
  testWidgets('Home screen shows PulseFlow title and Start button', (WidgetTester tester) async {
    await tester.pumpWidget(const PulseFlowApp());

    expect(find.text('PulseFlow'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('Tapping the pulse circle toggles to Stop', (WidgetTester tester) async {
    await tester.pumpWidget(const PulseFlowApp());

    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(find.text('Stop'), findsOneWidget);
  });
}
