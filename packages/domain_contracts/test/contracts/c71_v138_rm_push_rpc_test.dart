// C-71 읽기 모델 push RPC 표 — 01 §47
// (🆕 계약 v1.38 · 발주자 위임 2026-11-14 — 권고대로 · K330~K337 · 13 §8 R251).
//
// 정의: 「`rm_*` 쓰기 = `rm_push` 1창구 · 인자 4(기기 · epoch = 리스 글자 · 표 · 행) · 반환 한 행 4 ·
//        거부 = 리스 2 ∪ 고유 2 · 서버가 덮는 칸(`lease_epoch` · `pushed_at`)은 인자가 아니다」.
//   ① 판 · 표본 ② 이름 ③ 인자 ④ 반환 칸 ⑤ 거부 사전 · 도메인 ⑥ 글자 꼴.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

void main() {
  group('C-71 읽기 모델 push RPC 표 (01 §47)', () {
    test('C-71 ① 판 · 표본 — 1.38.0 · 398(버전 줄만)', () {
      expect(contractVersion, '1.38.0');
      expect(FixturePaths.all, hasLength(398));
      expect(allFixtureFilesOnDisk(), hasLength(398));
    });

    test('C-71 ② 이름 — rm_push 하나 · 리스 RPC 와 겹침 0', () {
      expect(ReadModelPushRpcNames.values, <String>{'rm_push'});
      expect(ReadModelPushRpcNames.push, 'rm_push');
      expect(
        ReadModelPushRpcNames.values.intersection(<String>{
          ...LeaseRpcNames.values,
          ...LeaseHandoverRpcNames.values,
        }),
        isEmpty,
      );
    });

    test('C-71 ③ 인자 — 4 · 기기 · epoch = 리스 글자 · 서버가 덮는 칸은 인자 아님', () {
      expect(ReadModelPushRpcParams.values, <String>{
        'p_device_id',
        'p_epoch',
        'p_table',
        'p_rows',
      });
      expect(ReadModelPushRpcParams.deviceId, LeaseRpcParams.deviceId);
      expect(ReadModelPushRpcParams.epoch, LeaseRpcParams.epoch);
      for (final String p in ReadModelPushRpcParams.values) {
        expect(p, startsWith('p_'));
        expect(p, isNot(contains('lease_epoch')));
        expect(p, isNot(contains('pushed_at')));
      }
    });

    test('C-71 ④ 반환 칸 — 한 행 4 · code · epoch = 리스 반환 글자', () {
      expect(ReadModelPushRpcColumns.values, <String>{
        'code',
        'epoch',
        'accepted',
        'skipped',
      });
      expect(ReadModelPushRpcColumns.code, LeaseRpcColumns.code);
      expect(ReadModelPushRpcColumns.epoch, LeaseRpcColumns.epoch);
    });

    test('C-71 ⑤ 거부 — 고유 2 · 도메인 등재 · 리스 사전과 서로소 · 합집합 = 리스 공용 2 ∪ 고유 2', () {
      expect(ReadModelPushResultCodes.values, <String>{
        'READ_MODEL_TABLE_UNKNOWN',
        'READ_MODEL_ROWS_INVALID',
      });
      expect(
        ContractCodes.byDomain['read_model_push_result'],
        ReadModelPushResultCodes.values,
      );
      expect(
        ReadModelPushResultCodes.values.intersection(<String>{
          ...LeaseRpcResultCodes.values,
          ...LeaseHandoverResultCodes.values,
        }),
        isEmpty,
      );
      // 리스 거부 중 push 가 쓰는 둘(다시 적지 않는다 — K333).
      expect(
        LeaseRpcResultCodes.values,
        containsAll(<String>[
          LeaseRpcResultCodes.lost,
          LeaseRpcResultCodes.deviceNotEligible,
        ]),
      );
    });

    test('C-71 ⑥ 글자 꼴 — 표 이름 = rm_ 접두(읽기 모델 표만 받는다) · 코드 = 대문자 snake', () {
      for (final ReadModelTable t in ReadModelTables.all) {
        expect(t.name, startsWith('rm_'));
      }
      for (final String c in ReadModelPushResultCodes.values) {
        expect(c, matches(RegExp(r'^[A-Z][A-Z0-9_]+$')));
      }
    });
  });
}
