// 🆕 E11q-b2a — X2 재개 화면 읽기 창구 operator 판(설계 13 §8 R186 · 01 §31 K64 · §34 K156).
//
// 🔴 화면 상태의 원장 → data_sync 원천 → 엔진 VM(`resumeReportVmOf` · `resumeGateVmOf`) · 원장 변경(재개 표 · 차단 플래그) ·
//    주기마다 다시 낸다(관측 시각) · 같은 값 = 다시 내지 않음.
// 🔴 계절 3택 = 이번 조각에서는 내지 않는다([canChoose] = false — 고르는 쓰기(`SafetyActions.run(seasonalWindowChoice)` →
//    엔진 `ResumeJob.applySeasonalChoice`)는 다음 조각 E11q-b2b · 버튼이 서는데 눌러도 «제출하지 못했습니다»만 나오는 일을 막는다).
// 🔴 리포트 링크 = 레지스트리에 본문이 있을 때만.

import 'package:data_sync/data_sync.dart'
    show SqliteResumeScreenSource, watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show ResumeGateRepository, ResumeGateVm, ResumeReportVm;

import 'operator_runtime.dart';
import 'operator_view.dart';
import 'view_stream.dart';

/// X2 재개 화면 읽기(operator).
class OperatorResumeGateRepository implements ResumeGateRepository {
  /// 만든다 — [hasBody] = 셸 레지스트리에 본문이 있나 · [canChoose] = 계절 선택 쓰기 창구가 있나 ·
  /// [tick] = 시간만 흐를 때 다시 읽는 주기.
  OperatorResumeGateRepository(
    this._rt, {
    required this.hasBody,
    this.canChoose = false,
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  /// 계절 선택 쓰기 창구가 있나(E11q-b2b 전 = false).
  final bool canChoose;

  /// 다시 읽는 주기.
  final Duration tick;

  SqliteResumeScreenSource _src(OperatorView v) => SqliteResumeScreenSource(
    v.db,
    clock: _rt.clock,
    canChoose: canChoose,
    hasBody: hasBody,
  );

  Stream<T> _follow<T>(T Function(OperatorView v) read, String what) =>
      followView<T>(
        view: _rt.view,
        changes: (OperatorView v) => watchLedgerQuery<T>(
          v.db,
          SqliteResumeScreenSource.watchedTables,
          () => read(v),
        ),
        now: read,
        tick: tick,
        noView: () => StateError('$what: 화면 상태 없음(온보딩 전)'),
      );

  @override
  Stream<ResumeGateVm> watchGate() =>
      _follow<ResumeGateVm>((OperatorView v) => _src(v).gate(), '재개 게이트');

  @override
  Stream<ResumeReportVm> watchReport() =>
      _follow<ResumeReportVm>((OperatorView v) => _src(v).report(), '재개 리포트');
}
