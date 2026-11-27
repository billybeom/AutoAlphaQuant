// 🆕 R277(설계 13 §8 R277 VC2 · R272 Y8 · 01 §8 미결 247) — 뷰어가 Supabase 에 닿는 세션 포트.
//
// 🔴 구현 = E11m-c(페어링 클라이언트 · 247 Edge Function `viewer-pair` 가 준 새로고침 토큰 · iOS 키체인 = 조립 앱) — 이 패키지는 포트만 둔다.
//    뷰어 화면에는 로그인 폼 · URL · 키 입력이 없다(04 §9-7 — QR 만) → 주소 · 공개 키 · 토큰 · 기기 id 는 모두 페어링이 정한 값이다.
// 🔴 토큰 · 주소 · 키 · 기기 id 는 어떤 문자열(toString · 오류 · 기록)에도 나오지 않는다.

/// 프로젝트 주소 · 공개 키(페어링이 QR 에서 받아 보관한 값).
final class ViewerEndpoint {
  /// 만든다 — [base] = `https://<ref>.supabase.co` 꼴(경로는 쓰지 않는다 · 꼴 검사 = 페어링 때).
  const ViewerEndpoint(this.base, this.publishableKey);

  /// 프로젝트 주소.
  final Uri base;

  /// 공개(publishable · anon) 키 — `apikey` 머리.
  final String publishableKey;

  @override
  String toString() => 'ViewerEndpoint(…)';
}

/// 뷰어 세션 — 🔴 구현 = E11m-c · 시험 = 가짜.
abstract interface class ViewerSession {
  /// 주소 · 공개 키 — 없음(페어링 전 · 보관 실패) = null.
  Future<ViewerEndpoint?> endpoint();

  /// 접근 토큰 — 없음(페어링 전 · 새로고침 실패) = null · [forceRefresh] = 401 · 403 뒤 새로 받는다.
  Future<String?> accessToken({bool forceRefresh = false});

  /// 이 기기 id(`app_device.device_id` · 페어링 때 정한 값) — 없음 = null.
  Future<String?> deviceId();
}
