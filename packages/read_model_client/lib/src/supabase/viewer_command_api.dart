// 🆕 R277(설계 13 §8 R277 VC3~VC8 · R272 Y7 · 계약 v1.41 §50 K364 · K366 · K367 · K370 · 01 §10-8 G-26) — 뷰어 `CommandApi`(E11m-b).
//
// 🔵 흐름 = 뷰어 4종(킬스위치 · 사전 저널 · blind 점수 · 열람 기록)을 `command_queue` 에 PostgREST 로 한 행 넣고(배치 D
//    `command_insert_viewer`) · 상태는 서버 판정 함수 `command_status` 를 보는 동안만 주기로 읽는다(K364 · NO_OPERATOR = 서버 now()).
// 🔴 맥락(`CommandContext` 4칸)은 화면이 아니라 여기서 싣는다(G-19) — 실행 모드 · 운영 방식 = 그 화면 모드의 `rm_config_view` 행 ·
//    리스 세대 = `operator_lease.epoch`(행 0 = 0 — 첫 클레임 전 · 뷰어 세대 = 감사용 · R274 A3) · 기기 = 세션 · 소유자 = 자기 기기 행.
//    🔴 화면 모드가 곧 명령이 닿는 원장이다(소비기 = 실행 모드 불일치 예외 없이 거부 · 킬스위치 포함) → 화면 모드 원천 = 01 §8 미결 252.
// 🔴 `requested_at` 은 보내지 않는다(v1.41 K369 — 정책 `requested_at = now()` · 서버 기본값) · 접수증 시각 = 돌려받은 행의 서버 시각
//    (`Prefer: return=representation` · RLS `command_select_own` 이 RETURNING 을 통과시킨다).
// 🔴 큐 없음(K370 · v1) — 실패 = `Future` 에러 [ViewerCommandFailure] = «접수 실패»(조용한 유실 0 · «전송 대기»가 «껐다»로 읽히는 오인 0) ·
//    `LocalCommandQueue` 무변경. 망 · 5xx = **같은 본문** 한 번 더(같은 명령 id · nonce) → 409 = 앞 시도가 닿았다 = 그 행을 읽어 접수증.
// 🔴 폐기 판정 = 자기 기기 행(행 0 · ACTIVE viewer 아님)으로만 — HTTP 상태로 코드를 짓지 않는다(K365) → `PAIRING_TOKEN_REVOKED`.
// 🔴 나머지 메서드(운영 폰 전용 — 입금 등록 · X7 · 알림 확인 · 기록 확인 · 원장 사건 · 내일 다시) = `UnsupportedError`(RLS 도 막는다).
// 🔴 글자 = 서버 판정 두 상태만 계약 카탈로그 `CommandStatusText` · 그 밖 = 최신 ack 의 엔진 글자 그대로(이 구현이 문장을 짓지 않는다).

import 'dart:async';
import 'dart:math';

import 'package:domain_contracts/domain_contracts.dart'
    show
        AdviceSkipSubmission,
        BlindReviewScore,
        CommandApi,
        CommandKind,
        CommandOpenColumns,
        CommandReadRpcNames,
        CommandReadRpcParams,
        CommandReceipt,
        CommandState,
        CommandStateMachine,
        CommandStatusColumns,
        CommandStatusText,
        DepositRegistration,
        DisclosureViewEvent,
        JournalDraft,
        KillChecklistSubmission,
        LedgerEventRecord,
        ManualFillAmendment,
        ManualFillSubmission,
        ManualFillVoid,
        OnboardingResultCodes,
        OperatingMode,
        RunMode,
        SelfReportSubmission,
        ViewerCommandTtl;

import 'viewer_rest.dart';

/// 배치 D 표 이름(계약 `ddl/batch_d_supabase.sql` — 시험이 원문과 대조).
const String _kCommandTable = 'command_queue';
const String _kDeviceTable = 'app_device';
const String _kLeaseTable = 'operator_lease';
const String _kConfigTable = 'rm_config_view';

/// 접수 실패 · 읽기 실패 까닭.
enum ViewerCommandFailureKind {
  /// 주소 · 공개 키 · 기기 id 없음(페어링 전).
  notPaired,

  /// 접근 토큰 없음(세션 없음 · 새로고침 실패).
  notSignedIn,

  /// 이 기기가 ACTIVE 뷰어가 아니다(폐기 · 행 0) — 페어링 다시(V-01 · `PAIRING_TOKEN_REVOKED`).
  revoked,

  /// 맥락 값을 정하지 못했다(그 모드 `rm_config_view` 행 없음 · 둘 · 모르는 글자 · 리스 행 꼴 아님).
  context,

  /// 401 · 403(토큰을 새로 받아 한 번 더 해도 · 기기는 ACTIVE).
  unauthorized,

  /// 서버 오류(5xx · 한 번 더 해도).
  server,

  /// 그 밖의 HTTP · 응답 꼴(함수 · 표 없음 = 404 포함).
  badResponse,

  /// 망 · 시간 초과(한 번 더 해도).
  network,
}

/// 뷰어 명령 «접수 실패» — 명령 메서드 `Future` 에러 · [CommandApi.watchCommand] 스트림 에러.
/// 🔴 토큰 · 주소 · 행 값 · 기기 id 0.
final class ViewerCommandFailure implements Exception {
  /// 만든다.
  const ViewerCommandFailure(this.kind, {this.statusCode});

  /// 까닭.
  final ViewerCommandFailureKind kind;

  /// HTTP 상태(있을 때).
  final int? statusCode;

  /// 계약 코드 — 폐기 = `OnboardingResultCodes.pairingTokenRevoked` · 그 밖 = null(상태 코드로 짓지 않는다 · K365).
  String? get reasonCode => kind == ViewerCommandFailureKind.revoked
      ? OnboardingResultCodes.pairingTokenRevoked
      : null;

  @override
  String toString() =>
      'ViewerCommandFailure(${kind.name}'
      '${statusCode == null ? '' : ' · $statusCode'})';
}

/// 명령 하나의 맥락(발행 시점).
typedef _Context = ({
  String deviceId,
  String ownerUid,
  RunMode runMode,
  OperatingMode operatingMode,
  int leaseEpoch,
});

/// 🆕 뷰어 명령 창구(E11m-b) — 원천 = [ViewerRest](같은 세션).
final class ViewerCommandApi implements CommandApi {
  /// 만든다 — [mode] = 화면 모드(조립 앱이 정한다 · `ViewerReadModels.mode` 와 같은 값) · [random] = 명령 id · nonce 원천
  /// (기본 `Random.secure()`) · [clock] = 만료 시각 원천(기기 시계 · TTL 일 단위라 시차 무관) · [pollInterval] = 상태 읽기 간격.
  ViewerCommandApi(
    this._rest, {
    required this.mode,
    Random? random,
    DateTime Function()? clock,
    this.pollInterval = const Duration(seconds: 15),
  }) : _random = random ?? Random.secure(),
       _clock = clock ?? DateTime.now;

  final ViewerRest _rest;
  final Random _random;
  final DateTime Function() _clock;

  /// 화면 모드 — 맥락을 읽는 `rm_config_view` 행.
  final RunMode mode;

  /// [watchCommand] 의 `command_status` 읽기 간격(보는 동안만).
  final Duration pollInterval;

  /// 이 인스턴스가 낸 명령의 접수증(명령 id → 접수증 · [watchCommand] 첫 값).
  final Map<String, CommandReceipt> _issued = <String, CommandReceipt>{};

  // ───── 뷰어 4종 ─────

  /// 인자 0 · 본문 = 빈 객체(운영 폰 발동과 같은 본문 · 소비기 = 지문만).
  @override
  Future<CommandReceipt> activateKillSwitch() =>
      _issue(CommandKind.killSwitchActivate, const <String, Object?>{});

  @override
  Future<CommandReceipt> submitJournalDraft(JournalDraft draft) =>
      _issue(CommandKind.journalDraft, draft.toJson());

  @override
  Future<CommandReceipt> submitBlindReviewScore(BlindReviewScore score) =>
      _issue(CommandKind.blindReviewScore, score.toJson());

  @override
  Future<CommandReceipt> recordDisclosureView(DisclosureViewEvent event) =>
      _issue(CommandKind.disclosureView, event.toJson());

  // ───── 운영 폰 전용 — 뷰어 경로 없음 ─────

  static Future<CommandReceipt> _operatorOnly(String what) =>
      Future<CommandReceipt>.error(
        UnsupportedError('$what: 운영 폰 전용(뷰어 = 배치 D command_insert_viewer 4종)'),
      );

  @override
  Future<CommandReceipt> registerDeposit(DepositRegistration registration) =>
      _operatorOnly('registerDeposit');

  @override
  Future<CommandReceipt> recordManualFill(ManualFillSubmission submission) =>
      _operatorOnly('recordManualFill');

  @override
  Future<CommandReceipt> amendManualFill(ManualFillAmendment amendment) =>
      _operatorOnly('amendManualFill');

  @override
  Future<CommandReceipt> voidManualFill(ManualFillVoid v) =>
      _operatorOnly('voidManualFill');

  @override
  Future<CommandReceipt> skipAdvice(AdviceSkipSubmission submission) =>
      _operatorOnly('skipAdvice');

  @override
  Future<CommandReceipt> submitSelfReportBalance(
    SelfReportSubmission submission,
  ) => _operatorOnly('submitSelfReportBalance');

  @override
  Future<CommandReceipt> acknowledgeAlert(String alertId) =>
      _operatorOnly('acknowledgeAlert');

  @override
  Future<CommandReceipt> confirmKillChecklist(
    KillChecklistSubmission submission,
  ) => _operatorOnly('confirmKillChecklist');

  @override
  Future<CommandReceipt> recordLedgerEvent(LedgerEventRecord record) =>
      _operatorOnly('recordLedgerEvent');

  @override
  Future<CommandReceipt> deferAdviceConfirm(String adviceId) =>
      _operatorOnly('deferAdviceConfirm');

  // ───── 상태 ─────

  /// 의무(01 §4-2) ① 이 인스턴스가 낸 명령 = 접수증을 곧바로(로컬 큐 없음 — 큐에만 있는 명령이 없다) ② 종단 전 완료 0 ·
  /// 종단 = 내고 닫는다 ③ 모르는 · 보이지 않는 id = 에러 하나 내고 닫는다(폐기면 [ViewerCommandFailure] revoked).
  /// 읽기 실패 = 에러 하나 내고 다음 주기에 다시(화면 = 마지막 접수증 유지 · 01 §8 미결 51 ③) · 구독 취소 = 읽기 멈춤.
  @override
  Stream<CommandReceipt> watchCommand(String commandId) {
    late final StreamController<CommandReceipt> out;
    Timer? timer;
    bool live = true;
    CommandReceipt? last;

    Future<void> finish([Object? error]) async {
      if (!live) return;
      live = false;
      timer?.cancel();
      if (error != null) out.addError(error);
      await out.close();
    }

    Future<void> tick() async {
      if (!live) return;
      try {
        final CommandReceipt base =
            last ?? _issued[commandId] ?? await _receiptOfRow(commandId);
        final CommandReceipt? next = await _statusOf(base);
        if (!live) return;
        if (next == null) {
          await finish(
            await _deviceRevoked()
                ? const ViewerCommandFailure(ViewerCommandFailureKind.revoked)
                : _unknown(),
          );
          return;
        }
        if (next != last) {
          last = next;
          out.add(next);
        }
        if (CommandStateMachine.isTerminal(next.state)) {
          await finish();
          return;
        }
      } on _UnknownCommand {
        await finish(_unknown());
        return;
      } on Object catch (e, st) {
        if (!live) return;
        out.addError(e, st);
      }
      if (live) timer = Timer(pollInterval, () => unawaited(tick()));
    }

    out = StreamController<CommandReceipt>(
      onListen: () {
        final CommandReceipt? mine = _issued[commandId];
        if (mine != null) {
          last = mine;
          out.add(mine);
        }
        unawaited(tick());
      },
      onCancel: () {
        live = false;
        timer?.cancel();
      },
    );
    return out.stream;
  }

  static ArgumentError _unknown() =>
      ArgumentError('모르는 · 보이지 않는 명령(command_queue · command_status 0행)');

  // ───── 내기 ─────

  Future<CommandReceipt> _issue(
    CommandKind kind,
    Map<String, Object?> payload,
  ) async {
    final Duration ttl = ViewerCommandTtl.of(kind)!; // 뷰어 4종만 여기로 온다.
    final _Context ctx = await _context();
    final String commandId = _uuidV4(_random);
    final String nonce = _hex(_random, 16);
    final Map<String, Object?> row = <String, Object?>{
      'command_id': commandId,
      'kind': kind.wire,
      'payload': payload,
      'issued_by_device': ctx.deviceId,
      'nonce': nonce,
      'expires_at': _clock().toUtc().add(ttl).toIso8601String(),
      'owner_uid': ctx.ownerUid,
      'run_mode': ctx.runMode.wire,
      'operating_mode': ctx.operatingMode.wire,
      'lease_epoch': ctx.leaseEpoch,
    };
    ViewerRestResult r = await _rest.insert(_kCommandTable, row);
    if (r.failure == ViewerRestFailure.network || (r.statusCode ?? 0) >= 500) {
      r = await _rest.insert(_kCommandTable, row); // 같은 본문 — 앞 시도가 닿았으면 409.
    }
    final CommandReceipt receipt;
    switch (r.statusCode) {
      case 201:
        final List<Map<String, Object?>>? rows = r.rows;
        final CommandReceipt? mine = rows != null && rows.length == 1
            ? _ownReceipt(rows.single, kind, commandId, nonce, ctx.deviceId)
            : null;
        if (mine == null) {
          throw const ViewerCommandFailure(
            ViewerCommandFailureKind.badResponse,
            statusCode: 201,
          );
        }
        receipt = mine;
      case 409:
        receipt = await _existing(kind, commandId, nonce, ctx.deviceId);
      case 401 || 403:
        if (await _deviceRevoked()) {
          throw const ViewerCommandFailure(ViewerCommandFailureKind.revoked);
        }
        throw ViewerCommandFailure(
          ViewerCommandFailureKind.unauthorized,
          statusCode: r.statusCode,
        );
      default:
        throw _failureOf(r);
    }
    _issued[commandId] = receipt;
    return receipt;
  }

  /// 409 — 같은 id 의 행을 읽어 우리 것(nonce · 종류 · 기기 같음)이면 접수증.
  Future<CommandReceipt> _existing(
    CommandKind kind,
    String commandId,
    String nonce,
    String deviceId,
  ) async {
    final ViewerRestResult r = await _rest.select(
      _kCommandTable,
      <String, String>{
        'command_id': 'eq.$commandId',
        'select': CommandOpenColumns.all.join(','),
      },
    );
    if (r.statusCode != 200) throw _failureOf(r);
    final List<Map<String, Object?>>? rows = r.rows;
    final CommandReceipt? mine = rows != null && rows.length == 1
        ? _ownReceipt(rows.single, kind, commandId, nonce, deviceId)
        : null;
    if (mine == null) {
      throw const ViewerCommandFailure(
        ViewerCommandFailureKind.badResponse,
        statusCode: 409,
      );
    }
    return mine;
  }

  /// 돌려받은 행 → 접수증(보낸 값과 다르면 null — 남의 행으로 접수증을 짓지 않는다).
  static CommandReceipt? _ownReceipt(
    Map<String, Object?> row,
    CommandKind kind,
    String commandId,
    String nonce,
    String deviceId,
  ) {
    final CommandReceipt? r = _receiptOf(row);
    if (r == null ||
        r.commandId != commandId ||
        r.kind != kind ||
        r.nonce != nonce ||
        r.issuedByDeviceId != deviceId) {
      return null;
    }
    return r;
  }

  /// `command_queue` 행 → 접수증(상태 = 보냄 · 처리 전) · 꼴 아님 = null.
  static CommandReceipt? _receiptOf(Map<String, Object?> row) {
    final Object? id = row['command_id'];
    final Object? nonce = row['nonce'];
    final Object? device = row['issued_by_device'];
    final CommandKind? kind = _kindOf(row['kind']);
    final DateTime? requested = _utc(row['requested_at']);
    final DateTime? expires = _utc(row['expires_at']);
    if (id is! String ||
        nonce is! String ||
        device is! String ||
        kind == null ||
        requested == null ||
        expires == null) {
      return null;
    }
    return CommandReceipt(
      commandId: id,
      kind: kind,
      state: CommandState.requested,
      stateLabel: CommandStatusText.requested,
      requestedAt: requested,
      expiresAt: expires,
      nonce: nonce,
      issuedByDeviceId: device,
    );
  }

  /// 재구독(이 인스턴스가 내지 않은 id) — `command_queue` 행에서 접수증 바탕.
  Future<CommandReceipt> _receiptOfRow(String commandId) async {
    if (!_uuid.hasMatch(commandId)) throw const _UnknownCommand();
    final ViewerRestResult r = await _rest.select(
      _kCommandTable,
      <String, String>{
        'command_id': 'eq.$commandId',
        'select': CommandOpenColumns.all.join(','),
      },
    );
    if (r.statusCode != 200) throw _failureOf(r);
    final List<Map<String, Object?>>? rows = r.rows;
    if (rows == null || rows.length > 1) {
      throw const ViewerCommandFailure(
        ViewerCommandFailureKind.badResponse,
        statusCode: 200,
      );
    }
    if (rows.isEmpty) throw const _UnknownCommand();
    final CommandReceipt? base = _receiptOf(rows.single);
    if (base == null || base.commandId != commandId) {
      throw const ViewerCommandFailure(
        ViewerCommandFailureKind.badResponse,
        statusCode: 200,
      );
    }
    return base;
  }

  /// `command_status` 한 번 — 바탕 + 상태 · 0행(보이지 않음) = null.
  Future<CommandReceipt?> _statusOf(CommandReceipt base) async {
    final ViewerRestResult r = await _rest.rpc(
      CommandReadRpcNames.status,
      <String, Object?>{
        CommandReadRpcParams.commandIds: <String>[base.commandId],
      },
    );
    if (r.statusCode != 200) throw _failureOf(r);
    final List<Map<String, Object?>>? rows = r.rows;
    if (rows == null || rows.length > 1) {
      throw const ViewerCommandFailure(
        ViewerCommandFailureKind.badResponse,
        statusCode: 200,
      );
    }
    if (rows.isEmpty) return null;
    final Map<String, Object?> row = rows.single;
    final CommandState? state = _stateOf(row[CommandStatusColumns.state]);
    final Object? engineLabel = row[CommandStatusColumns.stateLabel];
    final Object? code = row[CommandStatusColumns.rejectReasonCode];
    final String? label = engineLabel is String && engineLabel.isNotEmpty
        ? engineLabel
        : (state == null ? null : CommandStatusText.of(state));
    if (row[CommandStatusColumns.commandId] != base.commandId ||
        state == null ||
        label == null ||
        (code != null && code is! String) ||
        (CommandStateMachine.requiresRejectReasonCode(state) && code == null)) {
      throw const FormatException('command_status 행 꼴 아님');
    }
    return base.copyWith(
      state: state,
      stateLabel: label,
      rejectReasonCode: code as String?,
    );
  }

  // ───── 맥락 ─────

  Future<_Context> _context() async {
    final String? deviceId = await _deviceId();
    if (deviceId == null) {
      throw const ViewerCommandFailure(ViewerCommandFailureKind.notPaired);
    }
    final (
      ViewerRestResult device,
      ViewerRestResult config,
      ViewerRestResult lease,
    ) = await (
      _rest.select(_kDeviceTable, _deviceQuery(deviceId)),
      _rest.select(_kConfigTable, <String, String>{
        'mode': 'eq.${mode.wire}',
        'select': 'run_mode,operating_mode',
      }),
      _rest.select(_kLeaseTable, const <String, String>{'select': 'epoch'}),
    ).wait;
    // ① 기기 — 폐기 판정이 맥락보다 먼저(폐기된 뷰어는 rm_* 도 0행이라 «맥락 없음»으로 둔갑하지 않게).
    if (device.statusCode != 200) throw _failureOf(device);
    final String? owner = _activeOwner(device.rows);
    if (owner == null) {
      throw const ViewerCommandFailure(ViewerCommandFailureKind.revoked);
    }
    // ② 그 화면 모드 설정 행 — 실행 모드 · 운영 방식.
    if (config.statusCode != 200) throw _failureOf(config);
    final List<Map<String, Object?>>? cfg = config.rows;
    final RunMode? runMode = cfg != null && cfg.length == 1
        ? _runModeOf(cfg.single['run_mode'])
        : null;
    final OperatingMode? operating = cfg != null && cfg.length == 1
        ? _operatingModeOf(cfg.single['operating_mode'])
        : null;
    if (runMode == null || operating == null) {
      throw const ViewerCommandFailure(ViewerCommandFailureKind.context);
    }
    // ③ 리스 세대 — 행 0 = 0(첫 클레임 전 · 감사용).
    if (lease.statusCode != 200) throw _failureOf(lease);
    final List<Map<String, Object?>>? leaseRows = lease.rows;
    final Object? epoch = leaseRows == null
        ? null
        : (leaseRows.isEmpty
              ? 0
              : (leaseRows.length == 1 ? leaseRows.single['epoch'] : null));
    if (epoch is! int) {
      throw const ViewerCommandFailure(ViewerCommandFailureKind.context);
    }
    return (
      deviceId: deviceId,
      ownerUid: owner,
      runMode: runMode,
      operatingMode: operating,
      leaseEpoch: epoch,
    );
  }

  static Map<String, String> _deviceQuery(String deviceId) => <String, String>{
    'device_id': 'eq.$deviceId',
    'select': 'owner_uid,role,status',
  };

  /// 자기 기기 행이 ACTIVE 뷰어면 소유자 · 아니면(행 0 · 폐기 · 은퇴 · PENDING · 운영 폰 · 꼴 아님) null.
  static String? _activeOwner(List<Map<String, Object?>>? rows) {
    if (rows == null || rows.length != 1) return null;
    final Map<String, Object?> d = rows.single;
    final Object? owner = d['owner_uid'];
    if (d['role'] != 'viewer' ||
        d['status'] != 'ACTIVE' ||
        owner is! String ||
        owner.isEmpty) {
      return null;
    }
    return owner;
  }

  /// 401 · 403 뒤 · 상태 0행 뒤 — 자기 기기 행을 다시 읽어 «ACTIVE 뷰어 아님»이 **보일 때만** 참(읽기 실패 = 거짓).
  Future<bool> _deviceRevoked() async {
    final String? deviceId = await _deviceId();
    if (deviceId == null) return false;
    final ViewerRestResult r = await _rest.select(
      _kDeviceTable,
      _deviceQuery(deviceId),
    );
    return r.statusCode == 200 &&
        r.rows != null &&
        _activeOwner(r.rows) == null;
  }

  Future<String?> _deviceId() async {
    try {
      final String? id = await _rest.session.deviceId();
      return id == null || id.isEmpty ? null : id;
    } on Object {
      return null;
    }
  }

  static ViewerCommandFailure _failureOf(ViewerRestResult r) {
    switch (r.failure) {
      case ViewerRestFailure.notPaired:
        return const ViewerCommandFailure(ViewerCommandFailureKind.notPaired);
      case ViewerRestFailure.notSignedIn:
        return const ViewerCommandFailure(ViewerCommandFailureKind.notSignedIn);
      case ViewerRestFailure.network:
        return const ViewerCommandFailure(ViewerCommandFailureKind.network);
      case null:
        final int c = r.statusCode!;
        return ViewerCommandFailure(
          c == 401 || c == 403
              ? ViewerCommandFailureKind.unauthorized
              : c >= 500
              ? ViewerCommandFailureKind.server
              : ViewerCommandFailureKind.badResponse,
          statusCode: c,
        );
    }
  }
}

/// 모르는 · 보이지 않는 명령(내부 신호).
final class _UnknownCommand implements Exception {
  const _UnknownCommand();
}

final RegExp _uuid = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

/// 시차가 붙은 시각만(시차 없는 글자 = 기기 지역 시각으로 읽혀 어긋난다 — 소비기 `remoteCommandOf` 와 같은 결).
DateTime? _utc(Object? v) {
  if (v is! String) return null;
  final DateTime? t = DateTime.tryParse(v);
  if (t == null || !t.isUtc) return null;
  return t;
}

CommandKind? _kindOf(Object? wire) {
  for (final CommandKind k in CommandKind.values) {
    if (k.wire == wire) return k;
  }
  return null;
}

CommandState? _stateOf(Object? wire) {
  for (final CommandState s in CommandState.values) {
    if (s.wire == wire) return s;
  }
  return null;
}

RunMode? _runModeOf(Object? wire) {
  for (final RunMode m in RunMode.values) {
    if (m.wire == wire) return m;
  }
  return null;
}

OperatingMode? _operatingModeOf(Object? wire) {
  for (final OperatingMode m in OperatingMode.values) {
    if (m.wire == wire) return m;
  }
  return null;
}

/// 무작위 16바이트 16진(운영 폰 nonce 와 같은 꼴).
String _hex(Random r, int bytes) => <String>[
  for (int i = 0; i < bytes; i++)
    r.nextInt(256).toRadixString(16).padLeft(2, '0'),
].join();

/// uuid v4(무작위 · 판 4 · 변형 RFC).
String _uuidV4(Random r) {
  final List<int> b = <int>[for (int i = 0; i < 16; i++) r.nextInt(256)];
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final String x = b.map((int v) => v.toRadixString(16).padLeft(2, '0')).join();
  return '${x.substring(0, 8)}-${x.substring(8, 12)}-${x.substring(12, 16)}-'
      '${x.substring(16, 20)}-${x.substring(20)}';
}
