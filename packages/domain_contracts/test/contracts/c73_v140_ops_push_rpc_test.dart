// C-73 운영 폰 공유 표 push RPC 표 · 배치 D 옛 4표 select — 01 §49
// (🆕 계약 v1.40 · 발주자 위임 2026-11-14 — 권고대로 · K353~ · 01 §8 미결 229 · 222 ⓕ · 13 §8 R270 W1~W8).
//
// 정의: 「`rm_*` 밖 배치 D 쓰기 표 다섯 = `op_push` 1창구 · 인자 · 반환 = `rm_push` 글자 · 거부 = 리스 2 ∪ 고유 2 ·
//        표 목록 = 배치 D 표 다섯(차례 그대로 · `rm_*` 와 서로소) · 옛 4표 select 본문 = K311(ACTIVE 기기) ·
//        다섯 표 클라이언트 쓰기 정책 0」.
//   ① 판 · 표본 ② 이름 ③ 인자 ④ 반환 칸 ⑤ 거부 사전 · 도메인 ⑥ 표 다섯 ⑦ 배치 D select 본문 · 쓰기 정책 0 ⑧ 글자 꼴.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

String _batchD() =>
    File('${ddlDir.path}/batch_d_supabase.sql').readAsStringSync();

/// 주석(`-- …` 줄 끝까지)을 뺀 배치 D.
String _batchDCode() => _batchD().replaceAll(RegExp(r'--[^\n]*'), '');

/// 표 하나에 걸린 정책 문장(`create policy … on <표> …;`) 전부.
List<String> _policiesOn(String table) =>
    RegExp('create policy (\\w+) on $table\\b[^;]*;')
        .allMatches(_batchDCode())
        .map((RegExpMatch m) => m.group(0)!)
        .toList();

void main() {
  group('C-73 운영 폰 공유 표 push RPC (01 §49)', () {
    test('C-73 ① 판 · 표본 — 1.40.0 · 402(버전 줄만) · 봉투 판 = 계약 판', () {
      expect(contractVersion, '1.40.0');
      expect(FixturePaths.all, hasLength(402));
      expect(allFixtureFilesOnDisk(), hasLength(402));
      for (final String path in FixturePaths.all) {
        final Map<String, Object?> meta =
            (jsonDecode(readFixture(path)) as Map<String, Object?>)['meta']!
                as Map<String, Object?>;
        expect(meta['contract_version'], contractVersion, reason: path);
      }
    });

    test('C-73 ② 이름 — op_push 하나 · 리스 · 넘김 · rm_push 와 겹침 0', () {
      expect(OpsPushRpcNames.values, <String>{'op_push'});
      expect(OpsPushRpcNames.push, 'op_push');
      expect(
        OpsPushRpcNames.values.intersection(<String>{
          ...LeaseRpcNames.values,
          ...LeaseHandoverRpcNames.values,
          ...ReadModelPushRpcNames.values,
        }),
        isEmpty,
      );
    });

    test(
      'C-73 ③ 인자 — 4 · rm_push 글자 그대로(기기 · epoch = 리스 글자) · 서버가 덮는 칸은 인자 아님',
      () {
        expect(OpsPushRpcParams.values, <String>{
          'p_device_id',
          'p_epoch',
          'p_table',
          'p_rows',
        });
        expect(OpsPushRpcParams.values, ReadModelPushRpcParams.values);
        expect(OpsPushRpcParams.deviceId, LeaseRpcParams.deviceId);
        expect(OpsPushRpcParams.epoch, LeaseRpcParams.epoch);
        for (final String p in OpsPushRpcParams.values) {
          expect(p, startsWith('p_'));
          for (final String server in <String>[
            'lease_epoch',
            'operator_epoch',
            'acked_at',
            'updated_at',
            'stamped_at',
          ]) {
            expect(p, isNot(contains(server)), reason: '$p · $server');
          }
        }
      },
    );

    test(
      'C-73 ④ 반환 칸 — 한 행 4 · rm_push 반환 글자 그대로 · code · epoch = 리스 반환 글자',
      () {
        expect(OpsPushRpcColumns.values, <String>{
          'code',
          'epoch',
          'accepted',
          'skipped',
        });
        expect(OpsPushRpcColumns.values, ReadModelPushRpcColumns.values);
        expect(OpsPushRpcColumns.code, LeaseRpcColumns.code);
        expect(OpsPushRpcColumns.epoch, LeaseRpcColumns.epoch);
      },
    );

    test(
      'C-73 ⑤ 거부 — 고유 2 · 도메인 등재 · 리스 · 넘김 · rm_push 사전과 서로소 · 리스 공용 2 재사용',
      () {
        expect(OpsPushResultCodes.values, <String>{
          'OPS_PUSH_TABLE_UNKNOWN',
          'OPS_PUSH_ROWS_INVALID',
        });
        expect(
          ContractCodes.byDomain['ops_push_result'],
          OpsPushResultCodes.values,
        );
        expect(
          OpsPushResultCodes.values.intersection(<String>{
            ...LeaseRpcResultCodes.values,
            ...LeaseHandoverResultCodes.values,
            ...ReadModelPushResultCodes.values,
          }),
          isEmpty,
        );
        expect(
          LeaseRpcResultCodes.values,
          containsAll(<String>[
            LeaseRpcResultCodes.lost,
            LeaseRpcResultCodes.deviceNotEligible,
          ]),
        );
      },
    );

    test('C-73 ⑥ 표 다섯 — 배치 D 표 · 그 파일 차례 · rm_* 와 서로소 · 겹침 0', () {
      expect(OpsPushTables.all, <String>[
        'command_ack',
        'planned_work_mirror',
        'resume_run_mirror',
        'ledger_stamp',
        'calendar_sync_status',
      ]);
      expect(OpsPushTables.all.toSet(), hasLength(OpsPushTables.all.length));
      final String d = _batchD();
      int last = -1;
      for (final String t in OpsPushTables.all) {
        final int at = d.indexOf('create table if not exists $t (');
        expect(at, greaterThan(last), reason: '$t — 배치 D 에 있고 차례 그대로');
        last = at;
      }
      expect(
        OpsPushTables.all.toSet().intersection(
          ReadModelTables.all.map((ReadModelTable t) => t.name).toSet(),
        ),
        isEmpty,
      );
      for (final String t in OpsPushTables.all) {
        expect(t, isNot(startsWith('rm_')));
      }
    });

    test('C-73 ⑦ 배치 D — 옛 4표 select = K311 본문 · ack select 무변경 · 다섯 표 쓰기 정책 0 · using (true) = 리스 표만', () {
      for (final String t in <String>[
        OpsPushTables.plannedWorkMirror,
        OpsPushTables.resumeRunMirror,
        OpsPushTables.ledgerStamp,
        OpsPushTables.calendarSyncStatus,
      ]) {
        final List<String> ps = _policiesOn(t);
        expect(ps, hasLength(1), reason: t);
        final String p = ps.single.replaceAll(RegExp(r'\s+'), ' ');
        expect(
          p,
          'create policy ${ReadModelRls.selectPolicyName(t)} on $t for select to '
          '${ReadModelRls.selectRole} using (${ReadModelRls.selectUsing});',
          reason: t,
        );
        expect(
          _batchDCode(),
          contains('alter table $t enable row level security;'),
        );
      }
      // command_ack = 보이는 명령의 ack(v1.34) 그대로 — 뷰어 = 소유자 명령의 ack.
      final List<String> ack = _policiesOn(OpsPushTables.commandAck);
      expect(ack, hasLength(1));
      expect(
        ack.single.replaceAll(RegExp(r'\s+'), ' '),
        'create policy command_ack_select on command_ack for select to authenticated '
        'using (exists (select 1 from command_queue q where q.command_id = command_ack.command_id));',
      );
      // 다섯 표 모두 select 정책 하나뿐 — INSERT · UPDATE · DELETE · ALL 정책 0(쓰기 = op_push 만).
      for (final String t in OpsPushTables.all) {
        for (final String p in _policiesOn(t)) {
          expect(p, contains(' for select '), reason: t);
        }
      }
      // `using (true)` 남은 곳 = `operator_lease`(R-01 클레임 전 읽기 · R248) 하나.
      final List<String> open = RegExp(
        r'create policy \w+ on (\w+)[^;]*using \(true\)',
      ).allMatches(_batchDCode()).map((RegExpMatch m) => m.group(1)!).toList();
      expect(open, <String>['operator_lease']);
      // 머리 주석 — ack 쓰기 = op_push 만 · append-only(옛 «엔진(operator)만 INSERT» 0).
      final String d = _batchD();
      final String head = d.substring(
        d.indexOf('create table if not exists command_ack ('),
        d.indexOf('\n', d.indexOf('create table if not exists command_ack (')),
      );
      expect(head, contains('op_push 만'));
      expect(head, contains('append-only'));
      expect(d, isNot(contains('엔진(operator)만 INSERT')));
    });

    test('C-73 ⑧ 글자 꼴 — 코드 = 대문자 snake · OPS_PUSH_ 접두 · 표 = 소문자 snake', () {
      for (final String c in OpsPushResultCodes.values) {
        expect(c, matches(RegExp(r'^OPS_PUSH_[A-Z0-9_]+$')));
      }
      for (final String t in OpsPushTables.all) {
        expect(t, matches(RegExp(r'^[a-z][a-z0-9_]+$')));
      }
    });
  });
}
