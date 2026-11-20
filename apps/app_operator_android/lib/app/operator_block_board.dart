// 🆕 E11q-b3 — M5-5 차단 보드 읽기 창구 operator 판(설계 13 §8 R185 · 01 §34 K154).
//
// 🔴 원천 = 홈 · 일지 · 분석과 같은 안전 상태 조립(`SqliteSafetyRepository.state()` — 같은 원장 · 같은 감시 표) → 엔진 VM
//    (`blockBoardVmOf`) · 원장 변경 · 주기마다 다시 낸다(냉각 게이지 · 관측 시각) · 같은 값 = 다시 내지 않음.
// 🔴 신뢰 시각 = 런타임 시계(M5-1 과 같은 원천 — 보드 냉각 게이지와 킬스위치 화면 해제 시각 줄이 어긋나지 않게).
// 🔴 행 링크 · 재개 결정 링크 = 레지스트리에 본문이 있을 때만(없는 화면으로 보내지 않는다) · 킬스위치 진입 = 늘.

import 'package:core_engine/core_engine.dart' show blockBoardVmOf;
import 'package:data_sync/data_sync.dart'
    show SqliteSafetyRepository, watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show BlockBoardRepository, BlockBoardVm;

import 'operator_runtime.dart';
import 'operator_view.dart';
import 'view_stream.dart';

/// 차단 보드 읽기(operator).
class OperatorBlockBoardRepository implements BlockBoardRepository {
  /// 만든다 — [hasBody] = 셸 레지스트리에 본문이 있나 · [tick] = 시간만 흐를 때 다시 읽는 주기.
  OperatorBlockBoardRepository(
    this._rt, {
    required this.hasBody,
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  /// 다시 읽는 주기.
  final Duration tick;

  BlockBoardVm _read(OperatorView v) => blockBoardVmOf(
    state: SqliteSafetyRepository(
      v.db,
      mode: v.flags.runMode,
      clock: _rt.clock,
      trusted: _rt.trusted,
    ).state(),
    hasBody: hasBody,
  );

  @override
  Stream<BlockBoardVm> watchBoard() => followView<BlockBoardVm>(
    view: _rt.view,
    changes: (OperatorView v) => watchLedgerQuery<BlockBoardVm>(
      v.db,
      SqliteSafetyRepository.watchedTables,
      () => _read(v),
    ),
    now: _read,
    tick: tick,
    noView: () => StateError('차단 보드: 화면 상태 없음(온보딩 전)'),
  );
}
