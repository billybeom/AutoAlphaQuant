// 01 §12-1 — 🆕 계약 v1.2. **셋째 쓰기 창구** — 기기 로컬 입력 초안.
//
// 🔴 원장·명령·공유 저장소 쓰기가 **아니다**. 사람이 적던 입력을 **이 기기 안에** 보존할 뿐이며
//    제출은 여전히 `CommandApi` 하나다(01 §1-4 예외 1 · C-7 ⑤⑥).
// 🔴 구현 = `data_sync`(06 M4-9) · 주입 = **operator 조립 앱**의 `ProviderScope(overrides:)`.
//    viewer(iOS·웹) 조립에는 구현도 주입도 없다(TARGETS T-3).
// 🔴 화면은 저장 위치·암호화·모드(계열)를 모른다 — 아래 «구현 의무»는 전부 구현의 일이다.
//
// 구현 의무(01 §12-1-6 — 요지): ① 기기 로컬·정본 원장 파일(`ledger*.sqlite`) 밖 ② 하드웨어 결속 키로
// 암호화 ③ Supabase·GitHub·DB 백업·OS 백업·로그·오류 보고로 반출 금지 — 포트가 내는 에러 객체·메시지에도
// 본문 값을 싣지 않는다 ④ 모드 계열(§9-2 `RunModeIsSim`)별 분리 — `load` 는 현재 계열만 ⑤ `save` 완료 =
// 재부팅 생존 · `save`·`clear` 는 호출 순서대로 적용(`clear` 는 그 전에 호출된 모든 `save` 뒤에 효력)
// ⑥ 복호·해독 실패 = `load` null ⑦ `load` 가 준 `lastCommandId` 는 `watchCommand` 가 첫 값을 낼 수 있는 id
// ⑧ executed 관찰 시 연결된 초안 삭제 ⑨ 날짜 만료 없음 · 기기 이전 불이동 ⑩ 본문 칸 ≠ `key.kind` 면 `save`
// 거절 · 세 메서드는 **동기로 던지지 않는다**(에러는 전부 반환 `Future` 의 에러).

import 'drafts.dart';

/// 기기 로컬 입력 초안 포트.
///
/// 🔴 세 메서드는 **동기로 던지지 않는다** — 에러는 전부 반환 `Future` 의 에러다(구현·받침대 공통 ·
///    01 §12-1-2). 에러 객체·메시지에 본문 값을 싣지 않는다(01 §12-1-6 ③ — 화면은 그것을 그대로
///    `FlutterError.reportError` 로 올린다).
/// 화면 쪽 수명 주기(언제 `load`·`save`·`clear` 를 부르는가) = 01 §12-1-4 · `J-3` 상태 표 = 01 §12-4.
abstract interface class DraftStore {
  /// [key] 의 초안. 없으면 null — 다른 모드 계열의 초안 · 복호·해독 실패(구현이 값 없이 내부 보고)도 null.
  /// 🔴 돌려준 `lastCommandId` 는 `CommandApi.watchCommand` 가 첫 값을 낼 수 있는 id 다 —
  ///    구현이 그 명령을 모르면 `lastCommandId: null` 로 준다(잠긴 채 멈춤 방지).
  /// `Future` 에러 = 저장소 자체를 열 수 없음.
  Future<DraftRecord?> load(DraftKey key);

  /// 같은 키의 레코드를 **통째로 교체**(upsert)한다. 자주 불러도 된다 — 쓰기 합치기는 구현 몫이며,
  /// 호출 순서대로 적용된다(마지막 호출이 이긴다). 각 `Future` 는 그 값(또는 더 새 값)이 내구 기록되면 완료.
  /// `Future` 에러 = 쓰기 실패 · 본문 칸이 `key.kind` 의 칸 1개가 아님(`ArgumentError`).
  Future<void> save(DraftRecord record);

  /// 지운다. 없어도 에러가 아니다(멱등).
  /// `save` 와 같은 순서 규칙 — 그 전에 호출된 모든 `save` 뒤에 효력이 난다(합쳐져 아직 기록되지 않은
  /// 옛 `save` 가 지운 초안을 되살리지 않는다 · 01 §12-1-6 ⑤).
  /// 🔴 화면이 부르는 곳은 `CommandState.executed` 수신 **하나뿐**이다(01 §3-8 C17).
  Future<void> clear(DraftKey key);
}
