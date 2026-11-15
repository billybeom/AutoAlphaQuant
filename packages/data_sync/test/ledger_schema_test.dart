// E9c — 로컬 원장 스키마 v1(02 기본 + 배치 A·B·C·F 한 판) · 두 파일 · 한 트랜잭션(설계 13 §8 R19 · R20 · R21).
//
// 🔵 잡는 것: ① 새 설치가 한 판으로 서는가(표 · 번호 · 파일 식별 · 무결성) ② 다시 열면 재적용하지 않는가
//    ③ 중간 실패가 부분 상태를 남기지 않는가 ④ 다른 계열·더 새 판·식별 없는 파일을 거부하는가
//    ⑤ 파일별 CHECK 가 실제 DB 에서 막는가(mode · 명령 state · cash_flow · ledger_event · 수기 체결)
//    ⑥ 배치 사본이 `domain_contracts/ddl` 과 같은가 ⑦ 제어문 거르기 · `ATTACH` 0.

import 'dart:io';

import 'package:data_sync/data_sync.dart';
import 'package:data_sync/src/local/schema_v1_sql.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

DateTime _clock() => DateTime.utc(2026, 10, 21, 9);

int _tableCount(Database db) =>
    db
            .select(
              "SELECT count(*) AS n FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
            )
            .first['n']
        as int;

Object? _pragma(Database db, String name) =>
    db.select('PRAGMA $name').first.values.first;

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('aaq_schema_'));
  tearDown(() => dir.deleteSync(recursive: true));

  Database open(RunMode mode) {
    final Database db = openLocalLedger(dir.path, mode, clock: _clock);
    addTearDown(db.close);
    return db;
  }

  bool accepts(
    Database db,
    String sql, [
    List<Object?> args = const <Object?>[],
  ]) {
    try {
      db.execute(sql, args);
      return true;
    } on SqliteException {
      return false;
    }
  }

  group('새 설치', () {
    for (final (RunMode mode, LedgerFile file) in <(RunMode, LedgerFile)>[
      (RunMode.live, LedgerFile.live),
      (RunMode.simInternal, LedgerFile.sim),
    ]) {
      test(
        '${file.fileName} — 81표(🆕 v2.40 안전 통제 7표 · 🆕 v2.41 알림 3표 · 🆕 v2.42 job_run · 🆕 v2.43 resume_item · 🆕 v2.44 mode_transition · 🆕 v2.45 이전 저널 3표 · 정정 상세) · schema_version 1행 · application_id · 무결성',
        () {
          final Database db = open(mode);
          expect(
            _tableCount(db),
            81,
            reason: '02 기본 32 + 🆕 v2.40 안전 통제 7 + 🆕 v2.41 알림 3 + 🆕 v2.42 job_run 1 + 🆕 v2.43 resume_item 1 + 🆕 v2.44 mode_transition 1 + 🆕 v2.45 이전 저널 3 · 정정 상세 1 + 배치 신설 30(ledger_event 포함)',
          );
          expect(
            db
                .select(
                  "SELECT name FROM sqlite_master WHERE type = 'table' AND name LIKE 'alert_%' ORDER BY name",
                )
                .map((Row r) => r['name'])
                .toList(),
            <String>['alert_ack', 'alert_escalation', 'alert_event'],
          );
          expect(
            db
                .select(
                  "SELECT name FROM sqlite_master WHERE name IN ('job_run', 'ix_job_run_check', 'resume_item') ORDER BY name",
                )
                .map((Row r) => r['name'])
                .toList(),
            <String>['ix_job_run_check', 'job_run', 'resume_item'],
          );
          final ResultSet v = db.select(
            'SELECT version, applied_at, description FROM schema_version',
          );
          expect(v, hasLength(1));
          expect(v.first['version'], schemaVersion);
          expect(v.first['applied_at'], '2026-10-21T09:00:00.000Z');
          expect(v.first['description'] as String, contains(file.fileName));
          expect(_pragma(db, 'application_id'), file.applicationId);
          expect(_pragma(db, 'integrity_check'), 'ok');
          expect(_pragma(db, 'foreign_keys'), 1);
          expect(File('${dir.path}/${file.fileName}').existsSync(), isTrue);
        },
      );
    }

    test('simBroker 도 ledger_sim.sqlite 를 쓴다 — 두 SIM 모드가 한 파일', () {
      open(RunMode.simBroker).close();
      final Database again = open(RunMode.simInternal);
      expect(_pragma(again, 'application_id'), LedgerFile.sim.applicationId);
      expect(File('${dir.path}/ledger.sqlite').existsSync(), isFalse);
    });
  });

  test('다시 열면 재적용하지 않는다(ALTER ADD COLUMN 은 멱등이 아니다)', () {
    open(RunMode.live).close();
    final Database again = open(RunMode.live);
    expect(again.select('SELECT * FROM schema_version'), hasLength(1));
    expect(_tableCount(again), 81);
    expect(_pragma(again, 'foreign_keys'), 1, reason: 'FK 는 연결마다 다시 켠다');
  });

  test('중간 실패 → 표 0 · 식별 0 · 번호 0(부분 상태를 남기지 않는다)', () {
    final Database db = openLedgerDatabase('${dir.path}/ledger.sqlite');
    addTearDown(db.close);
    final List<String> scripts = ledgerSchemaV1Scripts(LedgerFile.live);
    expect(
      () => ensureLedgerSchema(
        db,
        LedgerFile.live,
        clock: _clock,
        // 배치 C 뒤 · F 앞에서 터진다 — A~C 가 남으면 실패다.
        scripts: <String>[
          ...scripts.take(4),
          'CREATE TABLE broken (',
          ...scripts.skip(4),
        ],
      ),
      throwsA(isA<SqliteException>()),
    );
    expect(_tableCount(db), 0);
    expect(_pragma(db, 'application_id'), 0);
    expect(db.autocommit, isTrue);
  });

  group('열지 않는 파일', () {
    test('다른 계열 — SIM 파일을 LIVE 로 열면 거부', () {
      final Database sim = openLedgerDatabase('${dir.path}/x.sqlite');
      ensureLedgerSchema(sim, LedgerFile.sim, clock: _clock);
      sim.close();
      final Database live = openLedgerDatabase('${dir.path}/x.sqlite');
      addTearDown(live.close);
      expect(
        () => ensureLedgerSchema(live, LedgerFile.live, clock: _clock),
        throwsA(
          isA<StateError>().having(
            (StateError e) => e.message,
            'message',
            contains('다른 계열'),
          ),
        ),
      );
    });

    test('더 새 판 — schema_version 2 가 있으면 앱을 되돌린 채 열지 않는다', () {
      final Database db = open(RunMode.live);
      db.execute(
        "INSERT INTO schema_version (version, applied_at, description) VALUES (2, 'x', 'future')",
      );
      db.close();
      expect(
        () => openLocalLedger(dir.path, RunMode.live, clock: _clock),
        throwsA(
          isA<StateError>().having(
            (StateError e) => e.message,
            'message',
            contains('더 새 판'),
          ),
        ),
      );
    });

    test('식별 없는 표 — 앱이 만들지 않은 파일은 열지 않는다', () {
      final Database db = openLedgerDatabase('${dir.path}/ledger.sqlite');
      db.execute('CREATE TABLE stray (x INTEGER)');
      db.close();
      expect(
        () => openLocalLedger(dir.path, RunMode.live, clock: _clock),
        throwsA(
          isA<StateError>().having(
            (StateError e) => e.message,
            'message',
            contains('식별'),
          ),
        ),
      );
    });
  });

  group('파일별 CHECK — 실제 DB', () {
    const String decision =
        'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, '
        "reason, reason_code, config_hash) VALUES (?, 't', '2026-10-20', ?, 'MANUAL', 's', 'r', 'c', 'h')";
    const String calendar =
        "INSERT INTO calendar_link (mode, google_calendar_id, created_at) VALUES (?, 'g', 't')";
    const String advice =
        'INSERT INTO advice (advice_id, batch_id, decision_id, mode, trade_date, valid_until_date, kind, '
        "sleeve, reason, reason_code, status, sizing_label, config_hash, created_at) VALUES (?, 'b', 'd', ?, "
        "'2026-10-20', '2026-10-21', 'ENTRY', 'A', 'r', 'c', 'OPEN', 'l', 'h', 't')";

    test('mode — LIVE 파일은 LIVE 만 · SIM 파일은 SIM 계열만 · 안내는 SIM_INTERNAL 만', () {
      final Database live = open(RunMode.live);
      expect(accepts(live, decision, <Object?>['d1', 'LIVE']), isTrue);
      for (final String m in <String>['SIM_INTERNAL', 'SIM_BROKER', 'SIM']) {
        expect(
          accepts(live, decision, <Object?>['d_$m', m]),
          isFalse,
          reason: m,
        );
      }
      expect(
        accepts(live, decision, <Object?>['d_null', null]),
        isFalse,
        reason: '기본값 없음 — 명시 필수',
      );
      expect(accepts(live, calendar, <Object?>['LIVE']), isTrue);
      expect(accepts(live, calendar, <Object?>['SIM']), isFalse);

      final Database sim = open(RunMode.simInternal);
      expect(accepts(sim, decision, <Object?>['d1', 'SIM_INTERNAL']), isTrue);
      expect(accepts(sim, decision, <Object?>['d2', 'SIM_BROKER']), isTrue);
      expect(accepts(sim, decision, <Object?>['d3', 'LIVE']), isFalse);
      expect(accepts(sim, calendar, <Object?>['SIM']), isTrue);
      expect(accepts(sim, calendar, <Object?>['LIVE']), isFalse);
      expect(accepts(sim, advice, <Object?>['a1', 'SIM_INTERNAL']), isTrue);
      expect(
        accepts(sim, advice, <Object?>['a2', 'SIM_BROKER']),
        isFalse,
        reason: 'simBroker × advisory 는 정의 모순(§10-2 #7·#8)',
      );
    });

    test('command_inbox.state = CommandState − REQUESTED', () {
      final Database db = open(RunMode.live);
      for (final CommandState s in CommandState.values) {
        expect(
          accepts(
            db,
            'INSERT INTO command_inbox (command_id, kind, ingested_at, state, state_label, payload_digest) '
            "VALUES (?, 'JOURNAL_DRAFT', 't', ?, 'l', 'p')",
            <Object?>['c_${s.wire}', s.wire],
          ),
          s != CommandState.requested,
          reason: s.wire,
        );
      }
    });

    test('cash_flow.kind = CashFlowKind 5값 · ledger_event 의 역분개 짝', () {
      final Database db = open(RunMode.live);
      for (final CashFlowKind k in CashFlowKind.values) {
        expect(
          accepts(
            db,
            "INSERT INTO cash_flow (flow_id, trade_date, amount, kind) VALUES (?, '2026-10-20', 1, ?)",
            <Object?>['f_${k.wire}', k.wire],
          ),
          isTrue,
          reason: k.wire,
        );
      }
      expect(
        accepts(
          db,
          "INSERT INTO cash_flow (flow_id, trade_date, amount, kind) VALUES ('f_x', 'd', 1, 'DIVIDEND')",
        ),
        isFalse,
      );
      const String event =
          'INSERT INTO ledger_event (event_id, kind, entry_kind, reverses_event_id, effective_date, '
          'account_alias, amount_krw, decision_id, command_id, authored_by_device_id, authored_at) '
          "VALUES (?, ?, ?, ?, '2026-10-20', '일반', 1000, 'd', 'c', 'dev', 't')";
      for (final LedgerEventKind k in LedgerEventKind.values) {
        expect(
          accepts(db, event, <Object?>[
            'e_${k.wire}',
            k.wire,
            'ORIGINAL',
            null,
          ]),
          isTrue,
          reason: k.wire,
        );
      }
      expect(
        accepts(db, event, <Object?>[
          'e_r',
          'WITHDRAWAL',
          'REVERSAL',
          'e_WITHDRAWAL',
        ]),
        isTrue,
      );
      expect(
        accepts(db, event, <Object?>['e_r2', 'WITHDRAWAL', 'REVERSAL', null]),
        isFalse,
      );
      expect(
        accepts(db, event, <Object?>['e_o2', 'WITHDRAWAL', 'ORIGINAL', 'e_x']),
        isFalse,
      );
    });

    test('배치 G(계약 v1.14 · 설계 13 §8 R25) — market_series · fetch_log · 원천 CHECK · 국면 행 source', () {
      final Database db = open(RunMode.live);
      db.execute(
        'INSERT INTO market_series (series_id, obs_date, value, source, fetched_at) '
        "VALUES ('NFCI', '2026-10-16', -0.52, 'FRED', 't')",
      );
      expect(
        accepts(
          db,
          'INSERT INTO market_series (series_id, obs_date, value, source, fetched_at) '
          "VALUES ('NFCI', '2026-10-16', -0.5, 'FRED', 't')",
        ),
        isFalse,
        reason: 'PK(series_id, obs_date)',
      );
      expect(
        accepts(
          db,
          'INSERT INTO market_series (series_id, obs_date, value, source, fetched_at) '
          "VALUES ('NFCI', '2026-10-23', NULL, 'FRED', 't')",
        ),
        isFalse,
        reason: '결측은 행 없음 — 값 NULL 금지',
      );
      expect(
        accepts(
          db,
          'INSERT INTO market_series (series_id, obs_date, value, source, fetched_at) '
          "VALUES ('VIX', '2026-10-23', 15, 'YAHOO', 't')",
        ),
        isFalse,
        reason: '원천은 MarketDataSource 6값만',
      );
      for (final MarketDataSource src in MarketDataSource.values) {
        expect(
          accepts(
            db,
            'INSERT INTO fetch_log (fetch_id, source, request_kind, row_count, fetched_at, outcome) '
            "VALUES (?, ?, 'SERIES', 0, 't', 'EMPTY')",
            <Object?>['f_${src.wire}', src.wire],
          ),
          isTrue,
          reason: src.wire,
        );
      }
      expect(
        accepts(
          db,
          'INSERT INTO fetch_log (fetch_id, source, request_kind, row_count, fetched_at, outcome) '
          "VALUES ('f_x', 'KIS', 'KR_DAILY', 1, 't', 'PARTIAL')",
        ),
        isFalse,
        reason: '결과는 OK · EMPTY · FAILED',
      );
      final List<String> priceCols = <String>[
        for (final Row r in db.select('PRAGMA table_info(daily_prices)'))
          r['name'] as String,
      ];
      expect(priceCols, containsAll(<String>['source', 'fetched_at']));
      expect(
        accepts(
          db,
          'INSERT INTO daily_prices (trade_date, market, symbol, open, high, low, close, volume, source) '
          "VALUES ('2026-10-23', 'KR', '133690', 1, 1, 1, 1, 0, 'KIS')",
        ),
        isTrue,
      );
      expect(
        accepts(
          db,
          'INSERT INTO daily_prices (trade_date, market, symbol, open, high, low, close, volume, source) '
          "VALUES ('2026-10-24', 'KR', '133690', 1, 1, 1, 1, 0, 'YAHOO')",
        ),
        isFalse,
      );
      db.execute(
        "INSERT INTO regime_score_daily (trade_date, status, config_hash) VALUES ('2026-10-23', 'OK', 'cfg')",
      );
      expect(
        db.select('SELECT source FROM regime_score_daily').single['source'],
        'LIVE',
        reason: '기본 LIVE · 갭일 재계산 행만 BACKFILL(X2-4)',
      );
      expect(
        accepts(
          db,
          "INSERT INTO regime_score_daily (trade_date, status, config_hash, source) VALUES ('2026-10-24', 'OK', 'cfg', 'GUESS')",
        ),
        isFalse,
      );
    });

    test('cash_flow.account_alias — 입금은 계좌별 행(계약 v1.11 · 설계 13 §8 R22 D6)', () {
      final Database db = open(RunMode.live);
      expect(
        db
            .select('PRAGMA table_info(cash_flow)')
            .map((Row r) => r['name'] as String),
        containsAll(<String>[
          'account_alias',
          'source_event_id',
          'recorded_at',
        ]),
        reason: '배치 F 재작성(5값) 뒤에도 계좌 칸이 남는다.',
      );
      db.execute(
        'INSERT INTO cash_flow (flow_id, trade_date, amount, kind, account_alias) VALUES '
        "('f_p', '2026-10-22', 400000, 'DEPOSIT', '연금저축'), "
        "('f_g', '2026-10-22', 600000, 'DEPOSIT', '일반')",
      );
      expect(
        db
            .select(
              "SELECT account_alias, SUM(amount) AS s FROM cash_flow WHERE kind = 'DEPOSIT' "
              'GROUP BY account_alias ORDER BY account_alias',
            )
            .map((Row r) => '${r['account_alias']}=${r['s']}'),
        <String>['연금저축=400000.0', '일반=600000.0'],
        reason: '계좌별 합 = 연금 납입 누계(R22 D7)·계좌별 현금 대사의 원천.',
      );
    });

    test('수기 체결 — MANUAL ⇔ broker_order_no NULL(R20 Q2)', () {
      final Database db = open(RunMode.live);
      const String fill =
          'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, fill_origin) '
          "VALUES (?, ?, 't', 1, 100, ?)";
      expect(accepts(db, fill, <Object?>['x1', null, 'MANUAL']), isTrue);
      expect(accepts(db, fill, <Object?>['x2', null, 'BROKER']), isFalse);
      expect(
        accepts(db, fill, <Object?>['x3', null, 'SIMULATED']),
        isFalse,
        reason: '모의는 모의 브로커 주문이 있다',
      );
      expect(
        db
            .select('PRAGMA table_info(executions)')
            .firstWhere((Row r) => r['name'] == 'broker_order_no')['notnull'],
        0,
      );
    });
  });

  group('자산', () {
    test('배치 사본 = domain_contracts/ddl 원문(바이트)', () {
      expect(kLocalBatchSql.map(((String, String) b) => b.$1), <String>[
        'batch_a_decision_mode.sql',
        'batch_b_plan_command.sql',
        'batch_c_x2_x5_local.sql',
        'batch_f_x7_advisory.sql',
        'batch_g_market_data.sql',
      ]);
      for (final (String name, String sql) in kLocalBatchSql) {
        expect(
          sql,
          File('../domain_contracts/ddl/$name').readAsStringSync(),
          reason: '$name — tool/make_local_schema.py 를 다시 돌린다',
        );
      }
    });

    test('02 기본 — PRAGMA 블록·§2-7 이후 배치 블록은 빠지고 executions.broker_order_no 는 NULL 허용(R20 Q2)', () {
      expect(kBase02Sql, isNot(contains('PRAGMA journal_mode')));
      expect(kBase02Sql, contains('CREATE TABLE IF NOT EXISTS schema_version'));
      // 🔴 SPEC v2.33 부터 02 에 배치 블록이 같이 실린다 — 기본 자산에 두 번 담기면 ALTER 가 중복으로 실패한다.
      expect(
        kBase02Sql,
        isNot(contains('CREATE TABLE IF NOT EXISTS decision_log')),
      );
      final int at = kBase02Sql.indexOf(
        'CREATE TABLE IF NOT EXISTS executions',
      );
      final String executions = kBase02Sql.substring(
        at,
        kBase02Sql.indexOf(');', at),
      );
      expect(executions, contains('broker_order_no TEXT,'));
      expect(executions, isNot(contains('broker_order_no TEXT NOT NULL')));
    });

    test('제어문 거르기 — 표준 꼴은 지우고 다른 꼴은 거부한다', () {
      expect(
        stripControlStatements(
          'PRAGMA foreign_keys = OFF;\nBEGIN TRANSACTION;\nCREATE TABLE t (x INT);\nCOMMIT;',
        ),
        'CREATE TABLE t (x INT);',
      );
      for (final String bad in <String>[
        'BEGIN;',
        'pragma foreign_keys=off;',
        'ATTACH DATABASE \'x\' AS y;',
      ]) {
        expect(
          () => stripControlStatements(bad),
          throwsA(isA<FormatException>()),
          reason: bad,
        );
      }
      // 주석 속 낱말과 COMMITTED 같은 값은 제어문이 아니다.
      expect(
        stripControlStatements(
          "-- BEGIN 은 주석이다\nCREATE TABLE t (c TEXT CHECK (c IN ('COMMITTED')));",
        ),
        contains('COMMITTED'),
      );
    });

    test('ATTACH 0 — 두 파일을 한 연결에 묶는 코드가 없다(01 §9-2)', () {
      for (final FileSystemEntity f in Directory(
        'lib',
      ).listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final String code = f
            .readAsLinesSync()
            .map((String l) => l.replaceAll(RegExp('//.*'), ''))
            .join('\n');
        expect(
          RegExp(r'''['"]\s*ATTACH\b''', caseSensitive: false).hasMatch(code),
          isFalse,
          reason: f.path,
        );
      }
    });
  });
}
