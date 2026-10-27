// 수집 기록 — `fetch_log`(설계 13 §8 R23 D7·D10 · R25 G2 · E8c).
//
// 🔴 응답 원문은 저장하지 않는다 — 본문 sha256 만(`body_sha256`). `detail` 은 엔진이 지은 문장이다: 요청 주소·헤더·
//    키·토큰을 넣지 않는다(FRED 주소에는 `api_key` 가 들어간다 — 주소를 통째로 남기면 키가 원장에 남는다).
// 🔵 `fetch_id` 는 호출자가 짓는다 — 같은 수집을 두 번 기록하면 두 번째는 무시된다(INSERT OR IGNORE · 재실행 멱등).

import 'package:domain_contracts/domain_contracts.dart' show MarketDataSource;
import 'package:sqlite3/sqlite3.dart';

/// `fetch_log.outcome`.
enum FetchOutcome {
  /// 받았고 행이 있다.
  ok('OK'),

  /// 받았는데 새 행이 없다(휴장 · 아직 발표 전).
  empty('EMPTY'),

  /// 끝내 받지 못했다(재시도·폴백 뒤).
  failed('FAILED');

  const FetchOutcome(this.wire);

  /// 기록 값.
  final String wire;
}

/// 수집 한 번의 기록.
class FetchRecord {
  const FetchRecord({
    required this.fetchId,
    required this.source,
    required this.requestKind,
    required this.rowCount,
    required this.fetchedAt,
    required this.outcome,
    this.asOf,
    this.bodySha256,
    this.detail,
  });

  final String fetchId;
  final MarketDataSource source;

  /// `KR_DAILY` · `US_DAILY` · `SERIES` · `SEED` …
  final String requestKind;

  /// 요청한 기준일(없으면 null).
  final String? asOf;

  /// 새로 쓴 행 수.
  final int rowCount;

  /// 응답 본문 sha256(실패면 null).
  final String? bodySha256;

  /// ISO8601 UTC.
  final String fetchedAt;
  final FetchOutcome outcome;

  /// 엔진 문장(키·토큰·주소 금지).
  final String? detail;
}

/// 로컬 원장 파일의 수집 기록.
final class SqliteFetchLog {
  SqliteFetchLog(this._db);

  final Database _db;

  /// 기록한다 — 같은 `fetch_id` 가 있으면 무시하고 false.
  bool record(FetchRecord r) {
    _db.execute(
      'INSERT INTO fetch_log (fetch_id, source, request_kind, as_of, row_count, body_sha256, '
      'fetched_at, outcome, detail) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) '
      'ON CONFLICT (fetch_id) DO NOTHING',
      <Object?>[
        r.fetchId,
        r.source.wire,
        r.requestKind,
        r.asOf,
        r.rowCount,
        r.bodySha256,
        r.fetchedAt,
        r.outcome.wire,
        r.detail,
      ],
    );
    return _db.updatedRows == 1;
  }

  /// 기록 전부(시각 순).
  List<FetchRecord> all() => <FetchRecord>[
    for (final Row r in _db.select(
      'SELECT * FROM fetch_log ORDER BY fetched_at, fetch_id',
    ))
      FetchRecord(
        fetchId: r['fetch_id'] as String,
        source: MarketDataSource.values.firstWhere(
          (MarketDataSource s) => s.wire == r['source'],
        ),
        requestKind: r['request_kind'] as String,
        asOf: r['as_of'] as String?,
        rowCount: r['row_count'] as int,
        bodySha256: r['body_sha256'] as String?,
        fetchedAt: r['fetched_at'] as String,
        outcome: FetchOutcome.values.firstWhere(
          (FetchOutcome o) => o.wire == r['outcome'],
        ),
        detail: r['detail'] as String?,
      ),
  ];
}
