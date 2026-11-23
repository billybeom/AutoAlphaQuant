-- 읽기 모델 rm_* 22표 — 계약 `ReadModelTables`(packages/domain_contracts/lib/src/schema/read_model_tables.dart)에서 생성.
-- 🔴 손으로 고치지 않는다 — 다시 뽑기 = packages/data_sync: dart run tool/gen_supabase_read_models.dart
-- 🔴 쓰기 정책 0(select 전용) — 쓰기 = operator 리스 epoch 를 검사하는 push RPC 1창구(E11l2).

-- rm_journal — 키 (mode, trade_date, entry_id) · 결속 TradeJournalEntry
create table if not exists rm_journal (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  entry_id text not null,
  trade_date text not null,
  executed_at text,
  symbol text,
  symbol_label text,
  sleeve text,
  side text,
  side_label text,
  quantity bigint,
  price text,
  commission text,
  tax text,
  quantity_text text,
  price_text text,
  commission_text text,
  tax_text text,
  status text,
  status_label text,
  status_tone text,
  visibility text,
  visibility_label text,
  reasons jsonb,
  decision jsonb,
  deviation jsonb,
  account_alias text,
  fill_origin text,
  fill_kind text,
  advice_id text,
  backdate jsonb,
  cost_source text,
  cost_source_label text,
  origin_label text,
  rebalance_event_id text,
  detail_deep_link text,
  as_of jsonb,
  primary key (mode, trade_date, entry_id)
);
alter table rm_journal enable row level security;
create policy rm_journal_select on rm_journal for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_holding — 키 (mode, trade_date, holding_id) · 결속 HoldingRow
create table if not exists rm_holding (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  trade_date text not null,
  symbol text,
  symbol_label text,
  sleeve text,
  account_alias text,
  quantity bigint,
  avg_price text,
  entry_date text,
  entry_decision jsonb,
  entry_reasons jsonb,
  sma_tranches jsonb,
  gates jsonb,
  stop_line jsonb,
  momentum jsonb,
  scope text,
  scope_label text,
  as_of jsonb,
  holding_id text not null,
  quantity_text text,
  avg_price_text text,
  weight_text text,
  pending_text text,
  sub_book_label text,
  detail_deep_link text,
  primary key (mode, trade_date, holding_id)
);
alter table rm_holding enable row level security;
create policy rm_holding_select on rm_holding for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_performance_point — 키 (mode, metric, granularity, cumulative, date) · 결속 PerfPoint
create table if not exists rm_performance_point (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  metric text not null,
  granularity text not null,
  cumulative boolean not null,
  date text not null,
  x_normalized double precision,
  date_text text,
  value_text text,
  y_normalized double precision,
  value double precision,
  gap_reason_code text,
  primary key (mode, metric, granularity, cumulative, date)
);
alter table rm_performance_point enable row level security;
create policy rm_performance_point_select on rm_performance_point for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_performance_series — 키 (mode, metric, granularity, cumulative) · 결속 PerformanceSeries
create table if not exists rm_performance_series (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  metric text not null,
  granularity text not null,
  cumulative boolean not null,
  segments jsonb,
  disclosure jsonb,
  as_of jsonb,
  series_label text,
  period_label text,
  y_ticks jsonb,
  unavailable_label text,
  benchmark jsonb,
  after_tax jsonb,
  primary key (mode, metric, granularity, cumulative)
);
alter table rm_performance_series enable row level security;
create policy rm_performance_series_select on rm_performance_series for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_rebalance_event — 키 (mode, event_id) · 결속 RebalanceEvent + JournalRebalanceScope(scope_)
create table if not exists rm_rebalance_event (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  event_id text not null,
  trade_date text,
  kind text,
  kind_label text,
  before jsonb,
  after jsonb,
  trigger jsonb,
  order_intent_ids jsonb,
  as_of jsonb,
  quality jsonb,
  thresholds jsonb,
  mode_label text,
  section_label text,
  journal_timeline_link jsonb,
  detail_deep_link text,
  scope_label text,
  scope_range jsonb,
  primary key (mode, event_id)
);
alter table rm_rebalance_event enable row level security;
create policy rm_rebalance_event_select on rm_rebalance_event for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_alert — 키 (mode, alert_id) · 결속 AlertItem
create table if not exists rm_alert (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  alert_id text not null,
  level text,
  raised_at text,
  code text,
  title text,
  body_text text,
  action_line text,
  grouped_count bigint,
  deep_link text,
  ack jsonb,
  raised_at_text text,
  grouped_text text,
  detail_deep_link text,
  primary key (mode, alert_id)
);
alter table rm_alert enable row level security;
create policy rm_alert_select on rm_alert for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_safety_state — 키 (mode) · 결속 SafetyState
create table if not exists rm_safety_state (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  breaker_level text,
  breaker_label text,
  drawdown double precision,
  active_flags jsonb,
  kill_switch jsonb,
  stopped_release_eligible boolean,
  release_progress jsonb,
  alert_block_sat_entry boolean,
  ramp_level text,
  holds jsonb,
  hold_labels jsonb,
  as_of jsonb,
  primary key (mode)
);
alter table rm_safety_state enable row level security;
create policy rm_safety_state_select on rm_safety_state for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_config_view — 키 (mode) · 결속 FeatureFlags + ContributionSetting(contribution_) + AllocationEditorVm(allocation_)
create table if not exists rm_config_view (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  satellite_enabled boolean,
  web_viewer_enabled boolean,
  calendar_enabled boolean,
  run_mode text,
  operating_mode text check (operating_mode in ('AUTO_TRADE', 'ADVISORY')),
  config_hash text,
  contribution_amount text,
  contribution_amount_text text,
  contribution_amount_input_text text,
  contribution_equivalent_note_text text,
  contribution_applies_from_text text,
  contribution_last_changed_text text,
  contribution_as_of jsonb,
  contribution_pension_limit_note_text text,
  allocation_label text,
  allocation_weights_text text,
  allocation_backtest_text text,
  allocation_honest_note_text text,
  allocation_sections jsonb,
  allocation_change_path_lines jsonb,
  allocation_as_of jsonb,
  sleeve_catalog jsonb,
  schema_version bigint,
  hash_format_version bigint,
  contract_version text,
  primary key (mode)
);
alter table rm_config_view enable row level security;
create policy rm_config_view_select on rm_config_view for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_advice — 키 (mode, trade_date, advice_id) · 결속 AdviceItem
create table if not exists rm_advice (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  advice_id text not null,
  batch_id text,
  kind text,
  trade_date text not null,
  issued_at text,
  valid_until_date text,
  validity_label text,
  sleeve text,
  sizing_label text,
  progress_label text,
  reasons jsonb,
  status text,
  effective_status text,
  status_label text,
  status_tone text,
  recorded_deviation_chips jsonb,
  is_urgent boolean,
  on_hold boolean,
  decision jsonb,
  suppressed boolean,
  defer_available boolean,
  as_of jsonb,
  phone_only_label text,
  close_reason_code text,
  depends_on_advice_id text,
  hold_reason_label text,
  account_alias text,
  suppressed_label text,
  detail_deep_link text,
  expired_confirm_label text,
  decision_link jsonb,
  close_reason_label text,
  primary key (mode, trade_date, advice_id)
);
alter table rm_advice enable row level security;
create policy rm_advice_select on rm_advice for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_advice_summary — 키 (mode) · 결속 AdviceInboxSummary
create table if not exists rm_advice_summary (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  batch_id text,
  trade_date text,
  open_count bigint,
  due_today_count bigint,
  has_suppressed_notice boolean,
  overdue_unrecorded_count bigint,
  headline text,
  level text,
  handover_cooling_active boolean,
  trust jsonb,
  as_of jsonb,
  due_soon_label text,
  stale_reason_code text,
  stale_label text,
  handover_cooling_label text,
  cash_notice jsonb,
  overdue_unrecorded_link jsonb,
  primary key (mode)
);
alter table rm_advice_summary enable row level security;
create policy rm_advice_summary_select on rm_advice_summary for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_monthly_report — 키 (mode, yyyy_mm) · 결속 MonthlyReport
create table if not exists rm_monthly_report (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  yyyy_mm text not null,
  items jsonb,
  goal_line text,
  disclosure_view_count_text text,
  trust jsonb,
  as_of jsonb,
  after_tax jsonb,
  backdate_footnote text,
  pending_notice_text text,
  generated_at_text text,
  config_hash text,
  goal_deep_link text,
  primary key (mode, yyyy_mm)
);
alter table rm_monthly_report enable row level security;
create policy rm_monthly_report_select on rm_monthly_report for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_report_archive — 키 (mode) · 결속 ReportArchiveVm
create table if not exists rm_report_archive (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  rows jsonb,
  as_of jsonb,
  empty_label text,
  primary key (mode)
);
alter table rm_report_archive enable row level security;
create policy rm_report_archive_select on rm_report_archive for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_ledger_diff — 키 (mode, diff_id) · 결속 LedgerDiffRow
create table if not exists rm_ledger_diff (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  diff_id text not null,
  pair text,
  axis text,
  authored_date text,
  delta_label text,
  severity text,
  candidate_origin_codes jsonb,
  status text,
  route text,
  evidence_hash text,
  applicable boolean,
  pair_label text,
  axis_label text,
  severity_label text,
  status_label text,
  route_label text,
  candidate_origins jsonb,
  detected_at_text text,
  primary key (mode, diff_id)
);
alter table rm_ledger_diff enable row level security;
create policy rm_ledger_diff_select on rm_ledger_diff for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_sleeve_allocation — 키 (mode) · 결속 SleeveAllocationVm
create table if not exists rm_sleeve_allocation (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  rows jsonb,
  notice_text text,
  empty_label text,
  as_of jsonb,
  primary key (mode)
);
alter table rm_sleeve_allocation enable row level security;
create policy rm_sleeve_allocation_select on rm_sleeve_allocation for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_perf_context — 키 (mode, range_preset_code) · 결속 DrawdownContextVm(drawdown_) + ContributionVm(contribution_)
create table if not exists rm_perf_context (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  range_preset_code text not null,
  drawdown_period_label text,
  drawdown_current_dd_text text,
  drawdown_max_dd_text text,
  drawdown_tuw_text text,
  drawdown_dd_normalized double precision,
  drawdown_as_of jsonb,
  drawdown_reference_band_text text,
  drawdown_reference_band_caveat_text text,
  contribution_period_label text,
  contribution_rows jsonb,
  contribution_method_note_text text,
  contribution_as_of jsonb,
  contribution_fx_note_text text,
  is_default boolean,
  primary key (mode, range_preset_code)
);
alter table rm_perf_context enable row level security;
create policy rm_perf_context_select on rm_perf_context for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_disclosure_view — 키 (mode) · 결속 DisclosureGateVm
create table if not exists rm_disclosure_view (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  gate_open boolean,
  headline text,
  view_count_text text,
  as_of jsonb,
  friction_line text,
  route text,
  primary key (mode)
);
alter table rm_disclosure_view enable row level security;
create policy rm_disclosure_view_select on rm_disclosure_view for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_ops_summary — 키 (mode) · 결속 OpsDailySummary
create table if not exists rm_ops_summary (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  as_of jsonb,
  today_orders_text text,
  today_errors_text text,
  signal_match_text text,
  streak_text text,
  discretion_budget_text text,
  next_rebalance_d_day_text text,
  upcoming jsonb,
  resume_line jsonb,
  rhythm jsonb,
  primary key (mode)
);
alter table rm_ops_summary enable row level security;
create policy rm_ops_summary_select on rm_ops_summary for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_ledger_trust — 키 (mode) · 결속 LedgerTrustBadge
create table if not exists rm_ledger_trust (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  grade text,
  level text,
  label text,
  consequence_line text,
  upgrade_hint text,
  last_verified_on text,
  action_deep_link text,
  primary key (mode)
);
alter table rm_ledger_trust enable row level security;
create policy rm_ledger_trust_select on rm_ledger_trust for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_execution_gap — 키 (mode, yyyy_mm) · 결속 ExecutionGapResult
create table if not exists rm_execution_gap (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  yyyy_mm text not null,
  report jsonb,
  empty_kind text,
  empty_label text,
  as_of jsonb,
  is_default boolean,
  primary key (mode, yyyy_mm)
);
alter table rm_execution_gap enable row level security;
create policy rm_execution_gap_select on rm_execution_gap for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_blind_review — 키 (mode, decision_id) · 결속 BlindReviewCard
create table if not exists rm_blind_review (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  decision_id text not null,
  title_text text,
  prompt_text text,
  context_chips jsonb,
  deviation jsonb,
  journal_state_label text,
  journal jsonb,
  questions jsonb,
  result jsonb,
  as_of jsonb,
  primary key (mode, decision_id)
);
alter table rm_blind_review enable row level security;
create policy rm_blind_review_select on rm_blind_review for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_watchdog — 키 (mode) · 결속 WatchdogBoardVm
create table if not exists rm_watchdog (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  rows jsonb,
  as_of jsonb,
  empty_label text,
  holiday_notice text,
  limit_notice text,
  last_received_text text,
  primary key (mode)
);
alter table rm_watchdog enable row level security;
create policy rm_watchdog_select on rm_watchdog for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));

-- rm_list_envelope — 키 (mode, list_code)
create table if not exists rm_list_envelope (
  row_version bigint not null,
  lease_epoch bigint not null,
  pushed_at timestamptz not null default now(),
  mode text not null check (mode in ('LIVE', 'SIM_INTERNAL', 'SIM_BROKER')),
  list_code text not null,
  as_of jsonb,
  empty_kind text,
  empty_label text,
  primary key (mode, list_code)
);
alter table rm_list_envelope enable row level security;
create policy rm_list_envelope_select on rm_list_envelope for select to authenticated
  using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE'));
