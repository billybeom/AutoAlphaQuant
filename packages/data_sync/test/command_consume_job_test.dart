// E11m-a — 운영 폰 명령 소비 일(설계 13 §8 R274 · R272 Y4~Y6 · 01 §10-8 · 계약 v1.41 §50 · 01 §8 미결 244 ⓒ).
//
// 지키는 것: 리스를 쥔 기기만 당긴다 · 못 읽음 = 주문 막음 · 뷰어 명령 → 폰 버튼과 같은 처리기(같은 원장 · 수신함 PK 멱등) ·
// 실행 모드 불일치 · 만료 = 원장 쓰기 0 · 운영 폰 종류 = 소비 0 · ack = (명령 · 상태)에서 정해진 id · 보관 → 풀림 = 새 상태 ack ·
// ack 보내기 실패 = 다음 당김에 같은 id · 처리기가 던짐 = ack 0 · ack 열 ⊆ 배치 D `command_ack`(서버가 덮는 칸 0).

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:data_sync/src/supabase/supabase_bootstrap_sources.dart'
    show kSupabaseBatchDSql;
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 12, 10, 1); // 한국 12-10 10:00

class _Reader implements CommandOpenReader {
  _Reader(this.rows);
  List<Map<String, Object?>> rows;
  CommandOpenResult? failWith;
  bool throwIt = false;
  int calls = 0;
  @override
  Future<CommandOpenResult> open({
    int limit = CommandReadLimits.openMax,
  }) async {
    calls++;
    if (throwIt) throw StateError('reader');
    return failWith ?? CommandOpenResult.rows(rows);
  }
}

class _Pusher implements OpsPusher {
  OpsPushResult? fail;
  final List<
    ({
      String deviceId,
      int epoch,
      String table,
      List<Map<String, Object?>> rows,
    })
  >
  calls =
      <
        ({
          String deviceId,
          int epoch,
          String table,
          List<Map<String, Object?>> rows,
        })
      >[];
  @override
  Future<OpsPushResult> push({
    required String deviceId,
    required int epoch,
    required String table,
    required List<Map<String, Object?>> rows,
  }) async {
    calls.add((deviceId: deviceId, epoch: epoch, table: table, rows: rows));
    return fail ??
        OpsPushResult.answered(
          code: null,
          epoch: epoch,
          accepted: rows.length,
          skipped: 0,
        );
  }
}

int _n = 0;
String _id() => '00000000-0000-4000-8000-${(++_n).toString().padLeft(12, '0')}';

Map<String, Object?> _row(
  String kind, {
  String? id,
  Map<String, Object?> payload = const <String, Object?>{},
  String runMode = 'LIVE',
  String expires = '2026-12-24T00:00:00+00:00',
}) => <String, Object?>{
  'command_id': id ?? _id(),
  'kind': kind,
  'payload': payload,
  'issued_by_device': 'viewer-ios-1',
  'nonce': 'n' * 32,
  'requested_at': '2026-12-10T00:59:00+00:00',
  'expires_at': expires,
  'owner_uid': 'uid-owner',
  'run_mode': runMode,
  'operating_mode': 'AUTO_TRADE',
  'lease_epoch': 3,
};

const String _rationale = '근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거근거';

Map<String, Object?> _journal(String key) => JournalDraft(
  decisionId: key,
  rationaleBefore: _rationale,
  expectedOutcome: '기대 결과',
  ruleCited: JournalRuleCitedCodes.reconCause,
).toJson();

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late _Trusted trusted;
  late _Reader reader;
  late _Pusher pusher;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_e11ma_');
    clock = _Clock(_t0);
    trusted = _Trusted(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    reader = _Reader(<Map<String, Object?>>[]);
    pusher = _Pusher();
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  CommandConsumeJob job() => CommandConsumeJob(
    db,
    clock: clock,
    trusted: trusted,
    kr: frozenExchangeCalendar(Market.kr),
    reader: reader,
    pusher: pusher,
  );

  Future<CommandConsumeReport> run({
    String? device = 'op-phone-1',
    int epoch = 3,
    RunMode mode = RunMode.live,
    LeaseVerdict verdict = LeaseVerdict.valid,
  }) => job().run(
    deviceId: device,
    epoch: epoch,
    runMode: mode,
    lease: () async => verdict,
  );

  Map<String, Object?>? inbox(String id) {
    final ResultSet rs = db.select(
      'SELECT * FROM command_inbox WHERE command_id = ?',
      <Object?>[id],
    );
    if (rs.isEmpty) return null;
    return <String, Object?>{
      for (final String k in rs.first.keys) k: rs.first[k],
    };
  }

  List<Map<String, Object?>> lastAcks() => pusher.calls.last.rows;

  int count(String sql) => db.select(sql).single.values.first! as int;

  group('당기기 전에 멈춤', () {
    test(
      '기기 id · 원격 세대 · 리스(쥐지 않음 · 모름 · 던짐) = 당김 0 · ack 0 · 주문 막음 0',
      () async {
        final List<(Future<CommandConsumeReport>, CommandConsumeStop)>
        cases = <(Future<CommandConsumeReport>, CommandConsumeStop)>[
          (run(device: null), CommandConsumeStop.noDevice),
          (run(device: ''), CommandConsumeStop.noDevice),
          (run(epoch: 0), CommandConsumeStop.noEpoch),
          (run(verdict: LeaseVerdict.invalid), CommandConsumeStop.leaseNotHeld),
          (run(verdict: LeaseVerdict.unknown), CommandConsumeStop.leaseUnknown),
          (
            job().run(
              deviceId: 'op',
              epoch: 3,
              runMode: RunMode.live,
              lease: () async => throw StateError('lease'),
            ),
            CommandConsumeStop.leaseUnknown,
          ),
        ];
        for (final (Future<CommandConsumeReport> f, CommandConsumeStop stop)
            in cases) {
          final CommandConsumeReport r = await f;
          expect((r.stop, r.blocksOrders), (stop, false), reason: stop.name);
        }
        expect((reader.calls, pusher.calls.length), (0, 0));
      },
    );

    test('🔴 리스는 쥐었는데 명령 표를 못 읽음(답 실패 · 던짐) = 주문 막음 · ack 0', () async {
      reader.failWith = const CommandOpenResult.failed(
        CommandOpenFailure.network,
      );
      final CommandConsumeReport a = await run();
      expect(
        (a.stop, a.pullFailure, a.blocksOrders),
        (CommandConsumeStop.pullFailed, CommandOpenFailure.network, true),
      );
      reader
        ..failWith = null
        ..throwIt = true;
      final CommandConsumeReport b = await run();
      expect((b.stop, b.blocksOrders), (CommandConsumeStop.pullFailed, true));
      expect(pusher.calls, isEmpty);
      final CommandConsumeReport ok = await (() {
        reader.throwIt = false;
        return run();
      })();
      expect((ok.stop, ok.blocksOrders, ok.acks), (null, false, null));
    });
  });

  group('집행', () {
    test('🔴 뷰어 킬스위치 = 폰 버튼과 같은 처리기(채널 viewer) · 수신함 EXECUTED · ack 1행(정해진 id) · 다시 당김 = 다시 발동 0 · 같은 ack id', () async {
      final String id = _id();
      reader.rows = <Map<String, Object?>>[
        _row('KILL_SWITCH_ACTIVATE', id: id),
      ];
      final CommandConsumeReport r = await run();
      expect(
        (r.pulled, r.executed, r.killSwitchExecuted, r.acks!.outcome),
        (1, 1, 1, OpsPushOutcome.ok),
      );
      expect(killSwitchActive(readKillSwitchRecord(db)), isTrue);
      expect(
        db
            .select(
              "SELECT channel FROM kill_switch_event WHERE kind = 'ACTIVATED'",
            )
            .single['channel'],
        kRemoteKillSwitchChannel,
      );
      expect(
        (inbox(id)!['kind'], inbox(id)!['state']),
        ('KILL_SWITCH_ACTIVATE', 'EXECUTED'),
      );
      final ({
        String deviceId,
        int epoch,
        String table,
        List<Map<String, Object?>> rows,
      })
      call = pusher.calls.single;
      expect(
        (call.deviceId, call.epoch, call.table),
        ('op-phone-1', 3, OpsPushTables.commandAck),
      );
      expect(call.rows.single, <String, Object?>{
        'ack_id': commandAckId(id, CommandState.executed),
        'command_id': id,
        'state': 'EXECUTED',
        'state_label': inbox(id)!['state_label'],
        'reject_reason_code': null,
        'decision_id': inbox(id)!['decision_id'],
      });
      // 서버가 ack 를 아직 안 받은 척 — 같은 행이 다시 온다.
      final CommandConsumeReport again = await run();
      expect((again.executed, again.killSwitchExecuted), (0, 0));
      expect(
        count(
          "SELECT COUNT(*) FROM kill_switch_event WHERE kind = 'ACTIVATED'",
        ),
        1,
      );
      expect(
        lastAcks().single['ack_id'],
        commandAckId(id, CommandState.executed),
      );
    });

    test('열람 기록 = 수신함 1행(발행 시점 맥락 그대로) · 다시 당김 = PK 충돌 0 · 행 그대로', () async {
      final String id = _id();
      reader.rows = <Map<String, Object?>>[
        _row(
          'DISCLOSURE_VIEW',
          id: id,
          payload: DisclosureViewEvent(
            surfaceCode: DisclosureSurfaceCodes.values.first,
            viewedAt: DateTime.utc(2026, 12, 10, 0, 58),
          ).toJson(),
        ),
      ];
      final CommandConsumeReport r = await run();
      expect((r.executed, r.localFailed), (1, 0));
      final Map<String, Object?> row = inbox(id)!;
      expect(
        (
          row['kind'],
          row['state'],
          row['run_mode'],
          row['operating_mode'],
          row['lease_epoch'],
        ),
        ('DISCLOSURE_VIEW', 'EXECUTED', 'LIVE', 'AUTO_TRADE', 3),
      );
      final CommandConsumeReport again = await run();
      expect((again.executed, again.localFailed), (0, 0));
      expect(
        count(
          "SELECT COUNT(*) FROM command_inbox WHERE kind = 'DISCLOSURE_VIEW'",
        ),
        1,
      );
      expect(lastAcks().single['state'], 'EXECUTED');
    });

    test('사전 저널 · blind 점수 = 엔진 처리기의 판정 그대로(모르는 키 · 모르는 결정 = 처리기 거부 코드 · 수신함 · ack)', () async {
      final String j = _id();
      final String b = _id();
      reader.rows = <Map<String, Object?>>[
        _row('JOURNAL_DRAFT', id: j, payload: _journal('J-NONE')),
        _row(
          'BLIND_REVIEW_SCORE',
          id: b,
          payload: const BlindReviewScore(
            decisionId: 'D-NONE',
            answers: <String, int>{'PIT_INPUT': 1},
          ).toJson(),
        ),
      ];
      await run();
      expect(
        (inbox(j)!['state'], inbox(j)!['reject_reason_code']),
        ('REJECTED', 'JOURNAL_TARGET_UNKNOWN'),
      );
      expect(
        (inbox(b)!['state'], inbox(b)!['reject_reason_code']),
        ('REJECTED', BlindReviewRejectCodes.answersInvalid),
      );
      expect(
        lastAcks().map(
          (Map<String, Object?> a) =>
              (a['command_id'], a['state'], a['reject_reason_code']),
        ),
        <(Object?, Object?, Object?)>[
          (j, 'REJECTED', 'JOURNAL_TARGET_UNKNOWN'),
          (b, 'REJECTED', BlindReviewRejectCodes.answersInvalid),
        ],
      );
    });

    test('보관(무결성) → 풀림 뒤 당김 = 처리기 다시 → 집행 · 새 상태의 ack(다른 id)', () async {
      db.execute(
        'INSERT INTO decision_journal(journal_id, trade_date, strategy_id, signal_value, action_taken, '
        'is_deviation, rationale_before, expected_outcome, rule_cited, kind, note, created_at) '
        "VALUES ('J-R', '2026-12-09', 'P0S', '{}', '{}', 1, NULL, NULL, NULL, 'RECON_CLEAR', NULL, "
        "'2026-12-09T01:00:00.000Z')",
      );
      db.execute(
        'INSERT INTO trading_block (flag_id, set_at, reason) VALUES (?, ?, ?)',
        <Object?>[FlagIds.ledgerIntegrity, _t0.toIso8601String(), '시험'],
      );
      final String id = _id();
      reader.rows = <Map<String, Object?>>[
        _row('JOURNAL_DRAFT', id: id, payload: _journal('J-R')),
      ];
      final CommandConsumeReport held = await run();
      expect((held.held, held.executed), (1, 0));
      expect(
        lastAcks().single['ack_id'],
        commandAckId(id, CommandState.heldForIntegrity),
      );
      db.execute(
        'UPDATE trading_block SET cleared_at = ?, cleared_by = ? WHERE flag_id = ?',
        <Object?>[_t0.toIso8601String(), 'test', FlagIds.ledgerIntegrity],
      );
      clock.at = _t0.add(const Duration(minutes: 5));
      final CommandConsumeReport done = await run();
      expect((done.held, done.executed), (0, 1));
      expect(
        (lastAcks().single['ack_id'], lastAcks().single['state']),
        (commandAckId(id, CommandState.executed), 'EXECUTED'),
      );
      expect(
        db
            .select(
              "SELECT rationale_before FROM decision_journal WHERE journal_id = 'J-R'",
            )
            .single['rationale_before'],
        _rationale,
      );
    });
  });

  group('집행 0', () {
    test(
      '🔴 실행 모드 불일치 = 거부 ack(RUN_MODE_MISMATCH) · 원장 · 수신함 쓰기 0 · 킬스위치 꺼진 채',
      () async {
        final String id = _id();
        reader.rows = <Map<String, Object?>>[
          _row('KILL_SWITCH_ACTIVATE', id: id, runMode: 'SIM_INTERNAL'),
        ];
        final CommandConsumeReport r = await run();
        expect((r.refused, r.executed), (1, 0));
        expect(inbox(id), isNull);
        expect(killSwitchActive(readKillSwitchRecord(db)), isFalse);
        expect(lastAcks().single, <String, Object?>{
          'ack_id': commandAckId(id, CommandState.rejected),
          'command_id': id,
          'state': 'REJECTED',
          'state_label': RemoteCommandTexts.runModeMismatch,
          'reject_reason_code': CommandContextRejectCodes.runModeMismatch,
          'decision_id': null,
        });
      },
    );

    test('만료(신뢰 시각) = EXPIRED ack · 수신함 0 · 신뢰 시각 모름 = 집행', () async {
      final String id = _id();
      reader.rows = <Map<String, Object?>>[
        _row(
          'JOURNAL_DRAFT',
          id: id,
          payload: _journal('J-NONE'),
          expires: '2026-12-10T00:30:00+00:00',
        ),
      ];
      await run();
      expect(inbox(id), isNull);
      expect(
        (lastAcks().single['state'], lastAcks().single['ack_id']),
        ('EXPIRED', commandAckId(id, CommandState.expired)),
      );
      trusted.at = null;
      await run();
      expect(inbox(id)!['state'], 'REJECTED'); // 처리기 판정(모르는 키)
    });

    test('운영 폰 종류 = 소비 0 · ack 0 · 꼴 아님 · 같은 id 두 번 = 수만 세고 한 번만', () async {
      final String id = _id();
      reader.rows = <Map<String, Object?>>[
        _row('DEPOSIT_REGISTER'),
        _row('RECORD_MANUAL_FILL'),
        <String, Object?>{'command_id': 'x'},
        _row('KILL_SWITCH_ACTIVATE', id: id),
        _row('KILL_SWITCH_ACTIVATE', id: id),
      ];
      final CommandConsumeReport r = await run();
      expect((r.pulled, r.skipped, r.malformed, r.executed), (5, 2, 2, 1));
      expect(
        lastAcks().map((Map<String, Object?> a) => a['command_id']),
        <String>[id],
      );
    });

    test('처리기가 던짐 = 수신함 0 · ack 0 · 실패 수 · 다음 행은 그대로', () async {
      db.execute('ALTER TABLE kill_switch_event RENAME TO kill_switch_event_x');
      final String kill = _id();
      final String view = _id();
      reader.rows = <Map<String, Object?>>[
        _row('KILL_SWITCH_ACTIVATE', id: kill),
        _row(
          'DISCLOSURE_VIEW',
          id: view,
          payload: DisclosureViewEvent(
            surfaceCode: DisclosureSurfaceCodes.values.first,
            viewedAt: DateTime.utc(2026, 12, 10, 0, 58),
          ).toJson(),
        ),
      ];
      final CommandConsumeReport r = await run();
      expect((r.localFailed, r.executed), (1, 1));
      expect(inbox(kill), isNull);
      expect(
        lastAcks().map((Map<String, Object?> a) => a['command_id']),
        <String>[view],
      );
    });

    test('ack 보내기 실패 = 갈래 lag(수신함은 남음) · 다음 당김 = 같은 id 로 다시', () async {
      final String id = _id();
      reader.rows = <Map<String, Object?>>[
        _row('KILL_SWITCH_ACTIVATE', id: id),
      ];
      pusher.fail = const OpsPushResult.failed(OpsPushFailure.network);
      final CommandConsumeReport r = await run();
      expect((r.acks!.outcome, r.blocksOrders), (OpsPushOutcome.lag, false));
      expect(inbox(id)!['state'], 'EXECUTED');
      pusher.fail = null;
      final CommandConsumeReport again = await run();
      expect(again.acks!.outcome, OpsPushOutcome.ok);
      expect(pusher.calls.map((c) => c.rows.single['ack_id']).toSet(), <String>{
        commandAckId(id, CommandState.executed),
      });
    });
  });

  test('ack 열 ⊆ 배치 D command_ack · 서버가 덮는 칸(lease_epoch · acked_at) 0 · 보고 문자열에 행 값 0', () async {
    reader.rows = <Map<String, Object?>>[_row('KILL_SWITCH_ACTIVATE')];
    final CommandConsumeReport r = await run();
    final String sql = kSupabaseBatchDSql;
    final int at = sql.indexOf('create table if not exists command_ack (');
    final String body = sql.substring(at, sql.indexOf(');', at));
    for (final String k in lastAcks().single.keys) {
      expect(RegExp('\\b$k\\b').hasMatch(body), isTrue, reason: k);
    }
    expect(lastAcks().single.keys, isNot(contains('lease_epoch')));
    expect(lastAcks().single.keys, isNot(contains('acked_at')));
    expect(r.toString(), isNot(contains('viewer-ios-1')));
    expect(
      r.toString(),
      isNot(contains(lastAcks().single['command_id']! as String)),
    );
  });
}
