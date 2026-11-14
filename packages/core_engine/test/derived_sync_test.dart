// E16a — X5-4 파생 ↔ 정본 관계 · 동기 조치 · 체인 diff(순수 · 설계 13 §8 R112 · 지도 e16-map D4).
//
// 🔵 잡는 것: ① epoch 먼저(체인이 같아도 높은 epoch = FORK) ② 앞섬 · 갈라짐 · 정본 첫 날보다 앞 = FORK
//    ③ 새 기준점(`fromDate ≤ 파생 날`) = REBASED ④ FORK 끈적 · FORK 판정은 리스 무관 · 봉인보다 FORK 먼저
//    ⑤ 재생성 = 리스 유효 ∧ 일 상한 안 · 시작 날(EMPTY 첫 날 · BEHIND 다음 날 · REBASED 가장 이른 기준점)
//    ⑥ 파생 diff = 늘 관측 · 후보 ⊂ 파생 쓰기 코드 · diffId 결정적.
import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

String _h(int n) => n.toRadixString(16).padLeft(64, '0');

const List<String> _days = <String>[
  '2026-11-10',
  '2026-11-11',
  '2026-11-12',
  '2026-11-13',
  '2026-11-14',
];

/// 정본 11-10 ~ 11-14 · 체인 = 날 끝자리(10 ~ 14).
CanonChain _canon({
  int epoch = 1,
  List<ChainBaseline> baselines = const <ChainBaseline>[],
}) => CanonChain(
  stamps: <StoredDayStamp>[
    for (final String d in _days)
      StoredDayStamp(
        authoredDate: d,
        dayHash: _h(900),
        chainHash: _h(int.parse(d.substring(8))),
        hashFormatVersion: 1,
      ),
  ],
  operatorEpoch: epoch,
  baselines: baselines,
);

CanonChain _emptyCanon() =>
    CanonChain(stamps: const <StoredDayStamp>[], operatorEpoch: 1);

DerivedStamp _d(String date, int chain, {int epoch = 1}) => DerivedStamp(
  authoredDate: date,
  chainHash: _h(chain),
  operatorEpoch: epoch,
);

DerivedSyncAction _act(
  DerivedRelation relation, {
  DerivedSyncStatus current = DerivedSyncStatus.ok,
  LeaseVerdict lease = LeaseVerdict.valid,
  int resyncsToday = 0,
  int dailyCap = 3,
  CanonChain? canon,
  DerivedStamp? derived,
}) => derivedSyncActionOf(
  relation: relation,
  current: current,
  lease: lease,
  resyncsToday: resyncsToday,
  dailyCap: dailyCap,
  canon: canon ?? _canon(),
  derived: derived,
);

/// 비동기 관계 6 — 각 관계를 만드는 (정본, 파생).
final Map<DerivedRelation, (CanonChain, DerivedStamp?)> _cases =
    <DerivedRelation, (CanonChain, DerivedStamp?)>{
      DerivedRelation.empty: (_canon(), null),
      DerivedRelation.behind: (_canon(), _d('2026-11-12', 12)),
      DerivedRelation.rebased: (
        _canon(
          baselines: const <ChainBaseline>[
            ChainBaseline(fromDate: '2026-11-12', decisionId: 'dec-1'),
          ],
        ),
        _d('2026-11-13', 777),
      ),
      DerivedRelation.ahead: (_canon(), _d('2026-11-15', 15)),
      DerivedRelation.diverged: (_canon(), _d('2026-11-13', 777)),
      DerivedRelation.epochAhead: (_canon(), _d('2026-11-14', 14, epoch: 2)),
    };

void main() {
  group('관계 분류', () {
    test('파생 없음 — 정본 0 = IN_SYNC · 정본 있음 = EMPTY', () {
      expect(derivedRelationOf(_emptyCanon(), null), DerivedRelation.inSync);
      expect(derivedRelationOf(_canon(), null), DerivedRelation.empty);
    });

    test('마지막 날 같은 체인 = IN_SYNC · 앞 날 같은 체인 = BEHIND', () {
      expect(
        derivedRelationOf(_canon(), _d('2026-11-14', 14)),
        DerivedRelation.inSync,
      );
      expect(
        derivedRelationOf(_canon(), _d('2026-11-12', 12)),
        DerivedRelation.behind,
      );
      expect(
        derivedRelationOf(_canon(), _d('2026-11-10', 10)),
        DerivedRelation.behind,
      );
    });

    test('🔴 파생 날 > 정본 마지막 = AHEAD · 정본 0 + 파생 = AHEAD', () {
      expect(
        derivedRelationOf(_canon(), _d('2026-11-15', 15)),
        DerivedRelation.ahead,
      );
      expect(
        derivedRelationOf(_emptyCanon(), _d('2026-11-10', 10)),
        DerivedRelation.ahead,
      );
    });

    test('같은 날 다른 체인 — 기준점 없음 = DIVERGED', () {
      expect(
        derivedRelationOf(_canon(), _d('2026-11-13', 777)),
        DerivedRelation.diverged,
      );
    });

    test(
      '🔴 새 기준점 fromDate ≤ 파생 날 = REBASED(같은 날 포함) · fromDate > 날 = DIVERGED',
      () {
        CanonChain withBase(String from) => _canon(
          baselines: <ChainBaseline>[
            ChainBaseline(fromDate: from, decisionId: 'dec-1'),
          ],
        );
        expect(
          derivedRelationOf(withBase('2026-11-12'), _d('2026-11-13', 777)),
          DerivedRelation.rebased,
        );
        expect(
          derivedRelationOf(withBase('2026-11-13'), _d('2026-11-13', 777)),
          DerivedRelation.rebased,
        );
        expect(
          derivedRelationOf(withBase('2026-11-14'), _d('2026-11-13', 777)),
          DerivedRelation.diverged,
        );
      },
    );

    test('🔴 정본 첫 날보다 앞 = DIVERGED(기준점이 그 앞이어도)', () {
      expect(
        derivedRelationOf(_canon(), _d('2026-11-05', 5)),
        DerivedRelation.diverged,
      );
      expect(
        derivedRelationOf(
          _canon(
            baselines: const <ChainBaseline>[
              ChainBaseline(fromDate: '2026-11-01', decisionId: 'dec-0'),
            ],
          ),
          _d('2026-11-05', 5),
        ),
        DerivedRelation.diverged,
      );
    });

    test('🔴 epoch 먼저 — 체인이 같아도 · 날이 앞서도 높은 epoch = EPOCH_AHEAD', () {
      expect(
        derivedRelationOf(_canon(), _d('2026-11-14', 14, epoch: 2)),
        DerivedRelation.epochAhead,
      );
      expect(
        derivedRelationOf(_canon(), _d('2026-11-12', 12, epoch: 2)),
        DerivedRelation.epochAhead,
      );
      expect(
        derivedRelationOf(_canon(), _d('2026-11-16', 16, epoch: 2)),
        DerivedRelation.epochAhead,
      );
      expect(
        derivedRelationOf(_emptyCanon(), _d('2026-11-16', 16, epoch: 2)),
        DerivedRelation.epochAhead,
      );
    });

    test('낮은 epoch + 같은 체인 = BEHIND · IN_SYNC(옛 기기 기록은 FORK 아님)', () {
      final CanonChain c = _canon(epoch: 3);
      expect(
        derivedRelationOf(c, _d('2026-11-12', 12, epoch: 1)),
        DerivedRelation.behind,
      );
      expect(
        derivedRelationOf(c, _d('2026-11-14', 14, epoch: 2)),
        DerivedRelation.inSync,
      );
    });

    test('forks = AHEAD · DIVERGED · EPOCH_AHEAD 만', () {
      expect(
        DerivedRelation.values.where((DerivedRelation r) => r.forks).toSet(),
        <DerivedRelation>{
          DerivedRelation.ahead,
          DerivedRelation.diverged,
          DerivedRelation.epochAhead,
        },
      );
      expect(
        DerivedRelation.values.map((DerivedRelation r) => r.wire),
        <String>[
          'IN_SYNC',
          'EMPTY',
          'BEHIND',
          'REBASED',
          'AHEAD',
          'DIVERGED',
          'EPOCH_AHEAD',
        ],
      );
    });

    test('_cases 표가 말한 관계를 실제로 만든다', () {
      _cases.forEach((DerivedRelation r, (CanonChain, DerivedStamp?) c) {
        expect(derivedRelationOf(c.$1, c.$2), r, reason: r.wire);
      });
    });
  });

  group('동기 조치', () {
    test('🔴 FORK 상태는 끈적 — 관계가 IN_SYNC 여도 ForkStop', () {
      final DerivedSyncAction a = _act(
        DerivedRelation.inSync,
        current: DerivedSyncStatus.fork,
      );
      expect(a, isA<DerivedForkStop>());
      expect((a as DerivedForkStop).relation, DerivedRelation.inSync);
      expect(
        _act(
          DerivedRelation.behind,
          current: DerivedSyncStatus.fork,
          derived: _d('2026-11-12', 12),
        ),
        isA<DerivedForkStop>(),
      );
    });

    test('🔴 FORK 판정은 리스와 무관 — 리스 invalid · unknown × AHEAD = ForkStop', () {
      for (final LeaseVerdict l in LeaseVerdict.values) {
        for (final DerivedRelation r in <DerivedRelation>[
          DerivedRelation.ahead,
          DerivedRelation.diverged,
          DerivedRelation.epochAhead,
        ]) {
          final DerivedSyncAction a = _act(r, lease: l);
          expect(a, isA<DerivedForkStop>(), reason: '${l.name} ${r.wire}');
          expect((a as DerivedForkStop).relation, r);
        }
      }
    });

    test('봉인 = Hold(SEALED) · 단 FORK 가 봉인보다 먼저', () {
      final DerivedSyncAction a = _act(
        DerivedRelation.behind,
        current: DerivedSyncStatus.sealed,
        derived: _d('2026-11-12', 12),
      );
      expect((a as DerivedHold).reason, DerivedHoldReason.sealed);
      expect(
        _act(DerivedRelation.ahead, current: DerivedSyncStatus.sealed),
        isA<DerivedForkStop>(),
      );
    });

    test('IN_SYNC = Noop(OK · PUSH_LAG · PUSH_FAILED)', () {
      for (final DerivedSyncStatus s in <DerivedSyncStatus>[
        DerivedSyncStatus.ok,
        DerivedSyncStatus.pushLag,
        DerivedSyncStatus.pushFailed,
      ]) {
        expect(_act(DerivedRelation.inSync, current: s), isA<DerivedNoop>());
      }
    });

    test('🔴 리스 invalid · unknown × BEHIND = Hold(LEASE_NOT_VALID)', () {
      for (final LeaseVerdict l in <LeaseVerdict>[
        LeaseVerdict.invalid,
        LeaseVerdict.unknown,
      ]) {
        final DerivedSyncAction a = _act(
          DerivedRelation.behind,
          lease: l,
          derived: _d('2026-11-12', 12),
        );
        expect((a as DerivedHold).reason, DerivedHoldReason.leaseNotValid);
      }
    });

    test(
      '🔴 일 상한 — cap-1 = Resync · cap = Hold(DAILY_CAP) · 0 = ArgumentError',
      () {
        expect(
          _act(
            DerivedRelation.behind,
            resyncsToday: 2,
            dailyCap: 3,
            derived: _d('2026-11-12', 12),
          ),
          isA<DerivedResync>(),
        );
        final DerivedSyncAction a = _act(
          DerivedRelation.behind,
          resyncsToday: 3,
          dailyCap: 3,
          derived: _d('2026-11-12', 12),
        );
        expect((a as DerivedHold).reason, DerivedHoldReason.dailyCap);
        expect(
          () => _act(DerivedRelation.inSync, dailyCap: 0),
          throwsArgumentError,
        );
      },
    );

    test('🔴 재생성 시작 날 — EMPTY = 정본 첫 날 · BEHIND = 파생 다음 날', () {
      expect(
        (_act(DerivedRelation.empty) as DerivedResync).fromDate,
        '2026-11-10',
      );
      expect(
        (_act(
          DerivedRelation.behind,
          current: DerivedSyncStatus.pushLag,
          derived: _d('2026-11-12', 12),
        ) as DerivedResync).fromDate,
        '2026-11-13',
      );
    });

    test('🔴 REBASED = 걸린 기준점 가운데 가장 이른 fromDate(뒤 기준점 무시)', () {
      final CanonChain c = _canon(
        baselines: const <ChainBaseline>[
          ChainBaseline(fromDate: '2026-11-12', decisionId: 'dec-2'),
          ChainBaseline(fromDate: '2026-11-14', decisionId: 'dec-3'),
          ChainBaseline(fromDate: '2026-11-11', decisionId: 'dec-1'),
        ],
      );
      final DerivedStamp d = _d('2026-11-13', 777);
      expect(derivedRelationOf(c, d), DerivedRelation.rebased);
      expect(
        (_act(
          DerivedRelation.rebased,
          canon: c,
          derived: d,
        ) as DerivedResync).fromDate,
        '2026-11-11',
      );
    });

    test('PUSH_FAILED 상태도 재생성 대상(FORK · SEALED 만 막는다)', () {
      expect(
        _act(DerivedRelation.empty, current: DerivedSyncStatus.pushFailed),
        isA<DerivedResync>(),
      );
    });
  });

  group('체인 diff', () {
    test('🔴 3 대상 × 6 비동기 관계 = 18칸 전부 관측 · 축 CHAIN_HASH · 후보 ⊂ 파생 쓰기 코드', () {
      int n = 0;
      for (final DerivedTarget t in DerivedTarget.values) {
        _cases.forEach((DerivedRelation r, (CanonChain, DerivedStamp?) c) {
          final DerivedChainDiff x = derivedChainDiffOf(t, r, c.$1, c.$2)!;
          expect(x.severity, DiffSeverity.observational, reason: r.wire);
          expect(x.pair, t.pair);
          expect(x.axis, LedgerAxis.chainHash);
          expect(x.candidates, isNotEmpty);
          expect(
            writableOriginCodesFor(t.pair).containsAll(x.candidates),
            isTrue,
            reason: '${t.syncTarget} ${r.wire} ${x.candidates}',
          );
          n++;
        });
      }
      expect(n, 18);
    });

    test('IN_SYNC = null', () {
      expect(
        derivedChainDiffOf(
          DerivedTarget.github,
          DerivedRelation.inSync,
          _canon(),
          _d('2026-11-14', 14),
        ),
        isNull,
      );
    });

    test('후보 — BEHIND · EMPTY = 뒤처짐 코드 · REBASED = CHAIN_BROKEN · AHEAD = RESTORE_ROLLBACK · 갈라짐 = 둘', () {
      List<String> cand(DerivedTarget t, DerivedRelation r) {
        final (CanonChain, DerivedStamp?) c = _cases[r]!;
        return derivedChainDiffOf(t, r, c.$1, c.$2)!.candidates;
      }

      expect(cand(DerivedTarget.supabase, DerivedRelation.behind), <String>[
        OriginCodes.pushLag,
      ]);
      expect(cand(DerivedTarget.github, DerivedRelation.empty), <String>[
        OriginCodes.archiveLag,
      ]);
      expect(cand(DerivedTarget.calendar, DerivedRelation.behind), <String>[
        OriginCodes.calWriteFailed,
      ]);
      expect(cand(DerivedTarget.github, DerivedRelation.rebased), <String>[
        OriginCodes.chainBroken,
      ]);
      expect(cand(DerivedTarget.github, DerivedRelation.ahead), <String>[
        OriginCodes.restoreRollback,
      ]);
      for (final DerivedRelation r in <DerivedRelation>[
        DerivedRelation.diverged,
        DerivedRelation.epochAhead,
      ]) {
        expect(cand(DerivedTarget.github, r), <String>[
          OriginCodes.chainBroken,
          OriginCodes.restoreRollback,
        ]);
      }
    });

    test('diffId — 결정적 · 관계마다 다름 · ld- + 24 hex', () {
      final Set<String> ids = <String>{};
      for (final DerivedTarget t in DerivedTarget.values) {
        _cases.forEach((DerivedRelation r, (CanonChain, DerivedStamp?) c) {
          final String a = derivedChainDiffOf(t, r, c.$1, c.$2)!.diffId;
          final String b = derivedChainDiffOf(t, r, c.$1, c.$2)!.diffId;
          expect(a, b);
          expect(a, matches(RegExp(r'^ld-[0-9a-f]{24}$')));
          ids.add(a);
        });
      }
      expect(ids, hasLength(18));
    });

    test('deltaJson · 귀속 날 · 문장 — BEHIND 아카이브', () {
      final DerivedChainDiff x = derivedChainDiffOf(
        DerivedTarget.github,
        DerivedRelation.behind,
        _canon(),
        _d('2026-11-12', 12),
      )!;
      expect(x.authoredDate, '2026-11-12');
      expect(jsonDecode(x.deltaJson), <String, Object?>{
        'target': 'GITHUB',
        'relation': 'BEHIND',
        'canon_date': '2026-11-14',
        'canon_chain8': _h(12).substring(0, 8),
        'derived_date': '2026-11-12',
        'derived_chain8': _h(12).substring(0, 8),
        'canon_epoch': 1,
        'derived_epoch': 1,
        'candidates': <String>['ARCHIVE_LAG'],
      });
      expect(x.label, '아카이브가 2026-11-12 에 멈춰 있습니다 — 정본 2026-11-14');
    });

    test('EMPTY = 정본 첫 날 귀속 · 문장에 금액 · «DRY_RUN» 0', () {
      final DerivedChainDiff x = derivedChainDiffOf(
        DerivedTarget.supabase,
        DerivedRelation.empty,
        _canon(),
        null,
      )!;
      expect(x.authoredDate, '2026-11-10');
      for (final DerivedTarget t in DerivedTarget.values) {
        _cases.forEach((DerivedRelation r, (CanonChain, DerivedStamp?) c) {
          final String l = derivedChainDiffOf(t, r, c.$1, c.$2)!.label;
          expect(l, isNotEmpty);
          expect(l, isNot(contains('DRY_RUN')));
          expect(l, isNot(matches(RegExp(r'\d원'))));
        });
      }
    });
  });

  group('입력 · 글자', () {
    test('DerivedStamp 입력 검증 3 · fromCheckpoint 칸 대응', () {
      expect(
        () => DerivedStamp(
          authoredDate: '2026-11-1',
          chainHash: _h(1),
          operatorEpoch: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => DerivedStamp(
          authoredDate: '2026-11-10',
          chainHash: _h(1).toUpperCase().replaceAll('0', 'A'),
          operatorEpoch: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => DerivedStamp(
          authoredDate: '2026-11-10',
          chainHash: _h(1),
          operatorEpoch: -1,
        ),
        throwsArgumentError,
      );
      final DerivedStamp s = DerivedStamp.fromCheckpoint(
        ArchiveCheckpoint(
          schemaVersion: 1,
          hashFormatVersion: 1,
          authoredDate: '2026-11-13',
          chainHash: _h(13),
          operatorEpoch: 4,
          writerDeviceId: 'dev-a',
          committedAt: '2026-11-13T09:00:00Z',
        ),
      );
      expect(
        (s.authoredDate, s.chainHash, s.operatorEpoch),
        ('2026-11-13', _h(13), 4),
      );
    });

    test('대상 글자 3 · 뒤처짐 코드 · 상태 parse 왕복 · 모름 = FormatException', () {
      expect(
        DerivedTarget.values.map((DerivedTarget t) => t.syncTarget),
        <String>['SUPABASE', 'GITHUB', 'CALENDAR'],
      );
      expect(
        DerivedTarget.values.map((DerivedTarget t) => t.lagOriginCode),
        <String>[
          OriginCodes.pushLag,
          OriginCodes.archiveLag,
          OriginCodes.calWriteFailed,
        ],
      );
      for (final DerivedSyncStatus s in DerivedSyncStatus.values) {
        expect(DerivedSyncStatus.parse(s.wire), s);
      }
      expect(
        DerivedSyncStatus.values.map((DerivedSyncStatus s) => s.wire),
        <String>['OK', 'PUSH_LAG', 'PUSH_FAILED', 'FORK', 'SEALED'],
      );
      expect(() => DerivedSyncStatus.parse('fork'), throwsFormatException);
      expect(kDerivedForkAlertCode, 'DERIVED_FORK');
    });

    test('CanonChain — 오름차순 아님 · 같은 날 둘 = ArgumentError · 첫 · 끝 · chainAt', () {
      StoredDayStamp st(String d) => StoredDayStamp(
        authoredDate: d,
        dayHash: _h(1),
        chainHash: _h(2),
        hashFormatVersion: 1,
      );
      expect(
        () => CanonChain(
          stamps: <StoredDayStamp>[st('2026-11-11'), st('2026-11-10')],
          operatorEpoch: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => CanonChain(
          stamps: <StoredDayStamp>[st('2026-11-10'), st('2026-11-10')],
          operatorEpoch: 1,
        ),
        throwsArgumentError,
      );
      final CanonChain c = _canon();
      expect((c.firstDate, c.lastDate), ('2026-11-10', '2026-11-14'));
      expect(c.chainAt('2026-11-12'), _h(12));
      expect(c.chainAt('2026-11-20'), isNull);
      expect((_emptyCanon().firstDate, _emptyCanon().lastDate), (null, null));
    });
  });
}
