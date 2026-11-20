// 🆕 계약 v1.29(01 §39 · E11k-b 계약 창 · K235) — data_sync Supabase 연결 · 서버 시각 enum = 계약 결과 사전.
//
// 🔴 두 배럴을 한 파일에서 import 한다 — 계약 이름이 엔진 이름과 같으면 여기서 `ambiguous_import` 로 컴파일이 깨진다(K80).
// 🔴 엔진 enum 은 와이어 글자가 없다 — 아래 표가 enum 값 → 계약 글자 대응의 정본 초안이다. 엔진이 `wire` 를 달 때(E11k-c ·
//    01 §8 미결 213) 이 표와 같아야 한다 · 엔진 lib 0줄.

import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

/// 입력 문제 6 → 계약 글자(이름 차례 = 엔진 선언 차례).
const Map<SupabaseInputProblem, String> _input = <SupabaseInputProblem, String>{
  SupabaseInputProblem.empty: SupabaseInputResultCodes.empty,
  SupabaseInputProblem.whitespace: SupabaseInputResultCodes.whitespace,
  SupabaseInputProblem.notProjectUrl: SupabaseInputResultCodes.notProjectUrl,
  SupabaseInputProblem.secretKey: SupabaseInputResultCodes.secretKey,
  SupabaseInputProblem.serviceRoleKey: SupabaseInputResultCodes.serviceRoleKey,
  SupabaseInputProblem.notPublishableKey:
      SupabaseInputResultCodes.notPublishableKey,
};

/// 서버 시각 실패 8 → 계약 글자.
const Map<SupabaseTimeFailure, String> _time = <SupabaseTimeFailure, String>{
  SupabaseTimeFailure.notConfigured: SupabaseTimeResultCodes.notConfigured,
  SupabaseTimeFailure.badConfig: SupabaseTimeResultCodes.badConfig,
  SupabaseTimeFailure.vault: SupabaseTimeResultCodes.vault,
  SupabaseTimeFailure.unauthorized: SupabaseTimeResultCodes.unauthorized,
  SupabaseTimeFailure.server: SupabaseTimeResultCodes.server,
  SupabaseTimeFailure.badResponse: SupabaseTimeResultCodes.badResponse,
  SupabaseTimeFailure.noDate: SupabaseTimeResultCodes.noDate,
  SupabaseTimeFailure.network: SupabaseTimeResultCodes.network,
};

void main() {
  group('E11k-b 계약 대조 — data_sync Supabase enum = 계약 사전', () {
    test(
      'SupabaseInputProblem 6 → SupabaseInputResultCodes(전수 · 1:1 · 차례)',
      () {
        expect(_input.keys.toList(), SupabaseInputProblem.values);
        expect(_input.values.toSet(), SupabaseInputResultCodes.values);
        expect(_input.values.toSet(), hasLength(_input.length));
      },
    );

    test('SupabaseTimeFailure 8 → SupabaseTimeResultCodes(전수 · 1:1 · 차례)', () {
      expect(_time.keys.toList(), SupabaseTimeFailure.values);
      expect(_time.values.toSet(), SupabaseTimeResultCodes.values);
      expect(_time.values.toSet(), hasLength(_time.length));
    });

    test(
      '금고 칸 이름 = 계약 밖(엔진 SecretId) · 연결 대상 = ConnectionTargetCodes.supabase',
      () {
        expect(ConnectionTargetCodes.supabase, 'SUPABASE');
        expect(OnboardingSlotIds.supabaseConnect, startsWith('SECRET_'));
      },
    );
  });
}
