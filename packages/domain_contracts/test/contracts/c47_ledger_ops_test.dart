// C-47 원장 차이·정정 `L-1`·`L-2` · 운영 홈·리듬 `H-01`·`H-02` · 알림 등급 — 01 §21 · §7 표 C-47(🆕 계약 v1.12 · R5·R13 선행
// 설계서 2026-10-22 §6-2 · 발주자 확정 2026-10-22 — 🔴 K30 «조치» 열 삭제 권고대로).
//
// 정의: 「`L-1`·`L-2` 는 엔진이 실은 짝 라벨·칩·시각·링크만 그리고 원값으로 표시·묶기·거르기를 하지 않는다 · 홈 3행은 리듬 표의
//   앞 3행과 같은 값 · 픽스처의 알림 등급은 엔진 등급표 그대로다」.
//   ① 허용 키 · DTO 필드 집합 == 목록   ② 라벨(보드와 같은 쌍 글자 · 후보 칩 = 코드 순서 · 관측 = «주문을 막지 않습니다»)
//   ③ 조치 링크 = 승인 → 정정 마법사 ∨ 자가보고 → L-3   ④ 정정 이력(계단 = 원본 바로 뒤 · 원본 «이후 정정됨» · 소속 · 결정 링크 ·
//   방향 색 · 원인 사전 · 재계산 고지)   ⑤ 리듬(홈 upcoming == 표 앞 ≤3 · 모름 ≠ 없음)   ⑥ 알림 등급(전 픽스처 walk —
//   등록부 미매핑 포함 · 정본 06_시스템설계/04_안전장치.md §5-3 v2.33)   ⑦ `L-1`·`L-2` 화면 소스 스캔(대상 0 = 공허 통과)
//   ⑧ 자체 검증   ⑨ R13 진입 링크 표본(9b 실사 카드 · 리듬 분기 실사 · 블록 2 X2 한 줄).
// 🆕 계약 v1.13(R13b 선행 · 01 §23 · 발주자 확정 2026-10-26) — ⑩ 대조 보드(칸 5 · 칸 레벨 원천 · 해당 없음 = info ·
//   파생 blocked 0 · headline 늘 엔진 문장 · 전부 일치 표본 · 쌍 글자 사전 한 벌)   ⑪ R13b 홈 참고 표본(억제 + 기한 라벨 ·
//   배분 notice 두 갈래).
// 🆕 v1.13 검증 반영(2026-10-26 · 변이 R2c·R2d·R2e·R4b·R4c·R4e) — ⑩ 칸 레벨 표본째 고정(diff BLOCKED·WATCH·OK·OK·INFO ·
//   ok OK×4·INFO) · 점검 칸 state_code OK ⇔ level OK(K3 ⓒ) · ledger_diffs_4 대응(K6)   ⑪ dueTodayCount > 0 ∧ ≤ openCount ·
//   headline 표본 글자 고정 ≠ zero(K8).
// 🔵 `H-01`·`H-02` 화면 스캔은 R13 카드(`ui_shell`)의 몫 — `ui_shell` 은 v1.8 C-44 ⑫ 에서도 제외였다.
// 🆕 검증 반영(2026-10-22 · 변이 R7 · 정합 갈래) — ⑦ 에 `firstWhere` 류 · 객체 패턴 구조 분해 · 라우트 상수(예외
//   `AppRoutes.ledgerRepairs`)·플랫폼 분기(`kIsWeb`·`defaultTargetPlatform`·`Platform.`) 를 더했다 — ⑧ 양성 +9 · 음성 +3.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

// ─── 픽스처 ──────────────────────────────────────────────────────────────────

/// `LedgerDiffRow` 를 싣는 표본(행 · `L-3` 결과 안 포함).
List<(String, Map<String, Object?>)> _diffRows() =>
    <(String, Map<String, Object?>)>[
      for (final String path in <String>[
        FixturePaths.ledgerDiffs4,
        FixturePaths.m6LedgerDiffsCashObserve,
      ])
        for (final Map<String, Object?> r in _rows(path)) (path, r),
      for (final String path in <String>[FixturePaths.m6SelfReportDiffResult])
        for (final Map<String, Object?> s in _rows(path))
          if (s['result'] case final Map<String, Object?> res)
            for (final Object? d in res['diffs']! as List<Object?>)
              (path, d! as Map<String, Object?>),
    ];

const List<String> _repairFixtures = <String>[
  FixturePaths.m6LedgerRepairs4,
  FixturePaths.m6LedgerRepairsEmpty,
];

const List<String> _opsHomes = <String>[
  FixturePaths.m8OpsHomeNormal,
  FixturePaths.m8OpsHomeBlocked,
  FixturePaths.m8OpsHomeAdviceOpen,
  FixturePaths.m8OpsHomeAdviceSuppressedDue,
  FixturePaths.m8OpsHomeAdviceZero,
  FixturePaths.m8OpsHomeResumeGap7,
];

/// ⑥ 🔴 알림 코드 → 엔진 등급(정본 = `06_시스템설계/04_안전장치.md` §5-3 «알림 코드 ↔ 등급 — 1회 대조 결과» v2.33 ·
///    정본이 바뀌면 이 표도 바뀐다 · `alert_codes.dart:4-5` «등급을 이 파일에 사전으로 만들지 않는다» → 표는 이 테스트 한 곳).
const Map<String, String> _engineLevel = <String, String>{
  // P0 7
  'ORDER_OUTCOME_UNKNOWN': 'P0',
  'RECON_MISMATCH': 'P0',
  'BROKER_AUTH_FAILED': 'P0',
  'MAINTENANCE_RESUME_FAILED': 'P0',
  'ADVICE_EXIT_URGENT': 'P0',
  'ADVICE_REVOKED': 'P0',
  'ADVICE_SUPPRESSED': 'P0',
  // P1 13
  'ORDER_REJECTED': 'P1',
  'REBALANCE_D1': 'P1',
  'WATCHDOG_LATE': 'P1',
  'DATA_SOURCE_DOWN': 'P1',
  'BACKUP_STALE': 'P1',
  'MAINTENANCE_WINDOW_OVERDUE': 'P1',
  'ADVICE_ISSUED': 'P1',
  'ADVICE_DUE_SOON': 'P1',
  'LEDGER_TRUST_DOWNGRADE': 'P1',
  'MANUAL_FILL_REJECTED': 'P1',
  'HANDOVER_COOLING_ACTIVE': 'P1',
  'HANDOVER_COMMITTED': 'P1',
  // 🆕 v1.17(엔진 D11) — 04_안전장치 §3-1 ③ 5 «P1 알림» 글자 · §5-3 표 등재 = 엔진 다음 SPEC 판(06 변경 이력).
  'STALE_ORDERS_HELD': 'P1',
  // P2 5
  'REBALANCE_D7': 'P2',
  'DEPOSIT_REMINDER': 'P2',
  'ADVICE_EXPIRED': 'P2',
  'SELF_AUDIT_DUE': 'P2',
  'CONTRIBUTION_CHANGED': 'P2',
  // 🆕 v1.18(엔진 등재형 · 01 §27 K-z) — 엔진 `kAlertLevels` 그대로 · SPEC 04 §5-3 «제안 → 정본» = 엔진 다음 SPEC 판.
  'BREAKER_STOPPED': 'P0',
  'LEDGER_INTEGRITY_BROKEN': 'P0',
  'RESUME_TRADING_HALTED': 'P0',
  'STOPPED_RELEASE_ELIGIBLE': 'P1',
  'RESUME_COMPLETED': 'P1',
  'RESUME_DATA_GAP': 'P2',
  // 🆕 v1.27(엔진 등재형 · 01 §36 K188~K190) — 엔진 `kAlertLevels` 그대로 · SPEC 04 §5-3 v2.45 · v2.46 «제안 → 정본» = 엔진 다음 SPEC 판.
  'DERIVED_FORK': 'P0',
  'DEFENSIVE_FLOOR_BREACHED': 'P1',
  'GOLD_SHARE_HIGH': 'P1',
  'FINANCIAL_INCOME_CAP_EXCEEDED': 'P1',
  'KRW_LIQUIDITY_LOW': 'P2',
};

const Set<String> _levels = <String>{'P0', 'P1', 'P2'};

final RegExp _selfReportLink = RegExp(
  r'^aaq://ledger/self-report/\d{4}-\d{2}/[^/?#]+$',
);

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _rows(String path) =>
    (_env(path)['rows']! as List<Object?>).cast<Map<String, Object?>>();

Iterable<Map<String, Object?>> _objects(Object? node) sync* {
  if (node is Map<String, Object?>) {
    yield node;
    for (final Object? v in node.values) {
      yield* _objects(v);
    }
  } else if (node is List<Object?>) {
    for (final Object? v in node) {
      yield* _objects(v);
    }
  }
}

// ─── ⑦ 화면 소스 스캔 ─────────────────────────────────────────────────────────

const String _journalPackage = 'packages/ui_journal';
const List<String> _ledgerFiles = <String>[
  'lib/src/ledger_diffs.dart',
  'lib/src/ledger_repairs.dart',
];
const String _ledgerDir = 'lib/src/ledger/';

/// 원값·키 0(🔵 `.severity`·`.route`·`.pair`·`.status` = exhaustive switch 색·아이콘 · `.applicable` · `.supersedes != null` ·
/// `.label`·`.directionLabel`·`.evidenceHash` 허용).
const String _rawFields =
    'candidateOriginCodes|originCode|directionCode|decisionId|appliedAt|'
    'recomputedFrom|diffId|repairId|wire|name';
final RegExp _raw = RegExp('\\.(?:$_rawFields)\\b');

/// 🆕 검증 반영(2026-10-22) — 같은 원값을 객체 패턴 구조 분해로 꺼내는 꼴(`LedgerDiffRow(:final diffId)` ·
/// `originCode: final o`) — C-46 ⑰ 과 같은 꼴.
final RegExp _rawPattern = RegExp(
  ':(?:final\\s+|var\\s+)?(?:[\\w<>?]+\\s+)?(?:$_rawFields)\\b'
  '|\\b(?:$_rawFields)\\s*:\\s*(?:final|var)\\b',
);

/// 묶기·거르기·재정렬 0 — 🆕 검증 반영: `firstWhere`·`lastWhere`·`singleWhere`·`indexWhere`·`whereType`·`takeWhile`·
/// `skipWhile` 도(첫 판 `\.where\b` 는 앞이 단어 글자인 이 꼴을 못 잡았다 · C-46 ㉕ 와 같은 목록).
final RegExp _reshape = RegExp(
  r'\.(?:where|firstWhere|lastWhere|singleWhere|indexWhere|whereType|takeWhile|skipWhile)\b|'
  r'groupBy|\.sort|\.fold|\.reduce',
);

/// 쓰기·초안·안전 상태 직접 0(배너 = `journalSafetyStateProvider` + 공용 `JournalSafetyBanners`).
final RegExp _write = RegExp(r'CommandApi|DraftStore|\.watchState\(');

/// 🆕 검증 반영(설계서 §8-3 `L-1` «폰/웹 분기로 정정 버튼» ↔ C-47 ②③⑦) — 라우트 상수(예외 = `L-1` 하단
/// `AppRoutes.ledgerRepairs` · 규칙 ④)와 플랫폼 분기 0. 조치 = 엔진이 실은 `actionLink` 하나(③) · 폰/웹 차이 = 엔진이 null 로.
final RegExp _routeOrPlatform = RegExp(
  r'AppRoutes\.(?!ledgerRepairs\b)|defaultTargetPlatform|\bkIsWeb\b|\bPlatform\.|'
  r'TargetPlatform\.|\.platform\b',
);

List<String> _scan(String source) {
  final String code = stripComments(source);
  return <String>[
    for (final RegExp re in <RegExp>[
      _raw,
      _rawPattern,
      _reshape,
      _write,
      _routeOrPlatform,
    ])
      for (final RegExpMatch m in re.allMatches(code)) m.group(0)!,
  ];
}

final Map<String, String> _targets = <String, String>{
  for (final File f in dartSourcesIn(
    Directory('${repoRoot.path}/$_journalPackage/lib'),
  ))
    if (_isLedgerTarget(shortPath(f))) shortPath(f): f.readAsStringSync(),
};

bool _isLedgerTarget(String repoRel) {
  if (!repoRel.startsWith('$_journalPackage/')) {
    return false;
  }
  final String rel = repoRel.substring(_journalPackage.length + 1);
  return _ledgerFiles.contains(rel) || rel.startsWith(_ledgerDir);
}

const List<String> _positives = <String>[
  'Text(r.originCode)',
  'rows.where((r) => r.supersedes == x)',
  "if (r.directionCode == 'CANON_CORRECT') {}",
  'Text(r.appliedAt.toString())',
  'Text(r.candidateOriginCodes.first)',
  'ref.watch(p).watchState();',
  'final DraftStore s = ref.read(p);',
  'rows.sort((a, b) => 0);',
  'Text(r.severity.name)',
  // 🆕 검증 반영(2026-10-22 · 변이 R7 · 정합 갈래).
  'Text(rows.firstWhere((r) => r.supersedes == id).label)',
  'final List<LedgerRepairRow> a = rows.whereType<LedgerRepairRow>().toList();',
  'final int i = rows.indexWhere((r) => r.applicable);',
  'opener.open(AppRoutes.x5RepairWizard);',
  'if (kIsWeb) {}',
  'if (defaultTargetPlatform == TargetPlatform.android) {}',
  'if (Platform.isAndroid) {}',
  'if (r case LedgerDiffRow(:final diffId)) {}',
  'if (r case LedgerRepairRow(originCode: final o)) {}',
];

const List<String> _negatives = <String>[
  'Text(r.originLabel)',
  'Text(r.label)',
  'switch (r.severity) { case DiffSeverity.blocking: break; case DiffSeverity.observational: break; }',
  'if (r.supersedes != null) {}',
  'opener.open(AppRoutes.ledgerRepairs);',
  'Text(r.appliedAtText)',
  'Text(r.evidenceHash)',
  'if (r.actionLink case final LinkAction l?) { opener.open(l.deepLink); }',
  'JournalSafetyBanners(safety: s)',
  'for (final (i, c) in r.candidateOrigins.indexed) {}',
  'Text(r.authoredDate.yyyyMmDd)',
  // 🆕 검증 반영 — 정상 꼴.
  'for (final (int i, LedgerRepairRow r) in rows.indexed) {}',
  'Text(r.originLabel, maxLines: 2)',
  'opener.open(AppNavActions.back);',
];

void _say(String line) {
  // ignore: avoid_print
  print(line);
}

void main() {
  group('C-47 원장 차이·정정 · 운영 리듬 · 알림 등급 (01 §21 · §23 · 계약 v1.12 · v1.13)', () {
    test('C-47 ① 허용 키 · DTO 필드 집합 == 목록', () {
      const Set<String> diffKeys = <String>{
        'diff_id',
        'pair',
        'axis',
        'authored_date',
        'delta_label',
        'severity',
        'candidate_origin_codes',
        'status',
        'route',
        'evidence_hash',
        'applicable',
        'pair_label',
        'axis_label',
        'severity_label',
        'status_label',
        'route_label',
        'candidate_origins',
        'detected_at_text',
        'action_link',
      };
      const Set<String> repairKeys = <String>{
        'repair_id',
        'diff_id',
        'direction_code',
        'direction_label',
        'origin_code',
        'decision_id',
        'evidence_hash',
        'supersedes',
        'recomputed_from',
        'applied_at',
        'label',
        'applied_at_text',
        'direction_tone',
        'origin_label',
        'target_text',
        'decision_link',
        'superseded_label',
        'chain_stamp_text',
      };
      final List<(String, Map<String, Object?>)> diffs = _diffRows();
      expect(diffs, isNotEmpty);
      expect(
        LedgerDiffRow.fromJson(diffs.first.$2).toJson().keys.toSet(),
        diffKeys,
      );
      for (final (String path, Map<String, Object?> r) in diffs) {
        expect(
          diffKeys.containsAll(r.keys),
          isTrue,
          reason: '$path ${r['diff_id']}',
        );
      }
      final List<Map<String, Object?>> repairs = _rows(
        FixturePaths.m6LedgerRepairs4,
      );
      expect(
        LedgerRepairRow.fromJson(repairs.first).toJson().keys.toSet(),
        repairKeys,
      );
      for (final Map<String, Object?> r in repairs) {
        expect(
          repairKeys.containsAll(r.keys),
          isTrue,
          reason: '${r['repair_id']}',
        );
      }
      final Map<String, Object?> gap7 = _rows(FixturePaths.m8OpsHomeResumeGap7)
          .single;
      expect(
        (gap7['resume_line']! as Map<String, Object?>).keys.toSet(),
        <String>{'label', 'deep_link'},
        reason: '`resumeLine` = LinkAction(K44).',
      );
      expect(
        OpsDailySummary.fromJson(gap7).toJson().keys,
        contains('resume_line'),
      );
    });

    test('C-47 ② 라벨 — 보드와 같은 쌍 글자 · 후보 칩 = 코드 순서·사전 · 관측 = 주문을 막지 않는다', () {
      final Map<String, String> board = <String, String>{
        for (final Object? c
            in (_rows(FixturePaths.m8ReconBoardDiff).single['cells']!
                as List<Object?>))
          (c! as Map<String, Object?>)['pair']! as String:
              (c as Map<String, Object?>)['label']! as String,
      };
      for (final (String path, Map<String, Object?> r) in _diffRows()) {
        final String id = r['diff_id']! as String;
        for (final String k in <String>[
          'pair_label',
          'axis_label',
          'severity_label',
          'status_label',
          'route_label',
          'detected_at_text',
        ]) {
          expect(r[k], isA<String>(), reason: '$path $id $k');
          expect((r[k]! as String).trim(), isNotEmpty, reason: '$path $id $k');
        }
        expect(
          r['pair_label'],
          board[r['pair']],
          reason: '$path $id — 사전 두 벌 금지(C-47 ②).',
        );
        final List<Object?> codes =
            r['candidate_origin_codes']! as List<Object?>;
        final List<Object?> chips = <Object?>[
          for (final Object? c in r['candidate_origins']! as List<Object?>)
            (c! as Map<String, Object?>)['code'],
        ];
        expect(chips, codes, reason: '$path $id — 칩 = 코드 순서 그대로.');
        for (final Object? c in r['candidate_origins']! as List<Object?>) {
          final Map<String, Object?> chip = c! as Map<String, Object?>;
          expect(
            OriginCodes.writable,
            contains(chip['code']),
            reason: '$path $id',
          );
          expect(chip['label'], isNotEmpty, reason: '$path $id');
        }
        if (r['severity'] == 'OBSERVATIONAL') {
          expect(
            r['severity_label'],
            contains('주문을 막지 않습니다'),
            reason: '$path $id — 경보 피로 방지(02 §5-1).',
          );
        }
      }
    });

    // 🆕 v1.35(01 §44 · K293 · 미결 217 ③) — 승인 → 정정 마법사 **대상 라우트**(그 행 `diff_id` · 허브 글자 = 0).
    test('C-47 ③ 조치 링크 — 승인 → 정정 마법사 대상(그 diff) ∨ 자가보고 → L-3 · 그 밖 = 부재', () {
      for (final (String path, Map<String, Object?> r) in _diffRows()) {
        final Object? link = r['action_link'];
        if (link is! Map<String, Object?>) {
          continue;
        }
        final String deep = link['deep_link']! as String;
        expect(
          deep,
          isNot(AppRoutes.x5RepairWizard),
          reason: '$path ${r['diff_id']} — 허브 글자는 «어느 차이»를 싣지 못한다(K293).',
        );
        final bool repair =
            r['route'] == 'APPROVAL' &&
            deep ==
                AppRoutes.x5RepairTarget.replaceFirst(
                  ':targetId',
                  r['diff_id']! as String,
                ) &&
            AppRoutes.isRegistered(deep);
        final bool audit =
            r['pair'] == 'CANON_SELF_REPORT' && _selfReportLink.hasMatch(deep);
        expect(
          repair || audit,
          isTrue,
          reason: '$path ${r['diff_id']} — 엉뚱한 조치 $deep(K26).',
        );
        expect(link['label'], isNotEmpty);
      }
      expect(
        _rows(FixturePaths.ledgerDiffs4)
            .where((Map<String, Object?> r) => r['action_link'] != null),
        isNotEmpty,
        reason: '조치 표본(공허 방지).',
      );
    });

    test(
      'C-47 ④ 정정 이력 — 계단 = 원본 바로 뒤 · 이후 정정됨 · 소속 · 결정 링크 · 방향 색 · 원인 · 재계산 고지',
      () {
        final Set<Object?> diffIds = <Object?>{
          for (final Map<String, Object?> r in _rows(FixturePaths.ledgerDiffs4))
            r['diff_id'],
        };
        for (final String path in _repairFixtures) {
          final Map<String, Object?> env = _env(path);
          final List<Map<String, Object?>> rows = _rows(path);
          expect(
            rows.isEmpty,
            env['empty_label'] != null,
            reason: '$path — 빈 ⇔ 문장.',
          );
          final Map<Object?, Object?> toneByCode = <Object?, Object?>{};
          for (int i = 0; i < rows.length; i++) {
            final Map<String, Object?> r = rows[i];
            final String id = r['repair_id']! as String;
            if (r['supersedes'] != null) {
              expect(i, greaterThan(0), reason: '$path $id');
              expect(
                rows[i - 1]['repair_id'],
                r['supersedes'],
                reason: '$path $id — 정정의 정정은 원본 바로 뒤(엔진 순서).',
              );
            }
            final Map<String, Object?>? next = i + 1 < rows.length
                ? rows[i + 1]
                : null;
            expect(
              r['superseded_label'] != null,
              next != null && next['supersedes'] == id,
              reason: '$path $id — «이후 정정됨» ⇔ 뒤 행이 이 행을 대체한다.',
            );
            expect(
              diffIds,
              contains(r['diff_id']),
              reason: '$path $id — 소속(정정 적용 ≠ 해소).',
            );
            expect(
              r['decision_link'] != null,
              r['decision_id'] != null,
              reason: '$path $id',
            );
            if (r['decision_link'] case final Map<String, Object?> l) {
              expect(
                l['deep_link'],
                'aaq://journal/decision/${r['decision_id']}',
                reason: '$path $id',
              );
            }
            expect(
              <String>{'DERIVED_RESYNC', 'CANON_CORRECT'},
              contains(r['direction_code']),
              reason: '$path $id',
            );
            final Object? seenTone = toneByCode.putIfAbsent(
              r['direction_code'],
              () => r['direction_tone'],
            );
            expect(
              r['direction_tone'],
              seenTone,
              reason: '$path $id — 같은 방향 = 같은 색.',
            );
            expect(
              OriginCodes.writable,
              contains(r['origin_code']),
              reason: '$path $id',
            );
            expect(r['label'], isNotEmpty, reason: '$path $id — 재계산 고지(C-29).');
            for (final String k in <String>[
              'applied_at_text',
              'origin_label',
              'target_text',
              'chain_stamp_text',
            ]) {
              expect(r[k], isNotEmpty, reason: '$path $id $k');
            }
            expect(
              r['chain_stamp_text'],
              isNot(r['evidence_hash']),
              reason: '$path $id — 체인 스탬프 ≠ 근거 해시.',
            );
          }
        }
        final List<Map<String, Object?>> four = _rows(
          FixturePaths.m6LedgerRepairs4,
        );
        expect(
          four.where((Map<String, Object?> r) => r['supersedes'] != null),
          isNotEmpty,
        );
        expect(
          four.map((Map<String, Object?> r) => r['direction_code']).toSet(),
          <String>{'DERIVED_RESYNC', 'CANON_CORRECT'},
        );
      },
    );

    test('C-47 ⑤ 리듬 — 홈 upcoming == 리듬 표 앞 ≤3 · 모름 ≠ 없음', () {
      final List<Map<String, Object?>> rhythm = _rows(
        FixturePaths.m8OpsRhythmRows,
      );
      for (final String path in _opsHomes) {
        final List<Object?> up =
            _rows(path).single['upcoming']! as List<Object?>;
        expect(up.length, lessThanOrEqualTo(3), reason: path);
        expect(
          jsonEncode(up),
          jsonEncode(rhythm.take(up.length).toList()),
          reason: '$path — 홈 3행 = watchRhythm 의 앞 행(엔진 의무 · K29).',
        );
      }
      final Map<String, Object?> empty = _env(FixturePaths.m8OpsRhythmEmpty);
      expect(empty['empty_kind'], 'NOT_LOADED');
      expect(empty['empty_label'], isNotEmpty);
      expect(empty['rows'], isEmpty);
    });

    test('C-47 ⑥ 알림 등급 — 전 픽스처의 level·code 객체 = 엔진 등급표 · 다이제스트 = P2', () {
      expect(
        _engineLevel.keys.toSet(),
        AlertCodes.values,
        reason: '등급표가 알림 코드 사전 전수와 같다(정본 대조 1회 · 04_안전장치 §5-3).',
      );
      final Map<String, int> count = <String, int>{'P0': 0, 'P1': 0, 'P2': 0};
      for (final String v in _engineLevel.values) {
        count[v] = count[v]! + 1;
      }
      expect(count, <String, int>{
        'P0': 11,
        'P1': 18,
        'P2': 7,
      }); // 🆕 v1.27 +1 · +3 · +1
      int seen = 0;
      final List<String> bad = <String>[];
      for (final String path in FixturePaths.all) {
        for (final Map<String, Object?> o in _objects(_env(path))) {
          final Object? level = o['level'];
          final Object? code = o['code'];
          if (!_levels.contains(level) || code is! String) {
            continue;
          }
          seen++;
          final String? want = _engineLevel[code];
          if (want == null) {
            bad.add('$path ${o['alert_id']} — 등급표에 없는 코드 $code');
          } else if (want != level) {
            bad.add('$path ${o['alert_id']} — $code 는 $want 인데 $level');
          }
        }
      }
      expect(
        bad,
        isEmpty,
        reason: '미결 114 재발 — 픽스처 등급이 엔진 정본과 어긋난다.\n${bad.join('\n')}',
      );
      expect(
        seen,
        greaterThanOrEqualTo(28),
        reason: '대조 대상 객체(실측 28 · 등록부 미매핑 포함).',
      );
      for (final Map<String, Object?> r in _rows(FixturePaths.m8AlertsDigest)) {
        expect(
          r['level'],
          'P2',
          reason: '다이제스트 표본 = P2 묶음(`n01_digest` «P2 3건»).',
        );
      }
    });

    test('C-47 ⑦ L-1·L-2 화면 소스 스캔 — 원값·묶기·쓰기·라우트 상수·플랫폼 분기 0', () {
      final List<String> files = _targets.keys.toList()..sort();
      _say(
        'C-47 ⑦ 대상 ${files.length}파일 — $_journalPackage/{${_ledgerFiles.join(', ')}} + $_ledgerDir**'
        '${files.isEmpty ? ' — 공허 통과' : '\n    ${files.join('\n    ')}'}',
      );
      final List<String> bad = <String>[
        for (final MapEntry<String, String> f in _targets.entries)
          for (final String h in _scan(f.value)) '${f.key}: $h',
      ];
      expect(
        bad,
        isEmpty,
        reason:
            '그리는 것은 `*Label`·`*Text`·칩·링크 · 들여쓰기 = `supersedes != null` · 색 = 열거 switch(K25 · K26).'
            '\n${bad.join('\n')}',
      );
    });

    test('C-47 ⑧ 자체 검증 — 양성은 걸리고 음성은 통과한다', () {
      for (final String snippet in _positives) {
        expect(_scan(snippet), isNotEmpty, reason: '양성 스니펫을 못 잡았다: $snippet');
        _say('C-47 ⑧ 양성 $snippet → ${_scan(snippet).join(' · ')}');
      }
      for (final String snippet in _negatives) {
        expect(_scan(snippet), isEmpty, reason: '음성 스니펫을 잘못 잡았다: $snippet');
      }
    });

    test('C-47 ⑨ R13 진입 링크 표본 — 9b 실사 카드 · 리듬 분기 실사 · 블록 2 X2 한 줄', () {
      final List<Object?> trustLinks = <Object?>[
        for (final String path in FixturePaths.all)
          if (path.startsWith('m7/ledger_trust_'))
            for (final Map<String, Object?> r in _rows(path))
              r['action_deep_link'],
      ];
      expect(
        trustLinks.whereType<String>().where(_selfReportLink.hasMatch),
        isNotEmpty,
        reason: '`SELF_AUDIT_DUE` 동안 배지 = `L-3` 링크(K45 · 엔진 의무).',
      );
      final Map<String, Object?> audit = _rows(FixturePaths.m8OpsRhythmRows)
          .singleWhere(
            (Map<String, Object?> r) => r['code'] == 'QUARTERLY_SELF_AUDIT',
          );
      expect(
        _selfReportLink.hasMatch(audit['route']! as String),
        isTrue,
        reason: 'K31',
      );
      final Map<String, Object?> gap7 = _rows(FixturePaths.m8OpsHomeResumeGap7)
          .single;
      expect(
        (gap7['resume_line']! as Map<String, Object?>)['deep_link'],
        AppRoutes.x2ResumeReport,
        reason: 'K44',
      );
    });

    test(
      'C-47 ⑩ 대조 보드 — 칸 5 · 레벨 원천 · headline 늘 · 전부 일치 표본 (01 §23 · 계약 v1.13)',
      () {
        const Set<String> cellKeys = <String>{
          'pair',
          'label',
          'applicable',
          'state_code',
          'state_label',
          'level',
        };
        for (final String path in <String>[
          FixturePaths.m8ReconBoardDiff,
          FixturePaths.m8ReconBoardOk,
        ]) {
          for (final Object? c
              in _rows(path).single['cells']! as List<Object?>) {
            expect(
              (c! as Map<String, Object?>).keys.toSet(),
              cellKeys,
              reason: '$path — 칸 키 = 6(🆕 level · K2)',
            );
          }
        }
        final DiagnosticsVm diff = DiagnosticsVm.fromJson(
          _rows(FixturePaths.m8ReconBoardDiff).single,
        );
        final DiagnosticsVm ok = DiagnosticsVm.fromJson(
          _rows(FixturePaths.m8ReconBoardOk).single,
        );
        expect(diff.cells.first.toJson().keys.toSet(), cellKeys);
        for (final (String name, DiagnosticsVm vm) in <(String, DiagnosticsVm)>[
          ('diff', diff),
          ('ok', ok),
        ]) {
          expect(vm.cells, hasLength(5), reason: '$name — 칸 수 5 고정(§2-9)');
          expect(
            vm.cells.map((DiagnosticCell c) => c.pair).toSet(),
            LedgerPair.values.toSet(),
            reason: '$name — 칸 = 쌍 5값 전수',
          );
          for (final DiagnosticCell c in vm.cells) {
            if (!c.applicable) {
              expect(
                c.level,
                UiLevel.info,
                reason:
                    '$name ${c.pair} — 해당 없음 = info(통과·차단으로 그리지 않는다 · K3 ⓐ)',
              );
            }
            if (c.level == UiLevel.blocked) {
              expect(
                <LedgerPair>{
                  LedgerPair.canonBroker,
                  LedgerPair.canonSelfReport,
                },
                contains(c.pair),
                reason: '$name ${c.pair} — 파생 불일치는 주문을 막지 않는다(K3 ⓑ · X5 ①)',
              );
            }
            expect(c.stateLabel.trim(), isNotEmpty, reason: '$name ${c.pair}');
          }
          expect(
            vm.headline.trim(),
            isNotEmpty,
            reason: '$name — headline = 늘 엔진 문장(K4)',
          );
        }
        expect(
          ok.headline,
          isNot(diff.headline),
          reason: '전부 일치 날의 문장은 따로 온다(K4)',
        );
        expect(
          ok.cells
              .where((DiagnosticCell c) => c.applicable)
              .every((DiagnosticCell c) => c.level == UiLevel.ok),
          isTrue,
          reason: 'ok — 점검한 칸 전부 일치(K5)',
        );
        expect(ok.cells.any((DiagnosticCell c) => !c.applicable), isTrue);
        expect(
          diff.cells.any(
            (DiagnosticCell c) => c.applicable && c.level != UiLevel.ok,
          ),
          isTrue,
          reason: 'diff — 어긋난 칸이 있다(K6)',
        );
        expect(
          <LedgerPair, String>{
            for (final DiagnosticCell c in ok.cells) c.pair: c.label,
          },
          <LedgerPair, String>{
            for (final DiagnosticCell c in diff.cells) c.pair: c.label,
          },
          reason: '두 표본의 쌍 글자 사전은 한 벌이다',
        );
        // 🆕 검증 반영(2026-10-26 · 변이 R2c·R2d·R2e·R4e) — 칸 색의 유일한 근거(K2)를 표본째 못박고,
        //   점검한 칸의 글자와 색이 말을 맞추며(K3 ⓒ) · 같은 날 차이 표본과도 말을 맞춘다(K6).
        expect(
          <LedgerPair, UiLevel>{
            for (final DiagnosticCell c in diff.cells) c.pair: c.level,
          },
          <LedgerPair, UiLevel>{
            LedgerPair.canonBroker: UiLevel.blocked,
            LedgerPair.canonSupabase: UiLevel.watch,
            LedgerPair.canonGithub: UiLevel.ok,
            LedgerPair.canonCalendar: UiLevel.ok,
            LedgerPair.canonSelfReport: UiLevel.info,
          },
          reason: 'diff — 칸 레벨 = BLOCKED·WATCH·OK·OK·INFO(K6)',
        );
        expect(
          <LedgerPair, UiLevel>{
            for (final DiagnosticCell c in ok.cells) c.pair: c.level,
          },
          <LedgerPair, UiLevel>{
            LedgerPair.canonBroker: UiLevel.ok,
            LedgerPair.canonSupabase: UiLevel.ok,
            LedgerPair.canonGithub: UiLevel.ok,
            LedgerPair.canonCalendar: UiLevel.ok,
            LedgerPair.canonSelfReport: UiLevel.info,
          },
          reason: 'ok — 점검 4칸 OK · 자가보고 해당 없음 INFO(K5)',
        );
        for (final (String name, DiagnosticsVm vm) in <(String, DiagnosticsVm)>[
          ('diff', diff),
          ('ok', ok),
        ]) {
          for (final DiagnosticCell c in vm.cells) {
            if (!c.applicable) continue;
            expect(
              c.stateCode == 'OK',
              c.level == UiLevel.ok,
              reason:
                  '$name ${c.pair} — 점검한 칸: state_code OK ⇔ level OK '
                  '(«어긋납니다» 를 초록으로 그리지 않는다 · K3 ⓒ)',
            );
          }
        }
        final Map<LedgerPair, UiLevel> fromDiffs = <LedgerPair, UiLevel>{
          for (final LedgerDiffRow d in _rows(
            FixturePaths.ledgerDiffs4,
          ).map(LedgerDiffRow.fromJson))
            d.pair: switch ((d.status, d.severity)) {
              (DiffStatus.open, DiffSeverity.blocking) => UiLevel.blocked,
              (DiffStatus.open, DiffSeverity.observational) => UiLevel.watch,
              (DiffStatus.resolved || DiffStatus.accepted, _) => UiLevel.ok,
            },
        };
        expect(fromDiffs, hasLength(4), reason: 'ledger_diffs_4 = 4쌍 한 행씩');
        for (final MapEntry<LedgerPair, UiLevel> e in fromDiffs.entries) {
          expect(
            diff.cells.singleWhere((DiagnosticCell c) => c.pair == e.key).level,
            e.value,
            reason:
                '${e.key} — 칸 = 같은 날 차이 표본 ledger_diffs_4 의 대응(열림 ∧ BLOCKING → '
                'BLOCKED · 열림 ∧ 관측 → WATCH · 해소·수용 → OK · K6)',
          );
        }
      },
    );

    test('C-47 ⑪ R13b 홈 참고 표본 — 억제 + 기한 · 배분 notice 두 갈래 (01 §23 · ⑭)', () {
      final AdviceInboxSummary s = AdviceInboxSummary.fromJson(
        _env(FixturePaths.m8OpsHomeAdviceSuppressedDue)['advice_summary']!
            as Map<String, Object?>,
      );
      expect(s.hasSuppressedNotice, isTrue);
      expect(s.openCount, isNot(0));
      expect(
        s.dueSoonLabel?.trim(),
        isNotEmpty,
        reason: '억제인데 기한 라벨이 실렸다 — 홈 3b 는 headline 한 줄만 그린다(K8)',
      );
      expect(s.headline.trim(), isNotEmpty);
      expect(s.headline, isNot(s.dueSoonLabel));
      // 🆕 검증 반영(2026-10-26 · 변이 R4b·R4c) — 표본이 보이려는 뜻(K8: 억제 날에도 기한의 뜻은
      //   headline 에)과 셈(기한 라벨의 «오늘까지» 건 = 처리 중 건의 일부)을 못박는다.
      expect(s.dueTodayCount, greaterThan(0), reason: '기한 라벨이 실렸으면 오늘까지 건이 있다');
      expect(
        s.dueTodayCount <= s.openCount,
        isTrue,
        reason: '오늘까지 건은 처리 중 건의 일부다',
      );
      final AdviceInboxSummary zero = AdviceInboxSummary.fromJson(
        _env(FixturePaths.m8OpsHomeAdviceZero)['advice_summary']!
            as Map<String, Object?>,
      );
      expect(
        s.headline,
        isNot(zero.headline),
        reason: 'K8 — 처리 중 건이 있는 억제 날은 «아무것도 하지 마십시오» 날이 아니다',
      );
      expect(
        s.headline,
        '오늘은 새 매매 안내를 내지 않았습니다. 처리 중인 안내 1건이 오늘까지입니다.',
        reason: 'K8 — 홈 3b 는 이 한 줄만 그린다 → 기한의 뜻은 headline 에 실린다(표본 글자 고정)',
      );
      final SleeveAllocationVm empty = SleeveAllocationVm.fromJson(
        _rows(FixturePaths.m6AllocationEmpty).single,
      );
      final SleeveAllocationVm band = SleeveAllocationVm.fromJson(
        _rows(FixturePaths.m6AllocationInBand).single,
      );
      expect(empty.noticeText, isNull, reason: 'K7 ⓐ — notice 없음 갈래');
      expect(empty.rows, isEmpty);
      expect(empty.emptyLabel, isNotNull);
      expect(band.noticeText, isNotNull, reason: 'notice 있음 갈래');
    });
  });
}
