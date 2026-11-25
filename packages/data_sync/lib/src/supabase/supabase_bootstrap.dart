// o_07 ① Supabase 부트스트랩 SQL 묶음 — 발주자가 SQL Editor 에 붙여 넣는 전문(E11k-e2 · 설계 13 §8 R221 · 계약 v1.29 01 §39 K232 ·
// 01 §6-4 «앱이 SQL 텍스트를 표시하고 발주자가 붙여 넣는다»(X3 ⑨ — `service_role` 미보관) · 06 M4-1 ① · M4-3).
//
// 🔵 조각 차례 = ① 배치 D(계약 사본 `domain_contracts/ddl/batch_d_supabase.sql` 원문) → ② operator 리스 RPC 본문
//    (`data_sync/sql/supabase_lease_rpc.sql`) → ③ 읽기 모델 `rm_*`(E11l1 생성기 출력) → ④ 읽기 모델 push RPC 본문
//    (`data_sync/sql/supabase_read_model_push_rpc.sql` · 🆕 E11l2 · 13 §8 R254 · 01 §47 — 쓰는 표가 다 선 다음) →
//    ⑤ 운영 폰 공유 표 push RPC 본문(`data_sync/sql/supabase_ops_push_rpc.sql` · 🆕 01 §8 미결 229 · 13 §8 R270 — rm_* 밖 쓰기 표 다섯) →
//    ⑥ 뷰어 페어링 RPC · 명령 표 읽는 함수 본문(`data_sync/sql/supabase_command_pairing_rpc.sql` · 🆕 01 §8 미결 246 · 13 §8 R272 — 티켓 ·
//    클레임 · 폐기 · `command_open` · `command_status`(NO_OPERATOR 서버 판정 · G-26) — 이주 장치가 없어 첫 판에 싣는다).
//    ① · ② · ④ · ⑤ · ⑥ = `supabase_bootstrap_sources.dart`(생성 · 바이트 대조 시험) · ③ = [SupabaseBootstrapSql.assemble] 인자.
// 🔵 판 = 여섯 조각 원문의 sha256 앞 12 — ③ 이 들어오거나 원문 하나가 바뀌면 판이 바뀐다(«같은 판» = 이 묶음 하나 · 따로 붙여 넣는 조각 0).
// 🔴 ③ 없음 = 미완 판(`complete` false) — o_07 ① 은 보이지 않는다(K232 · E11l1 뒤) · 잘못 보여도 첫 문장이 멈춘다(부분 적용 0 —
//    부분 적용 뒤에는 «이미 적용됨» 가드가 완성 판까지 막는다).
// 🔴 한 트랜잭션(`begin` … `commit`) — 중간 실패 = 아무것도 바뀌지 않는다 · 이미 적용된 프로젝트(`operator_lease` 있음) = 첫 문장에서 멈춘다.
//    판 올림(이미 적용된 프로젝트의 다음 판)은 이 묶음이 아니라 따로 이주 SQL 몫이다.
// 🔴 묶음 글자 = 공개 저장소 원문뿐 — 주소 · ref · 키 · 토큰 0.

import 'dart:convert';

import 'package:crypto/crypto.dart' show sha256;

import 'supabase_bootstrap_sources.dart';

/// 🆕 부트스트랩 SQL 묶음 한 판.
class SupabaseBootstrapSql {
  const SupabaseBootstrapSql._({
    required this.text,
    required this.edition,
    required this.complete,
  });

  /// 묶는다 — [readModelsSql] = E11l1 `rm_*` 생성기 출력(없음 · 빈칸 = 미완 판).
  factory SupabaseBootstrapSql.assemble({String? readModelsSql}) {
    final String? rm = (readModelsSql == null || readModelsSql.trim().isEmpty)
        ? null
        : readModelsSql;
    final String edition = sha256
        .convert(
          utf8.encode(
            '$kSupabaseBatchDSql\u0000$kSupabaseLeaseRpcSql\u0000${rm ?? ''}\u0000$kSupabaseReadModelPushRpcSql\u0000$kSupabaseOpsPushRpcSql\u0000$kSupabaseCommandPairingRpcSql',
          ),
        )
        .toString()
        .substring(0, 12);
    final bool complete = rm != null;
    final StringBuffer b = StringBuffer()
      ..writeln('-- AutoAlphaQuant Supabase 부트스트랩 SQL — 판 $edition')
      ..writeln(
        '-- Supabase 대시보드 → SQL Editor 에 이 전문을 그대로 붙여 넣고 Run 을 한 번 누릅니다.',
      )
      ..writeln(
        '-- 한 트랜잭션입니다 — 중간에 실패하면 아무것도 바뀌지 않습니다. 이미 적용된 프로젝트에서는 첫 문장에서 멈춥니다.',
      )
      ..writeln('begin;')
      ..writeln();
    if (!complete) {
      b
        ..writeln(r'do $incomplete$')
        ..writeln('begin')
        ..writeln(
          "  raise exception 'AAQ 부트스트랩 SQL 판 $edition 은 미완입니다(읽기 모델 조각 없음) — 붙여 넣지 마십시오. 아무것도 바뀌지 않았습니다.';",
        )
        ..writeln('end')
        ..writeln(r'$incomplete$;')
        ..writeln();
    }
    b
      ..writeln(r'do $guard$')
      ..writeln('begin')
      ..writeln("  if to_regclass('public.operator_lease') is not null then")
      ..writeln(
        "    raise exception 'AAQ 부트스트랩 SQL 이 이미 적용된 프로젝트입니다 — 아무것도 바꾸지 않고 멈춥니다.';",
      )
      ..writeln('  end if;')
      ..writeln('end')
      ..writeln(r'$guard$;')
      ..writeln()
      ..writeln(
        '-- ════ 1/6 배치 D — 계약 사본(packages/domain_contracts/ddl/batch_d_supabase.sql) ════',
      )
      ..write(kSupabaseBatchDSql)
      ..writeln()
      ..writeln(
        '-- ════ 2/6 operator 리스 RPC(packages/data_sync/sql/supabase_lease_rpc.sql) ════',
      )
      ..write(kSupabaseLeaseRpcSql)
      ..writeln()
      ..writeln('-- ════ 3/6 읽기 모델 rm_*(E11l1 생성기) ════');
    if (rm != null) {
      b.write(rm);
      if (!rm.endsWith('\n')) b.writeln();
    } else {
      b.writeln('-- (없음 — 미완 판)');
    }
    b
      ..writeln()
      ..writeln(
        '-- ════ 4/6 읽기 모델 push RPC(packages/data_sync/sql/supabase_read_model_push_rpc.sql) ════',
      )
      ..write(kSupabaseReadModelPushRpcSql)
      ..writeln()
      ..writeln(
        '-- ════ 5/6 운영 폰 공유 표 push RPC(packages/data_sync/sql/supabase_ops_push_rpc.sql) ════',
      )
      ..write(kSupabaseOpsPushRpcSql)
      ..writeln()
      ..writeln(
        '-- ════ 6/6 뷰어 페어링 RPC · 명령 표 읽는 함수(packages/data_sync/sql/supabase_command_pairing_rpc.sql) ════',
      )
      ..write(kSupabaseCommandPairingRpcSql)
      ..writeln()
      ..writeln('commit;');
    return SupabaseBootstrapSql._(
      text: b.toString(),
      edition: edition,
      complete: complete,
    );
  }

  /// 붙여 넣을 전문.
  final String text;

  /// 판(여섯 조각 원문 sha256 앞 12 · 소문자 16진).
  final String edition;

  /// 여섯 조각이 다 있다(③ 생성기 출력이 들어왔다 — o_07 ① 에 보여도 된다).
  final bool complete;

  @override
  String toString() =>
      'SupabaseBootstrapSql($edition${complete ? '' : ' · 미완'})';
}
