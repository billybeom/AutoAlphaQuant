// 🆕 E15f3b — simToAuto 2단계 · 기동 복구 모의 파일 처리 판정(설계 13 §8 R100 AH3 · AH7).

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

SimLedgerFinishPlan _of({
  bool live = true,
  bool rows = true,
  bool closed = false,
  SimLedgerFate? fate = SimLedgerFate.keep,
}) => simLedgerFinishOf(
  liveCommitted: live,
  simHasRows: rows,
  simClosed: closed,
  fate: fate,
);

String _s(SimLedgerFinishPlan p) => '${p.closeSim}/${p.finish.name}';

void main() {
  test('실전 커밋 없음 · 모의 행 없음 = 아무것도 안 함(고름 · 닫힘 무관)', () {
    for (final SimLedgerFate? f in <SimLedgerFate?>[
      null,
      ...SimLedgerFate.values,
    ]) {
      for (final bool closed in <bool>[false, true]) {
        expect(_s(_of(live: false, fate: f, closed: closed)), 'false/none');
        expect(_s(_of(rows: false, fate: f, closed: closed)), 'false/none');
      }
    }
  });

  test('실전 커밋 있음 — 안 닫혔으면 CLOSE · 고름대로(고름 없음 = 남김)', () {
    expect(_s(_of()), 'true/keep');
    expect(_s(_of(fate: SimLedgerFate.discard)), 'true/discard');
    expect(_s(_of(fate: null)), 'true/keep');
    expect(_s(_of(closed: true)), 'false/keep');
    expect(_s(_of(closed: true, fate: SimLedgerFate.discard)), 'false/discard');
    expect(_s(_of(closed: true, fate: null)), 'false/keep');
  });

  test('지우기 결과 코드 = 엔진 문자열 · 서로 다름', () {
    expect(
      SimLedgerDeleteResult.values.map((SimLedgerDeleteResult r) => r.code),
      <String>[
        'SIM_LEDGER_DELETED',
        'SIM_LEDGER_MISSING',
        'SIM_LEDGER_NOT_CLOSED',
        'SIM_LEDGER_NOT_DISCARD',
        'SIM_LEDGER_DELETE_FAILED',
      ],
    );
  });
}
