// C-46 X7 안내·수기 기록·실사 `A-1`~`A-4`·「지난 안내」·`L-3` — 01 §21 · §7 표 C-46(🆕 계약 v1.12 · R5 선행 설계서
// 2026-10-22 §6-1 · 발주자 확정 2026-10-22 — 🔴 K9·K14·K18·K36 권고대로).
//
// 정의: 「안내 화면은 엔진이 실어 준 버튼·링크·문장만 그리고, 기록 폼 셋은 사람이 친 원문을 제출 DTO 로 넘길 뿐이다 —
//   상태로 버튼을 고르지 않고 · 링크를 조립하지 않고 · 파싱·날짜 계산·맥락 위조를 하지 않는다」. C-44 꼴 — 픽스처
//   불변식(A) + 화면 소스 스캔(B)을 한 파일에 둔다.
//
// A. 픽스처·DTO 불변식(①~⑮) — 숫자 리터럴을 코드에 적지 않고 픽스처끼리 맞댄다.
//   ① 허용 키 · DTO 필드 집합 == 목록 · 손익 키 0   ② 링크 = 그 행 id(DETAIL 0)   ③ 뷰어 마스킹·양성 링크
//   ④ 만료 확인 카드(≤3 · 맨 앞 · [RECORD, SKIP] · 밖의 미분류 만료 = 인박스 0 · 요약 링크 ⇔ 넘침)   ⑤ 엔진 정렬
//   ⑥ 사유(예산 2종만 deep_link·requires_note · 네 벌 같음)   ⑦ 수량 채우기   ⑧ 재제출 선택지   ⑨ 거부 코드
//   ⑩ `L-3` 세션·결과   ⑪ 초안 키(그 달/그 계좌)   ⑫ `A-3` 선택지(거래일 = min~max − 휴장 · 테스트 쪽 산수)
//   ⑬ 배치 결측 = RECORD 만   ⑭ 닫힌 사유 짝   ⑮ `L-3` 링크 꼴(전 픽스처 walk).
//
// B. 화면 소스 스캔(⑯~㉗) — 대상 = `packages/ui_journal/lib/src/advice_inbox.dart` · `advice_history.dart` ·
//    `advice_detail.dart` · `lib/src/advice/**`(읽기 화면) · `lib/src/journal_draft/manual_fill_form.dart` ·
//    `advice_skip_form.dart` · `self_report_form.dart`(폼 3 — operator 라이브러리). 전처리 = `stripComments`(문자열 보간 안
//    코드까지 본다) · ⑲ 만 `stripCommentsAndStrings`. 대상 0(R5b 전) = ⑰~㉖ 공허 통과 + 대상 수 출력(C-44 ⑫ 선례).
//   🔵 설계서 ⑰ 의 읽기 화면 `.adviceId` 금지는 예외 2를 둔다 — `widget.adviceId`(`A-2` `findById`·`fillsOfAdvice` 인자)
//      · `deferAdviceConfirm(…adviceId)` 인자(K14 ⓐ). 표시·Key 에 쓰는 `.adviceId` 는 그대로 금지다(행 Key = 순번).
// 🔴 픽스처 값(수량·가격·날짜)을 이 파일에 적지 않는다 — 픽스처끼리 맞댄다. 자체 검증 스니펫의 값은 자리표시자다.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

// ─── A. 픽스처 ────────────────────────────────────────────────────────────────

/// 인박스 봉투(행 + `summary`) — `watchInbox`·`watchSummary` 의 표본.
const List<String> _inbox = <String>[
  FixturePaths.m6Advice12,
  FixturePaths.m6AdviceEmpty,
  FixturePaths.m6AdviceBlocked,
  FixturePaths.m6AdviceExpiredConfirm,
  FixturePaths.m6AdviceViewer4,
  FixturePaths.m6AdviceNoAction,
  FixturePaths.m6AdviceHandoverCooling,
  FixturePaths.m6AdviceStale,
];

/// `A-2` 상세(`findById`)의 표본.
const List<String> _details = <String>[
  FixturePaths.m6AdviceDetailPartial,
  FixturePaths.m6AdviceDetailOnhold,
];

const List<String> _adviceAll = <String>[..._inbox, ..._details];

/// `watchManualFillFormSpec` 의 표본 3벌.
const List<String> _specs = <String>[
  FixturePaths.m6FillFormSpec,
  FixturePaths.m6FillFormSpecStale,
  FixturePaths.m6FillFormSpecBlocked,
];

/// X7 접수증(N6·N7·N8·N9·R14).
const List<String> _x7Receipts = <String>[
  FixturePaths.m6SelfReportReceipts5,
  FixturePaths.m6ManualFillReceipts7,
  FixturePaths.m6AdviceSkipReceipts5,
  FixturePaths.m6AdviceDeferReceipts3,
  FixturePaths.m6FillRejectedPrice,
];

/// `L-3` 세션 표본(열린 · 결과 · 닫힘).
const List<String> _sessions = <String>[
  FixturePaths.m6SelfReport1,
  FixturePaths.m6SelfReportDiffResult,
  FixturePaths.m6SelfReportSessionClosed,
];

/// ⑥ 🔴 예산 코드 2종(집합 상수는 이 테스트 한 곳 — 정본 06:238 · 02 §3-9 표 · `SKIP_NOTE_REQUIRED` 주석).
const Set<String> _budgetCodes = <String>{
  'PRICE_UNACCEPTABLE',
  'INTENTIONAL_PAUSE',
};

const String _rFill = 'aaq://advice/fill/';
const String _rSkip = 'aaq://advice/skip/';
const String _rDetail = 'aaq://advice/detail/';
const String _rDecision = 'aaq://journal/decision/';
const String _rHistory = 'aaq://advice/history';
const String _rIntervention = 'aaq://m5/intervention';
const String _rSelfReport = 'aaq://ledger/self-report/';

/// ⑧ 재제출 선택지가 붙을 수 있는 (거부 코드, 재제출 코드) 짝(K20 · B5 · A9).
const Set<(String, String)> _retryPairs = <(String, String)>{
  ('PRICE_OUT_OF_RANGE', 'OFF_HOUR_TRADE'),
  ('DUPLICATE_SUSPECTED', 'DUPLICATE_ACK'),
};

/// ① 손익 키(C-6 `_pnlJsonKeys` 와 같은 목록).
const Set<String> _pnlKeys = <String>{
  'pnl',
  'unrealized_pnl',
  'realized_pnl',
  'pnl_pct',
  'return_pct',
};

/// ⑮ 링크를 싣는 JSON 키(C-33 `_linkKeys` 와 같은 목록).
const Set<String> _linkKeys = <String>{
  'deep_link',
  'detail_deep_link',
  'action_deep_link',
  'where_deep_link',
  'clear_deep_link',
  'route',
  'preview_route',
  'handoff_route',
  'resume_route',
  'goal_deep_link',
};

final RegExp _selfReportLink = RegExp(
  r'^aaq://ledger/self-report/(\d{4}-\d{2})/([^/?#]+)$',
);

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _rows(String path) =>
    (_env(path)['rows']! as List<Object?>).cast<Map<String, Object?>>();

Map<String, Object?>? _summary(String path) =>
    _env(path)['summary'] as Map<String, Object?>?;

List<Map<String, Object?>> _actions(Map<String, Object?> row) =>
    (row['actions']! as List<Object?>).cast<Map<String, Object?>>();

List<String> _actionIds(Map<String, Object?> row) => <String>[
  for (final Map<String, Object?> a in _actions(row)) a['action_id']! as String,
];

bool _isCard(Map<String, Object?> row) => row['expired_confirm_label'] != null;

Set<String> _accountAliases() => <String>{
  for (final Object? a
      in (_rows(FixturePaths.m6FillFormSpec).single['accounts']!
          as List<Object?>))
    (a! as Map<String, Object?>)['alias']! as String,
};

/// JSON 트리의 모든 객체(목록 원소 포함 — `walkJson` 은 목록 원소 객체 자체를 넘기지 않는다).
Iterable<Map<String, Object?>> _objects(Object? node) sync* {
  if (node is Map<String, Object?>) {
    yield node;
    for (final Object? v in node.values) {
      yield* _objects(v);
    }
  } else if (node is List<Object?>) {
    for (final Object? v in node) {
      yield* _objects(v);
    }
  }
}

/// 입금 정본(`deposit_plan_1`)의 종목 라벨(SPEC 대응표 · K23).
Map<String, String> _depositLabels() => <String, String>{
  for (final Map<String, Object?> o in _objects(
    _env(FixturePaths.depositPlan1),
  ))
    if (o['symbol'] is String && o['symbol_label'] is String)
      o['symbol']! as String: o['symbol_label']! as String,
};

bool _hasKey(Object? node, String key) {
  bool found = false;
  walkJson(node, (String path, String k, Object? value) {
    if (k == key) {
      found = true;
    }
  });
  return found;
}

// ─── B. 화면 소스 스캔 — 대상 ─────────────────────────────────────────────────

const String _journalPackage = 'packages/ui_journal';

/// 읽기 화면 3 + 내부 조각 폴더(배럴 쪽 · `/` 로 끝난다).
const List<String> _readFiles = <String>[
  'lib/src/advice_inbox.dart',
  'lib/src/advice_history.dart',
  'lib/src/advice_detail.dart',
];
const String _readDir = 'lib/src/advice/';

/// 폼 3(operator 라이브러리 `journal_draft/` 아래 · K10 ⓐ).
const List<String> _formFiles = <String>[
  'lib/src/journal_draft/manual_fill_form.dart',
  'lib/src/journal_draft/advice_skip_form.dart',
  'lib/src/journal_draft/self_report_form.dart',
];

bool _isRead(String rel) =>
    _readFiles.contains(rel) || rel.startsWith(_readDir);

bool _isForm(String rel) => _formFiles.contains(rel);

String? _journalRel(String repoRel) => repoRel.startsWith('$_journalPackage/')
    ? repoRel.substring(_journalPackage.length + 1)
    : null;

/// ⑯ X7 VM·창구·제출 이름.
final RegExp _x7Name = RegExp(
  r'\b(AdviceItem|AdviceInboxSummary|ManualFillFormSpec|SelfReportSession|'
  r'ManualFillSubmission|AdviceSkipSubmission|SelfReportSubmission|'
  r'watchSelfReportSession|deferAdviceConfirm)\b',
);

// ─── B. 정규식 ────────────────────────────────────────────────────────────────

/// ⑰ 공통(읽기 + 폼) — 원값·키. 🔴 `\b` 는 그룹 **밖**(`.statusLabel`·`.quantityText` 를 막지 않는다).
final RegExp _rawCommon = RegExp(
  r'\.(?:status|onHold|suppressed|actionId|quantity|recordedQuantity|quantityMax|'
  r'minTradeDate|maxTradeDate|nonTradingDates|low|high|reference|sleeve|wire|'
  r'closeReasonCode|asOfTradeDate|decision)\b',
);

/// ⑰ 읽기 화면만 — 종목·방향·코드·체결 종류 원값.
final RegExp _rawRead = RegExp(r'\.(?:symbol|side|code|fillKind)\b');

/// ⑰ 읽기 화면 `.adviceId` — 예외 2(`widget.adviceId` · `deferAdviceConfirm(…adviceId)`)는 [_scan] 이 거른다.
final RegExp _adviceIdAny = RegExp(r'\.adviceId\b');

/// ⑰ Key 에 `.adviceId`(행 Key = 순번 · v1.8 C-44 ⑮ 선례).
final RegExp _adviceIdKey = RegExp(r'Key\s*(<[^>]*>)?\s*\(\s*[^)]*\.adviceId');

/// ⑱ 분기 금지 — 상태·액션·사유·방향 열거 · `SelfReportPurpose` 는 `periodicAudit` 하나만(L-3 제출 DTO 고정값).
final RegExp _branch = RegExp(
  r'AdviceStatus\.|AdviceActionId\.|AdviceSkipReason\.|OrderSide\.|'
  r'SelfReportPurpose\.(?!periodicAudit\b)',
);

/// ⑲ 파싱·산술(`stripCommentsAndStrings` 뒤 — K4 · K37).
final RegExp _parse = RegExp(
  r'int\.parse|double\.parse|num\.parse|tryParse|\bDecimal\b|DateTime\.parse|'
  r'showDatePicker|\.toInt\(|\.round\(',
);

/// ⑳ 와이어·맥락(= C-28 ⑨ 의 실물).
final RegExp _wire = RegExp(
  r'\bCommandContext\b|\bManualFillRecord\(|\bAdviceSkip\(|\bSelfReportBalance\(|'
  r'\bAdviceDeferConfirm\(',
);

/// ㉑ 안전 상태 직접·조인(배너 = `journalSafetyStateProvider` + 공용 `JournalSafetyBanners` — 대상 밖 · 열려 있다).
final RegExp _safetyDirect = RegExp(
  r'\.watchState\(|activeFlags|FlagIds|markerOnly|\.killSwitch|releaseProgress|'
  r'stoppedReleaseEligible|watchDecisionDetail|JournalRepository|HoldingsRepository',
);

/// ㉒ 링크 조립 — 라우트 상수(예외 = `A-1` 하단 «지난 안내» · 규칙 ④ · K38) · `aaq://` 리터럴.
final RegExp _routeConst = RegExp(r'AppRoutes\.(?!adviceHistory\b)');
final RegExp _linkLiteral = RegExp(r'aaq://');

/// ㉓ 초안 지우기 — 앞 300자 안에 `CommandState.executed` 가 있어야 한다.
final RegExp _clearCall = RegExp(r'\.clear\(');
const int _clearWindow = 300;

/// ㉔ `dispose` 의 `ref`.
final RegExp _disposeBody = RegExp(
  r'void\s+dispose\s*\(\s*\)(.*?)super\.dispose\(\)',
  dotAll: true,
);
final RegExp _refUse = RegExp(r'\bref\.');

/// ㉕ 묶기·고르기(읽기 화면).
final RegExp _reshape = RegExp(
  r'groupBy|\.fold\(|\.reduce\(|\.where\(|\.sort\(',
);

/// ㉖ 명령 범위(읽기 화면) — 부르는 명령은 `deferAdviceConfirm` 하나(K14 ⓐ).
final RegExp _readCommands = RegExp(
  r'recordManualFill|skipAdvice|submitSelfReportBalance|amendManualFill|'
  r'voidManualFill|recordLedgerEvent',
);

class _Hit {
  const _Hit(this.clause, this.text);
  final String clause;
  final String text;

  @override
  String toString() => '$clause «$text»';
}

/// 대상 한 벌의 위반 — [read] = 읽기 화면(true) / 폼(false).
List<_Hit> _scan(String source, {required bool read}) {
  final String code = stripComments(source);
  final String bare = stripCommentsAndStrings(source);
  final List<_Hit> out = <_Hit>[
    for (final RegExpMatch m in _rawCommon.allMatches(code))
      _Hit('⑰', m.group(0)!),
    for (final RegExpMatch m in _branch.allMatches(code))
      _Hit('⑱', m.group(0)!),
    for (final RegExpMatch m in _parse.allMatches(bare)) _Hit('⑲', m.group(0)!),
    for (final RegExpMatch m in _wire.allMatches(code)) _Hit('⑳', m.group(0)!),
    for (final RegExpMatch m in _safetyDirect.allMatches(code))
      _Hit('㉑', m.group(0)!),
    for (final RegExpMatch m in _routeConst.allMatches(code))
      _Hit('㉒', m.group(0)!),
    for (final RegExpMatch m in _linkLiteral.allMatches(code))
      _Hit('㉒', m.group(0)!),
  ];
  for (final RegExpMatch m in _clearCall.allMatches(code)) {
    final int from = m.start - _clearWindow < 0 ? 0 : m.start - _clearWindow;
    if (!code.substring(from, m.start).contains('CommandState.executed')) {
      out.add(_Hit('㉓', m.group(0)!));
    }
  }
  for (final RegExpMatch m in _disposeBody.allMatches(code)) {
    if (_refUse.hasMatch(m.group(1)!)) {
      out.add(const _Hit('㉔', 'dispose 안 ref.'));
    }
  }
  if (read) {
    for (final RegExpMatch m in _rawRead.allMatches(code)) {
      out.add(_Hit('⑰', m.group(0)!));
    }
    for (final RegExpMatch m in _adviceIdAny.allMatches(code)) {
      final int from = m.start - 40 < 0 ? 0 : m.start - 40;
      final String before = code.substring(from, m.start);
      final bool widgetArg = before.endsWith('widget');
      final bool deferArg = RegExp(r'deferAdviceConfirm\(\s*[\w.]*$')
          .hasMatch(before);
      if (!widgetArg && !deferArg) {
        out.add(_Hit('⑰', m.group(0)!));
      }
    }
    for (final RegExpMatch m in _adviceIdKey.allMatches(code)) {
      out.add(_Hit('⑰', m.group(0)!));
    }
    for (final RegExpMatch m in _reshape.allMatches(code)) {
      out.add(_Hit('㉕', m.group(0)!));
    }
    for (final RegExpMatch m in _readCommands.allMatches(code)) {
      out.add(_Hit('㉖', m.group(0)!));
    }
  }
  return out;
}

// ─── B. 실대상 ────────────────────────────────────────────────────────────────

/// ⑯ 가드 대상 — `packages/ui_*/lib`(🔴 셸 제외 — 홈 블록 3b·9b 자리 · 저장소 기준 경로 → 원문).
final Map<String, String> _guardSources = <String, String>{
  for (final String p in uiPackageNames)
    if (p != 'ui_shell')
      for (final File f in dartSourcesIn(
        Directory('${repoRoot.path}/packages/$p/lib'),
      ))
        shortPath(f): f.readAsStringSync(),
};

bool _isTarget(String repoRel) {
  final String? rel = _journalRel(repoRel);
  return rel != null && (_isRead(rel) || _isForm(rel));
}

/// 대상 파일(저장소 기준 경로 → 원문). 없으면 빈 지도(공허 통과).
final Map<String, String> _targets = <String, String>{
  for (final MapEntry<String, String> e in _guardSources.entries)
    if (_isTarget(e.key)) e.key: e.value,
};

List<String> _violations(String clause) => <String>[
  for (final MapEntry<String, String> f in _targets.entries)
    for (final _Hit h in _scan(f.value, read: _isRead(_journalRel(f.key)!)))
      if (h.clause == clause) '${f.key}: $h',
];

void _say(String line) {
  // ignore: avoid_print
  print(line);
}

// ─── B. ㉗ 자체 검증 스니펫 ───────────────────────────────────────────────────

/// 양성 — (스니펫, 읽기 화면인가, 반드시 걸려야 하는 조항).
const List<(String, bool, String)> _positives = <(String, bool, String)>[
  ('if (a.effectiveStatus == AdviceStatus.expired) {}', true, '⑱'),
  ('final int n = int.parse(q);', false, '⑲'),
  ('final DateTime d = DateTime.parse(s);', false, '⑲'),
  ('final x = ManualFillRecord(', false, '⑳'),
  ('opener.open(AppRoutes.adviceFill);', true, '㉒'),
  ('if (a.actionId == AdviceActionId.record) {}', true, '⑰'),
  ('if (a.actionId == AdviceActionId.record) {}', true, '⑱'),
  ('final s = _input.copyWith(side: OrderSide.buy);', false, '⑱'),
  ('if (safety.activeFlags.isNotEmpty) {}', false, '㉑'),
  ('Text(a.quantity.toString())', true, '⑰'),
  ('if (a.status == x) {}', true, '⑰'),
  ('void dispose() { ref.read(p); super.dispose(); }', false, '㉔'),
  ('onTap: () { store.clear(key); }', false, '㉓'),
  ('rows.where((e) => e.fillKind == k)', true, '㉕'),
  ('rows.where((e) => e.fillKind == k)', true, '⑰'),
  ('api.recordManualFill(s);', true, '㉖'),
  ("opener.open('aaq://advice/fill/x');", true, '㉒'),
  ('Text(item.closeReasonCode!)', true, '⑰'),
  ('Text(item.adviceId)', true, '⑰'),
  ("ValueKey('a1-row-' + item.adviceId)", true, '⑰'),
  ('final c = CommandContext(', false, '⑳'),
  ('final int q = v.toInt();', false, '⑲'),
  ('showDatePicker(context: c);', false, '⑲'),
  ('ref.watch(x).watchState();', true, '㉑'),
  ('if (f == FlagIds.ledgerIntegrity) {}', false, '㉑'),
  ('purpose: SelfReportPurpose.simOpening,', false, '⑱'),
  ('Text(item.symbol!)', true, '⑰'),
  ('Text(spec.quantityMax.toString())', false, '⑰'),
  ('Text(item.decision.decisionId)', true, '⑰'),
  ('ref.watch(p).watchDecisionDetail(id);', true, '㉑'),
  ('final x = Decimal.parse(t);', false, '⑲'),
];

/// 음성 — (스니펫, 읽기 화면인가). 어느 조항에도 걸리지 않아야 한다.
const List<(String, bool)> _negatives = <(String, bool)>[
  ('opener.open(action.deepLink);', true),
  ('opener.open(item.detailDeepLink);', true),
  ('Text(item.statusLabel)', true),
  ('final t = item.statusTone;', true),
  ('if (item.suppressedLabel case final String l?) { Text(l); }', true),
  ('Text(s.asOfTradeDateText)', false),
  ('_qty.text = r.quantityText;', false),
  ('if (item.expiredConfirmLabel case final String l?) { Text(l); }', true),
  ('if (item.deferAvailable) {}', true),
  ('api.deferAdviceConfirm(item.adviceId);', true),
  ('repo.findById(widget.adviceId);', true),
  ('repo.fillsOfAdvice(widget.adviceId);', true),
  (
    'final s = ManualFillSubmission(adviceId: widget.adviceId, input: _input);',
    false,
  ),
  ('_input = _input.copyWith(side: o.side);', false),
  ('_input = _input.copyWith(tradeDate: o.date);', false),
  ('opener.open(AppNavActions.back);', false),
  ('opener.open(AppRoutes.adviceHistory);', true),
  (
    'if (r.state == CommandState.executed && !_cleared) { _cleared = true; s.clear(_key); }',
    false,
  ),
  (
    'final s = SelfReportSubmission(purpose: SelfReportPurpose.periodicAudit, yyyyMm: widget.yyyyMm, '
        'input: _input, declaredComplete: _declared);',
    false,
  ),
  (
    'void initState() { super.initState(); _actions = ref.read(journalSettingsActionsProvider); } '
        'void dispose() { unawaited(_actions.run(SettingsActionId.selfReportSessionStop, args: a)'
        '.then((_) {}, onError: (Object _, StackTrace __) {})); super.dispose(); }',
    false,
  ),
  ('JournalSafetyBanners(safety: s)', true),
  ('final s = ref.watch(journalSafetyStateProvider);', true),
  ('final AdviceSkipInput i = AdviceSkipInput.fromReasonCode(o.code);', false),
  ("ValueKey('a1-row-\$i')", true),
  ('for (final (i, a) in item.actions.indexed) {}', true),
  ('Text(item.symbolLabel ?? item.phoneOnlyLabel ?? \'\')', true),
  (
    'if (item.decisionLink case final LinkAction l?) { opener.open(l.deepLink); }',
    true,
  ),
  ('Text(item.sideLabel ?? \'\')', true),
  ('Text(r.retryLabel!)', false),
  ('_retry = <String>[..._retry, r.retryCode!];', false),
];

void main() {
  group('C-46 X7 안내·기록·실사 (01 §21 · 계약 v1.12)', () {
    // ═══ A. 픽스처 불변식 ═══════════════════════════════════════════════════

    test('C-46 ① 허용 키 · DTO 필드 집합 == 목록 · 손익 키 0', () {
      const Set<String> actionKeys = <String>{
        'action_id',
        'label',
        'enabled',
        'disabled_reason_label',
        'deep_link',
      };
      const Set<String> sessionKeys = <String>{
        'title_text',
        'notice_text',
        'as_of_trade_date_text',
        'symbols',
        'account_label',
        'cash_hint_label',
        'declare_complete_label',
        'session_closed_text',
        'blocked_text',
        'result',
        'trust',
        'as_of',
      };
      const Set<String> resultKeys = <String>{
        'diffs',
        'empty_label',
        'resolve_link',
        'next_account_link',
      };
      const Set<String> summaryNew = <String>{
        'cash_notice',
        'overdue_unrecorded_link',
        'manual_entry_link',
        'manual_entry_notice_text',
      };
      const Set<String> specNew = <String>{
        'sides',
        'trade_date_options',
        'skip_notice_text',
        'blocked_text',
        'banner_text',
      };
      // DTO 필드 집합 == 목록(필드를 더하면 01 §21 이 먼저 바뀐다).
      final Map<String, Object?> sampleAction = _actions(
        _rows(FixturePaths.m6Advice12).first,
      ).first;
      expect(
        AdviceAction.fromJson(sampleAction).toJson().keys.toSet(),
        actionKeys,
      );
      final Map<String, Object?> session = _rows(
        FixturePaths.m6SelfReportDiffResult,
      ).single;
      expect(
        SelfReportSession.fromJson(session).toJson().keys.toSet(),
        sessionKeys,
      );
      expect(
        SelfReportResult.fromJson(session['result']! as Map<String, Object?>)
            .toJson()
            .keys
            .toSet(),
        resultKeys,
      );
      expect(
        AdviceInboxSummary.fromJson(_summary(FixturePaths.m6Advice12)!)
            .toJson()
            .keys
            .toSet(),
        containsAll(summaryNew),
      );
      final Map<String, Object?> spec = _rows(FixturePaths.m6FillFormSpec)
          .single;
      expect(
        ManualFillFormSpec.fromJson(spec).toJson().keys.toSet(),
        containsAll(specNew),
      );
      expect(
        SideOption.fromJson(
          (spec['sides']! as List<Object?>).first! as Map<String, Object?>,
        ).toJson().keys.toSet(),
        <String>{'side', 'label'},
      );
      expect(
        TradeDateOption.fromJson(
          (spec['trade_date_options']! as List<Object?>).first!
              as Map<String, Object?>,
        ).toJson().keys.toSet(),
        <String>{'date', 'label'},
      );
      // 픽스처 키 ⊆ 목록.
      for (final String path in _adviceAll) {
        for (final Map<String, Object?> row in _rows(path)) {
          for (final Map<String, Object?> a in _actions(row)) {
            expect(actionKeys.containsAll(a.keys), isTrue, reason: '$path $a');
          }
        }
      }
      for (final String path in _sessions) {
        final Map<String, Object?> row = _rows(path).single;
        expect(sessionKeys.containsAll(row.keys), isTrue, reason: path);
        if (row['result'] case final Map<String, Object?> r) {
          expect(resultKeys.containsAll(r.keys), isTrue, reason: path);
        }
      }
      for (final String path in _specs) {
        final Set<String> allowed = ManualFillFormSpec.fromJson(
          _rows(path).single,
        ).toJson().keys.toSet();
        expect(allowed.containsAll(_rows(path).single.keys), isTrue);
      }
      // 손익 키 0.
      final List<String> pnl = <String>[];
      for (final String path in <String>[
        ..._adviceAll,
        ..._specs,
        ..._sessions,
        ..._x7Receipts,
        FixturePaths.m6AdviceFillsAd0005,
      ]) {
        walkJson(_env(path), (String jsonPath, String key, Object? value) {
          if (_pnlKeys.contains(key)) {
            pnl.add('$path $jsonPath');
          }
        });
      }
      expect(pnl, isEmpty, reason: 'X7 안내·폼·실사 표본에 손익 키가 없다(결정 8).');
    });

    test('C-46 ② 링크 = 그 행 id · DETAIL 액션 0 · 결정 링크 = 그 결정', () {
      int checked = 0;
      for (final String path in _adviceAll) {
        for (final Map<String, Object?> row in _rows(path)) {
          final String id = row['advice_id']! as String;
          expect(row['detail_deep_link'], '$_rDetail$id', reason: '$path $id');
          checked++;
          for (final Map<String, Object?> a in _actions(row)) {
            final String actionId = a['action_id']! as String;
            expect(
              <String>{'RECORD', 'SKIP'},
              contains(actionId),
              reason:
                  '$path $id — 액션은 RECORD·SKIP 만(K5 · 상세 = detail_deep_link · 자기 자신으로 가는 버튼 0).',
            );
            expect(
              a['deep_link'],
              '${actionId == 'RECORD' ? _rFill : _rSkip}$id',
              reason: '$path $id $actionId',
            );
            checked++;
          }
          if (row['decision_link'] case final Map<String, Object?> link) {
            final Map<String, Object?> decision =
                row['decision']! as Map<String, Object?>;
            expect(
              link['deep_link'],
              '$_rDecision${decision['decision_id']}',
              reason: '$path $id',
            );
            checked++;
          }
        }
      }
      expect(checked, greaterThan(0), reason: '검사한 링크가 없다(공허 통과).');
    });

    test('C-46 ③ 뷰어 — actions [] · 집행 정보 0 · 스냅샷·상세 링크는 있다', () {
      final List<Map<String, Object?>> rows = _rows(
        FixturePaths.m6AdviceViewer4,
      );
      expect(rows, isNotEmpty);
      for (final Map<String, Object?> row in rows) {
        final String id = row['advice_id']! as String;
        expect(
          row['actions'],
          isEmpty,
          reason: '$id — 뷰어 actions = 빈 목록(K6 · 부재).',
        );
        expect(row['defer_available'], isFalse, reason: id);
        for (final String k in <String>[
          'side_label',
          'prefill_quantity_text',
          'prefill_quantity_label',
          'expired_confirm_label',
        ]) {
          expect(row[k], isNull, reason: '$id $k — 뷰어는 집행 정보가 오지 않는다(A6).');
        }
        expect(row['decision_link'], isNotNull, reason: '$id — 뷰어 스냅샷(K6 양성).');
        expect(row['detail_deep_link'], isNotNull, reason: id);
      }
      final Map<String, Object?> s = _summary(FixturePaths.m6AdviceViewer4)!;
      expect(s['manual_entry_link'], isNull);
      expect(s['manual_entry_notice_text'], isNull);
    });

    test('C-46 ④ 만료 확인 카드 — ≤3 · 맨 앞 · [RECORD, SKIP] · 밖의 미분류 만료 = 인박스 0', () {
      int cardsSeen = 0;
      for (final String path in _adviceAll) {
        final List<Map<String, Object?>> rows = _rows(path);
        final List<int> cards = <int>[
          for (int i = 0; i < rows.length; i++)
            if (_isCard(rows[i])) i,
        ];
        expect(cards.length, lessThanOrEqualTo(3), reason: path);
        expect(
          cards,
          List<int>.generate(cards.length, (int i) => i),
          reason: '$path — 확인 카드는 목록 맨 앞에 잇달아 온다(엔진 · C16).',
        );
        cardsSeen += cards.length;
        for (final Map<String, Object?> row in rows) {
          final String id = row['advice_id']! as String;
          if (_isCard(row)) {
            expect(row['effective_status'], 'EXPIRED', reason: '$path $id');
            expect(_actionIds(row), <String>[
              'RECORD',
              'SKIP',
            ], reason: '$path $id — 확인 카드 버튼 = [RECORD, SKIP](순서까지 · K13).');
          }
          if (row['defer_available'] == true) {
            expect(
              _isCard(row),
              isTrue,
              reason: '$path $id — 「내일 다시」는 확인 카드에만.',
            );
          }
          if (_inbox.contains(path) && row['effective_status'] == 'EXPIRED') {
            expect(
              _isCard(row),
              isTrue,
              reason: '$path $id — 확인 카드 밖 미분류 만료는 인박스 행에 오지 않는다(K13).',
            );
          }
        }
        if (_inbox.contains(path)) {
          final Map<String, Object?> s = _summary(path)!;
          final int overdue = s['overdue_unrecorded_count']! as int;
          final Object? link = s['overdue_unrecorded_link'];
          expect(
            link != null,
            overdue > cards.length,
            reason: '$path — «미확인 만료 n건» 링크 ⇔ 확인 카드로 다 못 보인 만료가 있다.',
          );
          if (link case final Map<String, Object?> l) {
            expect(l['deep_link'], _rHistory, reason: path);
            expect(l['label'], isA<String>());
          }
        }
      }
      expect(cardsSeen, greaterThan(0));
      final List<Map<String, Object?>> expired = _rows(
        FixturePaths.m6AdviceExpiredConfirm,
      );
      expect(
        expired.where(_isCard),
        hasLength(3),
        reason: '갈래 공허 방지 — 확인 카드 3장 표본.',
      );
      expect(
        _summary(
          FixturePaths.m6AdviceExpiredConfirm,
        )!['overdue_unrecorded_link'],
        isNotNull,
      );
    });

    test('C-46 ⑤ 정렬 = 엔진 — 확인 카드 → is_urgent → 나머지', () {
      int rank(Map<String, Object?> r) =>
          _isCard(r) ? 0 : (r['is_urgent'] == true ? 1 : 2);
      for (final String path in _inbox) {
        final List<int> ranks = _rows(path).map(rank).toList();
        for (int i = 1; i < ranks.length; i++) {
          expect(
            ranks[i],
            greaterThanOrEqualTo(ranks[i - 1]),
            reason: '$path rows[$i] — 화면은 받은 순서 그대로 그린다(K13 · 정렬 = 엔진).',
          );
        }
      }
      expect(_rows(FixturePaths.m6Advice12).map(rank).toSet(), <int>{
        0,
        1,
        2,
      }, reason: '세 갈래가 다 있는 표본(공허 방지).');
    });

    test('C-46 ⑥ 사유 — 예산 2종만 deep_link·requires_note · 네 벌 같음 · 제출 전 문구', () {
      final List<List<Map<String, Object?>>> lists =
          <List<Map<String, Object?>>>[
            _rows(FixturePaths.m6AdviceSkipReasons),
            for (final String path in _specs)
              (_rows(path).single['skip_reasons']! as List<Object?>)
                  .cast<Map<String, Object?>>(),
          ];
      for (final List<Map<String, Object?>> lst in lists) {
        expect(
          jsonEncode(lst),
          jsonEncode(lists.first),
          reason: '사유 목록이 두 벌이 되면 한쪽만 갱신된다(H-5).',
        );
        for (final Map<String, Object?> r in lst) {
          final String code = r['code']! as String;
          final Object? link = r['deep_link'];
          expect(link != null, _budgetCodes.contains(code), reason: code);
          expect(
            r['requires_note'],
            link != null,
            reason: '$code — 정본 = 02 §3-9 표(K22).',
          );
          if (link != null) {
            expect(link, _rIntervention, reason: code);
          }
        }
      }
      expect(
        lists.first.where((Map<String, Object?> r) => r['deep_link'] != null),
        hasLength(_budgetCodes.length),
      );
      for (final String path in _specs) {
        expect(
          _rows(path).single['skip_notice_text'],
          isNotEmpty,
          reason: path,
        );
      }
    });

    test('C-46 ⑦ 수량 채우기 — 짝 · 열린 안내 · 원문 = 그 행 quantity', () {
      int seen = 0;
      for (final String path in _adviceAll) {
        for (final Map<String, Object?> row in _rows(path)) {
          final String id = row['advice_id']! as String;
          final Object? text = row['prefill_quantity_text'];
          expect(
            text != null,
            row['prefill_quantity_label'] != null,
            reason: '$path $id',
          );
          if (text is String) {
            seen++;
            expect(
              <String>{'OPEN', 'PARTIAL'},
              contains(row['effective_status']),
              reason: '$path $id',
            );
            expect(text, matches(RegExp(r'^\d+$')), reason: '$path $id');
            expect(
              text,
              '${row['quantity']}',
              reason: '$path $id — 픽스처끼리(안내 수량 그대로).',
            );
          }
        }
      }
      expect(seen, greaterThan(0));
    });

    test('C-46 ⑧ 재제출 선택지 — 거부 행만 · 짝 글자 · 허용된 짝', () {
      int seen = 0;
      for (final String path in FixturePaths.all) {
        for (final Map<String, Object?> o in _objects(_env(path))) {
          if (o.containsKey('retry_label')) {
            expect(
              o['retry_code'],
              isNotNull,
              reason: '$path — 짝 글자만 홀로 오지 않는다.',
            );
          }
          if (!o.containsKey('retry_code')) {
            continue;
          }
          seen++;
          final Object? retry = o['retry_code'];
          expect(retry, isA<String>(), reason: path);
          expect(o['state'], 'REJECTED', reason: path);
          expect(o['retry_label'], isNotEmpty, reason: path);
          expect(AdviceRetryCodes.values, contains(retry), reason: path);
          expect(
            _retryPairs,
            contains((o['reject_reason_code'], retry)),
            reason: '$path — 엉뚱한 완화(K20).',
          );
        }
      }
      expect(seen, greaterThanOrEqualTo(2), reason: 'B5·A9 두 짝 표본.');
    });

    test('C-46 ⑨ 거부 코드 — X7 사전 18 · 사실 추가에 LEASE_EXPIRED 0 · 「내일 다시」 = DEFER_ALREADY_USED', () {
      final Set<String> seen = <String>{};
      for (final String path in _x7Receipts) {
        for (final Map<String, Object?> r in _rows(path)) {
          final Object? code = r['reject_reason_code'];
          if (code is! String) {
            continue;
          }
          seen.add(code);
          expect(AdviceRejectCodes.values, contains(code), reason: path);
          if (r['kind'] == 'RECORD_MANUAL_FILL') {
            expect(
              code,
              isNot(AdviceRejectCodes.leaseExpired),
              reason: '$path — B19 사실 추가는 강등 접수.',
            );
          }
          if (r['kind'] == 'DEFER_ADVICE_CONFIRM') {
            expect(code, AdviceRejectCodes.deferAlreadyUsed, reason: path);
          }
        }
      }
      expect(
        seen,
        containsAll(<String>[
          AdviceRejectCodes.inputInvalid,
          AdviceRejectCodes.selfReportOutsideSession,
          AdviceRejectCodes.deferAlreadyUsed,
        ]),
        reason: 'v1.12 새 거부 코드 3종의 표본.',
      );
      expect(AdviceRejectCodes.values, hasLength(18));
    });

    test('C-46 ⑩ L-3 — 유니버스 라벨 · 닫힘 ⇒ 결과 0 · 결과 = 자가보고 쌍 · 원장 수량 키 0', () {
      final Map<String, String> labels = _depositLabels();
      bool closed = false;
      bool result = false;
      for (final String path in _sessions) {
        final Map<String, Object?> row = _rows(path).single;
        final List<Map<String, Object?>> symbols =
            (row['symbols']! as List<Object?>).cast<Map<String, Object?>>();
        expect(symbols, isNotEmpty, reason: path);
        for (final Map<String, Object?> s in symbols) {
          expect(
            s['label'],
            labels[s['symbol']],
            reason: '$path — SPEC 대응표(K23 · 입금 정본).',
          );
        }
        expect(
          _hasKey(row, 'quantity'),
          isFalse,
          reason: '$path — 원장 값 프리필 금지(앵커링 · 02 §3-10).',
        );
        if (row['session_closed_text'] != null) {
          closed = true;
          expect(row['result'], isNull, reason: path);
        }
        if (row['result'] case final Map<String, Object?> r) {
          result = true;
          final List<Map<String, Object?>> diffs =
              (r['diffs']! as List<Object?>).cast<Map<String, Object?>>();
          expect(diffs.isEmpty, r['empty_label'] != null, reason: path);
          for (final Map<String, Object?> d in diffs) {
            expect(d['pair'], 'CANON_SELF_REPORT', reason: path);
            expect(
              d['action_link'],
              isNull,
              reason: '$path — 결과 안에서 자기 자신으로 가는 고리 0.',
            );
          }
        }
      }
      expect(closed && result, isTrue, reason: '닫힘·결과 갈래 표본.');
    });

    test('C-46 ⑪ 초안 키 — L-3 = <yyyy-MM>/<별칭> · 안내 폼 = 안내 id', () {
      final Set<String> aliases = _accountAliases();
      final Set<String> sessionSymbols = <String>{
        for (final Object? s
            in (_rows(FixturePaths.m6SelfReport1).single['symbols']!
                as List<Object?>))
          (s! as Map<String, Object?>)['symbol']! as String,
      };
      final Set<String> adviceIds = <String>{
        for (final Map<String, Object?> r in _rows(FixturePaths.m6Advice12))
          r['advice_id']! as String,
      };
      int selfReport = 0;
      for (final DraftRecord d in _rows(
        FixturePaths.m6DraftRecordsX7,
      ).map(DraftRecord.fromJson)) {
        switch (d.key.kind) {
          case DraftKind.selfReportBalance:
            selfReport++;
            final RegExpMatch? m = RegExp(r'^\d{4}-\d{2}/([^/?#]+)$')
                .firstMatch(d.key.targetId);
            expect(
              m,
              isNotNull,
              reason: '${d.key.targetId} — 그 달 + 그 계좌(K7 · K36 ⓐ).',
            );
            expect(aliases, contains(m!.group(1)));
            for (final SelfReportLineInput l in d.selfReport!.lines) {
              expect(sessionSymbols, contains(l.symbol), reason: l.symbol);
            }
          case DraftKind.manualFillRecord:
          case DraftKind.adviceSkip:
            expect(adviceIds, contains(d.key.targetId), reason: d.key.targetId);
          case DraftKind.journalDraft:
            fail('X7 초안 픽스처에 J-3 행이 있다.');
        }
      }
      expect(selfReport, greaterThan(0));
    });

    test(
      'C-46 ⑫ A-3 선택지 — 거래일 = min~max − 휴장(순서까지) · 방향 ⊆ OrderSide · 세 벌 같음',
      () {
        final Set<String> sides = <String>{
          for (final OrderSide s in OrderSide.values) s.wire,
        };
        Map<String, Object?>? first;
        for (final String path in _specs) {
          final Map<String, Object?> spec = _rows(path).single;
          final DateTime lo = DateTime.parse(
            '${spec['min_trade_date']}T00:00:00Z',
          );
          final DateTime hi = DateTime.parse(
            '${spec['max_trade_date']}T00:00:00Z',
          );
          final Set<Object?> closed =
              (spec['non_trading_dates']! as List<Object?>).toSet();
          final List<String> want = <String>[];
          for (
            DateTime d = lo;
            !d.isAfter(hi);
            d = d.add(const Duration(days: 1))
          ) {
            final String iso = d.toIso8601String().substring(0, 10);
            if (!closed.contains(iso)) {
              want.add(iso);
            }
          }
          final List<Object?> got = <Object?>[
            for (final Object? o
                in spec['trade_date_options']! as List<Object?>)
              (o! as Map<String, Object?>)['date'],
          ];
          expect(got, want, reason: '$path — 화면이 날짜를 만들지 않게 엔진이 고른 목록(K37).');
          for (final Object? s in spec['sides']! as List<Object?>) {
            expect(
              sides,
              contains((s! as Map<String, Object?>)['side']),
              reason: path,
            );
          }
          final Map<String, Object?> shared = <String, Object?>{
            'sides': spec['sides'],
            'skip_reasons': spec['skip_reasons'],
            'skip_notice_text': spec['skip_notice_text'],
          };
          first ??= shared;
          expect(jsonEncode(shared), jsonEncode(first), reason: path);
        }
      },
    );

    test('C-46 ⑬ 배치 결측 — staleLabel ⇒ 전 행 RECORD 만', () {
      int seen = 0;
      for (final String path in _inbox) {
        if (_summary(path)?['stale_label'] == null) {
          continue;
        }
        seen++;
        for (final Map<String, Object?> row in _rows(path)) {
          expect(
            <String>{'RECORD'}.containsAll(_actionIds(row)),
            isTrue,
            reason:
                '$path ${row['advice_id']} — 엔진이 줄여 보낸다(K41 · 화면이 지우지 않는다).',
          );
        }
      }
      expect(seen, greaterThan(0), reason: 'advice_stale 표본.');
    });

    test('C-46 ⑭ 닫힌 사유 — close_reason_label ⇔ close_reason_code', () {
      int seen = 0;
      for (final String path in _adviceAll) {
        for (final Map<String, Object?> row in _rows(path)) {
          final bool hasCode = row['close_reason_code'] != null;
          expect(
            row['close_reason_label'] != null,
            hasCode,
            reason: '$path ${row['advice_id']}',
          );
          if (hasCode) {
            seen++;
          }
        }
      }
      expect(seen, greaterThan(0));
    });

    test('C-46 ⑮ L-3 링크 꼴 — 전 픽스처 /<yyyy-MM>/<별칭>', () {
      final Set<String> aliases = _accountAliases();
      int seen = 0;
      for (final String path in FixturePaths.all) {
        walkJson(_env(path), (String jsonPath, String key, Object? value) {
          if (!_linkKeys.contains(key) ||
              value is! String ||
              !value.startsWith('aaq://ledger/self-report')) {
            return;
          }
          seen++;
          final RegExpMatch? m = _selfReportLink.firstMatch(value);
          expect(
            m,
            isNotNull,
            reason: '$path $jsonPath = $value — 그 달·그 계좌가 빠진 링크.',
          );
          expect(aliases, contains(m!.group(2)), reason: '$path $jsonPath');
          expect(value, startsWith(_rSelfReport));
        });
      }
      expect(seen, greaterThanOrEqualTo(7), reason: '옛 꼴 7곳 + 새 표본(공허 방지).');
    });

    // ═══ B. 화면 소스 스캔 ═══════════════════════════════════════════════════

    test('C-46 ⑯ 대상 수 · 가드 — X7 VM·창구·제출 이름은 대상 파일에만', () {
      expect(
        _guardSources.keys.where(
          (String p) => p.startsWith('$_journalPackage/lib/'),
        ),
        isNotEmpty,
        reason: 'ui_journal/lib 를 못 읽었다 — 경로가 낡았다.',
      );
      expect(
        _guardSources.keys.where(
          (String p) => p.startsWith('packages/ui_shell/'),
        ),
        isEmpty,
        reason: '셸(ui_shell)은 홈 블록 3b·9b 자리라 가드에서 뺀다.',
      );
      final List<String> files = _targets.keys.toList()..sort();
      _say(
        'C-46 ⑯ 대상 ${files.length}파일 — 읽기 {${_readFiles.join(', ')}} + $_readDir** · 폼 {${_formFiles.join(', ')}}'
        '${files.isEmpty ? ' — ⑰~㉖ 공허 통과' : '\n    ${files.join('\n    ')}'}',
      );
      final List<String> bad = <String>[
        for (final MapEntry<String, String> e in _guardSources.entries)
          if (!_isTarget(e.key) && _x7Name.hasMatch(stripComments(e.value)))
            e.key,
      ];
      expect(
        bad,
        isEmpty,
        reason:
            'X7 VM·창구·제출 이름을 말하는 `ui_*/lib` 파일은 대상에만 둔다 — 밖에 두면 ⑰~㉖ 가 보지 않는다'
            '(🔵 `J-1` 배지 카드가 오면 그 파일을 대상에 더하는 것이 그 카드의 M2 몫).\n${bad.join('\n')}',
      );
    });

    test('C-46 ⑰ 원값·키 0 — 상태·수량·가격·슬리브·코드 · 읽기 화면 종목·방향·id·체결 종류', () {
      final List<String> bad = _violations('⑰');
      expect(
        bad,
        isEmpty,
        reason: '그리는 것은 `*Label`·`*Text`·칩·링크뿐이다(C-18 (d)).\n${bad.join('\n')}',
      );
    });

    test('C-46 ⑱ 분기 금지 — 상태·액션·사유·방향 열거', () {
      final List<String> bad = _violations('⑱');
      expect(
        bad,
        isEmpty,
        reason: '버튼 = actions · 선택 = 선택지 값 그대로(K5 · K37).\n${bad.join('\n')}',
      );
    });

    test('C-46 ⑲ 파싱·산술 0 — 화면 검증·날짜 변환 금지(K4 · K37)', () {
      final List<String> bad = _violations('⑲');
      expect(
        bad,
        isEmpty,
        reason: '원문 그대로 제출 DTO 에 싣는다 — 파싱은 구현.\n${bad.join('\n')}',
      );
    });

    test('C-46 ⑳ 와이어·맥락 0 — C-28 ⑨ 의 실물', () {
      final List<String> bad = _violations('⑳');
      expect(
        bad,
        isEmpty,
        reason: '화면은 제출 DTO 만 만든다(G-19 · K4).\n${bad.join('\n')}',
      );
    });

    test('C-46 ㉑ 안전 상태 직접·조인 0', () {
      final List<String> bad = _violations('㉑');
      expect(
        bad,
        isEmpty,
        reason:
            '배너 = `journalSafetyStateProvider` + `JournalSafetyBanners` · 제출 차단 = `blockedText`(K21) · '
            '`A-2` 스냅샷 = `decisionLink`(K18).\n${bad.join('\n')}',
      );
    });

    test('C-46 ㉒ 링크 조립 0 — 라우트 상수(예외 adviceHistory) · aaq:// 리터럴', () {
      final List<String> bad = _violations('㉒');
      expect(
        bad,
        isEmpty,
        reason: '링크는 데이터로 온다(01 §11-1 규칙 ③ · K5).\n${bad.join('\n')}',
      );
    });

    test('C-46 ㉓ 초안 수명 — clear 는 executed 갈래에서만', () {
      final List<String> bad = _violations('㉓');
      expect(
        bad,
        isEmpty,
        reason: '거부·예산 코드 탭은 지우지 않는다(C17 · K12).\n${bad.join('\n')}',
      );
    });

    test('C-46 ㉔ dispose 안 ref 0 — initState 에서 잡은 인스턴스로 stop', () {
      final List<String> bad = _violations('㉔');
      expect(
        bad,
        isEmpty,
        reason:
            'Riverpod 2.6.1 은 해제 뒤 ref 에 StateError(G58 · K9).\n${bad.join('\n')}',
      );
    });

    test('C-46 ㉕ 묶기·고르기 0(읽기 화면)', () {
      final List<String> bad = _violations('㉕');
      expect(
        bad,
        isEmpty,
        reason: '받은 순서 그대로(K18 · 01 §4-1 «거르기도 판정»).\n${bad.join('\n')}',
      );
    });

    test('C-46 ㉖ 명령 범위 — 읽기 화면의 명령 = deferAdviceConfirm 하나', () {
      final List<String> bad = _violations('㉖');
      expect(
        bad,
        isEmpty,
        reason: '기록 명령은 목적지 폼이 부른다(02 §3-6 · K14 ⓐ 예외 1).\n${bad.join('\n')}',
      );
    });

    test('C-46 ㉗ 자체 검증 — 양성은 걸리고 음성은 통과한다', () {
      for (final (String snippet, bool read, String clause) in _positives) {
        final Set<String> got = <String>{
          for (final _Hit h in _scan(snippet, read: read)) h.clause,
        };
        expect(
          got,
          contains(clause),
          reason: '양성 스니펫을 못 잡았다($clause): $snippet',
        );
        _say(
          'C-46 ㉗ 양성 ${read ? '읽기' : '폼'} $snippet → ${(got.toList()..sort()).join('')}',
        );
      }
      for (final (String snippet, bool read) in _negatives) {
        expect(
          _scan(snippet, read: read),
          isEmpty,
          reason: '음성 스니펫을 잘못 잡았다(${read ? '읽기' : '폼'}): $snippet',
        );
      }
    });
  });
}
