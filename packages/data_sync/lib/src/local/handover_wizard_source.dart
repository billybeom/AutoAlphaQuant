// 🆕 E11q-c1 — M5-11 simToAuto 위저드 원천(설계 13 §8 R191 · 01 §35 K167~K176 · 미결 207 ⓓ).
//
// 🔴 판정 · 문장 = 엔진(`judgeSimToAuto` · `handoverWizardVmOf`) · 여기는 원장 원문만 모은다:
//    모의 파일 = 모드 · 닫힘 · 운영 방식 · 체험(`SqliteSimTrialFacts`) · S5 고름 · 킬스위치 · 차단 플래그 · SAF-405 승인 지문 ·
//    실전 파일 = 안 닫힌 simToAuto 세션(만료 포함 — 판정이 «기한 지남»을 말한다) · 확정 행(RUN_MODE) · 확정 세션.
// 🔴 바깥 사실(골든 · 실전 키 · 계좌 별칭 · 지금 설정 지문 · 쓰기 창구 · 잠김) = 조립 앱이 넣는다.
// 🔴 시각 — 판정 = 신뢰 시각(모르면 엔진이 «시각을 확인할 수 없어»로 말한다 · 기기 시계로 대신 쓰지 않는다 · K176) ·
//    관측(신선도) = 기기 시계.
// 🔴 실전 파일이 없으면 세션 0 · 확정 0(여기서 만들지 않는다 — 여는 자리 = 세션 시작 동작).

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        HandoverCloseCode,
        HandoverCommitted,
        HandoverSessionKind,
        HandoverSessionRecord,
        LiveObservationConfig,
        ModeRowFacts,
        SimLedgerFate,
        SimToAutoFacts,
        SimToAutoReport,
        SimTrialReport,
        TrustedClock,
        handoverWizardVmOf,
        judgeSimToAuto,
        judgeSimTrial,
        kNoApprovedConfig,
        killSwitchActive;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, FlagIds, HandoverPath, HandoverWizardVm, LedgerFile;
import 'package:sqlite3/sqlite3.dart';

import 'handover_session_store.dart' show SqliteHandoverSessionStore;
import 'kill_switch_store.dart' show readKillSwitchRecord;
import 'mode_store.dart' show SqliteModeStore;
import 'rule_change_store.dart' show SqliteRuleChangeStore;
import 'sim_ledger_fate_store.dart' show SqliteSimLedgerFateStore;
import 'sim_trial_facts.dart' show SqliteSimTrialFacts;

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

DateTime? _instant(Object? v) {
  if (v == null) return null;
  if (v is! String || !_offset.hasMatch(v)) {
    throw FormatException('handover_session 시각에 시차가 없다', v);
  }
  return DateTime.parse(v).toUtc();
}

/// M5-11 위저드 원천.
class SqliteHandoverWizardSource {
  /// 원천을 만든다 — 🔴 [sim] 이 모의 파일이 아니면 [StateError] · [live] = 실전 파일(아직 없음 = null).
  ///
  /// [goldenVectorPassed] · [liveKeysVerified] = 바깥 검사(null = 아직) · [accountByStrategy] = 지금 설정의 계좌 별칭 ·
  /// [currentConfigHash] = 지금 설정 지문(없음 = null) · [canAct] = 위저드 쓰기 창구가 있나 · [lockedLabel] = 운영 등급 축소.
  SqliteHandoverWizardSource({
    required Database sim,
    required this._live,
    required Clock clock,
    required this._trusted,
    required this._kr,
    required this._observation,
    required bool? goldenVectorPassed,
    required bool? liveKeysVerified,
    required Map<String, String> accountByStrategy,
    required String? currentConfigHash,
    required this._canAct,
    this._lockedLabel,
  }) : _sim = sim,
       _clock = clock,
       _golden = goldenVectorPassed,
       _liveKeys = liveKeysVerified,
       _accounts = Map<String, String>.unmodifiable(accountByStrategy),
       _configHash = currentConfigHash,
       _simMode = SqliteModeStore(sim, LedgerFile.sim, clock: clock);

  final Database _sim;
  final Database? _live;
  final Clock _clock;
  final TrustedClock _trusted;
  final ExchangeCalendar _kr;
  final LiveObservationConfig _observation;
  final bool? _golden;
  final bool? _liveKeys;
  final Map<String, String> _accounts;
  final String? _configHash;
  final bool _canAct;
  final String? _lockedLabel;
  final SqliteModeStore _simMode;

  /// 모의 파일에서 다시 낼 표(체험 입력 · 모드 · 고름 · 안전 · 승인).
  static const Set<String> simTables = <String>{
    'mode_transition',
    'decision_log',
    'job_run',
    'rebalance_event',
    'reconciliation_log',
    'ledger_diff',
    'resume_run',
    'kill_switch_event',
    'kill_switch_state',
    'alert_event',
    'intervention_step',
    'trading_block',
    'config_versions',
  };

  /// 실전 파일에서 다시 낼 표(세션 · 확정).
  static const Set<String> liveTables = <String>{
    'handover_session',
    'mode_transition',
  };

  SqliteHandoverSessionStore? get _sessions {
    final Database? l = _live;
    return l == null
        ? null
        : SqliteHandoverSessionStore(l, clock: _clock, trusted: _trusted);
  }

  /// 안 닫힌 simToAuto 세션(만료 포함 · 실전 파일 없음 = null) — 취소 · 확정 args 의 원천.
  HandoverSessionRecord? session() => _sessions?.simToAutoSession();

  /// 판정 입력 — [trustedNowUtc] = 판정 시각(신뢰 · 모름 = null) · [session] = 세션 칸 원천.
  SimToAutoFacts facts({
    required DateTime? trustedNowUtc,
    required HandoverSessionRecord? session,
  }) {
    final ModeRowFacts? m = _simMode.current();
    return SimToAutoFacts(
      trustedNowUtc: trustedNowUtc,
      simRunMode: m?.runMode,
      simClosed: _simMode.closed(),
      operatingMode: _simMode.operatingMode(),
      trial: trial(),
      goldenVectorPassed: _golden,
      liveKeysVerified: _liveKeys,
      accountByStrategy: _accounts,
      fate: fate(),
      sessionOpenedAtUtc: session?.openedAtUtc,
      killSwitchActive: killSwitchActive(readKillSwitchRecord(_sim)),
      blockingFlags: <String>[
        for (final Row r in _sim.select(
          'SELECT flag_id FROM trading_block WHERE flag_id <> ? ORDER BY flag_id',
          <Object?>[FlagIds.dstWeek],
        ))
          r['flag_id'] as String,
      ],
    );
  }

  /// 체험 판정(모의 파일).
  SimTrialReport trial() =>
      judgeSimTrial(SqliteSimTrialFacts(_sim, clock: _clock).read(), kr: _kr);

  /// S5 고름(아직 = null).
  SimLedgerFate? fate() =>
      SqliteSimLedgerFateStore(_sim, clock: _clock).current();

  /// 지금 판정(신뢰 시각 · 안 닫힌 세션).
  SimToAutoReport report() => judgeSimToAuto(
    facts(trustedNowUtc: _trusted.trustedNowUtc()?.toUtc(), session: session()),
    kr: _kr,
    observation: _observation,
  );

  /// SAF-405 — 지금 설정이 승인된 설정인가(모의 기간 = 모의 파일의 `config_versions`).
  bool configApproved() {
    final String? h = _configHash;
    if (h == null) return false;
    final String approved = SqliteRuleChangeStore(
      _sim,
      clock: _clock,
      trusted: _trusted,
    ).approvedConfigHash();
    return approved != kNoApprovedConfig && approved == h.trim();
  }

  /// 확정 뒤인가(실전 파일 RUN_MODE 행 있음) — 확정 세션 시각(없으면 null).
  HandoverCommitted? committed() {
    final Database? l = _live;
    if (l == null) return null;
    if (SqliteModeStore(l, LedgerFile.live, clock: _clock).current() == null) {
      return null;
    }
    final ResultSet rs = l.select(
      'SELECT opened_at, closed_at FROM handover_session '
      'WHERE kind = ? AND path = ? AND close_code = ? '
      'ORDER BY closed_at DESC, handover_session_id DESC LIMIT 1',
      <Object?>[
        HandoverSessionKind.wizard.wire,
        HandoverPath.simToAuto.wire,
        HandoverCloseCode.committed.wire,
      ],
    );
    if (rs.isEmpty) return const HandoverCommitted();
    return HandoverCommitted(
      openedAtUtc: _instant(rs.first['opened_at']),
      committedAtUtc: _instant(rs.first['closed_at']),
    );
  }

  /// M5-11 한 화면.
  HandoverWizardVm wizard() {
    final HandoverCommitted? done = committed();
    final HandoverSessionRecord? s = done == null ? session() : null;
    final DateTime? now = _trusted.trustedNowUtc()?.toUtc();
    final SimToAutoFacts f = facts(trustedNowUtc: now, session: s);
    return handoverWizardVmOf(
      report: judgeSimToAuto(f, kr: _kr, observation: _observation),
      trial: f.trial,
      fate: f.fate,
      sessionId: s?.sessionId,
      configApproved: configApproved(),
      canAct: _canAct,
      observedAtUtc: _clock.nowUtc(),
      lockedLabel: _lockedLabel,
      committed: done,
    );
  }
}
