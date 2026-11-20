// E11q-b3 — M5-5 차단 보드 VM(설계 13 §8 R185 · 01 §34 K154 · K155).
//
// 🔴 표본 `m5/block_board_*` 와 글자 · 수준 · 차례가 같다(«(합성)» 표지 제외 · 브레이커 머리 = 사다리 조치 글자 — R185 결정) ·
//    C-59 불변식(킬스위치 진입 늘 · 빈 문장 ⇒ 행 0 · 사다리 지금 단 == 브레이커 라벨 · 재개 결정 ⇒ 목적지) · 홈 블록 3 과 같은 거름.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:domain_contracts/domain_contracts.dart' as c show BreakerLevel;
import 'package:test/test.dart';

Map<String, Object?> _row(String f) =>
    ((jsonDecode(File('../domain_contracts/fixtures/m5/$f').readAsStringSync())
                    as Map<String, Object?>)['rows']!
                as List<Object?>)
            .first!
        as Map<String, Object?>;

String _plain(String s) => s.replaceFirst('(합성) ', '');

final DateTime _at = DateTime.utc(2026, 12, 23, 1, 2); // 10:02 KST
final DateTime _confirmed = DateTime.utc(2026, 12, 23, 1, 20); // 10:20 KST

SafetyState _state({
  BreakerLevel level = BreakerLevel.normal,
  List<StoredBlockFlag> flags = const <StoredBlockFlag>[],
  String? journalDraftId,
  KillSwitchRecord ks = const KillSwitchRecord(),
  DateTime? trusted,
  bool eligible = false,
  List<GaugeProgress> gauges = const <GaugeProgress>[],
  AsOf? asOf,
}) => safetyStateOf(
  level: level,
  drawdown: 0,
  flags: blockFlagsOf(flags, journalDraftId: journalDraftId),
  killSwitch: killSwitchViewOf(ks, trusted),
  stoppedReleaseEligible: eligible,
  releaseProgress: gauges,
  rampLevel: RampLevel.l1,
  mode: RunMode.live,
  asOf:
      asOf ??
      safetyAsOf(
        lastSnapshotDate: '2026-12-23',
        nowUtc: DateTime.utc(2026, 12, 23, 2),
      ),
);

bool _all(String _) => true;
bool _none(String _) => false;

/// 표본과 비교(글자 = «(합성)» 뗌 · 사다리 · 게이지 · 기준 = 그대로).
void _same(BlockBoardVm vm, BlockBoardVm fx, {bool headline = true}) {
  if (headline) expect(vm.headline, _plain(fx.headline));
  expect(vm.level, fx.level);
  expect(vm.breakerLabel, fx.breakerLabel);
  expect(vm.rows.length, fx.rows.length);
  for (final (int i, BlockBoardRow r) in fx.rows.indexed) {
    final BlockBoardRow g = vm.rows[i];
    expect(g.rowId, r.rowId);
    expect(g.label, r.label);
    expect(g.setAtText, r.setAtText == null ? null : _plain(r.setAtText!));
    expect(g.clearKindLabel, _plain(r.clearKindLabel));
    expect(g.clearInstruction, _plain(r.clearInstruction));
    expect(g.level, r.level, reason: r.rowId);
    expect(g.link?.deepLink, r.link?.deepLink, reason: r.rowId);
    expect(g.link?.label, r.link == null ? null : _plain(r.link!.label));
  }
  expect(vm.gauges, fx.gauges);
  expect(vm.ladder, fx.ladder);
  expect(vm.killSwitchLink.deepLink, fx.killSwitchLink.deepLink);
  expect(vm.killSwitchLink.label, _plain(fx.killSwitchLink.label));
  expect(vm.stoppedDecisionLink?.deepLink, fx.stoppedDecisionLink?.deepLink);
  expect(
    vm.stoppedDecisionLink?.label,
    fx.stoppedDecisionLink == null
        ? null
        : _plain(fx.stoppedDecisionLink!.label),
  );
  expect(vm.emptyLabel, fx.emptyLabel == null ? null : _plain(fx.emptyLabel!));
  expect(vm.asOf, fx.asOf);
}

/// C-59 ⑩~⑫ 불변식.
void _invariants(BlockBoardVm vm) {
  expect(vm.killSwitchLink.deepLink, AppRoutes.m5KillSwitch);
  if (vm.emptyLabel != null) expect(vm.rows, isEmpty);
  expect(
    vm.ladder.rows.where((BreakerLadderRow r) => r.current).single.label,
    vm.breakerLabel,
  );
  if (vm.stoppedDecisionLink != null) {
    expect(vm.stoppedDecisionLink!.deepLink, AppRoutes.m5StoppedDecision);
  }
  for (final BlockBoardRow r in vm.rows) {
    expect(<String>{
      ...FlagIds.values,
      BlockBoardTexts.killSwitchRowId,
    }, contains(r.rowId));
  }
}

void main() {
  test('막힌 것 0 = 표본 block_board_clear(머리 · 빈 문장 · 사다리 5 단 · 킬스위치 진입)', () {
    final BlockBoardVm fx = BlockBoardVm.fromJson(
      _row('block_board_clear.json'),
    );
    final BlockBoardVm vm = blockBoardVmOf(
      state: _state(asOf: fx.asOf),
      hasBody: _all,
    );
    _same(vm, fx);
    _invariants(vm);
  });

  test('킬스위치 켜짐(기록 뒤) = 표본 block_board_kill_active(행 1 · 해제 예정 · 게이지 그대로)', () {
    final BlockBoardVm fx = BlockBoardVm.fromJson(
      _row('block_board_kill_active.json'),
    );
    final BlockBoardVm vm = blockBoardVmOf(
      state: _state(
        ks: KillSwitchRecord(
          activatedAtUtc: _at,
          checklistConfirmedAtUtc: _confirmed,
          activatedByDeviceLabel: KillSwitchScreenTexts.operatorPhone,
        ),
        trusted: fx.asOf.observedAt,
        gauges: fx.gauges,
        asOf: fx.asOf,
      ),
      hasBody: _all,
    );
    _same(vm, fx);
    _invariants(vm);
  });

  test('재개 미완 + 일지 = 표본 block_board_resume_incomplete(엔진 차례 · 묶음 수준 · 링크 = 엔진 목적지)', () {
    final BlockBoardVm fx = BlockBoardVm.fromJson(
      _row('block_board_resume_incomplete.json'),
    );
    final BlockBoardVm vm = blockBoardVmOf(
      state: _state(
        flags: <StoredBlockFlag>[
          StoredBlockFlag(
            FlagIds.journalMissing,
            DateTime.utc(2026, 12, 21, 21, 30),
          ),
          StoredBlockFlag(
            FlagIds.resumeIncomplete,
            DateTime.utc(2026, 12, 22, 0, 12),
          ),
        ],
        journalDraftId: 'dj_x2_01',
        asOf: fx.asOf,
      ),
      hasBody: _all,
    );
    _same(vm, fx);
    _invariants(vm);
  });

  test('정지 · 재개 자격 = 표본 block_board_stopped(행 0 · 빈 문장 0 · 재개 결정 링크) · 머리 = 사다리 조치 글자', () {
    final BlockBoardVm fx = BlockBoardVm.fromJson(
      _row('block_board_stopped.json'),
    );
    final BlockBoardVm vm = blockBoardVmOf(
      state: _state(
        level: BreakerLevel.stopped,
        eligible: true,
        gauges: fx.gauges,
        asOf: fx.asOf,
      ),
      hasBody: _all,
    );
    _same(vm, fx, headline: false);
    // 🔵 R185 — 브레이커 머리 = 사다리 지금 단 조치(설정 한 원천 · P0S 에 없는 새틀라이트를 말하지 않는다).
    expect(vm.headline, '서킷브레이커 정지 단계 — 신규 주문 전면 중단 · 보유 유지 · 자동 청산 없음');
    _invariants(vm);
    // 자격 없음 · 본문 없음 = 재개 결정 링크 0(정지 아님도 0).
    expect(
      blockBoardVmOf(
        state: _state(level: BreakerLevel.stopped),
        hasBody: _all,
      ).stoppedDecisionLink,
      isNull,
    );
    expect(
      blockBoardVmOf(
        state: _state(level: BreakerLevel.stopped, eligible: true),
        hasBody: _none,
      ).stoppedDecisionLink,
      isNull,
    );
    expect(
      blockBoardVmOf(
        state: _state(level: BreakerLevel.halted, eligible: true),
        hasBody: _all,
      ).stoppedDecisionLink,
      isNull,
    );
  });

  test('🔴 행 = 홈 블록 3 과 같은 거름(표식 4 제외 · 정정 포함) · 수준 = 주문 판정 묶음', () {
    final DateTime t = DateTime.utc(2026, 11, 1);
    final BlockBoardVm vm = blockBoardVmOf(
      state: _state(
        flags: <StoredBlockFlag>[
          for (final String f in FlagIds.values) StoredBlockFlag(f, t),
        ],
        journalDraftId: 'J-9',
      ),
      hasBody: _all,
    );
    final List<String> want = <String>[
      for (final BlockFlag f in blockFlagsOf(<StoredBlockFlag>[
        for (final String f in FlagIds.values) StoredBlockFlag(f, t),
      ]))
        if (!FlagIds.markerOnly.contains(f.flagId)) f.flagId,
    ];
    expect(vm.rows.map((BlockBoardRow r) => r.rowId).toList(), want);
    expect(want, hasLength(FlagIds.blocking.length + 1));
    final Map<String, UiLevel> lv = <String, UiLevel>{
      for (final BlockBoardRow r in vm.rows) r.rowId: r.level,
    };
    for (final String f in BlockBundles.allOrders) {
      expect(lv[f], UiLevel.blocked, reason: f);
    }
    for (final String f in <String>{
      ...BlockBundles.newBuys,
      ...BlockBundles.entryAdvice,
    }) {
      expect(lv[f], UiLevel.act, reason: f);
    }
    expect(lv[FlagIds.ledgerFix], UiLevel.watch);
    expect(vm.level, UiLevel.blocked);
    expect(vm.emptyLabel, isNull);
    _invariants(vm);
    // 표식만 = 행 0 · 빈 문장.
    final BlockBoardVm markers = blockBoardVmOf(
      state: _state(
        flags: <StoredBlockFlag>[
          for (final String f in FlagIds.markerOnly) StoredBlockFlag(f, t),
        ],
      ),
      hasBody: _all,
    );
    expect(markers.rows, isEmpty);
    expect(markers.emptyLabel, BlockBoardTexts.empty);
    expect(markers.level, UiLevel.ok);
  });

  test('🔴 링크 — 대사 불일치 = 보드 자신 → 0 · 본문 없음 = 0 · 킬스위치 진입은 늘', () {
    final DateTime t = DateTime.utc(2026, 11, 1);
    final List<StoredBlockFlag> all = <StoredBlockFlag>[
      for (final String f in FlagIds.blocking) StoredBlockFlag(f, t),
    ];
    final BlockBoardVm on = blockBoardVmOf(
      state: _state(
        flags: all,
        journalDraftId: 'J-9',
        ks: KillSwitchRecord(activatedAtUtc: _at),
      ),
      hasBody: _all,
    );
    final Map<String, String?> links = <String, String?>{
      for (final BlockBoardRow r in on.rows) r.rowId: r.link?.deepLink,
    };
    expect(links, <String, String?>{
      BlockBoardTexts.killSwitchRowId: AppRoutes.m5KillSwitch,
      FlagIds.ledgerIntegrity: AppRoutes.x5RepairWizard,
      FlagIds.reconMismatch: null,
      FlagIds.resumeIncomplete: AppRoutes.x2ResumeGate,
      FlagIds.adviceLedgerUnverified: AppRoutes.m5SelfAuditResolve,
      FlagIds.selfAuditOverdue: null,
      FlagIds.journalMissing: 'aaq://journal/draft/J-9',
      FlagIds.tierBUnjudged: null,
    });
    final BlockBoardVm off = blockBoardVmOf(
      state: _state(
        flags: all,
        journalDraftId: 'J-9',
        ks: KillSwitchRecord(activatedAtUtc: _at),
      ),
      hasBody: _none,
    );
    expect(off.rows.where((BlockBoardRow r) => r.link != null), isEmpty);
    expect(off.killSwitchLink.deepLink, AppRoutes.m5KillSwitch);
    // 등록된 패턴만 — 일지 초안 패턴이 있으면 구체 링크로.
    final BlockBoardVm journal = blockBoardVmOf(
      state: _state(flags: all, journalDraftId: 'J-9'),
      hasBody: (String r) => r == AppRoutes.journalDraft,
    );
    expect(
      <String?>[for (final BlockBoardRow r in journal.rows) r.link?.deepLink]
          .whereType<String>()
          .toList(),
      <String>['aaq://journal/draft/J-9'],
    );
  });

  test('🔴 엔진 목적지마다 계약 패턴 · 보드 글자가 있다(보드 자신 제외 — 링크가 소리 없이 사라지지 않게)', () {
    final List<BlockFlag> flags = blockFlagsOf(<StoredBlockFlag>[
      for (final String f in FlagIds.values)
        StoredBlockFlag(f, DateTime.utc(2026, 11, 1)),
    ], journalDraftId: 'J-9');
    int n = 0;
    for (final BlockFlag f in flags) {
      if (f.clearDeepLink == null) continue;
      final String? p = routePatternOf(f.clearDeepLink!);
      expect(p, isNotNull, reason: f.flagId);
      if (p == AppRoutes.m5BlockBoard) {
        expect(BlockBoardTexts.linkLabel, isNot(contains(p)));
        continue;
      }
      expect(BlockBoardTexts.linkLabel, contains(p), reason: f.flagId);
      n++;
    }
    expect(n, 4);
    expect(routePatternOf('aaq://journal/draft/J-9'), AppRoutes.journalDraft);
    expect(routePatternOf('aaq://journal/draft/'), isNull);
    expect(routePatternOf('aaq://nowhere'), isNull);
    expect(routePatternOf(AppRoutes.m5BlockBoard), AppRoutes.m5BlockBoard);
  });

  test('킬스위치 행 — 기록 전 = 체크리스트 문장 · 신뢰 시각 모름 = 엔진 문장 · 링크 본문 없음 = 0', () {
    final BlockBoardRow before = blockBoardVmOf(
      state: _state(ks: KillSwitchRecord(activatedAtUtc: _at)),
      hasBody: _all,
    ).rows.single;
    expect(before.clearInstruction, '체크리스트를 먼저 마치십시오 — 마친 때부터 48시간을 셉니다');
    expect(before.setAtText, '12-23 10:02부터');
    final BlockBoardRow unknown = blockBoardVmOf(
      state: _state(
        ks: KillSwitchRecord(
          activatedAtUtc: _at,
          checklistConfirmedAtUtc: _confirmed,
        ),
      ),
      hasBody: _none,
    ).rows.single;
    expect(unknown.clearInstruction, '서버 시각을 확인하지 못해 해제 시각을 셀 수 없습니다');
    expect(unknown.link, isNull);
    expect(unknown.level, UiLevel.blocked);
  });

  test(
    '머리 · 수준 — 행 + 브레이커 비정상 = 이름 뒤 단계 · 수준 = 가장 무거운 것 · 행 0 + 경보 = 사다리 조치',
    () {
      final BlockBoardVm both = blockBoardVmOf(
        state: _state(
          level: BreakerLevel.alert,
          flags: <StoredBlockFlag>[
            StoredBlockFlag(FlagIds.journalMissing, DateTime.utc(2026, 11, 1)),
          ],
        ),
        hasBody: _all,
      );
      expect(both.headline, '막힌 것 1 — 일지 · 서킷브레이커 경보 단계');
      expect(both.level, UiLevel.act);
      expect(both.emptyLabel, isNull);
      _invariants(both);
      for (final BreakerLevel l in BreakerLevel.values) {
        final BlockBoardVm vm = blockBoardVmOf(
          state: _state(level: l),
          hasBody: _all,
        );
        _invariants(vm);
        final BreakerLadderStep cur = breakerLadderOf(current: l)
            .firstWhere((BreakerLadderStep s) => s.current);
        expect(
          vm.headline,
          l == BreakerLevel.normal
              ? BlockBoardTexts.clearHeadline
              : '서킷브레이커 ${cur.label} 단계 — ${cur.actionText}',
        );
        expect(vm.emptyLabel == null, l != BreakerLevel.normal);
        expect(vm.level, switch (l) {
          BreakerLevel.normal => UiLevel.ok,
          BreakerLevel.alert => UiLevel.watch,
          BreakerLevel.reduced => UiLevel.act,
          BreakerLevel.halted || BreakerLevel.stopped => UiLevel.blocked,
        });
        expect(
          vm.ladder.rows.map((BreakerLadderRow r) => r.level).toList(),
          c.BreakerLevel.values,
        );
      }
    },
  );
}
