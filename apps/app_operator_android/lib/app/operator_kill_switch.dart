// 🆕 E11q-b1a — M5-1 킬스위치 읽기 창구 operator 판(설계 13 §8 R178 · 01 §34 K146).
//
// 🔴 화면 상태의 원장 → data_sync 원천 → 엔진 VM(`killSwitchScreenVmOf`) · 원장 변경(`kill_switch_state` · `kill_switch_event`) ·
//    주기마다 다시 낸다(해제 시각 줄 · 관측 시각) · 같은 값 = 다시 내지 않음.
// 🔴 기록 폼 = 이 기기 id 가 있을 때만(쓰기 창구 = 명령 API) · 게이트 링크 = 레지스트리에 본문이 있을 때만.
// 🔵 M5-2 재개 게이트(`watchResumeGate`) = E11q-b1b — 지금 원천 없음.

import 'package:data_sync/data_sync.dart'
    show SqliteKillSwitchScreenSource, watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show KillResumeGateVm, KillSwitchGateRepository, KillSwitchScreenVm;

import 'operator_runtime.dart';
import 'operator_view.dart';
import 'view_stream.dart';

/// 킬스위치 화면 읽기(operator).
class OperatorKillSwitchGateRepository implements KillSwitchGateRepository {
  /// 만든다 — [hasBody] = 셸 레지스트리에 본문이 있나 · [tick] = 시간만 흐를 때 다시 읽는 주기.
  OperatorKillSwitchGateRepository(
    this._rt, {
    required this.hasBody,
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  /// 다시 읽는 주기.
  final Duration tick;

  KillSwitchScreenVm _read(OperatorView v) => SqliteKillSwitchScreenSource(
    v.db,
    clock: _rt.clock,
    trusted: _rt.trusted,
    canRecord: _rt.deviceId != null,
    hasBody: hasBody,
  ).screen();

  @override
  Stream<KillSwitchScreenVm> watchKillSwitch() =>
      followView<KillSwitchScreenVm>(
        view: _rt.view,
        changes: (OperatorView v) => watchLedgerQuery<KillSwitchScreenVm>(
          v.db,
          SqliteKillSwitchScreenSource.watchedTables,
          () => _read(v),
        ),
        now: _read,
        tick: tick,
        noView: () => StateError('킬스위치: 화면 상태 없음(온보딩 전)'),
      );

  @override
  Stream<KillResumeGateVm> watchResumeGate() => Stream<KillResumeGateVm>.error(
    UnsupportedError('watchResumeGate: 원천 없음(E11q-b1b)'),
  );
}
