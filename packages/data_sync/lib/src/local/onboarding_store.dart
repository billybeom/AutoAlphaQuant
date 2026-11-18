// 온보딩 쓰기 — O-00b 운영 방식 선택 · 모의 개시(가상 초기금) · O-04 ⑥ 커밋(SPEC v2.44 02 §2-7 ⓐ · 01 §8-23 ·
// 앱 06 X6-5 ⓑ · 설계 13 §8 R80 D7 · D8 · D9 · D17 · R85 AA2~AA6).
//
// 🔴 sim 파일만 — 실전 원장(`ledger.sqlite`)에는 개시 행이 0 이다(X6-1 · 실전 개시 = simToAuto 커밋 E15f).
// 🔴 커밋 = 모드 행 · 전략 시딩 · `committed_at` 한 트랜잭션 — 실패하면 전부 되돌리고 `DRY_RUN_START_ROLLED_BACK`.
// 🔴 개시 행은 append-only — 두 번째 선언은 거부(고치려면 모의 원장 폐기 후 새 개시 · D9 와 같은 길).
// 🔴 첫 계획 = 커밋 뒤 첫 `monthly_rebalance` — 그때까지 가상 초기금은 현금으로 기다린다(R85 AA6).
// 🔵 결과 = 코드 + 엔진 문구 — `ActionResult` 로 감싸기 · 명령 접수는 조립(E11p).

import 'package:core_engine/core_engine.dart'
    show
        P0sStrategyIds,
        SimOpeningCodes,
        SimOpeningSplit,
        TierBCard,
        WhatIfConfig,
        kP0sSeedStrategies,
        kSeedCapitalCap,
        kSeedStrategyState,
        kstDateText,
        simOpeningDecisionId,
        simOpeningSplit,
        simTrialStartReject;
import 'package:domain_contracts/domain_contracts.dart'
    show
        Clock,
        DecisionReasonCodes,
        ExecPolicy,
        LedgerFile,
        OnboardingResultCodes,
        OperatingMode,
        RunMode,
        SelfReportBalance,
        SelfReportPurpose;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;
import 'mode_store.dart';

/// 시딩 전이 사유(`strategy_state_log.reason`).
const String kSimOpeningSeedReason = 'SIM_OPENING';

/// 온보딩 쓰기 결과 — 성공이면 [reasonCode] null.
class OnboardingOutcome {
  /// 성공.
  const OnboardingOutcome.ok(this.headline) : reasonCode = null;

  /// 거부(아무것도 쓰지 않았다).
  const OnboardingOutcome.no(String this.reasonCode, this.headline);

  /// 거부 코드.
  final String? reasonCode;

  /// 엔진 문구(화면은 그대로 그린다).
  final String headline;

  /// 성공했나.
  bool get ok => reasonCode == null;
}

/// 운영 방식 선택 행.
class OnboardingChoice {
  /// 행을 만든다.
  const OnboardingChoice({
    required this.operatingMode,
    required this.committed,
  });

  /// 고른 운영 방식.
  final OperatingMode operatingMode;

  /// `committed_at` 이 찼나(O-04 ⑥ 뒤).
  final bool committed;
}

String _modeLabel(OperatingMode m) => switch (m) {
  OperatingMode.autoTrade => '자동 매매',
  OperatingMode.advisory => '투자 안내',
};

String _won(int v) {
  final String s = v.toString();
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '$b원';
}

const Map<String, String> _rejectHeadline = <String, String>{
  SimOpeningCodes.notPositive: '가상 초기금은 0원보다 커야 합니다.',
  SimOpeningCodes.notWholeWon: '가상 초기금은 원 단위로 적어 주세요.',
  SimOpeningCodes.accountUnmapped: '전략의 계좌 대응이 비어 있어 가상 초기금을 나눌 수 없습니다.',
  SimOpeningCodes.linesNotAllowed: '자동 매매 모의 개시는 금액 한 칸만 받습니다.',
  SimOpeningCodes.wrongPurpose: '모의 개시 선언이 아닙니다.',
  SimOpeningCodes.alreadyDeclared:
      '가상 초기금은 이미 선언했습니다 — 바꾸려면 모의 원장을 폐기하고 새로 시작해야 합니다.',
  SimOpeningCodes.notDeclared: '가상 초기금을 먼저 선언해 주세요.',
  SimOpeningCodes.choiceMissing: '운영 방식을 먼저 골라 주세요.',
  SimOpeningCodes.advisoryNotReady: '투자 안내 모의 개시는 아직 준비되지 않았습니다.',
  SimOpeningCodes.tierBCardMissing: '계층 B 카드 값이 확정되지 않아 모의 체험을 시작할 수 없습니다.',
  OnboardingResultCodes.choiceCommitted:
      '모의투자를 이미 시작했습니다 — 이후 변경은 전환 위저드에서 합니다.',
};

OnboardingOutcome _no(String code) =>
    OnboardingOutcome.no(code, _rejectHeadline[code] ?? '요청을 처리하지 못했습니다.');

/// 🆕 E11p4f(R155) — 거부 코드 → 같은 사전의 엔진 문구 · 명령 구현이 저장소를 부르기 전에 거부할 때
/// (운영 방식 선택 전 · 계좌 대응 원천 없음 — 맥락 · 설정 판을 지어내지 않고 멈춘다).
OnboardingOutcome onboardingRejected(String code) => _no(code);

/// 온보딩 쓰기(sim 파일 하나).
final class SqliteOnboardingStore {
  /// 쓰기를 만든다 — 🔴 [db] 가 sim 파일이 아니면 열지 않는다(`application_id` 대조).
  SqliteOnboardingStore(this._db, {required this._clock})
    : _mode = SqliteModeStore(_db, LedgerFile.sim, clock: _clock);

  final Database _db;
  final Clock _clock;
  final SqliteModeStore _mode;

  /// 운영 방식 선택(없으면 null).
  OnboardingChoice? choice() {
    final Row? r = _db
        .select(
          'SELECT operating_mode, committed_at FROM onboarding_choice WHERE id = 1',
        )
        .firstOrNull;
    if (r == null) return null;
    return OnboardingChoice(
      operatingMode: OperatingMode.values.firstWhere(
        (OperatingMode m) => m.wire == r['operating_mode'],
      ),
      committed: r['committed_at'] != null,
    );
  }

  /// 개시 결정 id(선언 전 = null).
  String? openingDecisionId() =>
      _db.select(
            "SELECT decision_id FROM decision_log WHERE kind = 'MANUAL' AND reason_code = ? "
            'ORDER BY created_at LIMIT 1',
            <Object?>[DecisionReasonCodes.simOpeningBalance],
          ).firstOrNull?['decision_id']
          as String?;

  /// 🔴 O-00b — 운영 방식 선택(커밋 전이면 덮어쓴다 · 커밋 뒤 = `ONBOARDING_CHOICE_COMMITTED`).
  OnboardingOutcome selectOperatingMode(OperatingMode mode) =>
      inLedgerTransaction(_db, () {
        if (choice()?.committed ?? false) {
          return _no(OnboardingResultCodes.choiceCommitted);
        }
        _db.execute(
          'INSERT INTO onboarding_choice (id, operating_mode, chosen_at, committed_at) '
          'VALUES (1, ?, ?, NULL) ON CONFLICT(id) DO UPDATE SET '
          'operating_mode = excluded.operating_mode, chosen_at = excluded.chosen_at',
          <Object?>[mode.wire, _nowText()],
        );
        return OnboardingOutcome.ok('운영 방식을 «${_modeLabel(mode)}»(으)로 골랐습니다.');
      });

  /// 🔴 X6-5 ⓑ — 가상 초기금 선언(자동 매매 · `simInternal`) — 개시 결정 1행 + 계좌별 입금 행(한 트랜잭션).
  ///
  /// [accountByStrategy] = 주문 초안과 같은 대응(`DraftConfig.accountByStrategy`) · [configHash] = 지금 설정의 해시.
  OnboardingOutcome declareSimOpening(
    SelfReportBalance report, {
    required Map<String, String> accountByStrategy,
    required String configHash,
    WhatIfConfig? config,
  }) {
    if (report.purpose != SelfReportPurpose.simOpening) {
      return _no(SimOpeningCodes.wrongPurpose);
    }
    if (report.lines.isNotEmpty) return _no(SimOpeningCodes.linesNotAllowed);
    return inLedgerTransaction(_db, () {
      final OnboardingChoice? c = choice();
      if (c == null) return _no(SimOpeningCodes.choiceMissing);
      if (c.committed) return _no(OnboardingResultCodes.choiceCommitted);
      if (c.operatingMode == OperatingMode.advisory) {
        return _no(SimOpeningCodes.advisoryNotReady);
      }
      if (openingDecisionId() != null) {
        return _no(SimOpeningCodes.alreadyDeclared);
      }
      final SimOpeningSplit split = simOpeningSplit(
        cashKrw: report.cashKrw,
        weights: (config ?? WhatIfConfig.defaults).targetWeights,
        accountByStrategy: accountByStrategy,
      );
      if (split.reject != null) return _no(split.reject!);
      final String now = _nowText();
      final String id = simOpeningDecisionId(report.asOfTradeDate);
      _db.execute(
        'INSERT INTO decision_log (decision_id, created_at, trade_date, mode, kind, strategy_id, '
        'reason, reason_code, config_hash) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          id,
          now,
          report.asOfTradeDate.yyyyMmDd,
          RunMode.simInternal.wire,
          'MANUAL',
          P0sStrategyIds.deposit,
          '모의 개시 — 가상 초기금 선언',
          DecisionReasonCodes.simOpeningBalance,
          configHash,
        ],
      );
      int total = 0;
      for (final MapEntry<String, int> e in split.byAccount.entries) {
        total += e.value;
        _db.execute(
          'INSERT INTO cash_flow (flow_id, trade_date, amount, currency, kind, note, recorded_at, '
          "account_alias) VALUES (?, ?, ?, 'KRW', 'DEPOSIT', ?, ?, ?)",
          <Object?>[
            '$id-${e.key}',
            report.asOfTradeDate.yyyyMmDd,
            e.value.toDouble(),
            DecisionReasonCodes.simOpeningBalance,
            now,
            e.key,
          ],
        );
      }
      return OnboardingOutcome.ok(
        '가상 초기금 ${_won(total)}을 계좌 ${split.byAccount.length}곳에 나눠 넣었습니다.',
      );
    });
  }

  /// 🔴 O-04 ⑥ «DRY_RUN 시작» 커밋(D17 — 종착 = `simInternal × 선택한 운영 방식 × execute`) · 한 트랜잭션:
  /// 모드 행 + 전략 시딩(D8) + `committed_at`. 계층 B 카드가 없으면 거부(체험 시작 금지).
  OnboardingOutcome dryRunStart({required TierBCard? card}) {
    try {
      return inLedgerTransaction(_db, () {
        final OnboardingChoice? c = choice();
        if (c == null) return _no(SimOpeningCodes.choiceMissing);
        if (c.committed) return _no(OnboardingResultCodes.choiceCommitted);
        if (c.operatingMode == OperatingMode.advisory) {
          return _no(SimOpeningCodes.advisoryNotReady);
        }
        final String? decision = openingDecisionId();
        if (decision == null) return _no(SimOpeningCodes.notDeclared);
        final String? gate = simTrialStartReject(card: card);
        if (gate != null) return _no(gate);
        final String? denied = _mode.recordInTransaction(
          axis: ModeAxis.runMode,
          runMode: RunMode.simInternal,
          execPolicy: ExecPolicy.execute,
          operatingMode: c.operatingMode,
          handoverSessionValid: false,
          decisionId: decision,
        );
        if (denied != null) return _no(denied);
        final DateTime nowUtc = _clock.nowUtc();
        final String now = nowUtc.toUtc().toIso8601String();
        final String since = kstDateText(nowUtc);
        for (final String s in kP0sSeedStrategies) {
          _db.execute(
            'INSERT INTO strategy_state_current (strategy_id, state, since, capital_cap) VALUES (?, ?, ?, ?)',
            <Object?>[s, kSeedStrategyState, since, kSeedCapitalCap],
          );
          _db.execute(
            'INSERT INTO strategy_state_log (log_id, strategy_id, changed_at, from_state, to_state, reason) '
            'VALUES (?, ?, ?, NULL, ?, ?)',
            <Object?>[
              '$decision-$s',
              s,
              now,
              kSeedStrategyState,
              kSimOpeningSeedReason,
            ],
          );
        }
        _db.execute(
          'UPDATE onboarding_choice SET committed_at = ? WHERE id = 1 AND committed_at IS NULL',
          <Object?>[now],
        );
        if (_db.updatedRows != 1) {
          throw StateError('온보딩 선택 행을 커밋하지 못했다');
        }
        return const OnboardingOutcome.ok(
          '모의투자를 시작했습니다 — 첫 주문은 다음 정기 리밸런싱(월 마지막 거래일 다음 거래일 08:00)부터 나갑니다. '
          '그때까지 가상 초기금은 현금으로 기다립니다.',
        );
      });
    } on SqliteException {
      return const OnboardingOutcome.no(
        OnboardingResultCodes.dryRunStartRolledBack,
        '모의투자를 시작하지 못했습니다 — 바뀐 것은 없습니다. 다시 시도해 주세요.',
      );
    } on StateError {
      return const OnboardingOutcome.no(
        OnboardingResultCodes.dryRunStartRolledBack,
        '모의투자를 시작하지 못했습니다 — 바뀐 것은 없습니다. 다시 시도해 주세요.',
      );
    }
  }

  String _nowText() => _clock.nowUtc().toUtc().toIso8601String();
}
