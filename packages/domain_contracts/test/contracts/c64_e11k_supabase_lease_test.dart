// C-64 E11k-b 계약 창 — Supabase 연결(o_07 ②) · 신뢰 시각 · operator 리스 — 01 §39
// (🆕 계약 v1.29 · 발주자 위임 2026-11-14 — 권고대로 · K223~K236).
//
// 정의: 「o_07 ② = 슬롯 `SECRET_SUPABASE_CONNECT` + 기존 `connectionTest{target: SUPABASE}`(1단 — 통과 = 금고) · 결과 사전 2(엔진 enum 1:1 ·
//        와이어 = 계약) · 🔴 VERIFIED = 쓰기-읽기 왕복 뒤(첫 판 = IN_PROGRESS 중간 상태) · 리스 RPC 표 3(이름 · 인자 · 반환 칸 · 거부
//        사전 · 🔴 `server_now` 0) · `LEASE_INVALID` = v1.18 한 벌 · `app_device.auth_uid`」.
//   ① 사전 3 ② 슬롯 ③ RPC 표 ↔ DDL ④ o_07 상세 표본 ⑤ 연결 결과 표본 ⑥ 리스 두 축 ⑦ R-01 로그인 주석 ⑧ 글자 꼴.
// 🆕 계약 v1.34(01 §43 · 미결 214 · 13 닫음 · 발주자 위임 — 권고대로 · K282~K289) — ③ `auth_uid` = not null · 🔴 unique 0
//   (X1 새 폰 = 같은 운영 사용자) · 색인 · `recovery_secret.algo` 기본값 'sha256' · ⑨ RLS «`app_device` 조인»(JWT 클레임 0 ·
//   두 INSERT 정책 분리 유지 · 정책 6 꼴).

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _rows(String path) =>
    (_env(path)['rows']! as List).cast<Map<String, Object?>>();

const Map<String, Set<String>> _dict = <String, Set<String>>{
  // data_sync supabase/supabase_server_time.dart SupabaseInputProblem 6(PR #285 · 와이어 = 계약)
  'supabase_input_result': <String>{
    'SUPABASE_INPUT_EMPTY',
    'SUPABASE_INPUT_WHITESPACE',
    'SUPABASE_URL_INVALID',
    'SUPABASE_SECRET_KEY_REJECTED',
    'SUPABASE_SERVICE_ROLE_REJECTED',
    'SUPABASE_KEY_INVALID',
  },
  // 같은 파일 SupabaseTimeFailure 8
  'supabase_time_result': <String>{
    'SUPABASE_NOT_CONFIGURED',
    'SUPABASE_CONFIG_INVALID',
    'SUPABASE_VAULT_UNREADABLE',
    'SUPABASE_UNAUTHORIZED',
    'SUPABASE_SERVER_ERROR',
    'SUPABASE_BAD_RESPONSE',
    'SUPABASE_DATE_MISSING',
    'SUPABASE_NETWORK',
  },
  // RPC 표(01 §6-4) 거부
  'lease_rpc_result': <String>{
    'LEASE_HELD_BY_OTHER',
    'LEASE_LOST',
    'LEASE_DEVICE_NOT_ELIGIBLE',
    'RECOVERY_CODE_REQUIRED',
    'RECOVERY_CODE_INVALID',
  },
};

/// 연결 검증(`connectionTest{SUPABASE}`)에서 나오는 망 실패 5 — 금고 셋은 기준점(엔진 깨어남) 축.
const Set<String> _networkFailures = <String>{
  'SUPABASE_UNAUTHORIZED',
  'SUPABASE_SERVER_ERROR',
  'SUPABASE_BAD_RESPONSE',
  'SUPABASE_DATE_MISSING',
  'SUPABASE_NETWORK',
};

String _ddl() => File('${ddlDir.path}/batch_d_supabase.sql').readAsStringSync();

/// 정책 한 줄 — 표 · 동작 · 공백 하나로 접은 본문.
typedef _Policy = ({String table, String op, String body});

/// 줄주석을 지운 SQL 본문.
String _sqlOnly() => _ddl().replaceAll(RegExp(r'--[^\n]*'), '');

/// `create policy <이름> on <표> for <동작> to authenticated <본문>;` → 이름 → (표 · 동작 · 공백 하나로 접은 본문).
Map<String, _Policy> _policies() {
  final Map<String, _Policy> out = <String, _Policy>{};
  for (final RegExpMatch m in RegExp(
    r'create policy (\w+) on (\w+) for (\w+) to authenticated\s+([^;]*);',
  ).allMatches(_sqlOnly())) {
    expect(out.containsKey(m[1]), isFalse, reason: '${m[1]} — 정책 이름이 두 번');
    out[m[1]!] = (
      table: m[2]!,
      op: m[3]!,
      body: m[4]!.replaceAll(RegExp(r'\s+'), ' ').trim(),
    );
  }
  return out;
}

void main() {
  group('C-64 E11k-b Supabase 연결 · 신뢰 시각 · 리스 (01 §39)', () {
    test('C-64 ① 사전 3 — 글자 · byDomain 등재 · 다른 도메인과 겹침 0 · 이름 ≠ 엔진', () {
      expect(SupabaseInputResultCodes.values, _dict['supabase_input_result']);
      expect(SupabaseTimeResultCodes.values, _dict['supabase_time_result']);
      expect(LeaseRpcResultCodes.values, _dict['lease_rpc_result']);
      for (final MapEntry<String, Set<String>> e in _dict.entries) {
        expect(ContractCodes.byDomain[e.key], e.value, reason: e.key);
        for (final String c in e.value) {
          expect(ContractCodes.domainsOf(c), <String>{e.key}, reason: c);
        }
      }
      final String lib = <String>[
        for (final File f in dartSourcesIn(libDir)) f.readAsStringSync(),
      ].join('\n');
      for (final String engineName in <String>[
        'SupabaseInputProblem',
        'SupabaseTimeFailure',
      ]) {
        expect(
          RegExp('(?:class|enum|const String)\\s+$engineName\\b').hasMatch(lib),
          isFalse,
          reason: '$engineName — 계약 이름이 엔진 이름과 같다(K80)',
        );
      }
    });

    test('C-64 ② 슬롯 — SUPABASE_CONNECT ∈ onboarding_slot · 검증 대상 = ConnectionTargetCodes.supabase', () {
      expect(OnboardingSlotIds.supabaseConnect, 'SECRET_SUPABASE_CONNECT');
      expect(
        ContractCodes.byDomain['onboarding_slot'],
        contains('SECRET_SUPABASE_CONNECT'),
      );
      expect(ConnectionTargetCodes.supabase, 'SUPABASE');
    });

    test('C-64 ③ RPC 표 — 이름 3 · 인자 5 · 반환 칸 3 · DDL 서명 주석과 같은 글자 · server_now 0 · auth_uid not null · unique 0 · 색인 · algo sha256', () {
      expect(LeaseRpcNames.values, <String>{
        'lease_claim',
        'lease_renew',
        'lease_revoke',
      });
      expect(LeaseRpcParams.values, hasLength(5));
      expect(LeaseRpcColumns.values, <String>{'code', 'epoch', 'expires_at'});
      final String ddl = _ddl();
      for (final String n in <String>{
        ...LeaseRpcNames.values,
        ...LeaseRpcParams.values,
        ...LeaseRpcResultCodes.values,
      }) {
        expect(ddl, contains(n), reason: '$n — DDL 서명 주석에 없다');
      }
      // 🔴 SQL 본문(주석 뺀 것)에 `server_now` 0 — 신뢰 시각 원천 = 게이트웨이 `Date`(T1).
      final String sqlOnly = ddl.replaceAll(RegExp(r'--[^\n]*'), '');
      expect(sqlOnly, isNot(contains('server_now')));
      // 🆕 v1.34(미결 214) not null · 🔴 unique 0 — X1 새 폰은 같은 운영 사용자로 로그인한다(옛 폰 · 새 폰 = 같은 auth_uid).
      expect(
        sqlOnly,
        matches(
          RegExp(
            r'auth_uid\s+uuid not null references auth\.users\(id\)\s*\n\);',
          ),
        ),
      );
      final String device = RegExp(
        r'create table if not exists app_device \(([^;]*?)\n\);',
      ).firstMatch(sqlOnly)![1]!;
      expect(device, isNot(contains('unique')));
      expect(
        sqlOnly,
        contains(
          'create index if not exists ix_app_device_auth_uid on app_device(auth_uid);',
        ),
      );
      // 🆕 v1.34 — 기본값 = 리스 RPC 가 적는 값(13 R221 S6) · 옛 argon2id 0.
      expect(
        sqlOnly,
        matches(RegExp(r"\n\s+algo\s+text not null default 'sha256',\n")),
      );
      expect(sqlOnly, isNot(contains('argon2')));
      for (final String n in LeaseRpcNames.values) {
        expect(n, isNot(contains('server_now')));
      }
    });

    test('C-64 ④ o_07 상세 — IN_PROGRESS 중간 상태 · 검증 = CONNECTION_TEST{SUPABASE} · 슬롯 · 🔴 VERIFIED 아님', () {
      final Map<String, Object?> row = _rows(
        FixturePaths.m8OnboardingStepDetailSupabase,
      ).single;
      final Map<String, Object?> step = row['step']! as Map<String, Object?>;
      expect(step['step_id'], 'o_07');
      expect(step['state'], StepState.inProgress.wire);
      expect(step['state'], isNot(StepState.verified.wire));
      expect(step['verification_label'], isA<String>());
      final Map<String, Object?> verify =
          row['verify']! as Map<String, Object?>;
      expect(verify['id'], SettingsActionId.connectionTest.wire);
      expect(verify['args'], <String, Object?>{
        'target': ConnectionTargetCodes.supabase,
      });
      expect(row['secret_slot_id'], OnboardingSlotIds.supabaseConnect);
      final OnboardingStepDetailVm vm = OnboardingStepDetailVm.fromJson(row);
      expect(vm.toJson(), row);
    });

    test('C-64 ⑤ 연결 결과 — 12행 · 접수 1 + 입력 6 전수 + 망 5 · id = CONNECTION_TEST · 금고 셋 0', () {
      final List<Map<String, Object?>> rows = _rows(
        FixturePaths.m8OnboardingSupabaseConnectResults,
      );
      expect(rows, hasLength(12));
      expect(rows.map((Map<String, Object?> r) => r['id']).toSet(), <Object?>{
        SettingsActionId.connectionTest.wire,
      });
      final List<Object?> codes = <Object?>[
        for (final Map<String, Object?> r in rows) r['reason_code'],
      ];
      expect(codes.first, isNull);
      expect(codes.where((Object? c) => c == null), hasLength(1));
      expect(codes.whereType<String>().toSet(), <String>{
        ...SupabaseInputResultCodes.values,
        ..._networkFailures,
      });
      for (final Map<String, Object?> r in rows) {
        final ActionResult a = ActionResult.fromJson(r);
        expect(a.toJson(), r);
      }
    });

    test('C-64 ⑥ 리스 두 축 — LEASE_INVALID = v1.18 journal_reason 한 벌(새 사전 0) ≠ LEASE_EXPIRED(명령 접수)', () {
      expect(JournalReasonCodes.leaseInvalid, 'LEASE_INVALID');
      expect(ContractCodes.domainsOf('LEASE_INVALID'), <String>{
        'journal_reason',
      });
      expect(AdviceRejectCodes.leaseExpired, 'LEASE_EXPIRED');
      expect(LeaseRpcResultCodes.values, isNot(contains('LEASE_INVALID')));
    });

    test('C-64 ⑦ R-01 복구 로그인 = 이메일 + 비밀번호 — 계약 소스에 «매직링크/OTP» 현행 문장 0', () {
      for (final String rel in <String>[
        'src/labels/onboarding_codes.dart',
        'src/dto/onboarding.dart',
      ]) {
        final String src = File('${libDir.path}/$rel').readAsStringSync();
        expect(src, contains('비밀번호'), reason: rel);
        // 정정 표기(~~…~~) 안에서만 옛 글자가 남는다.
        expect(
          src.replaceAll('~~매직링크/OTP~~', ''),
          isNot(contains('매직링크')),
          reason: rel,
        );
      }
    });

    test('C-64 ⑧ 글자 꼴 — 새 상수 = 대문자 · 숫자 · _ (RPC 글자 = 소문자 · _ · 값 · 주소 0)', () {
      final RegExp wire = RegExp(r'^[A-Z][A-Z0-9_]*$');
      for (final String c in <String>{
        for (final Set<String> v in _dict.values) ...v,
      }) {
        expect(c, matches(wire));
      }
      final RegExp sql = RegExp(r'^[a-z][a-z_]*$');
      for (final String n in <String>{
        ...LeaseRpcNames.values,
        ...LeaseRpcParams.values,
        ...LeaseRpcColumns.values,
      }) {
        expect(n, matches(sql));
      }
    });

    test('C-64 ⑨ 미결 214(v1.34 · 01 §43) — RLS «app_device 조인» · JWT 클레임 0 · INSERT 정책 3(두 명령 정책 분리) · UPDATE · DELETE 0', () {
      final String sqlOnly = _sqlOnly();
      // `role` 자리 = app_device 행(미결 13 닫음) — JWT `app_metadata` · `auth.jwt()` 를 읽는 정책 0.
      expect(sqlOnly, isNot(contains('app_metadata')));
      expect(sqlOnly, isNot(contains('auth.jwt()')));
      final Map<String, _Policy> p = _policies();
      // 쓰기 정책 = INSERT 셋뿐(append-only · 리스 · 미러 · 스탬프 쓰기 = RPC) · 두 명령 정책은 합치지 않는다(Q-C).
      expect(p.values.map((_Policy e) => e.op).toSet(), <String>{
        'select',
        'insert',
      });
      expect(
        <String>{
          for (final MapEntry<String, _Policy> e in p.entries)
            if (e.value.op == 'insert') e.key,
        },
        <String>{
          'device_insert_viewer_only',
          'command_insert_viewer',
          'command_insert_operator',
        },
      );

      // 기기 — 클라이언트 = 운영 사용자 자기 기기(viewer · PENDING)만 · 뷰어 기기 행 = 페어링 RPC(서버).
      expect(p['device_insert_viewer_only']!.table, 'app_device');
      // 🔵 v1.39(01 §48 K349 ②) — 첫 클레임 뒤 = 운영 사용자만(리스 쥔 기기 소유) — 뒤 조건 전문 = C-72 ⑩.
      expect(
        p['device_insert_viewer_only']!.body,
        startsWith(
          "with check (auth_uid = auth.uid() and owner_uid = auth.uid() and role = 'viewer' and status = 'PENDING'",
        ),
      );
      expect(
        p['device_select_own']!.body,
        'using (owner_uid = auth.uid() or auth_uid = auth.uid())',
      );

      // 명령 INSERT — 낸 기기 = 부른 사용자의 기기 · 명령 소유자의 기기 · 그 role · ACTIVE(`owner_uid = auth.uid()` 0).
      const String viewerKinds =
          "kind in ('KILL_SWITCH_ACTIVATE','JOURNAL_DRAFT','BLIND_REVIEW_SCORE','DISCLOSURE_VIEW')";
      for (final String role in <String>['viewer', 'operator']) {
        final _Policy c = p['command_insert_$role']!;
        expect(c.table, 'command_queue', reason: role);
        for (final String part in <String>[
          'expires_at > now()',
          'exists (select 1 from app_device d where d.device_id = command_queue.issued_by_device',
          'd.auth_uid = auth.uid() and d.owner_uid = command_queue.owner_uid',
          "d.role = '$role' and d.status = 'ACTIVE')",
        ]) {
          expect(c.body, contains(part), reason: '$role — $part');
        }
        expect(c.body, isNot(contains('owner_uid = auth.uid()')), reason: role);
        expect(
          c.body.contains(viewerKinds),
          role == 'viewer',
          reason: '$role — 뷰어 4종 화이트리스트는 뷰어 정책에만',
        );
      }
      expect(p['command_insert_operator']!.body, isNot(contains('kind')));

      // 명령 읽기 = 부른 사용자의 ACTIVE 기기가 그 소유자의 기기 · ack = 보이는 명령.
      expect(
        p['command_select_own']!.body,
        "using (exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.owner_uid = command_queue.owner_uid and d.status = 'ACTIVE'))",
      );
      expect(
        p['command_ack_select']!.body,
        'using (exists (select 1 from command_queue q where q.command_id = command_ack.command_id))',
      );
    });
  });
}
