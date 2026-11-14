// 첫 회차 하한 — 이 원장 파일의 모드가 시작된 시각(E11p3b-3 · 설계 13 §8 R93 · R88 Q5).
//
// 🔴 깨어남 회차 판정은 «이 파일의 모드가 생기기 전» 회차를 돌리지 않는다 — 온보딩을 10시에 마친 날
//    09:10 주문 회차가 runNow 로 잡히지 않게. 시작 = 이 파일 RUN_MODE 행의 가장 이른 커밋 시각
//    (sim 파일 = 모의 개시 · live 파일 = 실전 커밋 · 집행 정책 전이 · CLOSE 는 보지 않는다).
// 🔵 `mode_store.dart` 는 E15e2 · E15f 가 고치는 파일이라 따로 둔다.

import 'package:sqlite3/sqlite3.dart';

/// 이 원장 파일의 모드 시작 시각(RUN_MODE 행 없음 = null).
DateTime? modeStartedAtUtc(Database db) {
  final Object? v = db
      .select(
        "SELECT MIN(committed_at) AS t FROM mode_transition WHERE axis = 'RUN_MODE'",
      )
      .first['t'];
  return v == null ? null : DateTime.parse(v as String).toUtc();
}
