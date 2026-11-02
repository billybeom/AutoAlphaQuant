// decision_id v2.38 형식 · 집행일 접미 · 순매매 결합(04 §3-2 v2.38 · 설계 13 §8 R33 D2 · R34 U2 · U6).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const TradeDate _td = TradeDate('2026-10-30');

void main() {
  test('P0S 형식 7종 — 04 §3-2 v2.38 표 그대로', () {
    expect(DecisionIds.deposit('pl_20260901_01'), 'DEP-pl_20260901_01');
    expect(DecisionIds.pensionFunding(_td), 'FUND-2026-10-30');
    expect(DecisionIds.seasonalAEntry(_td), 'SEAS-A-IN-2026-10-30');
    expect(DecisionIds.seasonalAExit(_td), 'SEAS-A-OUT-2026-10-30');
    expect(DecisionIds.potSma(_td), 'POT-SMA-2026-10-30');
    expect(DecisionIds.potLiquidation(_td), 'POT-LIQ-2026-10-30');
    expect(DecisionIds.sleeveCRebalance(_td), 'C-REBAL-2026-10-30');
    // 슬리브 B 조달 매도 = 기존 BAND 형식(새 형식 없음).
    expect(DecisionIds.band('B', _td), 'BAND-B-2026-10-30');
  });

  test('입금 결정 id 는 한 곳(DecisionIds.deposit)에서 온다', () {
    expect(depositDecisionId('pl_1'), DecisionIds.deposit('pl_1'));
    expect(() => DecisionIds.deposit('pl 1'), throwsArgumentError);
    expect(() => DecisionIds.deposit(''), throwsArgumentError);
  });

  group('집행일 접미', () {
    test('{논리 id}@{집행일} — 분할 날마다 다른 멱등키 · 같은 날 재실행은 같은 키', () {
      final String logical = DecisionIds.seasonalAEntry(_td);
      final String d1 = DecisionIds.forExecution(
        logical,
        const TradeDate('2026-10-28'),
      );
      final String d2 = DecisionIds.forExecution(
        logical,
        const TradeDate('2026-10-29'),
      );
      expect(d1, 'SEAS-A-IN-2026-10-30@2026-10-28');
      String key(String id) => idempotencyKey(
        market: 'KR',
        account: 'isa',
        symbol: '229200',
        side: 'BUY',
        decisionId: id,
      );
      expect(key(d1), isNot(key(d2)));
      expect(
        key(DecisionIds.forExecution(logical, const TradeDate('2026-10-28'))),
        key(d1),
      );
    });

    test('접미는 두 번 붙지 않는다 · 날짜 꼴이 아니면 거절', () {
      final String once = DecisionIds.forExecution(
        'B-SMA-2026-10-30',
        const TradeDate('2026-11-02'),
      );
      expect(
        () => DecisionIds.forExecution(once, const TradeDate('2026-11-03')),
        throwsArgumentError,
      );
      expect(
        () => DecisionIds.forExecution('B-SMA-x', const TradeDate('20261102')),
        throwsArgumentError,
      );
      expect(
        () => DecisionIds.forExecution('B SMA', const TradeDate('2026-11-02')),
        throwsArgumentError,
      );
    });
  });

  group('순매매 결합', () {
    test('정렬 · 중복 제거 뒤 + 로 잇는다 — 순서와 무관', () {
      expect(
        DecisionIds.combined(<String>['BAND-B-2026-10-30', 'B-SMA-2026-10-30']),
        'B-SMA-2026-10-30+BAND-B-2026-10-30',
      );
      expect(
        DecisionIds.combined(<String>[
          'B-SMA-2026-10-30',
          'BAND-B-2026-10-30',
          'B-SMA-2026-10-30',
        ]),
        'B-SMA-2026-10-30+BAND-B-2026-10-30',
      );
      expect(
        DecisionIds.combined(<String>['FUND-2026-10-30']),
        'FUND-2026-10-30',
      );
    });

    test('결합 id 에도 접미가 붙는다', () {
      expect(
        DecisionIds.forExecution(
          DecisionIds.combined(<String>['X-1', 'A-1']),
          const TradeDate('2026-11-02'),
        ),
        'A-1+X-1@2026-11-02',
      );
    });

    test('빈 목록 · 이미 접미나 + 가 있는 id 는 거절', () {
      expect(() => DecisionIds.combined(<String>[]), throwsArgumentError);
      expect(
        () => DecisionIds.combined(<String>['A-1@2026-11-02']),
        throwsArgumentError,
      );
      expect(
        () => DecisionIds.combined(<String>['A-1+B-1']),
        throwsArgumentError,
      );
    });
  });
}
