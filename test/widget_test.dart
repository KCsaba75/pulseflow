import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pulseflow/config/app_config.dart';
import 'package:pulseflow/main.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  });

  testWidgets('Unauthenticated user sees the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PulseFlowApp());

    expect(find.text('PulseFlow'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
