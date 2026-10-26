// FRED · OFR 클라이언트 — 종가만 있는 매크로·신용 계열(설계 13 §8 R23 D1·D10·D11 · R26 H6 · E8c · FR-110 · FR-111).
//
// 🔴 FRED = 키가 있으면 JSON API(`api.stlouisfed.org`) → 실패하면 키 없는 CSV(`fredgraph.csv` — 참조 엔진
//    `fetch_market.py` 가 쓰는 길)로 옮긴다(FR-111 «정의된 폴백 순서»). 키가 없으면 CSV 만. 행의 `source` 는 실제로 받은
//    길(`FRED` · `FRED_CSV`)이다.
// 🔴 OFR FSI = `financialresearch.gov` 의 `fsi.csv`(FRED 에 없다 · FR-110 MUST) — 전 이력 파일 하나 · `OFR FSI` 칸.
// 🔴 결측(FRED `.` · 빈 칸)은 행을 만들지 않는다(결측 = 행 없음 · R25 G2). 숫자도 결측 표시도 아닌 글자는 응답이 틀린
//    것이다 → 그 길은 실패(지어내지 않는다).
// 🔴 키는 주소의 쿼리에만 들어간다 — 오류·기록 문장에 주소를 넣지 않는다([HttpFetchError.reason]).
// 🟡 응답 꼴은 문서·참조 엔진 기준으로 쓴 시험 픽스처로 맞췄다 — 첫 실호출(발주자 승인) 때 받은 본문으로 바꾼다(D11).

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart' show MarketDataSource;
import 'package:http/http.dart' as http;

import 'csv_table.dart';
import 'http_fetch.dart';
import 'market_store.dart';

/// 계열 수집 한 번의 결과.
class SeriesFetch {
  const SeriesFetch({
    required this.source,
    required this.obs,
    required this.bodySha256,
    required this.attempts,
    this.fallbackReason,
  });

  /// 실제로 받은 길.
  final MarketDataSource source;

  /// [start] 이후(포함) 관측(날짜 오름차순 · 결측 제외).
  final List<SeriesObs> obs;
  final String bodySha256;

  /// 모든 길의 시도 수 합.
  final int attempts;

  /// 평소 길이 실패해 옮겼으면 그 까닭(엔진 문장).
  final String? fallbackReason;
}

/// 모든 길이 실패했다.
class SourceDownError implements Exception {
  const SourceDownError(this.source, this.reason, {required this.attempts});

  /// 평소 원천.
  final MarketDataSource source;

  /// 엔진 문장(길마다 «길: 까닭»).
  final String reason;
  final int attempts;

  @override
  String toString() => 'SourceDownError(${source.wire} · $reason)';
}

/// FRED.
class FredClient {
  FredClient(
    this._http, {
    this._apiKey,
    this.policy = const HttpRetryPolicy(),
    this._sleep,
  });

  final http.Client _http;
  final String? _apiKey;
  final HttpRetryPolicy policy;
  final FetchSleep? _sleep;

  /// JSON API 주소(키 포함 — 기록 금지).
  Uri jsonUri(String code, String start) => Uri.https(
    'api.stlouisfed.org',
    '/fred/series/observations',
    <String, String>{
      'series_id': code,
      'api_key': _apiKey ?? '',
      'file_type': 'json',
      'observation_start': start,
    },
  );

  /// 키 없는 CSV 주소.
  static Uri csvUri(String code, String start) => Uri.https(
    'fred.stlouisfed.org',
    '/graph/fredgraph.csv',
    <String, String>{'id': code, 'cosd': start},
  );

  /// 계열 [code] 의 [start] 이후(포함) 관측.
  Future<SeriesFetch> observations(String code, {required String start}) async {
    int attempts = 0;
    String? jsonFail;
    if (_apiKey != null) {
      try {
        final HttpBody b = await _get(jsonUri(code, start));
        attempts += b.attempts;
        return SeriesFetch(
          source: MarketDataSource.fred,
          obs: parseFredJson(b.text, start: start),
          bodySha256: b.sha256Hex,
          attempts: attempts,
        );
      } on HttpFetchError catch (e) {
        attempts += e.attempts;
        jsonFail = 'FRED: ${e.reason}';
      } on FormatException catch (e) {
        jsonFail = 'FRED: 응답 꼴 — ${e.message}';
      }
    }
    try {
      final HttpBody b = await _get(csvUri(code, start));
      attempts += b.attempts;
      return SeriesFetch(
        source: MarketDataSource.fredCsv,
        obs: parseFredCsv(b.text, start: start),
        bodySha256: b.sha256Hex,
        attempts: attempts,
        fallbackReason: jsonFail,
      );
    } on HttpFetchError catch (e) {
      throw SourceDownError(
        MarketDataSource.fred,
        _joinReasons(jsonFail, 'FRED_CSV: ${e.reason}'),
        attempts: attempts + e.attempts,
      );
    } on FormatException catch (e) {
      throw SourceDownError(
        MarketDataSource.fred,
        _joinReasons(jsonFail, 'FRED_CSV: 응답 꼴 — ${e.message}'),
        attempts: attempts,
      );
    }
  }

  Future<HttpBody> _get(Uri u) =>
      getWithRetry(_http, u, policy: policy, sleep: _sleep);
}

String _joinReasons(String? first, String last) =>
    first == null ? last : '$first · $last';

/// OFR 금융스트레스지수.
class OfrClient {
  OfrClient(this._http, {this.policy = const HttpRetryPolicy(), this._sleep});

  final http.Client _http;
  final HttpRetryPolicy policy;
  final FetchSleep? _sleep;

  /// 전 이력 CSV.
  static final Uri fsiUri = Uri.https(
    'www.financialresearch.gov',
    '/financial-stress-index/data/fsi.csv',
  );

  /// 칸 이름(번들 · 참조 엔진과 같음).
  static const String column = 'OFR FSI';

  /// [start] 이후(포함) 관측.
  Future<SeriesFetch> fsi({required String start}) async {
    int attempts = 0;
    try {
      final HttpBody b = await getWithRetry(
        _http,
        fsiUri,
        headers: _headers,
        policy: policy,
        sleep: _sleep,
      );
      attempts = b.attempts;
      return SeriesFetch(
        source: MarketDataSource.ofr,
        obs: parseOfrCsv(b.text, start: start),
        bodySha256: b.sha256Hex,
        attempts: attempts,
      );
    } on HttpFetchError catch (e) {
      throw SourceDownError(
        MarketDataSource.ofr,
        'OFR: ${e.reason}',
        attempts: e.attempts,
      );
    } on FormatException catch (e) {
      throw SourceDownError(
        MarketDataSource.ofr,
        'OFR: 응답 꼴 — ${e.message}',
        attempts: attempts,
      );
    }
  }

  /// 🟡 참조 엔진이 브라우저 꼴 User-Agent 로 받았다(`fetch_market.py`) — 기본 UA 를 막는 경우에 대비.
  static const Map<String, String> _headers = <String, String>{
    'User-Agent': 'Mozilla/5.0 (compatible; AutoAlphaQuant)',
  };
}

/// FRED JSON(`observations[].date` · `.value` — `.` = 결측).
List<SeriesObs> parseFredJson(String text, {required String start}) {
  final Object? root = jsonDecode(text);
  if (root is! Map<String, Object?> || root['observations'] is! List<Object?>) {
    throw const FormatException('observations 배열이 없다');
  }
  final List<SeriesObs> out = <SeriesObs>[];
  for (final Object? o in root['observations']! as List<Object?>) {
    if (o is! Map<String, Object?> ||
        o['date'] is! String ||
        o['value'] is! String) {
      throw const FormatException('관측 꼴이 아니다');
    }
    final String d = _isoDate(o['date']! as String);
    final double v = csvNumber(o['value']! as String);
    if (!v.isNaN && d.compareTo(start) >= 0) out.add(SeriesObs(d, v));
  }
  return _sorted(out);
}

/// FRED `fredgraph.csv`(칸 2개 — 이름은 `DATE`·`observation_date` 어느 것이든 · 참조 엔진도 위치로 읽는다).
List<SeriesObs> parseFredCsv(String text, {required String start}) {
  final CsvTable t = CsvTable.parse(text);
  if (t.header.length != 2) {
    throw FormatException('fredgraph 칸 ${t.header.length}(2 여야 한다)');
  }
  return _sorted(<SeriesObs>[
    for (final List<String> r in t.rows)
      if (!csvNumber(r[1]).isNaN && _isoDate(r[0]).compareTo(start) >= 0)
        SeriesObs(_isoDate(r[0]), csvNumber(r[1])),
  ]);
}

/// OFR `fsi.csv`(첫 칸 = 날짜 · `OFR FSI` 칸).
List<SeriesObs> parseOfrCsv(String text, {required String start}) {
  final CsvTable t = CsvTable.parse(text);
  final int c = t.indexOf(OfrClient.column);
  return _sorted(<SeriesObs>[
    for (final List<String> r in t.rows)
      if (!csvNumber(r[c]).isNaN && _isoDate(r[0]).compareTo(start) >= 0)
        SeriesObs(_isoDate(r[0]), csvNumber(r[c])),
  ]);
}

final RegExp _iso = RegExp(r'^\d{4}-\d{2}-\d{2}$');
final RegExp _us = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');

/// `YYYY-MM-DD` 또는 `M/D/YYYY` → `YYYY-MM-DD`(그 밖은 [FormatException]).
String _isoDate(String s) {
  final String x = s.trim();
  if (_iso.hasMatch(x)) return x;
  final RegExpMatch? m = _us.firstMatch(x);
  if (m == null) throw FormatException('날짜 꼴이 아니다: «$s»');
  String two(String v) => v.padLeft(2, '0');
  return '${m[3]}-${two(m[1]!)}-${two(m[2]!)}';
}

/// 날짜 오름차순 · 같은 날 두 번이면 틀린 응답.
List<SeriesObs> _sorted(List<SeriesObs> obs) {
  obs.sort((SeriesObs a, SeriesObs b) => a.date.compareTo(b.date));
  for (int i = 1; i < obs.length; i++) {
    if (obs[i].date == obs[i - 1].date) {
      throw FormatException('같은 날이 두 번: ${obs[i].date}');
    }
  }
  return obs;
}
