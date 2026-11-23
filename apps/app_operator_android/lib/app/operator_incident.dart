// 🆕 E11q-d2 — M8 `D-01` 장애 배너 창구 operator 판(설계 13 §8 · 06 M4-12 ① 장애 override 의무 · 04 §6 · 01 §26 K9 · 미결 164).
//
// 🔴 원천 = 화면이 읽는 원장(엔진과 같은 연결)의 열린 사건(`incidents` · `resolved_at` 빈칸) → 엔진 `incidentBannerVmOf`
//    (고르기 · 정렬 · 최대 1건 · 글자 = 엔진 — 화면은 받은 0/1건을 그린다).
// 🔴 다시 낸다 = 들을 때 · 사건 표가 바뀔 때(같은 연결 `db.updates` — 건이 열리고 닫히는 곳) · 화면 상태가 바뀔 때(새 원장으로
//    옮긴다) · 바뀐 값만. 시간만 흐르는 몫 0(배너는 열림 · 닫힘만 본다 — 주기 0).
// 🔴 화면 상태가 없으면(온보딩 전) sim 원장을 읽는다(`operatorDbProvider` 와 같은 원장) — 매매 전이라 열린 사건 0 = 배너 없음.
//    오류로 내지 않는다: 배너 자리의 오류는 모든 탭 위에 «다시 시도»를 세운다(셸 `d01-fail`).
// 🔴 원장을 못 읽으면 = 오류(셸이 다시 시도 자리를 그린다 — 지어내지 않는다).
// 🔴 조치 링크 = 셸 레지스트리에 그 목적지의 본문이 있을 때만([hasBody] · 엔진이 계약 라우트 패턴으로 묻는다).

import 'dart:async';

import 'package:core_engine/core_engine.dart' show incidentBannerVmOf;
import 'package:data_sync/data_sync.dart'
    show kIncidentWatchedTables, openIncidentsOf, watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show IncidentBannerVm, IncidentRepository;
import 'package:sqlite3/sqlite3.dart' show Database;

import 'operator_runtime.dart' show OperatorRuntime;

/// `D-01` — 열린 사건 → 배너 0/1건.
class OperatorIncidentRepository implements IncidentRepository {
  /// 만든다 — [hasBody] = 셸 레지스트리에 본문이 있나.
  OperatorIncidentRepository(this._rt, {required this.hasBody});

  final OperatorRuntime _rt;

  /// 셸 레지스트리에 본문이 있나(계약 라우트 패턴).
  final bool Function(String route) hasBody;

  /// 화면이 읽는 원장 — 기동 판정이 고른 파일(온보딩 미완 = sim 파일).
  Database _db() => _rt.view.value?.db ?? _rt.files.sim;

  /// 지금 값(한 번 읽기).
  IncidentBannerVm _now(Database db) =>
      incidentBannerVmOf(openIncidentsOf(db), hasBody: hasBody);

  @override
  Stream<IncidentBannerVm> watchIncident() {
    late final StreamController<IncidentBannerVm> c;
    StreamSubscription<IncidentBannerVm>? sub;
    Database? on;
    IncidentBannerVm? last;
    bool has = false;

    void put(IncidentBannerVm v) {
      if (c.isClosed || (has && v == last)) return;
      has = true;
      last = v;
      c.add(v);
    }

    void fail(Object e, StackTrace st) {
      if (c.isClosed) return;
      has = false; // 오류 뒤 같은 값도 다시 낸다(셸이 오류 자리를 걷는다).
      c.addError(e, st);
    }

    void follow() {
      final Database db = _db();
      if (identical(db, on) && sub != null) return; // 같은 원장 = 감시 그대로.
      unawaited(sub?.cancel());
      on = db;
      sub = watchLedgerQuery<IncidentBannerVm>(
        db,
        kIncidentWatchedTables,
        () => _now(db),
      ).listen(put, onError: fail);
    }

    c = StreamController<IncidentBannerVm>(
      onListen: () {
        _rt.view.addListener(follow);
        follow();
      },
      onCancel: () async {
        _rt.view.removeListener(follow);
        await sub?.cancel();
        await c.close();
      },
    );
    return c.stream;
  }
}
