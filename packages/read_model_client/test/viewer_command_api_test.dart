// 🆕 R277(설계 13 §8 R277 VC3~VC9) — 뷰어 `CommandApi`(E11m-b) 시험: 가짜 HTTP(`MockClient`) · 가짜 세션 · 실 프로젝트 호출 0.
// 🔴 본문 · 읽는 표 · 열 = 계약 배치 D 원문(`domain_contracts/ddl/batch_d_supabase.sql`)과 대조(정적).

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:read_model_client/read_model_client.dart';
import 'package:test/test.dart';

const String _deviceId = 'viewer-device-1';
const String _ownerUid = '11111111-2222-4333-8444-555555555555';
const String _serverNow = '2026-11-27T08:00:00.123456+00:00';
const String _secretToken = 'tok-SECRET-1';
const String _secretKey = 'sb_publishable_SECRET';

final class _FakeSession implements ViewerSession {
  ViewerEndpoint? ep = ViewerEndpoint(
    Uri.parse('https://proj.supabase.test'),
    _secretKey,
  );
  String? device = _deviceId;
  List<String?> tokens = <String?>[_secretToken, 'tok-2'];
  int refreshes = 0;

  @override
  Future<ViewerEndpoint?> endpoint() async => ep;

  @override
  Future<String?> accessToken({bool forceRefresh = false}) async {
    if (forceRefresh) refreshes++;
    return tokens[min(refreshes, tokens.length - 1)];
  }

  @override
  Future<String?> deviceId() async => device;
}

/// 가짜 서버 — 표 · 함수 몇 개만(경로 · 방법으로 가른다).
final class _FakeServer {
  List<Map<String, Object?>> deviceRows = <Map<String, Object?>>[
    <String, Object?>{
      'owner_uid': _ownerUid,
      'role': 'viewer',
      'status': 'ACTIVE',
    },
  ];
  List<Map<String, Object?>> configRows = <Map<String, Object?>>[
    <String, Object?>{'run_mode': 'SIM_BROKER', 'operating_mode': 'ADVISORY'},
  ];
  List<Map<String, Object?>> leaseRows = <Map<String, Object?>>[
    <String, Object?>{'epoch': 7},
  ];

  /// 넣은 행(명령 id → 저장된 행).
  final Map<String, Map<String, Object?>> commands =
      <String, Map<String, Object?>>{};

  /// 넣기 응답 차례(비면 정상 201) — `null` = 망 실패(예외) · 정수 = 그 상태(본문 = 오류 객체) · 'commit+drop' = 넣고 망 실패.
  final List<Object?> insertScript = <Object?>[];

  /// 상태 응답 차례(마지막 것을 되풀이) — 행 목록 · `null` = 망 실패 · 정수 = 그 상태.
  final List<Object?> statusScript = <Object?>[];

  /// 기기 읽기 응답 차례(비면 [deviceRows]) — 정수 = 그 상태 · 행 목록 = 그 행 · null = [deviceRows].
  final List<Object?> deviceScript = <Object?>[];

  /// 저장 · 응답하는 행의 nonce 를 이 값으로(남의 행 흉내).
  String? storedNonce;

  /// 저장 · 응답하는 행의 시각을 시차 없는 글자로.
  bool naiveTime = false;

  /// 받은 요청(차례).
  final List<http.Request> requests = <http.Request>[];

  late final http.Client client = MockClient(_handle);

  int get inserts => requests
      .where(
        (http.Request r) =>
            r.method == 'POST' && r.url.path == '/rest/v1/command_queue',
      )
      .length;

  int get statusCalls => requests
      .where((http.Request r) => r.url.path == '/rest/v1/rpc/command_status')
      .length;

  Future<http.Response> _handle(http.Request r) async {
    requests.add(r);
    final String path = r.url.path;
    if (r.method == 'GET' && path == '/rest/v1/app_device') {
      if (deviceScript.isNotEmpty) {
        final Object? s = deviceScript.removeAt(0);
        if (s is int) return http.Response('{"message":"x"}', s);
        if (s is List<Object?>) return _json(s);
      }
      return _json(deviceRows);
    }
    if (r.method == 'GET' && path == '/rest/v1/rm_config_view') {
      return _json(configRows);
    }
    if (r.method == 'GET' && path == '/rest/v1/operator_lease') {
      return _json(leaseRows);
    }
    if (r.method == 'POST' && path == '/rest/v1/command_queue') {
      final Object? step = insertScript.isEmpty
          ? 'ok'
          : insertScript.removeAt(0);
      final Map<String, Object?> body =
          jsonDecode(r.body) as Map<String, Object?>;
      if (step == null) throw http.ClientException('망 끊김');
      if (step is int) return http.Response('{"code":"x"}', step);
      final String id = body['command_id']! as String;
      if (commands.containsKey(id)) {
        return http.Response('{"code":"23505"}', 409);
      }
      final Map<String, Object?> stored = <String, Object?>{
        ...body,
        'requested_at': naiveTime ? '2026-11-27T08:00:00' : _serverNow,
        'expires_at': _pgTime(body['expires_at']! as String),
        'nonce': storedNonce ?? body['nonce'],
      };
      commands[id] = stored;
      if (step == 'commit+drop') throw http.ClientException('응답 유실');
      return _json(<Object?>[stored], 201);
    }
    if (r.method == 'GET' && path == '/rest/v1/command_queue') {
      final String id = r.url.queryParameters['command_id']!.substring(3);
      final Map<String, Object?>? row = commands[id];
      return _json(<Object?>[?row]);
    }
    if (r.method == 'POST' && path == '/rest/v1/rpc/command_status') {
      final Object? step = statusScript.length > 1
          ? statusScript.removeAt(0)
          : (statusScript.isEmpty ? <Object?>[] : statusScript.single);
      if (step == null) throw http.ClientException('망 끊김');
      if (step is int) return http.Response('{"code":"x"}', step);
      return _json(step);
    }
    return http.Response('{"code":"PGRST"}', 404);
  }

  static http.Response _json(Object? v, [int status = 200]) =>
      http.Response.bytes(utf8.encode(jsonEncode(v)), status);

  /// PostgREST 가 돌려주는 timestamptz 꼴(시차 +00:00).
  static String _pgTime(String iso) =>
      DateTime.parse(iso).toUtc().toIso8601String().replaceFirst('Z', '+00:00');
}

Map<String, Object?> _statusRow(
  String id,
  String state, {
  String? label,
  String? code,
}) => <String, Object?>{
  'command_id': id,
  'state': state,
  'state_label': label,
  'reject_reason_code': code,
  'decision_id': null,
  'acked_at': label == null ? null : _serverNow,
};

/// 배치 D 원문.
final String _batchD = File('../domain_contracts/ddl/batch_d_supabase.sql')
    .readAsStringSync();

/// `create table if not exists <t> (` … `);` 의 열 이름.
Set<String> _tableColumns(String table) {
  final RegExpMatch m = RegExp(
    'create table if not exists $table \\((.*?)\\n\\);',
    dotAll: true,
  ).firstMatch(_batchD)!;
  return <String>{
    for (final String line in m.group(1)!.split('\n'))
      if (RegExp(r'^  ([a-z_]+)\s').firstMatch(line) case final RegExpMatch c
          when c.group(1) != 'unique' && c.group(1) != 'check')
        c.group(1)!,
  };
}

void main() {
  late _FakeServer server;
  late _FakeSession session;
  late ViewerCommandApi api;
  final DateTime deviceNow = DateTime.utc(2026, 11, 27, 9);

  ViewerCommandApi make({Duration poll = const Duration(milliseconds: 1)}) =>
      ViewerCommandApi(
        ViewerRest(server.client, session),
        mode: RunMode.simBroker,
        random: Random(42),
        clock: () => deviceNow,
        pollInterval: poll,
      );

  setUp(() {
    server = _FakeServer();
    session = _FakeSession();
    api = make();
  });

  Map<String, Object?> lastInsertBody() => jsonDecode(
    server.requests
        .lastWhere(
          (http.Request r) =>
              r.method == 'POST' && r.url.path == '/rest/v1/command_queue',
        )
        .body,
  ) as Map<String, Object?>;

  group('계약 배치 D 대조(정적)', () {
    test(
      '넣는 열 = command_queue 열 − requested_at(정책 requested_at = now() · 서버 기본값)',
      () async {
        await api.activateKillSwitch();
        final Set<String> cols = _tableColumns('command_queue');
        expect(cols, contains('requested_at'));
        expect(
          lastInsertBody().keys.toSet(),
          cols.difference(<String>{'requested_at'}),
        );
        expect(
          CommandOpenColumns.all.toSet(),
          cols,
          reason: '409 뒤 읽는 열 = 표 열 전부',
        );
      },
    );

    test('뷰어 넣기 정책 4종 = ViewerCommandTtl.kinds = 이 구현이 내는 종류', () {
      final RegExpMatch m = RegExp(
        r'create policy command_insert_viewer on command_queue.*?kind in \(([^)]*)\)',
        dotAll: true,
      ).firstMatch(_batchD)!;
      final List<String> kinds = RegExp("'([A-Z_]+)'")
          .allMatches(m.group(1)!)
          .map((RegExpMatch k) => k.group(1)!)
          .toList();
      expect(kinds, ViewerCommandTtl.kinds.map((CommandKind k) => k.wire));
    });

    test('읽는 열 = 배치 D · 읽기 모델 표 열', () {
      expect(
        _tableColumns('app_device'),
        containsAll(<String>['device_id', 'owner_uid', 'role', 'status']),
      );
      expect(_tableColumns('operator_lease'), contains('epoch'));
      expect(
        ReadModelTables.configView.columns.map((ReadModelColumn c) => c.name),
        containsAll(<String>['run_mode', 'operating_mode']),
      );
      expect(ReadModelTables.configView.name, 'rm_config_view');
    });
  });

  group('내기', () {
    test('킬스위치 — 본문 · 머리 · 맥락 · 접수증(서버 시각)', () async {
      final CommandReceipt r = await api.activateKillSwitch();
      final Map<String, Object?> b = lastInsertBody();
      expect(b['kind'], 'KILL_SWITCH_ACTIVATE');
      expect(b['payload'], <String, Object?>{});
      expect(b['issued_by_device'], _deviceId);
      expect(b['owner_uid'], _ownerUid);
      expect(b['run_mode'], 'SIM_BROKER');
      expect(b['operating_mode'], 'ADVISORY');
      expect(b['lease_epoch'], 7);
      expect(b['expires_at'], '2026-12-27T09:00:00.000Z');
      expect(
        b['command_id'],
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(b['nonce'], matches(RegExp(r'^[0-9a-f]{32}$')));
      final http.Request req = server.requests.last;
      expect(req.headers['apikey'], _secretKey);
      expect(req.headers['authorization'], 'Bearer $_secretToken');
      expect(req.headers['prefer'], 'return=representation');
      expect(req.url.host, 'proj.supabase.test');
      // 화면 모드 행만 · 기기 = 자기 행만.
      final http.Request cfg = server.requests.firstWhere(
        (http.Request q) => q.url.path == '/rest/v1/rm_config_view',
      );
      expect(cfg.url.queryParameters['mode'], 'eq.SIM_BROKER');
      final http.Request dev = server.requests.firstWhere(
        (http.Request q) => q.url.path == '/rest/v1/app_device',
      );
      expect(dev.url.queryParameters['device_id'], 'eq.$_deviceId');

      expect(r.commandId, b['command_id']);
      expect(r.kind, CommandKind.killSwitchActivate);
      expect(r.state, CommandState.requested);
      expect(r.stateLabel, CommandStatusText.requested);
      expect(r.requestedAt, DateTime.parse(_serverNow));
      expect(r.requestedAt.isUtc, isTrue);
      expect(r.expiresAt, DateTime.utc(2026, 12, 27, 9));
      expect(r.nonce, b['nonce']);
      expect(r.issuedByDeviceId, _deviceId);
      expect(r.rejectReasonCode, isNull);
    });

    test('기록 셋 — 본문 = 계약 와이어 toJson(소비기 fromJson 왕복) · TTL 14일', () async {
      const JournalDraft d = JournalDraft(
        decisionId: 'j-1',
        rationaleBefore: '근거',
        expectedOutcome: '기대',
        ruleCited: 'RULE_A',
      );
      await api.submitJournalDraft(d);
      Map<String, Object?> b = lastInsertBody();
      expect(b['kind'], 'JOURNAL_DRAFT');
      expect(JournalDraft.fromJson(b['payload']! as Map<String, Object?>), d);
      expect(b['expires_at'], '2026-12-11T09:00:00.000Z');

      const BlindReviewScore s = BlindReviewScore(
        decisionId: 'd-1',
        answers: <String, int>{'q1': 2, 'q2': 0},
      );
      await api.submitBlindReviewScore(s);
      b = lastInsertBody();
      expect(b['kind'], 'BLIND_REVIEW_SCORE');
      expect(
        BlindReviewScore.fromJson(b['payload']! as Map<String, Object?>),
        s,
      );
      expect(b['expires_at'], '2026-12-11T09:00:00.000Z');

      final DisclosureViewEvent e = DisclosureViewEvent(
        surfaceCode: DisclosureSurfaceCodes.values.first,
        viewedAt: DateTime.utc(2026, 11, 27, 8, 30),
      );
      await api.recordDisclosureView(e);
      b = lastInsertBody();
      expect(b['kind'], 'DISCLOSURE_VIEW');
      expect(
        DisclosureViewEvent.fromJson(b['payload']! as Map<String, Object?>),
        e,
      );
      expect(b['expires_at'], '2026-12-11T09:00:00.000Z');
      expect(server.inserts, 3);
    });

    test('명령마다 새 id · nonce', () async {
      final CommandReceipt a = await api.activateKillSwitch();
      final CommandReceipt b = await api.activateKillSwitch();
      expect(a.commandId, isNot(b.commandId));
      expect(a.nonce, isNot(b.nonce));
    });

    test('리스 행 0 = 세대 0(첫 클레임 전 — 그래도 보낸다 · 상태 = 서버 NO_OPERATOR)', () async {
      server.leaseRows = <Map<String, Object?>>[];
      await api.activateKillSwitch();
      expect(lastInsertBody()['lease_epoch'], 0);
    });
  });

  group('접수 실패', () {
    Future<void> failsWith(
      Future<CommandReceipt> Function() call,
      ViewerCommandFailureKind kind, {
      int? status,
      bool inserted = false,
    }) async {
      await expectLater(
        call(),
        throwsA(
          isA<ViewerCommandFailure>()
              .having((ViewerCommandFailure f) => f.kind, 'kind', kind)
              .having(
                (ViewerCommandFailure f) => f.statusCode,
                'statusCode',
                status,
              ),
        ),
      );
      if (!inserted) expect(server.inserts, 0, reason: '넣기 전에 멈춘다');
    }

    test('기기 행 0 · 폐기 · 은퇴 · PENDING · 운영 폰 = revoked(PAIRING_TOKEN_REVOKED) · 넣기 0', () async {
      for (final List<Map<String, Object?>> rows
          in <List<Map<String, Object?>>>[
            <Map<String, Object?>>[],
            <Map<String, Object?>>[
              <String, Object?>{
                'owner_uid': _ownerUid,
                'role': 'viewer',
                'status': 'REVOKED',
              },
            ],
            <Map<String, Object?>>[
              <String, Object?>{
                'owner_uid': _ownerUid,
                'role': 'viewer',
                'status': 'RETIRED',
              },
            ],
            <Map<String, Object?>>[
              <String, Object?>{
                'owner_uid': _ownerUid,
                'role': 'viewer',
                'status': 'PENDING',
              },
            ],
            <Map<String, Object?>>[
              <String, Object?>{
                'owner_uid': _ownerUid,
                'role': 'operator',
                'status': 'ACTIVE',
              },
            ],
          ]) {
        server.deviceRows = rows;
        await failsWith(
          api.activateKillSwitch,
          ViewerCommandFailureKind.revoked,
        );
      }
      await expectLater(
        api.activateKillSwitch(),
        throwsA(
          isA<ViewerCommandFailure>().having(
            (ViewerCommandFailure f) => f.reasonCode,
            'reasonCode',
            OnboardingResultCodes.pairingTokenRevoked,
          ),
        ),
      );
    });

    test('그 모드 설정 행 없음 · 둘 · 모르는 글자 = context · 리스 꼴 아님 = context', () async {
      server.configRows = <Map<String, Object?>>[];
      await failsWith(api.activateKillSwitch, ViewerCommandFailureKind.context);
      server.configRows = <Map<String, Object?>>[
        <String, Object?>{'run_mode': 'LIVE', 'operating_mode': 'ADVISORY'},
        <String, Object?>{'run_mode': 'LIVE', 'operating_mode': 'ADVISORY'},
      ];
      await failsWith(api.activateKillSwitch, ViewerCommandFailureKind.context);
      server.configRows = <Map<String, Object?>>[
        <String, Object?>{'run_mode': 'PAPER', 'operating_mode': 'ADVISORY'},
      ];
      await failsWith(api.activateKillSwitch, ViewerCommandFailureKind.context);
      server.configRows = <Map<String, Object?>>[
        <String, Object?>{'run_mode': 'LIVE', 'operating_mode': null},
      ];
      await failsWith(api.activateKillSwitch, ViewerCommandFailureKind.context);
      server.configRows = <Map<String, Object?>>[
        <String, Object?>{'run_mode': 'LIVE', 'operating_mode': 'AUTO_TRADE'},
      ];
      server.leaseRows = <Map<String, Object?>>[
        <String, Object?>{'epoch': '7'},
      ];
      await failsWith(api.activateKillSwitch, ViewerCommandFailureKind.context);
    });

    test('세션 없음 — 기기 id · 주소 = notPaired · 토큰 = notSignedIn', () async {
      session.device = null;
      await failsWith(
        api.activateKillSwitch,
        ViewerCommandFailureKind.notPaired,
      );
      expect(server.requests, isEmpty);
      session
        ..device = _deviceId
        ..ep = null;
      await failsWith(
        api.activateKillSwitch,
        ViewerCommandFailureKind.notPaired,
      );
      session
        ..ep = ViewerEndpoint(
          Uri.parse('https://proj.supabase.test'),
          _secretKey,
        )
        ..tokens = <String?>[null];
      await failsWith(
        api.activateKillSwitch,
        ViewerCommandFailureKind.notSignedIn,
      );
      expect(server.requests, isEmpty);
    });

    test('401 = 토큰 새로 한 번 → 통과', () async {
      server.insertScript.add(401);
      final CommandReceipt r = await api.activateKillSwitch();
      expect(r.state, CommandState.requested);
      expect(session.refreshes, 1);
      expect(server.requests.last.headers['authorization'], 'Bearer tok-2');
      expect(server.inserts, 2);
    });

    test('403 두 번 — 기기 ACTIVE = unauthorized · 기기가 폐기로 보이면 revoked', () async {
      server.insertScript.addAll(<Object?>[403, 403]);
      await failsWith(
        api.activateKillSwitch,
        ViewerCommandFailureKind.unauthorized,
        status: 403,
        inserted: true,
      );
      server.insertScript.addAll(<Object?>[403, 403]);
      // 맥락 읽기 = ACTIVE · 넣기 뒤 다시 읽기 = 폐기(그 사이 운영 폰이 끊었다).
      server.deviceScript.addAll(<Object?>[
        null,
        <Object?>[
          <String, Object?>{
            'owner_uid': _ownerUid,
            'role': 'viewer',
            'status': 'REVOKED',
          },
        ],
      ]);
      await expectLater(
        api.activateKillSwitch(),
        throwsA(
          isA<ViewerCommandFailure>().having(
            (ViewerCommandFailure x) => x.kind,
            'kind',
            ViewerCommandFailureKind.revoked,
          ),
        ),
      );
    });

    test('망 끊김 → 같은 본문 한 번 더 → 201', () async {
      server.insertScript.add(null);
      final CommandReceipt r = await api.activateKillSwitch();
      final List<http.Request> ins = server.requests
          .where(
            (http.Request q) =>
                q.method == 'POST' && q.url.path == '/rest/v1/command_queue',
          )
          .toList();
      expect(ins, hasLength(2));
      expect(ins[0].body, ins[1].body, reason: '같은 명령 id · nonce');
      expect(
        r.commandId,
        (jsonDecode(ins[0].body) as Map<String, Object?>)['command_id'],
      );
    });

    test('앞 시도가 닿고 응답만 유실 → 다시 보냄 409 → 그 행 읽어 접수증(서버 시각)', () async {
      server.insertScript.add('commit+drop');
      final CommandReceipt r = await api.activateKillSwitch();
      expect(server.inserts, 2);
      expect(server.commands, hasLength(1));
      expect(r.commandId, server.commands.keys.single);
      expect(r.requestedAt, DateTime.parse(_serverNow));
      final http.Request read = server.requests.last;
      expect(read.method, 'GET');
      expect(read.url.path, '/rest/v1/command_queue');
      expect(
        read.url.queryParameters['select'],
        CommandOpenColumns.all.join(','),
      );
    });

    test('409 인데 그 행의 nonce 가 다르다 = badResponse(남의 행으로 접수증을 짓지 않는다)', () async {
      server
        ..insertScript.add('commit+drop')
        ..storedNonce = 'ffff';
      await expectLater(
        api.activateKillSwitch(),
        throwsA(
          isA<ViewerCommandFailure>()
              .having(
                (ViewerCommandFailure x) => x.kind,
                'kind',
                ViewerCommandFailureKind.badResponse,
              )
              .having((ViewerCommandFailure x) => x.statusCode, 'status', 409),
        ),
      );
    });

    test('201 인데 돌려받은 행이 보낸 값과 다름 · 시차 없는 시각 = badResponse', () async {
      server.storedNonce = 'ffff';
      await failsWith(
        api.activateKillSwitch,
        ViewerCommandFailureKind.badResponse,
        status: 201,
        inserted: true,
      );
      server
        ..storedNonce = null
        ..naiveTime = true;
      await failsWith(
        api.activateKillSwitch,
        ViewerCommandFailureKind.badResponse,
        status: 201,
        inserted: true,
      );
    });

    test('5xx 두 번 = server · 400 = badResponse(한 번만)', () async {
      server.insertScript.addAll(<Object?>[503, 500]);
      await failsWith(
        api.activateKillSwitch,
        ViewerCommandFailureKind.server,
        status: 500,
        inserted: true,
      );
      expect(server.inserts, 2);
      server.insertScript.add(400);
      await failsWith(
        api.activateKillSwitch,
        ViewerCommandFailureKind.badResponse,
        status: 400,
        inserted: true,
      );
      expect(server.inserts, 3);
    });

    test('망 두 번 = network', () async {
      server.insertScript.addAll(<Object?>[null, null]);
      await failsWith(
        api.activateKillSwitch,
        ViewerCommandFailureKind.network,
        inserted: true,
      );
    });

    test('운영 폰 전용 = UnsupportedError · 요청 0', () async {
      final List<Future<CommandReceipt> Function()> calls =
          <Future<CommandReceipt> Function()>[
            () => api.registerDeposit(const DepositRegistration(planId: 'p')),
            () => api.acknowledgeAlert('a'),
            () => api.deferAdviceConfirm('a'),
          ];
      for (final Future<CommandReceipt> Function() c in calls) {
        await expectLater(c(), throwsUnsupportedError);
      }
      expect(server.requests, isEmpty);
    });

    test('문자열에 토큰 · 키 · 기기 id 0', () async {
      server.insertScript.addAll(<Object?>[503, 500]);
      final Object err = await api.activateKillSwitch().then<Object>(
        (CommandReceipt r) => r,
        onError: (Object e) => e,
      );
      expect(err, isA<ViewerCommandFailure>());
      expect(err.toString(), isNot(contains(_secretToken)));
      expect(err.toString(), isNot(contains(_deviceId)));
      final String e = ViewerEndpoint(
        Uri.parse('https://proj.supabase.test'),
        _secretKey,
      ).toString();
      expect(e, isNot(contains(_secretKey)));
      expect(e, isNot(contains('proj')));
      const ViewerRestResult rr = ViewerRestResult.response(
        200,
        '[{"x":"$_secretToken"}]',
      );
      expect(rr.toString(), isNot(contains(_secretToken)));
    });
  });

  group('watchCommand', () {
    test(
      '① 낸 명령 = 곧바로 첫 값 · 서버 판정 글자 · 엔진 글자 · ② 종단 = 내고 닫음 · 같은 값 다시 내지 않음',
      () async {
        final CommandReceipt sent = await api.activateKillSwitch();
        final String id = sent.commandId;
        server.statusScript.addAll(<Object?>[
          <Object?>[_statusRow(id, 'NO_OPERATOR')],
          <Object?>[_statusRow(id, 'NO_OPERATOR')],
          <Object?>[_statusRow(id, 'RECEIVED', label: '받음 — 엔진')],
          <Object?>[_statusRow(id, 'EXECUTED', label: '켜짐 — 엔진')],
        ]);
        final List<CommandReceipt> got = await api.watchCommand(id).toList();
        expect(got.map((CommandReceipt r) => r.state), <CommandState>[
          CommandState.requested,
          CommandState.noOperator,
          CommandState.received,
          CommandState.executed,
        ]);
        expect(got[0], sent);
        expect(got[1].stateLabel, CommandStatusText.noOperator);
        expect(got[2].stateLabel, '받음 — 엔진');
        expect(got[3].stateLabel, '켜짐 — 엔진');
        expect(got[3].requestedAt, sent.requestedAt);
        expect(got[3].nonce, sent.nonce);
        final http.Request st = server.requests.lastWhere(
          (http.Request r) => r.url.path == '/rest/v1/rpc/command_status',
        );
        expect(jsonDecode(st.body), <String, Object?>{
          CommandReadRpcParams.commandIds: <String>[id],
        });
      },
    );

    test('서버 REQUESTED = 계약 글자(보냄 · 처리 전)', () async {
      final CommandReceipt sent = await api.activateKillSwitch();
      server.statusScript.addAll(<Object?>[
        <Object?>[_statusRow(sent.commandId, 'REQUESTED')],
        <Object?>[_statusRow(sent.commandId, 'EXPIRED', label: '만료 — 엔진')],
      ]);
      final List<CommandReceipt> got = await api
          .watchCommand(sent.commandId)
          .toList();
      expect(got, hasLength(2), reason: '보냄 = 첫 값과 같아 다시 내지 않는다');
      expect(got.last.state, CommandState.expired);
    });

    test('재구독(다른 인스턴스) = command_queue 행에서 바탕 · REJECTED 코드 · 닫음', () async {
      final CommandReceipt sent = await api.submitJournalDraft(
        const JournalDraft(
          decisionId: 'j',
          rationaleBefore: 'a',
          expectedOutcome: 'b',
          ruleCited: 'c',
        ),
      );
      server.statusScript.add(<Object?>[
        _statusRow(
          sent.commandId,
          'REJECTED',
          label: '거부됨 — 엔진',
          code: CommandContextRejectCodes.runModeMismatch,
        ),
      ]);
      final List<CommandReceipt> got = await make()
          .watchCommand(sent.commandId)
          .toList();
      expect(got, hasLength(1));
      expect(got.single.kind, CommandKind.journalDraft);
      expect(got.single.state, CommandState.rejected);
      expect(
        got.single.rejectReasonCode,
        CommandContextRejectCodes.runModeMismatch,
      );
      expect(got.single.requestedAt, sent.requestedAt);
      expect(got.single.expiresAt, sent.expiresAt);
    });

    test('③ 모르는 id = 에러 하나 · 닫음 · uuid 꼴 아님 = 요청 0', () async {
      final List<Object> errs = <Object>[];
      await make()
          .watchCommand('00000000-0000-4000-8000-000000000000')
          .handleError(errs.add)
          .toList();
      expect(errs.single, isA<ArgumentError>());
      expect(server.statusCalls, 0);

      errs.clear();
      final int before = server.requests.length;
      await make().watchCommand('not-a-uuid').handleError(errs.add).toList();
      expect(errs.single, isA<ArgumentError>());
      expect(server.requests.length, before);
    });

    test('상태 0행 — 기기 폐기 = revoked · ACTIVE = 모르는 명령 · 둘 다 닫음', () async {
      final CommandReceipt sent = await api.activateKillSwitch();
      final List<Object> errs = <Object>[];
      final List<CommandReceipt> got = await api
          .watchCommand(sent.commandId)
          .handleError(errs.add)
          .toList();
      expect(got, <CommandReceipt>[sent]);
      expect(errs.single, isA<ArgumentError>());

      server.deviceRows = <Map<String, Object?>>[
        <String, Object?>{
          'owner_uid': _ownerUid,
          'role': 'viewer',
          'status': 'REVOKED',
        },
      ];
      errs.clear();
      await api.watchCommand(sent.commandId).handleError(errs.add).toList();
      expect(
        errs.single,
        isA<ViewerCommandFailure>().having(
          (ViewerCommandFailure f) => f.kind,
          'kind',
          ViewerCommandFailureKind.revoked,
        ),
      );
    });

    test('읽기 실패 · 꼴 아님 = 에러 하나 내고 다음 주기에 다시(닫지 않음)', () async {
      final CommandReceipt sent = await api.activateKillSwitch();
      final String id = sent.commandId;
      server.statusScript.addAll(<Object?>[
        null,
        503,
        <Object?>[_statusRow(id, 'REJECTED', label: '거부 — 엔진')], // 코드 없음 = 꼴 아님
        <Object?>[_statusRow(id, 'BOGUS')],
        <Object?>[_statusRow(id, 'RECEIVED')], // 엔진 상태인데 글자 없음 = 꼴 아님
        <Object?>[
          _statusRow(
            '00000000-0000-4000-8000-000000000000',
            'RECEIVED',
            label: 'x',
          ),
        ],
        <Object?>[_statusRow(id, 'EXECUTED', label: '켜짐 — 엔진')],
      ]);
      final List<Object> errs = <Object>[];
      final List<CommandReceipt> got = await api
          .watchCommand(id)
          .handleError(errs.add)
          .toList();
      expect(got.map((CommandReceipt r) => r.state), <CommandState>[
        CommandState.requested,
        CommandState.executed,
      ]);
      expect(errs, hasLength(6));
      expect(
        errs[0],
        isA<ViewerCommandFailure>().having(
          (ViewerCommandFailure f) => f.kind,
          'kind',
          ViewerCommandFailureKind.network,
        ),
      );
      expect(
        errs[1],
        isA<ViewerCommandFailure>().having(
          (ViewerCommandFailure f) => f.kind,
          'kind',
          ViewerCommandFailureKind.server,
        ),
      );
      expect(errs.sublist(2), everyElement(isA<FormatException>()));
    });

    test('구독 취소 = 읽기 멈춤', () async {
      final CommandReceipt sent = await api.activateKillSwitch();
      server.statusScript.add(<Object?>[
        _statusRow(sent.commandId, 'NO_OPERATOR'),
      ]);
      final StreamSubscription<CommandReceipt> sub = api
          .watchCommand(sent.commandId)
          .listen((_) {});
      while (server.statusCalls < 3) {
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }
      await sub.cancel();
      final int at = server.statusCalls;
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(server.statusCalls, lessThanOrEqualTo(at + 1));
      final int settled = server.statusCalls;
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(server.statusCalls, settled);
    });
  });
}
