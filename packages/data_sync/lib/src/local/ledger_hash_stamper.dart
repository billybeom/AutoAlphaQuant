// `ledger_daily_hash` 스탬프 — 모집단 행을 한국 날짜로 귀속해 day_hash · 체인을 쓴다(설계 13 §8 R51 H4~H7).
//
// 🔴 날 = 달력일 연속(행 없는 날도 1행) · 첫 날 = 모집단 최소 귀속 날 · 이미 끝난 한국 날짜만.
// 🔴 한 번에 여러 날 = 한 트랜잭션 · 멱등(이미 있는 날은 건너뜀) · 귀속 실패 = 아무것도 쓰지 않고 [LedgerHashError].
// 🔴 지난날 재계산 대조 = E13c1 `LedgerIntegrityCheck`(X5-2 · 설계 13 §8 R58 C9) — 여기서는 하지 않는다.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, hashFormatVersion;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;

/// 스탬프 하루.
class LedgerDayStamp {
  /// 하루를 만든다.
  const LedgerDayStamp({
    required this.authoredDate,
    required this.dayHash,
    required this.chainHash,
    required this.rowCounts,
  });

  /// 귀속 날(한국 날짜).
  final String authoredDate;

  /// day_hash.
  final String dayHash;

  /// chain_hash.
  final String chainHash;

  /// 표마다 행 수(정규 JSON).
  final String rowCounts;

  @override
  String toString() =>
      'LedgerDayStamp($authoredDate · ${chainStampText(chainHash)})';
}

String _kstToday(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${k.year.toString().padLeft(4, '0')}-${two(k.month)}-${two(k.day)}';
}

final RegExp _ymd = RegExp(r'^\d{4}-\d{2}-\d{2}$');

String _nextDay(String ymd) {
  final DateTime d = DateTime.parse('${ymd}T00:00:00Z')
      .add(const Duration(days: 1));
  return d.toIso8601String().substring(0, 10);
}

/// 모집단 행 → (귀속 날 → 표 → 정규 줄)(R51 H1 · H5) — 귀속 실패 = [LedgerHashError].
Map<String, Map<String, List<String>>> ledgerLinesByDay(
  Database db, {
  List<LedgerHashTable> population = kLedgerHashPopulationV1,
}) {
  final Map<String, Map<String, List<String>>> out =
      <String, Map<String, List<String>>>{};
  for (final LedgerHashTable t in population) {
    final String cols = t.columns.map((String c) => 't.$c').join(', ');
    final String sql = t.parentTable == null
        ? 'SELECT $cols, t.${t.axis} AS aaq__axis FROM ${t.table} t'
        : 'SELECT $cols, p.${t.axis} AS aaq__axis FROM ${t.table} t '
              'LEFT JOIN ${t.parentTable} p ON p.${t.parentKey} = t.${t.parentKey}';
    for (final Row r in db.select(sql)) {
      final Map<String, Object?> row = <String, Object?>{
        for (final String c in t.columns) c: r[c],
      };
      final String day = authoredKstDate(
        r['aaq__axis'],
        where: '${t.table} ${row[t.columns.first]}',
      );
      ((out[day] ??= <String, List<String>>{})[t.table] ??= <String>[]).add(
        canonicalRow(row, t.columns),
      );
    }
  }
  return out;
}

/// `ledger_daily_hash` 스탬프(R51 H7).
class LedgerHashStamper {
  /// 스탬프를 만든다.
  LedgerHashStamper(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  /// 마지막 스탬프(없으면 null) — (날 · 체인 · 형식 판).
  (String, String, int)? lastStamp() {
    final ResultSet rs = _db.select(
      'SELECT authored_date, chain_hash, hash_format_version FROM ledger_daily_hash '
      'ORDER BY authored_date DESC LIMIT 1',
    );
    if (rs.isEmpty) return null;
    return (
      rs.first['authored_date'] as String,
      rs.first['chain_hash'] as String,
      rs.first['hash_format_version'] as int,
    );
  }

  /// 마지막 스탬프 다음 날 ~ [kstDay](포함)를 쓴다 — 쓴 날들(이미 다 있으면 빈 목록).
  List<LedgerDayStamp> stampThrough(String kstDay) {
    if (!_ymd.hasMatch(kstDay)) {
      throw ArgumentError.value(kstDay, 'kstDay', 'YYYY-MM-DD 가 아니다');
    }
    final DateTime now = _clock.nowUtc();
    if (kstDay.compareTo(_kstToday(now)) >= 0) {
      throw LedgerHashError('$kstDay: 아직 끝나지 않은 날');
    }
    final (String, String, int)? last = lastStamp();
    if (last != null && last.$3 != hashFormatVersion) {
      throw LedgerHashError('형식 판 다름: 마지막 ${last.$3} · 지금 $hashFormatVersion');
    }
    final Map<String, Map<String, List<String>>> byDay = ledgerLinesByDay(_db);
    String? start;
    if (last != null) {
      start = _nextDay(last.$1);
    } else if (byDay.isNotEmpty) {
      start = (byDay.keys.toList()..sort()).first;
    }
    if (start == null || start.compareTo(kstDay) > 0) {
      return const <LedgerDayStamp>[];
    }
    final String at = now.toIso8601String();
    final List<LedgerDayStamp> out = <LedgerDayStamp>[];
    String prev = last?.$2 ?? kChainGenesis;
    inLedgerTransaction(_db, () {
      for (String d = start!; d.compareTo(kstDay) <= 0; d = _nextDay(d)) {
        final Map<String, List<String>> lines =
            byDay[d] ?? const <String, List<String>>{};
        final String day = dayHashOf(lines);
        final String chain = chainHashOf(prev, day);
        final String counts = rowCountsJson(lines);
        _db.execute(
          'INSERT INTO ledger_daily_hash(authored_date, day_hash, chain_hash, hash_format_version, '
          'row_counts, created_at) VALUES (?, ?, ?, ?, ?, ?)',
          <Object?>[d, day, chain, hashFormatVersion, counts, at],
        );
        out.add(
          LedgerDayStamp(
            authoredDate: d,
            dayHash: day,
            chainHash: chain,
            rowCounts: counts,
          ),
        );
        prev = chain;
      }
    });
    return out;
  }
}
