// 재개 갭 · 보수 모드 사다리(06 X2-2 · 04 §3-1 v2.42 ④ · 02 §4 `operations.resume` · 08M 그림 10-3 ·
// 설계 13 §8 R70 D3 · R72 J1 · J2).
//
// 🔴 갭 = 마지막 성공 세션 다음 ~ 오늘 앞(오늘 제외)의 KR 세션 수. 성공 세션 = 그 세션의 `equity_snapshot`
//    잡 성공(02 `job_run` — 소급 불가 잡이라 «엔진이 그날 끝까지 살았다»의 증거).
// 🔴 기준 없음 = null(«재개 판정 없음» — 첫 가동 · 실행 기록 이전) · 모르는 날 = 오류(0 으로 답하지 않는다).
// 🔴 임계 = 설정 값(전략 config_hash 밖 · 권고값 · 첫 3개월 로그로 재조정) — 부르는 쪽이 사다리를 넘긴다.

import 'package:domain_contracts/domain_contracts.dart'
    show ResumeMode, TradeDate;

import '../calendar/exchange_calendar.dart' show ExchangeCalendar;

/// 보수 모드 사다리(02 §4 `operations.resume`).
class ResumeLadder {
  /// 사다리를 만든다 — [gapLadderTradingDays] = 오름차순 3개(≥ 0 · NORMAL · CONSERVATIVE · RECOVERY_DRY 의 상한) ·
  /// [backupGapDays] ≥ 1(달력일). 아니면 [ArgumentError].
  ResumeLadder({
    required List<int> gapLadderTradingDays,
    required this.backupGapDays,
  }) : gapLadderTradingDays = List<int>.unmodifiable(gapLadderTradingDays) {
    final List<int> g = this.gapLadderTradingDays;
    if (g.length != 3) {
      throw ArgumentError.value(g, 'gapLadderTradingDays', '세 칸이어야 한다');
    }
    if (g[0] < 0 || g[1] <= g[0] || g[2] <= g[1]) {
      throw ArgumentError.value(g, 'gapLadderTradingDays', '0 이상 오름차순이어야 한다');
    }
    if (backupGapDays < 1) {
      throw ArgumentError.value(backupGapDays, 'backupGapDays', '1 이상이어야 한다');
    }
  }

  /// 02 §4 권고값(`[2, 5, 10]` · 백업 7일).
  static final ResumeLadder defaults = ResumeLadder(
    gapLadderTradingDays: const <int>[2, 5, 10],
    backupGapDays: 7,
  );

  /// NORMAL · CONSERVATIVE · RECOVERY_DRY 의 갭 상한(포함 · 거래일).
  final List<int> gapLadderTradingDays;

  /// 이 달력일 이상이면 RECOVERY_FULL.
  final int backupGapDays;
}

/// 갭(KR 세션 수) — [lastSuccessSession] 다음 ~ [today] 앞(오늘 제외).
///
/// 기준 없음 = null. 기준이 오늘보다 뒤면 [ArgumentError] · 달력 범위 밖이면 [StateError] 그대로.
int? resumeGapSessions({
  required ExchangeCalendar calendar,
  required TradeDate? lastSuccessSession,
  required TradeDate today,
}) {
  if (lastSuccessSession == null) return null;
  final DateTime from = _day(lastSuccessSession);
  final DateTime to = _day(today);
  if (from.isAfter(to)) {
    throw ArgumentError.value(
      lastSuccessSession.yyyyMmDd,
      'lastSuccessSession',
      '오늘보다 뒤의 성공 세션',
    );
  }
  int n = 0;
  for (
    DateTime d = from.add(const Duration(days: 1));
    d.isBefore(to);
    d = d.add(const Duration(days: 1))
  ) {
    if (calendar.isSession(TradeDate(_text(d)))) n++;
  }
  return n;
}

/// 갭 · 백업 갭 → 재개 모드(그림 10-3 · v2.42 ④).
///
/// [backupGapDays] = 복원한 백업의 나이(달력일) · null = 그 축 빠짐(원천 = E14d). 음수 = [ArgumentError].
ResumeMode resumeModeOf({
  required int gapSessions,
  required int? backupGapDays,
  required ResumeLadder ladder,
}) {
  if (gapSessions < 0) {
    throw ArgumentError.value(gapSessions, 'gapSessions', '음수 갭');
  }
  if (backupGapDays != null && backupGapDays < 0) {
    throw ArgumentError.value(backupGapDays, 'backupGapDays', '음수 백업 갭');
  }
  if (backupGapDays != null && backupGapDays >= ladder.backupGapDays) {
    return ResumeMode.recoveryFull;
  }
  final List<int> g = ladder.gapLadderTradingDays;
  if (gapSessions <= g[0]) return ResumeMode.normal;
  if (gapSessions <= g[1]) return ResumeMode.conservative;
  if (gapSessions <= g[2]) return ResumeMode.recoveryDry;
  return ResumeMode.recoveryFull;
}

DateTime _day(TradeDate d) {
  final DateTime? t = DateTime.tryParse('${d.yyyyMmDd}T00:00:00Z');
  if (t == null || _text(t) != d.yyyyMmDd) {
    throw ArgumentError.value(d.yyyyMmDd, 'date', 'YYYY-MM-DD 가 아니다');
  }
  return t;
}

String _text(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
