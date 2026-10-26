// M1-7 결측 판정(fail-closed) · 월말 판정 시점(설계 13 §8 R23 D4 · D13 · R24 B2·B5 · E8b2).
//
// 🔴 KR(D4) — 판정일에 계획 대상 종목이 하나라도 결측이면 **그날 계획을 만들지 않는다**(FR-111 · 부분 계획 금지 —
//    월말 단계는 서로의 입력이다). 결측 = 동결 캘린더가 세션이라 한 날에 행이 없음 · 종가 ≤ 0 · 거래량 < 0 ·
//    전 세션 대비 |변동| ≥ 60%(FR-112 sanity). 기록은 `data_gap` + `DATA_SOURCE_DOWN`(P1) — 쓰는 것은 E8c 다.
// 🔴 전 종목이 같은 날 함께 비면 «캘린더 의심»(R15 꼴) — 그래도 결측으로 처리하고 알린다. 표를 자동으로 고치지 않는다.
// 🔴 미국·매크로(D4 후반) — 카테고리 안 결측은 재정규화가 이어받는다(03 §1-1 · `directionScores`) · 낡은 값은
//    신선도 상한([applyFreshnessCaps])이 결측으로 바꾼다. 여기서는 KR 만 판정한다.
// ✅ 결측 사유 코드([DataGapCause])의 글자는 계약 사전 `GapReasonCodes`(`data_gap.reason_code`)에 등재됐다(계약 v1.14 ·
//    R24 B5 · R25 G4) — 시험이 두 목록을 맞댄다.

import 'package:domain_contracts/domain_contracts.dart' show TradeDate;

import '../calendar/exchange_calendar.dart';
import 'dated_series.dart';

/// 결측 사유(엔진 열거 · 글자 = 계약 `GapReasonCodes` · v1.14).
enum DataGapCause {
  /// 세션인데 행이 없다.
  missingRow('MISSING_ROW'),

  /// 종가 ≤ 0.
  nonPositivePrice('NON_POSITIVE_PRICE'),

  /// 거래량 < 0.
  negativeVolume('NEGATIVE_VOLUME'),

  /// 전 세션 대비 |변동| ≥ 상한(기본 60%).
  priceJump('PRICE_JUMP'),

  /// 전 종목이 같은 날 함께 비었다(캘린더 의심 — 표 자동 수정 금지).
  calendarSuspect('CALENDAR_SUSPECT');

  const DataGapCause(this.wire);

  /// 기록 값(`data_gap.reason_code` · 계약 `GapReasonCodes`).
  final String wire;
}

/// 일봉 한 칸(종가 · 거래량 — 거래량을 모르면 null).
class KrBar {
  const KrBar({required this.close, this.volume});

  final double close;
  final double? volume;
}

/// 결측 하나.
class DataIssue {
  const DataIssue({required this.key, required this.date, required this.cause});

  /// 종목 코드(또는 지수 이름).
  final String key;
  final TradeDate date;
  final DataGapCause cause;

  @override
  String toString() => '$key ${date.yyyyMmDd} ${cause.wire}';
}

/// 판정일의 결론.
class KrDayVerdict {
  const KrDayVerdict({
    required this.day,
    required this.issues,
    required this.calendarSuspect,
  });

  final TradeDate day;
  final List<DataIssue> issues;

  /// 전 종목이 함께 비었다.
  final bool calendarSuspect;

  /// 계획을 만들어도 되는가(결측 0 일 때만).
  bool get proceed => issues.isEmpty;
}

/// 판정일 [day] 에 계획 대상 [targets] 의 일봉을 본다 — [bars] = 종목 → (날짜 `YYYY-MM-DD` → 일봉).
///
/// [day] 가 [kr] 의 세션이 아니거나 범위 밖이면 [StateError](판정일은 세션이어야 한다 — 모르는 날을 지어내지 않는다).
/// 변동은 [day] 바로 앞 세션의 종가와 잰다(그 세션 행이 없으면 변동은 보지 않는다 — 그 날의 결측은 그날 판정 몫).
KrDayVerdict judgeKrPlanDay(
  TradeDate day,
  List<String> targets,
  Map<String, Map<String, KrBar>> bars,
  ExchangeCalendar kr, {
  double maxJump = 0.6,
}) {
  if (!kr.isSession(day)) {
    throw StateError('${day.yyyyMmDd} 는 ${kr.market.mic} 세션이 아니다');
  }
  final String prev = _prevSession(day, kr);
  final List<DataIssue> issues = <DataIssue>[];
  int missing = 0;
  for (final String t in targets) {
    final Map<String, KrBar> b = bars[t] ?? const <String, KrBar>{};
    final KrBar? bar = b[day.yyyyMmDd];
    if (bar == null) {
      issues.add(DataIssue(key: t, date: day, cause: DataGapCause.missingRow));
      missing++;
      continue;
    }
    if (!(bar.close > 0)) {
      issues.add(
        DataIssue(key: t, date: day, cause: DataGapCause.nonPositivePrice),
      );
      continue;
    }
    final double? v = bar.volume;
    if (v != null && v < 0) {
      issues.add(
        DataIssue(key: t, date: day, cause: DataGapCause.negativeVolume),
      );
    }
    final KrBar? before = b[prev];
    if (before != null && before.close > 0) {
      final double jump = (bar.close / before.close - 1.0).abs();
      if (jump >= maxJump) {
        issues.add(DataIssue(key: t, date: day, cause: DataGapCause.priceJump));
      }
    }
  }
  final bool suspect = targets.isNotEmpty && missing == targets.length;
  return KrDayVerdict(
    day: day,
    issues: <DataIssue>[
      ...issues,
      if (suspect)
        DataIssue(key: '*', date: day, cause: DataGapCause.calendarSuspect),
    ],
    calendarSuspect: suspect,
  );
}

String _prevSession(TradeDate day, ExchangeCalendar kr) {
  String d = day.yyyyMmDd;
  for (int i = 0; i < 40; i++) {
    d = minusOneDay(d);
    final TradeDate t = TradeDate(d);
    if (t.yyyyMmDd.compareTo(kr.coverageStart.yyyyMmDd) < 0) return '';
    if (kr.isSession(t)) return d;
  }
  return '';
}

/// 월말 판정 시점(R23 D13 (c)) — 아직 판정할 수 없으면 null.
///
/// KR 월말 세션 [krDay] 의 국면 = «미국 [krDay] 이하» 마지막 값(참조 엔진의 같은 날짜 포함 정렬). 그래서 미국에
/// [krDay] 세션이 있으면 그 종가가 들어온 뒤(= KST 다음 날 아침)에만 판정한다 — [lastUsDataDate] 가 그 날보다
/// 앞이면 아직이다. 미국이 휴장이면 그 앞 값이 최종이라 바로 판정한다. [us] = 동결 XNYS 캘린더.
bool monthEndRegimeReady(
  String krDay,
  String lastUsDataDate,
  ExchangeCalendar us,
) {
  if (!us.isSession(TradeDate(krDay))) return true;
  return lastUsDataDate.compareTo(krDay) >= 0;
}
