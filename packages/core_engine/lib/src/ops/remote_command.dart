// 🆕 E11m-a — 운영 폰 명령 소비기의 순수 몫(설계 13 §8 R274 · R272 Y4~Y6 · 01 §10-8 소비 규칙 · 계약 v1.41 §50
// `CommandReadRpcNames.open` · `CommandOpenColumns` · `CommandContextRejectCodes` · `ViewerCommandTtl`).
//
// 🔵 한 줄 = `command_open` 이 돌려준 `command_queue` 행 하나 → [RemoteCommand] → 갈래([routeRemoteCommand]):
//    집행(엔진 처리기 넷 — 킬스위치 · 사전 저널 · blind 점수 · 열람 기록) / 거부 · 만료(원장 쓰기 0 · ack 만) / 소비 0(운영 폰 종류).
// 🔴 실행 모드(`run_mode`) 불일치 = 예외 없이 거부(`RUN_MODE_MISMATCH` · 파일 경계는 협상 대상이 아니다 — 01 §10-8).
// 🔴 운영 방식 · 리스 세대 불일치 = 뷰어 4종엔 보류 0(R274 A3 — 네 명령의 뜻이 운영 방식 · 리스 세대에 달리지 않는다 ·
//    뷰어는 리스를 쥐지 않아 그 세대는 감사용 기록일 뿐 · 맥락은 수신함에 발행 시점 값 그대로 남는다).
// 🔴 만료 = 신뢰 시각으로만(모르면 만료로 치지 않는다 — 만료는 안전이 아니라 사실 손실 · ㊵) · 🔴 킬스위치는 만료로 버리지 않는다
//    (늦게 닿아도 멈춤 = 안전 쪽 · 결정 6 «끄기는 쉽게» · G-26 «요청됨»의 침묵이 가장 위험한 오인).
// 🔴 ack id = (명령 id · 상태)에서 정해지는 값 — 같은 상태 ack 를 다시 보내도 서버는 건너뛴다(append-only · `on conflict do nothing`) →
//    로컬 «보낸 ack» 표 0(보내기 실패 = 다음 당김이 같은 id 로 다시).
// 🔴 문구 = 엔진 글자([RemoteCommandTexts]) — 화면 · 뷰어는 짓지 않는다(뷰어는 `command_status` 가 준 `state_label` 을 그린다).

import 'dart:convert';

import 'package:crypto/crypto.dart' show sha256;
import 'package:domain_contracts/domain_contracts.dart';

/// 소비기 글자(엔진 · ack `state_label`).
abstract final class RemoteCommandTexts {
  /// 실행 모드 불일치 거부.
  static const String runModeMismatch =
      '거부됨 — 다른 실행 모드에서 낸 명령입니다(모의 · 실전 원장은 서로 닿지 않습니다 · 지금 모드에서 다시 내 주세요)';

  /// 내용을 읽을 수 없음.
  static const String inputInvalid =
      '거부됨 — 명령 내용을 읽을 수 없습니다(앱을 업데이트한 뒤 다시 내 주세요)';

  /// 만료.
  static const String expired = '만료됨 — 운영 폰이 받기 전에 유효 기간이 지났습니다(필요하면 다시 내 주세요)';

  /// 킬스위치 이력의 «누른 기기» 이름표(뷰어가 낸 발동).
  static const String viewerDevice = '뷰어 기기';
}

/// 원장 채널 규약(`kill_switch_event.channel`)의 뷰어 값.
const String kRemoteKillSwitchChannel = 'viewer';

/// `command_open` 행 하나(🔴 `payload` = 와이어 원문 · 기록 금지 — 수신함 = 지문만).
class RemoteCommand {
  /// 만든다(시험 · [remoteCommandOf]).
  const RemoteCommand({
    required this.commandId,
    required this.kindWire,
    required this.payload,
    required this.issuedByDevice,
    required this.nonce,
    required this.requestedAt,
    required this.expiresAt,
    required this.runModeWire,
    required this.operatingModeWire,
    required this.leaseEpoch,
  });

  /// 명령 id(uuid 글자).
  final String commandId;

  /// `command_queue.kind` 글자.
  final String kindWire;

  /// 와이어 본문.
  final Map<String, Object?> payload;

  /// 낸 기기 id.
  final String issuedByDevice;

  /// 1회용 값.
  final String nonce;

  /// 낸 시각(서버 now() · v1.41 `requested_at = now()`) · 만료 시각(UTC).
  final DateTime requestedAt, expiresAt;

  /// 발행 시점 맥락(v1.41 not null + check — 그래도 모르는 글자면 null 로 읽힌다).
  final String? runModeWire, operatingModeWire;

  /// 발행 시점 리스 세대(뷰어 = 본 운영 리스 세대 · 감사용).
  final int? leaseEpoch;

  /// 종류(모르는 글자 = null).
  CommandKind? get kind {
    for (final CommandKind k in CommandKind.values) {
      if (k.wire == kindWire) return k;
    }
    return null;
  }

  /// 발행 시점 실행 모드(모르는 글자 = null).
  RunMode? get runMode {
    for (final RunMode m in RunMode.values) {
      if (m.wire == runModeWire) return m;
    }
    return null;
  }

  /// 발행 시점 운영 방식(모르는 글자 = null).
  OperatingMode? get operatingMode {
    for (final OperatingMode m in OperatingMode.values) {
      if (m.wire == operatingModeWire) return m;
    }
    return null;
  }

  @override
  String toString() => 'RemoteCommand($kindWire · ${runModeWire ?? '?'})';
}

DateTime? _time(Object? v) {
  if (v is! String) return null;
  final DateTime? t = DateTime.tryParse(v);
  // 🔴 시차 없는 글자(isUtc = false) = 기기 지역 시각으로 읽혀 만료가 밀린다 → 읽지 않는다.
  if (t == null || !t.isUtc) return null;
  return t;
}

String? _text(Object? v) => v is String && v.isNotEmpty ? v : null;

/// 🆕 `command_open` 행([CommandOpenColumns]) → [RemoteCommand] — 꼴이 아니면 null(그 행은 ack 를 지을 수 없다 · 수만 센다).
RemoteCommand? remoteCommandOf(Map<String, Object?> row) {
  final String? id = _text(row['command_id']);
  final String? kind = _text(row['kind']);
  final String? device = _text(row['issued_by_device']);
  final String? nonce = _text(row['nonce']);
  final DateTime? requested = _time(row['requested_at']);
  final DateTime? expires = _time(row['expires_at']);
  final Object? payload = row['payload'];
  final Object? epoch = row['lease_epoch'];
  if (id == null ||
      kind == null ||
      device == null ||
      nonce == null ||
      requested == null ||
      expires == null ||
      payload is! Map<String, Object?> ||
      (epoch != null && epoch is! int)) {
    return null;
  }
  return RemoteCommand(
    commandId: id,
    kindWire: kind,
    payload: payload,
    issuedByDevice: device,
    nonce: nonce,
    requestedAt: requested,
    expiresAt: expires,
    runModeWire: _text(row['run_mode']),
    operatingModeWire: _text(row['operating_mode']),
    leaseEpoch: epoch as int?,
  );
}

/// 와이어 JSON 의 SHA-256 16진(폰이 직접 낸 명령과 같은 식 — `command_inbox.payload_digest`).
String remotePayloadDigest(Map<String, Object?> wire) =>
    sha256.convert(utf8.encode(jsonEncode(wire))).toString();

/// 갈래.
sealed class RemoteCommandRoute {
  const RemoteCommandRoute();
}

/// 엔진 처리기로 집행(각 처리기가 수신함 · 원장을 한 트랜잭션으로 쓴다).
sealed class RemoteCommandExecute extends RemoteCommandRoute {
  const RemoteCommandExecute(this.payloadDigest);

  /// `command_inbox.payload_digest`.
  final String payloadDigest;
}

/// 킬스위치 발동(인자 0 — 기기 · 채널 = 소비기).
final class RemoteKillSwitch extends RemoteCommandExecute {
  /// 만든다.
  const RemoteKillSwitch(super.payloadDigest);
}

/// 사전 저널(`J-3` 와이어).
final class RemoteJournalDraft extends RemoteCommandExecute {
  /// 만든다.
  const RemoteJournalDraft(this.draft, super.payloadDigest);

  /// 와이어.
  final JournalDraft draft;
}

/// blind 리뷰 점수(`J-4` 와이어).
final class RemoteBlindReviewScore extends RemoteCommandExecute {
  /// 만든다.
  const RemoteBlindReviewScore(this.score, super.payloadDigest);

  /// 와이어.
  final BlindReviewScore score;
}

/// 열람 기록(`S7-2G` 와이어).
final class RemoteDisclosureView extends RemoteCommandExecute {
  /// 만든다.
  const RemoteDisclosureView(this.event, super.payloadDigest);

  /// 와이어.
  final DisclosureViewEvent event;
}

/// 집행하지 않고 종단 ack 만(원장 쓰기 0 · 수신함 쓰기 0 — 같은 판정을 다음 당김이 다시 낸다).
final class RemoteCommandRefuse extends RemoteCommandRoute {
  /// 만든다.
  const RemoteCommandRefuse(this.state, this.stateLabel, this.reasonCode);

  /// `REJECTED` · `EXPIRED`.
  final CommandState state;

  /// 엔진 글자.
  final String stateLabel;

  /// 거부 코드(`EXPIRED` = null).
  final String? reasonCode;
}

/// 소비 0 — 뷰어 4종 밖(운영 폰 종류 · 모르는 종류). 🔴 ack 0(운영 폰 명령을 넣는 코드 0 · 소비 규칙 = 그 종류를 소비할 때 정한다).
final class RemoteCommandSkip extends RemoteCommandRoute {
  /// 만든다.
  const RemoteCommandSkip();
}

RemoteCommandRefuse _refuse(String code, String label) =>
    RemoteCommandRefuse(CommandState.rejected, label, code);

const RemoteCommandRefuse _invalid = RemoteCommandRefuse(
  CommandState.rejected,
  RemoteCommandTexts.inputInvalid,
  AdviceRejectCodes.inputInvalid,
);

/// 🆕 한 명령의 갈래 — [runMode] = 지금(소비 시점) 실행 모드 · [trustedNowUtc] = 신뢰 시각(모르면 null = 만료 판정 0).
RemoteCommandRoute routeRemoteCommand(
  RemoteCommand c, {
  required RunMode runMode,
  required DateTime? trustedNowUtc,
}) {
  final CommandKind? kind = c.kind;
  if (kind == null || !ViewerCommandTtl.kinds.contains(kind)) {
    return const RemoteCommandSkip();
  }
  // ① 파일 경계 — 모르는 글자도 «다름»(v1.41 check 가 막지만 계약 밖 글자를 같은 모드로 치지 않는다).
  if (c.runMode != runMode) {
    return _refuse(
      CommandContextRejectCodes.runModeMismatch,
      RemoteCommandTexts.runModeMismatch,
    );
  }
  // ①b 기록 셋은 발행 시점 운영 방식을 수신함에 그대로 남긴다 — 모르는 글자면 남길 값이 없다(v1.41 check 가 막는 자리).
  if (kind != CommandKind.killSwitchActivate && c.operatingMode == null) {
    return _invalid;
  }
  // ② 만료 — 킬스위치 제외 · 신뢰 시각으로만.
  final DateTime? now = trustedNowUtc?.toUtc();
  if (kind != CommandKind.killSwitchActivate &&
      now != null &&
      !c.expiresAt.isAfter(now)) {
    return const RemoteCommandRefuse(
      CommandState.expired,
      RemoteCommandTexts.expired,
      null,
    );
  }
  // ③ 와이어 → 처리기 인자(꼴 아님 = INPUT_INVALID).
  final String digest = remotePayloadDigest(c.payload);
  try {
    switch (kind) {
      case CommandKind.killSwitchActivate:
        return RemoteKillSwitch(digest);
      case CommandKind.journalDraft:
        final JournalDraft d = JournalDraft.fromJson(c.payload);
        return RemoteJournalDraft(d, remotePayloadDigest(d.toJson()));
      case CommandKind.blindReviewScore:
        final BlindReviewScore s = BlindReviewScore.fromJson(c.payload);
        return RemoteBlindReviewScore(s, remotePayloadDigest(s.toJson()));
      case CommandKind.disclosureView:
        final DisclosureViewEvent e = DisclosureViewEvent.fromJson(c.payload);
        if (!DisclosureSurfaceCodes.values.contains(e.surfaceCode)) {
          return _invalid;
        }
        return RemoteDisclosureView(e, remotePayloadDigest(e.toJson()));
      // 뷰어 4종 밖은 위에서 걸렀다 — 전수 나열(C-12 결 · 새 종류 = 컴파일 실패).
      case CommandKind.depositRegister ||
          CommandKind.manualFillRecord ||
          CommandKind.manualFillAmend ||
          CommandKind.manualFillVoid ||
          CommandKind.adviceSkip ||
          CommandKind.selfReportBalance ||
          CommandKind.alertAck ||
          CommandKind.killChecklistConfirm ||
          CommandKind.ledgerEventRecord ||
          CommandKind.adviceDeferConfirm:
        return const RemoteCommandSkip();
    }
  } on Object {
    return _invalid;
  }
}

/// 🆕 ack id — (명령 id · 상태)에서 정해지는 uuid 꼴(같은 상태 = 같은 id → 다시 보내도 서버가 건너뛴다).
String commandAckId(String commandId, CommandState state) {
  final List<int> h = sha256
      .convert(utf8.encode('aaq.command_ack.v1|$commandId|${state.wire}'))
      .bytes;
  final List<int> b = h.sublist(0, 16);
  b[6] = (b[6] & 0x0f) | 0x80; // 판 8(정해진 해시 기반 — RFC 9562 사용자 정의)
  b[8] = (b[8] & 0x3f) | 0x80; // 변형 RFC
  final String x = b.map((int v) => v.toRadixString(16).padLeft(2, '0')).join();
  return '${x.substring(0, 8)}-${x.substring(8, 12)}-${x.substring(12, 16)}-'
      '${x.substring(16, 20)}-${x.substring(20)}';
}

/// 🆕 `command_ack` 한 행(op_push 본문 — `lease_epoch` · `acked_at` = 서버가 덮는다 · 🔴 서버 판정 두 상태 = 만들지 않는다).
Map<String, Object?> commandAckRow({
  required String commandId,
  required CommandState state,
  required String stateLabel,
  String? rejectReasonCode,
  String? decisionId,
}) {
  if (state == CommandState.requested ||
      state == CommandState.noOperator ||
      state == CommandState.pendingLeaseConfirm) {
    // v1.41 K356 결 — 리스 보유자가 쓸 수 없는 상태(서버도 `OPS_PUSH_ROWS_INVALID`).
    throw ArgumentError.value(state.wire, 'state', 'ack 로 쓸 수 없는 상태');
  }
  return <String, Object?>{
    'ack_id': commandAckId(commandId, state),
    'command_id': commandId,
    'state': state.wire,
    'state_label': stateLabel,
    'reject_reason_code': rejectReasonCode,
    'decision_id': decisionId,
  };
}
