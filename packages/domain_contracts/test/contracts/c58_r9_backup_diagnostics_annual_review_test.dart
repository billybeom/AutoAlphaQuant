// C-58 백업·복원 S09 · 진단 S10 · 연간 리뷰 목차 S12 — VM 교체 · 감싸개 · 목차 · 결과 사전 — 01 §33(🆕 계약 v1.24 · R9 선행 ·
// 발주자 위임 2026-11-14 — 권고대로 · K104~K143).
//
// 정의: 「M9 `S09` 은 교체된 `BackupVm`(복원 버튼 0 · 크기·경로 칸 0 · 지점 행 동작 0)을 `OpsStatusRepository.watchBackup()` 으로,
//        `S10` 은 감싸개 `DiagnosticsScreenVm`(보드 = H-01 과 같은 `DiagnosticsVm` 값 · 실행 카드 2)을
//        `SettingsRepository.watchDiagnosticsScreen()` 으로, `S12` 는 목차 `AnnualReviewIndexVm`(세후·수치 칸 0)을
//        `OpsStatusRepository.watchAnnualReview()` 로 읽는다 · 결과 코드 = 엔진 글자 1:1 사전(`BackupResultCodes` 8 = `take` 경로 ·
//        `LedgerIntegrityResultCodes` 7 = E13c1) · 표본에 경로·크기·총계·금액 0」.
//   ① 허용 키 ② 잠김 ③ 빈 지점 ④ 지점 행 ⑤ 백업 결과 ⑥ 셀프테스트 결과 ⑦ 사전 ⑧ 중복 문서 ⑨ 보드 = H-01 값 ⑩ 글자 금지
//   ⑪ 목차 링크 ⑫ 서약 링크 ⑬ 변종 동치 ⑭ 화면 미호출 · ⏸ ⑮ 받침대 ⑯ 포트 경계.
//
// 🔴 픽스처 불변식 + 포트 경계 스캔만 본다 — S09·S10·S12 화면 규칙(복원 버튼 0 · 두 실행 카드 · 쓰기 0)은 R9a~c 카드 정적 묶음 몫.
// 🔴 리터럴 = 표본 id·키·코드·`FixturePaths` + 엔진 글자 표(⑦ 사전 값 15 — 출처 주석 파일:줄 · origin/main 01b0695 · K141).

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// S09 VM 6벌.
const List<String> _backupVms = <String>[
  FixturePaths.m9Backup,
  FixturePaths.m9BackupAgeWarn,
  FixturePaths.m9BackupEmpty,
  FixturePaths.m9BackupSim,
  FixturePaths.m9BackupLocked,
  FixturePaths.m9BackupStale,
];

/// S10 VM 5벌.
const List<String> _diagVms = <String>[
  FixturePaths.m9DiagnosticsScreen,
  FixturePaths.m9DiagnosticsScreenDiff,
  FixturePaths.m9DiagnosticsScreenRunning,
  FixturePaths.m9DiagnosticsScreenLocked,
  FixturePaths.m9DiagnosticsScreenStale,
];

/// S12 VM 4벌.
const List<String> _annualVms = <String>[
  FixturePaths.m9AnnualReviewIndexOpen,
  FixturePaths.m9AnnualReviewIndexClosed,
  FixturePaths.m9AnnualReviewIndexFirstYear,
  FixturePaths.m9AnnualReviewIndexStale,
];

/// v1.24 신설 17벌.
const List<String> _new = <String>[
  ..._backupVms,
  FixturePaths.m9BackupActionResults,
  ..._diagVms,
  FixturePaths.m9SelftestActionResults,
  ..._annualVms,
];

/// ① §4-1 JSON 키(선언 차례).
const List<String> _backupKeys = <String>[
  'last_backup_text',
  'age_badge_text',
  'level',
  'notice_text',
  'run_action',
  'locked_label',
  'points',
  'points_empty_label',
  'migration_link',
  'as_of',
];
const List<String> _pointKeys = <String>[
  'code',
  'label',
  'chain_hash_text',
  'state_label',
];
const List<String> _diagKeys = <String>[
  'golden',
  'integrity',
  'board',
  'diffs_link',
  'recommend_text',
  'locked_label',
  'as_of',
];
const List<String> _cardKeys = <String>[
  'title',
  'status_label',
  'level',
  'last_run_text',
  'summary_text',
  'run_action',
];
const List<String> _annualKeys = <String>[
  'year_label',
  'window_state_label',
  'entries',
  'pledge_link',
  'as_of',
];

/// ① 옛 칸 · 경로·크기 · 복원 동작 · 세후·수치 칸 금지.
const List<String> _backupBadKeys = <String>[
  'size_text',
  'route',
  'status_code',
  'action_available',
  'last_ok_text',
  'path',
  'file_name',
  'drill',
  'restore_action',
];
const List<String> _diagBadKeys = <String>['blocking', 'failures', 'total'];
const List<String> _annualBadKeys = <String>[
  'after_tax',
  'after_tax_counterfactual',
  'sections',
  'lines',
  'year',
  'window_state_code',
];

// ── 엔진 글자 표(origin/main 01b0695) ─────────────────────────────────────

/// ⑦ `take` 경로 거부 8 — core `migration/migration_plan.dart:114` `MigrationStartCodes.liveOnly` · core
///    `migration/backup_manifest.dart:35 · 38` `SnapshotCodes` · :142 · 148 · 151 · 154 · 160 `RestoreReason.wire`
///    (ds `migration/ledger_snapshot.dart:261-301` 이 내는 것 전수 · K132).
const Set<String> _engineTakeCodes = <String>{
  'X1_LIVE_ONLY',
  'SNAPSHOT_NO_STAMP',
  'SNAPSHOT_EXISTS',
  'RESTORE_UNREADABLE',
  'RESTORE_SCHEMA_SKEW',
  'RESTORE_SQLITE_INTEGRITY',
  'RESTORE_CHAIN_INVALID',
  'RESTORE_ROLLBACK',
};

/// ⑦ `take` 에서 나올 수 없는 복원 판정 2(core `backup_manifest.dart:139 · 157` — 매니페스트 = 같은 사본의 digest·머리).
const Set<String> _notFromTake = <String>{
  'RESTORE_SHA_MISMATCH',
  'RESTORE_MANIFEST_MISMATCH',
};

/// ⑦ 무결성 사유 7 — core `ops/ledger_integrity.dart:19-37` `LedgerIntegrityReason.code`.
const Set<String> _engineIntegrityCodes = <String>{
  'FORMAT_VERSION',
  'DATE_GAP',
  'CHAIN_BROKEN',
  'DAY_HASH_MISMATCH',
  'ROWS_BEFORE_FIRST_STAMP',
  'ATTRIBUTION',
  'SQLITE_INTEGRITY',
};

/// ⑭ 화면 미호출 · ⏸ 동작 wire.
const List<String> _notCalled = <String>[
  'BACKUP_RESTORE_START',
  'CALENDAR_SYNC_NOW',
  'CALENDAR_REBACKFILL',
  'CALENDAR_RECONNECT',
  'SETTINGS_GENERAL_UPDATE',
];

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _rows(String path) => (_env(path)['rows']! as List)
    .cast<Map<String, Object?>>()
    .toList(growable: false);

Map<String, Object?> _vm(String path) => _rows(path).single;

/// 메타·`deep_link` 를 뺀 전 문자열.
List<String> _strings(Object? v, {Set<String> skip = const <String>{}}) {
  final List<String> out = <String>[];
  void walk(Object? x) {
    if (x is Map) {
      x.forEach((Object? k, Object? y) {
        if (k != 'meta' && k != 'deep_link' && !skip.contains(k)) walk(y);
      });
    } else if (x is List) {
      x.forEach(walk);
    } else if (x is String) {
      out.add(x);
    }
  }

  walk(v);
  return out;
}

/// 키 몇 개를 뺀 행의 JSON(변종 동치).
String _without(Map<String, Object?> row, Set<String> keys) =>
    jsonEncode(<String, Object?>{
      for (final MapEntry<String, Object?> e in row.entries)
        if (!keys.contains(e.key)) e.key: e.value,
    });

Map<String, Object?> _card(Map<String, Object?> vm, String name) =>
    vm[name]! as Map<String, Object?>;

void main() {
  group('C-58 백업·복원 S09 · 진단 S10 · 연간 리뷰 목차 S12 — VM 교체 · 감싸개 · 목차 · 결과 사전 (01 §33 · 계약 v1.24)', () {
    test('C-58 ① 허용 키 — 세 VM 벌 키 == toJson == 선언(차례 포함) · 지점·카드 키 · 금지 키 0 · 결과 행 키 == ActionResult', () {
      for (final String path in _backupVms) {
        final Map<String, Object?> row = _vm(path);
        expect(row.keys.toList(), _backupKeys, reason: '$path — VM 키');
        expect(
          BackupVm.fromJson(row).toJson().keys.toList(),
          _backupKeys,
          reason: '$path — toJson 키',
        );
        for (final Object? p in row['points']! as List) {
          expect(
            (p! as Map<String, Object?>).keys.toList(),
            _pointKeys,
            reason: '$path — 지점 키',
          );
        }
        expect(
          RestorePointRow.fromJson(const <String, dynamic>{
            'code': 'x',
            'label': 'x',
            'chain_hash_text': 'x',
          }).toJson().keys.toList(),
          _pointKeys,
        );
        for (final String bad in _backupBadKeys) {
          expect(row.containsKey(bad), isFalse, reason: '$path — 금지 키 $bad');
          for (final Object? p in row['points']! as List) {
            expect(
              (p! as Map<String, Object?>).containsKey(bad),
              isFalse,
              reason: '$path — 지점 금지 키 $bad',
            );
          }
        }
      }
      for (final String path in _diagVms) {
        final Map<String, Object?> row = _vm(path);
        expect(row.keys.toList(), _diagKeys, reason: '$path — VM 키');
        expect(
          DiagnosticsScreenVm.fromJson(row).toJson().keys.toList(),
          _diagKeys,
          reason: '$path — toJson 키',
        );
        for (final String c in <String>['golden', 'integrity']) {
          expect(_card(row, c).keys.toList(), _cardKeys, reason: '$path $c');
          expect(
            SelfTestCard.fromJson(_card(row, c)).toJson().keys.toList(),
            _cardKeys,
            reason: '$path $c — toJson 키',
          );
          for (final String bad in _diagBadKeys) {
            expect(
              _card(row, c).containsKey(bad),
              isFalse,
              reason: '$path $c $bad',
            );
          }
        }
        for (final String bad in _diagBadKeys) {
          expect(row.containsKey(bad), isFalse, reason: '$path — 금지 키 $bad');
        }
      }
      for (final String path in _annualVms) {
        final Map<String, Object?> row = _vm(path);
        expect(row.keys.toList(), _annualKeys, reason: '$path — VM 키');
        expect(
          AnnualReviewIndexVm.fromJson(row).toJson().keys.toList(),
          _annualKeys,
          reason: '$path — toJson 키',
        );
        for (final String bad in _annualBadKeys) {
          expect(row.containsKey(bad), isFalse, reason: '$path — 금지 키 $bad');
        }
      }
      for (final String path in <String>[
        FixturePaths.m9BackupActionResults,
        FixturePaths.m9SelftestActionResults,
      ]) {
        for (final Map<String, Object?> r in _rows(path)) {
          expect(
            r.keys.toList(),
            ActionResult.fromJson(r).toJson().keys.toList(),
            reason: '$path — 결과 행 키',
          );
        }
      }
    });

    test('C-58 ② 잠김 — locked_label ⇒ 실행 칸 null · 잠김 = _locked 두 벌뿐', () {
      for (final String path in _backupVms) {
        final BackupVm vm = BackupVm.fromJson(_vm(path));
        if (vm.lockedLabel != null) {
          expect(vm.runAction, isNull, reason: '$path — 잠김에 버튼');
        }
        expect(
          vm.lockedLabel != null,
          path == FixturePaths.m9BackupLocked,
          reason: '$path — 잠김 갈래',
        );
      }
      for (final String path in _diagVms) {
        final DiagnosticsScreenVm vm = DiagnosticsScreenVm.fromJson(_vm(path));
        if (vm.lockedLabel != null) {
          expect(vm.golden.runAction, isNull, reason: '$path — 골든 버튼');
          expect(vm.integrity.runAction, isNull, reason: '$path — 무결성 버튼');
        }
        expect(
          vm.lockedLabel != null,
          path == FixturePaths.m9DiagnosticsScreenLocked,
          reason: '$path — 잠김 갈래',
        );
      }
    });

    test('C-58 ③ 빈 지점 — S09 6벌: points 빈 ⇔ points_empty_label non-null', () {
      for (final String path in _backupVms) {
        final BackupVm vm = BackupVm.fromJson(_vm(path));
        expect(vm.points.isEmpty, vm.pointsEmptyLabel != null, reason: path);
      }
    });

    test('C-58 ④ 지점 행 — chain_hash_text ^[0-9a-f]{8}\$ · code 한 벌 안 유일 · 꼴 rp_s09_nn', () {
      final RegExp hash = RegExp(r'^[0-9a-f]{8}$');
      final RegExp code = RegExp(r'^rp_s09_\d\d$');
      for (final String path in _backupVms) {
        final BackupVm vm = BackupVm.fromJson(_vm(path));
        for (final RestorePointRow p in vm.points) {
          expect(
            hash.hasMatch(p.chainHashText),
            isTrue,
            reason: '$path ${p.code}',
          );
          expect(code.hasMatch(p.code), isTrue, reason: '$path ${p.code}');
        }
        expect(
          vm.points.map((RestorePointRow p) => p.code).toSet(),
          hasLength(vm.points.length),
          reason: path,
        );
      }
    });

    test('C-58 ⑤ 백업 결과 — id 하나 · 코드 == 사전 8 + 생체 + 접수 정확히 · 레벨 5값 · 넘김·재시도 0 · «(합성)»', () {
      final List<ActionResult> rows = _rows(FixturePaths.m9BackupActionResults)
          .map(ActionResult.fromJson)
          .toList();
      expect(rows, hasLength(10));
      expect(rows.map((ActionResult r) => r.id).toSet(), <SettingsActionId>{
        SettingsActionId.backupRunNow,
      });
      final List<String?> codes = rows
          .map((ActionResult r) => r.reasonCode)
          .toList();
      expect(codes.toSet(), <String?>{
        ...BackupResultCodes.values,
        SettingsResultCodes.biometricUnavailable,
        null,
      });
      expect(codes.toSet(), hasLength(codes.length), reason: '10행 = 10값');
      expect(
        rows.map((ActionResult r) => r.level).toSet(),
        UiLevel.values.toSet(),
      );
      for (final ActionResult r in rows) {
        expect(r.handoffRoute, isNull, reason: r.actionRunId);
        expect(r.retryable, isFalse, reason: r.actionRunId);
        if (r.reasonCode != SettingsResultCodes.biometricUnavailable) {
          expect(r.headline, startsWith('(합성)'), reason: r.actionRunId);
        }
      }
      expect(
        rows.map((ActionResult r) => r.actionRunId).toSet(),
        hasLength(rows.length),
      );
    });

    test('C-58 ⑥ 셀프테스트 결과 — 골든 코드 = {생체, null} · 무결성 = 사전 7 + 생체 + null · 사유 행 BLOCKED', () {
      final List<ActionResult> rows = _rows(
        FixturePaths.m9SelftestActionResults,
      ).map(ActionResult.fromJson).toList();
      expect(rows, hasLength(12));
      expect(rows.map((ActionResult r) => r.id).toSet(), <SettingsActionId>{
        SettingsActionId.selftestGoldenRun,
        SettingsActionId.selftestIntegrityRun,
      });
      final Iterable<ActionResult> golden = rows.where(
        (ActionResult r) => r.id == SettingsActionId.selftestGoldenRun,
      );
      final Iterable<ActionResult> integrity = rows.where(
        (ActionResult r) => r.id == SettingsActionId.selftestIntegrityRun,
      );
      expect(golden.map((ActionResult r) => r.reasonCode).toSet(), <String?>{
        SettingsResultCodes.biometricUnavailable,
        null,
      });
      expect(integrity.map((ActionResult r) => r.reasonCode).toSet(), <String?>{
        ...LedgerIntegrityResultCodes.values,
        SettingsResultCodes.biometricUnavailable,
        null,
      });
      for (final ActionResult r in rows) {
        expect(r.handoffRoute, isNull, reason: r.actionRunId);
        expect(r.retryable, isFalse, reason: r.actionRunId);
        if (LedgerIntegrityResultCodes.values.contains(r.reasonCode)) {
          expect(
            r.level,
            UiLevel.blocked,
            reason: '${r.actionRunId} — fail-closed',
          );
        }
      }
      expect(
        rows.map((ActionResult r) => r.actionRunId).toSet(),
        hasLength(rows.length),
      );
    });

    test('C-58 ⑦ 사전 — values == 엔진(take 경로 8 · 사유 7) · 나올 수 없는 2 제외 · byDomain · 설정 결과와 겹침 0 · 선언 == values', () {
      expect(BackupResultCodes.values, _engineTakeCodes);
      expect(BackupResultCodes.values.intersection(_notFromTake), isEmpty);
      expect(LedgerIntegrityResultCodes.values, _engineIntegrityCodes);
      expect(ContractCodes.byDomain['backup_result'], BackupResultCodes.values);
      expect(
        ContractCodes.byDomain['ledger_integrity_result'],
        LedgerIntegrityResultCodes.values,
      );
      expect(
        BackupResultCodes.values.intersection(SettingsResultCodes.values),
        isEmpty,
      );
      expect(
        LedgerIntegrityResultCodes.values.intersection(
          SettingsResultCodes.values,
        ),
        isEmpty,
      );
      final String src = stripComments(
        File('${libDir.path}/src/labels/settings_codes.dart')
            .readAsStringSync(),
      );
      for (final MapEntry<String, Set<String>> e in <String, Set<String>>{
        'BackupResultCodes': BackupResultCodes.values,
        'LedgerIntegrityResultCodes': LedgerIntegrityResultCodes.values,
      }.entries) {
        final RegExpMatch? m = RegExp(
          'abstract final class ${e.key}\\s*\\{(.*?)\\n\\}',
          dotAll: true,
        ).firstMatch(src);
        expect(m, isNotNull, reason: e.key);
        expect(
          <String>{
            for (final RegExpMatch c in RegExp(
              r"static const String \w+\s*=\s*'([^']*)';",
            ).allMatches(m![1]!))
              c[1]!,
          },
          e.value,
          reason: '${e.key} — 선언 상수 == values',
        );
      }
    });

    test('C-58 ⑧ 중복 문서 — CHAIN_BROKEN · RESTORE_ROLLBACK = origin_code 와 한 쌍씩 · 그 밖 새 값 = 도메인 하나', () {
      expect(ContractCodes.domainsOf('CHAIN_BROKEN'), <String>{
        'origin_code',
        'ledger_integrity_result',
      });
      expect(ContractCodes.domainsOf('RESTORE_ROLLBACK'), <String>{
        'origin_code',
        'backup_result',
      });
      for (final String code in <String>{
        ...BackupResultCodes.values,
        ...LedgerIntegrityResultCodes.values,
      }.difference(<String>{'CHAIN_BROKEN', 'RESTORE_ROLLBACK'})) {
        expect(ContractCodes.domainsOf(code), hasLength(1), reason: code);
      }
    });

    test('C-58 ⑨ 보드 = H-01 값 — S10 5벌 board == m8/recon_board_ok · _diff rows[0](기본·실행 중·오래됨 = ok · 차이·잠김 = diff)', () {
      final String ok = jsonEncode(_vm(FixturePaths.m8ReconBoardOk));
      final String diff = jsonEncode(_vm(FixturePaths.m8ReconBoardDiff));
      const Set<String> diffSide = <String>{
        FixturePaths.m9DiagnosticsScreenDiff,
        FixturePaths.m9DiagnosticsScreenLocked,
      };
      for (final String path in _diagVms) {
        expect(
          jsonEncode(_vm(path)['board']),
          diffSide.contains(path) ? diff : ok,
          reason: path,
        );
      }
    });

    test(
      'C-58 ⑩ 글자 금지 — 신설 17: 경로·파일·크기·16진 9자·총계·n/m·%·DRY_RUN·손익 낱말·8자리 숫자 0',
      () {
        final List<RegExp> bad = <RegExp>[
          RegExp(r'[/\\]'),
          RegExp(r'\.sqlite|\.json|manifest|sha256'),
          RegExp('KB|MB|GB|바이트'),
          RegExp('[0-9a-fA-F]{9,}'),
          RegExp('345|109|196'),
          RegExp(r'\d+\s*/\s*\d+'),
          RegExp('%'),
          RegExp('DRY_RUN'),
          RegExp('평가손익|수익률|평가액|손익|세후'),
          RegExp('[0-9]{8,}'),
        ];
        final List<String> offenders = <String>[];
        for (final String path in _new) {
          for (final String s in _strings(_env(path))) {
            for (final RegExp rx in bad) {
              if (rx.hasMatch(s)) offenders.add('$path: «$s» ~ ${rx.pattern}');
            }
          }
        }
        expect(offenders, isEmpty);
      },
    );

    test('C-58 ⑪ 목차 링크 — entries ∈ 라우트 · 파라미터 0 · settings 밖 · 서약 = m5Pledge · 목차 글자 숫자 0', () {
      for (final String path in _annualVms) {
        final AnnualReviewIndexVm vm = AnnualReviewIndexVm.fromJson(_vm(path));
        expect(vm.entries, isNotEmpty, reason: path);
        for (final LinkAction e in vm.entries) {
          expect(
            AppRoutes.all,
            contains(e.deepLink),
            reason: '$path ${e.deepLink}',
          );
          expect(e.deepLink.contains('{'), isFalse, reason: path);
          expect(e.deepLink.contains('?'), isFalse, reason: path);
          expect(
            e.deepLink.startsWith('aaq://settings'),
            isFalse,
            reason: path,
          );
        }
        if (vm.pledgeLink != null) {
          expect(vm.pledgeLink!.deepLink, AppRoutes.m5Pledge, reason: path);
        }
        final List<String> digits = _strings(
          _vm(path),
          skip: const <String>{'as_of', 'year_label'},
        ).where((String s) => RegExp('[0-9]').hasMatch(s)).toList();
        expect(digits, isEmpty, reason: '$path — 수치 줄');
      }
    });

    test('C-58 ⑫ 서약 링크 — pledge_link non-null ⇔ _open · _stale(원판 OPEN)', () {
      const Set<String> open = <String>{
        FixturePaths.m9AnnualReviewIndexOpen,
        FixturePaths.m9AnnualReviewIndexStale,
      };
      for (final String path in _annualVms) {
        expect(
          _vm(path)['pledge_link'] != null,
          open.contains(path),
          reason: path,
        );
      }
    });

    test('C-58 ⑬ 변종 동치 — _locked 두 벌 · _stale 세 벌은 원판에서 그 칸만 다르다', () {
      final Map<String, Object?> backup = _vm(FixturePaths.m9Backup);
      final Map<String, Object?> backupLocked = _vm(
        FixturePaths.m9BackupLocked,
      );
      const Set<String> bkKeys = <String>{
        'run_action',
        'migration_link',
        'locked_label',
      };
      expect(_without(backupLocked, bkKeys), _without(backup, bkKeys));
      expect(backupLocked['run_action'], isNull);
      expect(backupLocked['migration_link'], isNull);
      expect(backup['run_action'], isNotNull);
      expect(backup['migration_link'], isNotNull);

      final Map<String, Object?> diff = _vm(
        FixturePaths.m9DiagnosticsScreenDiff,
      );
      final Map<String, Object?> diagLocked = _vm(
        FixturePaths.m9DiagnosticsScreenLocked,
      );
      String cardWithoutRun(Map<String, Object?> vm, String c) =>
          _without(_card(vm, c), const <String>{'run_action'});
      for (final String c in <String>['golden', 'integrity']) {
        expect(
          cardWithoutRun(diagLocked, c),
          cardWithoutRun(diff, c),
          reason: c,
        );
        expect(_card(diff, c)['run_action'], isNotNull, reason: c);
      }
      const Set<String> dgKeys = <String>{
        'golden',
        'integrity',
        'locked_label',
      };
      expect(_without(diagLocked, dgKeys), _without(diff, dgKeys));
      expect(
        diagLocked['diffs_link'],
        isNotNull,
        reason: '잠김에도 남는 조회 링크(K138)',
      );

      final Map<String, String> staleOf = <String, String>{
        FixturePaths.m9BackupStale: FixturePaths.m9Backup,
        FixturePaths.m9DiagnosticsScreenStale: FixturePaths.m9DiagnosticsScreen,
        FixturePaths.m9AnnualReviewIndexStale:
            FixturePaths.m9AnnualReviewIndexOpen,
      };
      for (final MapEntry<String, String> e in staleOf.entries) {
        expect(
          _without(_vm(e.key), const <String>{'as_of'}),
          _without(_vm(e.value), const <String>{'as_of'}),
          reason: e.key,
        );
        final Map<String, Object?> asOf =
            _vm(e.key)['as_of']! as Map<String, Object?>;
        expect(asOf['stale_label'], isNotNull, reason: e.key);
        expect(
          _without(asOf, const <String>{'stale_label'}),
          jsonEncode(_vm(e.value)['as_of']),
          reason: e.key,
        );
      }
      for (final String path in _new) {
        expect(
          (_env(path)['as_of']! as Map<String, Object?>).containsKey(
            'stale_label',
          ),
          isFalse,
          reason: '$path 봉투',
        );
        if (staleOf.containsKey(path)) continue;
        for (final Map<String, Object?> r in _rows(path)) {
          final Object? asOf = r['as_of'];
          if (asOf is Map) {
            expect(asOf.containsKey('stale_label'), isFalse, reason: path);
          }
        }
      }
    });

    test('C-58 ⑭ 화면 미호출 · ⏸ — 전 표본 문자열에 복원·캘린더·일반 설정 동작 0 · S09·S10 run_action.args == {}', () {
      final List<String> offenders = <String>[];
      for (final String path in FixturePaths.all) {
        for (final String s in _strings(_env(path))) {
          for (final String id in _notCalled) {
            if (s.contains(id)) offenders.add('$path: $id');
          }
        }
      }
      expect(offenders, isEmpty);
      for (final String path in _backupVms) {
        final BackupVm vm = BackupVm.fromJson(_vm(path));
        if (vm.runAction != null) {
          expect(vm.runAction!.id, SettingsActionId.backupRunNow, reason: path);
          expect(vm.runAction!.args, isEmpty, reason: path);
        }
      }
      for (final String path in _diagVms) {
        final DiagnosticsScreenVm vm = DiagnosticsScreenVm.fromJson(_vm(path));
        if (vm.golden.runAction != null) {
          expect(
            vm.golden.runAction!.id,
            SettingsActionId.selftestGoldenRun,
            reason: path,
          );
          expect(vm.golden.runAction!.args, isEmpty, reason: path);
        }
        if (vm.integrity.runAction != null) {
          expect(
            vm.integrity.runAction!.id,
            SettingsActionId.selftestIntegrityRun,
            reason: path,
          );
          expect(vm.integrity.runAction!.args, isEmpty, reason: path);
        }
      }
    });

    test('C-58 ⑮ 받침대 — watchDiagnosticsScreen · watchBackup · watchAnnualReview = 동기 throw · 반환 = AnnualReviewIndexVm', () {
      expect(
        () => UnimplementedSettingsRepository().watchDiagnosticsScreen(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => UnimplementedOpsStatusRepository().watchBackup(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => UnimplementedOpsStatusRepository().watchAnnualReview(),
        throwsA(isA<UnimplementedError>()),
      );
      // 정적 반환 타입(옛 `AnnualReviewVm` 으로 되돌리면 이 줄이 컴파일되지 않는다).
      final Stream<AnnualReviewIndexVm> Function() annual =
          UnimplementedOpsStatusRepository().watchAnnualReview;
      final Stream<DiagnosticsScreenVm> Function() diagnostics =
          UnimplementedSettingsRepository().watchDiagnosticsScreen;
      expect(annual, isNotNull);
      expect(diagnostics, isNotNull);
    });

    test('C-58 ⑯ 포트 경계 — ui_*(ui_settings 제외)에 R9 이름 0 · ui_settings 에 S7-7 타입·보드 창구 0 · ui_shell 에 감싸개 0', () {
      final List<RegExp> r9 = <RegExp>[
        RegExp(r'\bwatchDiagnosticsScreen\s*\('),
        RegExp(r'\bDiagnosticsScreenVm\b'),
        RegExp(r'\bSelfTestCard\b'),
        RegExp(r'\bRestorePointRow\b'),
        RegExp(r'\bAnnualReviewIndexVm\b'),
        RegExp(r'\bBackupResultCodes\b'),
        RegExp(r'\bLedgerIntegrityResultCodes\b'),
      ];
      final List<RegExp> settings = <RegExp>[
        RegExp(r'\bAnnualReviewVm\b'),
        RegExp(r'\bwatchDiagnostics\s*\('),
        RegExp(r'\bPerformanceRepository\b'),
      ];
      final List<String> offenders = <String>[];
      int scanned = 0;
      for (final String name in uiPackageNames) {
        final Directory lib = Directory('${repoRoot.path}/packages/$name/lib');
        if (!lib.existsSync()) continue;
        for (final File f in dartSourcesIn(lib)) {
          scanned++;
          final String code = stripCommentsAndStrings(f.readAsStringSync());
          for (final RegExp rx in name == 'ui_settings' ? settings : r9) {
            if (rx.hasMatch(code)) {
              offenders.add('${shortPath(f)}: ${rx.pattern}');
            }
          }
        }
      }
      expect(scanned, greaterThan(0), reason: 'ui_*/lib 를 못 읽었다');
      expect(
        offenders,
        isEmpty,
        reason:
            '🔴 값의 원천 하나 — S12 는 목차 타입만(S7-7 의 AnnualReviewVm 0) · S10 은 감싸개 하나(보드 창구 따로 0) · '
            'H-01(ui_shell)은 watchDiagnostics 그대로(K113 · K118).',
      );
    });
  });
}
