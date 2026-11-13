// E14c1 — 잡 실행 기록 저장 · 질의(설계 13 §8 R73 K6 · 02 v2.42 `job_run`).
//
// 🔵 잡는 것: ① 1행 칸 값 · 되읽기 ② 같은 rid = 한 번만(덮지 않음) ③ 입력 검사(빈칸 · 날짜 꼴 · 끝 < 시작) ·
//    DDL CHECK ④ 마지막 성공 = SUCCESS · LATE 의 가장 늦은 세션(FAILED · HOLIDAY 빼고) · 없으면 null ·
//    운영 모드 4벌 · 다른 잡 · 비슷한 이름 · `_` 와일드카드 0 ⑤ «돈» 세션 = SUCCESS · LATE · HOLIDAY · from 포함 ·
//    중복 0 · 오름차순 ⑥ 잡 이름 검사 ⑦ 오프셋 없는 시각 = FormatException
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

final DateTime _t0 = DateTime.utc(2026, 11, 13, 1);

JobRunEntry _e(
  String rid,
  String check,
  String day,
  JobRunStatus status, {
  int startMin = 0,
  int endMin = 5,
}) => JobRunEntry(
  rid: rid,
  checkName: check,
  sessionDay: TradeDate(day),
  startedAtUtc: _t0.add(Duration(minutes: startMin)),
  finishedAtUtc: _t0.add(Duration(minutes: endMin)),
  status: status,
);

void main() {
  late Directory dir;
  late Database db;
  late SqliteJobRunLog log;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_jobrun_');
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    log = SqliteJobRunLog(db);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  test('1행 칸 값 · 되읽기 · 같은 rid = 한 번만(덮지 않음)', () async {
    await log.record(
      _e('r1', 'live-auto-equity_snapshot', '2026-11-12', JobRunStatus.late),
    );
    await log.record(
      _e('r1', 'live-auto-equity_snapshot', '2026-11-13', JobRunStatus.failed),
    );
    final Row row = db.select('SELECT * FROM job_run').single;
    expect(row['rid'], 'r1');
    expect(row['check_name'], 'live-auto-equity_snapshot');
    expect(row['session_day'], '2026-11-12');
    expect(row['started_at'], '2026-11-13T01:00:00.000Z');
    expect(row['finished_at'], '2026-11-13T01:05:00.000Z');
    expect(row['status'], 'LATE');
    final JobRunEntry back = log.entriesOf('equity_snapshot').single;
    expect(back.rid, 'r1');
    expect(back.status, JobRunStatus.late);
    expect(back.sessionDay, const TradeDate('2026-11-12'));
    expect(back.startedAtUtc, _t0);
    expect(back.finishedAtUtc, _t0.add(const Duration(minutes: 5)));
  });

  test('입력 검사 — 빈칸 · 날짜 꼴 · 끝 < 시작 · DDL CHECK', () async {
    expect(
      () => log.record(
        _e(' ', 'live-auto-x', '2026-11-12', JobRunStatus.success),
      ),
      throwsArgumentError,
    );
    expect(
      () => log.record(_e('r', '', '2026-11-12', JobRunStatus.success)),
      throwsArgumentError,
    );
    expect(
      () =>
          log.record(_e('r', 'live-auto-x', '20261112', JobRunStatus.success)),
      throwsArgumentError,
    );
    expect(
      () => log.record(
        _e('r', 'live-auto-x', '2026-11-12', JobRunStatus.success, startMin: 6),
      ),
      throwsArgumentError,
    );
    expect(
      () => db.execute(
        "INSERT INTO job_run VALUES ('z', 'c', '2026-11-12', 'a', 'b', 'DONE')",
      ),
      throwsA(isA<SqliteException>()),
    );
    expect(db.select('SELECT * FROM job_run'), isEmpty);
  });

  test(
    '🔴 마지막 성공 = SUCCESS · LATE 의 가장 늦은 세션 · 운영 모드 4벌 · 다른 잡 · 비슷한 이름 제외',
    () async {
      expect(log.lastSuccessSession('equity_snapshot'), isNull);
      for (final JobRunEntry e in <JobRunEntry>[
        _e(
          'a',
          'live-auto-equity_snapshot',
          '2026-11-09',
          JobRunStatus.success,
        ),
        _e(
          'b',
          'live-advisory-equity_snapshot',
          '2026-11-10',
          JobRunStatus.late,
        ),
        _e('c', 'live-auto-equity_snapshot', '2026-11-11', JobRunStatus.failed),
        _e(
          'd',
          'live-auto-equity_snapshot',
          '2026-11-12',
          JobRunStatus.holiday,
        ),
        _e('e', 'live-auto-daily_data', '2026-11-13', JobRunStatus.success),
        _e(
          'f',
          'live-auto-xequity_snapshot',
          '2026-11-14',
          JobRunStatus.success,
        ),
        _e(
          'g',
          'live-auto-equity_snapshot2',
          '2026-11-15',
          JobRunStatus.success,
        ),
        _e(
          'h',
          'live-auto-equityXsnapshot',
          '2026-11-16',
          JobRunStatus.success,
        ),
      ]) {
        await log.record(e);
      }
      expect(
        log.lastSuccessSession('equity_snapshot'),
        const TradeDate('2026-11-10'),
      );
      await log.record(
        _e(
          'i',
          'sim-advisory-equity_snapshot',
          '2026-11-17',
          JobRunStatus.success,
        ),
      );
      await log.record(
        _e('j', 'sim-auto-equity_snapshot', '2026-11-16', JobRunStatus.success),
      );
      expect(
        log.lastSuccessSession('equity_snapshot'),
        const TradeDate('2026-11-17'),
      );
      expect(
        log.lastSuccessSession('daily_data'),
        const TradeDate('2026-11-13'),
      );
    },
  );

  test('«돈» 세션 = SUCCESS · LATE · HOLIDAY · from 포함 · 중복 0 · 오름차순', () async {
    for (final JobRunEntry e in <JobRunEntry>[
      _e('a', 'live-auto-kr_order', '2026-11-06', JobRunStatus.success),
      _e('b', 'live-auto-kr_order', '2026-11-09', JobRunStatus.failed),
      _e('c', 'live-auto-kr_order', '2026-11-09', JobRunStatus.late),
      _e('d', 'live-auto-kr_order', '2026-11-07', JobRunStatus.holiday),
      _e('e', 'live-auto-kr_order', '2026-11-10', JobRunStatus.failed),
      _e('f', 'live-auto-kr_order', '2026-11-05', JobRunStatus.success),
      _e('g', 'sim-auto-kr_order', '2026-11-11', JobRunStatus.success),
      _e('h', 'live-auto-kr_order_close', '2026-11-12', JobRunStatus.success),
      // 같은 세션에 «돈» 회차가 둘(운영 모드가 바뀐 날) — 한 번만 나온다.
      _e('i', 'live-advisory-kr_order', '2026-11-06', JobRunStatus.late),
    ]) {
      await log.record(e);
    }
    expect(
      log.doneSessions('kr_order', from: const TradeDate('2026-11-06')),
      <TradeDate>[
        const TradeDate('2026-11-06'),
        const TradeDate('2026-11-07'),
        const TradeDate('2026-11-09'),
        const TradeDate('2026-11-11'),
      ],
    );
    expect(
      () => log.doneSessions('kr_order', from: const TradeDate('11-06')),
      throwsArgumentError,
    );
  });

  test('잡 이름 검사 — 빈칸 · `-` = 오류', () {
    expect(() => log.lastSuccessSession(''), throwsArgumentError);
    expect(
      () => log.lastSuccessSession('live-auto-kr_order'),
      throwsArgumentError,
    );
    expect(() => log.entriesOf(' '), throwsArgumentError);
  });

  test('오프셋 없는 시각 = FormatException', () {
    db.execute(
      "INSERT INTO job_run VALUES ('z', 'live-auto-kr_order', '2026-11-12', "
      "'2026-11-12T00:00:00', '2026-11-12T00:01:00Z', 'SUCCESS')",
    );
    expect(() => log.entriesOf('kr_order'), throwsFormatException);
  });
}
