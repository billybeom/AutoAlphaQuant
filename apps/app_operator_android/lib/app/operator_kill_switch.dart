// 🆕 E11q-b1a — M5-1 킬스위치 읽기 창구 operator 판(설계 13 §8 R178 · 01 §34 K146).
//
// 🔴 화면 상태의 원장 → data_sync 원천 → 엔진 VM(`killSwitchScreenVmOf`) · 원장 변경(`kill_switch_state` · `kill_switch_event`) ·
//    주기마다 다시 낸다(해제 시각 줄 · 관측 시각) · 같은 값 = 다시 내지 않음.
// 🔴 기록 폼 = 이 기기 id 가 있을 때만(쓰기 창구 = 명령 API) · 게이트 링크 = 레지스트리에 본문이 있을 때만.
// 🆕 E11q-b1b — M5-2 재개 게이트(`watchResumeGate`) = 같은 원천 + 초안(구현이 든다 · [OperatorKillResumeDraft]) ·
//    초안이 바뀌거나 원장이 바뀌면 다시 낸다 · 🔴 다시 열 때(구독할 때) 4번 미충족 초안은 비운다(미결 184 ⑥ — 1번부터).

import 'dart:async';

import 'package:core_engine/core_engine.dart' show ResumeChecklist;
import 'package:data_sync/data_sync.dart'
    show KillResumeGateSource, SqliteKillSwitchScreenSource, watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show KillResumeGateVm, KillSwitchGateRepository, KillSwitchScreenVm;
import 'package:flutter/foundation.dart' show ValueNotifier;

import 'operator_runtime.dart';
import 'operator_view.dart';
import 'view_stream.dart';

/// 재개판 초안 — 이 앱 실행 동안만(앱 재시작 = 1번부터 · 미결 184 ⑤) · 문항 제출(`SafetyActions`)과 게이트 읽기가 같이 쓴다.
class OperatorKillResumeDraft extends ValueNotifier<ResumeChecklist> {
  /// 빈 초안으로 만든다.
  OperatorKillResumeDraft() : super(ResumeChecklist.empty);
}

/// 킬스위치 화면 읽기(operator).
class OperatorKillSwitchGateRepository implements KillSwitchGateRepository {
  /// 만든다 — [hasBody] = 셸 레지스트리에 본문이 있나 · [tick] = 시간만 흐를 때 다시 읽는 주기.
  OperatorKillSwitchGateRepository(
    this._rt, {
    required this.hasBody,
    OperatorKillResumeDraft? draft,
    this.tick = const Duration(minutes: 1),
  }) : draft = draft ?? OperatorKillResumeDraft();

  /// 재개판 초안(문항 제출과 같은 인스턴스).
  final OperatorKillResumeDraft draft;

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

  KillResumeGateVm _gate(OperatorView v) => SqliteKillSwitchScreenSource(
    v.db,
    clock: _rt.clock,
    trusted: _rt.trusted,
    canRecord: _rt.deviceId != null,
    hasBody: hasBody,
  ).gate(draft.value);

  /// 원장 변경 + 초안 변경 → 다시 읽기.
  Stream<KillResumeGateVm> _gateChanges(OperatorView v) {
    late final StreamController<KillResumeGateVm> c;
    StreamSubscription<KillResumeGateVm>? ledger;
    void onDraft() {
      if (!c.isClosed) c.add(_gate(v));
    }

    c = StreamController<KillResumeGateVm>(
      onListen: () {
        ledger = watchLedgerQuery<KillResumeGateVm>(
          v.db,
          SqliteKillSwitchScreenSource.watchedTables,
          () => _gate(v),
        ).listen(c.add, onError: c.addError);
        draft.addListener(onDraft);
      },
      onCancel: () async {
        draft.removeListener(onDraft);
        await ledger?.cancel();
        await c.close();
      },
    );
    return c.stream;
  }

  @override
  Stream<KillResumeGateVm> watchResumeGate() {
    // 다시 열 때 4번 미충족 초안을 비운다(1번부터).
    if (draft.value.conditionUnmet) draft.value = ResumeChecklist.empty;
    return followView<KillResumeGateVm>(
      view: _rt.view,
      changes: _gateChanges,
      now: _gate,
      tick: tick,
      noView: () => StateError('재개 게이트: 화면 상태 없음(온보딩 전)'),
    );
  }
}
