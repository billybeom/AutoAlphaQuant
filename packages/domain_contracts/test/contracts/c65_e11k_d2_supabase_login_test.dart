// C-65 E11k-d2 계약 창 — o_07 ③ Supabase 로그인 — 01 §40
// (🆕 계약 v1.31 · 발주자 위임 2026-11-14 — 권고대로 · K237~K246).
//
// 정의: 「o_07 ③ = ② 통과 뒤 같은 단계에서 슬롯 `SECRET_SUPABASE_LOGIN` + 🆕 `supabaseSignIn{}`(1단 — 통과 = 새로고침 토큰 금고) ·
//        인증 고유 실패 6 = 🆕 `SupabaseAuthResultCodes` · 전송 6 = v1.29 `SupabaseTimeResultCodes` 한 벌 · 🔴 로그인 통과 = 여전히
//        `IN_PROGRESS`(VERIFIED = 쓰기-읽기 왕복 뒤) · 로그아웃 노출 0」.
//   ① 인증 사전 ② 전송 한 벌 ③ 슬롯 ④ 동작 ⑤ o_07 ③ 상세 ⑥ 로그인 결과 ⑦ 로그아웃 0 ⑧ 글자 꼴.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _rows(String path) =>
    (_env(path)['rows']! as List).cast<Map<String, Object?>>();

/// data_sync `supabase/supabase_auth.dart` `SupabaseAuthFailure` 12 가운데 인증 고유 6(PR #295 · 와이어 = 계약).
const Set<String> _auth = <String>{
  'SUPABASE_AUTH_INPUT_INVALID',
  'SUPABASE_NOT_SIGNED_IN',
  'SUPABASE_CREDENTIALS_REJECTED',
  'SUPABASE_SESSION_LOST',
  'SUPABASE_RATE_LIMITED',
  'SUPABASE_AUTH_VAULT_FAILED',
};

/// 전송 6 = v1.29 `SupabaseTimeResultCodes` 글자(같은 사건 · 한 벌).
const Set<String> _transport = <String>{
  'SUPABASE_NOT_CONFIGURED',
  'SUPABASE_CONFIG_INVALID',
  'SUPABASE_UNAUTHORIZED',
  'SUPABASE_SERVER_ERROR',
  'SUPABASE_BAD_RESPONSE',
  'SUPABASE_NETWORK',
};

/// 로그인 결과 표본에 나오는 것 — 인증 4 + 망 4(금고 · 설정 셋 = ② 전 · 갱신 둘 = 토큰 갱신 축).
const Set<String> _signInCodes = <String>{
  'SUPABASE_AUTH_INPUT_INVALID',
  'SUPABASE_CREDENTIALS_REJECTED',
  'SUPABASE_RATE_LIMITED',
  'SUPABASE_AUTH_VAULT_FAILED',
  'SUPABASE_UNAUTHORIZED',
  'SUPABASE_SERVER_ERROR',
  'SUPABASE_BAD_RESPONSE',
  'SUPABASE_NETWORK',
};

void main() {
  group('C-65 E11k-d2 o_07 ③ Supabase 로그인 (01 §40)', () {
    test('C-65 ① 인증 사전 6 — 글자 · byDomain 등재 · 다른 도메인과 겹침 0 · 이름 ≠ 엔진', () {
      expect(SupabaseAuthResultCodes.values, _auth);
      expect(ContractCodes.byDomain['supabase_auth_result'], _auth);
      for (final String c in _auth) {
        expect(ContractCodes.domainsOf(c), <String>{
          'supabase_auth_result',
        }, reason: c);
      }
      final String lib = <String>[
        for (final File f in dartSourcesIn(libDir)) f.readAsStringSync(),
      ].join('\n');
      expect(
        RegExp(r'(?:class|enum)\s+SupabaseAuthFailure\b').hasMatch(lib),
        isFalse,
        reason: '계약 이름이 엔진 이름과 같다(K80)',
      );
    });

    test(
      'C-65 ② 전송 6 = SupabaseTimeResultCodes 한 벌(새 글자 0) · 금고 = 인증 쪽 다른 글자',
      () {
        expect(SupabaseTimeResultCodes.values, containsAll(_transport));
        expect(
          SupabaseAuthResultCodes.values.intersection(
            SupabaseTimeResultCodes.values,
          ),
          isEmpty,
        );
        // 시각 쪽 금고 = 읽기만 · 인증 쪽 = 읽기 또는 쓰기 → 다른 글자.
        expect(SupabaseTimeResultCodes.vault, 'SUPABASE_VAULT_UNREADABLE');
        expect(SupabaseAuthResultCodes.vault, 'SUPABASE_AUTH_VAULT_FAILED');
      },
    );

    test('C-65 ③ 슬롯 — SECRET_SUPABASE_LOGIN ∈ onboarding_slot · SECRET_ 접두 · ② 슬롯과 다름', () {
      expect(OnboardingSlotIds.supabaseLogin, 'SECRET_SUPABASE_LOGIN');
      expect(OnboardingSlotIds.supabaseLogin, startsWith('SECRET_'));
      expect(
        OnboardingSlotIds.supabaseLogin,
        isNot(OnboardingSlotIds.supabaseConnect),
      );
      expect(
        ContractCodes.byDomain['onboarding_slot'],
        contains('SECRET_SUPABASE_LOGIN'),
      );
    });

    test('C-65 ④ 동작 — supabaseSignIn 와이어 · connectionTest 와 다름', () {
      expect(SettingsActionId.supabaseSignIn.wire, 'SUPABASE_SIGN_IN');
      expect(
        SettingsActionId.supabaseSignIn,
        isNot(SettingsActionId.connectionTest),
      );
      expect(
        SettingsActionId.values.where(
          (SettingsActionId id) => id.wire == 'SUPABASE_SIGN_IN',
        ),
        hasLength(1),
      );
    });

    test('C-65 ⑤ o_07 ③ 상세 — 같은 단계 IN_PROGRESS · 검증 = SUPABASE_SIGN_IN{} · 로그인 슬롯 · 🔴 VERIFIED 아님 · 왕복', () {
      final Map<String, Object?> row = _rows(
        FixturePaths.m8OnboardingStepDetailSupabaseLogin,
      ).single;
      final Map<String, Object?> step = row['step']! as Map<String, Object?>;
      expect(step['step_id'], 'o_07');
      expect(step['state'], StepState.inProgress.wire);
      expect(step['state'], isNot(StepState.verified.wire));
      final Map<String, Object?> verify =
          row['verify']! as Map<String, Object?>;
      expect(verify['id'], SettingsActionId.supabaseSignIn.wire);
      expect(verify['args'], isEmpty);
      expect(row['secret_slot_id'], OnboardingSlotIds.supabaseLogin);
      // 같은 단계 · 같은 상태 줄 = ② 상세의 통과 뒤 꼴(한 화면에 슬롯 하나 — K241).
      final Map<String, Object?> connect = _rows(
        FixturePaths.m8OnboardingStepDetailSupabase,
      ).single;
      expect(
        (connect['step']! as Map<String, Object?>)['state'],
        step['state'],
      );
      expect(connect['secret_slot_id'], isNot(row['secret_slot_id']));
      final OnboardingStepDetailVm vm = OnboardingStepDetailVm.fromJson(row);
      expect(vm.toJson(), row);
    });

    test(
      'C-65 ⑥ 로그인 결과 — 9행 · 접수 1 + 인증 4 + 망 4 · id = SUPABASE_SIGN_IN · 왕복',
      () {
        final List<Map<String, Object?>> rows = _rows(
          FixturePaths.m8OnboardingSupabaseSigninResults,
        );
        expect(rows, hasLength(9));
        expect(rows.map((Map<String, Object?> r) => r['id']).toSet(), <Object?>{
          SettingsActionId.supabaseSignIn.wire,
        });
        final List<Object?> codes = <Object?>[
          for (final Map<String, Object?> r in rows) r['reason_code'],
        ];
        expect(codes.first, isNull);
        expect(codes.where((Object? c) => c == null), hasLength(1));
        expect(codes.whereType<String>().toSet(), _signInCodes);
        expect(
          _signInCodes,
          everyElement(
            anyOf(
              isIn(SupabaseAuthResultCodes.values),
              isIn(SupabaseTimeResultCodes.values),
            ),
          ),
        );
        for (final Map<String, Object?> r in rows) {
          expect(ActionResult.fromJson(r).toJson(), r);
        }
      },
    );

    test('C-65 ⑦ 로그아웃 노출 0 — 이 판에 로그아웃 동작 · 슬롯 0(미결 216)', () {
      final Set<String> wires = <String>{
        for (final SettingsActionId id in SettingsActionId.values) id.wire,
      };
      expect(wires.where((String w) => w.contains('SIGN_OUT')), isEmpty);
      expect(
        OnboardingSlotIds.values.where(
          (String s) => s.contains('LOGOUT') || s.contains('SIGN_OUT'),
        ),
        isEmpty,
      );
    });

    test('C-65 ⑧ 글자 꼴 — 새 상수 = 대문자 · 숫자 · _ · 표본에 이메일 · 키 · 주소 값 0', () {
      final RegExp wire = RegExp(r'^[A-Z][A-Z0-9_]*$');
      for (final String c in _auth) {
        expect(c, matches(wire));
      }
      for (final String path in <String>[
        FixturePaths.m8OnboardingStepDetailSupabaseLogin,
        FixturePaths.m8OnboardingSupabaseSigninResults,
      ]) {
        final String txt = readFixture(path);
        expect(txt, isNot(contains('@')), reason: path);
        expect(txt, isNot(contains('.supabase.co')), reason: path);
        expect(txt, isNot(contains('eyJ')), reason: path);
      }
    });
  });
}
