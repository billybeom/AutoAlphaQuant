// X5-1 정규 직렬화 · day_hash · 해시 체인(설계 13 §8 R51 H1~H9 · 01 §6-3 X5 절 · §6-7 · 06 X5-1 · 계약 `hashFormatVersion`).
//
// 🔴 이 파일이 정규 직렬화의 정본이다(규칙을 바꾸면 `hashFormatVersion` 을 올리고 골든을 다시 고정한다).
// 🔴 모집단 = authored 귀속 불변 스트림 16표 · 칸 = 고정 투영(상태 전이 칸만 뺀다) — 아카이브(E11h2)와 같은 목록.
// 🔴 독립 구현 = `tool/make_ledger_hash_golden.py`(표준 라이브러리만) — 골든 `test/golden/vectors/ledger_hash_v1.json`.

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// 체인 시작값(`0` × 64 · R51 H6).
const String kChainGenesis =
    '0000000000000000000000000000000000000000000000000000000000000000';

/// 해시 모집단 한 표(R51 H1 · H2).
class LedgerHashTable {
  /// 표를 만든다.
  const LedgerHashTable(
    this.table, {
    required this.axis,
    required this.columns,
    this.excluded = const <String>[],
    this.parentTable,
    this.parentKey,
  });

  /// 표 이름.
  final String table;

  /// authored 축 칸 — [parentTable] 이 있으면 그 표의 칸.
  final String axis;

  /// 해시 투영 칸(전부 · 순서 무관 — 정규 행은 이름 순).
  final List<String> columns;

  /// 상태 전이 칸(투영에서 뺀 칸 — 시험이 «스키마 − 투영 = 이것»을 단언한다).
  final List<String> excluded;

  /// 축을 부모 표에서 읽을 때 그 표.
  final String? parentTable;

  /// 부모와 잇는 칸(같은 이름).
  final String? parentKey;
}

/// 모집단 v1(R51 H1 · 순서 고정 — day_hash 입력 순서).
const List<LedgerHashTable> kLedgerHashPopulationV1 = <LedgerHashTable>[
  LedgerHashTable(
    'executions',
    axis: 'authored_at',
    columns: <String>[
      'execution_id',
      'broker_order_no',
      'executed_at',
      'quantity',
      'price',
      'commission',
      'tax',
      'authored_at',
      'fill_origin',
      'fill_kind',
      'advice_id',
      'reverses_fill_id',
      'restates_fill_id',
      'authored_by_device_id',
      'backdate_trading_days',
      'cost_source',
      'off_hour_trade',
      'during_halt',
      'price_range_source_date',
    ],
  ),
  LedgerHashTable(
    'trades',
    axis: 'authored_at',
    columns: <String>[
      'trade_id',
      'strategy_id',
      'market',
      'symbol',
      'entry_date',
      'exit_date',
      'quantity',
      'entry_price',
      'exit_price',
      'gross_pnl',
      'total_cost',
      'net_pnl',
      'pnl_pct',
      'exit_tier',
      'exit_kind',
      'holding_days',
      'mode',
      'authored_at',
      'fill_origin',
      'fill_kind',
    ],
  ),
  LedgerHashTable(
    'cash_flow',
    axis: 'recorded_at',
    columns: <String>[
      'flow_id',
      'trade_date',
      'amount',
      'currency',
      'kind',
      'note',
      'recorded_at',
      'source_event_id',
      'account_alias',
    ],
  ),
  LedgerHashTable(
    'decision_log',
    axis: 'created_at',
    columns: <String>[
      'decision_id',
      'created_at',
      'trade_date',
      'mode',
      'kind',
      'strategy_id',
      'sleeve',
      'symbol',
      'reason',
      'reason_code',
      'tier',
      'exit_kind',
      'trigger_price',
      'threshold_registered',
      'rule_cited',
      'regime_ref',
      'config_hash',
      'parent_decision_id',
      'journal_id',
    ],
  ),
  LedgerHashTable(
    'rebalance_event',
    axis: 'created_at',
    columns: <String>[
      'event_id',
      'trade_date',
      'mode',
      'kind',
      'decision_id',
      'trigger_snapshot',
      'weights_before',
      'weights_after',
      'config_hash',
      'created_at',
    ],
  ),
  LedgerHashTable(
    'decision_journal',
    axis: 'created_at',
    columns: <String>[
      'journal_id',
      'trade_date',
      'strategy_id',
      'signal_value',
      'action_taken',
      'is_deviation',
      'rationale_before',
      'expected_outcome',
      'rule_cited',
      'kind',
      'note',
      'created_at',
    ],
  ),
  LedgerHashTable(
    'order_intents',
    axis: 'created_at',
    columns: <String>[
      'intent_id',
      'idempotency_key',
      'created_at',
      'trade_date',
      'market',
      'account',
      'strategy_id',
      'decision_id',
      'symbol',
      'side',
      'order_type',
      'quantity',
      'limit_price',
      'sizing_binding',
      'config_hash',
      'dry_run',
      'mode',
      'operating_mode',
    ],
    excluded: <String>['status', 'error_message', 'updated_at'],
  ),
  LedgerHashTable(
    'advice',
    axis: 'created_at',
    columns: <String>[
      'advice_id',
      'batch_id',
      'intent_id',
      'decision_id',
      'mode',
      'trade_date',
      'valid_until_date',
      'kind',
      'symbol',
      'sleeve',
      'side',
      'quantity',
      'price_low',
      'price_high',
      'price_ref',
      'is_urgent',
      'reason',
      'reason_code',
      'depends_on_advice_id',
      'account_alias',
      'suppressed',
      'suppressed_label',
      'sizing_label',
      'config_hash',
      'created_at',
    ],
    excluded: <String>['status', 'close_reason_code', 'superseded_by'],
  ),
  LedgerHashTable(
    'advice_transition',
    axis: 'occurred_at',
    columns: <String>[
      'transition_id',
      'advice_id',
      'from_status',
      'to_status',
      'cause_code',
      'command_id',
      'fill_id',
      'decision_id',
      'occurred_at',
    ],
  ),
  LedgerHashTable(
    'external_holding',
    axis: 'registered_at',
    columns: <String>[
      'external_id',
      'symbol',
      'account_alias',
      'quantity',
      'decision_id',
      'note',
      'registered_at',
    ],
    excluded: <String>['released_at'],
  ),
  LedgerHashTable(
    'self_report_balance',
    axis: 'reported_at',
    columns: <String>[
      'report_id',
      'as_of_trade_date',
      'account_alias',
      'session_started_at',
      'cash_krw',
      'declared_complete',
      'device_id',
      'command_id',
      'reported_at',
    ],
  ),
  LedgerHashTable(
    'self_report_line',
    axis: 'reported_at',
    columns: <String>['report_id', 'symbol', 'quantity'],
    parentTable: 'self_report_balance',
    parentKey: 'report_id',
  ),
  LedgerHashTable(
    'handover_session',
    axis: 'opened_at',
    columns: <String>[
      'handover_session_id',
      'kind',
      'path',
      'device_id',
      'lease_epoch',
      'opened_at',
      'expires_at',
    ],
    excluded: <String>['closed_at', 'close_code'],
  ),
  LedgerHashTable(
    'operating_mode_transition',
    axis: 'committed_at',
    columns: <String>[
      'transition_id',
      'handover_session_id',
      'from_mode',
      'to_mode',
      'decision_id',
      'committed_at',
    ],
  ),
  LedgerHashTable(
    'operating_param_log',
    axis: 'changed_at',
    columns: <String>[
      'row_id',
      'param_key',
      'value_text',
      'changed_at',
      'effective_from',
      'action_run_id',
      'device_id',
    ],
    excluded: <String>['superseded_by'],
  ),
  LedgerHashTable(
    'ledger_event',
    axis: 'authored_at',
    columns: <String>[
      'event_id',
      'kind',
      'entry_kind',
      'reverses_event_id',
      'effective_date',
      'account_alias',
      'symbol',
      'amount_krw',
      'tax_withheld_krw',
      'action_type',
      'ratio_from',
      'ratio_to',
      'cash_in_lieu_krw',
      'decision_id',
      'command_id',
      'authored_by_device_id',
      'authored_at',
      'note',
    ],
  ),
];

/// 정규화 · 귀속 실패 — 🔴 사유 = 표 · 칸 · 키만(금액 0).
class LedgerHashError implements Exception {
  /// 실패를 만든다.
  const LedgerHashError(this.reason);

  /// 사유.
  final String reason;

  @override
  String toString() => 'LedgerHashError($reason)';
}

/// 실수의 정규 표기(R51 H3) — 최단 왕복 자릿수 · 지수 없는 10진 · 소수 1자리 이상 · −0 = `0.0` · 무한 · NaN = 실패.
String canonicalDouble(double v) {
  if (v.isNaN || v.isInfinite) throw const LedgerHashError('실수가 유한하지 않다');
  if (v == 0) return '0.0';
  final String s = v.toString(); // Dart = 최단 왕복 자릿수
  final bool neg = s.startsWith('-');
  final String body = neg ? s.substring(1) : s;
  // Dart 는 지수 꼴을 |v| ≥ 1e21 · < 1e-6 에만 쓴다(JS 와 같은 규칙) — 큰 쪽은 정수부가 자릿수보다 길고,
  // 작은 쪽은 정수부가 0 이하다. 최단 자릿수라 끝 0 은 «N.0» 꼴에만 있다.
  final int e = body.indexOf('e');
  String plain;
  if (e < 0) {
    plain = body;
  } else {
    final String mant = body.substring(0, e);
    final int exp = int.parse(body.substring(e + 1));
    final int dot = mant.indexOf('.');
    final String digits = mant.replaceFirst('.', '');
    final int intLen = (dot < 0 ? mant.length : dot) + exp;
    plain = intLen <= 0
        ? '0.${'0' * -intLen}$digits'
        : '${digits.padRight(intLen, '0')}.0';
  }
  return neg ? '-$plain' : plain;
}

String _hex4(int c) => c.toRadixString(16).padLeft(4, '0');

/// 문자열의 정규 표기(R51 H3) — 큰따옴표 · 역슬래시 · 제어 문자만 이스케이프 · 비ASCII = 그대로.
String canonicalString(String s) {
  final StringBuffer b = StringBuffer('"');
  for (final int c in s.codeUnits) {
    switch (c) {
      case 0x22:
        b.write(r'\"');
      case 0x5c:
        b.write(r'\\');
      case 0x08:
        b.write(r'\b');
      case 0x0c:
        b.write(r'\f');
      case 0x0a:
        b.write(r'\n');
      case 0x0d:
        b.write(r'\r');
      case 0x09:
        b.write(r'\t');
      default:
        if (c < 0x20) {
          b.write('\\u${_hex4(c)}');
        } else {
          b.writeCharCode(c);
        }
    }
  }
  b.write('"');
  return b.toString();
}

/// 값 하나의 정규 표기 — 정수 · 실수 · 문자열 · NULL 만(그 밖 = 실패).
String canonicalValue(Object? v) => switch (v) {
  null => 'null',
  final int i => i.toString(),
  final double d => canonicalDouble(d),
  final String s => canonicalString(s),
  _ => throw LedgerHashError('정규화할 수 없는 값 형식: ${v.runtimeType}'),
};

/// 행 하나의 정규 표기(R51 H3) — [columns] 만 · 이름 ASCII 순 · 공백 없음 · 칸이 없으면 실패.
String canonicalRow(Map<String, Object?> row, List<String> columns) {
  final List<String> names = <String>[...columns]..sort();
  final StringBuffer b = StringBuffer('{');
  for (int k = 0; k < names.length; k++) {
    final String n = names[k];
    if (!row.containsKey(n)) throw LedgerHashError('칸 없음: $n');
    if (k > 0) b.write(',');
    b
      ..write(canonicalString(n))
      ..write(':')
      ..write(canonicalValue(row[n]));
  }
  b.write('}');
  return b.toString();
}

int _compareBytes(List<int> a, List<int> b) {
  final int n = a.length < b.length ? a.length : b.length;
  for (int k = 0; k < n; k++) {
    if (a[k] != b[k]) return a[k] - b[k];
  }
  return a.length - b.length;
}

/// 정규 줄들을 UTF-8 바이트 순으로(R51 H4).
List<String> sortCanonicalLines(Iterable<String> lines) {
  final List<(String, List<int>)> keyed =
      <(String, List<int>)>[for (final String l in lines) (l, utf8.encode(l))]
        ..sort(
          ((String, List<int>) x, (String, List<int>) y) =>
              _compareBytes(x.$2, y.$2),
        );
  return <String>[for (final (String l, _) in keyed) l];
}

String _sha256Hex(List<int> bytes) => sha256.convert(bytes).toString();

/// 하루의 해시 입력(R51 H4) — 모집단 순서 · 표마다 정렬된 `{표}\t{정규 행}\n`.
String dayHashInput(
  Map<String, List<String>> linesByTable, {
  List<LedgerHashTable> population = kLedgerHashPopulationV1,
}) {
  final Set<String> known = <String>{
    for (final LedgerHashTable t in population) t.table,
  };
  for (final String t in linesByTable.keys) {
    if (!known.contains(t)) throw LedgerHashError('모집단 밖 표: $t');
  }
  final StringBuffer b = StringBuffer();
  for (final LedgerHashTable t in population) {
    for (final String l in sortCanonicalLines(
      linesByTable[t.table] ?? const <String>[],
    )) {
      b
        ..write(t.table)
        ..write('\t')
        ..write(l)
        ..write('\n');
    }
  }
  return b.toString();
}

/// day_hash(D) — SHA-256 소문자 16진(행 0 = 빈 입력의 해시).
String dayHashOf(
  Map<String, List<String>> linesByTable, {
  List<LedgerHashTable> population = kLedgerHashPopulationV1,
}) =>
    _sha256Hex(utf8.encode(dayHashInput(linesByTable, population: population)));

final RegExp _hex64 = RegExp(r'^[0-9a-f]{64}$');

/// chain(D) = SHA-256(ASCII(chain(D−1) ‖ day_hash(D)))(R51 H6).
String chainHashOf(String previousChain, String dayHash) {
  if (!_hex64.hasMatch(previousChain) || !_hex64.hasMatch(dayHash)) {
    throw ArgumentError('해시는 소문자 16진 64자여야 한다');
  }
  return _sha256Hex(ascii.encode('$previousChain$dayHash'));
}

/// 표마다 행 수(전 모집단 표 · 0 포함) 정규 JSON(R51 H4 · `row_counts`).
String rowCountsJson(
  Map<String, List<String>> linesByTable, {
  List<LedgerHashTable> population = kLedgerHashPopulationV1,
}) => canonicalRow(
  <String, Object?>{
    for (final LedgerHashTable t in population)
      t.table: (linesByTable[t.table] ?? const <String>[]).length,
  },
  <String>[for (final LedgerHashTable t in population) t.table],
);

final RegExp _isoWithOffset = RegExp(
  r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2}(\.\d{1,6})?)?(Z|[+-]\d{2}:\d{2})$',
);

/// 축 시각의 한국 날짜 `YYYY-MM-DD`(R51 H5 · UTC+9) — NULL · 못 읽음 = 실패.
String authoredKstDate(Object? axis, {required String where}) {
  if (axis is! String) throw LedgerHashError('$where: 기록 시각 없음');
  // 🔴 시간대가 없으면 Dart 는 기기 현지 시각으로 읽는다 — `Z` 또는 `±hh:mm` 만 받는다.
  final DateTime? t = _isoWithOffset.hasMatch(axis)
      ? DateTime.tryParse(axis)
      : null;
  if (t == null) throw LedgerHashError('$where: 기록 시각을 읽을 수 없다');
  final DateTime k = t.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${k.year.toString().padLeft(4, '0')}-${two(k.month)}-${two(k.day)}';
}

/// 표시 스탬프 `chn_{앞 4}…{뒤 2}`(R51 H8 · 계약 `LedgerRepairRow.chainStampText`).
String chainStampText(String chain) {
  if (!_hex64.hasMatch(chain)) throw ArgumentError('체인 해시가 아니다');
  return 'chn_${chain.substring(0, 4)}…${chain.substring(62)}';
}

/// 캘린더 운반 축약 — 앞 16자(R51 H8 · `CalendarEventDto.chainHash`).
String chainCarryText(String chain) {
  if (!_hex64.hasMatch(chain)) throw ArgumentError('체인 해시가 아니다');
  return chain.substring(0, 16);
}
