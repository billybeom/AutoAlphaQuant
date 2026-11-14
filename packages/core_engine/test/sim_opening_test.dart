// 🆕 E15d1 — 모의 개시 나눔 · 시딩 목록 · 체험 시작 문(설계 13 §8 R85 AA3 · AA4 · SPEC v2.44 02 §2-7 ⓐ).

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

const Map<String, String> _twoAccounts = <String, String>{
  P0sStrategyIds.sleeveA: 'general',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'general',
};

SimOpeningSplit _split(
  String cash, {
  Map<String, String> accounts = _twoAccounts,
  Map<SleeveId, Decimal>? weights,
}) => simOpeningSplit(
  cashKrw: Decimal.parse(cash),
  weights: weights ?? WhatIfConfig.defaults.targetWeights,
  accountByStrategy: accounts,
);

void main() {
  group('🆕 E15d1 가상 초기금 나눔(R85 AA3)', () {
    test('P0S 목표 비중(A 0.20 · B 0.42 · C 0.38)을 계좌별로 모은다', () {
      final SimOpeningSplit s = _split('10000000');
      expect(s.reject, isNull);
      expect(s.byAccount, <String, int>{
        'general': 5800000,
        'pension': 4200000,
      });
    });

    test('세 계좌면 세 줄', () {
      final SimOpeningSplit s = _split(
        '10000000',
        accounts: const <String, String>{
          P0sStrategyIds.sleeveA: 'isa',
          P0sStrategyIds.sleeveB: 'pension',
          P0sStrategyIds.sleeveC: 'general',
        },
      );
      expect(s.byAccount, <String, int>{
        'general': 3800000,
        'isa': 2000000,
        'pension': 4200000,
      });
    });

    test('🔴 원 단위 내림 · 나머지 원 = 비중이 가장 큰 계좌 · 합 = 선언 금액', () {
      final SimOpeningSplit s = _split('1000001');
      expect(s.byAccount, <String, int>{'general': 580001, 'pension': 420000});
      for (final String cash in <String>[
        '1',
        '7',
        '99',
        '1000003',
        '12345679',
        '987654321',
      ]) {
        final SimOpeningSplit r = _split(cash);
        expect(r.reject, isNull, reason: cash);
        expect(
          r.byAccount.values.fold(0, (int a, int b) => a + b),
          int.parse(cash),
          reason: cash,
        );
      }
    });

    test('비중 동률이면 별칭 순으로 첫 계좌가 나머지를 받는다', () {
      final SimOpeningSplit s = _split(
        '3',
        accounts: const <String, String>{
          P0sStrategyIds.sleeveA: 'y',
          P0sStrategyIds.sleeveB: 'x',
        },
        weights: <SleeveId, Decimal>{
          SleeveId.a: Decimal.parse('0.5'),
          SleeveId.b: Decimal.parse('0.5'),
        },
      );
      expect(s.byAccount, <String, int>{'x': 2, 'y': 1});
    });

    test('금액이 0 인 계좌 줄은 만들지 않는다', () {
      final SimOpeningSplit s = _split('1');
      expect(s.byAccount, <String, int>{'general': 1});
    });

    test('🔴 0 · 음수 = 거부 · 원 미만 = 거부', () {
      expect(_split('0').reject, SimOpeningCodes.notPositive);
      expect(_split('-5').reject, SimOpeningCodes.notPositive);
      expect(_split('100.5').reject, SimOpeningCodes.notWholeWon);
      expect(_split('100.5').byAccount, isEmpty);
    });

    test('🔴 비중이 있는 전략의 계좌가 없으면 거부(나누지 않는다)', () {
      final SimOpeningSplit s = _split(
        '10000000',
        accounts: const <String, String>{
          P0sStrategyIds.sleeveA: 'general',
          P0sStrategyIds.sleeveB: 'pension',
        },
      );
      expect(s.reject, SimOpeningCodes.accountUnmapped);
      expect(s.byAccount, isEmpty);
    });

    test('비중 0 슬리브는 계좌가 없어도 된다 · 슬리브 밖 비중은 거부', () {
      expect(
        _split(
          '100',
          accounts: const <String, String>{P0sStrategyIds.sleeveB: 'p'},
          weights: <SleeveId, Decimal>{
            SleeveId.a: Decimal.zero,
            SleeveId.b: Decimal.one,
          },
        ).byAccount,
        <String, int>{'p': 100},
      );
      expect(
        _split(
          '100',
          weights: <SleeveId, Decimal>{SleeveId.satellite: Decimal.one},
        ).reject,
        SimOpeningCodes.accountUnmapped,
      );
      expect(
        _split('100', weights: <SleeveId, Decimal>{}).reject,
        SimOpeningCodes.accountUnmapped,
      );
    });
  });

  group('🆕 E15d1 시딩 · 결정 id · 체험 시작 문(R85 AA4)', () {
    test('시딩 전략 = A · B · C · POT(입금 P0S 는 전략이 아니다)', () {
      expect(kP0sSeedStrategies, <String>[
        'P0S_A',
        'P0S_B',
        'P0S_C',
        'P0S_POT',
      ]);
      expect(kSeedStrategyState, 'ACTIVE');
      expect(kSeedCapitalCap, 1.0);
    });

    test('슬리브 → 전략', () {
      expect(p0sStrategyOfSleeve(SleeveId.a), P0sStrategyIds.sleeveA);
      expect(p0sStrategyOfSleeve(SleeveId.b), P0sStrategyIds.sleeveB);
      expect(p0sStrategyOfSleeve(SleeveId.c), P0sStrategyIds.sleeveC);
      expect(p0sStrategyOfSleeve(SleeveId.pot), isNull);
      expect(p0sStrategyOfSleeve(SleeveId.cash), isNull);
      expect(p0sStrategyOfSleeve(SleeveId.satellite), isNull);
    });

    test('개시 결정 id', () {
      expect(
        simOpeningDecisionId(const TradeDate('2026-12-21')),
        'SIMOPEN-2026-12-21',
      );
    });

    test('🔴 계층 B 카드가 없으면 체험 시작 거부 · 있으면 통과', () {
      expect(simTrialStartReject(card: null), SimOpeningCodes.tierBCardMissing);
      expect(p0sTierBCard(), isNull);
      expect(
        simTrialStartReject(
          card: const TierBCard(
            b1R12mFloor: -0.15,
            b2DdFloor: -0.34,
            b3TuwMonths: 31,
          ),
        ),
        isNull,
      );
    });
  });
}
