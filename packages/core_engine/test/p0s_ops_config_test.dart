// E11p3b-1 — 설정 지문 · P0S 운영 설정 원천(설계 13 §8 R90).

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

/// 시험용 사람 값 — 🔴 실제 값이 아니다(체크리스트 P0-① · P0-② 는 발주자 몫).
P0sHumanInputs _human({String a = '999990', String? accountC}) =>
    P0sHumanInputs(
      aSymbol: a,
      accountByStrategy: <String, String>{
        P0sStrategyIds.sleeveA: 'acct_x',
        P0sStrategyIds.sleeveB: 'acct_pension',
        P0sStrategyIds.sleeveC: accountC ?? 'acct_general',
        P0sStrategyIds.pot: 'acct_x',
      },
    );

void main() {
  group('설정 지문', () {
    test('정규 JSON = 키 ASCII 순 · 공백 없음 · 잎 꼴 그대로', () {
      expect(
        canonicalConfigJson(<String, Object?>{
          'b': <Object?>[1, true, null],
          'a': 0.5,
          'c': Decimal.parse('0.42'),
          'd': 'x"y',
        }),
        '{"a":0.5,"b":[1,true,null],"c":"0.42","d":"x\\"y"}',
      );
    });

    test('🔴 키 차례가 달라도 지문은 같다 · 16자 hex', () {
      final String a = configFingerprint(<String, Object?>{'x': 1, 'y': 2});
      final String b = configFingerprint(<String, Object?>{'y': 2, 'x': 1});
      expect(a, b);
      expect(a, matches(RegExp(r'^[0-9a-f]{16}$')));
      expect(configFingerprint(<String, Object?>{'x': 1, 'y': 3}), isNot(a));
    });

    test('🔴 쓸 수 없는 꼴 · 문자열 아닌 키 = ArgumentError(지어내지 않는다)', () {
      expect(
        () => configFingerprint(<String, Object?>{'t': DateTime.utc(2026)}),
        throwsArgumentError,
      );
      expect(
        () => configFingerprint(<Object?, Object?>{1: 'x'}),
        throwsArgumentError,
      );
    });
  });

  group('P0S 운영 설정', () {
    test('🔴 한도 = 04 §1 SAF 표 그대로', () {
      final LimitConfig l = p0sLimitConfig();
      expect(l.maxNotionalPct, 0.05); // SAF-101
      expect(l.riskBudgetPct, 0.0035); // SAF-102
      expect(l.satelliteMaxPositions, 8); // SAF-203
      expect(l.satelliteMaxPerSector, 3); // SAF-206
      expect(l.maxRiskExposure, 0.85); // SAF-301
      expect(l.maxLeverage, 1.0); // SAF-303
      expect(l.maxPositions, 30); // SAF-304
      expect(l.maxOrdersPerDay, 60); // SAF-401
      expect(l.maxOrderValueKrw, Decimal.fromInt(20000000)); // SAF-402
      expect(l.maxDailyLossPct, 0.03); // SAF-403(양수)
      expect(l.orderTypeWhitelist, <String>{'LIMIT', 'MARKET'}); // SAF-404
    });

    test('비용 · 지정가 여유 = 02 §4 · 03 §5-3 값', () {
      expect(kP0sFillCostRates.commissionRate, 0.00015);
      expect(kP0sFillCostRates.sellTaxRate, 0);
      expect(kP0sLimitOffsetPct, 0.005);
      expect(kP0sBuyCostRate, 0.00115);
      final P0sOpsConfig c = P0sOpsConfig.of(_human());
      expect(c.draft.limitOffsetPct, kP0sLimitOffsetPct);
      expect(c.draft.buyCostRate, c.buyCostRate);
    });

    test('🔴 상품 구분 = 계획 종목 + 슬리브 A 전부 ETF(빠지면 L1 이 ETF 매수를 막는다)', () {
      final P0sOpsConfig c = P0sOpsConfig.of(_human());
      expect(c.krSymbols, containsAll(p0sKrPlanSymbols()));
      expect(c.krSymbols, contains('999990'));
      expect(c.instruments.keys.toSet(), c.krSymbols.toSet());
      expect(c.instruments.values.toSet(), <InstrumentKind>{
        InstrumentKind.etf,
      });
    });

    test('연금 계좌 = 슬리브 B 의 계좌 · 초안 계좌 대응 = 사람 값 그대로', () {
      final P0sOpsConfig c = P0sOpsConfig.of(_human());
      expect(c.pensionAlias, 'acct_pension');
      expect(c.draft.accountByStrategy, c.human.accountByStrategy);
    });

    test('🔴 사람 값 검사 — 종목 꼴 · 전략 넷 정확히 · 빈 별칭', () {
      expect(() => _human(a: '12345'), throwsArgumentError);
      expect(() => _human(a: 'abcdef'), throwsArgumentError);
      expect(() => _human(accountC: ' '), throwsArgumentError);
      expect(
        () => P0sHumanInputs(
          aSymbol: '999990',
          accountByStrategy: <String, String>{
            P0sStrategyIds.sleeveA: 'a',
            P0sStrategyIds.sleeveB: 'b',
            P0sStrategyIds.sleeveC: 'c',
          },
        ),
        throwsArgumentError,
      );
      expect(
        () => P0sHumanInputs(
          aSymbol: '999990',
          accountByStrategy: <String, String>{
            P0sStrategyIds.sleeveA: 'a',
            P0sStrategyIds.sleeveB: 'b',
            P0sStrategyIds.sleeveC: 'c',
            P0sStrategyIds.pot: 'a',
            P0sStrategyIds.deposit: 'd',
          },
        ),
        throwsArgumentError,
      );
      // 넷이지만 POT 대신 입금 — 개수만 보면 통과한다.
      expect(
        () => P0sHumanInputs(
          aSymbol: '999990',
          accountByStrategy: <String, String>{
            P0sStrategyIds.sleeveA: 'a',
            P0sStrategyIds.sleeveB: 'b',
            P0sStrategyIds.sleeveC: 'c',
            P0sStrategyIds.deposit: 'd',
          },
        ),
        throwsArgumentError,
      );
    });

    test('🔴 지문은 사람 값 · 한도에 따라 바뀌고, 같은 입력이면 같다', () {
      final String h = P0sOpsConfig.of(_human()).configHash;
      expect(P0sOpsConfig.of(_human()).configHash, h);
      expect(P0sOpsConfig.of(_human(a: '999991')).configHash, isNot(h));
      expect(
        P0sOpsConfig.of(_human(accountC: 'acct_irp')).configHash,
        isNot(h),
      );
      expect(h, matches(RegExp(r'^[0-9a-f]{16}$')));
    });

    test('🔴 지문 고정값 — 내용이 바뀌면 이 시험이 먼저 울린다(SAF-405 승인 단위)', () {
      // 값이 바뀌는 것이 의도라면(SPEC 판 · 한도 · 기본판 변경) 새 값으로 고치고 R 행에 적는다.
      expect(P0sOpsConfig.of(_human()).configHash, 'bf17e643d78255fa');
      expect(P0sOpsConfig.of(_human()).regimeConfigHash, 'a334201eb65f9ee4');
    });

    test('국면 지문은 사람 값에 따라 바뀌지 않는다', () {
      expect(
        P0sOpsConfig.of(_human(a: '999991')).regimeConfigHash,
        P0sOpsConfig.of(_human()).regimeConfigHash,
      );
    });

    test('🔴 사람 값 리터럴 0 — 원천 파일에 종목 · 계좌 리터럴이 없다', () {
      final String src = File('lib/src/ops/p0s_ops_config.dart')
          .readAsStringSync();
      // 슬리브 A 시험값(229200 · R49) · 계좌 역할 이름이 기본값으로 박히지 않았는지.
      for (final String lit in <String>[
        '229200',
        "'ISA'",
        "'IRP'",
        'pension\'',
      ]) {
        expect(src.contains(lit), false, reason: lit);
      }
      expect(RegExp(r"aSymbol\s*=\s*'").hasMatch(src), false);
    });
  });
}
