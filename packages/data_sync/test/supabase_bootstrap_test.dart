// E11k-e2 — o_07 ① 부트스트랩 SQL 묶음 · 리스 RPC 본문 · 복구 코드 해시 꼴(설계 13 §8 R221 · 계약 v1.29 `schema/supabase_rpc.dart` ·
// `LeaseRpcResultCodes` · 01 §6-4 리스 RPC 표).
//
// 🔵 잡는 것(정적 — CI 에 Postgres 0): ① 원문 조각 = 두 SQL 파일 바이트 그대로(생성기 다시 돌림) ② RPC 서명 = 계약 이름 · 인자 차례 ·
//    반환 칸 그대로 · 거부 글자 = 계약 사전 5 전부 · 그 밖 0 ③ security definer · search_path '' · 실행 권한 = authenticated 만(anon 회수) ·
//    세 RPC 같은 잠금 · CAS 꼴(바뀐 행 수 확인) · T = 엔진 `kLeaseTtl` · `server_now` · 확장 0 ④ 묶음 차례 · 한 트랜잭션 · 가드 ·
//    미완 판 = 첫 문장이 멈춤 · 판 = 원문이 바뀌면 바뀜 ⑤ 복구 코드 해시 = Postgres 가 계산한 고정 벡터 · 서버 정규식과 같은 글자.
// 🔵 실행 검증(Postgres 16 · PGlite) = 설계 13 §8 R221 기록 · 실 프로젝트 동시 클레임 = E11k-f.

import 'dart:io';

import 'package:core_engine/core_engine.dart' show kLeaseTtl;
import 'package:data_sync/data_sync.dart';
import 'package:data_sync/src/supabase/supabase_bootstrap_sources.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show LeaseRpcColumns, LeaseRpcNames, LeaseRpcParams, LeaseRpcResultCodes;
import 'package:test/test.dart';

/// 주석을 뺀 SQL(`--` 줄 끝까지 — 리스 RPC 원문에는 문자열 안 `--` 가 없다).
String _code(String sql) => sql.replaceAll(RegExp(r'--[^\n]*'), '');

final String _rpc = _code(kSupabaseLeaseRpcSql);

/// `create or replace function public.<이름>(…)` 의 인자 이름 차례.
List<String> _params(String name) {
  final RegExpMatch? m = RegExp(
    'create or replace function public\\.$name\\(([^)]*)\\)',
  ).firstMatch(_rpc);
  expect(m, isNotNull, reason: '$name — 함수 정의가 없다');
  return m!
      .group(1)!
      .split(',')
      .map((String p) => p.trim().split(RegExp(r'\s+')).first)
      .toList();
}

/// 함수 하나의 본문(`$fn$` … `$fn$`).
String _body(String name) {
  final int at = _rpc.indexOf('function public.$name(');
  final int open = _rpc.indexOf(r'$fn$', at);
  final int close = _rpc.indexOf(r'$fn$', open + 4);
  return _rpc.substring(open, close);
}

void main() {
  group('① 원문 조각', () {
    test('배치 D = 계약 사본 원문 · 리스 RPC = sql/ 원문(바이트)', () {
      expect(
        kSupabaseBatchDSql,
        File('../domain_contracts/ddl/batch_d_supabase.sql').readAsStringSync(),
        reason: 'tool/make_supabase_bootstrap.py 를 다시 돌린다',
      );
      expect(
        kSupabaseLeaseRpcSql,
        File('sql/supabase_lease_rpc.sql').readAsStringSync(),
        reason: 'tool/make_supabase_bootstrap.py 를 다시 돌린다',
      );
    });
  });

  group('② RPC = 계약 표', () {
    test('이름 3 · 인자 차례 · 인자 5 전부', () {
      expect(_params(LeaseRpcNames.claim), <String>[
        LeaseRpcParams.deviceId,
        LeaseRpcParams.recoveryCodeHash,
      ]);
      expect(_params(LeaseRpcNames.renew), <String>[
        LeaseRpcParams.deviceId,
        LeaseRpcParams.epoch,
      ]);
      expect(_params(LeaseRpcNames.revoke), <String>[
        LeaseRpcParams.deviceId,
        LeaseRpcParams.recoveryCode,
        LeaseRpcParams.newRecoveryCodeHash,
      ]);
      expect(
        RegExp(r'create or replace function public\.(\w+)\(')
            .allMatches(_rpc)
            .map((RegExpMatch m) => m.group(1))
            .toSet(),
        LeaseRpcNames.values,
        reason: '계약 밖 함수 0(PostgREST 에 그대로 드러난다)',
      );
      // 첫 클레임 아닌 클레임 = 해시 없이 부른다(E11k-e1 · `claim(deviceId:)`).
      expect(_rpc, contains('p_recovery_code_hash text default null'));
    });

    test('반환 = 한 행 (code · epoch · expires_at) — 셋 다 같은 꼴', () {
      final List<RegExpMatch> m = RegExp(
        r'returns table \((\w+) text, (\w+) bigint, (\w+) timestamptz\)',
      ).allMatches(_rpc).toList();
      expect(m, hasLength(3));
      for (final RegExpMatch r in m) {
        expect(
          <String?>{r.group(1), r.group(2), r.group(3)},
          <String>{
            LeaseRpcColumns.code,
            LeaseRpcColumns.epoch,
            LeaseRpcColumns.expiresAt,
          },
        );
        expect(r.group(1), LeaseRpcColumns.code);
      }
      // 🔴 반환은 `return query select …` 한 줄씩 — 거부도 예외(HTTP 오류)로 알리지 않는다.
      expect(_rpc, isNot(contains('raise exception')));
      expect(_rpc, isNot(contains('raise ')));
    });

    test('거부 글자 = 계약 사전 5 전부 · 그 밖 0', () {
      final Set<String> used = RegExp(r"'([A-Z_]+)'::text")
          .allMatches(_rpc)
          .map((RegExpMatch m) => m.group(1)!)
          .toSet();
      expect(used, LeaseRpcResultCodes.values);
      // 함수마다 표의 거부가 나온다(01 §6-4 리스 RPC 표).
      expect(
        _body(LeaseRpcNames.claim),
        contains(LeaseRpcResultCodes.heldByOther),
      );
      expect(
        _body(LeaseRpcNames.claim),
        contains(LeaseRpcResultCodes.recoveryCodeRequired),
      );
      expect(_body(LeaseRpcNames.renew), contains(LeaseRpcResultCodes.lost));
      expect(
        _body(LeaseRpcNames.revoke),
        contains(LeaseRpcResultCodes.recoveryCodeInvalid),
      );
      for (final String n in LeaseRpcNames.values) {
        expect(
          _body(n),
          contains(LeaseRpcResultCodes.deviceNotEligible),
          reason: n,
        );
      }
    });
  });

  group('③ 안전 꼴', () {
    test('security definer · search_path \'\' · 실행 권한 = authenticated 만', () {
      expect(
        RegExp(r"security definer\s+set search_path = ''").allMatches(_rpc),
        hasLength(3),
      );
      for (final (String n, String sig) in <(String, String)>[
        (LeaseRpcNames.claim, 'text, text'),
        (LeaseRpcNames.renew, 'text, bigint'),
        (LeaseRpcNames.revoke, 'text, text, text'),
      ]) {
        expect(
          _rpc,
          contains('revoke all on function public.$n($sig) from public, anon;'),
        );
        expect(
          _rpc,
          contains(
            'grant execute on function public.$n($sig) to authenticated;',
          ),
        );
      }
      expect(_rpc, isNot(contains('to anon')));
      // search_path '' — 표 이름은 늘 스키마를 붙인다.
      expect(
        RegExp(
          r'(from|update|into)\s+(operator_lease|app_device|recovery_secret)\b',
        ).hasMatch(_rpc),
        isFalse,
      );
    });

    test('부르는 기기 판정 = auth.uid() 의 운영 기기 · REVOKED · RETIRED 제외(셋 다)', () {
      for (final String n in LeaseRpcNames.values) {
        final String b = _body(n);
        expect(b, contains('auth.uid()'), reason: n);
        expect(b, contains('d.auth_uid = v_uid'), reason: n);
        expect(b, contains('d.owner_uid = v_uid'), reason: n);
        expect(
          b,
          contains("d.status not in ('REVOKED', 'RETIRED')"),
          reason: n,
        );
        expect(b, isNot(contains('app_metadata')), reason: n);
      }
    });

    test('같은 잠금 · CAS(바뀐 행 수 · epoch 조건) · T = 엔진 kLeaseTtl', () {
      for (final String n in LeaseRpcNames.values) {
        expect(
          _body(n),
          contains('pg_advisory_xact_lock(1094799692)'),
          reason: n,
        );
      }
      expect(
        RegExp(
          r'where l\.id = 1 and l\.epoch = v_epoch and l\.device_id = v_holder',
        ).allMatches(_rpc),
        hasLength(2),
        reason: 'claim 넘어옴 · revoke = 읽은 값 조건부 쓰기',
      );
      expect(_body(LeaseRpcNames.renew), contains('and l.epoch = p_epoch'));
      expect(_body(LeaseRpcNames.renew), contains('and l.expires_at > now()'));
      expect(_rpc, contains('get diagnostics v_rows = row_count;'));
      expect(_rpc, contains('on conflict (id) do nothing;'));
      final Iterable<RegExpMatch> ttl = RegExp(
        r"now\(\) \+ interval '(\d+) minutes'",
      ).allMatches(_rpc);
      expect(ttl, hasLength(2));
      for (final RegExpMatch m in ttl) {
        expect(int.parse(m.group(1)!), kLeaseTtl.inMinutes);
      }
    });

    test('첫 클레임 = 복구 해시와 같은 트랜잭션 · 그 밖 클레임은 해시를 읽지 않는다', () {
      final String b = _body(LeaseRpcNames.claim);
      final int first = b.indexOf('if p_recovery_code_hash is null');
      final int other = b.indexOf('elsif v_holder = p_device_id');
      expect(first, greaterThan(0));
      expect(other, greaterThan(first));
      expect(
        b.substring(first, other),
        contains('insert into public.recovery_secret'),
      );
      expect(b.substring(other), isNot(contains('p_recovery_code_hash')));
      expect(b.substring(other), isNot(contains('recovery_secret')));
      // 리스 행이 먼저 서고(CAS) 그 뒤에 해시 — 진 쪽 해시가 남지 않는다.
      expect(
        b.indexOf('insert into public.operator_lease'),
        lessThan(b.indexOf('insert into public.recovery_secret')),
      );
    });

    test('핵심 문장(행동 검증 = PGlite 실행 · CI 는 글자로 지킨다 — R221)', () {
      final String claim = _body(LeaseRpcNames.claim);
      // 같은 기기 = epoch 그대로 · 다른 기기에서 넘어옴 = +1 · 다른 기기 유효 = 거부.
      expect(
        claim,
        contains(
          'case when v_holder = p_device_id then v_epoch else v_epoch + 1 end',
        ),
      );
      expect(
        claim,
        contains('elsif v_holder = p_device_id or v_exp <= now() then'),
      );
      final String revoke = _body(LeaseRpcNames.revoke);
      // 대조 = 같은 정규화 · 같은 식 · 틀리면 거부.
      expect(
        revoke,
        contains(
          "v_norm := upper(regexp_replace(coalesce(p_recovery_code, ''), '[^0-9A-Za-z]', '', 'g'));",
        ),
      );
      expect(
        revoke,
        contains(
          "encode(sha256(convert_to(split_part(v_hash, ':', 2) || ':' || v_norm, 'UTF8')), 'hex')\n"
          "        <> split_part(v_hash, ':', 3) then",
        ),
      );
      // 같은 트랜잭션: 옛 보유 기기 REVOKED · 해시 교체.
      expect(revoke, contains("set status = 'REVOKED'"));
      expect(
        revoke,
        contains('set code_hash = p_new_recovery_code_hash, algo = \'sha256\''),
      );
    });

    test('server_now · 확장 · 비밀 0', () {
      expect(_rpc, isNot(contains('server_now'))); // 주석 밖(C-64 ③ 과 같은 잣대)
      expect(_rpc, isNot(contains('create extension')));
      expect(_rpc, isNot(contains('pgsodium')));
      expect(_rpc, isNot(contains('crypt(')));
      expect(kSupabaseLeaseRpcSql, isNot(contains('supabase.co')));
    });
  });

  group('④ 묶음', () {
    const String rm = '-- rm 시험 조각\ncreate table if not exists rm_x (a int);';

    test('미완 판(rm_* 없음) = complete false · 첫 문장이 멈춘다', () {
      final SupabaseBootstrapSql s = SupabaseBootstrapSql.assemble();
      expect(s.complete, isFalse);
      expect(
        SupabaseBootstrapSql.assemble(readModelsSql: '  \n').complete,
        isFalse,
      );
      final int stop = s.text.indexOf(r'do $incomplete$');
      expect(stop, greaterThan(0));
      expect(stop, lessThan(s.text.indexOf(r'do $guard$')));
      expect(stop, lessThan(s.text.indexOf('create table')));
      expect(s.text, contains('미완'));
      expect(s.toString(), contains('미완'));
    });

    test('완성 판 = 한 트랜잭션 · 가드 → 배치 D → 리스 RPC → rm_* 차례 · 미완 멈춤 0', () {
      final SupabaseBootstrapSql s = SupabaseBootstrapSql.assemble(
        readModelsSql: rm,
      );
      expect(s.complete, isTrue);
      final String t = s.text;
      expect(t, isNot(contains(r'$incomplete$')));
      expect(t.indexOf('begin;'), lessThan(t.indexOf(r'do $guard$')));
      expect(t.indexOf(r'do $guard$'), lessThan(t.indexOf(kSupabaseBatchDSql)));
      expect(
        t.indexOf(kSupabaseBatchDSql),
        lessThan(t.indexOf(kSupabaseLeaseRpcSql)),
      );
      expect(t.indexOf(kSupabaseLeaseRpcSql), lessThan(t.indexOf(rm)));
      expect(t.trimRight(), endsWith('commit;'));
      expect('begin;'.allMatches(t), hasLength(1));
      expect(t, contains("to_regclass('public.operator_lease') is not null"));
      expect(
        t,
        startsWith('-- AutoAlphaQuant Supabase 부트스트랩 SQL — 판 ${s.edition}\n'),
      );
      expect(t, isNot(contains('supabase.co')));
    });

    test('판 = 원문 셋의 sha256 앞 12 — rm_* 가 바뀌면 바뀐다 · 같은 원문 = 같은 판', () {
      final SupabaseBootstrapSql a = SupabaseBootstrapSql.assemble();
      final SupabaseBootstrapSql b = SupabaseBootstrapSql.assemble(
        readModelsSql: rm,
      );
      final SupabaseBootstrapSql c = SupabaseBootstrapSql.assemble(
        readModelsSql: '$rm ',
      );
      expect(a.edition, matches(RegExp(r'^[0-9a-f]{12}$')));
      expect(<String>{a.edition, b.edition, c.edition}, hasLength(3));
      expect(
        SupabaseBootstrapSql.assemble(readModelsSql: rm).edition,
        b.edition,
      );
    });
  });

  group('⑤ 복구 코드 해시', () {
    const String salt1 = '00112233445566778899aabbccddeeff';
    test('Postgres 가 계산한 고정 벡터와 같다(정규화 포함)', () {
      // 벡터 = PGlite(Postgres 16) `encode(sha256(convert_to(salt || ':' || upper(regexp_replace(code, '[^0-9A-Za-z]', '', 'g')), 'UTF8')), 'hex')`.
      const String d1 =
          'd8f1603121808b8a4d01a5fa3af78642104b1e575b683c2215fb53b019136737';
      expect(
        recoveryCodeHash('ABCDE-FGHJK-MNPQR-STUVW', saltHex: salt1),
        'sha256:$salt1:$d1',
      );
      expect(
        recoveryCodeHash(' abcde fghjk-mnpqr stuvw ', saltHex: salt1),
        'sha256:$salt1:$d1',
      );
      expect(
        recoveryCodeHash(
          'wxyz2-34567-abcde-fghjk',
          saltHex: 'ffeeddccbbaa99887766554433221100',
        ),
        'sha256:ffeeddccbbaa99887766554433221100:'
        'e37e280b0d7ec8251173416a73d8c92411e9aa81766f71d41de60254e4b1b862',
      );
      // 영숫자 밖(한글 포함)은 지운다 — 서버 `[^0-9A-Za-z]` 와 같다.
      expect(normalizeRecoveryCode('가A1-b2'), 'A1B2');
      expect(
        recoveryCodeHash('가A1-b2', saltHex: '0123456789abcdef0123456789abcdef'),
        'sha256:0123456789abcdef0123456789abcdef:'
        '9a71d33f71663207b3493231a5c63a7afc81f07e061cc23f61552c0fa6a36a1b',
      );
    });

    test('꼴 아님 = null(소금 길이 · 대문자 소금 · 빈 코드)', () {
      expect(recoveryCodeHash('ABC', saltHex: '0011'), isNull);
      expect(recoveryCodeHash('ABC', saltHex: salt1.toUpperCase()), isNull);
      expect(recoveryCodeHash(' - - ', saltHex: salt1), isNull);
      expect(recoveryCodeHash('', saltHex: salt1), isNull);
    });

    test('해시 꼴 = 서버 정규식과 같은 글자(SQL 원문에서 읽는다)', () {
      final Set<String> server = RegExp(r"!~ '(\^sha256[^']*)'")
          .allMatches(_rpc)
          .map((RegExpMatch m) => m.group(1)!)
          .toSet();
      expect(server, <String>{kRecoveryCodeHashShape.pattern});
      expect(
        kRecoveryCodeHashShape.hasMatch(
          recoveryCodeHash('ABCDE', saltHex: salt1)!,
        ),
        isTrue,
      );
    });
  });
}
