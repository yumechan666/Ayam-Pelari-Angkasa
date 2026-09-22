// Smoke test: pastikan aplikasi dapat di-build tanpa error kompilasi.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kucing/game/data.dart';
import 'package:kucing/main.dart';

void main() {
  testWidgets('App boots without throwing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MyApp(progress: defaultProgress(), prefs: prefs));
    await tester.pump();
  });
}
