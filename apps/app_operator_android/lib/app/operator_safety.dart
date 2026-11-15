// 안전 상태 원천 operator 판(E11p3d-3b · 설계 13 §8 R113 · 앱 01 §2-10 `SafetyRepository` · 엔진 R62 U1~U9).
//
// 🔴 원장 = 화면 상태가 고른 원장(엔진과 같은 연결) · 모드 = 그 원장의 실행 모드 · 신뢰 시각 = 모름(E11k 전 · R102 선례).
// 🔴 다시 낸다 = `followView`(R120 — 들을 때 · 감시 표 변경(`SqliteSafetyRepository.watchState`) · [OperatorSafetyRepository.tick] ·
//    화면 상태 변경 · 바뀐 값만) — 시간만 흐르는 몫 = R62 U9 «조립 앱의 주기 신호».
// 🔴 화면 상태가 없으면(온보딩 전) 오류 — 지어내지 않는다(일지 · 분석 = 배너 부재).
// 🔴 셸(H-01) · 일지 · 분석이 **한 인스턴스**를 쓴다 — 하나라도 빠지면 그 화면의 차단 배너가 소리 없이 사라진다(R113 ·
//    일지 화면은 안전 흐름을 `valueOrNull` 로 읽는다).

import 'package:data_sync/data_sync.dart' show SqliteSafetyRepository;
import 'package:domain_contracts/domain_contracts.dart'
    show SafetyRepository, SafetyState;

import '../engine/fgs_status_source.dart' show UnknownTrustedClock;
import 'operator_runtime.dart';
import 'operator_view.dart';
import 'view_stream.dart';

/// 안전 상태 원천(operator).
class OperatorSafetyRepository implements SafetyRepository {
  /// 만든다 — [tick] = 시간만 흐를 때 다시 계산하는 주기.
  OperatorSafetyRepository(this._rt, {this.tick = const Duration(minutes: 1)});

  final OperatorRuntime _rt;

  /// 다시 계산하는 주기.
  final Duration tick;

  SqliteSafetyRepository _repoOf(OperatorView v) => SqliteSafetyRepository(
    v.db,
    mode: v.flags.runMode,
    clock: _rt.clock,
    trusted: const UnknownTrustedClock(),
  );

  /// 지금 값 — 화면 상태 없음 = [StateError].
  SafetyState state() {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('안전 상태: 화면 상태 없음(온보딩 전)');
    return _repoOf(v).state();
  }

  @override
  Stream<SafetyState> watchState() => followView<SafetyState>(
    view: _rt.view,
    changes: (OperatorView v) => _repoOf(v).watchState(),
    now: (OperatorView v) => _repoOf(v).state(),
    tick: tick,
    noView: () => StateError('안전 상태: 화면 상태 없음(온보딩 전)'),
  );
}
