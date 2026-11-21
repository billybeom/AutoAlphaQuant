// X5 읽기 쪽 — `L-1` 최근 차이 · 5칸 대조 보드(앱 계약 01 §2-9 · §21-5-4 · §23 · 설계 13 §8 R59 S1~S7).
//
// 🔴 글자 · 색 · 순서 = 엔진이 정한다 — 화면은 `level` · `*Label` 만 그린다(원값으로 색을 고르지 않는다).
// 🔴 파생 불일치(미러 · 아카이브 · 캘린더)는 어떤 경우에도 `blocked` 가 아니다 — 주문을 막지 않는다.
// 🔴 해당 없는 칸도 빼지 않는다 — 칸 수 5 고정 · «점검 안 함»을 빈칸 · 통과로 그리지 않는다.

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:domain_contracts/domain_contracts.dart';

/// `L-1` 최근 창(R59 S1) — 닫힌 차이는 이 기간 안의 것만.
const Duration kRecentDiffWindow = Duration(days: 30);

/// `L-1` 한 번에 내보내는 행 수(R59 S1).
const int kRecentDiffLimit = 50;

/// 대조 기준의 신선 한도(R59 S7 · 픽스처 93600초).
const Duration kReconStaleAfter = Duration(hours: 26);

/// 쌍 라벨(R59 S3 · `DiagnosticCell.label` 과 같은 사전).
String pairLabelOf(LedgerPair p) => switch (p) {
  LedgerPair.canonBroker => '브로커 대조',
  LedgerPair.canonSupabase => '미러 대조',
  LedgerPair.canonGithub => '아카이브 대조',
  LedgerPair.canonCalendar => '캘린더 대조',
  LedgerPair.canonSelfReport => '자가 보고 대조',
};

/// 축 라벨.
String axisLabelOf(LedgerAxis a) => switch (a) {
  LedgerAxis.quantity => '수량',
  LedgerAxis.executionRow => '체결 건',
  LedgerAxis.cash => '현금',
  LedgerAxis.chainHash => '체인 해시',
};

/// 심각도 라벨.
String severityLabelOf(DiffSeverity s) => switch (s) {
  DiffSeverity.blocking => '주문 차단',
  DiffSeverity.observational => '관측 항목 — 주문을 막지 않습니다',
};

/// 경로(R59 S4) — 차단 = 승인 · 관측 = 자동.
RepairRoute routeOf(DiffSeverity s) => switch (s) {
  DiffSeverity.blocking => RepairRoute.approval,
  DiffSeverity.observational => RepairRoute.auto,
};

/// 경로 라벨.
String routeLabelOf(RepairRoute r) => switch (r) {
  RepairRoute.auto => '자동 재동기화',
  RepairRoute.approval => '승인 필요',
  RepairRoute.x1Emergency => '긴급 경로',
};

/// 원인 코드 라벨(R59 S3 · 정해진 6 + 초안).
const Map<String, String> kOriginLabels = <String, String>{
  OriginCodes.fillLag: '체결 반영 지연',
  OriginCodes.manualOrder: '수동 주문',
  OriginCodes.dbError: '원장 기록 오류',
  OriginCodes.brokerError: '브로커 응답 오류',
  OriginCodes.externalCashflow: '시스템 밖 입출금',
  OriginCodes.corporateAction: '분할 · 병합',
  OriginCodes.corpActionLegacy: '분할 · 병합(옛 코드)',
  OriginCodes.pushLag: '미러 전송 지연',
  OriginCodes.pushFailed: '미러 전송 실패',
  OriginCodes.archiveLag: '아카이브 적체',
  OriginCodes.calWriteFailed: '캘린더 쓰기 실패',
  OriginCodes.schemaSkew: '스키마 판 어긋남',
  OriginCodes.chainBroken: '체인 끊김',
  OriginCodes.restoreRollback: '복원 되돌림',
  OriginCodes.advisoryFill: '안내 체결',
  OriginCodes.unrecordedFill: '기록 안 된 체결',
  OriginCodes.misrecordedFill: '잘못 기록된 체결',
  OriginCodes.selfReportCorrection: '자가 보고 정정',
  OriginCodes.externalHolding: '시스템 밖 보유',
  OriginCodes.accountMisdeclared: '계좌 신고 오류',
};

/// 원인 코드 칩 — 🔴 모르는 코드 = [ArgumentError](열거 밖 글자를 만들지 않는다).
ReasonChip originChipOf(String code) {
  final String? label = kOriginLabels[code];
  if (label == null) throw ArgumentError.value(code, 'code', '모르는 원인 코드');
  return ReasonChip(
    code: code,
    label: label,
    tone: ChipTone.neutral,
    detailDeepLink: code == OriginCodes.fillLag
        ? 'handbook://unknown/resolve'
        : null,
  );
}

String _two(int n) => n.toString().padLeft(2, '0');

DateTime _kst(DateTime utc) => utc.toUtc().add(const Duration(hours: 9));

/// 한국 날짜 `YYYY-MM-DD`.
String kstDateText(DateTime utc) {
  final DateTime k = _kst(utc);
  return '${k.year.toString().padLeft(4, '0')}-${_two(k.month)}-${_two(k.day)}';
}

/// 한국 시각 `YYYY-MM-DD HH:mm`.
String kstMinuteText(DateTime utc) {
  final DateTime k = _kst(utc);
  return '${kstDateText(utc)} ${_two(k.hour)}:${_two(k.minute)}';
}

/// 상태 라벨(R59 S2 — 닫힌 시각을 모르면 날짜 없이).
String statusLabelOf(DiffStatus s, DateTime? closedAtUtc) {
  final String day = closedAtUtc == null
      ? ''
      : ' · ${kstDateText(closedAtUtc)}';
  return switch (s) {
    DiffStatus.open => '열림',
    DiffStatus.resolved => '해소됨$day',
    DiffStatus.accepted => '받아들임$day',
  };
}

/// 증거 해시(R59 S3) — `delta` 의 SHA-256 앞 12자(브로커 원문은 저장하지 않는다).
String evidenceHashOf(String delta) =>
    'ev_${sha256.convert(utf8.encode(delta)).toString().substring(0, 12)}';

/// `delta` 의 후보 원인 코드(없으면 빈 목록).
List<String> candidatesOfDelta(String delta) {
  final Object? j = jsonDecode(delta);
  if (j is! Map<String, Object?>) return const <String>[];
  final Object? c = j['candidates'];
  return c is List<Object?>
      ? <String>[for (final Object? x in c) x! as String]
      : const <String>[];
}

T _byWire<T>(List<T> values, String Function(T) wire, Object? w) {
  for (final T v in values) {
    if (wire(v) == w) return v;
  }
  throw FormatException('모르는 값', w);
}

/// `ledger_diff` 한 행(+ 닫힌 시각).
class StoredLedgerDiff {
  /// 행을 만든다.
  const StoredLedgerDiff({
    required this.diffId,
    required this.pair,
    required this.axis,
    required this.authoredDate,
    required this.delta,
    required this.deltaLabel,
    required this.severity,
    required this.status,
    required this.detectedAtUtc,
    required this.applicable,
    this.closedAtUtc,
  });

  /// 칸 이름 → 값(SQL 행)으로 만든다 — 모르는 열거 값 = [FormatException].
  factory StoredLedgerDiff.fromColumns(
    Map<String, Object?> c, {
    DateTime? closedAtUtc,
  }) => StoredLedgerDiff(
    diffId: c['diff_id']! as String,
    pair: _byWire(LedgerPair.values, (LedgerPair v) => v.wire, c['pair']),
    axis: _byWire(LedgerAxis.values, (LedgerAxis v) => v.wire, c['axis']),
    authoredDate: TradeDate(c['authored_date']! as String),
    delta: c['delta']! as String,
    deltaLabel: c['delta_label']! as String,
    severity: _byWire(
      DiffSeverity.values,
      (DiffSeverity v) => v.wire,
      c['severity'],
    ),
    status: _byWire(DiffStatus.values, (DiffStatus v) => v.wire, c['status']),
    detectedAtUtc: DateTime.parse(c['detected_at']! as String).toUtc(),
    applicable: c['applicable'] == 1,
    closedAtUtc: closedAtUtc,
  );

  /// 칸.
  final String diffId, delta, deltaLabel;

  /// 쌍 · 축.
  final LedgerPair pair;

  /// 축.
  final LedgerAxis axis;

  /// 집행일.
  final TradeDate authoredDate;

  /// 심각도 · 상태.
  final DiffSeverity severity;

  /// 상태.
  final DiffStatus status;

  /// 탐지 · 닫힌 시각.
  final DateTime detectedAtUtc;

  /// 닫힌 시각(열림 · 모름 = null).
  final DateTime? closedAtUtc;

  /// 점검했나.
  final bool applicable;
}

/// 저장 행 → `LedgerDiffRow`(R59 S3 · S4) — [phone] = operator 폰(조치 링크를 단다).
LedgerDiffRow ledgerDiffRowOf(StoredLedgerDiff d, {bool phone = true}) {
  final RepairRoute route = routeOf(d.severity);
  final List<String> candidates = candidatesOfDelta(d.delta);
  return LedgerDiffRow(
    diffId: d.diffId,
    pair: d.pair,
    axis: d.axis,
    authoredDate: d.authoredDate,
    deltaLabel: d.deltaLabel,
    severity: d.severity,
    candidateOriginCodes: candidates,
    status: d.status,
    route: route,
    evidenceHash: evidenceHashOf(d.delta),
    applicable: d.applicable,
    pairLabel: pairLabelOf(d.pair),
    axisLabel: axisLabelOf(d.axis),
    severityLabel: severityLabelOf(d.severity),
    statusLabel: statusLabelOf(d.status, d.closedAtUtc),
    routeLabel: routeLabelOf(route),
    candidateOrigins: <ReasonChip>[
      for (final String c in candidates) originChipOf(c),
    ],
    detectedAtText: '탐지 ${kstMinuteText(d.detectedAtUtc)}',
    // 🆕 E16j-a(01 §8 미결 217 ⓕ · 계약 v1.32 K248) — 대상 라우트(어느 차이인지 싣는다 · 허브 = 목록).
    actionLink:
        phone && d.status == DiffStatus.open && route == RepairRoute.approval
        ? LinkAction(
            label: '정정하기',
            deepLink: AppRoutes.x5RepairTarget.replaceFirst(
              ':targetId',
              d.diffId,
            ),
          )
        : null,
  );
}

/// 대조 기준 `AsOf`(R59 S7) — 관측 = 마지막 대사(없으면 지금).
AsOf reconAsOf({
  required DateTime? lastReconUtc,
  required DateTime nowUtc,
  String prefix = '대조 기준',
}) {
  final DateTime at = (lastReconUtc ?? nowUtc).toUtc();
  final String day = kstDateText(at);
  return AsOf(
    observedAt: at,
    tradeDate: TradeDate(day),
    source: AsOfSource.localSqlite,
    staleAfter: kReconStaleAfter,
    label: '$prefix $day',
  );
}

/// `L-1` 최근 차이(R59 S1) — 열린 것 전부 + 닫힌 날이 창 안인 것 · 정렬 · 50행.
ListResult<LedgerDiffRow> recentLedgerDiffsOf(
  List<StoredLedgerDiff> rows, {
  required DateTime nowUtc,
  required AsOf asOf,
  bool phone = true,
  int limit = kRecentDiffLimit,
}) {
  final String since = kstDateText(nowUtc.subtract(kRecentDiffWindow));
  DateTime closedKey(StoredLedgerDiff d) => d.closedAtUtc ?? d.detectedAtUtc;
  int rank(StoredLedgerDiff d) => d.status != DiffStatus.open
      ? 2
      : d.severity == DiffSeverity.blocking
      ? 0
      : 1;
  final List<StoredLedgerDiff> picked =
      <StoredLedgerDiff>[
        for (final StoredLedgerDiff d in rows)
          if (d.status == DiffStatus.open ||
              kstDateText(closedKey(d)).compareTo(since) >= 0)
            d,
      ]..sort((StoredLedgerDiff a, StoredLedgerDiff b) {
        final int r = rank(a).compareTo(rank(b));
        if (r != 0) return r;
        final int t = rank(a) == 2
            ? closedKey(b).compareTo(closedKey(a))
            : b.detectedAtUtc.compareTo(a.detectedAtUtc);
        return t != 0 ? t : a.diffId.compareTo(b.diffId);
      });
  return ListResult<LedgerDiffRow>(
    rows: <LedgerDiffRow>[
      for (final StoredLedgerDiff d in picked.take(limit))
        ledgerDiffRowOf(d, phone: phone),
    ],
    asOf: asOf,
    emptyKind: EmptyKind.noData,
    emptyLabel: picked.isEmpty ? '최근 대조 차이가 없습니다' : null,
    hasMore: picked.length > limit,
  );
}

/// 빈 목록 봉투(생산자 판 전 · R59 S9).
ListResult<T> emptyLedgerList<T>(AsOf asOf, String label) => ListResult<T>(
  rows: <T>[],
  asOf: asOf,
  emptyKind: EmptyKind.noData,
  emptyLabel: label,
  hasMore: false,
);

// ── 5칸 대조 보드(R59 S5 · S6) ─────────────────────────────────────────────

/// 칸 상태 코드(새 열거 0 — 문자열).
abstract final class DiagnosticStates {
  /// 일치.
  static const String ok = 'OK';

  /// 어긋남.
  static const String mismatch = 'MISMATCH';

  /// 뒤처짐(파생).
  static const String lag = 'LAG';

  /// 대사 실패.
  static const String unavailable = 'UNAVAILABLE';

  /// 현금 관측.
  static const String cashObserved = 'CASH_OBSERVED';

  /// 점검 안 함.
  static const String notChecked = 'NOT_CHECKED';

  /// 해당 없음.
  static const String notApplicable = 'NOT_APPLICABLE';
}

/// 브로커 칸 재료.
class BrokerReconSummary {
  /// 재료를 만든다.
  const BrokerReconSummary({
    required this.reconRan,
    this.lastActionCode,
    this.openBlockingAxes = const <LedgerAxis>{},
    this.openObservational = false,
  });

  /// 대사를 한 번이라도 돌렸나.
  final bool reconRan;

  /// 마지막 대사의 `action_taken`.
  final String? lastActionCode;

  /// 열린 차단 행의 축.
  final Set<LedgerAxis> openBlockingAxes;

  /// 열린 관측 행(현금)이 있나.
  final bool openObservational;
}

/// 파생 칸 재료.
class DerivedPairSummary {
  /// 재료를 만든다.
  const DerivedPairSummary({
    required this.connected,
    this.openCandidates = const <List<String>>[],
  });

  /// 대상이 생겼나(`sync_state` 행).
  final bool connected;

  /// 열린 행마다의 후보 원인 코드.
  final List<List<String>> openCandidates;
}

DiagnosticCell _cell(
  LedgerPair p,
  String code,
  String label,
  UiLevel level, {
  bool applicable = true,
}) => DiagnosticCell(
  pair: p,
  label: pairLabelOf(p),
  applicable: applicable,
  stateCode: code,
  stateLabel: label,
  level: level,
);

/// 브로커 칸(R59 S5).
DiagnosticCell brokerCellOf(OperatingMode mode, BrokerReconSummary s) {
  const LedgerPair p = LedgerPair.canonBroker;
  if (mode == OperatingMode.advisory) {
    return _cell(
      p,
      DiagnosticStates.notApplicable,
      '해당 없음',
      UiLevel.info,
      applicable: false,
    );
  }
  if (!s.reconRan) {
    return _cell(
      p,
      DiagnosticStates.notChecked,
      '아직 대사 전 — 점검 안 함',
      UiLevel.info,
      applicable: false,
    );
  }
  if (s.openBlockingAxes.isNotEmpty) {
    final List<String> axes = <String>[
      for (final LedgerAxis a in <LedgerAxis>[
        LedgerAxis.quantity,
        LedgerAxis.executionRow,
      ])
        if (s.openBlockingAxes.contains(a)) axisLabelOf(a),
    ];
    // 수량 · 체결 건 = 받침이 있어 «이».
    return _cell(
      p,
      DiagnosticStates.mismatch,
      '${axes.join(' · ')}이 어긋납니다',
      UiLevel.blocked,
    );
  }
  if (s.lastActionCode == 'UNAVAILABLE') {
    return _cell(p, DiagnosticStates.unavailable, '대사하지 못했습니다', UiLevel.watch);
  }
  if (s.openObservational) {
    return _cell(
      p,
      DiagnosticStates.cashObserved,
      '현금이 기록과 다릅니다(관측)',
      UiLevel.watch,
    );
  }
  return _cell(p, DiagnosticStates.ok, '일치', UiLevel.ok);
}

/// 지연 원인(R59 S5).
const Set<String> kLagOriginCodes = <String>{
  OriginCodes.pushLag,
  OriginCodes.archiveLag,
};

String _derivedNoun(LedgerPair p) => switch (p) {
  LedgerPair.canonSupabase => '미러',
  LedgerPair.canonGithub => '아카이브',
  LedgerPair.canonCalendar => '캘린더',
  _ => throw ArgumentError.value(p, 'pair', '파생 쌍이 아니다'),
};

/// 파생 칸(R59 S5) — 🔴 늘 `watch` 이하(주문을 막지 않는다).
DiagnosticCell derivedCellOf(LedgerPair p, DerivedPairSummary s) {
  final String noun = _derivedNoun(p);
  if (!s.connected) {
    return _cell(
      p,
      DiagnosticStates.notChecked,
      '아직 연결 전 — 점검 안 함',
      UiLevel.info,
      applicable: false,
    );
  }
  if (s.openCandidates.isEmpty) {
    return _cell(p, DiagnosticStates.ok, '일치', UiLevel.ok);
  }
  final bool lagOnly = s.openCandidates.every(
    (List<String> c) => c.isNotEmpty && c.every(kLagOriginCodes.contains),
  );
  return lagOnly
      ? _cell(p, DiagnosticStates.lag, '$noun가 뒤처집니다', UiLevel.watch)
      : _cell(p, DiagnosticStates.mismatch, '$noun가 어긋납니다', UiLevel.watch);
}

/// 자가 보고 칸(R59 S5 · E18 전).
DiagnosticCell selfReportCellOf(OperatingMode mode) =>
    mode == OperatingMode.autoTrade
    ? _cell(
        LedgerPair.canonSelfReport,
        DiagnosticStates.notApplicable,
        '해당 없음',
        UiLevel.info,
        applicable: false,
      )
    : _cell(
        LedgerPair.canonSelfReport,
        DiagnosticStates.notChecked,
        '점검하지 않음',
        UiLevel.info,
        applicable: false,
      );

const List<String> _countWords = <String>['', '한', '두', '세', '네', '다섯'];

const Set<LedgerPair> _derivedPairs = <LedgerPair>{
  LedgerPair.canonSupabase,
  LedgerPair.canonGithub,
  LedgerPair.canonCalendar,
};

/// 요약 문장(R59 S6) — 🔴 늘 엔진 문장(빈 글자 0).
String diagnosticsHeadline(List<DiagnosticCell> cells) {
  final List<DiagnosticCell> checked = <DiagnosticCell>[
    for (final DiagnosticCell c in cells)
      if (c.applicable) c,
  ];
  if (checked.isEmpty) return '아직 점검한 칸이 없습니다.';
  int count(String code) =>
      checked.where((DiagnosticCell c) => c.stateCode == code).length;
  final int notOk = checked
      .where((DiagnosticCell c) => c.stateCode != DiagnosticStates.ok)
      .length;
  if (notOk == 0) {
    return '점검한 ${_countWords[checked.length]} 칸이 모두 일치합니다.';
  }
  final String total = _countWords[cells.length];
  final int mismatch = count(DiagnosticStates.mismatch);
  final int lag = count(DiagnosticStates.lag);
  final String first = mismatch > 0
      ? '$total 칸 중 ${_countWords[mismatch]} 칸이 어긋납니다.'
      : lag > 0
      ? '$total 칸 중 ${_countWords[lag]} 칸이 뒤처집니다.'
      : '$total 칸 중 ${_countWords[notOk]} 칸을 확인해 주십시오.';
  final bool derivedOff = checked.any(
    (DiagnosticCell c) =>
        _derivedPairs.contains(c.pair) && c.stateCode != DiagnosticStates.ok,
  );
  return derivedOff ? '$first 파생 불일치는 주문을 막지 않습니다.' : first;
}

/// 5칸 보드(R59 S5 · S6) — 칸 순서 = `LedgerPair` 순서.
DiagnosticsVm diagnosticsOf({
  required OperatingMode mode,
  required BrokerReconSummary broker,
  required Map<LedgerPair, DerivedPairSummary> derived,
  required AsOf asOf,
}) {
  final List<DiagnosticCell> cells = <DiagnosticCell>[
    brokerCellOf(mode, broker),
    for (final LedgerPair p in <LedgerPair>[
      LedgerPair.canonSupabase,
      LedgerPair.canonGithub,
      LedgerPair.canonCalendar,
    ])
      derivedCellOf(
        p,
        derived[p] ?? const DerivedPairSummary(connected: false),
      ),
    selfReportCellOf(mode),
  ];
  return DiagnosticsVm(
    cells: cells,
    headline: diagnosticsHeadline(cells),
    asOf: asOf,
  );
}
