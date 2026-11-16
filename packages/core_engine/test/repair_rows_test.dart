// E16d2 — X5 정정 이력 표시 행 빌더(설계 13 §8 R123 G1~G6 · 픽스처 `m6/ledger_repairs_4`).
//
// 🔵 잡는 것: ① 픽스처 4행 1:1(차례 · 문장 · 대상 · 방향 · 색 · 원인 · 적용 글 · 결정 링크 · «이후 정정됨» · 체인 축약)
//    ② 묶음 = 원본 시각 역순 · 묶음 안 = 사슬 차례 · 고아 = 원본 · 고리 · 같은 id = StateError
//    ③ 대상 종류 닫힌 목록 · 방향 ↔ 종류 · 원인 사전 밖 = 실패 ④ 새 기준점 = 숨김 · 시계열 · 아카이브 문장.
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

List<Map<String, dynamic>> _fixtureRows() =>
    ((jsonDecode(
              File('../domain_contracts/fixtures/m6/ledger_repairs_4.json')
                  .readAsStringSync(),
            ) as Map<String, dynamic>)['rows']
            as List<dynamic>)
        .cast<Map<String, dynamic>>();

String _chain(String head, String tail) => '$head${'0' * 58}$tail';

StoredLedgerRepair _s(
  String id, {
  String diff = 'ld_x',
  String direction = 'CANON_CORRECT',
  String origin = 'FILL_LAG',
  String evidence = 'ev_x',
  required DateTime at,
  String chain = '',
  Map<String, Object?> target = const <String, Object?>{
    'kind': 'QUANTITY',
    'symbol': '069500',
    'before': 1,
    'after': 2,
  },
  String? decision = 'd_x',
  String? supersedes,
  String? from,
}) => StoredLedgerRepair(
  repairId: id,
  diffId: diff,
  direction: direction,
  originCode: origin,
  evidenceHash: evidence,
  appliedAtUtc: at,
  chainHash: chain.isEmpty ? 'ab' * 32 : chain,
  targetJson: jsonEncode(target),
  decisionId: decision,
  supersedes: supersedes,
  recomputedFrom: from,
);

/// 픽스처 4행의 저장판 — 일부러 섞인 차례.
final List<StoredLedgerRepair> _stored = <StoredLedgerRepair>[
  _s(
    'rp_0004',
    diff: 'ld_0001',
    origin: 'MANUAL_ORDER',
    evidence: 'ev_rp_d05c3a62',
    at: DateTime.utc(2026, 8, 29, 3, 40),
    chain: _chain('a21d', '7e'),
    target: const <String, Object?>{
      'kind': 'QUANTITY',
      'symbol': '069500',
      'before': 132,
      'after': 130,
    },
    decision: 'd_rp_0004',
    supersedes: 'rp_0003',
    from: '2026-08-26',
  ),
  _s(
    'rp_0001',
    diff: 'ld_0004',
    direction: 'DERIVED_RESYNC',
    origin: 'CAL_WRITE_FAILED',
    evidence: 'ev_rp_8a1f42c0',
    at: DateTime.utc(2026, 8, 28, 1, 30),
    chain: _chain('05e7', '9b'),
    target: const <String, Object?>{'kind': 'CALENDAR_EVENTS', 'count': 1},
    decision: null,
  ),
  _s(
    'rp_0003',
    diff: 'ld_0001',
    evidence: 'ev_rp_1f84b7e3',
    at: DateTime.utc(2026, 8, 28, 2, 2),
    chain: _chain('7f3a', 'c2'),
    target: const <String, Object?>{
      'kind': 'QUANTITY',
      'symbol': '069500',
      'before': 120,
      'after': 132,
    },
    decision: 'd_rp_0003',
    from: '2026-08-24',
  ),
  _s(
    'rp_0002',
    diff: 'ld_0002',
    direction: 'DERIVED_RESYNC',
    origin: 'PUSH_LAG',
    evidence: 'ev_rp_6c2d90a1',
    at: DateTime.utc(2026, 8, 30, 2, 15),
    chain: _chain('3b9e', '41'),
    target: const <String, Object?>{'kind': 'MIRROR_EXEC_ROWS', 'count': 2},
    decision: null,
  ),
];

void main() {
  test('🔴 픽스처 ledger_repairs_4 — 4행 1:1(차례 포함)', () {
    final List<LedgerRepairRow> got = ledgerRepairRowsOf(_stored);
    final List<LedgerRepairRow> want = _fixtureRows()
        .map(LedgerRepairRow.fromJson)
        .toList();
    expect(got.map((LedgerRepairRow r) => r.repairId), <String>[
      'rp_0002',
      'rp_0003',
      'rp_0004',
      'rp_0001',
    ]);
    for (int i = 0; i < want.length; i++) {
      expect(got[i], want[i], reason: want[i].repairId);
    }
  });

  test('🔴 묶음 = 원본 시각 역순 — 뒤 정정이 붙어도 묶음은 원본 자리', () {
    final DateTime t0 = DateTime.utc(2026, 9, 1);
    final List<LedgerRepairRow> r = ledgerRepairRowsOf(<StoredLedgerRepair>[
      _s('a', at: t0),
      _s('b', at: t0.add(const Duration(days: 1))),
      _s('a2', at: t0.add(const Duration(days: 5)), supersedes: 'a'),
      _s('a3', at: t0.add(const Duration(days: 6)), supersedes: 'a2'),
    ]);
    expect(r.map((LedgerRepairRow x) => x.repairId), <String>[
      'b',
      'a',
      'a2',
      'a3',
    ]);
    expect(r.map((LedgerRepairRow x) => x.supersededLabel), <String?>[
      null,
      kRepairSupersededLabel,
      kRepairSupersededLabel,
      null,
    ]);
  });

  test('같은 원본의 정정 둘 = 시각 차례 · 같은 시각 원본 = id 차례', () {
    final DateTime t0 = DateTime.utc(2026, 9, 1);
    final List<LedgerRepairRow> r = ledgerRepairRowsOf(<StoredLedgerRepair>[
      _s('z', at: t0),
      _s('y', at: t0),
      _s('z-late', at: t0.add(const Duration(hours: 2)), supersedes: 'z'),
      _s('z-early', at: t0.add(const Duration(hours: 1)), supersedes: 'z'),
    ]);
    expect(r.map((LedgerRepairRow x) => x.repairId), <String>[
      'y',
      'z',
      'z-early',
      'z-late',
    ]);
  });

  test('🔴 대체 대상이 목록 밖 = 그 행이 원본 · 고리 · 같은 id = StateError', () {
    final DateTime t0 = DateTime.utc(2026, 9, 1);
    final List<LedgerRepairRow> r = ledgerRepairRowsOf(<StoredLedgerRepair>[
      _s('orphan', at: t0, supersedes: 'gone'),
    ]);
    expect(r.single.supersedes, 'gone');
    expect(r.single.supersededLabel, isNull);
    expect(
      () => ledgerRepairRowsOf(<StoredLedgerRepair>[
        _s('p', at: t0, supersedes: 'q'),
        _s('q', at: t0, supersedes: 'p'),
      ]),
      throwsStateError,
    );
    expect(
      () => ledgerRepairRowsOf(<StoredLedgerRepair>[
        _s('p', at: t0),
        _s('p', at: t0),
      ]),
      throwsStateError,
    );
    expect(ledgerRepairRowsOf(const <StoredLedgerRepair>[]), isEmpty);
  });

  test('🔴 새 기준점 · 아카이브 · 시계열 문장 · 대상', () {
    final DateTime t0 = DateTime.utc(2026, 9, 1);
    final StoredLedgerRepair base = _s(
      'li',
      origin: 'CHAIN_BROKEN',
      at: t0,
      target: const <String, Object?>{'kind': 'LEDGER_INTEGRITY'},
      from: '2026-08-20',
    );
    expect(repairTargetTextOf(base), '숨김');
    expect(repairLabelOf(base), '새 기준점 선언 · 다시 스탬프 · 2026-08-20부터 재계산');
    final StoredLedgerRepair arch = _s(
      'ar',
      direction: 'DERIVED_RESYNC',
      origin: 'ARCHIVE_LAG',
      at: t0,
      target: const <String, Object?>{'kind': 'ARCHIVE_DAYS', 'count': 3},
      decision: null,
    );
    expect(
      (repairTargetTextOf(arch), repairLabelOf(arch)),
      ('아카이브 3일', '아카이브 3일을 다시 썼습니다'),
    );
    final StoredLedgerRepair ts = _s(
      'ts',
      direction: 'DERIVED_RESYNC',
      origin: 'MISRECORDED_FILL',
      at: t0,
      target: const <String, Object?>{'kind': 'TIMESERIES'},
      decision: null,
      from: '2026-08-10',
    );
    expect(
      (repairTargetTextOf(ts), repairLabelOf(ts)),
      ('시계열 재계산', '시계열을 다시 계산했습니다 · 2026-08-10부터 재계산'),
    );
    final LedgerRepairRow row = ledgerRepairRowOf(ts, superseded: false);
    expect((row.directionTone, row.decisionLink), (ChipTone.neutral, null));
  });

  test('🔴 실패 — 모르는 종류 · 방향 ↔ 종류 · 원인 사전 밖 · 칸 꼴', () {
    final DateTime t0 = DateTime.utc(2026, 9, 1);
    expect(
      () => repairTargetTextOf(
        _s('x', at: t0, target: const <String, Object?>{'kind': 'POSITIONS'}),
      ),
      throwsFormatException,
    );
    expect(
      () => repairLabelOf(
        _s(
          'x',
          at: t0,
          target: const <String, Object?>{
            'kind': 'MIRROR_EXEC_ROWS',
            'count': 1,
          },
        ),
      ),
      throwsFormatException,
      reason: '정본 정정에 파생 종류',
    );
    expect(
      () => repairLabelOf(
        _s('x', direction: 'DERIVED_RESYNC', at: t0, decision: null),
      ),
      throwsFormatException,
      reason: '파생 재생성에 수량 종류',
    );
    expect(
      () => repairLabelOf(_s('x', origin: 'PUSH_LAG', at: t0)),
      throwsArgumentError,
    );
    expect(
      () =>
          ledgerRepairRowOf(_s('x', origin: 'NOPE', at: t0), superseded: false),
      throwsArgumentError,
    );
    expect(
      () => repairTargetTextOf(
        _s(
          'x',
          direction: 'DERIVED_RESYNC',
          at: t0,
          target: const <String, Object?>{
            'kind': 'CALENDAR_EVENTS',
            'count': -1,
          },
        ),
      ),
      throwsFormatException,
    );
    expect(
      () => ledgerRepairRowOf(_s('x', at: t0, chain: 'xyz'), superseded: false),
      throwsArgumentError,
    );
  });

  test('원인 구 사전 = 정본 정정에 쓰일 수 있는 원인 전부', () {
    final Set<String> canon = <String>{
      ...repairOriginCodesFor(
        RepairDirection.canonCorrect,
        LedgerPair.canonBroker,
      ),
      ...repairOriginCodesFor(
        RepairDirection.canonCorrect,
        LedgerPair.canonSelfReport,
      ),
      ...kBaselineOriginCodes,
    };
    expect(kRepairReasonPhrases.keys.toSet().containsAll(canon), isTrue);
  });
}
