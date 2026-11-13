// 잡 실행 기록 저장 · 질의(02 v2.42 `job_run` · 04 §3-1 v2.42 ④ · 설계 13 §8 R70 D4 · R73 K6).
//
// 🔴 덧붙이기만 — 같은 `rid` = 한 번만(덮지 않는다 · 회차 id 는 체크 · 시작 시각의 결정적 값).
// 🔴 «마지막 성공 거래일» = 그 잡의 SUCCESS · LATE 가운데 가장 늦은 세션일(재개 갭의 기준 — `equity_snapshot`).
// 🔴 잡 → 체크 이름 4벌(`{sim|live}-{auto|advisory}-{잡}`)을 정확히 맞춘다 — 운영 모드가 바뀌어도 같은 모드 파일 안의
//    기록을 다 본다 · LIKE(`_` 와일드카드)를 쓰지 않는다.
// 🔴 해시 모집단 밖(원장 사실이 아니다).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show TradeDate;
import 'package:sqlite3/sqlite3.dart';

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');
final RegExp _day = RegExp(r'^\d{4}-\d{2}-\d{2}$');

DateTime _instant(String v) {
  if (!_offset.hasMatch(v)) throw FormatException('시각에 오프셋 없음', v);
  return DateTime.parse(v).toUtc();
}

void _checkDay(TradeDate d) {
  if (!_day.hasMatch(d.yyyyMmDd)) {
    throw ArgumentError.value(d.yyyyMmDd, 'sessionDay', 'YYYY-MM-DD 가 아니다');
  }
}

/// [job] 의 체크 이름 4벌 — 빈칸 · `-` 가 든 잡 이름 = [ArgumentError].
List<String> _checksOf(String job) {
  if (job.trim().isEmpty || job.contains('-')) {
    throw ArgumentError.value(job, 'job', '잡 이름이 아니다');
  }
  return <String>[
    for (final String r in <String>['sim', 'live'])
      for (final String o in <String>['auto', 'advisory']) '$r-$o-$job',
  ];
}

String _wires(bool Function(JobRunStatus s) keep) => JobRunStatus.values
    .where(keep)
    .map((JobRunStatus s) => "'${s.wire}'")
    .join(', ');

/// 잡 실행 기록(R73 K6).
class SqliteJobRunLog implements JobRunLog {
  /// 기록기를 만든다.
  SqliteJobRunLog(this._db);

  final Database _db;

  @override
  Future<void> record(JobRunEntry entry) async {
    if (entry.rid.trim().isEmpty || entry.checkName.trim().isEmpty) {
      throw ArgumentError('rid · 체크 이름이 비었다');
    }
    _checkDay(entry.sessionDay);
    if (entry.finishedAtUtc.isBefore(entry.startedAtUtc)) {
      throw ArgumentError('끝이 시작보다 앞이다');
    }
    _db.execute(
      'INSERT INTO job_run (rid, check_name, session_day, started_at, finished_at, status) '
      'VALUES (?, ?, ?, ?, ?, ?) ON CONFLICT (rid) DO NOTHING',
      <Object?>[
        entry.rid,
        entry.checkName,
        entry.sessionDay.yyyyMmDd,
        entry.startedAtUtc.toUtc().toIso8601String(),
        entry.finishedAtUtc.toUtc().toIso8601String(),
        entry.status.wire,
      ],
    );
  }

  /// [job] 의 마지막 성공 세션일(SUCCESS · LATE) — 없으면 null.
  TradeDate? lastSuccessSession(String job) {
    final List<String> c = _checksOf(job);
    final ResultSet rs = _db.select(
      'SELECT MAX(session_day) AS d FROM job_run '
      'WHERE check_name IN (?, ?, ?, ?) '
      'AND status IN (${_wires((JobRunStatus s) => s.succeeded)})',
      c,
    );
    final Object? d = rs.first['d'];
    return d == null ? null : TradeDate(d as String);
  }

  /// [job] 의 «돈» 세션일(SUCCESS · LATE · HOLIDAY) — [from] 이상(포함) · 오름차순.
  List<TradeDate> doneSessions(String job, {required TradeDate from}) {
    _checkDay(from);
    final List<String> c = _checksOf(job);
    return _db
        .select(
          'SELECT DISTINCT session_day FROM job_run '
          'WHERE check_name IN (?, ?, ?, ?) '
          'AND status IN (${_wires((JobRunStatus s) => s.done)}) '
          'AND session_day >= ? ORDER BY session_day',
          <Object?>[...c, from.yyyyMmDd],
        )
        .map((Row r) => TradeDate(r['session_day'] as String))
        .toList();
  }

  /// [job] 의 기록 전부(세션일 · 시작 차례) — 오프셋 없는 시각 = [FormatException].
  List<JobRunEntry> entriesOf(String job) {
    final List<String> c = _checksOf(job);
    return _db
        .select(
          'SELECT rid, check_name, session_day, started_at, finished_at, status '
          'FROM job_run WHERE check_name IN (?, ?, ?, ?) '
          'ORDER BY session_day, started_at, rid',
          c,
        )
        .map(
          (Row r) => JobRunEntry(
            rid: r['rid'] as String,
            checkName: r['check_name'] as String,
            sessionDay: TradeDate(r['session_day'] as String),
            startedAtUtc: _instant(r['started_at'] as String),
            finishedAtUtc: _instant(r['finished_at'] as String),
            status: JobRunStatus.values.firstWhere(
              (JobRunStatus s) => s.wire == r['status'],
            ),
          ),
        )
        .toList();
  }
}
