// KIS 시세 6종 · 응답 해석 · 날짜 창 밀기(설계 13 §8 R29 L6~L9 · 실험 5 = 07 §6-2).
//
// 🔵 엔드포인트·TR_ID 는 실험 5(모의 키 · 2026-10-29)에서 확정했다(02 §5-1). 시세 TR 은 실전·모의가 같은 이름이다.
// 🔴 값 판정(D4 결측 · CHECK)은 여기서 하지 않는다 — 받은 그대로 돌려주고 저장·판정이 본다. ^GSPC 거래량 `0` 도 그대로다
//    (실전 국면은 SPY 거래량을 읽는다 · R28 K5).
// 🔴 수 변환 = pandas `precise_xstrtod`(core_engine `pandasPreciseXstrtod` · R26 H9 — 시드와 같은 변환).
// 🔴 한 번에 오는 행이 정해져 있다(국내·해외 일봉 100 · 국내 지수 50). 범위 조회는 받은 가장 이른 날이 `from` 보다
//    늦으면 그 전날까지로 다시 부른다(R29 L9 · I3).

import 'package:core_engine/core_engine.dart' show pandasPreciseXstrtod;

import 'kis_rest_client.dart';

/// 업무 거절(서버가 `rt_cd ≠ 0` 으로 답했다 — 모의 미지원 · 잘못된 코드 등).
class KisRejected implements Exception {
  const KisRejected(this.trId, this.status, this.msgCd, this.msg1);

  final String trId;
  final int status;
  final String? msgCd, msg1;

  @override
  String toString() =>
      'KisRejected: $trId HTTP $status ${msgCd ?? ''} ${msg1 ?? ''}'.trim();
}

/// 일봉 하나(받은 그대로 · 날짜 = ISO). 종가가 없는 행은 만들지 않는다.
class KisBar {
  const KisBar({
    required this.date,
    required this.close,
    this.open,
    this.high,
    this.low,
    this.volume,
    this.tradeValue,
  });

  final String date;
  final double close;
  final double? open, high, low, volume, tradeValue;

  @override
  String toString() => 'KisBar($date · $close · 거래량 $volume)';
}

/// 현재가.
class KisPrice {
  const KisPrice({required this.price, this.volume});

  final double price;
  final double? volume;
}

/// 국내 휴장일 표 한 줄.
class KisHoliday {
  const KisHoliday({
    required this.date,
    required this.marketOpen,
    required this.businessDay,
    required this.tradingDay,
  });

  final String date;

  /// 개장일(`opnd_yn`) · 영업일(`bzdy_yn`) · 거래일(`tr_day_yn`).
  final bool marketOpen, businessDay, tradingDay;
}

/// 시세 경로 · TR_ID(실험 5 확정 · 02 §5-1).
abstract final class KisQuotePaths {
  static const String domesticDaily =
      '/uapi/domestic-stock/v1/quotations/inquire-daily-itemchartprice';
  static const String domesticPrice =
      '/uapi/domestic-stock/v1/quotations/inquire-price';
  static const String domesticIndexDaily =
      '/uapi/domestic-stock/v1/quotations/inquire-daily-indexchartprice';
  static const String domesticHoliday =
      '/uapi/domestic-stock/v1/quotations/chk-holiday';
  static const String overseasDaily =
      '/uapi/overseas-price/v1/quotations/dailyprice';
  static const String overseasIndexDaily =
      '/uapi/overseas-price/v1/quotations/inquire-daily-chartprice';
}

/// TR_ID(실전·모의 같음).
abstract final class KisQuoteTr {
  static const String domesticDaily = 'FHKST03010100';
  static const String domesticPrice = 'FHKST01010100';
  static const String domesticIndexDaily = 'FHKUP03500100';
  static const String domesticHoliday = 'CTCA0903R';
  static const String overseasDaily = 'HHDFS76240000';
  static const String overseasIndexDaily = 'FHKST03030100';
}

/// 창 밀기 상한(무한 반복 막음 — 국내 지수 50행이면 40년 ≈ 210쪽).
const int kKisMaxPages = 500;

/// 시세 조회.
class KisQuotes {
  const KisQuotes(this._c);

  final KisRestClient _c;

  Future<KisResponse> _ok(String path, String tr, Map<String, String> q) async {
    final KisResponse r = await _c.get(path, tr, q);
    if (!r.ok) throw KisRejected(tr, r.status, r.msgCd, r.msg1);
    return r;
  }

  /// 국내 종목 일봉([from]~[to] · ISO) — [adjusted] 참 = 수정주가(분배금 반영 · `FID_ORG_ADJ_PRC=0`) · 거짓 = 원주가(`1`).
  Future<List<KisBar>> domesticDaily(
    String code, {
    required String from,
    required String to,
    required bool adjusted,
  }) => pageBack(from, to, (String cursor) async {
    final KisResponse r = await _ok(
      KisQuotePaths.domesticDaily,
      KisQuoteTr.domesticDaily,
      <String, String>{
        'FID_COND_MRKT_DIV_CODE': 'J',
        'FID_INPUT_ISCD': code,
        'FID_INPUT_DATE_1': _ymd(from),
        'FID_INPUT_DATE_2': _ymd(cursor),
        'FID_PERIOD_DIV_CODE': 'D',
        'FID_ORG_ADJ_PRC': adjusted ? '0' : '1',
      },
    );
    return parseKisBars(r.body!, KisBarKeys.domestic);
  });

  /// 국내 종목 현재가.
  Future<KisPrice> domesticPrice(String code) async {
    final KisResponse r = await _ok(
      KisQuotePaths.domesticPrice,
      KisQuoteTr.domesticPrice,
      <String, String>{'FID_COND_MRKT_DIV_CODE': 'J', 'FID_INPUT_ISCD': code},
    );
    return parseKisPrice(r.body!);
  }

  /// 국내 업종 지수 일봉(KOSDAQ = `1001` · KOSPI = `0001`) — 한 번에 50행.
  Future<List<KisBar>> domesticIndexDaily(
    String code, {
    required String from,
    required String to,
  }) => pageBack(from, to, (String cursor) async {
    final KisResponse r = await _ok(
      KisQuotePaths.domesticIndexDaily,
      KisQuoteTr.domesticIndexDaily,
      <String, String>{
        'FID_COND_MRKT_DIV_CODE': 'U',
        'FID_INPUT_ISCD': code,
        'FID_INPUT_DATE_1': _ymd(from),
        'FID_INPUT_DATE_2': _ymd(cursor),
        'FID_PERIOD_DIV_CODE': 'D',
      },
    );
    return parseKisBars(r.body!, KisBarKeys.domesticIndex);
  });

  /// 해외 종목 일봉(거래소 [exchange] — SPY·RSP = `AMS`) — [adjusted] 참 = 배당까지 수정(`MODP=1`) · 거짓 = 원종가.
  Future<List<KisBar>> overseasDaily(
    String exchange,
    String symbol, {
    required String from,
    required String to,
    required bool adjusted,
  }) => pageBack(from, to, (String cursor) async {
    final KisResponse r = await _ok(
      KisQuotePaths.overseasDaily,
      KisQuoteTr.overseasDaily,
      <String, String>{
        'AUTH': '',
        'EXCD': exchange,
        'SYMB': symbol,
        'GUBN': '0',
        'BYMD': _ymd(cursor),
        'MODP': adjusted ? '1' : '0',
      },
    );
    return parseKisBars(r.body!, KisBarKeys.overseas);
  });

  /// 해외 지수 일봉(S&P500 = `SPX`) — 🔴 KIS 는 거래량을 0 으로 준다(실험 5).
  Future<List<KisBar>> overseasIndexDaily(
    String code, {
    required String from,
    required String to,
  }) => pageBack(from, to, (String cursor) async {
    final KisResponse r = await _ok(
      KisQuotePaths.overseasIndexDaily,
      KisQuoteTr.overseasIndexDaily,
      <String, String>{
        'FID_COND_MRKT_DIV_CODE': 'N',
        'FID_INPUT_ISCD': code,
        'FID_INPUT_DATE_1': _ymd(from),
        'FID_INPUT_DATE_2': _ymd(cursor),
        'FID_PERIOD_DIV_CODE': 'D',
      },
    );
    return parseKisBars(r.body!, KisBarKeys.overseasIndex);
  });

  /// 국내 휴장일 표([baseDate] 부터) — 🟡 모의 미지원(`EGW02006` · 실험 5) → 실전 키 때(R23 D14).
  Future<List<KisHoliday>> domesticHolidays(String baseDate) async {
    final KisResponse r = await _ok(
      KisQuotePaths.domesticHoliday,
      KisQuoteTr.domesticHoliday,
      <String, String>{
        'BASS_DT': _ymd(baseDate),
        'CTX_AREA_NK': '',
        'CTX_AREA_FK': '',
      },
    );
    return parseKisHolidays(r.body!);
  }
}

/// 일봉 칸 이름 한 벌.
class KisBarKeys {
  const KisBarKeys(
    this.date,
    this.open,
    this.high,
    this.low,
    this.close,
    this.volume, [
    this.tradeValue,
  ]);

  final String date, open, high, low, close, volume;
  final String? tradeValue;

  /// 국내 종목 일봉(`output2`).
  static const KisBarKeys domestic = KisBarKeys(
    'stck_bsop_date',
    'stck_oprc',
    'stck_hgpr',
    'stck_lwpr',
    'stck_clpr',
    'acml_vol',
    'acml_tr_pbmn',
  );

  /// 국내 업종 지수 일봉(`output2`).
  static const KisBarKeys domesticIndex = KisBarKeys(
    'stck_bsop_date',
    'bstp_nmix_oprc',
    'bstp_nmix_hgpr',
    'bstp_nmix_lwpr',
    'bstp_nmix_prpr',
    'acml_vol',
    'acml_tr_pbmn',
  );

  /// 해외 종목 일봉(`output2`).
  static const KisBarKeys overseas = KisBarKeys(
    'xymd',
    'open',
    'high',
    'low',
    'clos',
    'tvol',
    'tamt',
  );

  /// 해외 지수 일봉(`output2`).
  static const KisBarKeys overseasIndex = KisBarKeys(
    'stck_bsop_date',
    'ovrs_nmix_oprc',
    'ovrs_nmix_hgpr',
    'ovrs_nmix_lwpr',
    'ovrs_nmix_prpr',
    'acml_vol',
  );
}

double? _num(Object? v) {
  if (v is! String) return null;
  final String s = v.trim();
  if (s.isEmpty) return null;
  final double? x = pandasPreciseXstrtod(s);
  return x == null || x.isNaN ? null : x;
}

String? _iso(Object? v) {
  if (v is! String) return null;
  final String s = v.trim();
  if (s.length != 8 || int.tryParse(s) == null) return null;
  return '${s.substring(0, 4)}-${s.substring(4, 6)}-${s.substring(6)}';
}

String _ymd(String iso) => iso.replaceAll('-', '');

/// 응답 본문 → 일봉(날짜·종가가 없는 꼬리 행은 버린다 · 받은 순서 그대로).
List<KisBar> parseKisBars(Map<String, Object?> body, KisBarKeys k) {
  final Object? rows = body['output2'];
  if (rows is! List<Object?>) return const <KisBar>[];
  return <KisBar>[
    for (final Object? row in rows)
      if (row is Map<String, Object?>)
        if ((_iso(row[k.date]), _num(row[k.close])) case (
          final String date,
          final double close,
        ))
          KisBar(
            date: date,
            close: close,
            open: _num(row[k.open]),
            high: _num(row[k.high]),
            low: _num(row[k.low]),
            volume: _num(row[k.volume]),
            tradeValue: k.tradeValue == null ? null : _num(row[k.tradeValue]),
          ),
  ];
}

/// 응답 본문 → 현재가.
KisPrice parseKisPrice(Map<String, Object?> body) {
  final Object? o = body['output'];
  final double? p = o is Map<String, Object?> ? _num(o['stck_prpr']) : null;
  if (p == null) throw const FormatException('현재가(stck_prpr)가 없다');
  return KisPrice(
    price: p,
    volume: _num((o! as Map<String, Object?>)['acml_vol']),
  );
}

/// 응답 본문 → 휴장일 표.
List<KisHoliday> parseKisHolidays(Map<String, Object?> body) {
  final Object? rows = body['output'];
  if (rows is! List<Object?>) return const <KisHoliday>[];
  return <KisHoliday>[
    for (final Object? row in rows)
      if (row is Map<String, Object?>)
        if (_iso(row['bass_dt']) case final String date)
          KisHoliday(
            date: date,
            marketOpen: row['opnd_yn'] == 'Y',
            businessDay: row['bzdy_yn'] == 'Y',
            tradingDay: row['tr_day_yn'] == 'Y',
          ),
  ];
}

String _dayBefore(String iso) =>
    DateTime.parse('${iso}T00:00:00Z')
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

/// 범위 조회 창 밀기(R29 L9) — [page] 는 «[cursor] 이하 최근 N행»을 준다. 받은 가장 이른 날이 [from] 보다 늦으면
/// 그 전날을 새 [cursor] 로 다시 부른다. 같은 날이 두 번 오면 먼저 받은 것 · 진전이 없으면 멈춘다. 결과 = 날짜 오름차순.
Future<List<KisBar>> pageBack(
  String from,
  String to,
  Future<List<KisBar>> Function(String cursor) page,
) async {
  final Map<String, KisBar> got = <String, KisBar>{};
  String cursor = to;
  for (int i = 0; i < kKisMaxPages; i++) {
    final List<KisBar> rows = <KisBar>[
      for (final KisBar b in await page(cursor))
        if (b.date.compareTo(cursor) <= 0) b,
    ];
    if (rows.isEmpty) break;
    for (final KisBar b in rows) {
      got.putIfAbsent(b.date, () => b);
    }
    final String earliest = rows
        .map((KisBar b) => b.date)
        .reduce((String a, String b) => a.compareTo(b) <= 0 ? a : b);
    if (earliest.compareTo(from) <= 0) break;
    final String next = _dayBefore(earliest);
    if (next.compareTo(cursor) >= 0) break;
    cursor = next;
  }
  return got.values
      .where(
        (KisBar b) => b.date.compareTo(from) >= 0 && b.date.compareTo(to) <= 0,
      )
      .toList()
    ..sort((KisBar a, KisBar b) => a.date.compareTo(b.date));
}
