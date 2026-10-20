// 코어 밴드 · 납입 규약 중 정답지가 직접 보지 않는 것 — 03 §5-2 v2.21 두 다리 분리 · v2.32 조달 필요액 ·
// P0S B 목표 0.42 · 입력 거부 · 동률 순서.

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Decimal _d(String s) => Decimal.parse(s);

CoreBandMove _band({
  String b = '100',
  String eq = '1000',
  double target = 0.42,
  double band = 0.03,
  String cash = '1000',
  String reserved = '0',
  String park = '0',
  String quota = '1000',
  String used = '0',
}) => coreBandMove(
  bValue: _d(b),
  totalEquity: _d(eq),
  targetWeight: target,
  band: band,
  krwCash: _d(cash),
  reservedKrw: _d(reserved),
  reclassifiedPark: _d(park),
  annualQuota: _d(quota),
  pensionUsedThisYear: _d(used),
);

void main() {
  group('코어 밴드 — P0S B 목표 0.42 ± 0.03', () {
    test('정확히 0.45 · 0.39 는 밴드 안(strict)', () {
      expect(_band(b: '450').direction, CoreBandDirection.none);
      expect(_band(b: '390').direction, CoreBandDirection.none);
    });
    test('0.4501 초과 → 목표까지 전액 B→C 재분류(납입 0)', () {
      final CoreBandMove r = _band(b: '450.1');
      expect(r.direction, CoreBandDirection.bToC);
      expect(r.reclassified, _d('30.1'));
      expect(r.contribution, Decimal.zero);
      expect(r.prefundNeeded, Decimal.zero);
    });
    test('미달 — 환원 먼저(한도 무관) · 나머지만 납입(한도 안)', () {
      final CoreBandMove r = _band(
        b: '300',
        park: '50',
        quota: '30',
        used: '10',
      );
      // 목표 420 − 300 = 120 → 환원 50 → 남은 70 중 한도 잔여 20 만 납입.
      expect(r.direction, CoreBandDirection.cToB);
      expect(r.reclassified, _d('50'));
      expect(r.contribution, _d('20'));
      expect(r.total, _d('70'));
      expect(r.prefundNeeded, Decimal.zero);
    });
    test('환원한 몫은 납입 필요액에서 빠진다(한도가 남아도 두 번 채우지 않는다)', () {
      final CoreBandMove r = _band(b: '300', park: '100', quota: '50');
      // 필요 120 → 환원 100 → 납입은 남은 20 만(한도 잔여 50 이 있어도).
      expect(r.reclassified, _d('100'));
      expect(r.contribution, _d('20'));
      expect(r.total, _d('120'));
    });
    test('v2.32 — 원화가 한도 안 필요액에 못 미치면 그 차이를 조달 필요액으로', () {
      final CoreBandMove r = _band(b: '300', cash: '50', reserved: '20');
      // 필요 120 · 쓸 수 있는 원화 50 − 20 = 30 → 납입 30 · 먼저 마련할 몫 90.
      expect(r.contribution, _d('30'));
      expect(r.prefundNeeded, _d('90'));
    });
    test('조달 필요액도 연 한도 안에서만', () {
      final CoreBandMove r = _band(
        b: '300',
        cash: '10',
        quota: '40',
        used: '0',
      );
      expect(r.contribution, _d('10'));
      expect(r.prefundNeeded, _d('30'));
    });
    test('한도 소진 — 조달 필요액 0(한도 밖 원화를 마련하지 않는다)', () {
      final CoreBandMove r = _band(
        b: '300',
        cash: '0',
        quota: '18',
        used: '18',
      );
      expect(r.contribution, Decimal.zero);
      expect(r.prefundNeeded, Decimal.zero);
    });
    test('재진입 재원이 원화보다 크면 쓸 수 있는 원화 0(음수가 아니다)', () {
      final CoreBandMove r = _band(b: '300', cash: '10', reserved: '50');
      expect(r.contribution, Decimal.zero);
      expect(r.prefundNeeded, _d('120'));
    });
    test('한도 초과 사용 기록(used > quota)이어도 잔여 한도는 0', () {
      final CoreBandMove r = _band(b: '300', quota: '18', used: '20');
      expect(r.contribution, Decimal.zero);
      expect(r.prefundNeeded, Decimal.zero);
    });
    test('입력 거부 — 총자산 0 이하 · 음수 금액 · 비율 범위 밖', () {
      expect(() => _band(eq: '0'), throwsArgumentError);
      for (final CoreBandMove Function() f in <CoreBandMove Function()>[
        () => _band(b: '-1'),
        () => _band(cash: '-1'),
        () => _band(reserved: '-1'),
        () => _band(park: '-1'),
        () => _band(quota: '-1'),
        () => _band(used: '-1'),
        () => _band(target: -0.1),
        () => _band(target: 1.1),
        () => _band(band: -0.01),
      ]) {
        expect(f, throwsArgumentError);
      }
      // NaN 은 이 함수가 이름을 달아 거부한다(Decimal 승격에서 대신 터지지 않게).
      expect(
        () => _band(band: double.nan),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => e.name,
            'name',
            'band',
          ),
        ),
      );
    });
  });

  group('납입 배분', () {
    DepositAllocation run(
      Map<SleeveId, (String, String)> sleeves, {
      String amount = '100',
      String quota = '0',
    }) => allocateDeposit(
      amount: _d(amount),
      currents: <SleeveId, Decimal>{
        for (final MapEntry<SleeveId, (String, String)> e in sleeves.entries)
          e.key: _d(e.value.$1),
      },
      targets: <SleeveId, Decimal>{
        for (final MapEntry<SleeveId, (String, String)> e in sleeves.entries)
          e.key: _d(e.value.$2),
      },
      remainingPensionQuota: _d(quota),
    );
    test('P0S 꼴 — A · B · C 중 부족분 큰 순(B 한도 남으면 B 먼저)', () {
      final DepositAllocation r = run(
        <SleeveId, (String, String)>{
          SleeveId.a: ('10', '40'),
          SleeveId.b: ('30', '50'),
          SleeveId.c: ('20', '30'),
        },
        amount: '45',
        quota: '15',
      );
      expect(r.filled.map((DepositFill f) => f.sleeve), <SleeveId>[
        SleeveId.b,
        SleeveId.a,
      ]);
      expect(r.filled.map((DepositFill f) => f.amount), <Decimal>[
        _d('15'),
        _d('30'),
      ]);
      expect(r.residual, Decimal.zero);
    });
    test('부족분이 같으면 입력 순서대로', () {
      final DepositAllocation ac = run(<SleeveId, (String, String)>{
        SleeveId.a: ('0', '10'),
        SleeveId.c: ('0', '10'),
      }, amount: '15');
      expect(ac.filled.map((DepositFill f) => f.sleeve), <SleeveId>[
        SleeveId.a,
        SleeveId.c,
      ]);
      final DepositAllocation ca = run(<SleeveId, (String, String)>{
        SleeveId.c: ('0', '10'),
        SleeveId.a: ('0', '10'),
      }, amount: '15');
      expect(ca.filled.map((DepositFill f) => f.sleeve), <SleeveId>[
        SleeveId.c,
        SleeveId.a,
      ]);
    });
    test('부족분이 정확히 0 인 슬리브는 목록에 없다(남는 돈이 있어도)', () {
      final DepositAllocation r = run(<SleeveId, (String, String)>{
        SleeveId.a: ('10', '10'),
        SleeveId.c: ('0', '5'),
      }, amount: '20');
      expect(r.filled.map((DepositFill f) => f.sleeve), <SleeveId>[SleeveId.c]);
      expect(r.residual, _d('15'));
    });
    test('납입 0 이면 아무것도 채우지 않는다', () {
      final DepositAllocation r = run(<SleeveId, (String, String)>{
        SleeveId.c: ('0', '10'),
      }, amount: '0');
      expect(r.filled, isEmpty);
      expect(r.residual, Decimal.zero);
    });
    test('입력 거부 — 음수 납입 · 음수 한도 · 슬리브 집합이 다름', () {
      expect(
        () => run(<SleeveId, (String, String)>{
          SleeveId.c: ('0', '10'),
        }, amount: '-1'),
        throwsArgumentError,
      );
      expect(
        () => run(<SleeveId, (String, String)>{
          SleeveId.c: ('0', '10'),
        }, quota: '-1'),
        throwsArgumentError,
      );
      expect(
        () => allocateDeposit(
          amount: _d('1'),
          currents: <SleeveId, Decimal>{SleeveId.c: _d('1')},
          targets: <SleeveId, Decimal>{SleeveId.a: _d('1')},
          remainingPensionQuota: Decimal.zero,
        ),
        throwsArgumentError,
      );
      expect(
        () => allocateDeposit(
          amount: _d('1'),
          currents: <SleeveId, Decimal>{SleeveId.c: _d('1')},
          targets: <SleeveId, Decimal>{
            SleeveId.c: _d('1'),
            SleeveId.a: _d('1'),
          },
          remainingPensionQuota: Decimal.zero,
        ),
        throwsArgumentError,
      );
    });
  });
}
