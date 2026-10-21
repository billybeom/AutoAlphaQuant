// E7a3-1 — lib 월말 계획기(`planMonthEnd` · Decimal)가 재현 하네스(참조 엔진과 26년 비트 일치)의 월말 조정과 같은가.
//
// 🔵 다섯 실행(S7 · S6 · delay1 · nogate · nocut)의 **모든** KR 월말에서, 하네스가 `_krMonthEnd` 직전에 가진 상태를
//    lib 입력으로 옮겨 계획을 세우고, 하네스가 그날 남긴 원장 행(램프 · 코어 밴드 · 조달 · B 재원 · POT)과 쌓은 주문
//    (B 신호 → 다음 KR · C 리밸런싱 → 다음 US)을 **순서·종류·종목·방향**까지 맞대고 금액·비용은 1원 안에서 맞댄다.
// 🔵 하네스는 double · lib 는 Decimal 이다 — 금액 차이는 반올림 자리(원 미만 한참 아래)뿐이어야 한다.

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'replay_engine.dart';
import 'replay_market.dart';
import 'replay_month_end_config.dart';
import 'replay_regime.dart';

/// 하네스 한 행 → (종류, 종목, 매수?, 금액, 비용).
(MonthEndActionKind, String?, bool?, double, double) _fromLedger(LedgerRow r) {
  final MonthEndActionKind k = switch ((r.event, r.symbol)) {
    ('RAMP_DEPOSIT', _) => MonthEndActionKind.rampContribution,
    ('CORE_BAND', 'B->C(재분류)') => MonthEndActionKind.coreBandReclassify,
    ('CORE_BAND', 'C->B(재분류환원)') => MonthEndActionKind.coreBandReclaim,
    ('CORE_BAND', 'C->B') => MonthEndActionKind.coreBandContribution,
    ('RAISE_KRW', _) => MonthEndActionKind.raiseKrw,
    ('SLEEVE_B_FUNDING', _) => MonthEndActionKind.sleeveBFundingSell,
    ('D2_POT_SMA', _) => MonthEndActionKind.potTrade,
    _ => throw StateError('월말에 모르는 원장 행: ${r.event} ${r.symbol}'),
  };
  final bool transfer = r.side == 'MOVE';
  return (
    k,
    transfer ? null : r.symbol,
    transfer ? null : r.side == 'BUY',
    r.gross,
    r.cost,
  );
}

void main() {
  final ReplayMarket market = ReplayMarket.build();
  final ReplayRegime regime = ReplayRegime.build();
  final Map<String, Map<MonthEndActionKind, int>> coverage =
      <String, Map<MonthEndActionKind, int>>{};

  for (final ReplayVariant v in <ReplayVariant>[
    ReplayVariant.s7,
    ReplayVariant.s6,
    ReplayVariant.delay1,
    ReplayVariant.nogate,
    ReplayVariant.nocut,
  ]) {
    test('${v.name} — 모든 KR 월말에서 lib 계획 = 하네스 조정(순서·종류·종목·방향 · 금액·비용 1원 안)', () {
      final MonthEndConfig cfg = harnessMonthEndConfig(v);
      final ReplayEngine e = ReplayEngine(market, regime, variant: v);
      final List<String> bad = <String>[];
      final Map<MonthEndActionKind, int> seen = <MonthEndActionKind, int>{};
      int monthEnds = 0;
      double maxDiff = 0.0;
      late MonthEndPlan plan;
      late int ledgerBefore;
      late int krBefore, usBefore;
      String? nextKr, nextUs;
      e.onBeforeMonthEnd = (int i, String d) {
        plan = planMonthEnd(e.monthEndInput(i, d), cfg);
        ledgerBefore = e.ledger.length;
        nextKr = e.nextKrSession(d);
        nextUs = e.nextUsSession(d);
        krBefore = nextKr == null ? 0 : e.pendingOn(nextKr!).length;
        usBefore = nextUs == null ? 0 : e.pendingOn(nextUs!).length;
      };
      e.onAfterMonthEnd = (int i, String d) {
        monthEnds++;
        final List<LedgerRow> rows = e.ledger.sublist(ledgerBefore);
        final List<(MonthEndActionKind, String?, bool?, double, double)>
        want = <(MonthEndActionKind, String?, bool?, double, double)>[
          for (final LedgerRow r in rows)
            if (r.event != 'D2_POT_SMA') _fromLedger(r),
          if (nextKr != null)
            for (final (
                  String _,
                  String sym,
                  String side,
                  double amt,
                  String ev,
                )
                in e.pendingOn(nextKr!).sublist(krBefore))
              if (ev == 'SLEEVE_B_SMA')
                (MonthEndActionKind.sleeveBOrder, sym, side == 'BUY', amt, 0.0),
          if (nextUs != null)
            for (final (
                  String _,
                  String sym,
                  String side,
                  double amt,
                  String ev,
                )
                in e.pendingOn(nextUs!).sublist(usBefore))
              if (ev == 'SLEEVE_C_REBAL')
                (MonthEndActionKind.sleeveCOrder, sym, side == 'BUY', amt, 0.0),
          for (final LedgerRow r in rows)
            if (r.event == 'D2_POT_SMA') _fromLedger(r),
        ];
        final List<MonthEndAction> got = plan.actions;
        if (got.length != want.length) {
          bad.add(
            '$d — 행동 수 lib ${got.length} ↔ 하네스 ${want.length}: lib $got · 하네스 $want',
          );
          return;
        }
        for (int k = 0; k < got.length; k++) {
          final MonthEndAction g = got[k];
          final (
            MonthEndActionKind wk,
            String? ws,
            bool? wb,
            double wa,
            double wc,
          ) = want[k];
          if (g.kind != wk || g.symbol != ws || g.isBuy != wb) {
            bad.add('$d [$k] — lib $g ↔ 하네스 ($wk $ws $wb $wa)');
            continue;
          }
          final double da = (g.amount.toDouble() - wa).abs();
          final double dc = (g.cost.toDouble() - wc).abs();
          if (da > maxDiff) maxDiff = da;
          if (da > 1.0 || dc > 1.0) {
            bad.add(
              '$d [$k] ${g.kind.name} ${g.symbol} — 금액 lib ${g.amount} ↔ $wa · 비용 ${g.cost} ↔ $wc',
            );
          }
          seen[g.kind] = (seen[g.kind] ?? 0) + 1;
        }
      };
      e.run();
      coverage[v.name] = seen;
      expect(monthEnds, greaterThan(300));
      expect(
        bad,
        isEmpty,
        reason: '${bad.length}건 — 처음 5: ${bad.take(5).join('\n')}',
      );
      expect(maxDiff, lessThan(1e-3), reason: '금액 차이는 반올림 자리뿐이어야 한다');
    });
  }

  test('다섯 실행을 합치면 계획 행동 9종이 모두 한 번 이상 나왔다(검사가 빈 갈래를 보지 않은 것이 아니다)', () {
    final Map<MonthEndActionKind, int> all = <MonthEndActionKind, int>{};
    for (final Map<MonthEndActionKind, int> m in coverage.values) {
      m.forEach((MonthEndActionKind k, int n) => all[k] = (all[k] ?? 0) + n);
    }
    expect(
      all.keys.toSet(),
      MonthEndActionKind.values.toSet(),
      reason: '$coverage',
    );
  });
}
