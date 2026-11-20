// 🆕 E3d-4 — 월 잡 SAF-307 · 원화 유동성 월 집계(04 §1 Level 3 v2.46 · 앱 01 §36 K193).

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

/// 해외 기초자산 ETF(133690) [qty] 주 × 100원 + 원화 현금 [cash].
P0sWarnInputs _day(int qty, String cash, {String close = '100'}) =>
    P0sWarnInputs(
      holdings: <LedgerHolding>[LedgerHolding('P0S_B', '133690', qty)],
      closes: <String, Decimal>{'133690': _d(close)},
      cashKrw: _d(cash),
    );

P0sTallyDay _x(String date, P0sWarnInputs? inputs, [String? reason]) =>
    (date: date, inputs: inputs, reason: reason);

void main() {
  final P0sWarnSetup setup = P0sWarnSetup();

  group('셈', () {
    test('🔴 경계 = 일간 판정 그대로(307 엄격 > 0.50 · 원화 유동성 엄격 < 0.01)', () {
      final P0sExposureTally t = p0sMonthlyExposureTally(
        month: '2026-07',
        days: <P0sTallyDay>[
          _x('2026-07-01', _day(6, '400')), // 달러 0.60 넘음 · 원화 0.40
          _x('2026-07-02', _day(5, '500')), // 달러 0.50 = 통과
          _x('2026-07-03', _day(99, '99')), // 달러 0.99 넘음 · 원화 99/9999 밑
          _x('2026-07-06', _day(99, '100')), // 달러 0.99 넘음 · 원화 0.01 = 통과
        ],
        setup: setup,
      );
      expect(t.month, '2026-07');
      expect(t.tradingDays, 4);
      expect(t.usdOverDays, 3);
      expect(t.krwLowDays, 1);
      expect(t.unmeasured, isEmpty);
      expect(t.unmeasuredDays, 0);
    });

    test('계측 없는 날 = 까닭 기록 · 넘은 날로 세지 않는다', () {
      final P0sExposureTally t = p0sMonthlyExposureTally(
        month: '2026-07',
        days: <P0sTallyDay>[
          _x('2026-07-01', null, '평가 행 없음'),
          _x('2026-07-02', null),
          _x('2026-07-03', _day(99, '1', close: '0')), // 종가 0 = 셈 실패
          _x('2026-07-06', _day(99, '1')), // 달러 넘음 · 원화 밑
        ],
        setup: setup,
      );
      expect(t.tradingDays, 4);
      expect(t.usdOverDays, 1);
      expect(t.krwLowDays, 1);
      expect(t.unmeasuredDays, 3);
      expect(t.unmeasured[0], ('2026-07-01', '평가 행 없음'));
      expect(t.unmeasured[1], ('2026-07-02', '계측 없음'));
      expect(t.unmeasured[2].$1, '2026-07-03');
      expect(t.unmeasured[2].$2, contains('종가 없음'));
      expect(t.line, '307 초과 1/4일 · 원화 유동성 밑 1일 · 계측 없음 3일');
    });

    test('문턱 = 설정 값(기준선을 올리면 덜 센다)', () {
      final P0sExposureTally t = p0sMonthlyExposureTally(
        month: '2026-07',
        days: <P0sTallyDay>[_x('2026-07-01', _day(6, '400'))],
        setup: P0sWarnSetup(
          config: const P0sWarnConfig(
            minDefensivePct: 0.10,
            goldTotalMonitorPct: 0.20,
            usdBaselinePct: 0.70,
            krwLiquidityFloorPct: 0.50,
          ),
        ),
      );
      expect(t.usdOverDays, 0);
      expect(t.krwLowDays, 1);
    });

    test('빈 달 = 0', () {
      final P0sExposureTally t = p0sMonthlyExposureTally(
        month: '2026-12',
        days: const <P0sTallyDay>[],
        setup: setup,
      );
      expect(t.tradingDays, 0);
      expect(t.line, '307 초과 0/0일 · 원화 유동성 밑 0일 · 계측 없음 0일');
    });
  });

  group('입력 가드', () {
    test('달 꼴', () {
      for (final String m in <String>['2026-7', '2026-13', '202607', '']) {
        expect(
          () => p0sMonthlyExposureTally(
            month: m,
            days: const <P0sTallyDay>[],
            setup: setup,
          ),
          throwsArgumentError,
          reason: m,
        );
      }
    });

    test('달 밖의 날 · 날짜 순 아님 · 겹침 = 오류', () {
      for (final List<String> ds in <List<String>>[
        <String>['2026-06-30'],
        <String>['2026-07-02', '2026-07-01'],
        <String>['2026-07-02', '2026-07-02'],
        <String>['2026-07-1'],
      ]) {
        expect(
          () => p0sMonthlyExposureTally(
            month: '2026-07',
            days: <P0sTallyDay>[for (final String d in ds) _x(d, null)],
            setup: setup,
          ),
          throwsArgumentError,
          reason: ds.join(','),
        );
      }
    });
  });
}
