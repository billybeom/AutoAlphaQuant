// 운영 설정 읽기 — 앱 자산 묶음에서(설계 13 §8 R148 Z6).

import 'package:app_operator_android/engine/operations_loader.dart';
import 'package:core_engine/core_engine.dart' show OperationsConfig;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _Bundle extends CachingAssetBundle {
  _Bundle(this.text);
  final String? text;
  final List<String> asked = <String>[];

  @override
  Future<ByteData> load(String key) async {
    asked.add(key);
    final String? t = text;
    if (t == null) throw StateError('자산 없음: $key');
    return ByteData.sublistView(Uint8List.fromList(t.codeUnits));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('🔴 앱 자산 묶음(rootBundle)에서 data_sync 운영 설정을 읽는다', () async {
    final OperationsConfig c = await loadOperationsConfig(rootBundle);
    expect(c.maintenanceOverdue, const Duration(hours: 72));
    expect(c.migrationObservation!.emergencyTradingDays, 5);
  });

  test('자산 키 · 없음 = 던짐 · 꼴 틀림 = FormatException', () async {
    final _Bundle ok = _Bundle(
      '{"migration": {"maintenance_overdue_hours": 5}}',
    );
    expect((await loadOperationsConfig(ok)).maintenanceOverdueHours, 5);
    expect(ok.asked, <String>[
      'packages/data_sync/assets/config/operations.json',
    ]);
    await expectLater(loadOperationsConfig(_Bundle(null)), throwsStateError);
    await expectLater(
      loadOperationsConfig(_Bundle('[]')),
      throwsFormatException,
    );
  });
}
