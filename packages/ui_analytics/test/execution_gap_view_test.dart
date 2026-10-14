import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── T710-17 ────────────────────────────────────────────────────────────────
  testWidgets('T710-17 autoDispose', (WidgetTester tester) async {
    final String content = File('lib/src/providers/analytics_providers.dart')
        .readAsStringSync();
    final List<String> autoDisposeLines = content
        .split('\n')
        .where((String line) => line.contains('autoDispose'))
        .toList();
    expect(autoDisposeLines, hasLength(9));
  });
}
