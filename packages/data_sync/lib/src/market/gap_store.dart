// 결측 기록 — `data_gap`(설계 13 §8 R23 D4·D10 · R24 B5 · R25 G4 · R26 H5 · E8c).
//
// 🔴 사유 글자 = 계약 사전 `GapReasonCodes`(= core_engine `DataGapCause.wire`) — 사전 밖 글자를 쓰지 않는다.
// 🔴 `gap_id` = `{dataset}:{key}:{from_date}:{reason}`(결정적) — 같은 결측을 다시 기록하면 행이 늘지 않고 끝날짜만
//    늘어난다(재실행 멱등 · 잡 유예 2h 안 재실행 · D10). 표에 종목 칸이 없어서 종목은 이 id 에 들어간다.
// 🔴 시세·지표는 원천에 이력이 남아 다시 받을 수 있다 → `recoverable = 1`(다음 성공 수집이 소급 — D10).
// 🔵 KR 판정의 «캘린더 의심»은 `dataset = calendar`(표 자동 수정 금지 — 사람이 덮어쓰기 목록 PR 로 고친다 · D14).

import 'package:core_engine/core_engine.dart'
    show DataGapCause, DataIssue, KrDayVerdict;
import 'package:sqlite3/sqlite3.dart';

/// `data_gap.dataset`(E8 몫).
enum GapDataset {
  /// 국내 일봉(계획 대상 종목 · 지수).
  prices('prices'),

  /// 미국·매크로 계열(FRED · OFR · VIX …).
  macro('macro'),

  /// 국면 행.
  regime('regime'),

  /// 캘린더 의심.
  calendar('calendar');

  const GapDataset(this.wire);

  /// 기록 값.
  final String wire;
}

/// 결측 한 행.
class StoredGap {
  const StoredGap({
    required this.gapId,
    required this.dataset,
    required this.fromDate,
    required this.toDate,
    required this.recoverable,
    required this.reasonCode,
    required this.detectedAt,
  });

  final String gapId, dataset, fromDate, toDate;
  final bool recoverable;
  final String reasonCode, detectedAt;
}

/// 로컬 원장 파일의 결측 기록.
final class SqliteGapStore {
  SqliteGapStore(this._db);

  final Database _db;

  /// 결측 하나를 기록한다(있으면 끝날짜만 늘린다) — 결정적 `gap_id` 를 돌려준다.
  String record({
    required GapDataset dataset,
    required String key,
    required String fromDate,
    required String toDate,
    required DataGapCause cause,
    required String detectedAt,
  }) {
    final String id = '${dataset.wire}:$key:$fromDate:${cause.wire}';
    _db.execute(
      'INSERT INTO data_gap (gap_id, dataset, from_date, to_date, recoverable, reason_code, detected_at) '
      'VALUES (?, ?, ?, ?, 1, ?, ?) '
      'ON CONFLICT (gap_id) DO UPDATE SET to_date = MAX(to_date, excluded.to_date)',
      <Object>[id, dataset.wire, fromDate, toDate, cause.wire, detectedAt],
    );
    return id;
  }

  /// KR 판정일의 결측 전부 — 캘린더 의심은 `calendar` · 나머지는 `prices`.
  List<String> recordKrVerdict(KrDayVerdict v, {required String detectedAt}) =>
      <String>[
        for (final DataIssue i in v.issues)
          record(
            dataset: i.cause == DataGapCause.calendarSuspect
                ? GapDataset.calendar
                : GapDataset.prices,
            key: i.key,
            fromDate: i.date.yyyyMmDd,
            toDate: i.date.yyyyMmDd,
            cause: i.cause,
            detectedAt: detectedAt,
          ),
      ];

  /// 기록 전부(`gap_id` 순) · [dataset] 을 주면 그것만.
  List<StoredGap> all({GapDataset? dataset}) => <StoredGap>[
    for (final Row r in _db.select(
      'SELECT * FROM data_gap '
      '${dataset == null ? '' : 'WHERE dataset = ? '}ORDER BY gap_id',
      dataset == null ? const <Object>[] : <Object>[dataset.wire],
    ))
      StoredGap(
        gapId: r['gap_id'] as String,
        dataset: r['dataset'] as String,
        fromDate: r['from_date'] as String,
        toDate: r['to_date'] as String,
        recoverable: r['recoverable'] == 1,
        reasonCode: r['reason_code'] as String,
        detectedAt: r['detected_at'] as String,
      ),
  ];
}
