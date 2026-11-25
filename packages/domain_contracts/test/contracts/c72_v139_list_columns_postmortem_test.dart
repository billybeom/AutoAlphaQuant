// C-72 뷰어 목록 열 · postmortem · 리뷰 3차 등재 · 생체 목적 — 01 §48
// (🆕 계약 v1.39 · 발주자 위임 2026-11-14 — 권고대로 · K338~K352 · 13 §8 R269).
//
// 정의: 「행 표 목록 = 차례 열 `<목록>_rank`(기본 호출 · 상한 없이 1부터 · null = 밖) · 봉투 빈 문장 2 · 기간 프리셋 열 —
//        push 빌더 비요구 · 결속 밖 / postmortem = 목록 VM + 라우트 하나(쓰기 = 기존 runPostmortem) /
//        엔진이 먼저 쓴 코드 = 계약 사전 안(원천 대조) / 생체 대화상자 = 목적마다 글자 한 벌」.
//   ① 판 · 표본 ② 목록 열 ③ 봉투 열 ④ 회차 키 꼴 ⑤ 230 ⓒ 창구 글자 ⑥ postmortem ⑦ 등재 · 사전
//   ⑧ 엔진 코드 ⊆ 계약(리뷰 3차 I-2) ⑨ 생체 목적 ⑩ 배치 D 넣기 정책 · 리스 문언 ⑪ 공개 가입 확인 ⑫ R-01 gap7 ⑬ 화면 경계.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _rows(String path) =>
    (_env(path)['rows']! as List).cast<Map<String, Object?>>();

const List<String> _newFixtures = <String>[
  FixturePaths.m5PostmortemListEmpty,
  FixturePaths.m5PostmortemListDue,
  FixturePaths.m5PostmortemListWrittenOverdue,
  FixturePaths.m8IncidentBannerPostmortemDue,
];

const List<String> _pmFixtures = <String>[
  FixturePaths.m5PostmortemListEmpty,
  FixturePaths.m5PostmortemListDue,
  FixturePaths.m5PostmortemListWrittenOverdue,
];

/// 표 → 목록 열(이름 · 창구) — K339 · K340 · K341 전량.
const Map<String, List<(String, String)>> _wantListColumns =
    <String, List<(String, String)>>{
      'rm_journal': <(String, String)>[
        ('timeline_rank', 'JournalRepository.watchTimeline'),
      ],
      'rm_holding': <(String, String)>[
        ('holdings_rank', 'HoldingsRepository.watchHoldings'),
      ],
      'rm_performance_point': <(String, String)>[
        ('series_rank', 'PerformanceRepository.series'),
      ],
      'rm_rebalance_event': <(String, String)>[
        ('events_rank', 'RebalanceRepository.watchEvents'),
      ],
      'rm_alert': <(String, String)>[
        ('inbox_rank', 'AlertRepository.watchInbox'),
      ],
      'rm_config_view': <(String, String)>[
        ('range_presets', 'ConfigRepository.watchRangePresets'),
      ],
      'rm_advice': <(String, String)>[
        ('inbox_rank', 'AdviceRepository.watchInbox'),
        ('history_rank', 'AdviceRepository.watchHistory'),
      ],
      'rm_ledger_diff': <(String, String)>[
        ('open_diffs_rank', 'LedgerRepository.watchOpenDiffs'),
      ],
      'rm_blind_review': <(String, String)>[
        ('queue_rank', 'JournalRepository.watchBlindReviewQueue'),
      ],
      'rm_list_envelope': <(String, String)>[
        ('filtered_empty_label', ReadModelListColumn.everyList),
        ('scope_empty_label', ReadModelListColumn.everyList),
      ],
    };

/// 계약 저장소 인터페이스 → 본문(주석 뺌).
Map<String, String> _interfaces() {
  final Map<String, String> out = <String, String>{};
  for (final File f in dartSourcesIn(
    Directory('${libDir.path}/src/repositories'),
  )) {
    final String src = stripComments(f.readAsStringSync());
    for (final RegExpMatch m in RegExp(
      r'abstract interface class (\w+)[^{]*\{(.*?)\n\}',
      dotAll: true,
    ).allMatches(src)) {
      out[m[1]!] = m[2]!;
    }
  }
  return out;
}

/// «저장소.메서드» 가 그 인터페이스 본문에 선언돼 있나.
bool _declares(Map<String, String> ifaces, String window) {
  final List<String> p = window.split('.');
  final String? body = ifaces[p.first];
  return body != null && RegExp('\\b${p.last}\\(').hasMatch(body);
}

/// 엔진 파일 한 클래스의 글자 상수(`static const String x = 'Y';`).
Set<String> _engineClassCodes(String rel, String cls) {
  final String src = stripComments(
    File('${repoRoot.path}/packages/core_engine/lib/src/$rel')
        .readAsStringSync(),
  );
  final RegExpMatch? m = RegExp(
    'abstract final class $cls\\s*\\{(.*?)\\n\\}',
    dotAll: true,
  ).firstMatch(src);
  expect(m, isNotNull, reason: '$rel $cls');
  return <String>{
    for (final RegExpMatch c in RegExp(
      r"static const String \w+\s*=\s*'([^']*)';",
    ).allMatches(m![1]!))
      c[1]!,
  };
}

/// 엔진 파일의 맨 위 글자 상수(`const String kX = 'Y';`) 가운데 접두가 맞는 것.
Set<String> _engineTopCodes(String rel, String prefix) {
  final String src = stripComments(
    File('${repoRoot.path}/packages/core_engine/lib/src/$rel')
        .readAsStringSync(),
  );
  return <String>{
    for (final RegExpMatch c in RegExp(
      r"^const String k\w+\s*=\s*'([^']*)';",
      multiLine: true,
    ).allMatches(src))
      if (c[1]!.startsWith(prefix)) c[1]!,
  };
}

void main() {
  group('C-72 뷰어 목록 열 · postmortem · 등재 · 생체 목적 (01 §48)', () {
    // 🔵 v1.40(01 §49) — 판 글자 · 수 고정 = 최신 창 시험(C-73 ①)만 · 여기는 «1.39.0 이상 · 402 이상 · 봉투 판 = 계약 판».
    test('C-72 ① 판 · 표본 — 1.39.0 이상 · 402 이상(신설 4 · 개정 1) · 봉투 판', () {
      expect(contractVersion, isNot(anyOf('1.37.0', '1.38.0')));
      expect(FixturePaths.all.length, greaterThanOrEqualTo(402));
      expect(allFixtureFilesOnDisk().length, FixturePaths.all.length);
      for (final String path in _newFixtures) {
        expect(FixturePaths.all, contains(path));
        expect(fixtureExists(path), isTrue, reason: path);
        final Map<String, Object?> meta =
            _env(path)['meta']! as Map<String, Object?>;
        expect(meta['contract_version'], contractVersion, reason: path);
      }
    });

    test(
      'C-72 ② 목록 열 — 표마다 전량 · 표 맨 끝 · 형 · 결속 · DTO 밖 · 키 밖 · 창구 = 그 인터페이스 메서드',
      () {
        final Map<String, String> ifaces = _interfaces();
        final Map<String, List<(String, String)>> got =
            <String, List<(String, String)>>{
              for (final ReadModelTable t in ReadModelTables.all)
                if (t.listColumns.isNotEmpty)
                  t.name: <(String, String)>[
                    for (final ReadModelListColumn c in t.listColumns)
                      (c.name, c.window),
                  ],
            };
        expect(got, _wantListColumns);
        for (final ReadModelTable t in ReadModelTables.all) {
          final List<String> cols = t.columns
              .map((ReadModelColumn c) => c.name)
              .toList();
          final List<String> names = t.listColumns
              .map((ReadModelListColumn c) => c.name)
              .toList();
          // 표 맨 끝 · 같은 차례(DDL 뒤에 붙는다 — 옛 열 차례 무변경).
          expect(
            cols.sublist(cols.length - names.length),
            names,
            reason: '${t.name} 목록 열 = 맨 끝',
          );
          for (final ReadModelListColumn c in t.listColumns) {
            final ReadModelColumn col = t.columns.firstWhere(
              (ReadModelColumn x) => x.name == c.name,
            );
            final ReadModelColumnType want = c.name.endsWith('_rank')
                ? ReadModelColumnType.bigint
                : c.name == 'range_presets'
                ? ReadModelColumnType.jsonb
                : ReadModelColumnType.text;
            expect(col.type, want, reason: '${t.name}.${c.name}');
            expect(col.checkValues, isEmpty);
            expect(t.keyColumns, isNot(contains(c.name)));
            expect(
              t.extraColumns.map((ReadModelExtraColumn x) => x.name),
              isNot(contains(c.name)),
              reason: '${t.name}.${c.name} — DTO 밖 열이면 push 빌더가 요구한다',
            );
            for (final ReadModelBinding b in t.bindings) {
              expect(
                c.name.startsWith(b.prefix) && b.prefix.isNotEmpty,
                isFalse,
                reason: '${t.name}.${c.name} — 결속 접두 열 아님',
              );
            }
            expect(c.rule, isNotEmpty);
            if (c.window != ReadModelListColumn.everyList) {
              expect(_declares(ifaces, c.window), isTrue, reason: c.window);
            }
          }
          expect(names.toSet(), hasLength(names.length));
        }
        // 행 표 목록 창구(봉투 있는 것)는 전부 차례 열이 있다 — 리듬(rm_ops_summary jsonb 목록) 빼고.
        final Set<String> ranked = <String>{
          for (final ReadModelTable t in ReadModelTables.all)
            for (final ReadModelListColumn c in t.listColumns)
              if (c.name.endsWith('_rank')) c.window,
        };
        for (final String code in ReadModelListCodes.all) {
          if (code == ReadModelListCodes.opsSummaryWatchRhythm) continue;
          expect(ranked, contains(code), reason: '$code 차례 열');
        }
      },
    );

    test(
      'C-72 ③ 봉투 열 — 빈 문장 2(필터 · 회차) · has_more 열 0(limit+1 · K310 그대로)',
      () {
        final List<String> env = ReadModelTables.listEnvelope.columns
            .map((ReadModelColumn c) => c.name)
            .toList();
        expect(env, <String>[
          'list_code',
          'as_of',
          'empty_kind',
          'empty_label',
          'filtered_empty_label',
          'scope_empty_label',
        ]);
        expect(env, isNot(contains('has_more')));
        // 빌더가 요구하는 DTO 밖 열은 v1.36 넷 그대로(엔진 push 무변경).
        expect(
          ReadModelTables.listEnvelope.extraColumns.map(
            (ReadModelExtraColumn x) => x.name,
          ),
          <String>['list_code', 'as_of', 'empty_kind', 'empty_label'],
        );
      },
    );

    test('C-72 ④ 회차 키 꼴 — 퍼센트 한 번 풀기 · 못 풀면 그대로(엔진 journalKeyOf 와 같은 규칙)', () {
      expect(routeParamKeyOf('RB-2026-09-01'), 'RB-2026-09-01');
      expect(routeParamKeyOf('RB%2326'), 'RB#26');
      expect(routeParamKeyOf('a%2Fb%3Fc'), 'a/b?c');
      expect(routeParamKeyOf('R%2523'), 'R%23', reason: '한 번만 푼다');
      expect(routeParamKeyOf('50%'), '50%', reason: '못 풀면 그대로');
      expect(routeParamKeyOf('x@y+z'), 'x@y+z');
    });

    test('C-72 ⑤ 230 ⓒ — 리듬 · 오늘 창구 = OpsSummaryRepository · 창구 글자 = 그 인터페이스 메서드(좁힘)', () {
      final Map<String, String> ifaces = _interfaces();
      expect(
        ReadModelListCodes.opsSummaryWatchRhythm,
        'OpsSummaryRepository.watchRhythm',
      );
      expect(
        ReadModelListCodes.opsStatusWatchRhythm,
        ReadModelListCodes.opsSummaryWatchRhythm,
      );
      expect(
        ReadModelListCodes.all,
        contains(ReadModelListCodes.opsSummaryWatchRhythm),
      );
      for (final ReadModelTable t in ReadModelTables.all) {
        for (final String code in t.listCodes) {
          expect(_declares(ifaces, code), isTrue, reason: '${t.name} $code');
        }
        for (final ReadModelBinding b in t.bindings) {
          for (final String f in b.feeds) {
            expect(_declares(ifaces, f), isTrue, reason: '${t.name} $f');
          }
        }
      }
      for (final String code in ReadModelListCodes.all) {
        expect(code, isNot(startsWith('OpsStatusRepository.')));
      }
    });

    test('C-72 ⑥ postmortem — 목록 VM 불변식 · 차례 · 라우트 · 창구 · 받침대 · 배너 조치', () {
      int rows = 0;
      for (final String path in _pmFixtures) {
        for (final Map<String, Object?> r in _rows(path)) {
          final PostmortemListVm vm = PostmortemListVm.fromJson(r);
          expect(vm.rows.isEmpty, vm.emptyLabel != null, reason: path);
          for (final PostmortemRow row in vm.rows) {
            rows++;
            expect(row.incidentId, isNotEmpty);
            if (row.form != null) expect(row.writtenText, isNull);
            if (row.writtenText != null) expect(row.form, isNull);
            if (row.nextLink != null) {
              expect(row.nextLink!.deepLink, AppRoutes.m5StoppedDecision);
            }
            if (row.overdue) {
              expect(row.form, isNotNull, reason: '기한 넘김 = 쓸 차례');
            }
          }
        }
      }
      expect(rows, 3);
      final PostmortemListVm two = PostmortemListVm.fromJson(
        _rows(FixturePaths.m5PostmortemListWrittenOverdue).single,
      );
      expect(two.rows.map((PostmortemRow r) => r.severityLabel), <String>[
        'SEV1',
        'SEV2',
      ], reason: '차례 = 심각도 → 기한(엔진)');
      expect(AppRoutes.all.last, AppRoutes.m5Postmortem);
      expect(AppRoutes.m5Postmortem, 'aaq://m5/postmortem');
      expect(AppRoutes.m5Postmortem, isNot(contains('/:')), reason: '파라미터 0');
      expect(AppRoutes.isRegistered(AppRoutes.m5Postmortem), isTrue);
      final String repo = _interfaces()['PostmortemRepository']!;
      expect(
        RegExp(r'\b(\w+)\(').allMatches(repo).map((RegExpMatch m) => m[1]),
        <String>['watchPostmortems'],
      );
      expect(
        () => UnimplementedPostmortemRepository().watchPostmortems(),
        throwsUnimplementedError,
      );
      // 쓰기 = 기존 `PostmortemSubmission` · 결과 사전 3 그대로(C-7 표면 무변경).
      expect(PostmortemResultCodes.values, hasLength(3));
      final IncidentBannerVm due = IncidentBannerVm.fromJson(
        _rows(FixturePaths.m8IncidentBannerPostmortemDue).single,
      );
      expect(due.banner!.kind, IncidentKind.other);
      expect(due.banner!.actionLink!.deepLink, AppRoutes.m5Postmortem);
      final IncidentBannerVm other = IncidentBannerVm.fromJson(
        _rows(FixturePaths.m8IncidentBannerOther).single,
      );
      expect(other.banner!.actionLink, isNull, reason: '옛 other 표본 무변경');
    });

    test('C-72 ⑦ 등재 — 엔진 예약 4 · 닫힌 원장 · 경보 3 · 가입 확인 · 도메인 · 승격 차례 주석', () {
      expect(LivePromotionResultCodes.values, <String>{
        'HANDOVER_SESSION_INVALID',
        'LIVE_PROMOTION_NOT_OBSERVING',
        'LIVE_PROMOTION_NOT_AUTO_TRADE',
        'LIVE_PROMOTION_CLOCK_BEHIND',
        'LIVE_PROMOTION_ROLLED_BACK',
        'LIVE_PROMOTION_CONFIG_UNAVAILABLE',
      });
      expect(SimToAutoCommitResultCodes.values, hasLength(15));
      expect(
        SimToAutoCommitResultCodes.values,
        containsAll(<String>{
          'SIM_LEDGER_FATE_CONFIG_UNAVAILABLE',
          'SIM_TO_AUTO_CONFIG_NOT_APPROVED',
          'SIM_TO_AUTO_ACCOUNT_DUPLICATE',
        }),
      );
      expect(LedgerWriteGateCodes.values, <String>{'LEDGER_CLOSED'});
      expect(SupabaseSignupResultCodes.values, <String>{
        'SUPABASE_SIGNUP_OPEN',
      });
      expect(
        ContractCodes.byDomain['ledger_write_gate'],
        LedgerWriteGateCodes.values,
      );
      expect(
        ContractCodes.byDomain['supabase_signup_result'],
        SupabaseSignupResultCodes.values,
      );
      expect(AlertCodes.values, hasLength(39));
      expect(AlertCodes.killSwitch, <String>{'KILL_SWITCH_ACK_MISMATCH'});
      expect(AlertCodes.readModelPush, <String>{
        'READ_MODEL_PUSH_SECRET_BLOCKED',
        'READ_MODEL_PUSH_REJECTED',
      });
      // 알림 코드 ≠ 확인 결과 코드(같은 사건 두 축).
      expect(
        AlertCodes.killSwitchAckMismatch,
        isNot(KillSwitchResultCodes.ackMismatch),
      );
      // 새 글자는 한 도메인에만(리스 무효 · 생체 = 기존 한 벌 그대로).
      for (final String c in <String>{
        ...LedgerWriteGateCodes.values,
        ...SupabaseSignupResultCodes.values,
        LivePromotionResultCodes.configUnavailable,
        SimToAutoCommitResultCodes.fateConfigUnavailable,
        SimToAutoCommitResultCodes.configNotApproved,
        SimToAutoCommitResultCodes.accountDuplicate,
      }) {
        final List<String> domains = <String>[
          for (final MapEntry<String, Set<String>> e
              in ContractCodes.byDomain.entries)
            if (e.value.contains(c)) e.key,
        ];
        expect(domains, hasLength(1), reason: '$c → $domains');
      }
      expect(
        LivePromotionResultCodes.values,
        isNot(contains(JournalReasonCodes.leaseInvalid)),
      );
      final String sim = File('${libDir.path}/src/labels/sim_codes.dart')
          .readAsStringSync();
      expect(sim, contains('**리스 → 설정 → 재판정**'));
    });

    test('C-72 ⑧ 엔진 코드 ⊆ 계약 — core 원천 대조(리뷰 3차 I-2 · 사전 밖 글자 0)', () {
      final Set<String> commit = _engineClassCodes(
        'mode/sim_to_auto_commit.dart',
        'SimToAutoCommitCodes',
      );
      expect(commit, isNotEmpty);
      expect(
        commit.difference(SimToAutoCommitResultCodes.values),
        isEmpty,
        reason: '엔진 SimToAutoCommitCodes 가 계약 사전 밖 글자를 낸다',
      );
      expect(
        _engineTopCodes(
          'mode/sim_to_auto_switch.dart',
          'SIM_TO_AUTO_',
        ).difference(SimToAutoCommitResultCodes.values),
        isEmpty,
      );
      final Set<String> promo = _engineClassCodes(
        'mode/live_promotion.dart',
        'LivePromotionCodes',
      );
      expect(promo, isNotEmpty);
      expect(promo.difference(LivePromotionResultCodes.values), isEmpty);
      final Set<String> s2a = _engineClassCodes(
        'mode/sim_to_auto.dart',
        'SimToAutoCodes',
      );
      expect(s2a, isNotEmpty);
      expect(s2a.difference(SimToAutoResultCodes.values), isEmpty);
      final Set<String> session = _engineClassCodes(
        'mode/handover_session.dart',
        'HandoverSessionCodes',
      );
      expect(session, isNotEmpty);
      expect(
        session.difference(<String>{
          ...HandoverSessionResultCodes.values,
          LivePromotionResultCodes.sessionInvalid,
        }),
        isEmpty,
      );
      expect(_engineTopCodes('ops/lease_gate.dart', 'LEASE_'), <String>{
        JournalReasonCodes.leaseInvalid,
      });
    });

    test('C-72 ⑨ 생체 목적 — 4 · 목적마다 글자 · 서약 글자 = 서약만 · 실주문 동작 = «실제 주문» · 수치 0', () {
      expect(
        BiometricPurpose.values.map((BiometricPurpose p) => p.wire),
        <String>[
          'PLEDGE_SIGN',
          'HANDOVER_START',
          'LIVE_PROMOTION',
          'X1_MIGRATION',
        ],
      );
      final Set<String> titles = <String>{};
      for (final BiometricPurpose p in BiometricPurpose.values) {
        final BiometricPrompt b = BiometricPromptText.of(p);
        expect(b.title, isNotEmpty);
        expect(b.subtitle, isNotEmpty);
        titles.add(b.title);
        expect('${b.title}${b.subtitle}', isNot(matches(RegExp(r'\d'))));
        if (p != BiometricPurpose.pledgeSign) {
          expect(
            '${b.title}${b.subtitle}',
            isNot(contains('서약')),
            reason: p.wire,
          );
        }
      }
      expect(titles, hasLength(BiometricPurpose.values.length));
      expect(BiometricPromptText.livePromotion.subtitle, contains('실제 주문'));
      expect(
        BiometricPromptText.handoverStart.subtitle,
        contains('실제 주문은 나가지 않습니다'),
      );
      expect(BiometricPromptText.cancel, '취소');
      // 서약 글자 = 엔진 R159 글자 그대로(지금 대화상자 — 배선 카드가 이 상수로 옮긴다).
      final String eng = File(
        '${repoRoot.path}/packages/core_engine/lib/src/onboarding/biometric_sign.dart',
      ).readAsStringSync();
      expect(eng, contains("'${BiometricPromptText.pledgeSign.title}'"));
      expect(eng, contains("'${BiometricPromptText.pledgeSign.subtitle}'"));
    });

    test('C-72 ⑩ 배치 D — 넣기 정책 = 첫 클레임 뒤 운영 사용자만 · 리스 표 뒤 · 클레임 문언 정정 · rm_* RLS 무변경', () {
      final String d = File('${ddlDir.path}/batch_d_supabase.sql')
          .readAsStringSync();
      final int table = d.indexOf('create table if not exists operator_lease');
      final int policy = d.indexOf(
        'create policy device_insert_viewer_only on app_device',
      );
      expect(table, greaterThan(0));
      expect(policy, greaterThan(table), reason: '정책이 리스 표를 읽는다 — 표 뒤에서 만든다');
      final String body = d.substring(policy, d.indexOf(';', policy));
      expect(body, contains("role = 'viewer' and status = 'PENDING'"));
      expect(body, contains('not exists (select 1 from operator_lease)'));
      expect(body, contains('h.owner_uid = auth.uid()'));
      expect(
        RegExp(r'create policy \w+ on app_device for (update|delete)')
            .hasMatch(d),
        isFalse,
      );
      expect(d, isNot(contains('· 만료 ∨ 같은 기기 → 이 기기')));
      expect(d, contains('REVOKED · RETIRED 일 때만'));
      expect(
        ReadModelRls.selectUsing,
        "exists (select 1 from app_device d where d.auth_uid = auth.uid() and d.status = 'ACTIVE')",
      );
    });

    test('C-72 ⑪ 공개 가입 확인 — 글자 하나 · 전송 · 로그인 사전과 서로소 · 로그인 결과 축', () {
      expect(
        SupabaseSignupResultCodes.values.intersection(<String>{
          ...SupabaseTimeResultCodes.values,
          ...SupabaseAuthResultCodes.values,
          ...SupabaseInputResultCodes.values,
        }),
        isEmpty,
      );
      final String cmd = File('${libDir.path}/src/enums/command.dart')
          .readAsStringSync();
      expect(cmd, contains('`SupabaseSignupResultCodes`'));
    });

    test('C-72 ⑫ R-01 gap7 — 분기 = 비상 이전 먼저 · 고지 = 이어받지 않음 · 다른 표본 고지 무변경', () {
      final RestartVm gap7 = RestartVm.fromJson(
        _rows(FixturePaths.m8RestartVmGap7).single,
      );
      expect(gap7.branches.map((LinkAction b) => b.deepLink), <String>[
        AppRoutes.x1MigrationEmergency,
      ]);
      expect(gap7.inheritNotice, contains('이어받지 않습니다'));
      expect(gap7.inheritNotice, isNot(contains('켜진 그대로')));
      final RestartVm lost = RestartVm.fromJson(
        _rows(FixturePaths.m8RestartVmLostPhone).single,
      );
      expect(lost.inheritNotice, '킬스위치와 차단 플래그는 켜진 그대로 이어받습니다.');
    });

    test('C-72 ⑬ 화면 경계 — postmortem 창구 · 목록 열은 `ui_safety` · 뷰어 밖 화면이 부르지 않는다 · 수치 0', () {
      final Directory pkgs = Directory('${packageRoot.path}/..');
      for (final FileSystemEntity e in pkgs.listSync()) {
        if (e is! Directory) continue;
        final String name = e.uri.pathSegments
            .where((String s) => s.isNotEmpty)
            .last;
        if (!name.startsWith('ui_') || name == 'ui_safety') continue;
        final Directory lib = Directory('${e.path}/lib');
        if (!lib.existsSync()) continue;
        for (final FileSystemEntity f in lib.listSync(recursive: true)) {
          if (f is! File || !f.path.endsWith('.dart')) continue;
          final String s = f.readAsStringSync();
          expect(s, isNot(contains('PostmortemRepository')), reason: f.path);
          expect(s, isNot(contains('ReadModelListColumn')), reason: f.path);
        }
      }
      final String dto = stripCommentsAndStrings(
        File('${libDir.path}/src/dto/postmortem.dart').readAsStringSync(),
      );
      expect(dto, isNot(matches(RegExp(r'\b\d+\b'))), reason: '기한 수치 = 엔진 상수');
    });
  });
}
