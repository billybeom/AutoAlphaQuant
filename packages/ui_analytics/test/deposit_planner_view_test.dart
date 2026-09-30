// test/deposit_planner_view_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('T74-22 planner library export structure', () {
    final plannerFile = File('lib/planner.dart');
    final content = plannerFile.readAsStringSync();
    final exportLines = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.startsWith('export '))
        .toSet();

    expect(exportLines, {
      "export 'src/planner/deposit_planner_screen.dart';",
      "export 'src/planner/planner_providers.dart';",
    });

    final checkDirs = [
      'lib/ui_analytics.dart',
      'lib/src/screens',
      'lib/src/widgets',
      'lib/src/providers',
    ];

    for (final path in checkDirs) {
      if (FileSystemEntity.isFileSync(path)) {
        final text = File(path).readAsStringSync();
        expect(text.contains('planner'), isFalse, reason: 'File $path must not contain planner');
      } else if (FileSystemEntity.isDirectorySync(path)) {
        for (final file in Directory(path).listSync(recursive: true)) {
          if (file is File && file.path.endsWith('.dart')) {
            final text = file.readAsStringSync();
            expect(text.contains('planner'), isFalse, reason: 'File ${file.path} must not contain planner');
          }
        }
      }
    }
  });
}
