// 재량 예산(SAF-409 · FR-709) 판정 · 예산 셈 · 게이지 문장
// (04 §1 SAF-409 표 · v2.11 블록 · 05 AC-S18 GV-40e · 03_운영 재량 예산 표 · 설계 13 §8 R64 W2 · W3 · W6 · W7).
//
// 🔴 횟수는 DB 가 센다(04 §1 v2.11 ④) — 여기는 그 셈의 규칙이다.
// 🔴 사유는 전부 모아 오름차순(GV-40e e9) — 첫 사유에서 멈추지 않는다.
// 🔴 예산 셈은 하나(지도 D24) — 조정 요청 · X7 예산 사건(E18)이 같은 목록에 든다.
//    예산 0 이 막는 것은 «조정 요청» 뿐이다(01 §3-8 G-24 — 기록 · 미이행은 막지 않는다).

import 'package:domain_contracts/domain_contracts.dart'
    show DecisionJournalKinds;

/// 1회 조정폭 상한(±10%p · 04 §1 SAF-409 표 · 02 DDL CHECK — 경계 포함).
const double kDiscretionMaxDelta = 0.10;

/// 롤링 12개월 사용 상한(04 §1 SAF-409 표).
const int kDiscretionMaxUses = 4;

/// `decision_journal.kind` 의 재량 조정 저널(02 §2 · 🆕 미결 220 ⓒ — 계약 `DecisionJournalKinds` 참조 · K294 예외 = 동작 와이어
/// `DISCRETION_ADJUST` 와 다르다).
const String kDiscretionJournalKind = DecisionJournalKinds.discretion;

/// SAF-409 거부 코드(GV-40e · 오름차순 = 이 선언 차례).
abstract final class DiscretionCodes {
  /// 롤링 12개월 사용이 이미 상한.
  static const String countExceeded = 'COUNT_EXCEEDED';

  /// 조정폭이 상한 밖.
  static const String deltaExceeded = 'DELTA_EXCEEDED';

  /// 저널 미연결.
  static const String journalMissing = 'JOURNAL_MISSING';

  /// 신뢰 시각 모름(E11j 코드 재사용 · R64 W4).
  static const String trustedTimeUnknown = 'TRUSTED_TIME_UNKNOWN';
}

final RegExp _date = RegExp(r'^(\d{4})-(\d\d)-(\d\d)$');

String _two(int v) => v.toString().padLeft(2, '0');

String _dateText(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

/// 롤링 12개월 창의 첫날(포함) — 한국 날 `YYYY-MM-DD` 의 연 −1 같은 월·일(문자열).
///
/// 🔵 2월 29일의 전해 «02-29» 는 없는 날이지만 문자열 비교라 3월 1일부터 든다
/// (SQLite `date(…,'-12 months')` · 참조 `_minus_12_months` 와 같은 결).
String discretionWindowStart(String today) {
  final RegExpMatch? m = _date.firstMatch(today);
  if (m == null) throw FormatException('YYYY-MM-DD 아님', today);
  final int y = int.parse(m.group(1)!);
  return '${(y - 1).toString().padLeft(4, '0')}-${m.group(2)}-${m.group(3)}';
}

/// 롤링 12개월 사용 횟수(창 첫날 포함).
int rollingDiscretionUses(Iterable<String> useDates, String today) {
  final String start = discretionWindowStart(today);
  return useDates.where((String d) => d.compareTo(start) >= 0).length;
}

/// 그 사용이 창에서 빠지는 첫날(한국 날) — 그날부터 셈에서 빠진다.
String discretionRecoveryDate(String useDate) {
  final RegExpMatch? m = _date.firstMatch(useDate);
  if (m == null) throw FormatException('YYYY-MM-DD 아님', useDate);
  final int y = int.parse(m.group(1)!), mo = int.parse(m.group(2)!);
  // 이듬해 같은 달 1일부터 차례로 — 창 첫날이 그 사용보다 뒤인 첫날(2월 29일 = 3월 1일).
  DateTime d = DateTime.utc(y + 1, mo);
  while (discretionWindowStart(_dateText(d)).compareTo(useDate) <= 0) {
    d = d.add(const Duration(days: 1));
  }
  return _dateText(d);
}

/// 재량 저널의 사실(R64 W3) — `decision_journal` 행 + 이미 쓰였는지.
class DiscretionJournalFacts {
  /// 사실을 만든다.
  const DiscretionJournalFacts({
    required this.kind,
    required this.rationaleBefore,
    required this.expectedOutcome,
    required this.ruleCited,
    required this.alreadyUsed,
  });

  /// `decision_journal.kind`.
  final String? kind;

  /// 사전 3필드(SAF-408 과 같은 열).
  final String? rationaleBefore, expectedOutcome, ruleCited;

  /// 다른 조정이 이미 이 저널을 썼나.
  final bool alreadyUsed;
}

bool _filled(String? v) => v != null && v.trim().isNotEmpty;

/// 🔴 «저널 연결»(R64 W3) — 행 있음 ∧ kind DISCRETION ∧ 사전 3필드 ∧ 저널 하나 = 조정 하나.
bool discretionJournalLinked(DiscretionJournalFacts? j) =>
    j != null &&
    j.kind == kDiscretionJournalKind &&
    _filled(j.rationaleBefore) &&
    _filled(j.expectedOutcome) &&
    _filled(j.ruleCited) &&
    !j.alreadyUsed;

/// SAF-409 판정 결과.
class DiscretionJudgement {
  /// 결과를 만든다.
  const DiscretionJudgement({
    required this.rejectReasons,
    required this.rolling12mCount,
    required this.deltaPct,
  });

  /// 거부 사유(오름차순 · 빈 목록 = 반영).
  final List<String> rejectReasons;

  /// 요청 전 롤링 12개월 사용 횟수.
  final int rolling12mCount;

  /// 요청 조정폭.
  final double deltaPct;

  /// 반영하나.
  bool get applies => rejectReasons.isEmpty;
}

/// SAF-409 판정(GV-40e · 참조 `gv40e_discretion`).
///
/// 🔴 조정폭이 수가 아니면(NaN · 무한) 상한 밖이다(fail-closed).
DiscretionJudgement judgeDiscretion({
  required double deltaPct,
  required bool journalLinked,
  required Iterable<String> priorUseDates,
  required String today,
}) {
  final int rolling = rollingDiscretionUses(priorUseDates, today);
  final List<String> reasons = <String>[
    if (!(deltaPct.abs() <= kDiscretionMaxDelta)) DiscretionCodes.deltaExceeded,
    if (rolling >= kDiscretionMaxUses) DiscretionCodes.countExceeded,
    if (!journalLinked) DiscretionCodes.journalMissing,
  ]..sort();
  return DiscretionJudgement(
    rejectReasons: List<String>.unmodifiable(reasons),
    rolling12mCount: rolling,
    deltaPct: deltaPct,
  );
}

/// 재량 예산 한 장(R64 W6).
class DiscretionBudget {
  /// 예산을 만든다.
  const DiscretionBudget({
    required this.used,
    required this.max,
    required this.nextRecoveryDate,
  });

  /// 롤링 12개월 사용(조정 + X7 예산 사건 — X7 은 상한을 넘을 수 있다 · G-24).
  final int used;

  /// 상한.
  final int max;

  /// 남은 횟수가 하나 느는 첫날(한국 날) — 사용 0 이면 null.
  final String? nextRecoveryDate;

  /// 남은 횟수.
  int get remaining => used >= max ? 0 : max - used;

  /// 소진됐나.
  bool get exhausted => used >= max;
}

/// 예산 셈(R64 W6 · D24 하나) — 창 안 사용 · 다음 회복일.
DiscretionBudget discretionBudgetOf(Iterable<String> useDates, String today) {
  final String start = discretionWindowStart(today);
  final List<String> inWindow =
      useDates.where((String d) => d.compareTo(start) >= 0).toList()..sort();
  final int used = inWindow.length;
  // 남은 횟수가 느는 것 = 사용이 상한 − 1 로 내려올 때 — 그때까지 빠져야 하는 가장 늦은 사용의 회복일.
  final int idx = used >= kDiscretionMaxUses ? used - kDiscretionMaxUses : 0;
  return DiscretionBudget(
    used: used,
    max: kDiscretionMaxUses,
    nextRecoveryDate: used == 0 ? null : discretionRecoveryDate(inWindow[idx]),
  );
}

/// 게이지 문장(R64 W7) — 신뢰 시각 모름 = null.
String discretionBudgetText(DiscretionBudget? b) {
  if (b == null) return '재량 예산 — 신뢰 시각 확인 중';
  final String head = '12개월 ${b.max}회 중 ${b.used}회 사용';
  final String tail = b.nextRecoveryDate == null
      ? ''
      : ' · 다음 회복 ${b.nextRecoveryDate}';
  return b.exhausted ? '재량 예산 소진 — $head$tail' : '재량 예산 $head$tail';
}
