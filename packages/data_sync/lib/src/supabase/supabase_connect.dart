// o_07 ② Supabase 연결 확인 결과(E11k-c · 설계 13 §8 R206 · 계약 v1.29 01 §39 · 표본 `m8/onboarding_supabase_connect_results`).
//
// 🔴 결과 글자 · 등급 · 재시도 = 엔진 몫(이 파일) — 화면 · 조립 앱은 그대로 싣는다(`ActionResult.headline` · `reasonCode`).
// 🔴 사유 코드 = 엔진 enum 의 [SupabaseInputProblem.wire] · [SupabaseTimeFailure.wire](계약 사전 1:1 · 01 §8 미결 213).
// 🔴 연결 확인은 붙여 넣은 값으로만 잰다(`SupabaseServerTime.probe`) — 금고 실패 셋(`notConfigured` · `badConfig` · `vault`)은
//    여기서 나올 수 없다(나오면 [StateError] — 조용히 다른 글자로 덮지 않는다).
// 🔴 주소 · 키 값은 어떤 글자에도 싣지 않는다.

import 'package:domain_contracts/domain_contracts.dart' show UiLevel;

import 'supabase_auth.dart';
import 'supabase_server_time.dart';

/// 연결 확인 한 줄(등급 · 글자 · 사유 코드 · 다시 해 볼 만한가).
typedef SupabaseConnectOutcome = ({
  UiLevel level,
  String headline,
  String? reasonCode,
  bool retryable,
});

/// 🔴 결과 글자(표본 글자 그대로).
abstract final class SupabaseConnectText {
  /// 통과(o_07 = 진행 중 · 로그인 · SQL 남음).
  static const String ok = '서버 시각을 확인했습니다. 로그인과 SQL 단계가 남았습니다.';

  /// 입력 문제 6.
  static String input(SupabaseInputProblem p) => switch (p) {
    SupabaseInputProblem.empty => '주소와 키를 모두 붙여 넣으십시오.',
    SupabaseInputProblem.whitespace => '붙여 넣은 값에 빈칸이나 따옴표가 섞였습니다. 다시 복사하십시오.',
    SupabaseInputProblem.notProjectUrl =>
      '프로젝트 주소 꼴이 아닙니다. 설정 화면의 주소를 그대로 복사하십시오.',
    SupabaseInputProblem.secretKey =>
      '비밀 키는 앱에 넣지 않습니다. publishable 키를 복사하십시오.',
    SupabaseInputProblem.serviceRoleKey =>
      'service_role 키는 앱에 넣지 않습니다. publishable 키를 복사하십시오.',
    SupabaseInputProblem.notPublishableKey =>
      '공개 키 꼴이 아닙니다. publishable 키를 그대로 복사하십시오.',
  };
}

/// 통과.
const SupabaseConnectOutcome kSupabaseConnectOk = (
  level: UiLevel.ok,
  headline: SupabaseConnectText.ok,
  reasonCode: null,
  retryable: false,
);

/// 🆕 붙여 넣은 두 값의 첫 문제(없음 = null) — 하나라도 비면 «모두 붙여 넣으십시오» · 그다음 주소 · 그다음 키.
SupabaseInputProblem? supabaseConnectInputProblem({
  required String? url,
  required String? key,
}) {
  final String u = url?.trim() ?? '';
  final String k = key?.trim() ?? '';
  if (u.isEmpty || k.isEmpty) return SupabaseInputProblem.empty;
  return supabaseProjectUrlProblem(u) ?? supabasePublishableKeyProblem(k);
}

/// 입력 문제 → 결과(망에 가기 전 · 모두 BLOCKED · 다시 붙여 넣어야 하므로 재시도 아님).
SupabaseConnectOutcome supabaseInputOutcome(SupabaseInputProblem p) => (
  level: UiLevel.blocked,
  headline: SupabaseConnectText.input(p),
  reasonCode: p.wire,
  retryable: false,
);

/// 서버 시각 실패 → 결과(망 다섯 · 🔴 금고 셋 = [StateError]).
SupabaseConnectOutcome supabaseTimeOutcome(SupabaseTimeFailure f) =>
    switch (f) {
      SupabaseTimeFailure.unauthorized => (
        level: UiLevel.blocked,
        headline: '키가 거절되었습니다. 설정 화면에서 키를 다시 확인하십시오.',
        reasonCode: f.wire,
        retryable: false,
      ),
      SupabaseTimeFailure.server => (
        level: UiLevel.watch,
        headline: '서버가 응답하지 못했습니다. 잠시 뒤 다시 확인하십시오.',
        reasonCode: f.wire,
        retryable: true,
      ),
      SupabaseTimeFailure.badResponse => (
        level: UiLevel.blocked,
        headline: '예상하지 못한 응답입니다. 주소를 다시 확인하십시오.',
        reasonCode: f.wire,
        retryable: false,
      ),
      SupabaseTimeFailure.noDate => (
        level: UiLevel.blocked,
        headline: '서버 시각을 읽지 못했습니다. 잠시 뒤 다시 확인하십시오.',
        reasonCode: f.wire,
        retryable: true,
      ),
      SupabaseTimeFailure.network => (
        level: UiLevel.watch,
        headline: '연결되지 않았습니다. 망을 확인한 뒤 다시 확인하십시오.',
        reasonCode: f.wire,
        retryable: true,
      ),
      SupabaseTimeFailure.notConfigured ||
      SupabaseTimeFailure.badConfig ||
      SupabaseTimeFailure.vault => throw StateError(
        '연결 확인에서 나올 수 없는 실패: ${f.name}',
      ),
    };

/// 🆕 붙여 넣은 값으로 연결을 확인한다 — 입력 문제 = 망 0 · 통과 = [kSupabaseConnectOk](저장은 부르는 쪽이 이 뒤에만).
Future<SupabaseConnectOutcome> checkSupabaseConnection(
  SupabaseServerTime time, {
  required String? url,
  required String? key,
}) async {
  final SupabaseInputProblem? p = supabaseConnectInputProblem(
    url: url,
    key: key,
  );
  if (p != null) return supabaseInputOutcome(p);
  final SupabaseTimeRead r = await time.probe(url!, key!);
  final SupabaseTimeFailure? f = r.failure;
  return f == null ? kSupabaseConnectOk : supabaseTimeOutcome(f);
}

// ── 🆕 E11k-d2(R216 · 계약 v1.31 01 §40 · 표본 `m8/onboarding_supabase_signin_results` 9행) — o_07 ③ 로그인 결과 ──────────
// 🔴 로그인에서 나오는 것 = 접수 1 + 인증 4(입력 · 자격 · 과속 · 금고) + 망 4(키 · 서버 · 응답 · 망) — 표본 글자 그대로.
// 🔴 나올 수 없는 넷(`notConfigured` · `badConfig` = 로그인 칸은 ② 통과 뒤에만 선다 · `notSignedIn` · `sessionLost` = 새로고침 축) =
//    [StateError](표본에 없는 글자를 짓지 않는다).

/// 로그인 통과(o_07 = 여전히 진행 중 · SQL 남음).
const SupabaseConnectOutcome kSupabaseSignInOk = (
  level: UiLevel.ok,
  headline: '로그인했습니다. SQL 단계가 남았습니다.',
  reasonCode: null,
  retryable: false,
);

/// 로그인 실패 → 결과(표본 8줄 · 🔴 나올 수 없는 넷 = [StateError]).
SupabaseConnectOutcome supabaseSignInOutcome(SupabaseAuthFailure f) {
  SupabaseConnectOutcome row(UiLevel level, String text, bool retry) =>
      (level: level, headline: text, reasonCode: f.wire, retryable: retry);
  return switch (f) {
    SupabaseAuthFailure.badInput => row(
      UiLevel.blocked,
      '이메일과 비밀번호를 모두 붙여 넣으십시오.',
      false,
    ),
    SupabaseAuthFailure.invalidCredentials => row(
      UiLevel.blocked,
      '이메일 또는 비밀번호가 맞지 않습니다. 비밀번호 관리자의 값을 다시 확인하십시오.',
      false,
    ),
    SupabaseAuthFailure.rateLimited => row(
      UiLevel.watch,
      '시도가 너무 잦습니다. 잠시 뒤 다시 로그인하십시오.',
      true,
    ),
    SupabaseAuthFailure.vault => row(
      UiLevel.blocked,
      '로그인 상태를 이 기기에 저장하지 못했습니다. 다시 로그인하십시오.',
      false,
    ),
    SupabaseAuthFailure.unauthorized => row(
      UiLevel.blocked,
      '연결 키가 거절되었습니다. 연결 단계를 다시 확인하십시오.',
      false,
    ),
    SupabaseAuthFailure.server => row(
      UiLevel.watch,
      '서버가 응답하지 못했습니다. 잠시 뒤 다시 로그인하십시오.',
      true,
    ),
    SupabaseAuthFailure.badResponse => row(
      UiLevel.blocked,
      '예상하지 못한 응답입니다. 잠시 뒤 다시 로그인하십시오.',
      false,
    ),
    SupabaseAuthFailure.network => row(
      UiLevel.watch,
      '연결되지 않았습니다. 망을 확인한 뒤 다시 로그인하십시오.',
      true,
    ),
    SupabaseAuthFailure.notConfigured ||
    SupabaseAuthFailure.badConfig ||
    SupabaseAuthFailure.notSignedIn ||
    SupabaseAuthFailure.sessionLost => throw StateError(
      '로그인에서 나올 수 없는 실패: ${f.name}',
    ),
  };
}
