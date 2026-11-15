// E16d1 — X5-3 정정 계획: 기본 선택 · 대상 · «delta 같음» · 방향별 원인 코드 · 행 꼴(설계 13 §8 R121 F3~F5).
//
// 🔵 잡는 것: ① FILL_LAG 후보 · 현금 축 = 아무것도 안 하기 · 그 밖 = 기본 없음 ② 정정 대상 = 해시 모집단 16표만
//    ③ 탐지 diff 가 재대사에 없으면 REPAIR_DELTA_CHANGED ④ 정본 정정 원인 = 쌍 목록 − 파생 · 파생 재생성 = 파생 ∪ 소급 3
//    ⑤ 행 꼴(CANON_CORRECT 결정 · 자기 대체 · 날 · 체인 · UTC).
import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

StoredLedgerDiff _diff({
  LedgerAxis axis = LedgerAxis.quantity,
  List<String> candidates = const <String>['MANUAL_ORDER', 'DB_ERROR'],
}) => StoredLedgerDiff(
  diffId: 'ld-1',
  pair: LedgerPair.canonBroker,
  axis: axis,
  authoredDate: const TradeDate('2026-11-14'),
  delta:
      '{"kind":"QTY","candidates":[${candidates.map((String c) => '"$c"').join(',')}]}',
  deltaLabel: '',
  severity: DiffSeverity.blocking,
  status: DiffStatus.open,
  detectedAtUtc: DateTime.utc(2026, 11, 14, 1),
  applicable: true,
);

LedgerRepairPlanRow _row({
  RepairDirection direction = RepairDirection.canonCorrect,
  String origin = 'MANUAL_ORDER',
  String? decision = 'dec-1',
  String? supersedes,
  String? from,
  String? chain,
  DateTime? at,
}) => LedgerRepairPlanRow(
  repairId: 'rp-1',
  diffId: 'ld-1',
  direction: direction,
  originCode: origin,
  evidenceHash: 'ev_123',
  appliedAtUtc: at ?? DateTime.utc(2026, 11, 15),
  decisionId: decision,
  supersedes: supersedes,
  recomputedFrom: from,
  chainHash: chain,
);

void main() {
  test('🔴 기본 선택 — FILL_LAG 후보 · 현금 축 = 아무것도 안 하기 · 그 밖 = 없음', () {
    expect(
      defaultRepairChoiceOf(
        _diff(candidates: <String>['FILL_LAG', 'DB_ERROR']),
      ),
      RepairChoice.doNothing,
    );
    expect(
      defaultRepairChoiceOf(
        _diff(axis: LedgerAxis.cash, candidates: <String>[]),
      ),
      RepairChoice.doNothing,
    );
    expect(defaultRepairChoiceOf(_diff()), isNull);
    expect(
      defaultRepairChoiceOf(
        _diff(
          axis: LedgerAxis.executionRow,
          candidates: <String>['DB_ERROR', 'BROKER_ERROR'],
        ),
      ),
      isNull,
    );
  });

  test('🔴 정정 대상 = 해시 모집단 16표만 · 재계산 산출물 거부', () {
    expect(kRepairableTables, hasLength(16));
    for (final String t in <String>[
      'executions',
      'cash_flow',
      'ledger_event',
    ]) {
      expect(repairTargetRejectCode(t), isNull, reason: t);
    }
    for (final String t in <String>[
      'positions',
      'equity_snapshot',
      'strategy_state',
      'ramp_state',
      'ledger_repair',
    ]) {
      expect(
        repairTargetRejectCode(t),
        RepairCodes.targetNotImmutable,
        reason: t,
      );
    }
  });

  test('🔴 delta 같음 — 탐지 diff id 가 재대사에 있으면 통과 · 없으면 REPAIR_DELTA_CHANGED', () {
    expect(
      repairDeltaRejectCode(
        detectedDiffId: 'ld-1',
        freshDiffIds: <String>['ld-0', 'ld-1'],
      ),
      isNull,
    );
    expect(
      repairDeltaRejectCode(
        detectedDiffId: 'ld-1',
        freshDiffIds: <String>['ld-2'],
      ),
      RepairCodes.deltaChanged,
    );
    expect(
      repairDeltaRejectCode(
        detectedDiffId: 'ld-1',
        freshDiffIds: const <String>[],
      ),
      RepairCodes.deltaChanged,
    );
  });

  test('🔴 방향별 원인 코드 — 정본 정정 = 쌍 목록 − 파생 · 파생 재생성 = 파생 ∪ 소급 3', () {
    final Set<String> canon = repairOriginCodesFor(
      RepairDirection.canonCorrect,
      LedgerPair.canonBroker,
    );
    expect(canon.contains(OriginCodes.manualOrder), isTrue);
    expect(canon.contains(OriginCodes.misrecordedFill), isTrue);
    expect(canon.intersection(OriginCodes.derived), isEmpty);
    expect(
      repairOriginCodesFor(
        RepairDirection.canonCorrect,
        LedgerPair.canonGithub,
      ),
      isEmpty,
      reason: '파생 쌍은 정본 정정이 없다',
    );
    final Set<String> resync = repairOriginCodesFor(
      RepairDirection.derivedResync,
      LedgerPair.canonBroker,
    );
    expect(resync, <String>{
      ...OriginCodes.derived,
      ...kResyncCanonOriginCodes,
    });
    expect(resync.contains(OriginCodes.manualOrder), isFalse);
    expect(repairOriginRejectCode(_row(), LedgerPair.canonBroker), isNull);
    expect(
      repairOriginRejectCode(_row(origin: 'PUSH_LAG'), LedgerPair.canonBroker),
      RepairCodes.originNotAllowed,
    );
    expect(
      repairOriginRejectCode(
        _row(
          direction: RepairDirection.derivedResync,
          origin: 'MISRECORDED_FILL',
          decision: null,
        ),
        LedgerPair.canonBroker,
      ),
      isNull,
    );
  });

  test('🔴 행 꼴 — 정본 정정 결정 필수 · 자기 대체 · 날 · 체인 · UTC', () {
    expect(() => _row(decision: null), throwsArgumentError);
    expect(() => _row(decision: ' '), throwsArgumentError);
    expect(
      _row(direction: RepairDirection.derivedResync, decision: null).decisionId,
      isNull,
    );
    expect(() => _row(supersedes: 'rp-1'), throwsArgumentError);
    expect(_row(supersedes: 'rp-0').supersedes, 'rp-0');
    expect(() => _row(from: '2026-11-1'), throwsArgumentError);
    expect(() => _row(chain: 'A' * 64), throwsArgumentError);
    expect(_row(chain: 'a' * 64, from: '2026-11-10').chainHash, 'a' * 64);
    expect(() => _row(at: DateTime(2026, 11, 15)), throwsArgumentError);
    expect(RepairDirection.values.map((RepairDirection d) => d.wire), <String>[
      'DERIVED_RESYNC',
      'CANON_CORRECT',
    ]);
    expect(
      RepairDirection.parse('CANON_CORRECT'),
      RepairDirection.canonCorrect,
    );
    expect(() => RepairDirection.parse('X'), throwsFormatException);
  });
}
