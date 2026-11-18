// E11p4e — 사람 값 원천(설계 13 §8 R154 · R153 발주자 결정).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart' show P0sStrategyIds;
import 'package:data_sync/data_sync.dart';
import 'package:test/test.dart';

Map<String, Object?> _shipped() =>
    jsonDecode(File(kP0sHumanAssetPath).readAsStringSync())
        as Map<String, Object?>;

String _with(void Function(Map<String, Object?> j) edit) {
  final Map<String, Object?> j = _shipped();
  edit(j);
  return jsonEncode(j);
}

void main() {
  test('🔴 실린 자산 = 발주자 결정(R153) — A 종목 229200 · A·POT = ISA(같은 계좌) · B = 연금 · C = 일반 · 표시 글자', () {
    final P0sHumanDecision d = p0sHumanDecisionFromText(
      File(kP0sHumanAssetPath).readAsStringSync(),
    );
    expect(d.inputs.aSymbol, '229200');
    final Map<String, String> m = d.inputs.accountByStrategy;
    expect(m, <String, String>{
      P0sStrategyIds.sleeveA: 'isa',
      P0sStrategyIds.sleeveB: 'pension',
      P0sStrategyIds.sleeveC: 'general',
      P0sStrategyIds.pot: 'isa',
    });
    // 🔴 POT 는 A 와 같은 계좌(POT 청산 대금 = A 진입 재원 · 02 v2.38).
    expect(m[P0sStrategyIds.pot], m[P0sStrategyIds.sleeveA]);
    expect(d.labelOf('isa'), 'ISA');
    expect(d.labelOf('pension'), '연금저축');
    expect(d.labelOf('general'), '일반 위탁');
    expect(d.labelOf('other'), 'other');
    expect(d.decisionRef, contains('R153'));
    expect(
      kP0sHumanAssetKey,
      'packages/data_sync/assets/config/p0s_human.json',
    );
  });

  test('🔴 꼴 틀림 = FormatException(조용히 넘어가지 않는다) — JSON 아님 · 판 · 종목 · 결정 근거 · 계좌 · 표시 글자', () {
    void bad(String text, String why) => expect(
      () => p0sHumanDecisionFromText(text),
      throwsA(isA<FormatException>()),
      reason: why,
    );
    bad('not json', 'JSON 아님');
    bad('[]', '객체 아님');
    bad(_with((Map<String, Object?> j) => j['version'] = 2), '판 다름');
    bad(_with((Map<String, Object?> j) => j.remove('version')), '판 없음');
    bad(
      _with((Map<String, Object?> j) => j.remove('sleeve_a_symbol')),
      '종목 없음',
    );
    bad(
      _with((Map<String, Object?> j) => j['sleeve_a_symbol'] = '22920'),
      '종목 6자리 아님',
    );
    bad(_with((Map<String, Object?> j) => j.remove('decision')), '결정 근거 없음');
    bad(_with((Map<String, Object?> j) => j['decision'] = '  '), '결정 근거 빈');
    bad(_with((Map<String, Object?> j) => j.remove('accounts')), '계좌 없음');
    bad(
      _with(
        (Map<String, Object?> j) =>
            (j['accounts']! as Map<String, Object?>).remove(P0sStrategyIds.pot),
      ),
      '전략 넷이 아님',
    );
    bad(
      _with(
        (Map<String, Object?> j) =>
            (j['accounts']! as Map<String, Object?>)['P0S_X'] = 'isa',
      ),
      '모르는 전략',
    );
    bad(
      _with(
        (Map<String, Object?> j) =>
            (j['accounts']! as Map<String, Object?>)[P0sStrategyIds.sleeveC] =
                '',
      ),
      '빈 별칭',
    );
    bad(
      _with(
        (Map<String, Object?> j) =>
            (j['accounts']! as Map<String, Object?>)[P0sStrategyIds.sleeveC] =
                7,
      ),
      '별칭이 글자 아님',
    );
    bad(
      _with(
        (Map<String, Object?> j) =>
            (j['account_labels']! as Map<String, Object?>).remove('general'),
      ),
      '별칭 표시 글자 빠짐',
    );
    bad(
      _with((Map<String, Object?> j) => j.remove('account_labels')),
      '표시 글자 없음',
    );
  });
}
