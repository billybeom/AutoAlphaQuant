// 🆕 E11m-a — 운영 폰 명령 소비 일(설계 13 §8 R274 · R272 Y4~Y6 · 01 §10-8 · 01 §8 미결 244 ⓒ · 계약 v1.41 §50).
//
// 🔵 한 번 = ① 리스 원격 확인(쥔 기기만 소비 주체) → ② `command_open`(종단 ack 없는 명령 · 킬스위치 먼저) → ③ 명령마다:
//    수신함에 이미 있음 = 그 상태 그대로(보관된 저널 · blind 점수 = 처리기를 다시 불러 무결성 풀림이면 집행) /
//    없음 = 갈래(`routeRemoteCommand`) → 엔진 처리기 넷(킬스위치 · 사전 저널 · blind 점수 · 열람 기록 — 폰 버튼과 같은 처리기 ·
//    같은 원장 한 트랜잭션 · 뷰어 `command_id` 그대로 = 수신함 PK 멱등) · 거부 · 만료 = 원장 쓰기 0 · 운영 폰 종류 = 소비 0 →
//    ④ ack = 명령마다 지금 상태 한 행(`commandAckRow` · id = (명령 · 상태)에서 정해짐) → `op_push` `command_ack`(K356 — 한 호출 한 명령 한 행).
// 🔴 ack 보내기 실패 = 다음 당김이 같은 id 로 다시(서버 = 건너뜀) — 로컬 «보낸 ack» 표 0 · 종단 ack 가 서버에 들어가야 당김에서 빠진다.
// 🔴 리스 = 쥔 기기만(`LeaseVerdict.valid`) · 아니면 당기지 않는다(소비 주체 아님 · 뷰어 = `command_status` 가 NO_OPERATOR 판정).
// 🔴 [CommandConsumeReport.blocksOrders] = 리스는 쥐었는데 명령 표를 못 읽음 — 주문 잡은 이 깨어남에 돌지 않는다(R274 A5 · R272 Y6 ⓑ).
// 🔴 행 값 · 본문 · 토큰은 어떤 문자열에도 나오지 않는다(보고 = 수만).

import 'package:core_engine/core_engine.dart'
    show
        DisclosureViewCommand,
        ExchangeCalendar,
        LeaseVerdict,
        OrderBroker,
        RemoteBlindReviewScore,
        RemoteCommand,
        RemoteCommandRefuse,
        RemoteCommandRoute,
        RemoteCommandSkip,
        RemoteCommandTexts,
        RemoteDisclosureView,
        RemoteJournalDraft,
        RemoteKillSwitch,
        TrustedClock,
        commandAckRow,
        kRemoteKillSwitchChannel,
        remoteCommandOf,
        routeRemoteCommand;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, CommandState, OpsPushTables, RunMode;
import 'package:sqlite3/sqlite3.dart';

import '../local/blind_review_store.dart';
import '../local/journal_draft_store.dart';
import '../local/journal_source.dart';
import '../local/kill_switch_store.dart';
import '../local/performance_source.dart';
import '../supabase/supabase_command_open.dart';
import '../supabase/supabase_ops_push.dart';
import 'ops_push_send.dart';

/// 소비를 끝까지 못 한 까닭(🔴 [pullFailed] 만 주문 잡을 막는다).
enum CommandConsumeStop {
  /// 기기 id 없음(첫 클레임 전).
  noDevice,

  /// 원격 리스 세대 0(첫 클레임 전 · 모의 내부).
  noEpoch,

  /// 이 기기가 리스를 쥐지 않았다(소비 주체 아님).
  leaseNotHeld,

  /// 리스를 모른다(주문 잡은 자기 리스 판정이 막는다).
  leaseUnknown,

  /// 리스는 쥐었는데 명령 표를 못 읽었다.
  pullFailed,
}

/// 한 번의 보고(🔴 행 값 0 · 수만).
class CommandConsumeReport {
  /// 만든다.
  const CommandConsumeReport({
    this.stop,
    this.pullFailure,
    this.pulled = 0,
    this.malformed = 0,
    this.skipped = 0,
    this.executed = 0,
    this.held = 0,
    this.refused = 0,
    this.localFailed = 0,
    this.killSwitchExecuted = 0,
    this.acks,
  });

  /// 끝까지 못 한 까닭(null = 당겨서 다 봤다).
  final CommandConsumeStop? stop;

  /// 당김 실패 까닭([CommandConsumeStop.pullFailed] 일 때).
  final CommandOpenFailure? pullFailure;

  /// 받은 행 · 꼴 아님 · 소비 0(운영 폰 종류) · 이번에 집행 · 보관(무결성) · 거부 · 만료 · 처리기가 던짐.
  final int pulled, malformed, skipped, executed, held, refused, localFailed;

  /// 이번에 집행된 킬스위치 발동 수(FGS · 화면 상태 = 같은 깨어남 뒤 칸이 다시 읽는다).
  final int killSwitchExecuted;

  /// `command_ack` 보내기(보낼 행이 없었으면 null).
  final OpsTablePush? acks;

  /// 🔴 주문 잡을 이 깨어남에 돌리지 않는다 — 리스는 쥐었는데 명령 표를 못 읽음(뷰어 킬스위치가 주문 전에 닿는다는 보장).
  bool get blocksOrders => stop == CommandConsumeStop.pullFailed;

  @override
  String toString() =>
      'CommandConsumeReport(${stop?.name ?? 'OK'}'
      '${pullFailure == null ? '' : ' ${pullFailure!.name}'} · 받음 $pulled · 집행 $executed · 보관 $held · '
      '거부 $refused · 소비 0 $skipped · 꼴 아님 $malformed · 실패 $localFailed · ack ${acks ?? '-'})';
}

class _Inbox {
  const _Inbox(this.state, this.label, this.reason, this.decisionId);
  final CommandState state;
  final String label;
  final String? reason, decisionId;
}

/// 🆕 명령 소비 일 — 원장 = [_db](지금 실행 모드의 원장) · 당김 = [reader] · ack = [pusher].
class CommandConsumeJob {
  /// 만든다 — [kr] = blind 리뷰 카드 원천(판정 재료) · [trusted] = 만료 판정 · 킬스위치 시각.
  CommandConsumeJob(
    this._db, {
    required this.clock,
    required this.trusted,
    required this.kr,
    required this.reader,
    required this.pusher,
    Map<String, OrderBroker> killSwitchBrokers = const <String, OrderBroker>{},
  }) : _brokers = killSwitchBrokers;

  final Database _db;

  /// 기기 시계(수신 시각 · 열람 집계 달).
  final Clock clock;

  /// 신뢰 시각.
  final TrustedClock trusted;

  /// 거래소 달력(한국).
  final ExchangeCalendar kr;

  /// 당김.
  final CommandOpenReader reader;

  /// ack 보내기.
  final OpsPusher pusher;

  /// 🔴 킬스위치 미체결 취소 경로 — 폰 버튼과 같은 값(지금 = 비움 · 실계좌 취소 = 트랙 C).
  final Map<String, OrderBroker> _brokers;

  /// 🆕 한 번 소비 — [deviceId] · [epoch] = 이 기기 · 그 원장의 원격 리스 세대 · [runMode] = 지금 실행 모드 · [lease] = 원격 확인.
  Future<CommandConsumeReport> run({
    required String? deviceId,
    required int epoch,
    required RunMode runMode,
    required Future<LeaseVerdict> Function() lease,
  }) async {
    if (deviceId == null || deviceId.isEmpty) {
      return const CommandConsumeReport(stop: CommandConsumeStop.noDevice);
    }
    if (epoch < 1) {
      return const CommandConsumeReport(stop: CommandConsumeStop.noEpoch);
    }
    final LeaseVerdict verdict;
    try {
      verdict = await lease();
    } on Object {
      return const CommandConsumeReport(stop: CommandConsumeStop.leaseUnknown);
    }
    switch (verdict) {
      case LeaseVerdict.valid:
        break;
      case LeaseVerdict.invalid:
        return const CommandConsumeReport(
          stop: CommandConsumeStop.leaseNotHeld,
        );
      case LeaseVerdict.unknown:
        return const CommandConsumeReport(
          stop: CommandConsumeStop.leaseUnknown,
        );
    }
    final CommandOpenResult pulled;
    try {
      pulled = await reader.open();
    } on Object {
      return const CommandConsumeReport(
        stop: CommandConsumeStop.pullFailed,
        pullFailure: CommandOpenFailure.badResponse,
      );
    }
    final List<Map<String, Object?>>? rows = pulled.rows;
    if (rows == null) {
      return CommandConsumeReport(
        stop: CommandConsumeStop.pullFailed,
        pullFailure: pulled.failure,
      );
    }
    int malformed = 0, skipped = 0, executed = 0, held = 0, refused = 0;
    int failed = 0, kills = 0;
    final List<Map<String, Object?>> acks = <Map<String, Object?>>[];
    final Set<String> seen = <String>{};
    for (final Map<String, Object?> row in rows) {
      final RemoteCommand? c = remoteCommandOf(row);
      // 같은 id 두 번 = 한 번만(K356 — 한 호출에 같은 명령 두 번 = 서버 거부).
      if (c == null || !seen.add(c.commandId)) {
        malformed++;
        continue;
      }
      final RemoteCommandRoute route = routeRemoteCommand(
        c,
        runMode: runMode,
        trustedNowUtc: trusted.trustedNowUtc(),
      );
      if (route is RemoteCommandSkip) {
        skipped++;
        continue;
      }
      if (route is RemoteCommandRefuse) {
        refused++;
        acks.add(
          commandAckRow(
            commandId: c.commandId,
            state: route.state,
            stateLabel: route.stateLabel,
            rejectReasonCode: route.reasonCode,
          ),
        );
        continue;
      }
      final _Inbox? before = _inbox(c.commandId);
      _Inbox? after = before;
      // 처음 · 보관(무결성)된 기록 둘 = 처리기를 부른다(보관 = 처리기가 풀림을 보고 집행하거나 그대로 둔다) ·
      // 🆕 R280(K319) — `M5-13` 일괄 확정이 `RECEIVED` 로 옮긴 행도 같다(보통 소비 규칙).
      final bool call =
          before == null ||
          ((before.state == CommandState.heldForIntegrity ||
                  before.state == CommandState.received) &&
              (route is RemoteJournalDraft || route is RemoteBlindReviewScore));
      if (call) {
        try {
          await _execute(c, route);
        } on Object {
          // 처리기가 던짐 = 수신함 0(한 트랜잭션) → ack 0 · 다음 당김에 다시.
          failed++;
          continue;
        }
        after = _inbox(c.commandId);
      }
      if (after == null) {
        failed++;
        continue;
      }
      if (after.state == CommandState.heldForIntegrity) held++;
      if (before?.state != after.state &&
          after.state == CommandState.executed) {
        executed++;
        if (route is RemoteKillSwitch) kills++;
      }
      acks.add(
        commandAckRow(
          commandId: c.commandId,
          state: after.state,
          stateLabel: after.label,
          rejectReasonCode: after.reason,
          decisionId: after.decisionId,
        ),
      );
    }
    final OpsTablePush? sent = acks.isEmpty
        ? null
        : await sendOpsRows(
            pusher,
            deviceId: deviceId,
            epoch: epoch,
            table: OpsPushTables.commandAck,
            rows: acks,
          );
    return CommandConsumeReport(
      pulled: rows.length,
      malformed: malformed,
      skipped: skipped,
      executed: executed,
      held: held,
      refused: refused,
      localFailed: failed,
      killSwitchExecuted: kills,
      acks: sent,
    );
  }

  _Inbox? _inbox(String commandId) {
    final ResultSet rs = _db.select(
      'SELECT state, state_label, reject_reason_code, decision_id FROM command_inbox WHERE command_id = ?',
      <Object?>[commandId],
    );
    if (rs.isEmpty) return null;
    final Row r = rs.first;
    final CommandState? s = _stateOf(r['state']);
    if (s == null) return null;
    return _Inbox(
      s,
      r['state_label'] as String,
      r['reject_reason_code'] as String?,
      r['decision_id'] as String?,
    );
  }

  static CommandState? _stateOf(Object? wire) {
    for (final CommandState s in CommandState.values) {
      if (s.wire == wire) return s;
    }
    return null;
  }

  Future<void> _execute(RemoteCommand c, RemoteCommandRoute route) async {
    final RunMode runMode = c.runMode!; // 갈래가 지금 모드와 같음을 봤다.
    switch (route) {
      case RemoteKillSwitch():
        await SqliteKillSwitchStore(
          _db,
          clock: clock,
          trusted: trusted,
        ).activateLocal(
          commandId: c.commandId,
          payloadDigest: route.payloadDigest,
          brokers: _brokers,
          channel: kRemoteKillSwitchChannel,
          deviceLabel: RemoteCommandTexts.viewerDevice,
        );
      case RemoteJournalDraft():
        SqliteJournalDraftStore(_db, clock: clock).submit(
          commandId: c.commandId,
          payloadDigest: route.payloadDigest,
          draft: route.draft,
          runMode: runMode,
          operatingMode: c.operatingMode!,
          leaseEpoch: c.leaseEpoch,
        );
      case RemoteBlindReviewScore():
        SqliteBlindReviewStore(
          _db,
          // 카드 = 판정 재료(문항 · 선택지 · 결정 키)뿐 — 폰 버튼과 같은 조립(링크 · 계좌 이름표는 판정에 쓰지 않는다).
          source: SqliteJournalSource(
            _db,
            clock: clock,
            kr: kr,
            runMode: runMode,
            accountLabels: const <String, String>{},
            hasBody: (String _) => false,
          ),
          clock: clock,
        ).submit(
          commandId: c.commandId,
          payloadDigest: route.payloadDigest,
          score: route.score,
          runMode: runMode,
          operatingMode: c.operatingMode!,
          leaseEpoch: c.leaseEpoch,
        );
      case RemoteDisclosureView():
        SqlitePerformanceSource(_db, clock: clock).record(
          DisclosureViewCommand(
            commandId: c.commandId,
            nonce: c.nonce,
            requestedAt: c.requestedAt,
            expiresAt: c.expiresAt,
            event: route.event,
            deviceId: c.issuedByDevice,
          ),
          runMode: runMode,
          operatingMode: c.operatingMode!,
          leaseEpoch: c.leaseEpoch,
        );
      case RemoteCommandRefuse() || RemoteCommandSkip():
        throw StateError('집행 갈래가 아니다');
    }
  }
}
