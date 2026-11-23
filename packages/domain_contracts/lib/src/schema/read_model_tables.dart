// 영역 H — 🆕 계약 v1.36(01 §45 · §6-4 · 지도 D15 · 13 R230 L2 · K303~K316) 읽기 모델 `rm_*` 표 22 — 열 · 키 · 형 · 결속 DTO.
//
// 🔴 이 파일이 `rm_*` DDL 의 정본이다 — 생성기(data_sync E11l1 · Dart 순수 함수) · 엔진 push(E11l2) · 뷰어(`read_model_client`)가
//    같은 글자를 쓴다. DDL 은 손으로 적지 않는다(`ddl/batch_d_supabase.sql` §읽기 모델 · 06 M4-1).
// 🔴 열 = 결속 DTO `toJson()` 최상위 키(접두 · 제외 · 펼침 한 겹) + DTO 밖 열 + 규칙 5조 4칸 — C-69 가 표본 인스턴스로 대조한다(G-22).
//    뷰어 = 행에서 접두를 떼고(펼친 키는 다시 묶고) 제외 키에 뷰어 판 값을 넣어 `X.fromJson` 한 번(C-69 ⑥ 왕복).
// 🔴 형 = 와이어 그대로(글자 → text · 정수 → bigint · 실수 → double precision · 참거짓 → boolean · 객체 · 목록 → jsonb) ·
//    규칙 5조 칸만 bigint · timestamptz · NOT NULL = 키 열 + 규칙 5조 4칸뿐(DTO 모양 판정 = 뷰어 `fromJson(row)` · 못 읽으면 던짐 — K206).
// 🔴 수치(돈 · 안전 문턱)를 이 파일에 적지 않는다 — 열 이름 · 형 · 사유 글자뿐.
// 🔵 v1.28 `AllocationReadModelColumns`(`read_model_columns.dart`) = `rm_config_view` 의 `allocation_*` 7열 그대로(C-69 ⑨).

/// 열 형(와이어 그대로 — K305).
/// 🔵 와이어 열거가 아니다(JSON 으로 나가지 않는다 — C-12 밖) — Postgres 형 글자를 담는 상수 다섯 + `timestamptz`.
final class ReadModelColumnType {
  const ReadModelColumnType._(this.sql);

  /// `text`.
  static const ReadModelColumnType text = ReadModelColumnType._('text');

  /// `bigint`.
  static const ReadModelColumnType bigint = ReadModelColumnType._('bigint');

  /// `double precision`.
  static const ReadModelColumnType doublePrecision = ReadModelColumnType._(
    'double precision',
  );

  /// `boolean`.
  static const ReadModelColumnType boolean = ReadModelColumnType._('boolean');

  /// `jsonb`.
  static const ReadModelColumnType jsonb = ReadModelColumnType._('jsonb');

  /// `timestamptz` — 규칙 5조 `pushed_at` 만.
  static const ReadModelColumnType timestamptz = ReadModelColumnType._(
    'timestamptz',
  );

  /// 전부(이 차례).
  static const List<ReadModelColumnType> values = <ReadModelColumnType>[
    text,
    bigint,
    doublePrecision,
    boolean,
    jsonb,
    timestamptz,
  ];

  /// Postgres 형 글자.
  final String sql;

  @override
  String toString() => sql;
}

/// 열 하나.
final class ReadModelColumn {
  const ReadModelColumn(
    this.name,
    this.type, {
    this.checkValues = const <String>[],
  });

  /// 열 이름(snake · DTO 와이어 키 그대로).
  final String name;

  /// 형.
  final ReadModelColumnType type;

  /// `check (… in (…))` 값 — 빈 = check 없음(`mode`(규칙 5조 ①) · `operating_mode`(§8-19)만).
  final List<String> checkValues;
}

/// 제외 키 — 열 0 · 뷰어가 `fromJson` 앞에 넣는 값(K307).
final class ReadModelExclusion {
  const ReadModelExclusion(this.key, this.reason, {this.viewerValue = 'null'});

  /// DTO 와이어 키(접두 없음).
  final String key;

  /// 사유(문서 글자).
  final String reason;

  /// 뷰어 판 값 — JSON 글자(`null` · `[]`) 또는 같은 행의 열 이름(그 열 값을 옮긴다).
  final String viewerValue;
}

/// DTO 결속 — 열 = [prefix] + `toJson()` 최상위 키(제외 뺌 · [flatten] 키는 그 객체의 키로 한 겹 펼침).
final class ReadModelBinding {
  const ReadModelBinding(
    this.dto, {
    this.prefix = '',
    this.flatten = const <String, String>{},
    this.excluded = const <ReadModelExclusion>[],
    this.feeds = const <String>[],
  });

  /// 계약 타입 이름.
  final String dto;

  /// 열 접두 — 빈 = 무접두(한 표에 DTO 여럿이면 둘째부터 — K306).
  final String prefix;

  /// 한 겹 펼칠 키 → 그 값의 타입 이름(v1.28 `allocation_*` = `current` 펼침 · K201).
  final Map<String, String> flatten;

  /// 제외 키.
  final List<ReadModelExclusion> excluded;

  /// 이 결속이 원천인 뷰어 창구(«저장소.메서드»).
  final List<String> feeds;
}

/// DTO 밖 열 — 출처 한 줄(K308).
final class ReadModelExtraColumn {
  const ReadModelExtraColumn(this.name, this.source);

  /// 열 이름.
  final String name;

  /// 출처(문서 글자).
  final String source;
}

/// 뷰어 판 열 — 열은 있다 · 엔진 push 가 뷰어 판 값을 싣는다(K309).
final class ReadModelViewerVariant {
  const ReadModelViewerVariant(this.keyPath, this.rule);

  /// 열 이름 또는 jsonb 안 경로(`rows[].deployed_text`).
  final String keyPath;

  /// 규칙(문서 글자).
  final String rule;
}

/// 읽기 모델 표 하나.
final class ReadModelTable {
  const ReadModelTable({
    required this.name,
    required this.keyColumns,
    required this.columns,
    this.bindings = const <ReadModelBinding>[],
    this.extraColumns = const <ReadModelExtraColumn>[],
    this.viewerVariants = const <ReadModelViewerVariant>[],
    this.listCodes = const <String>[],
  });

  /// 표 이름(`rm_` 접두).
  final String name;

  /// 증분 키 = 기본 키(첫 칸 = `mode` — 규칙 5조 ①).
  final List<String> keyColumns;

  /// 열 — 규칙 5조 4칸 밖 · 이 차례(생성기 출력 차례 = 규칙 5조 4칸 뒤).
  final List<ReadModelColumn> columns;

  /// 결속 DTO.
  final List<ReadModelBinding> bindings;

  /// DTO 밖 열.
  final List<ReadModelExtraColumn> extraColumns;

  /// 뷰어 판 열.
  final List<ReadModelViewerVariant> viewerVariants;

  /// 이 표가 행 원천인 목록 창구 — 봉투 = `rm_list_envelope` 그 `list_code` 행(K310).
  final List<String> listCodes;
}

/// 규칙 5조 ① push 4칸(전 `rm_*` · 열 차례 = 표 맨 앞 · 전부 NOT NULL).
abstract final class ReadModelPushColumns {
  /// `row_version bigint not null` — upsert 승자(규칙 5조 ②).
  static const ReadModelColumn rowVersion = ReadModelColumn(
    'row_version',
    ReadModelColumnType.bigint,
  );

  /// `lease_epoch bigint not null` — 낮은 epoch 쓰기 거부(push RPC · E11l2).
  static const ReadModelColumn leaseEpoch = ReadModelColumn(
    'lease_epoch',
    ReadModelColumnType.bigint,
  );

  /// `pushed_at timestamptz not null default now()`.
  static const ReadModelColumn pushedAt = ReadModelColumn(
    'pushed_at',
    ReadModelColumnType.timestamptz,
  );

  /// `mode text not null check (mode in (RunMode 3))` — 키 첫 칸(G-31).
  static const ReadModelColumn mode = ReadModelColumn(
    'mode',
    ReadModelColumnType.text,
    checkValues: <String>['LIVE', 'SIM_INTERNAL', 'SIM_BROKER'],
  );

  /// 전부(이 차례).
  static const List<ReadModelColumn> all = <ReadModelColumn>[
    rowVersion,
    leaseEpoch,
    pushedAt,
    mode,
  ];
}

/// RLS — 표마다 `enable row level security` + select 전용 정책 하나(규칙 5조 ④ · G-10 · K311).
/// 🔴 INSERT · UPDATE · DELETE 클라이언트 정책 0 — 쓰기 = operator 리스 epoch 를 검사하는 security definer RPC 1창구(E11l2).
abstract final class ReadModelRls {
  /// 정책 이름 = `<표>_select`.
  static String selectPolicyName(String table) => '${table}_select';

  /// select 정책 대상 역할.
  static const String selectRole = 'authenticated';

  /// select 정책 `using (…)` 본문 — 부른 사용자의 ACTIVE 기기 행이 있을 때(v1.34 `app_device` 조인 · JWT 클레임 0).
  static const String selectUsing =
      "exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE')";
}

/// 목록 창구 이름 — `rm_list_envelope.list_code` 값(«저장소.메서드» · K310).
abstract final class ReadModelListCodes {
  /// `JournalRepository.watchTimeline` — 행 = `rm_journal`.
  static const String journalWatchTimeline = 'JournalRepository.watchTimeline';

  /// `HoldingsRepository.watchHoldings` — 행 = `rm_holding`.
  static const String holdingsWatchHoldings =
      'HoldingsRepository.watchHoldings';

  /// `RebalanceRepository.watchEvents` — 행 = `rm_rebalance_event`.
  static const String rebalanceWatchEvents = 'RebalanceRepository.watchEvents';

  /// `AdviceRepository.watchInbox` — 행 = `rm_advice`.
  static const String adviceWatchInbox = 'AdviceRepository.watchInbox';

  /// `AdviceRepository.watchHistory` — 행 = `rm_advice`.
  static const String adviceWatchHistory = 'AdviceRepository.watchHistory';

  /// `LedgerRepository.watchOpenDiffs` — 행 = `rm_ledger_diff`.
  static const String ledgerWatchOpenDiffs = 'LedgerRepository.watchOpenDiffs';

  /// `OpsStatusRepository.watchRhythm` — 행 = `rm_ops_summary`.
  static const String opsStatusWatchRhythm = 'OpsStatusRepository.watchRhythm';

  /// `JournalRepository.watchBlindReviewQueue` — 행 = `rm_blind_review`.
  static const String journalWatchBlindReviewQueue =
      'JournalRepository.watchBlindReviewQueue';

  /// 전부(이 차례).
  static const List<String> all = <String>[
    journalWatchTimeline,
    holdingsWatchHoldings,
    rebalanceWatchEvents,
    adviceWatchInbox,
    adviceWatchHistory,
    ledgerWatchOpenDiffs,
    opsStatusWatchRhythm,
    journalWatchBlindReviewQueue,
  ];
}

/// 읽기 모델 표 22(K303 · 01 §6-4 · 이 차례 = 부트스트랩 출력 차례).
abstract final class ReadModelTables {
  /// `rm_journal`.
  static const ReadModelTable journal = ReadModelTable(
    name: 'rm_journal',
    keyColumns: <String>['mode', 'trade_date', 'entry_id'],
    columns: <ReadModelColumn>[
      ReadModelColumn('entry_id', ReadModelColumnType.text),
      ReadModelColumn('trade_date', ReadModelColumnType.text),
      ReadModelColumn('executed_at', ReadModelColumnType.text),
      ReadModelColumn('symbol', ReadModelColumnType.text),
      ReadModelColumn('symbol_label', ReadModelColumnType.text),
      ReadModelColumn('sleeve', ReadModelColumnType.text),
      ReadModelColumn('side', ReadModelColumnType.text),
      ReadModelColumn('side_label', ReadModelColumnType.text),
      ReadModelColumn('quantity', ReadModelColumnType.bigint),
      ReadModelColumn('price', ReadModelColumnType.text),
      ReadModelColumn('commission', ReadModelColumnType.text),
      ReadModelColumn('tax', ReadModelColumnType.text),
      ReadModelColumn('quantity_text', ReadModelColumnType.text),
      ReadModelColumn('price_text', ReadModelColumnType.text),
      ReadModelColumn('commission_text', ReadModelColumnType.text),
      ReadModelColumn('tax_text', ReadModelColumnType.text),
      ReadModelColumn('status', ReadModelColumnType.text),
      ReadModelColumn('status_label', ReadModelColumnType.text),
      ReadModelColumn('status_tone', ReadModelColumnType.text),
      ReadModelColumn('visibility', ReadModelColumnType.text),
      ReadModelColumn('visibility_label', ReadModelColumnType.text),
      ReadModelColumn('reasons', ReadModelColumnType.jsonb),
      ReadModelColumn('decision', ReadModelColumnType.jsonb),
      ReadModelColumn('deviation', ReadModelColumnType.jsonb),
      ReadModelColumn('account_alias', ReadModelColumnType.text),
      ReadModelColumn('fill_origin', ReadModelColumnType.text),
      ReadModelColumn('fill_kind', ReadModelColumnType.text),
      ReadModelColumn('advice_id', ReadModelColumnType.text),
      ReadModelColumn('backdate', ReadModelColumnType.jsonb),
      ReadModelColumn('cost_source', ReadModelColumnType.text),
      ReadModelColumn('cost_source_label', ReadModelColumnType.text),
      ReadModelColumn('origin_label', ReadModelColumnType.text),
      ReadModelColumn('rebalance_event_id', ReadModelColumnType.text),
      ReadModelColumn('detail_deep_link', ReadModelColumnType.text),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'TradeJournalEntry',
        feeds: <String>[
          'JournalRepository.watchTimeline',
          'JournalRepository.findByDecisionId',
          'JournalRepository.chainOf',
          'JournalRepository.fillChain',
          'AdviceRepository.fillsOfAdvice',
        ],
      ),
    ],
    listCodes: <String>['JournalRepository.watchTimeline'],
  );

  /// `rm_holding`.
  static const ReadModelTable holding = ReadModelTable(
    name: 'rm_holding',
    keyColumns: <String>['mode', 'trade_date', 'holding_id'],
    columns: <ReadModelColumn>[
      ReadModelColumn('trade_date', ReadModelColumnType.text),
      ReadModelColumn('symbol', ReadModelColumnType.text),
      ReadModelColumn('symbol_label', ReadModelColumnType.text),
      ReadModelColumn('sleeve', ReadModelColumnType.text),
      ReadModelColumn('account_alias', ReadModelColumnType.text),
      ReadModelColumn('quantity', ReadModelColumnType.bigint),
      ReadModelColumn('avg_price', ReadModelColumnType.text),
      ReadModelColumn('entry_date', ReadModelColumnType.text),
      ReadModelColumn('entry_decision', ReadModelColumnType.jsonb),
      ReadModelColumn('entry_reasons', ReadModelColumnType.jsonb),
      ReadModelColumn('sma_tranches', ReadModelColumnType.jsonb),
      ReadModelColumn('gates', ReadModelColumnType.jsonb),
      ReadModelColumn('stop_line', ReadModelColumnType.jsonb),
      ReadModelColumn('momentum', ReadModelColumnType.jsonb),
      ReadModelColumn('scope', ReadModelColumnType.text),
      ReadModelColumn('scope_label', ReadModelColumnType.text),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('holding_id', ReadModelColumnType.text),
      ReadModelColumn('quantity_text', ReadModelColumnType.text),
      ReadModelColumn('avg_price_text', ReadModelColumnType.text),
      ReadModelColumn('weight_text', ReadModelColumnType.text),
      ReadModelColumn('pending_text', ReadModelColumnType.text),
      ReadModelColumn('sub_book_label', ReadModelColumnType.text),
      ReadModelColumn('detail_deep_link', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'HoldingRow',
        excluded: <ReadModelExclusion>[
          ReadModelExclusion(
            'pnl',
            '🔴 손익 원장 금지(규칙 5조 ⑤ · K15) — 뷰어 `pnlToggleLabel` null',
          ),
        ],
        feeds: <String>['HoldingsRepository.watchHoldings'],
      ),
    ],
    extraColumns: <ReadModelExtraColumn>[
      ReadModelExtraColumn(
        'trade_date',
        'push 스냅숏 거래일 — 그 행 `as_of.trade_date` 와 같은 값(엔진)',
      ),
    ],
    listCodes: <String>['HoldingsRepository.watchHoldings'],
  );

  /// `rm_performance_point`.
  static const ReadModelTable performancePoint = ReadModelTable(
    name: 'rm_performance_point',
    keyColumns: <String>['mode', 'metric', 'granularity', 'cumulative', 'date'],
    columns: <ReadModelColumn>[
      ReadModelColumn('metric', ReadModelColumnType.text),
      ReadModelColumn('granularity', ReadModelColumnType.text),
      ReadModelColumn('cumulative', ReadModelColumnType.boolean),
      ReadModelColumn('date', ReadModelColumnType.text),
      ReadModelColumn('x_normalized', ReadModelColumnType.doublePrecision),
      ReadModelColumn('date_text', ReadModelColumnType.text),
      ReadModelColumn('value_text', ReadModelColumnType.text),
      ReadModelColumn('y_normalized', ReadModelColumnType.doublePrecision),
      ReadModelColumn('value', ReadModelColumnType.doublePrecision),
      ReadModelColumn('gap_reason_code', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'PerfPoint',
        feeds: <String>['PerformanceRepository.series'],
      ),
    ],
    extraColumns: <ReadModelExtraColumn>[
      ReadModelExtraColumn(
        'metric',
        '부모 시리즈 `PerformanceSeries.metric` 와이어(같은 키 글자)',
      ),
      ReadModelExtraColumn(
        'granularity',
        '부모 시리즈 `PerformanceSeries.granularity` 와이어',
      ),
      ReadModelExtraColumn(
        'cumulative',
        '부모 시리즈 `PerformanceSeries.cumulative`',
      ),
    ],
  );

  /// `rm_performance_series`.
  static const ReadModelTable performanceSeries = ReadModelTable(
    name: 'rm_performance_series',
    keyColumns: <String>['mode', 'metric', 'granularity', 'cumulative'],
    columns: <ReadModelColumn>[
      ReadModelColumn('metric', ReadModelColumnType.text),
      ReadModelColumn('granularity', ReadModelColumnType.text),
      ReadModelColumn('cumulative', ReadModelColumnType.boolean),
      ReadModelColumn('segments', ReadModelColumnType.jsonb),
      ReadModelColumn('disclosure', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('series_label', ReadModelColumnType.text),
      ReadModelColumn('period_label', ReadModelColumnType.text),
      ReadModelColumn('y_ticks', ReadModelColumnType.jsonb),
      ReadModelColumn('unavailable_label', ReadModelColumnType.text),
      ReadModelColumn('benchmark', ReadModelColumnType.jsonb),
      ReadModelColumn('after_tax', ReadModelColumnType.jsonb),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'PerformanceSeries',
        excluded: <ReadModelExclusion>[
          ReadModelExclusion(
            'points',
            '점 = `rm_performance_point` 그 시리즈 행(`date` 오름차순 · 뷰어가 다시 정규화하지 않는다)',
            viewerValue: '[]',
          ),
        ],
        feeds: <String>['PerformanceRepository.series'],
      ),
    ],
  );

  /// `rm_rebalance_event`.
  static const ReadModelTable rebalanceEvent = ReadModelTable(
    name: 'rm_rebalance_event',
    keyColumns: <String>['mode', 'event_id'],
    columns: <ReadModelColumn>[
      ReadModelColumn('event_id', ReadModelColumnType.text),
      ReadModelColumn('trade_date', ReadModelColumnType.text),
      ReadModelColumn('kind', ReadModelColumnType.text),
      ReadModelColumn('kind_label', ReadModelColumnType.text),
      ReadModelColumn('before', ReadModelColumnType.jsonb),
      ReadModelColumn('after', ReadModelColumnType.jsonb),
      ReadModelColumn('trigger', ReadModelColumnType.jsonb),
      ReadModelColumn('order_intent_ids', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('quality', ReadModelColumnType.jsonb),
      ReadModelColumn('thresholds', ReadModelColumnType.jsonb),
      ReadModelColumn('mode_label', ReadModelColumnType.text),
      ReadModelColumn('section_label', ReadModelColumnType.text),
      ReadModelColumn('journal_timeline_link', ReadModelColumnType.jsonb),
      ReadModelColumn('detail_deep_link', ReadModelColumnType.text),
      ReadModelColumn('scope_label', ReadModelColumnType.text),
      ReadModelColumn('scope_range', ReadModelColumnType.jsonb),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'RebalanceEvent',
        feeds: <String>[
          'RebalanceRepository.watchEvents',
          'RebalanceRepository.watchEvent',
        ],
      ),
      ReadModelBinding(
        'JournalRebalanceScope',
        prefix: 'scope_',
        excluded: <ReadModelExclusion>[
          ReadModelExclusion(
            'rebalance_event_id',
            '같은 값 = `event_id` 열',
            viewerValue: 'event_id',
          ),
        ],
        feeds: <String>['JournalRepository.watchRebalanceScope'],
      ),
    ],
    listCodes: <String>['RebalanceRepository.watchEvents'],
  );

  /// `rm_alert`.
  static const ReadModelTable alert = ReadModelTable(
    name: 'rm_alert',
    keyColumns: <String>['mode', 'alert_id'],
    columns: <ReadModelColumn>[
      ReadModelColumn('alert_id', ReadModelColumnType.text),
      ReadModelColumn('level', ReadModelColumnType.text),
      ReadModelColumn('raised_at', ReadModelColumnType.text),
      ReadModelColumn('code', ReadModelColumnType.text),
      ReadModelColumn('title', ReadModelColumnType.text),
      ReadModelColumn('body_text', ReadModelColumnType.text),
      ReadModelColumn('action_line', ReadModelColumnType.text),
      ReadModelColumn('grouped_count', ReadModelColumnType.bigint),
      ReadModelColumn('deep_link', ReadModelColumnType.text),
      ReadModelColumn('ack', ReadModelColumnType.jsonb),
      ReadModelColumn('raised_at_text', ReadModelColumnType.text),
      ReadModelColumn('grouped_text', ReadModelColumnType.text),
      ReadModelColumn('detail_deep_link', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'AlertItem',
        feeds: <String>['AlertRepository.watchInbox'],
      ),
    ],
  );

  /// `rm_safety_state`.
  static const ReadModelTable safetyState = ReadModelTable(
    name: 'rm_safety_state',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('breaker_level', ReadModelColumnType.text),
      ReadModelColumn('breaker_label', ReadModelColumnType.text),
      ReadModelColumn('drawdown', ReadModelColumnType.doublePrecision),
      ReadModelColumn('active_flags', ReadModelColumnType.jsonb),
      ReadModelColumn('kill_switch', ReadModelColumnType.jsonb),
      ReadModelColumn('stopped_release_eligible', ReadModelColumnType.boolean),
      ReadModelColumn('release_progress', ReadModelColumnType.jsonb),
      ReadModelColumn('alert_block_sat_entry', ReadModelColumnType.boolean),
      ReadModelColumn('ramp_level', ReadModelColumnType.text),
      ReadModelColumn('holds', ReadModelColumnType.jsonb),
      ReadModelColumn('hold_labels', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'SafetyState',
        feeds: <String>['SafetyRepository.watchState'],
      ),
    ],
  );

  /// `rm_config_view`.
  static const ReadModelTable configView = ReadModelTable(
    name: 'rm_config_view',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('satellite_enabled', ReadModelColumnType.boolean),
      ReadModelColumn('web_viewer_enabled', ReadModelColumnType.boolean),
      ReadModelColumn('calendar_enabled', ReadModelColumnType.boolean),
      ReadModelColumn('run_mode', ReadModelColumnType.text),
      ReadModelColumn(
        'operating_mode',
        ReadModelColumnType.text,
        checkValues: <String>['AUTO_TRADE', 'ADVISORY'],
      ),
      ReadModelColumn('config_hash', ReadModelColumnType.text),
      ReadModelColumn('contribution_amount', ReadModelColumnType.text),
      ReadModelColumn('contribution_amount_text', ReadModelColumnType.text),
      ReadModelColumn(
        'contribution_amount_input_text',
        ReadModelColumnType.text,
      ),
      ReadModelColumn(
        'contribution_equivalent_note_text',
        ReadModelColumnType.text,
      ),
      ReadModelColumn(
        'contribution_applies_from_text',
        ReadModelColumnType.text,
      ),
      ReadModelColumn(
        'contribution_last_changed_text',
        ReadModelColumnType.text,
      ),
      ReadModelColumn('contribution_as_of', ReadModelColumnType.jsonb),
      ReadModelColumn(
        'contribution_pension_limit_note_text',
        ReadModelColumnType.text,
      ),
      ReadModelColumn('allocation_label', ReadModelColumnType.text),
      ReadModelColumn('allocation_weights_text', ReadModelColumnType.text),
      ReadModelColumn('allocation_backtest_text', ReadModelColumnType.text),
      ReadModelColumn('allocation_honest_note_text', ReadModelColumnType.text),
      ReadModelColumn('allocation_sections', ReadModelColumnType.jsonb),
      ReadModelColumn(
        'allocation_change_path_lines',
        ReadModelColumnType.jsonb,
      ),
      ReadModelColumn('allocation_as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('sleeve_catalog', ReadModelColumnType.jsonb),
      ReadModelColumn('schema_version', ReadModelColumnType.bigint),
      ReadModelColumn('hash_format_version', ReadModelColumnType.bigint),
      ReadModelColumn('contract_version', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'FeatureFlags',
        feeds: <String>['ConfigRepository.watchFlags'],
      ),
      ReadModelBinding(
        'ContributionSetting',
        prefix: 'contribution_',
        feeds: <String>['ConfigRepository.watchContributionSetting'],
      ),
      ReadModelBinding(
        'AllocationEditorVm',
        prefix: 'allocation_',
        flatten: <String, String>{'current': 'AllocationProfileCard'},
        feeds: <String>['SettingsRepository.watchAllocationEditor'],
      ),
    ],
    extraColumns: <ReadModelExtraColumn>[
      ReadModelExtraColumn(
        'sleeve_catalog',
        '`ConfigRepository.watchSleeves` 목록 — `[SleeveCatalogEntry.toJson()]` 받은 순서(엔진)',
      ),
      ReadModelExtraColumn(
        'schema_version',
        '버전 스탬프(G-36) — 계약 `schemaVersion`(push 층 · 규칙 5조 ⑥)',
      ),
      ReadModelExtraColumn(
        'hash_format_version',
        '버전 스탬프(G-36) — 계약 `hashFormatVersion`(push 층)',
      ),
      ReadModelExtraColumn(
        'contract_version',
        '버전 스탬프(G-36) — 계약 `contractVersion`(push 층)',
      ),
    ],
  );

  /// `rm_advice`.
  static const ReadModelTable advice = ReadModelTable(
    name: 'rm_advice',
    keyColumns: <String>['mode', 'trade_date', 'advice_id'],
    columns: <ReadModelColumn>[
      ReadModelColumn('advice_id', ReadModelColumnType.text),
      ReadModelColumn('batch_id', ReadModelColumnType.text),
      ReadModelColumn('kind', ReadModelColumnType.text),
      ReadModelColumn('trade_date', ReadModelColumnType.text),
      ReadModelColumn('issued_at', ReadModelColumnType.text),
      ReadModelColumn('valid_until_date', ReadModelColumnType.text),
      ReadModelColumn('validity_label', ReadModelColumnType.text),
      ReadModelColumn('sleeve', ReadModelColumnType.text),
      ReadModelColumn('sizing_label', ReadModelColumnType.text),
      ReadModelColumn('progress_label', ReadModelColumnType.text),
      ReadModelColumn('reasons', ReadModelColumnType.jsonb),
      ReadModelColumn('status', ReadModelColumnType.text),
      ReadModelColumn('effective_status', ReadModelColumnType.text),
      ReadModelColumn('status_label', ReadModelColumnType.text),
      ReadModelColumn('status_tone', ReadModelColumnType.text),
      ReadModelColumn('recorded_deviation_chips', ReadModelColumnType.jsonb),
      ReadModelColumn('is_urgent', ReadModelColumnType.boolean),
      ReadModelColumn('on_hold', ReadModelColumnType.boolean),
      ReadModelColumn('decision', ReadModelColumnType.jsonb),
      ReadModelColumn('suppressed', ReadModelColumnType.boolean),
      ReadModelColumn('defer_available', ReadModelColumnType.boolean),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('phone_only_label', ReadModelColumnType.text),
      ReadModelColumn('close_reason_code', ReadModelColumnType.text),
      ReadModelColumn('depends_on_advice_id', ReadModelColumnType.text),
      ReadModelColumn('hold_reason_label', ReadModelColumnType.text),
      ReadModelColumn('account_alias', ReadModelColumnType.text),
      ReadModelColumn('suppressed_label', ReadModelColumnType.text),
      ReadModelColumn('detail_deep_link', ReadModelColumnType.text),
      ReadModelColumn('expired_confirm_label', ReadModelColumnType.text),
      ReadModelColumn('decision_link', ReadModelColumnType.jsonb),
      ReadModelColumn('close_reason_label', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'AdviceItem',
        excluded: <ReadModelExclusion>[
          ReadModelExclusion(
            'symbol',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice)',
          ),
          ReadModelExclusion(
            'symbol_label',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice)',
          ),
          ReadModelExclusion(
            'side',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice)',
          ),
          ReadModelExclusion(
            'side_label',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice)',
          ),
          ReadModelExclusion(
            'quantity',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice)',
          ),
          ReadModelExclusion(
            'price_band',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice)',
          ),
          ReadModelExclusion(
            'recorded_quantity',
            '🔴 A6 — 뷰어 판 null(0 을 채우면 «0주 기록됨» 거짓 · §10-7)',
          ),
          ReadModelExclusion(
            'prefill_quantity_text',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice) — 수기 입력 미리 채움 = 폰 전용',
          ),
          ReadModelExclusion(
            'prefill_quantity_label',
            '🔴 A6 마스킹 — 종목 · 방향 · 수량 · 가격은 읽기 모델에 싣지 않는다(01 §6-4 rm_advice) — 수기 입력 미리 채움 = 폰 전용',
          ),
          ReadModelExclusion(
            'actions',
            '뷰어 판 = 빈 목록(«부재» · G-22 · v1.12)',
            viewerValue: '[]',
          ),
        ],
        feeds: <String>[
          'AdviceRepository.watchInbox',
          'AdviceRepository.watchHistory',
          'AdviceRepository.findById',
        ],
      ),
    ],
    viewerVariants: <ReadModelViewerVariant>[
      ReadModelViewerVariant('sizing_label', '뷰어 판 글자(수량 0 — A6 · v1.12)'),
      ReadModelViewerVariant('progress_label', '뷰어 판 글자(수량 0 — A6)'),
    ],
    listCodes: <String>[
      'AdviceRepository.watchInbox',
      'AdviceRepository.watchHistory',
    ],
  );

  /// `rm_advice_summary`.
  static const ReadModelTable adviceSummary = ReadModelTable(
    name: 'rm_advice_summary',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('batch_id', ReadModelColumnType.text),
      ReadModelColumn('trade_date', ReadModelColumnType.text),
      ReadModelColumn('open_count', ReadModelColumnType.bigint),
      ReadModelColumn('due_today_count', ReadModelColumnType.bigint),
      ReadModelColumn('has_suppressed_notice', ReadModelColumnType.boolean),
      ReadModelColumn('overdue_unrecorded_count', ReadModelColumnType.bigint),
      ReadModelColumn('headline', ReadModelColumnType.text),
      ReadModelColumn('level', ReadModelColumnType.text),
      ReadModelColumn('handover_cooling_active', ReadModelColumnType.boolean),
      ReadModelColumn('trust', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('due_soon_label', ReadModelColumnType.text),
      ReadModelColumn('stale_reason_code', ReadModelColumnType.text),
      ReadModelColumn('stale_label', ReadModelColumnType.text),
      ReadModelColumn('handover_cooling_label', ReadModelColumnType.text),
      ReadModelColumn('cash_notice', ReadModelColumnType.jsonb),
      ReadModelColumn('overdue_unrecorded_link', ReadModelColumnType.jsonb),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'AdviceInboxSummary',
        excluded: <ReadModelExclusion>[
          ReadModelExclusion(
            'manual_entry_link',
            '수기 입력 = 폰 전용 — 뷰어 판 null(v1.12)',
          ),
          ReadModelExclusion(
            'manual_entry_notice_text',
            '수기 입력 = 폰 전용 — 뷰어 판 null(v1.12)',
          ),
        ],
        feeds: <String>['AdviceRepository.watchSummary'],
      ),
    ],
  );

  /// `rm_monthly_report`.
  static const ReadModelTable monthlyReport = ReadModelTable(
    name: 'rm_monthly_report',
    keyColumns: <String>['mode', 'yyyy_mm'],
    columns: <ReadModelColumn>[
      ReadModelColumn('yyyy_mm', ReadModelColumnType.text),
      ReadModelColumn('items', ReadModelColumnType.jsonb),
      ReadModelColumn('goal_line', ReadModelColumnType.text),
      ReadModelColumn('disclosure_view_count_text', ReadModelColumnType.text),
      ReadModelColumn('trust', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('after_tax', ReadModelColumnType.jsonb),
      ReadModelColumn('backdate_footnote', ReadModelColumnType.text),
      ReadModelColumn('pending_notice_text', ReadModelColumnType.text),
      ReadModelColumn('generated_at_text', ReadModelColumnType.text),
      ReadModelColumn('config_hash', ReadModelColumnType.text),
      ReadModelColumn('goal_deep_link', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'MonthlyReport',
        feeds: <String>['PerformanceRepository.monthlyReport'],
      ),
    ],
  );

  /// `rm_report_archive`.
  static const ReadModelTable reportArchive = ReadModelTable(
    name: 'rm_report_archive',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('rows', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('empty_label', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'ReportArchiveVm',
        feeds: <String>['PerformanceRepository.reportArchive'],
      ),
    ],
  );

  /// `rm_ledger_diff`.
  static const ReadModelTable ledgerDiff = ReadModelTable(
    name: 'rm_ledger_diff',
    keyColumns: <String>['mode', 'diff_id'],
    columns: <ReadModelColumn>[
      ReadModelColumn('diff_id', ReadModelColumnType.text),
      ReadModelColumn('pair', ReadModelColumnType.text),
      ReadModelColumn('axis', ReadModelColumnType.text),
      ReadModelColumn('authored_date', ReadModelColumnType.text),
      ReadModelColumn('delta_label', ReadModelColumnType.text),
      ReadModelColumn('severity', ReadModelColumnType.text),
      ReadModelColumn('candidate_origin_codes', ReadModelColumnType.jsonb),
      ReadModelColumn('status', ReadModelColumnType.text),
      ReadModelColumn('route', ReadModelColumnType.text),
      ReadModelColumn('evidence_hash', ReadModelColumnType.text),
      ReadModelColumn('applicable', ReadModelColumnType.boolean),
      ReadModelColumn('pair_label', ReadModelColumnType.text),
      ReadModelColumn('axis_label', ReadModelColumnType.text),
      ReadModelColumn('severity_label', ReadModelColumnType.text),
      ReadModelColumn('status_label', ReadModelColumnType.text),
      ReadModelColumn('route_label', ReadModelColumnType.text),
      ReadModelColumn('candidate_origins', ReadModelColumnType.jsonb),
      ReadModelColumn('detected_at_text', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'LedgerDiffRow',
        excluded: <ReadModelExclusion>[
          ReadModelExclusion(
            'action_link',
            '정정 = 폰 전용 — 뷰어 판 null(v1.12 §21-5-4)',
          ),
        ],
        feeds: <String>['LedgerRepository.watchOpenDiffs'],
      ),
    ],
    listCodes: <String>['LedgerRepository.watchOpenDiffs'],
  );

  /// `rm_sleeve_allocation`.
  static const ReadModelTable sleeveAllocation = ReadModelTable(
    name: 'rm_sleeve_allocation',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('rows', ReadModelColumnType.jsonb),
      ReadModelColumn('notice_text', ReadModelColumnType.text),
      ReadModelColumn('empty_label', ReadModelColumnType.text),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'SleeveAllocationVm',
        feeds: <String>['HoldingsRepository.watchAllocation'],
      ),
    ],
    viewerVariants: <ReadModelViewerVariant>[
      ReadModelViewerVariant(
        'rows[].deployed_text',
        '엔진 가림 글자(LEDGER_INTEGRITY «숨김»과 같은 글자 · 금액 0 — 04 §2-6 · DTO 칸은 non-null 그대로)',
      ),
      ReadModelViewerVariant('rows[].parking_text', '엔진 가림 글자(금액 0 — 04 §2-6)'),
    ],
  );

  /// `rm_perf_context`.
  static const ReadModelTable perfContext = ReadModelTable(
    name: 'rm_perf_context',
    keyColumns: <String>['mode', 'range_preset_code'],
    columns: <ReadModelColumn>[
      ReadModelColumn('range_preset_code', ReadModelColumnType.text),
      ReadModelColumn('drawdown_period_label', ReadModelColumnType.text),
      ReadModelColumn('drawdown_current_dd_text', ReadModelColumnType.text),
      ReadModelColumn('drawdown_max_dd_text', ReadModelColumnType.text),
      ReadModelColumn('drawdown_tuw_text', ReadModelColumnType.text),
      ReadModelColumn(
        'drawdown_dd_normalized',
        ReadModelColumnType.doublePrecision,
      ),
      ReadModelColumn('drawdown_as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('drawdown_reference_band_text', ReadModelColumnType.text),
      ReadModelColumn(
        'drawdown_reference_band_caveat_text',
        ReadModelColumnType.text,
      ),
      ReadModelColumn('contribution_period_label', ReadModelColumnType.text),
      ReadModelColumn('contribution_rows', ReadModelColumnType.jsonb),
      ReadModelColumn(
        'contribution_method_note_text',
        ReadModelColumnType.text,
      ),
      ReadModelColumn('contribution_as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('contribution_fx_note_text', ReadModelColumnType.text),
      ReadModelColumn('is_default', ReadModelColumnType.boolean),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'DrawdownContextVm',
        prefix: 'drawdown_',
        feeds: <String>['PerformanceRepository.drawdownContext'],
      ),
      ReadModelBinding(
        'ContributionVm',
        prefix: 'contribution_',
        feeds: <String>['PerformanceRepository.contribution'],
      ),
    ],
    extraColumns: <ReadModelExtraColumn>[
      ReadModelExtraColumn(
        'range_preset_code',
        '구간 프리셋 코드 — `DateRange.presetCode`(`watchRangePresets` 의 프리셋 · 사용자 지정 구간 = 행 없음)',
      ),
      ReadModelExtraColumn(
        'is_default',
        '엔진 기본 구간 표식 — `drawdownContext(range: null)` 의 행(한 모드에 참 하나)',
      ),
    ],
  );

  /// `rm_disclosure_view`.
  static const ReadModelTable disclosureView = ReadModelTable(
    name: 'rm_disclosure_view',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('gate_open', ReadModelColumnType.boolean),
      ReadModelColumn('headline', ReadModelColumnType.text),
      ReadModelColumn('view_count_text', ReadModelColumnType.text),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('friction_line', ReadModelColumnType.text),
      ReadModelColumn('route', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'DisclosureGateVm',
        feeds: <String>['PerformanceRepository.watchDisclosureGate'],
      ),
    ],
  );

  /// `rm_ops_summary`.
  static const ReadModelTable opsSummary = ReadModelTable(
    name: 'rm_ops_summary',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('today_orders_text', ReadModelColumnType.text),
      ReadModelColumn('today_errors_text', ReadModelColumnType.text),
      ReadModelColumn('signal_match_text', ReadModelColumnType.text),
      ReadModelColumn('streak_text', ReadModelColumnType.text),
      ReadModelColumn('discretion_budget_text', ReadModelColumnType.text),
      ReadModelColumn('next_rebalance_d_day_text', ReadModelColumnType.text),
      ReadModelColumn('upcoming', ReadModelColumnType.jsonb),
      ReadModelColumn('resume_line', ReadModelColumnType.jsonb),
      ReadModelColumn('rhythm', ReadModelColumnType.jsonb),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'OpsDailySummary',
        feeds: <String>['OpsStatusRepository.watchToday'],
      ),
    ],
    extraColumns: <ReadModelExtraColumn>[
      ReadModelExtraColumn(
        'rhythm',
        '`OpsStatusRepository.watchRhythm` 전체 목록 — `[OpsRhythmRow.toJson()]` 받은 순서(엔진 · v1.12 K29)',
      ),
    ],
    listCodes: <String>['OpsStatusRepository.watchRhythm'],
  );

  /// `rm_ledger_trust`.
  static const ReadModelTable ledgerTrust = ReadModelTable(
    name: 'rm_ledger_trust',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('grade', ReadModelColumnType.text),
      ReadModelColumn('level', ReadModelColumnType.text),
      ReadModelColumn('label', ReadModelColumnType.text),
      ReadModelColumn('consequence_line', ReadModelColumnType.text),
      ReadModelColumn('upgrade_hint', ReadModelColumnType.text),
      ReadModelColumn('last_verified_on', ReadModelColumnType.text),
      ReadModelColumn('action_deep_link', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'LedgerTrustBadge',
        feeds: <String>['LedgerTrustRepository.watchGrade'],
      ),
    ],
  );

  /// `rm_execution_gap`.
  static const ReadModelTable executionGap = ReadModelTable(
    name: 'rm_execution_gap',
    keyColumns: <String>['mode', 'yyyy_mm'],
    columns: <ReadModelColumn>[
      ReadModelColumn('yyyy_mm', ReadModelColumnType.text),
      ReadModelColumn('report', ReadModelColumnType.jsonb),
      ReadModelColumn('empty_kind', ReadModelColumnType.text),
      ReadModelColumn('empty_label', ReadModelColumnType.text),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('is_default', ReadModelColumnType.boolean),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'ExecutionGapResult',
        feeds: <String>['ExecutionGapRepository.monthly'],
      ),
    ],
    extraColumns: <ReadModelExtraColumn>[
      ReadModelExtraColumn(
        'yyyy_mm',
        '그 달(`yyyy-MM` · `monthly(yyyyMm:)` 인자와 같은 꼴)',
      ),
      ReadModelExtraColumn(
        'is_default',
        '엔진 기본 달 표식 — `monthly(yyyyMm: null)` 의 행(한 모드에 참 하나 · 06 X7-4)',
      ),
    ],
  );

  /// `rm_blind_review`.
  static const ReadModelTable blindReview = ReadModelTable(
    name: 'rm_blind_review',
    keyColumns: <String>['mode', 'decision_id'],
    columns: <ReadModelColumn>[
      ReadModelColumn('decision_id', ReadModelColumnType.text),
      ReadModelColumn('title_text', ReadModelColumnType.text),
      ReadModelColumn('prompt_text', ReadModelColumnType.text),
      ReadModelColumn('context_chips', ReadModelColumnType.jsonb),
      ReadModelColumn('deviation', ReadModelColumnType.jsonb),
      ReadModelColumn('journal_state_label', ReadModelColumnType.text),
      ReadModelColumn('journal', ReadModelColumnType.jsonb),
      ReadModelColumn('questions', ReadModelColumnType.jsonb),
      ReadModelColumn('result', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'BlindReviewCard',
        feeds: <String>[
          'JournalRepository.watchBlindReviewQueue',
          'JournalRepository.watchBlindReviewCard',
        ],
      ),
    ],
    listCodes: <String>['JournalRepository.watchBlindReviewQueue'],
  );

  /// `rm_watchdog`.
  static const ReadModelTable watchdog = ReadModelTable(
    name: 'rm_watchdog',
    keyColumns: <String>['mode'],
    columns: <ReadModelColumn>[
      ReadModelColumn('rows', ReadModelColumnType.jsonb),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('empty_label', ReadModelColumnType.text),
      ReadModelColumn('holiday_notice', ReadModelColumnType.text),
      ReadModelColumn('limit_notice', ReadModelColumnType.text),
      ReadModelColumn('last_received_text', ReadModelColumnType.text),
    ],
    bindings: <ReadModelBinding>[
      ReadModelBinding(
        'WatchdogBoardVm',
        feeds: <String>['OpsStatusRepository.watchWatchdog'],
      ),
    ],
  );

  /// `rm_list_envelope`.
  static const ReadModelTable listEnvelope = ReadModelTable(
    name: 'rm_list_envelope',
    keyColumns: <String>['mode', 'list_code'],
    columns: <ReadModelColumn>[
      ReadModelColumn('list_code', ReadModelColumnType.text),
      ReadModelColumn('as_of', ReadModelColumnType.jsonb),
      ReadModelColumn('empty_kind', ReadModelColumnType.text),
      ReadModelColumn('empty_label', ReadModelColumnType.text),
    ],
    extraColumns: <ReadModelExtraColumn>[
      ReadModelExtraColumn(
        'list_code',
        '목록 창구 이름 — `ReadModelListCodes`(«저장소.메서드»)',
      ),
      ReadModelExtraColumn('as_of', '`ListResult.asOf`(엔진)'),
      ReadModelExtraColumn('empty_kind', '`ListResult.emptyKind` 와이어(엔진)'),
      ReadModelExtraColumn(
        'empty_label',
        '`ListResult.emptyLabel`(엔진 · 없으면 null)',
      ),
    ],
  );

  /// 전부(이 차례 = 부트스트랩 출력 차례).
  static const List<ReadModelTable> all = <ReadModelTable>[
    journal,
    holding,
    performancePoint,
    performanceSeries,
    rebalanceEvent,
    alert,
    safetyState,
    configView,
    advice,
    adviceSummary,
    monthlyReport,
    reportArchive,
    ledgerDiff,
    sleeveAllocation,
    perfContext,
    disclosureView,
    opsSummary,
    ledgerTrust,
    executionGap,
    blindReview,
    watchdog,
    listEnvelope,
  ];
}
