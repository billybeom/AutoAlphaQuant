// C-31 (01 §7 · §2-1 · §2-5 · P 회차) — 비중 기준 축.
//
// ⓑ(「`ui_*` 에서 A 와 POT 를 더하는 산술」)는 `ui_*` 소스 스캔이 선행한다
// (인벤토리 §9 C-31 = 🟡).
//
// 🔴 같은 «비중»에 기준이 둘이라 섞으면 슬리브 A 가 **8.1% 로도 20.2% 로도** 보인다.
//    - `engineColumn` = 엔진 원장 열(POT 잔액이 C 에 합산됨)
//    - `accounting`  = 회계 소속(POT → A · 03 §2-9-3)
//    목표 배분·밴드 판정과 비교할 수 있는 것은 `accounting` **하나뿐**이다.
// 🔴 그래서 계약 면의 검사는 「한 목록 안에서 기준이 섞이지 않는가」다 — 섞이면
//    화면은 그것을 알아볼 방법이 없다(둘 다 그냥 «비중» 이다).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_io_t2.dart';

void main() {
  group('C-31 P 비중 기준 축 (01 §7 · §2-5)', () {
    test('C-31 ① AllocationBasis 는 2값이고 표기가 고정이다', () {
      expect(
        AllocationBasis.values.map((AllocationBasis b) => b.wire).toList(),
        <String>['ENGINE_COLUMN', 'ACCOUNTING'],
      );
    });

    test('C-31 ⓐ 한 목록 안에서 basis 가 섞이지 않는다 — 배분 현황', () {
      final List<SleeveAllocationRow> rows = fixtureRows(
        FixturePaths.m7RealizedAllocS7,
      ).map(SleeveAllocationRow.fromJson).toList();

      expect(rows, isNotEmpty);
      final Set<AllocationBasis> bases = rows
          .map((SleeveAllocationRow r) => r.basis)
          .toSet();
      expect(bases, <AllocationBasis>{
        AllocationBasis.accounting,
      }, reason: '목표·밴드와 비교할 수 있는 기준은 accounting 하나뿐이다.');
    });

    test('C-31 ⓐ 한 목록 안에서 basis 가 섞이지 않는다 — 슬리브 비중', () {
      // 🔴 `basis` 는 M2-2 배치 전까지 nullable 이며 null = 미표기다(§2-5) —
      //    섞이는 것이 금지이지 «null 이면 실패» 가 아니다.
      for (final Map<String, Object?> row in fixtureRows(
        FixturePaths.rebalance6,
      )) {
        final RebalanceEvent event = RebalanceEvent.fromJson(row);
        for (final List<SleeveWeight> list in <List<SleeveWeight>>[
          event.before,
          event.after,
        ]) {
          final Set<AllocationBasis?> bases = list
              .map((SleeveWeight w) => w.basis)
              .toSet();
          expect(
            bases.length,
            1,
            reason: '${event.eventId} — 한 목록에 서로 다른 basis 가 섞였다: $bases',
          );
          for (final AllocationBasis? basis in bases) {
            expect(
              basis,
              anyOf(isNull, AllocationBasis.accounting),
              reason:
                  '${event.eventId} — SleeveWeight.basis 는 accounting 외 값을 갖지 않는다.',
            );
          }
        }
      }
    });

    test('C-31 ⓑ POT 는 A 의 하위 행으로 오고 A 에 미리 합산되지 않는다', () {
      // 🔴 화면이 A 와 POT 를 더하는 산술을 하지 않아도 되도록 «회계 소속»은
      //    `parentSleeve` 로 온다 — 더하기는 엔진이 이미 끝냈거나 하지 않은 것이다.
      final List<SleeveAllocationRow> rows = fixtureRows(
        FixturePaths.m7RealizedAllocS7,
      ).map(SleeveAllocationRow.fromJson).toList();

      final SleeveAllocationRow pot = rows.firstWhere(
        (SleeveAllocationRow r) => r.sleeve == SleeveId.pot,
      );
      expect(pot.parentSleeve, SleeveId.a);
      expect(
        pot.engineColumnNote,
        isNotNull,
        reason: '엔진 원장 열 값의 유일한 출구는 이 문자열이다 — 비교·합산하지 않는다.',
      );

      // A 행은 자기 행으로 따로 온다(합산본이 아니다).
      expect(
        rows.where((SleeveAllocationRow r) => r.sleeve == SleeveId.a).length,
        1,
      );
    });

    test('C-31 ⓒ 여집합을 화면이 계산하지 않도록 두 비율을 모두 준다', () {
      for (final SleeveAllocationRow row in fixtureRows(
        FixturePaths.m7RealizedAllocS7,
      ).map(SleeveAllocationRow.fromJson)) {
        // 🔴 `1 − deployedRatio` 를 화면이 만들지 않게 하는 것이 이 두 필드의 이유다
        //    (C-4 확장이 잡지 못한 double 산술의 자리).
        expect(row.deployedPctText, isNotEmpty, reason: row.sleeve.wire);
        expect(row.parkingPctText, isNotEmpty, reason: row.sleeve.wire);
        expect(row.trancheStateText, isNotEmpty, reason: row.sleeve.wire);
      }
    });

    test(
      'C-31 ⓓ (R12 밖) ui_* 에서 A 와 POT 값을 더하는 산술 탐지 — R12 화면 = C-42 ⑧',
      () {},
      skip: 'ui_* 소스 정적 스캔이 필요하다 — 패키지 선행(인벤토리 §9 C-31 = 🟡).',
    );
  });
}
