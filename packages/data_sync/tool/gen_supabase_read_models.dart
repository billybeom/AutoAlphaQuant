// 🆕 E11l1(설계 13 §8 R246) — 읽기 모델 골든 `sql/supabase_read_models.sql` 을 다시 뽑는다.
//
// 쓰는 법(packages/data_sync 에서): dart run tool/gen_supabase_read_models.dart [--dump <폴더>]
//   --dump = PGlite 하네스(tool/pglite/read_models_harness.mjs) 입력 bootstrap_full.sql · bootstrap_incomplete.sql 도 쓴다.
// 🔴 골든은 손으로 고치지 않는다 — 계약 `ReadModelTables` 가 바뀌면 이 대본을 돌리고, 시험
//    (`test/supabase_read_models_test.dart`)이 생성기 출력과 바이트로 대조한다.

import 'dart:io';

import 'package:data_sync/src/supabase/supabase_bootstrap.dart'
    show SupabaseBootstrapSql;
import 'package:data_sync/src/supabase/supabase_read_models.dart'
    show supabaseReadModelsSql;

void main(List<String> args) {
  final File out = File.fromUri(
    Platform.script.resolve('../sql/supabase_read_models.sql'),
  );
  final String sql = supabaseReadModelsSql();
  out.writeAsStringSync(sql);
  stdout.writeln('${out.path}: ${sql.length} chars');
  final int i = args.indexOf('--dump');
  if (i >= 0 && i + 1 < args.length) {
    final String dir = args[i + 1];
    File(
      '$dir/bootstrap_full.sql',
    ).writeAsStringSync(SupabaseBootstrapSql.assemble(readModelsSql: sql).text);
    File('$dir/bootstrap_incomplete.sql')
        .writeAsStringSync(SupabaseBootstrapSql.assemble().text);
    stdout.writeln('$dir: bootstrap_full.sql · bootstrap_incomplete.sql');
  }
}
