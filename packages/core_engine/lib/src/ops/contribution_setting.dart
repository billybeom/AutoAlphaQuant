// 월 납입 운영값(M3-6 엔진 몫 · 설계 13 §8 R54 J2~J5 · 01 §2-6 G-05 · §4-1 `ContributionSetting` · 02 §2 조회 규약 N-S4-01).
//
// 🔴 전략 `config_hash` **밖**의 운영 파라미터다 — 월말 계획 · what-if 계획 config 어디에도 들어가지 않는다.
// 🔴 납입 주기 = 매월 첫 KR 세션(`contribution_day = FIRST_TRADING_DAY`) · 접수가 그 앞이면 그 달부터 · 당일이나 뒤면 다음 달부터.
// 🔴 현재값 = `effective_from ≤ 오늘` 중 `changed_at` 최대 · `effective_from` 이 미래인 행은 **예정값**이다(현재값에 섞지 않는다).
// 🔴 문장은 전부 엔진이 만든다(화면은 비교 · 환산하지 않는다) — 꼴 = 픽스처 `m9/contribution_setting_*.json`.

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show AsOf, AsOfSource, ContributionSetting, TradeDate;

import '../calendar/exchange_calendar.dart';
import '../whatif/what_if_text.dart' show wonText;

/// 월 납입 운영 config(02 §4 `operations` 와 같은 결 — 전략 `config_hash` 밖).
class ContributionConfig {
  /// config 를 만든다.
  const ContributionConfig({
    required this.defaultAmount,
    required this.equivalentAmount,
    required this.maxAmount,
    required this.pensionAnnualLimit,
    required this.taxCreditBand,
    required this.asOfStaleAfter,
  });

  /// 기록이 하나도 없을 때의 값(발주자 결정 2026-09-07 · SPEC 2.32 7차).
  final Decimal defaultAmount;

  /// 12%-등가 월 납입(참고 역산치 · 백테스트6 P 회차 · 정직 기대 10.2% 기준).
  final Decimal equivalentAmount;

  /// 입력 상한(05 미결 16 권고 «상한 = 엔진 config» 선반영 · 발주자가 숫자를 정하면 여기만).
  final Decimal maxAmount;

  /// 연금 합산 연 납입한도.
  final Decimal pensionAnnualLimit;

  /// 세액공제 대상 구간.
  final Decimal taxCreditBand;

  /// 설정 화면 신선도.
  final Duration asOfStaleAfter;
}

/// P0S 기본 config.
ContributionConfig p0sContributionConfig() => ContributionConfig(
  defaultAmount: Decimal.fromInt(100000),
  equivalentAmount: Decimal.fromInt(97000),
  maxAmount: Decimal.fromInt(1000000000),
  pensionAnnualLimit: Decimal.fromInt(18000000),
  taxCreditBand: Decimal.fromInt(9000000),
  asOfStaleAfter: const Duration(hours: 26),
);

/// 운영 파라미터 한 행(`operating_param_log` · `monthly_contribution`).
class ContributionParamRow {
  /// 행을 만든다.
  const ContributionParamRow({
    required this.rowId,
    required this.amount,
    required this.changedAtUtc,
    required this.effectiveFrom,
    required this.actionRunId,
  });

  /// `row_id`.
  final int rowId;

  /// 금액(원).
  final Decimal amount;

  /// 접수 시각(신뢰 시각 · UTC).
  final DateTime changedAtUtc;

  /// 적용 개시일(한국 날짜 `YYYY-MM-DD` = 그 달 첫 KR 세션).
  final String effectiveFrom;

  /// `SettingsActions.run` 의 회차.
  final String actionRunId;
}

/// 저장 칸 글자 → 행(🔴 data_sync 는 `decimal` 을 쓰지 않는다 — 금액 해석은 여기서) · 못 읽음 = [FormatException].
ContributionParamRow contributionParamRowFromColumns({
  required int rowId,
  required String valueText,
  required String changedAtText,
  required String effectiveFrom,
  required String actionRunId,
}) => ContributionParamRow(
  rowId: rowId,
  amount: Decimal.parse(valueText),
  changedAtUtc: DateTime.parse(changedAtText).toUtc(),
  effectiveFrom: effectiveFrom,
  actionRunId: actionRunId,
);

String _kstYmd(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${k.year.toString().padLeft(4, '0')}-${two(k.month)}-${two(k.day)}';
}

/// [utc] 의 한국 날짜.
String contributionKstDay(DateTime utc) => _kstYmd(utc);

/// [year]-[month] 의 첫 KR 세션.
String firstKrSessionOfMonth(ExchangeCalendar kr, int year, int month) {
  final DateTime first = DateTime.utc(year, month);
  final TradeDate d = TradeDate(first.toIso8601String().substring(0, 10));
  return (kr.isSession(d) ? d : kr.nextSession(d)).yyyyMmDd;
}

/// 접수일 [kstDay] 의 적용 개시일(R54 J2 · 01 §2-6 G-05) — 그 달 첫 세션 **앞**이면 그 날 · 아니면 다음 달 첫 세션.
String contributionEffectiveFrom(ExchangeCalendar kr, String kstDay) {
  final int y = int.parse(kstDay.substring(0, 4));
  final int m = int.parse(kstDay.substring(5, 7));
  final String thisMonth = firstKrSessionOfMonth(kr, y, m);
  if (kstDay.compareTo(thisMonth) < 0) return thisMonth;
  return m == 12
      ? firstKrSessionOfMonth(kr, y + 1, 1)
      : firstKrSessionOfMonth(kr, y, m + 1);
}

/// [kstDay] 뒤(당일 제외)의 첫 납입 주기 날 — 예정이 없을 때 «다음 납입 주기».
String nextContributionDay(ExchangeCalendar kr, String kstDay) =>
    contributionEffectiveFrom(kr, kstDay);

bool _later(ContributionParamRow a, ContributionParamRow b) {
  final int c = a.changedAtUtc.compareTo(b.changedAtUtc);
  return c > 0 || (c == 0 && a.rowId > b.rowId);
}

/// (현재값 행 · 예정값 행)(R54 J3) — 둘 다 없을 수 있다.
(ContributionParamRow?, ContributionParamRow?) splitContributionRows(
  List<ContributionParamRow> rows,
  String todayKst,
) {
  ContributionParamRow? current;
  ContributionParamRow? pending;
  for (final ContributionParamRow r in rows) {
    if (r.effectiveFrom.compareTo(todayKst) <= 0) {
      if (current == null || _later(r, current)) current = r;
    } else {
      if (pending == null || _later(r, pending)) pending = r;
    }
  }
  // 🔴 현재값보다 먼저 접수된 예정은 이미 뒤 행에 덮였다(예정 뒤에 새로 바꿈 = 그 새 값이 이긴다).
  if (pending != null && current != null && !_later(pending, current)) {
    pending = null;
  }
  return (current, pending);
}

/// 가장 최근에 접수된 행(예정 포함) — «바뀌는 게 없음» 판정의 기준.
ContributionParamRow? latestContributionRow(List<ContributionParamRow> rows) {
  ContributionParamRow? out;
  for (final ContributionParamRow r in rows) {
    if (out == null || _later(r, out)) out = r;
  }
  return out;
}

String _monthDayText(String ymd) =>
    '${int.parse(ymd.substring(5, 7))}월 ${int.parse(ymd.substring(8, 10))}일';

/// 12%-등가 대비 한 줄(R54 J4).
String contributionEquivalentNoteText(Decimal amount, ContributionConfig cfg) =>
    amount >= cfg.equivalentAmount
    ? '12% 등가 납입액 대비 충족합니다.'
    : '12% 등가 납입액 대비 부족합니다.';

/// 연금 한도와의 관계 한 줄(R54 J4) — 0원 = null(비교할 것이 없다).
String? contributionPensionLimitNoteText(
  Decimal amount,
  ContributionConfig cfg,
) {
  if (amount <= Decimal.zero) return null;
  final Decimal year = amount * Decimal.fromInt(12);
  if (year > cfg.pensionAnnualLimit) {
    return '월 납입을 1년 모으면 ${wonText(year)}으로 연 합산 납입한도(${wonText(cfg.pensionAnnualLimit)})를 넘습니다 — 넘는 몫은 연금 계좌에 넣을 수 없습니다.';
  }
  if (year > cfg.taxCreditBand) {
    return '월 납입을 1년 모으면 ${wonText(year)}으로 세액공제 대상 구간(${wonText(cfg.taxCreditBand)})을 넘습니다 — 넘는 몫은 공제되지 않습니다.';
  }
  return '월 납입만으로는 연 합산 납입한도에 닿지 않습니다.';
}

/// `ContributionSetting`(R54 J3 · J4) — [todayKst] = 오늘(한국 날짜) · [observedAtUtc] = 읽은 시각.
ContributionSetting contributionSettingOf({
  required List<ContributionParamRow> rows,
  required String todayKst,
  required DateTime observedAtUtc,
  required ExchangeCalendar kr,
  ContributionConfig? config,
}) {
  final ContributionConfig cfg = config ?? p0sContributionConfig();
  final (ContributionParamRow? current, ContributionParamRow? pending) =
      splitContributionRows(rows, todayKst);
  final Decimal amount = current?.amount ?? cfg.defaultAmount;
  final ContributionParamRow? latest = latestContributionRow(rows);
  final String applies = pending != null
      ? '다음 납입 주기(${_monthDayText(pending.effectiveFrom)})부터 ${wonText(pending.amount)}이 적용됩니다.'
      : '다음 납입 주기(${_monthDayText(nextContributionDay(kr, todayKst))})부터 이 금액이 적용됩니다.';
  final String lastChanged;
  if (latest == null) {
    lastChanged = '변경 기록 없음(기본값)';
  } else {
    ContributionParamRow? before;
    for (final ContributionParamRow r in rows) {
      if (_later(latest, r) && (before == null || _later(r, before))) {
        before = r;
      }
    }
    final String day = _kstYmd(latest.changedAtUtc);
    // 첫 기록의 «앞 값» = 그때까지 적용되던 기본값.
    final Decimal from = before?.amount ?? cfg.defaultAmount;
    lastChanged = from == latest.amount
        ? '최근 변경: $day · ${wonText(latest.amount)}으로 정함'
        : '최근 변경: $day · ${wonText(from)} → ${wonText(latest.amount)}';
  }
  return ContributionSetting(
    amount: amount,
    amountText: wonText(amount),
    amountInputText: amount.toBigInt().toString(),
    equivalentNoteText: contributionEquivalentNoteText(amount, cfg),
    appliesFromText: applies,
    lastChangedText: lastChanged,
    asOf: AsOf(
      observedAt: observedAtUtc.toUtc(),
      tradeDate: TradeDate(todayKst),
      source: AsOfSource.localSqlite,
      staleAfter: cfg.asOfStaleAfter,
      label: '설정 기준 $todayKst',
    ),
    pensionLimitNoteText: contributionPensionLimitNoteText(amount, cfg),
  );
}

/// 거부 사유 코드(🟡 계약 등재 = `settingsContributionUpdate` 바인딩 창).
abstract final class ContributionRejectCodes {
  /// 빈칸.
  static const String blank = 'CONTRIBUTION_INPUT_BLANK';

  /// 숫자 아님.
  static const String notNumber = 'CONTRIBUTION_INPUT_NOT_NUMBER';

  /// 음수.
  static const String negative = 'CONTRIBUTION_INPUT_NEGATIVE';

  /// 상한 초과.
  static const String overMax = 'CONTRIBUTION_INPUT_OVER_MAX';

  /// 바뀌는 게 없음.
  static const String unchanged = 'CONTRIBUTION_UNCHANGED';

  /// 신뢰 시각 모름.
  static const String trustedTimeUnknown = 'TRUSTED_TIME_UNKNOWN';

  /// 신뢰 시각이 마지막 기록보다 앞서지 않음(같은 순간 · 되감김).
  static const String clockNotAdvanced = 'CONTRIBUTION_CLOCK_NOT_ADVANCED';
}

/// 변경 판정.
class ContributionDecision {
  const ContributionDecision._({
    this.amount,
    this.effectiveFrom,
    this.changedAtUtc,
    this.replay,
    this.reasonCode,
    this.rejectedText,
  });

  /// 받아들임(새 행) — 금액.
  final Decimal? amount;

  /// 받아들임 — 적용 개시일.
  final String? effectiveFrom;

  /// 받아들임 — 접수 시각(신뢰 시각).
  final DateTime? changedAtUtc;

  /// 같은 회차 재시도 — 이미 있는 행.
  final ContributionParamRow? replay;

  /// 거부 — 사유 코드.
  final String? reasonCode;

  /// 거부 — 엔진 문장.
  final String? rejectedText;

  /// 새 행을 쓴다.
  bool get accepted => amount != null;

  /// 거부.
  bool get rejected => reasonCode != null;
}

final RegExp _digits = RegExp(r'^[0-9]+$');
final RegExp _negative = RegExp(r'^-[0-9]+$');

/// 변경 판정(R54 J5) — 입력칸 글자 그대로 · 같은 [actionRunId] 가 이미 있으면 그 행을 돌려준다(멱등).
ContributionDecision decideContributionChange({
  required String amountInput,
  required String actionRunId,
  required List<ContributionParamRow> rows,
  required DateTime? trustedNowUtc,
  required ExchangeCalendar kr,
  ContributionConfig? config,
}) {
  for (final ContributionParamRow r in rows) {
    if (r.actionRunId == actionRunId) return ContributionDecision._(replay: r);
  }
  final ContributionConfig cfg = config ?? p0sContributionConfig();
  ContributionDecision reject(String code, String text) =>
      ContributionDecision._(reasonCode: code, rejectedText: text);
  final String s = amountInput.trim().replaceAll(',', '');
  if (s.isEmpty) {
    return reject(ContributionRejectCodes.blank, '금액을 입력해 주세요.');
  }
  if (_negative.hasMatch(s)) {
    return reject(ContributionRejectCodes.negative, '0원 이상으로 입력해 주세요.');
  }
  if (!_digits.hasMatch(s)) {
    return reject(ContributionRejectCodes.notNumber, '금액을 원 단위 숫자로 입력해 주세요.');
  }
  final Decimal v = Decimal.parse(s);
  if (v > cfg.maxAmount) {
    return reject(
      ContributionRejectCodes.overMax,
      '${wonText(cfg.maxAmount)}까지 입력할 수 있습니다.',
    );
  }
  if (trustedNowUtc == null) {
    return reject(
      ContributionRejectCodes.trustedTimeUnknown,
      '서버 시각을 확인하지 못해 지금은 바꿀 수 없습니다. 연결을 확인한 뒤 다시 시도해 주세요.',
    );
  }
  final ContributionParamRow? latest = latestContributionRow(rows);
  // 🔴 «changed_at 최대 = 이긴다» 규약이 서려면 접수 시각이 늘 앞으로 가야 한다(UNIQUE(param_key, changed_at) 와 같은 뜻).
  if (latest != null && !trustedNowUtc.isAfter(latest.changedAtUtc)) {
    return reject(
      ContributionRejectCodes.clockNotAdvanced,
      '방금 바뀐 기록이 있습니다. 잠시 뒤 다시 시도해 주세요.',
    );
  }
  final Decimal standing = latest?.amount ?? cfg.defaultAmount;
  if (v == standing) {
    return reject(ContributionRejectCodes.unchanged, '지금 금액과 같습니다.');
  }
  return ContributionDecision._(
    amount: v,
    effectiveFrom: contributionEffectiveFrom(kr, _kstYmd(trustedNowUtc)),
    changedAtUtc: trustedNowUtc.toUtc(),
  );
}
