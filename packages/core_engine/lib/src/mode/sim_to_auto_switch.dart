// simToAuto 전환 오케스트레이션 — 새 감시 체크 → 로컬 커밋(f3a) → 모의 마감(f3b) → 옛 체크 멈춤 · 보상 · 기동 보정
// (SPEC v2.44 04 :925 · 06 :242 · :312 · :331 · 설계 13 §8 R93 AE6 · R103 AI7 · R106 AK1~AK8).
//
// 🔴 새 체크 생성 · 재개만 커밋 조건이다 — 하나라도 실패하면 로컬 쓰기 0(되돌림 = 이번에 재개한 것만 다시 멈춤).
// 🔴 커밋 성공 뒤엔 되돌리지 않는다(실전 원장 = append-only) — 마감 · 옛 멈춤 실패는 «남음»으로 돌려주고 기동 때 다시.
// 🔴 커밋 콜백이 던지면(결과 모름) 보상하지 않는다 — 실제로 커밋됐다면 새 체크를 다시 멈추는 쪽이 더 위험(무감시).
// 🔴 로컬 커밋 · 마감은 콜백 — core 는 data_sync 를 보지 않는다(선례 `runOrderBatch`).

import '../ops/watchdog_ports.dart'
    show
        EnsuredCheck,
        PauseReason,
        RemoteCheck,
        RemoteCheckStatus,
        WatchdogCheckSpec,
        WatchdogRemote,
        kWatchdogPrefixes,
        watchdogPrefixOf;

/// 새 체크 준비(생성 · 재개 · 목록) 실패 — 전환하지 않았다.
const String kSimToAutoWatchdogPrepareFailed =
    'SIM_TO_AUTO_WATCHDOG_PREPARE_FAILED';

/// 커밋 콜백이 던졌다 — 결과를 모른다(보상하지 않았다).
const String kSimToAutoCommitUnknown = 'SIM_TO_AUTO_COMMIT_UNKNOWN';

/// 로컬 커밋 콜백의 결과(data_sync `SimToAutoCommitOutcome` 을 부르는 쪽이 옮겨 담는다).
class SimToAutoSwitchCommit {
  /// 커밋됐다.
  const SimToAutoSwitchCommit.ok(String this.decisionId, this.headline)
    : code = null;

  /// 거부 · 되돌림(로컬 쓰기 0).
  const SimToAutoSwitchCommit.no(String this.code, this.headline)
    : decisionId = null;

  /// 거부 코드(커밋 = null).
  final String? code;

  /// 실전 개시 결정 id(거부 = null).
  final String? decisionId;

  /// 엔진 문구.
  final String headline;
}

/// 어디까지 갔나.
enum SimToAutoSwitchStage {
  /// 새 체크 준비에서 멈췄다.
  prepare,

  /// 로컬 커밋에서 멈췄다.
  commit,

  /// 끝까지 갔다(마감 · 옛 멈춤은 남았을 수 있다).
  done,
}

/// 전환 결과(R106 AK7).
class SimToAutoSwitchResult {
  /// 결과를 만든다.
  const SimToAutoSwitchResult({
    required this.committed,
    required this.stage,
    required this.headline,
    this.code,
    this.decisionId,
    this.finishPending = false,
    this.pendingPauses = const <String>[],
    this.oldChecksUnknown = false,
  });

  /// 실전 커밋됐나.
  final bool committed;

  /// 어디까지 갔나.
  final SimToAutoSwitchStage stage;

  /// 엔진 문구.
  final String headline;

  /// 멈춘 사유 코드(끝까지 갔으면 null).
  final String? code;

  /// 실전 개시 결정 id.
  final String? decisionId;

  /// 모의 마감이 남았다(기동 복구가 마저 한다).
  final bool finishPending;

  /// 멈추지 못한 옛 체크(기동 보정이 다시 한다).
  final List<String> pendingPauses;

  /// 옛 체크 목록을 읽지 못했다(기동 보정이 다시 한다).
  final bool oldChecksUnknown;
}

/// 🔴 기동 보정(R106 AK6) — 지금 접두 [currentPrefix] 가 아닌 알려진 접두의 «멈추지 않은» 체크(슬러그 순).
List<String> pendingOldModePauses(
  List<RemoteCheck> remote, {
  required String currentPrefix,
}) {
  final Set<String> out = <String>{
    for (final RemoteCheck c in remote)
      if (c.status != RemoteCheckStatus.paused &&
          watchdogPrefixOf(c.slug) != null &&
          watchdogPrefixOf(c.slug) != currentPrefix)
        c.slug,
  };
  return out.toList()..sort();
}

/// 기동 보정 실행 — [remote] 의 [checks] 가운데 옛 접두 체크를 멈춘다 · 반환 = 멈추지 못한 슬러그(멱등).
Future<List<String>> repairOldModePauses(
  WatchdogRemote remote,
  List<RemoteCheck> checks, {
  required String currentPrefix,
}) async {
  final List<String> failed = <String>[];
  for (final String slug in pendingOldModePauses(
    checks,
    currentPrefix: currentPrefix,
  )) {
    try {
      await remote.pause(
        slug,
        reason: PauseReason.modeSwitchCommit,
        toPrefix: currentPrefix,
      );
    } on Object {
      failed.add(slug);
    }
  }
  return failed;
}

Future<void> _undoResumes(
  WatchdogRemote remote,
  List<String> resumed,
  String oldPrefix,
) async {
  for (final String slug in resumed) {
    try {
      await remote.pause(
        slug,
        reason: PauseReason.modeSwitchCommit,
        toPrefix: oldPrefix,
      );
    } on Object {
      // 되돌림 실패 = 둔다(재개된 new 체크는 첫 핑 전 경보 0 · 기동 보정이 다시 멈춘다).
    }
  }
}

const String _prepareFailedHeadline =
    '바깥 감시를 준비하지 못해 전환하지 않았습니다 — 바뀐 것은 없습니다. 잠시 뒤 다시 확정해 주세요.';
const String _commitUnknownHeadline =
    '확정 결과를 확인하지 못했습니다 — 앱을 다시 열어 상태를 확인해 주세요.';

/// 🔴 전환 실행(R106 AK1~AK5) — [newSpecs] = 새 접두 [newPrefix] 체크 스펙(`watchdogCheckSpecsFor`) ·
/// [oldPrefix] = 모의 접두 · [commit] = f3a 커밋 · [finish] = f3b 마감.
Future<SimToAutoSwitchResult> runSimToAutoSwitch({
  required WatchdogRemote remote,
  required List<WatchdogCheckSpec> newSpecs,
  required String newPrefix,
  required String oldPrefix,
  required Future<SimToAutoSwitchCommit> Function() commit,
  required Future<void> Function() finish,
}) async {
  if (!kWatchdogPrefixes.contains(newPrefix) ||
      !kWatchdogPrefixes.contains(oldPrefix) ||
      newPrefix == oldPrefix) {
    throw ArgumentError('접두가 틀렸다: $oldPrefix → $newPrefix');
  }
  for (final WatchdogCheckSpec s in newSpecs) {
    if (watchdogPrefixOf(s.slug) != newPrefix) {
      throw ArgumentError.value(s.slug, 'newSpecs', '새 접두가 아니다');
    }
  }

  // ① 새 체크 — 만들고(같으면 고침) 멈춰 있었으면 재개.
  final List<String> resumed = <String>[];
  try {
    for (final WatchdogCheckSpec s in newSpecs) {
      final EnsuredCheck e = await remote.ensure(s);
      if (e.check.status == RemoteCheckStatus.paused) {
        await remote.resume(s.slug, reason: PauseReason.modeSwitchCommit);
        resumed.add(s.slug);
      }
    }
  } on Object {
    await _undoResumes(remote, resumed, oldPrefix);
    return const SimToAutoSwitchResult(
      committed: false,
      stage: SimToAutoSwitchStage.prepare,
      code: kSimToAutoWatchdogPrepareFailed,
      headline: _prepareFailedHeadline,
    );
  }

  // ② 로컬 커밋(f3a).
  final SimToAutoSwitchCommit c;
  try {
    c = await commit();
  } on Object {
    return const SimToAutoSwitchResult(
      committed: false,
      stage: SimToAutoSwitchStage.commit,
      code: kSimToAutoCommitUnknown,
      headline: _commitUnknownHeadline,
    );
  }
  final String? rejected = c.code;
  if (rejected != null) {
    await _undoResumes(remote, resumed, oldPrefix);
    return SimToAutoSwitchResult(
      committed: false,
      stage: SimToAutoSwitchStage.commit,
      code: rejected,
      headline: c.headline,
    );
  }

  // ③ 모의 마감(f3b) — 실패 = 기동 복구가 마저 한다.
  bool finishPending = false;
  try {
    await finish();
  } on Object {
    finishPending = true;
  }

  // ④ 옛 체크 멈춤 — 실패 = 남음(기동 보정).
  List<String> pending = const <String>[];
  bool unknown = false;
  try {
    pending = await repairOldModePauses(
      remote,
      await remote.checks(),
      currentPrefix: newPrefix,
    );
  } on Object {
    unknown = true;
  }

  final StringBuffer h = StringBuffer(c.headline);
  if (finishPending) h.write(' 모의 기록 정리는 다음 시작 때 마저 합니다.');
  if (unknown || pending.isNotEmpty) {
    h.write(' 모의투자 감시 체크 일부를 멈추지 못해 다음 시작 때 다시 멈춥니다.');
  }
  return SimToAutoSwitchResult(
    committed: true,
    stage: SimToAutoSwitchStage.done,
    decisionId: c.decisionId,
    headline: h.toString(),
    finishPending: finishPending,
    pendingPauses: pending,
    oldChecksUnknown: unknown,
  );
}
