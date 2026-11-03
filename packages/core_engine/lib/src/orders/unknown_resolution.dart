// UNKNOWN 해소 — 결과 불명 의도를 체결조회 원주문 행에 맞춘다(04 §3-3 v2.38 «KIS 에서의 5단계» · 설계 13 §8 R33 D16 ·
// R39 T5~T9).
//
// 🔴 KIS 주문 본문에는 클라이언트 주문번호가 없다 — 그래서 (종목 · 방향 · 주문 수량 · 주문 단가 · 주문 시각)으로 맞춘다.
//    정확히 1행 = 연결 · 2행 이상 = UNKNOWN 유지 + P0 · 0행 = 같은 날 3분 이상 사이를 둔 두 번째 놓침에서 REJECTED.
// 🔴 이미 다른 의도에 붙은 주문번호(`broker_orders` 에 있는 것)는 후보가 아니다 — 남의 주문을 가져오지 않는다.
// 🔴 해소는 «조회 함수이지 게이트가 아니다»(04 §3-3 v1.5) — NR-1 2.5단계는 UNKNOWN 이 남아 있는 동안 계속 막는다.
// 🔵 연결 뒤의 체결 기록은 다음 `runFillSync` 가 쓴다(배선 E11 — 해소 → 체결 동기화 순).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';

import '../decimal_rules.dart';
import 'fills.dart';
import 'order_ports.dart';

/// 해소 대상 UNKNOWN 의도(R39 T5).
class UnknownIntent {
  /// 의도를 만든다.
  const UnknownIntent({
    required this.intentId,
    required this.tradeDate,
    required this.account,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.limitPrice,
    required this.createdAtUtc,
    required this.errorMessage,
  });

  /// 의도 id.
  final String intentId;

  /// 집행일(체결조회 주문일).
  final TradeDate tradeDate;

  /// 계좌 별칭 · 종목.
  final String account, symbol;

  /// 방향.
  final OrderSide side;

  /// 주문 수량.
  final int quantity;

  /// 지정가(원 · 시장가면 null — 원장 REAL 그대로).
  final double? limitPrice;

  /// 의도 예약 시각(맞추기 시각 하한의 기준).
  final DateTime createdAtUtc;

  /// 지금 사유(«놓침» 표시가 앞에 붙어 있을 수 있다).
  final String? errorMessage;
}

/// «놓침» 표시 접두(R39 T7) — `UNKNOWN_MISS@{UTC ISO} · `.
const String kUnknownMissPrefix = 'UNKNOWN_MISS@';

/// 0행 두 번째 놓침까지의 최소 간격(R39 T6 · 🟡 실전 키 때 재고).
const Duration kUnknownMissGap = Duration(minutes: 3);

/// 주문 시각 여유(R39 T5 · 🟡) — 원주문 행 주문 시각 ≥ 예약 시각 − 이만큼.
const Duration kUnknownTimeMargin = Duration(seconds: 60);

/// 사유 앞의 «놓침» 시각(없으면 null).
DateTime? unknownMissAt(String? errorMessage) {
  if (errorMessage == null || !errorMessage.startsWith(kUnknownMissPrefix)) {
    return null;
  }
  final int end = errorMessage.indexOf(' · ');
  final String iso = errorMessage.substring(
    kUnknownMissPrefix.length,
    end < 0 ? errorMessage.length : end,
  );
  return DateTime.tryParse(iso)?.toUtc();
}

/// [at] 의 «놓침» 표시를 사유 앞에 붙인다(앞선 표시는 갈아 끼운다 · 원래 사유는 뒤에 남는다).
String withUnknownMiss(String? errorMessage, DateTime at) {
  String rest = errorMessage ?? '';
  if (unknownMissAt(rest) != null) {
    final int end = rest.indexOf(' · ');
    rest = end < 0 ? '' : rest.substring(end + 3);
  }
  final String head = '$kUnknownMissPrefix${at.toUtc().toIso8601String()}';
  return rest.isEmpty ? head : '$head · $rest';
}

/// 해소 판정 한 줄.
sealed class UnknownResolution {
  const UnknownResolution(this.intent);

  /// 의도.
  final UnknownIntent intent;
}

/// 정확히 1행 — 그 주문으로 연결한다.
final class UnknownLinked extends UnknownResolution {
  const UnknownLinked(super.intent, this.row);

  /// 맞은 원주문 행.
  final DailyFillRow row;
}

/// 2행 이상 — UNKNOWN 유지 + P0(사람이 본다).
final class UnknownAmbiguous extends UnknownResolution {
  const UnknownAmbiguous(super.intent, this.candidates);

  /// 맞은 행 수.
  final int candidates;
}

/// 0행 첫 번째(또는 간격 전) — «놓침»만 남긴다.
final class UnknownMissed extends UnknownResolution {
  const UnknownMissed(super.intent, this.at, {required this.first});

  /// 이번 놓침 시각.
  final DateTime at;

  /// 첫 놓침인가(false = 간격이 안 찼다 — 표시를 고치지 않는다).
  final bool first;
}

/// 0행 두 번째 — REJECTED(`UNKNOWN_NOT_FOUND`).
final class UnknownNotFound extends UnknownResolution {
  const UnknownNotFound(super.intent);
}

int _secondsOfDayKst(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  return k.hour * 3600 + k.minute * 60 + k.second;
}

int? _hhmmss(String? t) {
  if (t == null || !RegExp(r'^\d{6}$').hasMatch(t)) return null;
  return int.parse(t.substring(0, 2)) * 3600 +
      int.parse(t.substring(2, 4)) * 60 +
      int.parse(t.substring(4));
}

String _kstDate(DateTime utc) => utc
    .toUtc()
    .add(const Duration(hours: 9))
    .toIso8601String()
    .substring(0, 10);

bool _priceMatches(double? limit, Decimal? orderPrice) {
  if (limit == null) return orderPrice == null || orderPrice == Decimal.zero;
  return orderPrice != null && orderPrice == promoteRatio(limit);
}

/// UNKNOWN 의도 하나를 그 집행일 체결조회 행에 맞춘다(R39 T5 · T6 · 순수).
///
/// [linkedOrderNos] = 이미 `broker_orders` 에 있는 주문번호(후보에서 뺀다).
UnknownResolution resolveUnknown(
  UnknownIntent it, {
  required List<DailyFillRow> rows,
  required Set<String> linkedOrderNos,
  required DateTime nowUtc,
  Duration missGap = kUnknownMissGap,
  Duration timeMargin = kUnknownTimeMargin,
}) {
  // 시각 하한 — 예약(− 여유)이 집행일 앞날이면 하한 없음 · 같은 날이면 그 시각 · 뒷날이면 맞출 행이 없다(fail-closed).
  final DateTime lower = it.createdAtUtc.subtract(timeMargin);
  final int dayOrder = _kstDate(lower).compareTo(it.tradeDate.yyyyMmDd);
  final int floor = dayOrder < 0 ? 0 : _secondsOfDayKst(lower);
  final List<DailyFillRow> hits = <DailyFillRow>[
    for (final DailyFillRow r in rows)
      if (!r.isCancelRow &&
          r.orderDate == it.tradeDate &&
          r.symbol == it.symbol &&
          r.side == it.side &&
          r.orderQty == it.quantity &&
          _priceMatches(it.limitPrice, r.orderPrice) &&
          !linkedOrderNos.contains(r.brokerOrderNo))
        if (_hhmmss(r.orderTime) case final int t
            when dayOrder <= 0 && t >= floor)
          r,
  ];
  if (hits.length == 1) return UnknownLinked(it, hits.single);
  if (hits.length > 1) return UnknownAmbiguous(it, hits.length);
  final DateTime? prior = unknownMissAt(it.errorMessage);
  final DateTime now = nowUtc.toUtc();
  if (prior == null || _kstDate(prior) != _kstDate(now)) {
    return UnknownMissed(it, now, first: true);
  }
  if (now.difference(prior) >= missGap) return UnknownNotFound(it);
  return UnknownMissed(it, prior, first: false);
}

/// 해소 원장 포트(R39 T9) — 구현 = data_sync `SqliteOrderLedger`.
abstract interface class UnknownLedger {
  /// 브로커 주문이 없는 UNKNOWN 의도 전부(날 무관 — 2.5단계가 날을 넘겨 막는다).
  ///
  /// 🔴 주문번호가 있는 UNKNOWN(일 마감 조회 실패 · 원주문 행 없음 — E10e1)은 맞출 것이 없다 — 넣지 않는다.
  Future<List<UnknownIntent>> unknownIntents();

  /// [brokerOrderNos] 가운데 이미 `broker_orders` 에 있는 것.
  Future<Set<String>> linkedOrderNos(Iterable<String> brokerOrderNos);

  /// 연결 — `broker_orders` 행 + 의도 UNKNOWN → SUBMITTED(한 트랜잭션).
  Future<void> linkUnknown(String intentId, String brokerOrderNo);

  /// 거절 — UNKNOWN → REJECTED(`UNKNOWN_NOT_FOUND: …`).
  Future<void> rejectUnknown(String intentId, String message);

  /// «놓침» 표시를 사유에 남긴다(UNKNOWN 그대로).
  Future<void> noteUnknownMiss(String intentId, String message);
}

/// UNKNOWN 해소의 거절 사유 접두(orders_today 에 센다 — 7단계를 지났다).
const String kUnknownNotFoundPrefix = 'UNKNOWN_NOT_FOUND: ';

/// 해소 실행 결과.
class UnknownResolutionReport {
  /// 결과를 만든다.
  const UnknownResolutionReport({
    required this.resolutions,
    required this.unavailable,
  });

  /// 판정(실행 순서).
  final List<UnknownResolution> resolutions;

  /// 체결조회를 못 한 (계좌 · 집행일).
  final List<(String, TradeDate)> unavailable;

  /// P0 — 2행 이상(사람이 본다).
  List<UnknownAmbiguous> get ambiguous => <UnknownAmbiguous>[
    for (final UnknownResolution r in resolutions)
      if (r is UnknownAmbiguous) r,
  ];
}

/// UNKNOWN 해소 실행(R39 T8) — (계좌 · 집행일)마다 체결조회 한 번 → 판정 → 원장.
Future<UnknownResolutionReport> resolveUnknownOrders({
  required UnknownLedger ledger,
  required Map<String, OrderBroker> brokers,
  required DateTime nowUtc,
  Duration missGap = kUnknownMissGap,
  Duration timeMargin = kUnknownTimeMargin,
}) async {
  final List<UnknownIntent> all = await ledger.unknownIntents();
  final Map<(String, String), List<UnknownIntent>> groups =
      <(String, String), List<UnknownIntent>>{};
  for (final UnknownIntent it in all) {
    (groups[(it.account, it.tradeDate.yyyyMmDd)] ??= <UnknownIntent>[]).add(it);
  }
  final List<UnknownResolution> out = <UnknownResolution>[];
  final List<(String, TradeDate)> unavailable = <(String, TradeDate)>[];
  final List<(String, String)> keys = groups.keys.toList()
    ..sort(((String, String) a, (String, String) b) {
      final int c = a.$1.compareTo(b.$1);
      return c != 0 ? c : a.$2.compareTo(b.$2);
    });
  for (final (String account, String day) in keys) {
    final TradeDate date = TradeDate(day);
    final OrderBroker? broker = brokers[account];
    List<DailyFillRow> rows;
    try {
      if (broker == null) throw StateError('계좌 $account 의 브로커가 없다');
      rows = await broker.dailyFills(date);
    } on Object {
      unavailable.add((account, date));
      continue;
    }
    final Set<String> linked = await ledger.linkedOrderNos(
      rows
          .where((DailyFillRow r) => !r.isCancelRow)
          .map((DailyFillRow r) => r.brokerOrderNo),
    );
    for (final UnknownIntent it in groups[(account, day)]!) {
      final UnknownResolution r = resolveUnknown(
        it,
        rows: rows,
        linkedOrderNos: linked,
        nowUtc: nowUtc,
        missGap: missGap,
        timeMargin: timeMargin,
      );
      switch (r) {
        case UnknownLinked(:final DailyFillRow row):
          await ledger.linkUnknown(it.intentId, row.brokerOrderNo);
          linked.add(row.brokerOrderNo); // 같은 조회의 다음 의도가 가져가지 않게
        case UnknownNotFound():
          await ledger.rejectUnknown(
            it.intentId,
            '$kUnknownNotFoundPrefix같은 날 두 번 맞추지 못했다(${it.symbol} ${it.side.wire} ${it.quantity})',
          );
        case UnknownMissed(:final DateTime at, :final bool first):
          if (first) {
            await ledger.noteUnknownMiss(
              it.intentId,
              withUnknownMiss(it.errorMessage, at),
            );
          }
        case UnknownAmbiguous():
          break;
      }
      out.add(r);
    }
  }
  return UnknownResolutionReport(resolutions: out, unavailable: unavailable);
}
