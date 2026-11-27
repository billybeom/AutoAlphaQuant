// E11q-q6 — `L-3` 정기 실사 operator 조립(앱 계약 01 §21-3 · §21-4 · 02 §3-10 · 엔진 = core `ops/self_report.dart` ·
// 원장 = data_sync `SqliteSelfReportSource`).
//
// 🔴 세션 = 이 폰 한 대 · 메모리(K9) — `SettingsActions` start 가 열고 stop 이 닫는다(앱이 죽으면 닫힌다 — «화면을 다시
//    여십시오» 문장과 같다) · 원장 표 0. 여는 판정 · 기준일 · 글자 = 엔진(`selfReportStartOf`) · 신뢰 시각 = E11k-a 관문.
// 🔴 세션이 열린 동안 이 폰의 보유(H6) · 일지(J) 원천이 «숨김»으로 낸다(엔진 가림 그대로 · 화면은 세션을 모른다) —
//    [OperatorSelfReportSessions.anyOpen] · 바뀜 = [OperatorSelfReportSessions.changes](감시 흐름이 곧바로 다시 읽는다).
// 🔴 읽기(`watch`) = 부작용 0(01 §1-4) · 제출 = 엔진 판정 → 원장 한 트랜잭션 → 세션 닫음(원장 값은 제출 뒤에 보인다).
// 🔴 접수증 글자 · 사유 코드 = 엔진(`selfReportReceiptOf` · 로컬 거부 = `INPUT_INVALID` 칸 글자) · 큐 적재 0(폰 안에서 끝난다).
// 🆕 R278(01 §8 미결 227) — 현금 축 = 엔진 판정(허용 오차 = 운영 설정 `self_report_cash_tolerance_krw` · 표식 = 0원 · 둘 다 없음 =
//    대조 안 함) · 원천 = ds `cashFactsOf` · 🆕 R281(미결 256 · 계약 v1.42) 판정 = 실사 행에 같이 적고 결과 빈 문장은 그 판정을
//    읽는다(`cashCheckOf` → `selfReportCashSkipOfCheck` — 나중 설정 · 표식으로 다시 정하지 않는다).
// 🆕 R280(01 §8 미결 226 · K320) — 다시 실사: 그 달 · 그 계좌 실사가 있어도 그 기준일 · 계좌에 열린 자가 보고 차이가 남았으면 세션을
//    연다(차이 행 «다시 실사하기» 목적지) · 세션이 열린 동안 = 폼(결과 0) · 기록 = 같은 트랜잭션에서 0오차 리셋 · 플래그 해제(대응 계좌).

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:core_engine/core_engine.dart'
    show
        P0sOpsConfig,
        SelfReportCashVerdict,
        SelfReportDiffRow,
        SelfReportInputInvalid,
        SelfReportOpenSession,
        SelfReportOutcome,
        SelfReportQuantityDiff,
        SelfReportStartOpen,
        SelfReportStartRefused,
        SelfReportStartVerdict,
        SelfReportTexts,
        SelfReportWireReady,
        SelfReportWireResult,
        SimOpeningCommand,
        selfReportAccountsOf,
        selfReportAlreadyAuditedOf,
        selfReportAsOfOf,
        selfReportCashDiffRowsOf,
        selfReportCashRecordOf,
        selfReportCashSkipOfCheck,
        selfReportCashToleranceOf,
        selfReportCashVerdictOf,
        selfReportDiffRowsOf,
        selfReportLedgerCashOf,
        selfReportNextAccountOf,
        selfReportQuantityDiffsOf,
        selfReportReceiptOf,
        selfReportResultOf,
        selfReportSessionVmOf,
        selfReportStartOf,
        selfReportStrategiesOf,
        selfReportSymbolsOf,
        selfReportWireOf;
import 'package:data_sync/data_sync.dart'
    show
        P0sHumanDecision,
        SqliteLeaseGate,
        SqliteLedgerTrustSource,
        SqliteSelfReportSource,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        ActionResult,
        AppRoutes,
        Clock,
        CommandContext,
        CommandReceipt,
        ContributionUpdateSubmission,
        LedgerTrustBadge,
        OperatingMode,
        SelfReportBalance,
        SelfReportCashCheck,
        SelfReportPurpose,
        SelfReportResult,
        SelfReportSession,
        SelfReportSubmission,
        SettingsActionId,
        SettingsActions,
        SymbolOption,
        TradeDate,
        UiLevel;

import 'operator_runtime.dart';
import 'operator_view.dart';
import 'view_stream.dart';

/// 실사 세션 장부 — 이 폰 한 대 · 메모리(키 = 그 달 · 그 계좌).
class OperatorSelfReportSessions {
  final Map<String, (String, String, SelfReportStartVerdict)> _byKey =
      <String, (String, String, SelfReportStartVerdict)>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  static String _key(String yyyyMm, String alias) =>
      jsonEncode(<String>[yyyyMm, alias]);

  /// 바뀔 때마다 한 번(열림 · 닫힘 · 거절 기록).
  Stream<void> get changes => _changes.stream;

  /// 이 폰에 열린 실사 세션이 하나라도 있나(가림 판정).
  bool anyOpen() => _byKey.values.any(
    ((String, String, SelfReportStartVerdict) e) => e.$3 is SelfReportStartOpen,
  );

  /// 그 달 · 그 계좌의 판정(없음 = 시작 전 · 닫힘).
  SelfReportStartVerdict? of(String yyyyMm, String alias) =>
      _byKey[_key(yyyyMm, alias)]?.$3;

  /// 그 달에 다른 계좌로 열린 세션이 있나.
  bool openOtherAccount(String yyyyMm, String alias) => _byKey.values.any(
    ((String, String, SelfReportStartVerdict) e) =>
        e.$1 == yyyyMm && e.$2 != alias && e.$3 is SelfReportStartOpen,
  );

  /// 판정을 적는다.
  void put(String yyyyMm, String alias, SelfReportStartVerdict v) {
    _byKey[_key(yyyyMm, alias)] = (yyyyMm, alias, v);
    if (!_changes.isClosed) _changes.add(null);
  }

  /// 닫는다(없으면 아무것도 안 함).
  void close(String yyyyMm, String alias) {
    if (_byKey.remove(_key(yyyyMm, alias)) != null && !_changes.isClosed) {
      _changes.add(null);
    }
  }

  /// 장부를 버린다(조립 묶음이 사라질 때 · 세션 전부 닫힘).
  void dispose() {
    _byKey.clear();
    unawaited(_changes.close());
  }
}

/// `L-3` 정기 실사 — 세션 여닫기(설정 동작) · 세션 VM 흐름 · 제출.
class OperatorSelfReport {
  /// 만든다 — [hasBody] = 셸 레지스트리에 본문이 있나(해소 링크 `M5-13`) · [tick] = 다시 읽는 주기.
  OperatorSelfReport(
    this._rt, {
    required this.hasBody,
    OperatorSelfReportSessions? sessions,
    this.tick = const Duration(minutes: 1),
  }) : sessions = sessions ?? OperatorSelfReportSessions();

  final OperatorRuntime _rt;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  /// 세션 장부(가림 판정이 같은 인스턴스를 읽는다).
  final OperatorSelfReportSessions sessions;

  /// 다시 읽는 주기.
  final Duration tick;

  static (String, String) _args(SettingsActionId id, Map<String, String> a) {
    final String? m = a['yyyy_mm'];
    final String? alias = a['account_alias'];
    if (a.length != 2 || m == null || alias == null) {
      throw ArgumentError('${id.name} args = {yyyy_mm, account_alias}');
    }
    return (m, alias);
  }

  Map<String, String> _accounts() =>
      _rt.humanDecision?.inputs.accountByStrategy ?? const <String, String>{};

  /// 🔴 세션 열기(K9 — 부른 그 자리에서 동기로 적는다: 화면이 곧바로 구독해도 열린 세션을 본다) · 결과 글자 = 엔진.
  ActionResult start(String actionRunId, Map<String, String> args) {
    final (String m, String alias) = _args(
      SettingsActionId.selfReportSessionStart,
      args,
    );
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('실사 세션: 화면 상태 없음(온보딩 전)');
    SelfReportStartVerdict verdict = selfReportStartOf(
      yyyyMm: m,
      accountAlias: alias,
      operatingMode: v.flags.operatingMode,
      accountByStrategy: _accounts(),
      trustedNowUtc: _rt.trusted.trustedNowUtc(),
      kr: _rt.calendars.kr,
    );
    final SqliteSelfReportSource src = SqliteSelfReportSource(
      v.db,
      clock: _rt.clock,
    );
    if (verdict is SelfReportStartOpen &&
        selfReportAlreadyAuditedOf(
          audited: src.auditedAccounts(verdict.asOf).contains(alias),
          openDiffs: src.openDiffsAt(verdict.asOf, alias),
        )) {
      verdict = SelfReportStartRefused(
        SelfReportTexts.alreadyAudited,
        asOf: verdict.asOf,
      );
    }
    sessions.put(m, alias, verdict);
    return switch (verdict) {
      SelfReportStartOpen() => ActionResult(
        actionRunId: actionRunId,
        id: SettingsActionId.selfReportSessionStart,
        level: UiLevel.ok,
        headline: SelfReportTexts.notice,
        retryable: false,
      ),
      SelfReportStartRefused(:final String text) => ActionResult(
        actionRunId: actionRunId,
        id: SettingsActionId.selfReportSessionStart,
        level: UiLevel.blocked,
        headline: text,
        retryable: false,
      ),
    };
  }

  /// 세션 닫기(이탈 · 화면 떠남 — 초안은 기기에 남는다).
  ActionResult stop(String actionRunId, Map<String, String> args) {
    final (String m, String alias) = _args(
      SettingsActionId.selfReportSessionStop,
      args,
    );
    sessions.close(m, alias);
    return ActionResult(
      actionRunId: actionRunId,
      id: SettingsActionId.selfReportSessionStop,
      level: UiLevel.info,
      headline: SelfReportTexts.sessionClosed,
      retryable: false,
    );
  }

  List<SymbolOption> _symbols(
    P0sHumanDecision? human,
    SqliteSelfReportSource src,
    List<String> strategies,
  ) => human == null
      ? const <SymbolOption>[]
      : selfReportSymbolsOf(
          P0sOpsConfig.of(human.inputs),
          held: src.heldSleeves(strategies),
        );

  /// 세션 VM(지금) — 부작용 0.
  SelfReportSession sessionOf(OperatorView v, String yyyyMm, String alias) {
    final P0sHumanDecision? human = _rt.humanDecision;
    final Map<String, String> accounts = _accounts();
    final SqliteSelfReportSource src = SqliteSelfReportSource(
      v.db,
      clock: _rt.clock,
    );
    final TradeDate? asOf = selfReportAsOfOf(yyyyMm, _rt.calendars.kr);
    final List<String> strategies = selfReportStrategiesOf(accounts, alias);
    final SelfReportStartVerdict? state = sessions.of(yyyyMm, alias);
    SelfReportResult? result;
    // 🆕 R280 — 다시 실사 세션이 열린 동안 = 폼(결과를 싣지 않는다 · 화면은 결과가 있으면 폼을 그리지 않는다).
    if (asOf != null && state is! SelfReportStartOpen) {
      final Set<String> audited = src.auditedAccounts(asOf);
      if (audited.contains(alias)) {
        result = selfReportResultOf(
          diffs: src.diffsOf(asOf, alias),
          yyyyMm: yyyyMm,
          nextAlias: selfReportNextAccountOf(
            accounts: selfReportAccountsOf(accounts),
            current: alias,
            audited: audited,
          ),
          resolveRegistered: hasBody(AppRoutes.m5SelfAuditResolve),
          cashSkipped: selfReportCashSkipOfCheck(src.cashCheckOf(asOf, alias)),
        );
      }
    }
    return selfReportSessionVmOf(
      yyyyMm: yyyyMm,
      accountAlias: alias,
      asOf: asOf,
      symbols: _symbols(human, src, strategies),
      closedText: switch (state) {
        SelfReportStartOpen() => null,
        SelfReportStartRefused(:final String text) => text,
        null => SelfReportTexts.sessionClosed,
      },
      result: result,
      lastVerifiedOn: src.lastVerifiedOn(alias),
      observedAtUtc: state is SelfReportStartOpen
          ? state.startedAtUtc
          : _rt.clock.nowUtc(),
    );
  }

  /// 🔴 세션 VM 흐름 — 원장 변경 · 세션 바뀜 · 주기마다 다시 읽는다(같은 값 = 다시 내지 않음).
  Stream<SelfReportSession> watch(String yyyyMm, String alias) =>
      followView<SelfReportSession>(
        view: _rt.view,
        changes: (OperatorView v) => mergeKicks<SelfReportSession>(
          watchLedgerQuery<SelfReportSession>(
            v.db,
            SqliteSelfReportSource.watchedTables,
            () => sessionOf(v, yyyyMm, alias),
          ),
          sessions.changes,
          () => sessionOf(v, yyyyMm, alias),
        ),
        now: (OperatorView v) => sessionOf(v, yyyyMm, alias),
        tick: tick,
        noView: () => StateError('원장 실사: 화면 상태 없음(온보딩 전)'),
      );

  /// 🔴 정기 실사 제출(01 §21-3 구현 의무 ① ②) — 차례 = 달 → 세션 → 운영 방식 → 원문 → 신뢰 시각 → 리스 → 무결성(보관) →
  /// 기록(한 트랜잭션 · 세션 닫음). 접수증 = 엔진.
  CommandReceipt submit(SelfReportSubmission s, {required Random random}) {
    if (s.purpose != SelfReportPurpose.periodicAudit) {
      throw ArgumentError.value(s.purpose, 'purpose', '정기 실사 제출이 아니다');
    }
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('원장 실사: 화면 상태 없음(온보딩 전)');
    final String? deviceId = _rt.deviceId;
    if (deviceId == null) throw StateError('원장 실사: 기기 id 없음');
    final SimOpeningCommand c = SimOpeningCommand.issue(
      deviceId: deviceId,
      nowUtc: _rt.clock.nowUtc(),
      random: random,
    );
    CommandReceipt outcome(SelfReportOutcome o) => selfReportReceiptOf(c, o);
    final String? m = s.yyyyMm;
    if (m == null) {
      return c.inputInvalid(
        SelfReportTexts.inputInvalid(SelfReportTexts.monthMissing),
      );
    }
    final String? alias = s.input.accountAlias;
    if (alias == null) {
      return c.inputInvalid(
        SelfReportTexts.inputInvalid(SelfReportTexts.accountMismatch),
      );
    }
    final SelfReportStartVerdict? state = sessions.of(m, alias);
    if (state is! SelfReportStartOpen) {
      return sessions.openOtherAccount(m, alias)
          ? c.inputInvalid(
              SelfReportTexts.inputInvalid(SelfReportTexts.accountMismatch),
            )
          : outcome(SelfReportOutcome.outsideSession);
    }
    final OperatingMode mode = v.flags.operatingMode;
    if (mode != OperatingMode.advisory) {
      return outcome(SelfReportOutcome.operatingModeMismatch);
    }
    final P0sHumanDecision? human = _rt.humanDecision;
    if (human == null) throw StateError('원장 실사: 계좌 대응 없음');
    final SqliteSelfReportSource src = SqliteSelfReportSource(
      v.db,
      clock: _rt.clock,
    );
    final List<String> strategies = selfReportStrategiesOf(
      human.inputs.accountByStrategy,
      alias,
    );
    final SqliteLeaseGate lease = SqliteLeaseGate(
      v.db,
      mode: v.flags.runMode,
      clock: _rt.clock,
    );
    final int epoch = lease.epoch();
    final SelfReportWireResult w = selfReportWireOf(
      s,
      session: SelfReportOpenSession(
        yyyyMm: m,
        accountAlias: alias,
        asOf: state.asOf,
        startedAtUtc: state.startedAtUtc,
      ),
      symbols: _symbols(human, src, strategies),
      context: CommandContext(
        runMode: v.flags.runMode,
        operatingMode: mode,
        leaseEpoch: epoch,
        deviceId: deviceId,
      ),
    );
    final SelfReportBalance wire;
    switch (w) {
      case SelfReportInputInvalid():
        return c.inputInvalid(w.stateLabel);
      case SelfReportWireReady():
        wire = w.wire;
    }
    final DateTime? trusted = _rt.trusted.trustedNowUtc();
    if (trusted == null) return outcome(SelfReportOutcome.trustedTimeUnknown);
    if (lease.sealed()) return outcome(SelfReportOutcome.leaseExpired);
    if (src.integrityBroken()) {
      final CommandReceipt held = outcome(SelfReportOutcome.held);
      src.hold(
        wire: wire,
        commandId: c.commandId,
        stateLabel: held.stateLabel,
        runMode: v.flags.runMode,
        operatingMode: mode,
        leaseEpoch: epoch,
      );
      return held;
    }
    final List<SelfReportQuantityDiff> diffs = selfReportQuantityDiffsOf(
      ledger: src.ledgerQuantities(state.asOf, strategies),
      reported: wire.lines,
    );
    // 🆕 R278 — 현금 축(K323): 허용 오차 = 표식이면 0원 · 아니면 운영 설정 값 · 없음 = 대조 안 함 · 원장 현금 모름 = 대조 안 함.
    final SelfReportCashVerdict cash = selfReportCashVerdictOf(
      toleranceKrw: selfReportCashToleranceOf(
        configuredKrw: _rt.operations?.selfReportCashToleranceKrw,
        patternMarker: src.patternUnverifiedStanding(),
      ),
      ledgerKrw: selfReportLedgerCashOf(src.cashFactsOf(state.asOf, alias)),
      reportedKrw: wire.cashKrw,
    );
    final ({SelfReportCashCheck check, double? toleranceKrw}) judged =
        selfReportCashRecordOf(cash);
    final CommandReceipt done = outcome(SelfReportOutcome.executed);
    src.record(
      wire: wire,
      commandId: c.commandId,
      deviceId: deviceId,
      reportedAtUtc: trusted,
      diffs: <SelfReportDiffRow>[
        ...selfReportDiffRowsOf(asOf: state.asOf, alias: alias, diffs: diffs),
        ...selfReportCashDiffRowsOf(
          asOf: state.asOf,
          alias: alias,
          verdict: cash,
        ),
      ],
      cashCheck: judged.check,
      cashToleranceKrw: judged.toleranceKrw,
      stateLabel: done.stateLabel,
      runMode: v.flags.runMode,
      operatingMode: mode,
      leaseEpoch: epoch,
      // 🆕 R280(K321 ④) — 플래그 해제 판정의 대응 계좌.
      accounts: selfReportAccountsOf(human.inputs.accountByStrategy),
    );
    sessions.close(m, alias);
    // 🆕 E11q-q6c(R240) — 실사 1회 = 그 계좌 갭이 기준일부터 다시 센다 → 표식을 곧바로 맞춘다(엔진 일정과 같은 판정).
    refreshSelfAudit(v, trusted);
    return done;
  }

  /// 🆕 E11q-q6c(R240) — 실사 예정 · 기한 표식 · 알림을 맞춘다(신뢰 시각 · 운영 방식 · 계좌 차례 = 엔진 판정).
  void refreshSelfAudit(OperatorView v, DateTime trustedNowUtc) =>
      SqliteLedgerTrustSource(v.db, clock: _rt.clock).refreshSelfAuditFor(
        operatingMode: v.flags.operatingMode,
        accounts: selfReportAccountsOf(_accounts()),
        trustedNowUtc: trustedNowUtc,
        kr: _rt.calendars.kr,
      );

  /// 🆕 E11q-q6c(R240) — 지금 신뢰 배지(01 §4-1 `watchGrade` · 홈 9b) — 투자 안내 = 실사 갭(엔진 · 신뢰 시각 · 모르면 갭을
  /// 세지 않는다) · 그 밖 = 브로커 대사 한 판정(월간 리포트와 같은 함수 · 지금까지). 읽기 = 부작용 0.
  LedgerTrustBadge gradeOf(OperatorView v) {
    final SqliteLedgerTrustSource src = SqliteLedgerTrustSource(
      v.db,
      clock: _rt.clock,
    );
    if (v.flags.operatingMode != OperatingMode.advisory) {
      return src.reconBadge(hasBody: hasBody);
    }
    return src.selfAuditBadge(
      accounts: selfReportAccountsOf(_accounts()),
      trustedNowUtc: _rt.trusted.trustedNowUtc(),
      kr: _rt.calendars.kr,
    );
  }

  /// 🆕 E11q-q6c — 배지 흐름(원장 변경 · 주기 — 갭은 시간만 흘러도 바뀐다 · 같은 값 = 다시 내지 않음).
  Stream<LedgerTrustBadge> watchGrade() => followView<LedgerTrustBadge>(
    view: _rt.view,
    changes: (OperatorView v) => watchLedgerQuery<LedgerTrustBadge>(
      v.db,
      SqliteLedgerTrustSource.watchedTables,
      () => gradeOf(v),
    ),
    now: gradeOf,
    tick: tick,
    noView: () => StateError('원장 신뢰 등급: 화면 상태 없음(온보딩 전)'),
  );
}

/// 🔴 `L-3` 화면 주입용 설정 동작 — 실사 세션 둘(`selfReportSessionStart` · `Stop`)만 · 그 밖 = 구현 없음(오류).
/// 부른 자리에서 동기로 적는다(화면 `initState` 가 곧바로 구독해도 열린 세션을 본다) · 결과 = 엔진 글자(화면은 읽지 않는다).
class OperatorSelfReportActions implements SettingsActions {
  /// 만든다.
  OperatorSelfReportActions(this._selfReport, {required this._clock});

  final OperatorSelfReport _selfReport;
  final Clock _clock;
  final Map<String, ActionResult> _results = <String, ActionResult>{};
  int _seq = 0;

  String _runId() =>
      'ar_sr_${_clock.nowUtc().microsecondsSinceEpoch}_${++_seq}';

  @override
  Future<ActionResult> run(
    SettingsActionId id, {
    Map<String, String> args = const <String, String>{},
  }) {
    try {
      // 🔴 `switch` 의 전부 받기(`_`) 금지(C-12) — 두 동작만 가르고 그 밖 = 구현 없음.
      final ActionResult r;
      if (id == SettingsActionId.selfReportSessionStart) {
        r = _selfReport.start(_runId(), args);
      } else if (id == SettingsActionId.selfReportSessionStop) {
        r = _selfReport.stop(_runId(), args);
      } else {
        throw UnsupportedError('${id.name}: 실사 화면 주입 밖');
      }
      _results[r.actionRunId] = r;
      return Future<ActionResult>.value(r);
    } on Object catch (e, st) {
      return Future<ActionResult>.error(e, st);
    }
  }

  @override
  Future<ActionResult> runContributionUpdate(
    ContributionUpdateSubmission submission,
  ) => Future<ActionResult>.error(
    UnsupportedError('runContributionUpdate: 실사 화면 주입 밖'),
  );

  @override
  Stream<ActionResult> watch(String actionRunId) {
    final ActionResult? r = _results[actionRunId];
    return r == null
        ? Stream<ActionResult>.error(StateError('모르는 동작 $actionRunId'))
        : Stream<ActionResult>.value(r);
  }
}

/// [source] 를 그대로 내고 [kicks] 가 올 때마다 [now] 를 한 번 더 낸다(던지면 오류로).
Stream<T> mergeKicks<T>(
  Stream<T> source,
  Stream<void> kicks,
  T Function() now,
) {
  late final StreamController<T> c;
  StreamSubscription<T>? a;
  StreamSubscription<void>? b;
  c = StreamController<T>(
    onListen: () {
      a = source.listen(c.add, onError: c.addError);
      b = kicks.listen((_) {
        try {
          c.add(now());
        } on Object catch (e, st) {
          c.addError(e, st);
        }
      });
    },
    onCancel: () async {
      await a?.cancel();
      await b?.cancel();
      await c.close();
    },
  );
  return c.stream;
}
