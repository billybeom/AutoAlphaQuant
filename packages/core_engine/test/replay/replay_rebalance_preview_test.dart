// E7a3-2 — 리밸런싱 미리보기를 26년 재현의 **모든 KR 월말**에서 실제 상태로 돌려 본다(S7 · nogate).
//
// 🔵 월말마다 하네스 상태를 What-if 상태(월말 계획기 입력 + as-of 종가)로 옮겨 `previewRebalancePlan` 을 부르고:
//    · E7a0 판정 함수 — C-41 ①(한 갈래) · ②(as-of · 머리 글자 · 고지 · 빈 초안 짝 · 지정가 짝 · 계좌 별칭)
//    · 초안 = 계획 행동 중 매매의 정수 주(금액 ÷ 종가 버림 · 0주 제외)와 순서·종목·방향·수량이 같다
//    · 사유 칩 코드가 사전에 있다 · 전후 비중 세 줄(회계 기준) 합 = 1 · JSON 왕복
// 🔵 미리보기는 계획기를 그대로 쓴다(실집행과 같은 경로) — 계획기 자체의 하네스 일치는 `replay_month_end_test.dart` 몫.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'replay_engine.dart';
import 'replay_market.dart';
import 'replay_month_end_config.dart';
import 'replay_regime.dart';

Decimal _dec(double x) => Decimal.parse(x.toString());

void main() {
  final ReplayMarket market = ReplayMarket.build();
  final ReplayRegime regime = ReplayRegime.build();

  for (final ReplayVariant v in <ReplayVariant>[
    ReplayVariant.s7,
    ReplayVariant.nogate,
  ]) {
    test(
      '${v.name} — 월말 320 전부: C-41 ①② · 초안 = 계획 매매의 정수 주 · 사유 코드 · 전후 비중 · JSON 왕복',
      () {
        final WhatIfConfig cfg = WhatIfConfig(
          planTtl: const Duration(hours: 24),
          pensionAnnualLimit: Decimal.parse('18000000'),
          taxCreditBand: Decimal.parse('9000000'),
          depositMin: Decimal.one,
          depositMax: Decimal.parse('1000000000'),
          monthEnd: harnessMonthEndConfig(v),
          symbolLabels: const <String, String>{
            '133690': '133690 TIGER 미국나스닥100',
            '411060': '411060 ACE KRX금현물',
            'IEI': 'IEI 미국 중기채(참조)',
            'IAU': 'IAU 금(참조)',
          },
        );
        final ReplayEngine e = ReplayEngine(market, regime, variant: v);
        final List<String> bad = <String>[];
        final Map<String, int> codes = <String, int>{};
        int months = 0, empty = 0, contributionLines = 0;
        e.onBeforeMonthEnd = (int i, String d) {
          months++;
          final MonthEndState me = e.monthEndInput(i, d);
          double px(String k) => e.m.px[k]!.values[i];
          final double fx = px('fx');
          final WhatIfState s = WhatIfState(
            asOfTradeDate: TradeDate(d),
            configHash: 'cfg_replay',
            activeFlags: const <BlockFlag>[],
            recovery: false,
            accounts: const WhatIfAccounts(
              pensionAlias: '연금저축',
              generalAlias: '일반',
            ),
            pensionUsedThisYear: me.pensionUsedThisYear,
            observedAt: DateTime.parse('${d}T09:00:00Z'),
            source: AsOfSource.localSqlite,
            sleeveValues: const <SleeveId, Decimal>{},
            prices: <String, Decimal>{
              for (final String t in <String>['133690', '411060'])
                if (px(t).isFinite && px(t) > 0) t: _dec(px(t)),
              if (px('IEI').isFinite) 'IEI': _dec(px('IEI') * fx),
              if (px('IAU').isFinite && px('IAU') > 0)
                'IAU': _dec(px('IAU') * fx),
            },
            monthEnd: me,
          );
          final String? next = e.nextKrSession(d);
          final RebalancePreviewResult r = previewRebalancePlan(
            s,
            cfg,
            planned: next == null ? null : TradeDate(next),
            planId: 'pv_re_replay',
          );
          bad.addAll(rebalancePreviewResultViolations(d, r));
          final RebalancePreview? p = r.preview;
          if (p == null) {
            if (next != null) bad.add('$d — 다음 세션이 있는데 차단: ${r.blockedText}');
            return;
          }
          bad.addAll(
            rebalancePreviewViolations(
              d,
              p,
              asOf: AsOf(
                observedAt: s.observedAt,
                tradeDate: s.asOfTradeDate,
                source: s.source,
                staleAfter: cfg.asOfStaleAfter,
                label: '초안 기준 $d 종가',
              ),
              pensionAliases: const <String>{'연금저축'},
              allAliases: const <String>{'연금저축', '일반'},
            ),
          );
          // 초안 = 계획 매매의 정수 주(지정가 = 종가 원 단위 반올림).
          final List<(String, bool, int)> want = <(String, bool, int)>[
            for (final MonthEndAction a in planMonthEnd(
              me,
              cfg.monthEnd,
            ).actions)
              if (a.symbol != null && a.isBuy != null)
                if ((a.amount / s.prices[a.symbol]!.round()).floor().toInt()
                    case final int q when q > 0)
                  (a.symbol!, a.isBuy!, q),
          ];
          final List<(String, bool, int)> got = <(String, bool, int)>[
            for (final OrderDraft o in p.orderDrafts)
              (o.symbol, o.side == OrderSide.buy, o.quantity),
          ];
          if (got.toString() != want.toString()) {
            bad.add('$d — 초안 $got ↔ 계획 $want');
          }
          for (final OrderDraft o in p.orderDrafts) {
            for (final ReasonChip c in o.reasons) {
              if (!ContractCodes.isRegistered(c.code)) {
                bad.add('$d — 사전 밖 사유 코드 ${c.code}');
              }
              codes[c.code] = (codes[c.code] ?? 0) + 1;
            }
          }
          if (p.orderDrafts.isEmpty) empty++;
          if (p.warningLines.any((String l) => l.contains('납입이 함께 필요합니다'))) {
            contributionLines++;
          }
          for (final List<SleeveWeight> ws in <List<SleeveWeight>>[
            p.before,
            p.after,
          ]) {
            final double sum = ws.fold(
              0.0,
              (double a, SleeveWeight w) => a + w.weight,
            );
            if (ws.length != 3 || (sum - 1.0).abs() > 1e-9) {
              bad.add('$d — 비중 ${ws.length}줄 합 $sum');
            }
            if (ws.any(
              (SleeveWeight w) =>
                  w.basis != AllocationBasis.accounting ||
                  !w.label.contains('%'),
            )) {
              bad.add('$d — 비중 줄 basis·라벨');
            }
          }
          if (RebalancePreviewResult.fromJson(r.toJson()) != r) {
            bad.add('$d — JSON 왕복');
          }
        };
        e.run();
        expect(months, greaterThan(300));
        expect(
          bad,
          isEmpty,
          reason: '${bad.length}건 — 처음 5: ${bad.take(5).join('\n')}',
        );
        // 갈래 표본 — 빈 초안 · 납입 경고 줄 · 사유 코드 4종(B 신호 · 코어 밴드 · C · POT).
        expect(empty, greaterThan(0));
        expect(contributionLines, greaterThan(0));
        expect(
          codes.keys.toSet(),
          containsAll(RebalanceReasonCodes.values),
          reason: '$codes',
        );
        if (v == ReplayVariant.nogate) {
          expect(
            codes[LedgerEventCodes.pensionFunding],
            greaterThan(0),
            reason: 'nogate 는 원화 조달 2건',
          );
        }
      },
    );
  }
}
