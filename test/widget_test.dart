// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:luxury_taxi_app/main.dart';
import 'package:luxury_taxi_app/utils/app_strings.dart';

void main() {
  testWidgets('Login screen shows validation errors when empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(const VaneLuxApp());

    expect(find.text('VaneLux'), findsWidgets);
    expect(find.text(AppConstants.signIn), findsWidgets);

    await tester.tap(find.text(AppConstants.signIn).first);
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.pleaseEnterEmail), findsOneWidget);
    expect(find.text(AppConstants.pleaseEnterPassword), findsOneWidget);
  });
}
