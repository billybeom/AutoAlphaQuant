// 설정 · 온보딩 «동작» operator 판 — 첫 칸 = 키 검증 1단(E11p3d-5c · 설계 13 §8 R118 · 06 M4-4 v1.20 · M4-12 ⑤⑦ · 앱 01 §4-3).
//
// 🔴 `credentialVerify{kind}` = 검증 1단 — 슬롯 위젯(`KisKeySetField`)이 쥔 값을 넘김([SecretHandoff])으로 받아
//    ① 모의 서버 토큰 발급 ② 잔고 1쪽 조회(계좌 · 상품코드가 이 키와 맞는가) ③ 둘 다 통과 = 금고 저장 → 칸 비움.
//    🔴 저장은 통과 뒤에만(05 §4 원칙 4) · 값은 args · 결과 · 로그 어디에도 없다 · 실패 = 칸 그대로(다시 붙여넣지 않아도 된다).
// 🔴 모의 칸 검증은 모의 서버만 부른다 — 실전 도메인 호출 0(«다른 환경의 키» 판정 = 실전 세트가 생길 때 · 그 전 = 거절로 보인다).
// 🔴 같은 세트 검증이 진행 중이면 같은 결과를 기다린다(토큰 발급 1분 1회 · 두 번 누름 = 한 번 발급).
// 🔴 나머지 동작 = 아직 구현 없음 → `UnsupportedError`(지어내지 않는다 — 그 동작을 쓰는 화면은 아직 레지스트리에 없다).
// 🆕 E11p4b(R125) — `onboardingOperatingModeSelect{operating_mode}`(sim 파일 `onboarding_choice` · 확정 뒤 = 거부) ·
//    키 검증 결과를 온보딩 진척에 적는다(통과 = o_02 VERIFIED · 거절 = FAILED `CREDENTIAL_REJECTED` · 재시도 갈래 = 그대로).
//    결과 문장 = 표본 글자(core `kOnboardingMode*Text`) — sim 파일이 없으면(시험 · 화면 없는 조립) 이 두 몫은 빠진다.
// 🆕 E11q-c2(R201) — M9 S09 «지금 백업»(`backupRunNow{}`) = X1 스냅숏 `take`(`OperatorBackup` · 기기 안만) · 결과 = 엔진 글자.
// 🆕 E11k-c(R206 · 계약 v1.29 01 §39) — `connectionTest{target: SUPABASE}` = o_07 ② 연결 확인 1단: 슬롯 칸
//    (`SupabaseConnectField`)의 주소 · 공개 키를 넘김으로 받아 서버 시각 1회(data_sync `checkSupabaseConnection`) →
//    통과 = 금고 저장 → 칸 비움 → o_07 IN_PROGRESS(VERIFIED = 쓰기-읽기 왕복 뒤) → 신뢰 시각 바로 한 번 잼.
//    🔴 결과 글자 · 사유 코드 = 엔진(표본 그대로) · 금고 쓰기 = 통과 뒤에만 · 그 밖 대상 = 그대로 구현 없음.
// 🆕 E11k-d2(R216 · 계약 v1.31 01 §40) — `supabaseSignIn{}` = o_07 ③ 로그인 1단: 슬롯 칸(`SupabaseLoginPanel`)의 이메일 ·
//    비밀번호를 넘김으로 받아 `SupabaseAuth.signIn` → 🔴 통과 · 실패 모두 칸을 비운다(비밀번호를 오래 쥐지 않는다) ·
//    통과 = o_07 진행 중 그대로(VERIFIED 는 내리지 않음 · 확인 글자 «로그인됨» = 엔진 · 사실 = 세션) · 결과 = 엔진 표본 글자 ·
//    🆕 R276(미결 243 ⓔ · K349 ④) — 통과 뒤 공개 가입 확인 1회(열림 = `SUPABASE_SIGNUP_OPEN` · 결과 글자 = data_sync).
// 🆕 E11q-s05(R252 · 01 §28 K4 · K6 · K7) — M9 S05 동작 2:
//    · `runtimeModeSwitchRequest{run_mode: LIVE}` = M5-11 위저드로 넘김만(상태 변경 0 · 판정 · 생체 = 위저드 · 결과 = 엔진 표본 글자) ·
//      위저드 본문이 등록됐을 때만([modeSwitch]).
//    · `runtimeLivePromotion{}` = 엔진 승격 저장(생체 1회 · 리스 · 관찰 재판정 — [OperatorLivePromotion]).
//    🔴 운영 방식 전환 요청 · 엔진 시작 · 중지 = 그대로 구현 없음(미결 173 · VM 이 버튼을 싣지 않는다).

import 'dart:async';

import 'package:broker_gateway/broker_gateway.dart'
    show
        KisCredentialRead,
        KisCredentials,
        KisCredentialsStored,
        KisEnvironment,
        KisKeySet,
        KisOrderBroker,
        KisRejected,
        KisRestClient,
        KisTokenError,
        KisUnavailable,
        readKisCredentials,
        storeKisCredentials;
import 'package:core_engine/core_engine.dart'
    show
        SecretVault,
        contributionUpdateResultOf,
        kLiveKeyRegistryAlias,
        kOnboardingDryRunRolledBackText,
        kOnboardingDryRunStartedText,
        kOnboardingModeCommittedText,
        kOnboardingModeSelectedText,
        p0sTierBCard,
        runModeSwitchRequestedResultOf,
        selftestGoldenResultOf,
        selftestIntegrityResultOf;
import 'package:data_sync/data_sync.dart'
    show
        ContributionChangeResult,
        ContributionSettingSource,
        SupabaseAuth,
        SupabaseAuthResult,
        SupabaseConnectOutcome,
        SupabaseServerTime,
        checkSupabaseConnection,
        supabaseSignInOutcome,
        supabaseSignupOutcome,
        storeSupabaseConnection,
        LedgerIntegrityCheck,
        LedgerIntegrityReport,
        OnboardingOutcome,
        SqliteCredentialRegistry,
        SqliteOnboardingProgressStore,
        SqliteOnboardingStore;
import 'package:domain_contracts/domain_contracts.dart'
    show
        ActionResult,
        BrokerRawCodes,
        Clock,
        ConnectionTargetCodes,
        ContributionUpdateSubmission,
        OnboardingResultCodes,
        OperatingMode,
        RunMode,
        SettingsActionId,
        SettingsActions,
        StepState,
        UiLevel;
import 'package:sqlite3/sqlite3.dart' show Database;

import '../secret/secret_handoff.dart';
import 'operator_backup.dart' show OperatorBackup;
import 'operator_golden.dart' show OperatorGolden;
import 'operator_handover.dart' show OperatorHandover, kOperatorHandoverActions;
import 'operator_live_promotion.dart' show OperatorLivePromotion;

/// 검증 결과 문구(엔진 몫 — 화면은 그대로 그린다).
abstract final class CredentialVerifyText {
  /// 통과 · 저장.
  static const String saved = '검증을 통과해 저장했습니다. 다음 회차부터 이 키를 씁니다.';

  /// 🆕 R129 — 금고 키 다시 검증 통과(표본 `m9/credential_action_results` ar_s02_02).
  static const String reverified = '다시 검증했습니다 — 바뀐 것이 없습니다.';

  /// 🆕 R196 — 실전 계좌 거절(실전 세트).
  static const String accountRejectedLive =
      '계좌번호가 이 키와 맞지 않습니다. 실전 종합계좌번호(8자리)를 다시 확인하십시오.';

  /// 🆕 R196 — 실전 서버에 닿지 못함(실전 세트).
  static const String unreachableLive =
      'KIS 실전 서버에 닿지 못했습니다 — 연결을 확인한 뒤 다시 시도하십시오.';

  /// 🆕 R196 — 실전 서버 응답을 읽지 못함(실전 세트).
  static const String unreadableLive =
      'KIS 실전 서버의 응답을 읽지 못했습니다 — 잠시 뒤 다시 시도하십시오.';

  /// 칸이 화면에 없다.
  static const String noField = '키 입력 칸이 화면에 없습니다 — 키를 붙여넣는 화면에서 검증하십시오.';

  /// 칸이 덜 찼다.
  static const String incomplete =
      'APP Key · APP Secret · 계좌번호를 모두 붙여넣은 뒤 다시 검증하십시오.';

  /// 토큰 1분 1회.
  static const String rateLimited = '접근토큰은 1분에 한 번만 발급됩니다. 잠시 뒤 다시 시도하십시오.';

  /// 앱키 거절.
  static const String keyRejected = '앱키가 거절되었습니다. 발급 화면에서 키를 다시 확인하십시오.';

  /// 계좌 거절.
  static const String accountRejected =
      '계좌번호가 이 키와 맞지 않습니다. 모의투자 계좌번호를 다시 확인하십시오.';

  /// 닿지 못함.
  static const String unreachable =
      'KIS 모의 서버에 닿지 못했습니다 — 연결을 확인한 뒤 다시 시도하십시오.';

  /// 응답을 읽지 못함.
  static const String unreadable = 'KIS 모의 서버의 응답을 읽지 못했습니다 — 잠시 뒤 다시 시도하십시오.';

  /// 저장 실패.
  static const String saveFailed = '검증은 통과했지만 키 금고에 저장하지 못했습니다 — 다시 시도하십시오.';

  /// 아직 이 기기에 없는 세트.
  static const String setNotYet = '이 키 세트는 아직 이 기기에서 검증할 수 없습니다.';

  /// 🆕 R262(미결 233 ⓐ · 리뷰 3차 A-2) — 실전 칸에 위탁(01)이 아닌 상품코드를 붙여넣었다(서버 0 · 저장 0).
  static const String productNotGeneralLive =
      '실전 칸에는 위탁(01) 계좌번호를 넣습니다 — 연금저축(22)은 같은 종합계좌라 따로 넣지 않습니다. 계좌번호를 다시 붙여넣으십시오.';
}

/// 검증용 KIS 클라이언트를 만든다(시험 = 가짜 HTTP).
typedef KisVerifyClientOf = KisRestClient Function(KisCredentials credentials);

/// 설정 · 온보딩 «동작» operator 판.
class OperatorSettingsActions implements SettingsActions {
  /// 만든다.
  OperatorSettingsActions({
    required this.secrets,
    required this.vault,
    required this.clientOf,
    required this.clock,
    this.sim,
    this.ledger,
    this.golden,
    this.contribution,
    this.handover,
    this.backup,
    this.supabaseTime,
    this.refreshTrusted,
    this.supabaseAuth,
    this.modeSwitch = false,
    this.livePromotion,
    this.wake,
  });

  /// 🆕 리뷰 3차 H1-1(설계 13 §8 R261 · 01 §8 미결 235 ⓐ) — 엔진 깨어남 창구(실행 묶음 `wakeNow` · 없음 = 깨어남 0 — 시험 ·
  /// 화면 없는 조립).
  final Future<void> Function()? wake;

  /// 🆕 E11q-s05(R252) — 실전 전환 요청을 위저드로 넘기나(위저드 본문이 레지스트리에 있을 때만 · 아니면 구현 없음).
  final bool modeSwitch;

  /// 🆕 R252 — S05 승격(없음 = 생체 · 관찰 설정 없음 → 구현 없음).
  final OperatorLivePromotion? livePromotion;

  /// 🆕 E11k-d2(R216) — o_07 ③ 로그인(없음 = 로그인 구현 없음).
  final SupabaseAuth? supabaseAuth;

  /// 🆕 E11k-c(R206) — o_07 ② 연결 확인의 서버 시각(붙여 넣은 값으로 잼 · 없음 = 연결 확인 구현 없음).
  final SupabaseServerTime? supabaseTime;

  /// 🆕 R206 — 저장 뒤 신뢰 시각을 바로 한 번 잰다(실행 묶음 `refreshTrusted` · 없음 = 다음 주기에).
  final Future<bool> Function()? refreshTrusted;

  /// 🆕 R125 — 온보딩이 쓰는 sim 파일(없음 = 운영 방식 선택 · 진척 기록 없음).
  final Database? sim;

  /// 슬롯 위젯 ↔ 검증 넘김.
  final SecretHandoff secrets;

  /// 키 금고(저장 = 통과 뒤에만).
  final SecretVault vault;

  /// 검증 클라이언트.
  final KisVerifyClientOf clientOf;

  /// 결과 id 시각.
  final Clock clock;

  /// 🆕 E11p4k(R160) — 지금 화면이 읽는 원장(S10 무결성 자가진단 대상 · 화면 상태 없음 = null).
  final Database? Function()? ledger;

  /// 🆕 E11q3(R174) — S13 월 납입 쓰기 창구(지금 화면 원장 · 신뢰 시각 · 이 기기 id · 없으면 null = 화면 상태 · 기기 id 없음).
  final ContributionSettingSource? Function()? contribution;

  /// 🆕 E11o-d(R167) — 골든 기기 실행기(없음 = 바인딩 없음).
  final OperatorGolden? golden;

  /// 🆕 E11q-c1(R191) — M5-11 위저드 동작 4(S5 고름 · 세션 시작 · 취소 · 확정 관문 · 없음 = 바인딩 없음).
  final OperatorHandover? handover;

  /// 🆕 E11q-c2(R201) — M9 S09 «지금 백업»(없음 = 바인딩 없음).
  final OperatorBackup? backup;

  /// 🆕 R201 — «지금 백업»(X1 `take` · 결과 = 엔진 문장 · args = {} · 기록해 두고 `watch` 로 다시 준다).
  Future<ActionResult> _backupRun(OperatorBackup b, Map<String, String> args) {
    try {
      final ActionResult r = b.run(_runId(), args);
      _results[r.actionRunId] = r;
      return Future<ActionResult>.value(r);
    } on Object catch (e, st) {
      return Future<ActionResult>.error(e, st);
    }
  }

  /// 🆕 R167 — M9 S10 골든벡터 셀프테스트(엔진 실행기 · 백그라운드 · 기록 = 지금 화면 원장 · 결과 = 엔진 문장 · args = {}).
  Future<ActionResult> _goldenRun(
    OperatorGolden g,
    Database? Function() book,
    Map<String, String> args,
  ) async {
    if (args.isNotEmpty) throw ArgumentError('selftestGoldenRun args = {}');
    final Database? db = book();
    if (db == null) throw StateError('골든: 화면 상태 없음(온보딩 전)');
    final ActionResult r = selftestGoldenResultOf(
      actionRunId: _runId(),
      result: await g.run(db),
    );
    _results[r.actionRunId] = r;
    return r;
  }

  /// 🆕 R160 — M9 S10 무결성 자가진단(정본 자가 대조 · 엔진 `LedgerIntegrityCheck.run` · 불일치 = `LEDGER_INTEGRITY` 차단 ·
  /// 결과 = 엔진 문장 · args = {}).
  Future<ActionResult> _integrityRun(
    Database? Function() book,
    Map<String, String> args,
  ) {
    if (args.isNotEmpty) {
      return Future<ActionResult>.error(
        ArgumentError('selftestIntegrityRun args = {}'),
      );
    }
    final Database? db = book();
    if (db == null) {
      return Future<ActionResult>.error(StateError('무결성: 화면 상태 없음(온보딩 전)'));
    }
    final LedgerIntegrityReport rep = LedgerIntegrityCheck(
      db,
      clock: clock,
    ).run();
    final ActionResult r = selftestIntegrityResultOf(
      actionRunId: _runId(),
      reason: rep.verdict.reason,
    );
    _results[r.actionRunId] = r;
    return Future<ActionResult>.value(r);
  }

  final Map<String, ActionResult> _results = <String, ActionResult>{};
  final Map<KisKeySet, Future<ActionResult>> _inFlight =
      <KisKeySet, Future<ActionResult>>{};
  Future<ActionResult>? _supabaseInFlight;
  Future<ActionResult>? _signInInFlight;

  /// 🆕 R216 — o_07 ③ 로그인(🔴 비밀번호 = 이 호출에만 · 칸은 통과 · 실패 모두 비운다).
  Future<ActionResult> _supabaseSignIn(SupabaseAuth auth) async {
    const SettingsActionId id = SettingsActionId.supabaseSignIn;
    final ({String? email, String? password})? draft = secrets
        .supabaseLoginDraft();
    final SupabaseAuthResult r = await auth.signIn(
      email: draft?.email ?? '',
      password: draft?.password ?? '',
    );
    secrets.clearSupabaseLogin();
    // 🆕 미결 243 ⓔ(설계 13 §8 R276 · 계약 v1.39 K349 ④) — 로그인 통과 뒤 공개 가입 확인 1회(`/auth/v1/settings`):
    //    꺼짐 = 통과 글자 · 열림 = `SUPABASE_SIGNUP_OPEN` · 못 읽음 = 전송 글자(모름 = 통과 아님) · 🔴 로그인 상태 = 금고에 둔다(o_07 진행 중).
    final SupabaseConnectOutcome o = r.ok
        ? supabaseSignupOutcome(await auth.readSignup())
        : supabaseSignInOutcome(r.failure!);
    if (r.ok) {
      final Database? db = sim;
      if (db != null) {
        final SqliteOnboardingProgressStore store =
            SqliteOnboardingProgressStore(db, clock: clock);
        // 진행 중 그대로 다시 적는다(읽기 모델이 다시 짓게) — 🔴 VERIFIED 는 내리지 않는다.
        if (store.lastRecord('o_07')?.state != StepState.verified) {
          store.record('o_07', StepState.inProgress);
        }
      }
    }
    return _result(
      id,
      o.level,
      o.headline,
      reasonCode: o.reasonCode,
      retryable: o.retryable,
    );
  }

  /// 🆕 R206 — o_07 ② 연결 확인(입력 문제 = 망 0 · 통과 = 저장 → 칸 비움 → IN_PROGRESS → 신뢰 시각 잼).
  Future<ActionResult> _supabaseConnect(SupabaseServerTime time) async {
    const SettingsActionId id = SettingsActionId.connectionTest;
    final ({String? url, String? key})? draft = secrets.supabaseDraft();
    final SupabaseConnectOutcome o = await checkSupabaseConnection(
      time,
      url: draft?.url,
      key: draft?.key,
    );
    if (o.level == UiLevel.ok) {
      try {
        await storeSupabaseConnection(vault, url: draft!.url!, key: draft.key!);
      } on Object {
        return _result(
          id,
          UiLevel.blocked,
          CredentialVerifyText.saveFailed,
          retryable: true,
        );
      }
      secrets.clearSupabaseAfterSave();
      final Database? db = sim;
      if (db != null) {
        final SqliteOnboardingProgressStore store =
            SqliteOnboardingProgressStore(db, clock: clock);
        // 🔴 이미 VERIFIED(쓰기-읽기 왕복 — E11k-d · e 뒤)면 진행 중으로 내리지 않는다.
        if (store.lastRecord('o_07')?.state != StepState.verified) {
          store.record('o_07', StepState.inProgress);
        }
      }
      await refreshTrusted?.call();
    }
    return _result(
      id,
      o.level,
      o.headline,
      reasonCode: o.reasonCode,
      retryable: o.retryable,
    );
  }

  int _seq = 0;

  String _runId() => 'ar_op_${clock.nowUtc().microsecondsSinceEpoch}_${++_seq}';

  ActionResult _result(
    SettingsActionId id,
    UiLevel level,
    String headline, {
    String? reasonCode,
    bool retryable = false,
  }) {
    final ActionResult r = ActionResult(
      actionRunId: _runId(),
      id: id,
      level: level,
      headline: headline,
      reasonCode: reasonCode,
      retryable: retryable,
    );
    _results[r.actionRunId] = r;
    return r;
  }

  @override
  Future<ActionResult> run(
    SettingsActionId id, {
    Map<String, String> args = const <String, String>{},
  }) {
    if (id == SettingsActionId.credentialVerify) {
      return _credentialVerify(args);
    }
    final SupabaseAuth? auth = supabaseAuth;
    if (id == SettingsActionId.supabaseSignIn && auth != null) {
      if (args.isNotEmpty) {
        return Future<ActionResult>.error(
          ArgumentError('supabaseSignIn args = {}'),
        );
      }
      return _signInInFlight ??= _supabaseSignIn(auth).whenComplete(() {
        _signInInFlight = null;
      });
    }
    final SupabaseServerTime? supa = supabaseTime;
    if (id == SettingsActionId.connectionTest &&
        args['target'] == ConnectionTargetCodes.supabase &&
        supa != null) {
      if (args.length != 1) {
        return Future<ActionResult>.error(
          ArgumentError('connectionTest args = {target} 하나'),
        );
      }
      // 🔴 블록 몸통(KIS 와 같은 까닭 — 지운 Future 를 돌려주면 자기를 기다린다).
      return _supabaseInFlight ??= _supabaseConnect(supa).whenComplete(() {
        _supabaseInFlight = null;
      });
    }
    final Database? db = sim;
    if (id == SettingsActionId.onboardingOperatingModeSelect && db != null) {
      return _modeSelect(db, args);
    }
    if (id == SettingsActionId.onboardingDryRunStart && db != null) {
      return _dryRunStart(db, args);
    }
    final Database? Function()? book = ledger;
    if (id == SettingsActionId.selftestIntegrityRun && book != null) {
      return _integrityRun(book, args);
    }
    final OperatorGolden? g = golden;
    if (id == SettingsActionId.selftestGoldenRun && g != null && book != null) {
      return _goldenRun(g, book, args);
    }
    final OperatorHandover? h = handover;
    if (kOperatorHandoverActions.contains(id) && h != null) {
      return _handoverRun(h, id, args);
    }
    final OperatorBackup? bk = backup;
    if (id == SettingsActionId.backupRunNow && bk != null) {
      return _backupRun(bk, args);
    }
    if (id == SettingsActionId.runtimeModeSwitchRequest && modeSwitch) {
      return _modeSwitchRequest(args);
    }
    final OperatorLivePromotion? lp = livePromotion;
    if (id == SettingsActionId.runtimeLivePromotion && lp != null) {
      return _promote(lp, args);
    }
    return Future<ActionResult>.error(
      UnsupportedError('${id.name}: operator 구현 없음(R118)'),
    );
  }

  /// 🆕 R252 — 실전 전환 요청(args = `{run_mode: LIVE}` 하나 · 그 밖 = [ArgumentError]) → 위저드로 넘김(상태 변경 0).
  Future<ActionResult> _modeSwitchRequest(Map<String, String> args) {
    if (args.length != 1 || args['run_mode'] != RunMode.live.wire) {
      return Future<ActionResult>.error(
        ArgumentError('runtimeModeSwitchRequest args = {run_mode: LIVE} 하나'),
      );
    }
    final ActionResult r = runModeSwitchRequestedResultOf(
      actionRunId: _runId(),
    );
    _results[r.actionRunId] = r;
    return Future<ActionResult>.value(r);
  }

  /// 🆕 R252 — 승격(엔진 저장 · 결과 = 엔진 글자 · 기록해 두고 `watch` 로 다시 준다).
  Future<ActionResult> _promote(
    OperatorLivePromotion lp,
    Map<String, String> args,
  ) async {
    final ActionResult r = await lp.run(_runId(), args);
    _results[r.actionRunId] = r;
    return r;
  }

  /// 🆕 R191 — 위저드 동작(결과 = 엔진 글자 · 기록해 두고 `watch` 로 다시 준다).
  Future<ActionResult> _handoverRun(
    OperatorHandover h,
    SettingsActionId id,
    Map<String, String> args,
  ) async {
    final ActionResult r = await h.run(id, args);
    _results[r.actionRunId] = r;
    return r;
  }

  /// 🆕 계약 v1.23(01 §32 · K92) — `S13` 월 납입 제출 = 구현 없음(바인딩 = 06 `M4-12` ⑧ · 지어내지 않는다).
  @override
  Future<ActionResult> runContributionUpdate(
    ContributionUpdateSubmission submission,
  ) {
    // 🆕 E11q3(R174) — 판정 · 기록 · 문장 = 엔진(`ContributionSettingSource.change` · `contributionUpdateResultOf`) ·
    //    입력칸 글자 그대로 · 신뢰 시각을 모르면 `TRUSTED_TIME_UNKNOWN`(기기 시계로 대신 쓰지 않는다).
    final ContributionSettingSource? src = contribution?.call();
    if (src == null) {
      return Future<ActionResult>.error(
        StateError('월 납입: 쓰기 창구 없음(화면 상태 · 기기 id)'),
      );
    }
    final String run = _runId();
    final ContributionChangeResult r = src.change(
      amountInput: submission.amountInput,
      actionRunId: run,
    );
    final ActionResult out = contributionUpdateResultOf(
      actionRunId: run,
      reasonCode: r.reasonCode,
      rejectedText: r.rejectedText,
    );
    _results[out.actionRunId] = out;
    return Future<ActionResult>.value(out);
  }

  @override
  Stream<ActionResult> watch(String actionRunId) {
    final ActionResult? r = _results[actionRunId];
    return r == null
        ? Stream<ActionResult>.error(StateError('모르는 동작 id'))
        : Stream<ActionResult>.value(r);
  }

  Future<ActionResult> _credentialVerify(Map<String, String> args) {
    final String? kind = args['kind'];
    if (kind == null || args.length != 1) {
      return Future<ActionResult>.error(
        ArgumentError('credentialVerify args = {kind} 하나'),
      );
    }
    KisKeySet? set;
    for (final KisKeySet s in KisKeySet.values) {
      if (s.wire == kind) set = s;
    }
    if (set == null) {
      return Future<ActionResult>.value(
        _result(
          SettingsActionId.credentialVerify,
          UiLevel.blocked,
          CredentialVerifyText.setNotYet,
        ),
      );
    }
    final KisKeySet target = set;
    final Future<ActionResult>? running = _inFlight[target];
    if (running != null) return running;
    // 🔴 블록 몸통 — `=> _inFlight.remove(..)` 는 지운 Future(자기 자신)를 돌려줘 whenComplete 가 자기를 기다린다(교착).
    final Future<ActionResult> f = _verify(target).whenComplete(() {
      _inFlight.remove(target);
    });
    _inFlight[target] = f;
    return f;
  }

  Future<ActionResult> _verify(KisKeySet set) async {
    const SettingsActionId id = SettingsActionId.credentialVerify;
    final KisCredentials? draft = secrets.draftOf(set);
    // 🆕 E11p3d-5d(R129) — 새로 붙여넣은 값이 없으면 금고의 키를 «다시 검증»(저장 없음 · S02 OK 카드).
    final KisCredentials? creds = draft ?? await _stored(set);
    if (creds == null) {
      return secrets.isOnScreen(set)
          ? _result(id, UiLevel.act, CredentialVerifyText.incomplete)
          : _result(id, UiLevel.blocked, CredentialVerifyText.noField);
    }
    // 🆕 R262(A-2) — 실전 칸에 붙여넣은 키 = 위탁 01 만(칸이 먼저 막는다 · 여기는 다른 원천에도 지키는 두 번째 문) · 서버 0 · 저장 0 ·
    //    기록 0. 금고에 이미 든 키는 엔진이 일반 위탁 = 01 · 연금저축 = 22 로 갈음해 부른다(`liveAccountKeyOf`).
    if (draft != null &&
        set == KisKeySet.live &&
        draft.productCode != kKisGeneralProductCode) {
      return _result(
        id,
        UiLevel.act,
        CredentialVerifyText.productNotGeneralLive,
      );
    }
    final KisRestClient client = clientOf(creds);
    try {
      await client.token();
    } on KisTokenError catch (e) {
      if (e.rateLimited) {
        return _result(
          id,
          UiLevel.blocked,
          CredentialVerifyText.rateLimited,
          reasonCode: BrokerRawCodes.kisTokenRateLimited,
          retryable: true,
        );
      }
      if (e.status == null) {
        return _result(id, UiLevel.blocked, _unreachable(set), retryable: true);
      }
      await _rejected(set, draft: draft != null);
      return _result(
        id,
        UiLevel.blocked,
        CredentialVerifyText.keyRejected,
        reasonCode: OnboardingResultCodes.credentialRejected,
      );
    }
    try {
      await KisOrderBroker(client).orderableCashKrw();
    } on KisRejected {
      await _rejected(set, draft: draft != null);
      return _result(
        id,
        UiLevel.blocked,
        _accountRejected(set),
        reasonCode: OnboardingResultCodes.credentialRejected,
      );
    } on KisTokenError {
      return _result(id, UiLevel.blocked, _unreachable(set), retryable: true);
    } on KisUnavailable {
      return _result(id, UiLevel.blocked, _unreachable(set), retryable: true);
    } on FormatException {
      return _result(id, UiLevel.blocked, _unreadable(set), retryable: true);
    }
    if (draft == null) {
      // 금고 키 다시 검증 — 저장 · 칸 비움 없음.
      _progress(set, StepState.verified, null);
      return _result(id, UiLevel.info, CredentialVerifyText.reverified);
    }
    try {
      await storeKisCredentials(vault, set, draft);
    } on Object {
      return _result(
        id,
        UiLevel.blocked,
        CredentialVerifyText.saveFailed,
        retryable: true,
      );
    }
    secrets.clearAfterSave(set);
    _progress(set, StepState.verified, null);
    return _result(id, UiLevel.ok, CredentialVerifyText.saved);
  }

  /// 🆕 R129 — 금고에 저장된 그 세트의 키(없음 · 꼴 틀림 · 금고 오류 = null — 값은 검증 요청에만 쓰고 쥐지 않는다).
  Future<KisCredentials?> _stored(KisKeySet set) async {
    try {
      final KisCredentialRead r = await readKisCredentials(vault, set);
      return r is KisCredentialsStored ? r.credentials : null;
    } on Object {
      return null;
    }
  }

  /// 🆕 R125 — 세트 → 온보딩 단계(모의 = o_02 · 그 밖 = 단계 없음).
  static String? _stepOf(KisKeySet set) => switch (set) {
    KisKeySet.paper => 'o_02',
    KisKeySet.live || KisKeySet.isa => null,
  };

  /// 🆕 R196 — 세트 환경별 글자(모의 = 기존 표본 글자 그대로 · 실전 = 실전 글자).
  static String _accountRejected(KisKeySet set) =>
      set.environment == KisEnvironment.live
      ? CredentialVerifyText.accountRejectedLive
      : CredentialVerifyText.accountRejected;
  static String _unreachable(KisKeySet set) =>
      set.environment == KisEnvironment.live
      ? CredentialVerifyText.unreachableLive
      : CredentialVerifyText.unreachable;
  static String _unreadable(KisKeySet set) =>
      set.environment == KisEnvironment.live
      ? CredentialVerifyText.unreadableLive
      : CredentialVerifyText.unreadable;

  /// 🆕 R262(미결 233 ⓑ · 리뷰 3차 A-5) — 거절 기록. 금고 키 «다시 검증»의 거절 = 그 키가 거절됐다(INVALID) ·
  /// 새로 붙여넣은(저장 전) 키의 거절 = 금고에 쓸 키가 없을 때만 실전 기록을 적는다 — 금고에 키가 있거나 금고를 못 열어 모르면
  /// 그 키의 기록을 그대로 둔다(멀쩡한 금고 키를 INVALID 로 만들어 `LIVE_AWAITING_KEYS` 로 멈추지 않는다). 모의 o_02 = 그대로.
  Future<void> _rejected(KisKeySet set, {required bool draft}) async {
    const String code = OnboardingResultCodes.credentialRejected;
    final bool registry = !draft || await _vaultHasNoKey(set);
    _progress(set, StepState.failed, code, registry: registry);
  }

  /// 🆕 R262(A-5) — 금고에 그 세트의 쓸 키가 없다고 확실한가(칸 없음 · 꼴 틀림 = 참 · 금고 못 엶 = 모름 = 거짓).
  Future<bool> _vaultHasNoKey(KisKeySet set) async {
    try {
      return await readKisCredentials(vault, set) is! KisCredentialsStored;
    } on Object {
      return false;
    }
  }

  void _progress(
    KisKeySet set,
    StepState state,
    String? code, {
    bool registry = true,
  }) {
    if (registry) _registry(set, state);
    final Database? db = sim;
    final String? step = _stepOf(set);
    if (db == null || step == null) return;
    SqliteOnboardingProgressStore(
      db,
      clock: clock,
    ).record(step, state, failureReasonCode: code);
  }

  /// 🆕 R196(미결 207 ⓑ) — 실전 세트 검증 결과 = 지금 운영 원장의 `credential_registry`(값 0 · 통과 = OK · 거절 = INVALID) ·
  /// 화면 원장 없음 = 적지 않는다(검증 결과 글자는 그대로).
  void _registry(KisKeySet set, StepState state) {
    final String? alias = kLiveKeyRegistryAlias[set.wire];
    final Database? db = ledger?.call();
    if (alias == null || db == null) return;
    SqliteCredentialRegistry(db, clock: clock).recordVerification(
      alias: alias,
      kind: set.wire,
      keystoreRef: set.slotPrefix,
      passed: state == StepState.verified,
    );
  }

  Future<ActionResult> _modeSelect(Database db, Map<String, String> args) {
    const SettingsActionId id = SettingsActionId.onboardingOperatingModeSelect;
    final String? wire = args['operating_mode'];
    OperatingMode? mode;
    for (final OperatingMode m in OperatingMode.values) {
      if (m.wire == wire) mode = m;
    }
    if (mode == null || args.length != 1) {
      return Future<ActionResult>.error(
        ArgumentError(
          'onboardingOperatingModeSelect args = {operating_mode} 하나',
        ),
      );
    }
    final OnboardingOutcome out = SqliteOnboardingStore(
      db,
      clock: clock,
    ).selectOperatingMode(mode);
    return Future<ActionResult>.value(
      out.ok
          ? _result(id, UiLevel.ok, kOnboardingModeSelectedText)
          : _result(
              id,
              UiLevel.blocked,
              out.reasonCode == OnboardingResultCodes.choiceCommitted
                  ? kOnboardingModeCommittedText
                  : out.headline,
              reasonCode: out.reasonCode,
            ),
    );
  }

  /// 🆕 E11p4c(R127) — `onboardingDryRunStart{}` = 엔진 `dryRunStart`(모드 행 · 시딩 · committed_at 한 트랜잭션 · 계층 B 카드 = 엔진 값) ·
  /// 통과 · 되돌림 문장 = 표본 글자 · 앞 조건 거부(마무리 VM 이 동작을 내기 전에 막는 것들) = 엔진 문장 · 코드 그대로.
  Future<ActionResult> _dryRunStart(Database db, Map<String, String> args) {
    const SettingsActionId id = SettingsActionId.onboardingDryRunStart;
    if (args.isNotEmpty) {
      return Future<ActionResult>.error(
        ArgumentError('onboardingDryRunStart args = {}'),
      );
    }
    final OnboardingOutcome out = SqliteOnboardingStore(
      db,
      clock: clock,
    ).dryRunStart(card: p0sTierBCard());
    if (out.ok) {
      // 🆕 리뷰 3차 H1-1(R261 · 미결 235 ⓐ) — 엔진 깨어남 한 번(셸 플래그 · FGS — 다음 알람까지 뼈대로 두지 않는다 · 기다리지 않는다).
      final Future<void> Function()? w = wake;
      if (w != null) unawaited(w());
      return Future<ActionResult>.value(
        _result(id, UiLevel.ok, kOnboardingDryRunStartedText),
      );
    }
    final bool rolledBack =
        out.reasonCode == OnboardingResultCodes.dryRunStartRolledBack;
    return Future<ActionResult>.value(
      _result(
        id,
        UiLevel.blocked,
        rolledBack ? kOnboardingDryRunRolledBackText : out.headline,
        reasonCode: out.reasonCode,
      ),
    );
  }
}
