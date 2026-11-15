// E16d1 — 새 기준점(재스탬프) 계획(설계 13 §8 R121 F8 · SPEC v2.45 04 §3-1 ④).
//
// 🔵 잡는 것: ① 경계 X5 만(X1 · 깨끗함 = 거부) ② 결정 · 원인(기준점 셋 ∩ 경계 후보) ③ 합성 `li-` diff id 결정적
//    ④ 다시 셀 첫 날 = 첫 어긋난 날 · 옛 스탬프 = 그 날 이후 날 차례 · 근거 해시 = evidenceHashOf ⑤ 체인은 비운다.
import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

LedgerIntegrityVerdict _bad(LedgerIntegrityReason r) =>
    LedgerIntegrityVerdict.failed(
      r,
      firstBadDate: '2026-11-12',
      daysChecked: 3,
      checkedThrough: '2026-11-11',
    );

final LedgerBoundaryVerdict _x5 = ledgerBoundaryOf(
  dbOpened: true,
  integrity: _bad(LedgerIntegrityReason.dayHashMismatch),
);

String _h(int n) => n.toRadixString(16).padLeft(64, '0');

final List<StoredDayStamp> _stamps = <StoredDayStamp>[
  for (final int d in <int>[13, 10, 12, 11])
    StoredDayStamp(
      authoredDate: '2026-11-$d',
      dayHash: _h(100 + d),
      chainHash: _h(d),
      hashFormatVersion: 1,
    ),
];

void main() {
  test('🔴 경계 X5 만 — X1 · 깨끗함 = BASELINE_NOT_X5', () {
    expect(
      baselineRejectCode(_x5, decisionId: 'dec-1', originCode: 'CHAIN_BROKEN'),
      isNull,
    );
    expect(
      baselineRejectCode(
        ledgerBoundaryOf(
          dbOpened: true,
          integrity: _bad(LedgerIntegrityReason.chainBroken),
        ),
        decisionId: 'dec-1',
        originCode: 'CHAIN_BROKEN',
      ),
      BaselineCodes.notX5,
    );
    expect(
      baselineRejectCode(
        ledgerBoundaryOf(
          dbOpened: true,
          integrity: const LedgerIntegrityVerdict.ok(
            daysChecked: 4,
            checkedThrough: '2026-11-13',
          ),
        ),
        decisionId: 'dec-1',
        originCode: 'CHAIN_BROKEN',
      ),
      BaselineCodes.notX5,
    );
  });

  test('🔴 첫 어긋난 날 모름 · 결정 없음 · 원인 밖 = 거부', () {
    final LedgerBoundaryVerdict noDate = ledgerBoundaryOf(
      dbOpened: true,
      integrity: const LedgerIntegrityVerdict.failed(
        LedgerIntegrityReason.attribution,
        daysChecked: 0,
      ),
    );
    expect(
      baselineRejectCode(noDate, decisionId: 'dec-1', originCode: 'DB_ERROR'),
      BaselineCodes.firstBadDateUnknown,
    );
    expect(
      baselineRejectCode(_x5, decisionId: null, originCode: 'CHAIN_BROKEN'),
      RepairCodes.decisionRequired,
    );
    expect(
      baselineRejectCode(_x5, decisionId: 'dec-1', originCode: 'SCHEMA_SKEW'),
      RepairCodes.originNotAllowed,
      reason: '기준점 셋 안이지만 이 경계 후보(CHAIN_BROKEN · DB_ERROR) 밖',
    );
    expect(
      baselineRejectCode(_x5, decisionId: 'dec-1', originCode: 'MANUAL_ORDER'),
      RepairCodes.originNotAllowed,
    );
    final LedgerBoundaryVerdict fmt = ledgerBoundaryOf(
      dbOpened: true,
      integrity: _bad(LedgerIntegrityReason.formatVersion),
    );
    expect(
      baselineRejectCode(fmt, decisionId: 'dec-1', originCode: 'SCHEMA_SKEW'),
      isNull,
    );
  });

  test(
    '🔴 계획 — CANON_CORRECT · 합성 li- id · 첫 어긋난 날 · 옛 스탬프 그 날 이후 · 체인 비움',
    () {
      final LedgerRepairPlanRow r = baselinePlanOf(
        _x5,
        repairId: 'rp-9',
        decisionId: 'dec-1',
        originCode: 'CHAIN_BROKEN',
        reasonWire: 'DAY_HASH_MISMATCH',
        stamps: _stamps,
        appliedAtUtc: DateTime.utc(2026, 11, 15, 3),
      );
      expect(
        (
          r.direction,
          r.originCode,
          r.decisionId,
          r.recomputedFrom,
          r.chainHash,
        ),
        (
          RepairDirection.canonCorrect,
          'CHAIN_BROKEN',
          'dec-1',
          '2026-11-12',
          null,
        ),
      );
      expect(r.diffId, integrityDiffIdOf('2026-11-12', 'DAY_HASH_MISMATCH'));
      expect(r.diffId, matches(RegExp(r'^li-[0-9a-f]{24}$')));
      expect(
        integrityDiffIdOf('2026-11-12', 'DAY_HASH_MISMATCH'),
        isNot(integrityDiffIdOf('2026-11-13', 'DAY_HASH_MISMATCH')),
      );
      final List<Object?> ev = jsonDecode(r.evidenceJson!) as List<Object?>;
      expect(
        ev.map((Object? e) => (e! as Map<String, Object?>)['date']),
        <String>['2026-11-12', '2026-11-13'],
      );
      expect((ev.first! as Map<String, Object?>)['chain_hash'], _h(12));
      expect(r.evidenceHash, evidenceHashOf(r.evidenceJson!));
      expect(
        () => baselinePlanOf(
          _x5,
          repairId: 'rp-9',
          decisionId: null,
          originCode: 'CHAIN_BROKEN',
          reasonWire: 'DAY_HASH_MISMATCH',
          stamps: _stamps,
          appliedAtUtc: DateTime.utc(2026, 11, 15, 3),
        ),
        throwsStateError,
      );
    },
  );

  test('옛 스탬프 근거 — 그 날 앞은 뺀다 · 날 차례 · 비면 빈 목록', () {
    expect(oldStampsEvidenceJson(_stamps, '2026-11-20'), '[]');
    final List<Object?> all = jsonDecode(
      oldStampsEvidenceJson(_stamps, '2026-11-01'),
    ) as List<Object?>;
    expect(
      all.map((Object? e) => (e! as Map<String, Object?>)['date']),
      <String>['2026-11-10', '2026-11-11', '2026-11-12', '2026-11-13'],
    );
    expect(OriginCodes.chainBroken, 'CHAIN_BROKEN');
  });
}
