// 본인 서약문 3문장 · 12월 편집 창 · DD 최초 도달 재생(M5-8 · 06 · 04M8 O-04 ② · 02 §2 `pledge` · `pledge_replay` ·
// 02 §4 `operations.pledge.replay_dd` · 설계 13 §8 R67).
//
// 🔴 원문은 한 번만 만든다(온보딩 첫 판) — 재생처(DD 게이트 · 재개 게이트 첫 화면 · 개입 2단계 · J-3)는 재생만.
// 🔴 편집 = 12월 창만(한국 달) · 같은 문장 = 새 판 없음.
// 🔴 재생 = 에피소드(마지막 고점부터)마다 임계당 한 번 · 여럿을 건너뛰어도 한 번(경보 피로).

import '../ops/ledger_views.dart' show kstDateText;
import 'rule_change.dart' show kRuleChangeWindowMonth;

/// 재생 임계(02 §4 `operations.pledge.replay_dd` · 얕은 것부터).
const List<double> kPledgeReplayDd = <double>[-0.10, -0.15, -0.20];

/// 서약 문장 수.
const int kPledgeSentences = 3;

/// 서약 거부 코드(R67).
abstract final class PledgeCodes {
  /// 이미 첫 판이 있다(원문은 한 번만).
  static const String alreadyWritten = 'PLEDGE_ALREADY_WRITTEN';

  /// 편집 저널 미연결.
  static const String journalMissing = 'PLEDGE_JOURNAL_MISSING';

  /// 첫 판이 없다(편집할 것이 없다).
  static const String notWritten = 'PLEDGE_NOT_WRITTEN';

  /// 12월 창 밖.
  static const String outOfWindow = 'PLEDGE_OUT_OF_WINDOW';

  /// 문장 빈칸 · 셋이 아님.
  static const String sentencesMissing = 'PLEDGE_SENTENCES_MISSING';

  /// 지금 판과 같다.
  static const String unchanged = 'PLEDGE_UNCHANGED';

  /// 신뢰 시각 모름(E11j 코드 재사용).
  static const String trustedTimeUnknown = 'TRUSTED_TIME_UNKNOWN';
}

/// 서약 한 판.
class Pledge {
  /// 판을 만든다.
  const Pledge({
    required this.version,
    required this.lines,
    required this.writtenAtUtc,
  });

  /// 판(1부터).
  final int version;

  /// 세 문장(차례대로).
  final List<String> lines;

  /// 쓴 시각(신뢰 시각).
  final DateTime writtenAtUtc;
}

/// 앞뒤 공백을 뺀 세 문장 — 셋이 아니거나 하나라도 비면 null.
List<String>? pledgeSentencesOf(List<String> sentences) {
  if (sentences.length != kPledgeSentences) return null;
  final List<String> out = <String>[for (final String s in sentences) s.trim()];
  return out.any((String s) => s.isEmpty) ? null : out;
}

/// 첫 판 판정(R67 Z1) — 통과 = null.
String? pledgeWriteRejectCode({
  required DateTime? nowUtc,
  required Pledge? current,
  required List<String> sentences,
  required String decisionId,
}) {
  if (nowUtc == null) return PledgeCodes.trustedTimeUnknown;
  if (current != null) return PledgeCodes.alreadyWritten;
  if (pledgeSentencesOf(sentences) == null) {
    return PledgeCodes.sentencesMissing;
  }
  if (decisionId.trim().isEmpty) return PledgeCodes.journalMissing;
  return null;
}

/// 편집 판정(R67 Z2) — 통과 = null.
String? pledgeEditRejectCode({
  required DateTime? nowUtc,
  required Pledge? current,
  required List<String> sentences,
  required bool journalLinked,
}) {
  if (nowUtc == null) return PledgeCodes.trustedTimeUnknown;
  if (current == null) return PledgeCodes.notWritten;
  final int month = int.parse(kstDateText(nowUtc).substring(5, 7));
  if (month != kRuleChangeWindowMonth) return PledgeCodes.outOfWindow;
  final List<String>? next = pledgeSentencesOf(sentences);
  if (next == null) return PledgeCodes.sentencesMissing;
  bool same = true;
  for (int i = 0; i < kPledgeSentences; i++) {
    if (next[i] != current.lines[i]) same = false;
  }
  if (same) return PledgeCodes.unchanged;
  if (!journalLinked) return PledgeCodes.journalMissing;
  return null;
}

/// 스냅숏 한 날(날짜 · DD).
class DrawdownPoint {
  /// 점을 만든다.
  const DrawdownPoint(this.tradeDate, this.drawdown);

  /// 거래일 `YYYY-MM-DD`.
  final String tradeDate;

  /// DD(≤ 0).
  final double drawdown;
}

/// 하락 에피소드(R67 Z5).
class DrawdownEpisode {
  /// 에피소드를 만든다.
  const DrawdownEpisode({required this.peakDate, required this.minDrawdown});

  /// 마지막 고점 날(에피소드 키).
  final String peakDate;

  /// 고점부터 지금까지의 최저 DD.
  final double minDrawdown;
}

/// 지금 에피소드 — 스냅숏 없음 = null · 고점 = DD ≥ 0 인 마지막 날(없으면 첫 날).
DrawdownEpisode? currentEpisodeOf(Iterable<DrawdownPoint> points) {
  final List<DrawdownPoint> ps = points.toList()
    ..sort(
      (DrawdownPoint a, DrawdownPoint b) => a.tradeDate.compareTo(b.tradeDate),
    );
  if (ps.isEmpty) return null;
  int peak = 0;
  for (int i = 0; i < ps.length; i++) {
    if (ps[i].drawdown >= 0) peak = i;
  }
  double minDd = ps[peak].drawdown;
  for (int i = peak; i < ps.length; i++) {
    if (ps[i].drawdown < minDd) minDd = ps[i].drawdown;
  }
  return DrawdownEpisode(peakDate: ps[peak].tradeDate, minDrawdown: minDd);
}

/// 재생 대상(R67 Z6).
class PledgeReplayDue {
  /// 대상을 만든다.
  const PledgeReplayDue({required this.peakDate, required this.thresholds});

  /// 에피소드 키.
  final String peakDate;

  /// 닿았고 아직 재생하지 않은 임계(얕은 것부터).
  final List<double> thresholds;

  /// 보여 줄 임계 — 가장 깊은 것.
  double get deepest => thresholds.last;
}

/// 재생 대상 — 서약 없음 · 에피소드 없음 · 대상 없음 = null.
PledgeReplayDue? pledgeReplayDueOf({
  required bool hasPledge,
  required DrawdownEpisode? episode,
  required Set<double> shownThresholds,
}) {
  if (!hasPledge || episode == null) return null;
  final List<double> due = <double>[
    for (final double t in kPledgeReplayDd)
      if (episode.minDrawdown <= t && !shownThresholds.contains(t)) t,
  ];
  if (due.isEmpty) return null;
  return PledgeReplayDue(
    peakDate: episode.peakDate,
    thresholds: List<double>.unmodifiable(due),
  );
}
