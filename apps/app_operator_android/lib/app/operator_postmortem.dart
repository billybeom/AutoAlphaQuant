// 🆕 미결 243 ⓐ — `M5-4` 안전 사건 postmortem 읽기 창구 operator 판(설계 13 §8 R282 · R243 P4 · 계약 v1.39 K345).
//
// 🔴 원천 = 화면이 읽는 원장(엔진과 같은 연결)의 열린 사건 + 쓴 글(data_sync `openIncidentsOf`) → 엔진 `postmortemListVmOf`
//    (의무 건 고르기 · 차례 · 기한 · 글자 = 엔진 — 화면은 받은 그대로 그린다).
// 🔴 다시 낸다 = 들을 때 · 사건 표가 바뀔 때(같은 연결 `db.updates` — 쓰면 닫히거나 글이 실린다) · 화면 상태가 바뀔 때 · 주기([tick] —
//    기한이 지나 «기한이 지났습니다»가 되는 몫).
// 🔴 쓰기 칸 = 늘(폰 = 안전 동작 창구 늘 주입 · 화면이 주입 null 이면 칸을 그리지 않는다) · 링크(«STOPPED 결정으로») = 셸 레지스트리에
//    그 목적지의 본문이 있을 때만([hasBody]).
// 🔴 화면 상태 없음(온보딩 전) = 오류(셸 공용 «읽지 못함» — 지어내지 않는다).

import 'package:core_engine/core_engine.dart'
    show postmortemAsOf, postmortemListVmOf;
import 'package:data_sync/data_sync.dart'
    show kIncidentWatchedTables, openIncidentsOf, watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show PostmortemListVm, PostmortemRepository;

import 'operator_runtime.dart';
import 'operator_view.dart';
import 'view_stream.dart';

/// `M5-4` — 화면 원장의 열린 의무 건 → 목록 + 쓰기 VM.
class OperatorPostmortemRepository implements PostmortemRepository {
  /// 만든다 — [hasBody] = 셸 레지스트리에 본문이 있나 · [tick] = 시간만 흐를 때 다시 읽는 주기(기한 넘김).
  OperatorPostmortemRepository(
    this._rt, {
    required this.hasBody,
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 셸 레지스트리에 본문이 있나(계약 라우트 패턴).
  final bool Function(String route) hasBody;

  /// 다시 읽는 주기.
  final Duration tick;

  PostmortemListVm _read(OperatorView v) {
    final DateTime now = _rt.clock.nowUtc();
    return postmortemListVmOf(
      openIncidentsOf(v.db),
      nowUtc: now,
      asOf: postmortemAsOf(now),
      canWrite: true,
      hasBody: hasBody,
    );
  }

  @override
  Stream<PostmortemListVm> watchPostmortems() => followView<PostmortemListVm>(
    view: _rt.view,
    changes: (OperatorView v) => watchLedgerQuery<PostmortemListVm>(
      v.db,
      kIncidentWatchedTables,
      () => _read(v),
    ),
    now: _read,
    tick: tick,
    noView: () => StateError('postmortem: 화면 상태 없음(온보딩 전)'),
  );
}
