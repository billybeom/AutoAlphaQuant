// 설정 읽기 모델 operator 판 — 첫 칸 = M9 S02 키 목록(E11p3d-5d · 설계 13 §8 R129 · 앱 01 §29 · 06 M4-12 ⑦).
//
// 🔴 VM 짓기 · 글자 = 엔진(core `credentialListVmOf`) · 여기는 사실만 — 금고 저장 여부(`readKisCredentials` · 값은 읽지만 넘기지 않는다 ·
//    저장 여부만) + 마지막 검증 기록(sim 파일 온보딩 진척 o_02) + 실행 모드(화면 상태 · 없으면 = 모의).
// 🔴 다시 낸다 = 들을 때 · 진척 표 변경(검증 = 진척 기록 — 저장 뒤에 적으므로 다시 읽으면 금고도 새 값) · 1분 주기 · 화면 상태 변경 · 바뀐 값만.
// 🆕 E11p3d-5e(R134) — M9 S01 설정 홈 = 엔진 `settingsHomeVmOf` · 사실 = 화면 상태(실행 모드 · 운영 방식 · 운영 설정 지문) +
//    키 목록(위와 같은 VM) + 월 납입 운영값(`operating_param_log`) + 레지스트리 본문 유무([hasBody] — 없는 화면으로 링크하지 않는다).
//    다시 낸다 = 키 목록과 같은 때 + 월 납입 기록 · 화면 상태 없음(온보딩 전) = 오류.
// 🔴 나머지 창구(운영 · 계좌 매핑) = 원천 없음(오류 — 지어내지 않는다 · 그 화면은 미등록).

import 'dart:async';

import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentialRead, KisCredentialsStored, KisKeySet, readKisCredentials;
import 'package:core_engine/core_engine.dart'
    show
        AccountMappingFacts,
        DiagnosticsScreenFacts,
        GoldenCardFacts,
        PaperAccountFacts,
        PaperCredentialFacts,
        SecretVault,
        SettingsHomeFacts,
        StoredLedgerDiff,
        accountMappingVmOf,
        contributionKstDay,
        contributionSettingOf,
        credentialListVmOf,
        diagnosticsScreenVmOf,
        kDeviceGoldenSuite,
        monthlyContributionVmOf,
        settingsHomeVmOf;
import 'package:data_sync/data_sync.dart'
    show
        LedgerDiagnosticsSource,
        OnboardingProgressRecord,
        OpsConfigRead,
        OpsConfigReady,
        SqliteOnboardingProgressStore,
        contributionRowsOf,
        currentP0sOpsConfig,
        kIntegrityOk,
        storedLedgerDiffs,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AccountMappingVm,
        ContributionSetting,
        CredentialListVm,
        DiagnosticsScreenVm,
        DiffStatus,
        FlagIds,
        MonthlyContributionVm,
        OperationsVm,
        RunMode,
        SettingsHomeVm,
        SettingsRepository,
        StepState;
import 'package:flutter/foundation.dart' show Listenable;
import 'package:sqlite3/sqlite3.dart' show Database, Row;

import 'operator_golden.dart' show GoldenPrepared, OperatorGolden;
import 'operator_runtime.dart';
import 'operator_view.dart';

bool _noBody(String _) => false;

/// 설정 읽기 모델(operator).
class OperatorSettingsRepository implements SettingsRepository {
  /// 만든다 — [tick] = 시간만 흐를 때 다시 읽는 주기 · [hasBody] = 조립 앱 레지스트리에 그 라우트의 본문이 있나(설정 홈 링크).
  OperatorSettingsRepository(
    this._rt, {
    this.tick = const Duration(minutes: 1),
    this.hasBody = _noBody,
  });

  final OperatorRuntime _rt;

  /// 다시 읽는 주기.
  final Duration tick;

  /// 🆕 R134 — 라우트 본문 유무(없으면 설정 홈 카드에 링크를 싣지 않는다).
  final bool Function(String route) hasBody;

  /// 🆕 R140 — 모의 키 세트 사실(금고 저장 여부 + 마지막 검증 기록) · 키 목록 · 연결 행(S07)이 같이 쓴다.
  Future<PaperCredentialFacts> paperFacts() async {
    final SecretVault? vault = _rt.vault;
    bool stored = false;
    if (vault != null) {
      try {
        final KisCredentialRead read = await readKisCredentials(
          vault,
          KisKeySet.paper,
        );
        stored = read is KisCredentialsStored;
      } on Object {
        stored = false;
      }
    }
    final OnboardingProgressRecord? last = SqliteOnboardingProgressStore(
      _rt.files.sim,
      clock: _rt.clock,
    ).lastRecord('o_02');
    return PaperCredentialFacts(
      stored: stored,
      lastState: last?.state,
      lastAtUtc: last?.updatedAtUtc,
      lastFailureCode: last?.failureReasonCode,
    );
  }

  /// 🆕 R151 — 모의 계좌 사실(금고의 모의 키 세트 번호 · 마지막 검증 통과 = 모의 서버 잔고 조회).
  Future<PaperAccountFacts> paperAccount() async {
    final SecretVault? vault = _rt.vault;
    String? no;
    String? product;
    if (vault != null) {
      try {
        final KisCredentialRead read = await readKisCredentials(
          vault,
          KisKeySet.paper,
        );
        if (read is KisCredentialsStored) {
          no = read.credentials.accountNo;
          product = read.credentials.productCode;
        }
      } on Object {
        no = null;
      }
    }
    final OnboardingProgressRecord? last = SqliteOnboardingProgressStore(
      _rt.files.sim,
      clock: _rt.clock,
    ).lastRecord('o_02');
    return PaperAccountFacts(
      accountNo: no,
      productCode: product,
      verifiedAtUtc: no != null && last?.state == StepState.verified
          ? last?.updatedAtUtc
          : null,
    );
  }

  /// 🆕 R151 — 지금 계좌 · 슬리브 매핑(화면 상태 없음 = 오류 · 운영 설정 없음 = 미지정).
  Future<AccountMappingVm> accountMapping() async {
    final OperatorView? v = _rt.view.value;
    if (v == null) {
      throw StateError('계좌: 화면 상태 없음(온보딩 전)');
    }
    final OpsConfigRead cfg = currentP0sOpsConfig(v.db);
    return accountMappingVmOf(
      AccountMappingFacts(
        paper: await paperAccount(),
        accountByStrategy: cfg is OpsConfigReady
            ? cfg.config.human.accountByStrategy
            : null,
        // 🆕 R154 — 정한 대응표(모의 개시 전) · 별칭 표시 글자.
        decidedByStrategy: _rt.humanDecision?.inputs.accountByStrategy,
        accountLabels:
            _rt.humanDecision?.accountLabels ?? const <String, String>{},
      ),
      nowUtc: _rt.clock.nowUtc(),
    );
  }

  /// 지금 키 목록.
  Future<CredentialListVm> credentials() async => credentialListVmOf(
    runMode: _rt.view.value?.flags.runMode ?? RunMode.simInternal,
    paper: await paperFacts(),
    nowUtc: _rt.clock.nowUtc(),
  );

  @override
  Stream<CredentialListVm> watchCredentials() => _follow(credentials);

  /// 🆕 R134 — 월 납입 운영값(엔진 `contributionSettingOf` · 읽기 실패 = 카드 상태 줄 없음 · 설정 홈 전체를 막지 않는다).
  ContributionSetting? _contributionOf(OperatorView v, DateTime now) {
    try {
      return contributionSettingOf(
        rows: contributionRowsOf(v.db),
        todayKst: contributionKstDay(now),
        observedAtUtc: now,
        kr: _rt.calendars.kr,
      );
    } on Object {
      return null;
    }
  }

  /// 🆕 R134 — 지금 설정 홈(화면 상태 없음 = 오류).
  Future<SettingsHomeVm> home() async {
    final OperatorView? v = _rt.view.value;
    if (v == null) {
      throw StateError('설정 홈: 화면 상태 없음(온보딩 전)');
    }
    final CredentialListVm creds = await credentials();
    final DateTime now = _rt.clock.nowUtc();
    return settingsHomeVmOf(
      SettingsHomeFacts(
        runMode: v.flags.runMode,
        operatingMode: v.flags.operatingMode,
        credentials: creds,
        contribution: _contributionOf(v, now),
        opsConfigReady: v.flags.configHash.isNotEmpty,
        hasBody: hasBody,
        // 🆕 R168 — 12월 연간 리뷰 카드(신뢰 시각 · 모름 = 카드 부재).
        trustedNowUtc: _rt.trusted.trustedNowUtc(),
      ),
      nowUtc: now,
    );
  }

  @override
  Stream<SettingsHomeVm> watchHome() =>
      _follow(home, viewTables: const <String>{'operating_param_log'});

  /// 표가 바뀔 때마다 한 번(값 = 매번 새 표지 — «바뀐 값만» 감시라 같은 값을 내지 않게) · 구독 첫 값은 건너뛴다.
  static Stream<Object> _touches(Database db, Set<String> tables) =>
      watchLedgerQuery<Object>(db, tables, Object.new).skip(1);

  /// 읽기 하나를 따라간다 — 들을 때 · sim 파일 진척 표(키 검증 기록) · 화면 상태 원장의 [viewTables] · [tick] 주기 ·
  /// 화면 상태 변경(원장 감시를 새 원장으로 옮긴다) · 바뀐 값만 · 읽기 실패 = 오류 한 번(다음 계기에 다시 읽는다).
  Stream<T> _follow<T>(
    Future<T> Function() read, {
    Set<String> viewTables = const <String>{},
    Listenable? also,
  }) {
    late final StreamController<T> c;
    StreamSubscription<Object>? progress;
    StreamSubscription<Object>? ledger;
    Timer? timer;
    T? last;
    bool has = false;

    Future<void> refresh() async {
      try {
        final T v = await read();
        if (c.isClosed || (has && v == last)) return;
        has = true;
        last = v;
        c.add(v);
      } on Object catch (e, st) {
        if (!c.isClosed) c.addError(e, st);
      }
    }

    void followLedger() {
      unawaited(ledger?.cancel());
      ledger = null;
      final OperatorView? v = _rt.view.value;
      if (v == null || viewTables.isEmpty) return;
      ledger = _touches(v.db, viewTables).listen((_) => unawaited(refresh()));
    }

    void onView() {
      followLedger();
      unawaited(refresh());
    }

    // 🆕 R167 — 장부 밖 사실이 바뀌면(골든 «실행 중») 다시 읽는다.
    void onAlso() => unawaited(refresh());

    c = StreamController<T>(
      onListen: () {
        progress = _touches(_rt.files.sim, const <String>{
          'onboarding_progress',
        }).listen((_) => unawaited(refresh()));
        followLedger();
        _rt.view.addListener(onView);
        also?.addListener(onAlso);
        timer = Timer.periodic(tick, (_) => unawaited(refresh()));
        unawaited(refresh());
      },
      onCancel: () async {
        _rt.view.removeListener(onView);
        also?.removeListener(onAlso);
        timer?.cancel();
        await progress?.cancel();
        await ledger?.cancel();
        await c.close();
      },
    );
    return c.stream;
  }

  static Stream<T> _none<T>(String what) =>
      Stream<T>.error(UnsupportedError('$what: 원천 없음(R129)'));

  @override
  Stream<OperationsVm> watchOperations() => _none('watchOperations');

  @override
  Stream<AccountMappingVm> watchAccountMapping() => _follow(
    accountMapping,
    viewTables: const <String>{'decision_log', 'config_versions'},
  );

  /// 🆕 E11q3(R174) — `S13` 월 납입 = 엔진 투영(`monthlyContributionVmOf` · 원천 = 셸 · 플래너와 같은 `contributionSettingOf`) ·
  /// 바꾸기 = 이 기기 id 가 있을 때만(쓰기 판정 · 문장 = 엔진 — 신뢰 시각을 모르면 `TRUSTED_TIME_UNKNOWN`) · 기록마다 · 주기마다.
  @override
  Stream<MonthlyContributionVm> watchContribution() => _follow(() async {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('월 납입: 화면 상태 없음(온보딩 전)');
    return monthlyContributionVmOf(
      contributionSettingOf(
        rows: contributionRowsOf(v.db),
        todayKst: contributionKstDay(_rt.clock.nowUtc()),
        observedAtUtc: _rt.clock.nowUtc(),
        kr: _rt.calendars.kr,
      ),
      canChange: _rt.deviceId != null,
    );
  }, viewTables: const <String>{'operating_param_log'});

  /// 🆕 계약 v1.24(01 §33 · K113) — `S10` 진단 화면 = 원천 없음(감싸개 VM 생산 = 엔진 `diagnosticsScreenVmOf` · 바인딩 = 06 `M4-12` ⑨ ·
  ///    그 화면은 레지스트리에 없다).
  @override
  Stream<DiagnosticsScreenVm> watchDiagnosticsScreen() => _follow(
    diagnosticsScreen,
    viewTables: const <String>{
      'ledger_diff',
      'reconciliation_log',
      'sync_state',
      'trading_block',
    },
    // 🆕 R167 — 골든 «실행 중»(기록 전 · 장부 밖).
    also: _rt.golden?.running,
  );

  /// 🆕 E11p4k(R160) — M9 S10 진단(감싸개 · 보드 = H-01 과 같은 엔진 원천 · 골든 = 실행기 전 판정 보류 · 화면 상태 없음 = 오류) ·
  /// 무결성 버튼 = 설정 동작이 있을 때만(금고 · 검증 HTTP — `operatorSettingsActionsProvider` 와 같은 조건).
  Future<DiagnosticsScreenVm> diagnosticsScreen() async {
    final OperatorView? v = _rt.view.value;
    if (v == null) {
      throw StateError('진단: 화면 상태 없음(온보딩 전)');
    }
    final Database db = v.db;
    // 🆕 R167 — 골든 자산(처음 한 번 · 못 읽으면 «판정 보류»).
    final OperatorGolden? g = _rt.golden;
    GoldenPrepared? prep;
    if (g != null) {
      try {
        prep = await g.prepare();
      } on Object {
        prep = null;
      }
    }
    final Row? ok = db.select(
      'SELECT run_at FROM reconciliation_log WHERE action_taken = ? '
      'ORDER BY run_at DESC LIMIT 1',
      <Object?>[kIntegrityOk],
    ).firstOrNull;
    return diagnosticsScreenVmOf(
      DiagnosticsScreenFacts(
        board: LedgerDiagnosticsSource(
          db,
          clock: _rt.clock,
          operatingMode: () => (_rt.view.value ?? v).flags.operatingMode,
        ).diagnostics(),
        lastIntegrityOkUtc: ok == null
            ? null
            : DateTime.parse(ok['run_at'] as String).toUtc(),
        integrityBlocked: db.select(
          'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
          <Object?>[FlagIds.ledgerIntegrity],
        ).isNotEmpty,
        openDiffs: storedLedgerDiffs(db).any(
          (StoredLedgerDiff d) => d.status == DiffStatus.open && d.applicable,
        ),
        canRun: _rt.vault != null && _rt.kisHttp != null,
        nowUtc: _rt.clock.nowUtc(),
        // 🆕 R167 — 골든 카드(실행기 «전량» · 자산 지문 · 이 원장의 마지막 기록 · 실행 중).
        golden: GoldenCardFacts(
          ready: kDeviceGoldenSuite.complete && prep != null,
          currentDigest: prep?.digest,
          last: OperatorGolden.lastRecord(db),
          running: g?.running.value ?? false,
          canRun: g != null && _rt.vault != null && _rt.kisHttp != null,
        ),
      ),
    );
  }
}
