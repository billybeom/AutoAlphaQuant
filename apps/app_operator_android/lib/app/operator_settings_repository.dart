// 설정 읽기 모델 operator 판 — 첫 칸 = M9 S02 키 목록(E11p3d-5d · 설계 13 §8 R129 · 앱 01 §29 · 06 M4-12 ⑦).
//
// 🔴 VM 짓기 · 글자 = 엔진(core `credentialListVmOf`) · 여기는 사실만 — 금고 저장 여부(`readKisCredentials` · 값은 읽지만 넘기지 않는다 ·
//    저장 여부만) + 마지막 검증 기록(sim 파일 온보딩 진척 o_02) + 실행 모드(화면 상태 · 없으면 = 모의).
// 🔴 다시 낸다 = 들을 때 · 진척 표 변경(검증 = 진척 기록 — 저장 뒤에 적으므로 다시 읽으면 금고도 새 값) · 1분 주기 · 화면 상태 변경 · 바뀐 값만.
// 🔴 나머지 창구(설정 홈 · 운영 · 계좌 매핑) = 원천 없음(오류 — 지어내지 않는다 · 그 화면은 미등록).

import 'dart:async';

import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentialRead, KisCredentialsStored, KisKeySet, readKisCredentials;
import 'package:core_engine/core_engine.dart'
    show PaperCredentialFacts, SecretVault, credentialListVmOf;
import 'package:data_sync/data_sync.dart'
    show
        OnboardingProgressRecord,
        SqliteOnboardingProgressStore,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AccountMappingVm,
        CredentialListVm,
        OperationsVm,
        RunMode,
        SettingsHomeVm,
        SettingsRepository;

import 'operator_runtime.dart';

/// 설정 읽기 모델(operator).
class OperatorSettingsRepository implements SettingsRepository {
  /// 만든다 — [tick] = 시간만 흐를 때 다시 읽는 주기.
  OperatorSettingsRepository(
    this._rt, {
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 다시 읽는 주기.
  final Duration tick;

  /// 지금 키 목록.
  Future<CredentialListVm> credentials() async {
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
    return credentialListVmOf(
      runMode: _rt.view.value?.flags.runMode ?? RunMode.simInternal,
      paper: PaperCredentialFacts(
        stored: stored,
        lastState: last?.state,
        lastAtUtc: last?.updatedAtUtc,
        lastFailureCode: last?.failureReasonCode,
      ),
      nowUtc: _rt.clock.nowUtc(),
    );
  }

  @override
  Stream<CredentialListVm> watchCredentials() {
    late final StreamController<CredentialListVm> c;
    StreamSubscription<int>? sub;
    Timer? timer;
    CredentialListVm? last;

    Future<void> refresh() async {
      try {
        final CredentialListVm v = await credentials();
        if (c.isClosed || v == last) return;
        last = v;
        c.add(v);
      } on Object catch (e, st) {
        if (!c.isClosed) c.addError(e, st);
      }
    }

    void onView() => unawaited(refresh());

    c = StreamController<CredentialListVm>(
      onListen: () {
        // 진척 표 지문(행 수 · 마지막 기록 시각) — 바뀐 값만 내는 감시라 지문을 읽는다.
        sub = watchLedgerQuery<int>(
          _rt.files.sim,
          const <String>{'onboarding_progress'},
          () => _rt.files.sim
              .select(
                'SELECT COUNT(*) AS n, MAX(updated_at) AS u FROM onboarding_progress',
              )
              .first
              .toString()
              .hashCode,
        ).skip(1).listen((_) => unawaited(refresh()));
        _rt.view.addListener(onView);
        timer = Timer.periodic(tick, (_) => unawaited(refresh()));
        unawaited(refresh());
      },
      onCancel: () async {
        _rt.view.removeListener(onView);
        timer?.cancel();
        await sub?.cancel();
        await c.close();
      },
    );
    return c.stream;
  }

  static Stream<T> _none<T>(String what) =>
      Stream<T>.error(UnsupportedError('$what: 원천 없음(R129)'));

  @override
  Stream<SettingsHomeVm> watchHome() => _none('watchHome');

  @override
  Stream<OperationsVm> watchOperations() => _none('watchOperations');

  @override
  Stream<AccountMappingVm> watchAccountMapping() =>
      _none('watchAccountMapping');
}
