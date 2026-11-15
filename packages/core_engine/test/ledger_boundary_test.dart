// E16a — X5-5 X1 과의 경계 판정(순수 · 설계 13 §8 R112 · 06 :290 · 지도 e16-map D2 · D4).
//
// 🔵 잡는 것: ① 파일 · PRAGMA · 스탬프 사슬 · 아카이브 앞섬 · 갈라짐 = X1(비상 경로 안내 · 경로 · 링크)
//    ② 내용 3사유 · 형식 판 = X5(정정 마법사 · 원인 후보) ③ 통과 × 아카이브 뒤처짐 · 같음 · 비었음 · 모름 = CLEAN
//    ④ 나쁜 쪽이 이긴다(PRAGMA + 앞섬 = PRAGMA · 내용 + 앞섬 = RESTORE_ROLLBACK) ⑤ 열렸는데 무결성 없음 = 실패
//    ⑥ 문장에 금액 · «DRY_RUN» 0.
import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const LedgerIntegrityVerdict _ok = LedgerIntegrityVerdict.ok(
  daysChecked: 5,
  checkedThrough: '2026-11-14',
);

LedgerIntegrityVerdict _bad(LedgerIntegrityReason r) =>
    LedgerIntegrityVerdict.failed(
      r,
      firstBadDate: '2026-11-12',
      daysChecked: 3,
      checkedThrough: '2026-11-11',
    );

void _expectX1(LedgerBoundaryVerdict v, BoundaryReason reason) {
  expect(v.path, BoundaryPath.x1Emergency, reason: reason.wire);
  expect(v.reason, reason);
  expect(v.route, RepairRoute.x1Emergency);
  expect(v.guideLink, AppRoutes.x1MigrationEmergency);
  expect(v.headline, kBoundaryX1Headline);
}

void _expectX5(LedgerBoundaryVerdict v, BoundaryReason reason) {
  expect(v.path, BoundaryPath.x5Repair, reason: reason.wire);
  expect(v.reason, reason);
  expect(v.route, RepairRoute.approval);
  expect(v.guideLink, AppRoutes.x5RepairWizard);
}

void main() {
  test('🔴 파일이 열리지 않음 = X1 · 후보 0 · 무결성 없어도 된다', () {
    final LedgerBoundaryVerdict v = ledgerBoundaryOf(dbOpened: false);
    _expectX1(v, BoundaryReason.dbOpenFailed);
    expect(v.originCandidates, isEmpty);
    expect(v.firstBadDate, isNull);
  });

  test('열렸는데 무결성 결과 없음 = ArgumentError', () {
    expect(() => ledgerBoundaryOf(dbOpened: true), throwsArgumentError);
  });

  test('🔴 PRAGMA = X1 · 후보 0', () {
    final LedgerBoundaryVerdict v = ledgerBoundaryOf(
      dbOpened: true,
      integrity: _bad(LedgerIntegrityReason.sqliteIntegrity),
    );
    _expectX1(v, BoundaryReason.sqliteIntegrity);
    expect(v.originCandidates, isEmpty);
  });

  test(
    '🔴 스탬프 사슬 끊김(DATE_GAP · CHAIN_BROKEN) = X1 · CHAIN_BROKEN · 첫 어긋난 날',
    () {
      for (final LedgerIntegrityReason r in <LedgerIntegrityReason>[
        LedgerIntegrityReason.dateGap,
        LedgerIntegrityReason.chainBroken,
      ]) {
        final LedgerBoundaryVerdict v = ledgerBoundaryOf(
          dbOpened: true,
          integrity: _bad(r),
        );
        _expectX1(v, BoundaryReason.stampChainBroken);
        expect(v.originCandidates, <String>[OriginCodes.chainBroken]);
        expect(v.firstBadDate, '2026-11-12');
      }
    },
  );

  test('🔴 아카이브 AHEAD = X1 RESTORE_ROLLBACK', () {
    final LedgerBoundaryVerdict v = ledgerBoundaryOf(
      dbOpened: true,
      integrity: _ok,
      archiveRelation: DerivedRelation.ahead,
    );
    _expectX1(v, BoundaryReason.restoreRollback);
    expect(v.originCandidates, <String>[OriginCodes.restoreRollback]);
  });

  test(
    '🔴 아카이브 DIVERGED · EPOCH_AHEAD = X1 ARCHIVE_DIVERGED · CHAIN_BROKEN',
    () {
      for (final DerivedRelation r in <DerivedRelation>[
        DerivedRelation.diverged,
        DerivedRelation.epochAhead,
      ]) {
        final LedgerBoundaryVerdict v = ledgerBoundaryOf(
          dbOpened: true,
          integrity: _ok,
          archiveRelation: r,
        );
        _expectX1(v, BoundaryReason.archiveDiverged);
        expect(v.originCandidates, <String>[OriginCodes.chainBroken]);
      }
    },
  );

  test(
    '🔴 내용 3사유 = X5 CONTENT_MISMATCH · 후보 CHAIN_BROKEN · DB_ERROR · 문장에 날 · 사유',
    () {
      for (final LedgerIntegrityReason r in <LedgerIntegrityReason>[
        LedgerIntegrityReason.dayHashMismatch,
        LedgerIntegrityReason.rowsBeforeFirstStamp,
        LedgerIntegrityReason.attribution,
      ]) {
        final LedgerBoundaryVerdict v = ledgerBoundaryOf(
          dbOpened: true,
          integrity: _bad(r),
          archiveRelation: DerivedRelation.behind,
        );
        _expectX5(v, BoundaryReason.contentMismatch);
        expect(v.originCandidates, <String>[
          OriginCodes.chainBroken,
          OriginCodes.dbError,
        ]);
        expect(v.firstBadDate, '2026-11-12');
        expect(
          v.headline,
          '지난 기록이 스탬프와 다릅니다(2026-11-12 · ${r.code}) — 정정 마법사에서 원인을 고르십시오.',
        );
      }
    },
  );

  test('🔴 FORMAT_VERSION = X5 · SCHEMA_SKEW', () {
    final LedgerBoundaryVerdict v = ledgerBoundaryOf(
      dbOpened: true,
      integrity: _bad(LedgerIntegrityReason.formatVersion),
    );
    _expectX5(v, BoundaryReason.formatVersion);
    expect(v.originCandidates, <String>[OriginCodes.schemaSkew]);
  });

  test('X5 첫 어긋난 날 모름 = «날 모름»', () {
    final LedgerBoundaryVerdict v = ledgerBoundaryOf(
      dbOpened: true,
      integrity: const LedgerIntegrityVerdict.failed(
        LedgerIntegrityReason.attribution,
        daysChecked: 0,
      ),
    );
    expect(v.headline, startsWith('지난 기록이 스탬프와 다릅니다(날 모름 · ATTRIBUTION)'));
  });

  test('🔴 통과 × 아카이브 BEHIND · IN_SYNC · EMPTY · REBASED · 모름 = CLEAN', () {
    for (final DerivedRelation? r in <DerivedRelation?>[
      DerivedRelation.behind,
      DerivedRelation.inSync,
      DerivedRelation.empty,
      DerivedRelation.rebased,
      null,
    ]) {
      final LedgerBoundaryVerdict v = ledgerBoundaryOf(
        dbOpened: true,
        integrity: _ok,
        archiveRelation: r,
      );
      expect(v.path, BoundaryPath.none, reason: '$r');
      expect(v.reason, BoundaryReason.clean);
      expect(v.route, isNull);
      expect(v.guideLink, isNull);
      expect(v.headline, isEmpty);
      expect(v.originCandidates, isEmpty);
    }
  });

  test('🔴 나쁜 쪽이 이긴다 — PRAGMA + AHEAD = PRAGMA · 사슬 + AHEAD = 사슬', () {
    expect(
      ledgerBoundaryOf(
        dbOpened: true,
        integrity: _bad(LedgerIntegrityReason.sqliteIntegrity),
        archiveRelation: DerivedRelation.ahead,
      ).reason,
      BoundaryReason.sqliteIntegrity,
    );
    expect(
      ledgerBoundaryOf(
        dbOpened: true,
        integrity: _bad(LedgerIntegrityReason.dateGap),
        archiveRelation: DerivedRelation.ahead,
      ).reason,
      BoundaryReason.stampChainBroken,
    );
  });

  test(
    '🔴 나쁜 쪽이 이긴다 — 내용 + AHEAD = RESTORE_ROLLBACK(X1) · 형식 + DIVERGED = X1',
    () {
      final LedgerBoundaryVerdict a = ledgerBoundaryOf(
        dbOpened: true,
        integrity: _bad(LedgerIntegrityReason.dayHashMismatch),
        archiveRelation: DerivedRelation.ahead,
      );
      _expectX1(a, BoundaryReason.restoreRollback);
      final LedgerBoundaryVerdict b = ledgerBoundaryOf(
        dbOpened: true,
        integrity: _bad(LedgerIntegrityReason.formatVersion),
        archiveRelation: DerivedRelation.diverged,
      );
      _expectX1(b, BoundaryReason.archiveDiverged);
    },
  );

  test('문장에 금액 · «DRY_RUN» 0 · X1 = 자동 기동 안 함', () {
    final List<LedgerBoundaryVerdict> all = <LedgerBoundaryVerdict>[
      ledgerBoundaryOf(dbOpened: false),
      for (final LedgerIntegrityReason r in LedgerIntegrityReason.values)
        ledgerBoundaryOf(dbOpened: true, integrity: _bad(r)),
    ];
    for (final LedgerBoundaryVerdict v in all) {
      expect(v.headline, isNotEmpty);
      expect(v.headline, isNot(contains('DRY_RUN')));
      expect(v.headline, isNot(matches(RegExp(r'\d원'))));
    }
    expect(kBoundaryX1Headline, contains('자동으로 다시 켜지 않습니다'));
  });

  test('사유 글자 8 · 길 3', () {
    expect(BoundaryReason.values.map((BoundaryReason r) => r.wire), <String>[
      'DB_OPEN_FAILED',
      'SQLITE_INTEGRITY',
      'STAMP_CHAIN_BROKEN',
      'RESTORE_ROLLBACK',
      'ARCHIVE_DIVERGED',
      'CONTENT_MISMATCH',
      'FORMAT_VERSION',
      'CLEAN',
    ]);
    expect(BoundaryPath.values, hasLength(3));
  });
}
