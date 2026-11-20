// M9 S09 백업·복원 VM · «지금 백업» 결과(E11q-c2 · 설계 13 §8 R201 · 01 §33 K110~K112 · K132 · K133 · 미결 199).
//
// 🔴 [backupVmOf] = 두 원천 중 기기 안 몫만 — X1 스냅숏 매니페스트 목록(지점 · 마지막 백업 · 나이). 바깥 올리기(아카이브 push 나이 ·
//    `backup_upload` D9) = 발주자 수치 미정 → 칸 없음(지어내지 않는다 · 미결 199 ⓐ ⓕ).
// 🔴 버튼(`backupRunNow{}`) = `take` 가 받아 줄 때만 — live 원장 ∧ 스탬프 ≥ 1 ∧ 아카이브 `IN_SYNC`(K133 · 미결 199 ⓑ ⓒ) ∧
//    낼 창구 있음 ∧ 잠김 아님. 아니면 버튼 부재 + 까닭 한 줄(고지) — 화면은 분기하지 않는다.
// 🔴 나이 = 가장 새 지점의 만든 시각 · 임계 = `BACKUP_STALE` 와 같은 26h([kBackupStaleAfter]) · 배지 «지금 백업을 눌러 주세요» =
//    누를 수 있는 판(live · 스탬프 · IN_SYNC)에서만.
// 🔴 지점 행 = 받은 매니페스트를 새것부터 · 해시 앞 8 = 엔진이 자른다 · 상태 줄 «복원 검증 통과» = 그 지점 머리(날 · 체인 · epoch)가
//    지금 아카이브 체크포인트와 같다(새 폰 복원 판정의 «같음만» — 만든 때 4중 검증 통과 ∧ 아카이브가 그 뒤 움직이지 않음).
// 🔴 [backupRunResultOf] = 표본(`m9/backup_action_results`) 글자에서 «(합성) » 만 뺀 것 · 코드 = `take` 가 낸 글자 그대로.
// 🔴 스냅숏 이름 = 만든 시각(UTC 분 · [backupSnapshotNameOf]) — 매니페스트에 시각 칸이 없어서(SPEC ⑧) 이름이 시각을 가진다.

import 'package:domain_contracts/domain_contracts.dart'
    show
        ActionResult,
        AppRoutes,
        AsOf,
        AsOfSource,
        BackupVm,
        LinkAction,
        RestorePointRow,
        SettingsActionCall,
        SettingsActionId,
        SettingsResultCodes,
        TradeDate,
        UiLevel;

import '../migration/backup_manifest.dart'
    show BackupManifest, RestoreReason, SnapshotCodes;
import '../migration/migration_plan.dart' show MigrationStartCodes;
import 'ledger_archive.dart' show ArchiveCheckpoint, BackupAge;
import 'ledger_views.dart' show kstDateText;

/// 백업 화면 기준 유효 시간(표본 26시간).
const Duration kBackupScreenStaleAfter = Duration(hours: 26);

/// S09 글자(엔진 · 표본 `m9/backup*` 그대로).
abstract final class BackupScreenTexts {
  /// 한 번도 만들지 않았다(live).
  static const String never = '아직 백업한 적이 없습니다';

  /// 모의 원장.
  static const String simNever = '백업 기록 없음';

  /// 마지막 백업 앞머리(뒤 = 한국 `MM-DD HH:mm`).
  static const String lastPrefix = '마지막 백업 ';

  /// 나이 배지(26h 초과 · 누를 수 있는 판).
  static const String ageBadge = '마지막 백업이 오래됐습니다. 지금 백업을 눌러 주세요.';

  /// 고지 — 기기 안만(바깥 올리기 = D9 미정).
  static const String notice = '백업은 이 폰 안에만 있습니다. 폰을 잃어버리면 사본도 함께 잃습니다.';

  /// 고지 — 모의 원장(`X1_LIVE_ONLY`).
  static const String simNotice =
      '모의투자 원장은 백업하지 않습니다. 실전으로 전환한 뒤 실전 원장에서 만듭니다.';

  /// 고지 — 스탬프 0(`SNAPSHOT_NO_STAMP` 결과 글자와 같다).
  static const String noStampNotice = '아직 마감된 장부가 없어 백업할 것이 없습니다.';

  /// 🆕 고지 — 아카이브 `IN_SYNC` 전(K133 · 표본 없음 — 엔진 글자 · 결과 `RESTORE_ROLLBACK` 과 같은 축).
  static const String archiveWaitNotice =
      '바깥 아카이브와 아직 맞춰지지 않아 지금은 백업할 수 없습니다. 아카이브가 끝나면 지금 백업 버튼이 나타납니다.';

  /// 버튼.
  static const String run = '지금 백업';

  /// 지점 0.
  static const String pointsEmpty = '아직 만든 복원 지점이 없습니다.';

  /// 지점 상태 — 지금 아카이브와 같은 머리.
  static const String pointVerified = '복원 검증 통과';

  /// X1 기기 이전 링크.
  static const String migration = '폰을 바꾸시나요? 기기 이전 안내 보기';

  /// 운영 등급 생체 «보기만»(미결 169 — 조립이 관문을 세울 때 넘긴다 · 지금 0).
  static const String locked = '생체 인증을 하지 않아 보기만 됩니다. 이 화면을 다시 열면 인증할 수 있습니다.';
}

/// «지금 백업» 결과 글자(표본 `m9/backup_action_results` 에서 «(합성) » 만 뺀 것).
abstract final class BackupRunTexts {
  /// 접수(지점 하나 만듦).
  static const String done = '이 폰 안에 복원 지점을 하나 만들었습니다.';

  /// 생체 없음.
  static const String biometric = '생체 확인이 없어 백업하지 않았습니다.';

  /// `X1_LIVE_ONLY`.
  static const String liveOnly = '모의투자 원장은 백업하지 않습니다. 실전 원장에서만 만듭니다.';

  /// `SNAPSHOT_NO_STAMP`.
  static const String noStamp = BackupScreenTexts.noStampNotice;

  /// `SNAPSHOT_EXISTS`.
  static const String exists = '같은 시각의 복원 지점이 이미 있습니다. 잠시 뒤 다시 눌러 주세요.';

  /// `RESTORE_UNREADABLE`.
  static const String unreadable = '만든 사본을 다시 읽지 못해 지웠습니다. 저장 공간을 확인해 주세요.';

  /// `RESTORE_SCHEMA_SKEW`.
  static const String schemaSkew = '장부 형식이 앱과 달라 백업을 멈췄습니다. 앱을 업데이트해 주세요.';

  /// `RESTORE_SQLITE_INTEGRITY`.
  static const String sqliteIntegrity = '장부 파일 점검에서 오류가 나와 백업을 멈췄습니다.';

  /// `RESTORE_CHAIN_INVALID`.
  static const String chainInvalid =
      '장부 사슬이 맞지 않아 백업을 멈췄습니다. 진단 화면에서 무결성을 확인해 주세요.';

  /// `RESTORE_ROLLBACK`.
  static const String rollback =
      '바깥 아카이브와 아직 맞춰지지 않아 백업을 미뤘습니다. 그날 아카이브가 끝난 뒤 다시 눌러 주세요.';
}

String _two(int n) => n.toString().padLeft(2, '0');

/// 한국 `MM-DD HH:mm`.
String _kstShort(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  return '${_two(k.month)}-${_two(k.day)} ${_two(k.hour)}:${_two(k.minute)}';
}

final RegExp _snapshotName = RegExp(
  r'^bk_(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})Z$',
);

/// 🔴 스냅숏 이름 = 만든 시각(UTC · 분) `bk_YYYYMMDDTHHmmZ` — 같은 분에 다시 누르면 `SNAPSHOT_EXISTS`(덮지 않는다).
String backupSnapshotNameOf(DateTime nowUtc) {
  final DateTime u = nowUtc.toUtc();
  return 'bk_${u.year.toString().padLeft(4, '0')}${_two(u.month)}${_two(u.day)}'
      'T${_two(u.hour)}${_two(u.minute)}Z';
}

/// 스냅숏 이름 → 만든 시각(UTC) · 이 꼴이 아니면 null(백업 지점이 아니다).
DateTime? backupSnapshotTimeOf(String name) {
  final RegExpMatch? m = _snapshotName.firstMatch(name);
  if (m == null) return null;
  final List<int> v = <int>[for (int i = 1; i <= 5; i++) int.parse(m[i]!)];
  final DateTime t = DateTime.utc(v[0], v[1], v[2], v[3], v[4]);
  // 달력에 없는 날(02-30 등)은 DateTime 이 넘겨 버린다 — 되쓴 이름이 같아야 지점이다.
  return backupSnapshotNameOf(t) == name ? t : null;
}

/// S09 복원 지점 사실 1(목록 함수가 매니페스트에서 읽는다).
final class BackupPointFacts {
  /// 만든다.
  const BackupPointFacts({
    required this.code,
    required this.createdAtUtc,
    required this.manifest,
  });

  /// 지점 코드(스냅숏 이름 · 화면 미참조).
  final String code;

  /// 만든 시각(이름).
  final DateTime createdAtUtc;

  /// 매니페스트(SPEC ⑧).
  final BackupManifest manifest;
}

/// S09 사실.
final class BackupScreenFacts {
  /// 만든다.
  const BackupScreenFacts({
    required this.liveLedger,
    required this.stamped,
    required this.archiveInSync,
    required this.archive,
    required this.points,
    required this.canRun,
    required this.migrationLinkable,
    required this.nowUtc,
    this.lockedLabel,
  });

  /// 화면 원장이 live 원장 파일이다(`application_id` — `take` 와 같은 판정).
  final bool liveLedger;

  /// 스탬프(`ledger_daily_hash`)가 하나라도 있다.
  final bool stamped;

  /// 정본 ↔ 아카이브 체크포인트 = `IN_SYNC`(`take` 와 같은 판정).
  final bool archiveInSync;

  /// 지금 아카이브 체크포인트(없음 = null · 지점 상태 줄 재료).
  final ArchiveCheckpoint? archive;

  /// 복원 지점(차례 무관 — 엔진이 새것부터 놓는다).
  final List<BackupPointFacts> points;

  /// «지금 백업»을 낼 창구가 있나(설정 동작 · 이 기기 id).
  final bool canRun;

  /// X1 기기 이전 화면 본문이 있나(조립 앱 레지스트리).
  final bool migrationLinkable;

  /// 지금(기준 줄 · 나이).
  final DateTime nowUtc;

  /// 운영 등급 생체 «보기만»(미결 169 · non-null ⇒ 버튼 · 링크 부재).
  final String? lockedLabel;
}

bool _sameHead(BackupManifest m, ArchiveCheckpoint? cp) =>
    cp != null &&
    m.authoredDate == cp.authoredDate &&
    m.chainHash == cp.chainHash &&
    m.operatorEpoch == cp.operatorEpoch;

/// 🔴 S09 VM.
BackupVm backupVmOf(BackupScreenFacts f) {
  final String day = kstDateText(f.nowUtc);
  final AsOf asOf = AsOf(
    observedAt: f.nowUtc.toUtc(),
    tradeDate: TradeDate(day),
    source: AsOfSource.localSqlite,
    staleAfter: kBackupScreenStaleAfter,
    label: '백업 기준 $day',
  );
  final bool locked = f.lockedLabel != null;
  if (!f.liveLedger) {
    return BackupVm(
      lastBackupText: BackupScreenTexts.simNever,
      level: UiLevel.info,
      noticeText: BackupScreenTexts.simNotice,
      lockedLabel: f.lockedLabel,
      points: const <RestorePointRow>[],
      pointsEmptyLabel: BackupScreenTexts.pointsEmpty,
      asOf: asOf,
    );
  }
  final List<BackupPointFacts> points = <BackupPointFacts>[...f.points]
    ..sort(
      (BackupPointFacts a, BackupPointFacts b) =>
          b.createdAtUtc.compareTo(a.createdAtUtc),
    );
  final BackupPointFacts? newest = points.isEmpty ? null : points.first;
  final bool takeable = f.stamped && f.archiveInSync;
  final bool stale =
      newest != null &&
      BackupAge(f.nowUtc.toUtc().difference(newest.createdAtUtc.toUtc())).stale;
  return BackupVm(
    lastBackupText: newest == null
        ? BackupScreenTexts.never
        : '${BackupScreenTexts.lastPrefix}${_kstShort(newest.createdAtUtc)}',
    ageBadgeText: stale && takeable ? BackupScreenTexts.ageBadge : null,
    level: newest == null
        ? UiLevel.info
        : stale
        ? UiLevel.watch
        : UiLevel.ok,
    noticeText: !f.stamped
        ? BackupScreenTexts.noStampNotice
        : !f.archiveInSync
        ? BackupScreenTexts.archiveWaitNotice
        : BackupScreenTexts.notice,
    runAction: takeable && f.canRun && !locked
        ? const SettingsActionCall(
            id: SettingsActionId.backupRunNow,
            args: <String, String>{},
            label: BackupScreenTexts.run,
          )
        : null,
    lockedLabel: f.lockedLabel,
    points: <RestorePointRow>[
      for (final BackupPointFacts p in points)
        RestorePointRow(
          code: p.code,
          label:
              '${_kstShort(p.createdAtUtc)} 만듦 · '
              '${p.manifest.authoredDate.substring(5)} 장부까지',
          chainHashText: p.manifest.chainHash.substring(0, 8),
          stateLabel: _sameHead(p.manifest, f.archive)
              ? BackupScreenTexts.pointVerified
              : null,
        ),
    ],
    pointsEmptyLabel: points.isEmpty ? BackupScreenTexts.pointsEmpty : null,
    migrationLink: f.migrationLinkable && !locked
        ? const LinkAction(
            label: BackupScreenTexts.migration,
            deepLink: AppRoutes.x1Migration,
          )
        : null,
    asOf: asOf,
  );
}

/// 🔴 «지금 백업» 결과 — [rejectCode] null = 접수(OK) · `take` 거부 코드 8 · 생체 = 표본 글자 · 그 밖 = [ArgumentError]
/// (`take` 에서 나올 수 없는 `RESTORE_SHA_MISMATCH` · `RESTORE_MANIFEST_MISMATCH` 포함 — K132 · 지어내지 않는다).
ActionResult backupRunResultOf({
  required String actionRunId,
  required String? rejectCode,
}) {
  final (UiLevel level, String headline) = switch (rejectCode) {
    null => (UiLevel.ok, BackupRunTexts.done),
    SettingsResultCodes.biometricUnavailable => (
      UiLevel.blocked,
      BackupRunTexts.biometric,
    ),
    MigrationStartCodes.liveOnly => (UiLevel.info, BackupRunTexts.liveOnly),
    SnapshotCodes.noStamp => (UiLevel.info, BackupRunTexts.noStamp),
    SnapshotCodes.exists => (UiLevel.info, BackupRunTexts.exists),
    _ when rejectCode == RestoreReason.unreadable.wire => (
      UiLevel.act,
      BackupRunTexts.unreadable,
    ),
    _ when rejectCode == RestoreReason.schemaSkew.wire => (
      UiLevel.act,
      BackupRunTexts.schemaSkew,
    ),
    _ when rejectCode == RestoreReason.sqliteIntegrity.wire => (
      UiLevel.blocked,
      BackupRunTexts.sqliteIntegrity,
    ),
    _ when rejectCode == RestoreReason.chainInvalid.wire => (
      UiLevel.blocked,
      BackupRunTexts.chainInvalid,
    ),
    _ when rejectCode == RestoreReason.rollback.wire => (
      UiLevel.watch,
      BackupRunTexts.rollback,
    ),
    _ => throw ArgumentError.value(rejectCode, 'rejectCode', '백업 결과 사전 밖'),
  };
  return ActionResult(
    actionRunId: actionRunId,
    id: SettingsActionId.backupRunNow,
    level: level,
    headline: headline,
    reasonCode: rejectCode,
    retryable: false,
  );
}
