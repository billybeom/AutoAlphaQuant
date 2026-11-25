// 🆕 미결 243 ⓒ — 공유 계층 push 경보(설계 13 §8 R273 · 계약 v1.39 K344 · v1.41 K372 · 13 R263 C3 · R271 O9).
//
// 🔵 두 push(`rm_push` 읽기 모델 · `op_push` 운영 폰 공유 표)의 «사람이 볼 실패»를 K344 두 P1 으로 — 조치가 다르면 다르게 말한다:
//    시크릿 차단 = `READ_MODEL_PUSH_SECRET_BLOCKED`(원인 확인) · 그 밖(`READ_MODEL_*` · `OPS_PUSH_*` 거부 · 응답 꼴 · 행을 못 만듦) =
//    `READ_MODEL_PUSH_REJECTED`(앱 업데이트 · 원격 설정 다시).
// 🔴 PUSH_LAG(망 · 서버 · 로그인 · 연결 칸 · 리스) · notTried = 알림 0(다음 깨어남에 다시 — 경보 피로).
// 🔴 낸 곳 = 하나([kSharedPushAlertSource]) — 같은 원인(부트스트랩 어긋남 등)이 두 RPC 에서 함께 나도 한국 날 · 코드마다 한 건
//    (`alert_event.dedupe_key` = 코드 · 낸 곳 · 한국 날). 어느 RPC · 표인지 = 보고서(표 이름 · 사유)에 남는다 — 알림 글 = 코드마다 고정
//    (엔진 문구 사전 · 행 값 · 찾은 글자 0).

import 'package:domain_contracts/domain_contracts.dart' show AlertCodes;

import '../supabase/supabase_ops_push.dart' show OpsPushFailure;
import '../supabase/supabase_read_model_push.dart' show ReadModelPushFailure;
import 'ops_push_send.dart' show OpsPushOutcome, OpsTablePush;
import 'read_model_push_job.dart' show ReadModelPushOutcome, ReadModelTablePush;

/// 공유 계층 push 경보의 낸 곳(`alert_event.source` · 두 push 공용).
const String kSharedPushAlertSource = 'shared_push';

/// 사람이 볼 push 실패 사유 → 경보 코드(시크릿 차단 = SECRET_BLOCKED · 그 밖 = REJECTED).
String sharedPushAlertCodeOf(String? reason) =>
    reason == ReadModelPushFailure.secretBlocked.name ||
        reason == OpsPushFailure.secretBlocked.name
    ? AlertCodes.readModelPushSecretBlocked
    : AlertCodes.readModelPushRejected;

/// 🆕 두 보고서의 표 결과 → 낼 경보 코드(사람이 볼 실패만 · 없음 = 빈 집합).
Set<String> sharedPushAlertCodes({
  Iterable<ReadModelTablePush> readModels = const <ReadModelTablePush>[],
  Iterable<OpsTablePush> ops = const <OpsTablePush>[],
}) => <String>{
  for (final ReadModelTablePush t in readModels)
    if (t.outcome == ReadModelPushOutcome.failed)
      sharedPushAlertCodeOf(t.reason),
  for (final OpsTablePush t in ops)
    if (t.outcome == OpsPushOutcome.failed) sharedPushAlertCodeOf(t.reason),
};
