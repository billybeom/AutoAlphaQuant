// 사람 값 읽기 — 앱 자산 묶음에서(설계 13 §8 R154 · R153 발주자 결정).

import 'package:app_operator_android/platform/human_inputs_loader.dart';
import 'package:data_sync/data_sync.dart' show P0sHumanDecision;
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

  test('🔴 앱 자산 묶음(rootBundle)에 실린 사람 값 = 발주자 결정(229200 · A·POT = ISA · B = 연금 · C = 일반)', () async {
    final P0sHumanDecision d = await loadP0sHumanDecision(rootBundle);
    expect(d.inputs.aSymbol, '229200');
    expect(d.inputs.accountByStrategy, <String, String>{
      'P0S_A': 'isa',
      'P0S_B': 'pension',
      'P0S_C': 'general',
      'P0S_POT': 'isa',
    });
    expect(d.labelOf('isa'), 'ISA');
  });

  test('자산 키 · 없음 = 던짐 · 꼴 틀림 = FormatException', () async {
    final _Bundle missing = _Bundle(null);
    await expectLater(loadP0sHumanDecision(missing), throwsStateError);
    expect(missing.asked, <String>[
      'packages/data_sync/assets/config/p0s_human.json',
    ]);
    await expectLater(
      loadP0sHumanDecision(_Bundle('{"version": 2}')),
      throwsFormatException,
    );
  });
}
