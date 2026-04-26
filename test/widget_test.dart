// SMO Flutter app — smoke test
// Verifies the app launches without throwing.

import 'package:flutter_test/flutter_test.dart';
import 'package:smo_flutter/main.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // App renders without throwing
    expect(tester.takeException(), isNull);
  });
}
