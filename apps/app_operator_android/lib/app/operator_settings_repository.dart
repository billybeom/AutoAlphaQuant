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
        PaperAccountFacts,
        PaperCredentialFacts,
        SecretVault,
        SettingsHomeFacts,
        accountMappingVmOf,
        contributionKstDay,
        contributionSettingOf,
        credentialListVmOf,
        settingsHomeVmOf;
import 'package:data_sync/data_sync.dart'
    show
        OnboardingProgressRecord,
        OpsConfigRead,
        OpsConfigReady,
        SqliteOnboardingProgressStore,
        contributionRowsOf,
        currentP0sOpsConfig,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AccountMappingVm,
        ContributionSetting,
        CredentialListVm,
        MonthlyContributionVm,
        OperationsVm,
        RunMode,
        SettingsHomeVm,
        SettingsRepository,
        StepState;
import 'package:sqlite3/sqlite3.dart' show Database;

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

    c = StreamController<T>(
      onListen: () {
        progress = _touches(_rt.files.sim, const <String>{
          'onboarding_progress',
        }).listen((_) => unawaited(refresh()));
        followLedger();
        _rt.view.addListener(onView);
        timer = Timer.periodic(tick, (_) => unawaited(refresh()));
        unawaited(refresh());
      },
      onCancel: () async {
        _rt.view.removeListener(onView);
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

  /// 🆕 계약 v1.23(01 §32 · K92) — `S13` 월 납입 투영 = 원천 없음(투영 + 잠김·버튼 칸 = 06 `M4-12` ⑧ · 그 화면은 레지스트리에 없다).
  @override
  Stream<MonthlyContributionVm> watchContribution() =>
      _none('watchContribution');
}
