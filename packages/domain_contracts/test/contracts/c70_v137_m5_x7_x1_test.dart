// C-70 M5 판 — 01 §46
// (🆕 계약 v1.37 · 발주자 위임 2026-11-14 — 권고대로 · K317~K330).
//
// 정의: 「`M5-13` 해소 게이트 = 한 스트림 VM(플래그 · 두 카운터 · 열린 자가 보고 차이 · 실사 링크 · 보관 명령) · 해제 = 실사 0오차 하나
//        (수동 해제 필드 · 동작 0) · 보관 명령 = 엔진 완성 일괄 확정 하나(버림 0) · 자가 보고 차이 = X5 정정 대상 아님(행 조치 = 다시 실사) ·
//        L-3 현금 축 = 관측 차이 · 미대조면 문장이 말한다 · X1 계획 이전 = `device_retire` 한 RPC + `lease_claim` 티켓 논스 · 넘김 거부 사전 ·
//        D-03 확인 · 비상 선언 = `decision_log.kind` SAFETY + 사유 2(스키마 0)」.
//   ① 판 · 표본 ② M5-13 불변식 ③ 수동 해제 0 ④ 일괄 확정 · 거부 사전 ⑤ 창구 · 받침대 ⑥ 자가 보고 차이 행 ⑦ L-3 현금 축
//   ⑧ X1 리스 넘김 상수 ⑨ DDL 티켓 열 · RPC 서명 주석 ⑩ 결정 사유 · kind 무변경 ⑪ 화면 경계.

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
  FixturePaths.m5SelfAuditResolveOpen,
  FixturePaths.m5SelfAuditResolveHeldBlocked,
  FixturePaths.m5SelfAuditResolveClear,
  FixturePaths.m5HeldReviewResults,
  FixturePaths.m6SelfReportCash2,
];

const List<String> _resolveFixtures = <String>[
  FixturePaths.m5SelfAuditResolveOpen,
  FixturePaths.m5SelfAuditResolveHeldBlocked,
  FixturePaths.m5SelfAuditResolveClear,
];

const String _l3Prefix = 'aaq://ledger/self-report/';

List<SelfAuditResolveVm> _resolveVms() => <SelfAuditResolveVm>[
  for (final String p in _resolveFixtures)
    for (final Map<String, Object?> r in _rows(p))
      SelfAuditResolveVm.fromJson(r),
];

void main() {
  group('C-70 M5 판 (01 §46)', () {
    // 🔵 v1.38(01 §47) — 판 글자 고정 = 최신 창 시험(C-71 ①)만 · 여기는 «봉투 판 = 계약 판».
    test('C-70 ① 판 · 표본 — 신설 5 = 전량 목록 · 디스크 · 봉투 판 · 398', () {
      for (final String path in _newFixtures) {
        expect(FixturePaths.all, contains(path));
        expect(fixtureExists(path), isTrue, reason: path);
        final Map<String, Object?> meta =
            _env(path)['meta']! as Map<String, Object?>;
        expect(meta['contract_version'], contractVersion, reason: path);
      }
      expect(FixturePaths.all, hasLength(398));
      expect(allFixtureFilesOnDisk(), hasLength(398));
    });

    test(
      'C-70 ② M5-13 불변식 — 빈 문장 ⇔ 빈 목록 · 확정 ⊕ 막힘 · 카운터 0|2 · 실사 링크 = L-3',
      () {
        final List<SelfAuditResolveVm> vms = _resolveVms();
        expect(vms, hasLength(3));
        for (final SelfAuditResolveVm v in vms) {
          expect(v.headline.trim(), isNotEmpty);
          expect(v.flagLine.trim(), isNotEmpty);
          expect(v.releaseRuleText.trim(), isNotEmpty);
          expect(v.diffsEmptyLabel == null, v.diffs.isNotEmpty);
          expect(v.heldEmptyLabel == null, v.heldCommands.isNotEmpty);
          expect(<int>{0, 2}, contains(v.counterLines.length));
          for (final String c in v.counterLines) {
            expect(c.trim(), isNotEmpty);
          }
          if (v.confirmHeld != null) {
            expect(v.heldCommands, isNotEmpty);
            expect(v.heldBlockedText, isNull);
            expect(v.confirmHeld!.id, SafetyActionId.heldCommandsConfirm);
            expect(v.confirmHeld!.args.keys.toSet(), <String>{'review_id'});
            expect(v.confirmHeld!.args['review_id']!.trim(), isNotEmpty);
            expect(v.confirmHeld!.label.trim(), isNotEmpty);
          }
          if (v.heldBlockedText != null) {
            expect(v.confirmHeld, isNull);
            expect(v.heldCommands, isNotEmpty);
          }
          for (final LinkAction l in v.auditLinks) {
            expect(l.deepLink, startsWith(_l3Prefix));
            expect(l.label.trim(), isNotEmpty);
          }
          for (final HeldCommandRow h in v.heldCommands) {
            expect(h.commandId.trim(), isNotEmpty);
            for (final String t in <String>[
              h.kindLabel,
              h.summaryText,
              h.receivedAtText,
              h.stateLabel,
            ]) {
              expect(t.trim(), isNotEmpty);
            }
          }
        }
        // 세 갈래가 다 있다 — 확정 가능 · 무결성 막힘 · 빈.
        expect(
          vms.where((SelfAuditResolveVm v) => v.confirmHeld != null),
          hasLength(1),
        );
        expect(
          vms.where((SelfAuditResolveVm v) => v.heldBlockedText != null),
          hasLength(1),
        );
        expect(
          vms.where(
            (SelfAuditResolveVm v) => v.diffs.isEmpty && v.heldCommands.isEmpty,
          ),
          hasLength(1),
        );
      },
    );

    test('C-70 ③ 수동 해제 0 — VM 키 · 표본 · `run` 화이트리스트(해제 id 0)', () {
      const Set<String> keys = <String>{
        'headline',
        'level',
        'flag_line',
        'release_rule_text',
        'counter_lines',
        'diffs',
        'diffs_empty_label',
        'audit_links',
        'held_commands',
        'held_empty_label',
        'confirm_held',
        'held_blocked_text',
        'as_of',
      };
      for (final String p in _resolveFixtures) {
        for (final Map<String, Object?> r in _rows(p)) {
          expect(r.keys.toSet(), keys, reason: p);
        }
      }
      final SelfAuditResolveVm v = _resolveVms().first;
      expect(v.toJson().keys.toSet(), keys);
      for (final String k in keys) {
        expect(
          k,
          isNot(
            matches(
              RegExp('release_(action|button|link)|unlock|clear_flag|manual'),
            ),
          ),
        );
      }
      // 이 판이 더한 동작 id = 보관 확정 하나 · 플래그 해제 · 실사 결과 받아들임 id 없음.
      final Set<String> wires = <String>{
        for (final SafetyActionId id in SafetyActionId.values) id.wire,
      };
      expect(wires, contains('HELD_COMMANDS_CONFIRM'));
      for (final String w in wires) {
        expect(
          w,
          isNot(
            matches(
              RegExp('ADVICE_LEDGER|SELF_AUDIT|HELD_COMMANDS_(DISCARD|DROP)'),
            ),
          ),
        );
      }
      final String safetyActions = File(
        '${libDir.path}/src/commands/safety_actions.dart',
      ).readAsStringSync();
      expect(safetyActions, contains('heldCommandsConfirm'));
      expect(safetyActions, isNot(contains('runSelfAudit')));
    });

    test('C-70 ④ 일괄 확정 — 거부 사전 3 · 도메인 · 결과 표본 · 버림 코드 0', () {
      expect(HeldReviewResultCodes.values, <String>{
        'HELD_REVIEW_STALE',
        'HELD_REVIEW_INTEGRITY_ACTIVE',
        'HELD_REVIEW_ARGS_INVALID',
      });
      expect(
        ContractCodes.byDomain['held_review_result'],
        HeldReviewResultCodes.values,
      );
      expect(SafetyActionId.heldCommandsConfirm.wire, 'HELD_COMMANDS_CONFIRM');
      final List<SafetyActionResult> rs = _rows(
        FixturePaths.m5HeldReviewResults,
      ).map(SafetyActionResult.fromJson).toList();
      expect(rs, hasLength(4));
      expect(rs.map((SafetyActionResult r) => r.id).toSet(), <SafetyActionId>{
        SafetyActionId.heldCommandsConfirm,
      });
      expect(
        rs.where((SafetyActionResult r) => r.reasonCode == null),
        hasLength(1),
      );
      expect(
        rs
            .map((SafetyActionResult r) => r.reasonCode)
            .whereType<String>()
            .toSet(),
        HeldReviewResultCodes.values,
      );
      for (final SafetyActionResult r in rs) {
        expect(r.headline.trim(), isNotEmpty);
        expect(r.handoffRoute, isNull);
        expect(r.actionRunId, startsWith('ar_held_'));
      }
      // 다시 = 묶음이 바뀐 때만(다시 읽고 다시 누른다).
      expect(
        rs
            .where((SafetyActionResult r) => r.retryable)
            .map((SafetyActionResult r) => r.reasonCode),
        <String?>[HeldReviewResultCodes.stale],
      );
      for (final String c in HeldReviewResultCodes.values) {
        expect(c, isNot(contains('DISCARD')));
      }
    });

    test('C-70 ⑤ 창구 · 받침대 — `watchResolve()` Stream · 라우트 = 기존 상수(파라미터 0) · 동기 throw', () {
      final String src = File(
        '${libDir.path}/src/repositories/self_audit_resolve_repository.dart',
      ).readAsStringSync();
      expect(src, contains('Stream<SelfAuditResolveVm> watchResolve();'));
      expect(AppRoutes.m5SelfAuditResolve, 'aaq://m5/self-audit-resolve');
      expect(AppRoutes.all, contains(AppRoutes.m5SelfAuditResolve));
      expect(AppRoutes.m5SelfAuditResolve, isNot(contains('/:')));
      expect(
        () => UnimplementedSelfAuditResolveRepository().watchResolve(),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('C-70 ⑥ 자가 보고 차이 행 — CANON_SELF_REPORT · 열림 · 관측 · 정정 마법사 아님 · 조치 = 다시 실사', () {
      final List<LedgerDiffRow> rows = <LedgerDiffRow>[
        for (final SelfAuditResolveVm v in _resolveVms()) ...v.diffs,
      ];
      expect(rows, hasLength(2));
      expect(rows.map((LedgerDiffRow r) => r.axis).toSet(), <LedgerAxis>{
        LedgerAxis.quantity,
        LedgerAxis.cash,
      });
      for (final LedgerDiffRow r in rows) {
        expect(r.pair, LedgerPair.canonSelfReport);
        expect(r.status, DiffStatus.open);
        expect(r.severity, DiffSeverity.observational);
        expect(
          r.route,
          isNot(RepairRoute.approval),
          reason: 'K320 — X5 정정 대상 아님',
        );
        expect(r.routeLabel, isNot('승인 필요'));
        expect(r.actionLink, isNotNull);
        expect(r.actionLink!.deepLink, startsWith(_l3Prefix));
        expect(r.actionLink!.deepLink, isNot(contains('repair-wizard')));
        expect(
          r.candidateOriginCodes.toSet().difference(<String>{
            OriginCodes.externalCashflow,
            OriginCodes.unrecordedFill,
            OriginCodes.selfReportCorrection,
          }),
          isEmpty,
        );
        expect(
          r.candidateOrigins.map((ReasonChip c) => c.code).toList(),
          r.candidateOriginCodes,
        );
      }
    });

    test('C-70 ⑦ L-3 현금 축 — 관측 차이 1 · 미대조 문장 1 · 결과 안 조치 0 · 새 수치 0', () {
      final List<SelfReportSession> ss = _rows(FixturePaths.m6SelfReportCash2)
          .map(SelfReportSession.fromJson)
          .toList();
      expect(ss, hasLength(2));
      final SelfReportResult diff = ss[0].result!;
      expect(diff.diffs, hasLength(1));
      final LedgerDiffRow c = diff.diffs.single;
      expect(c.pair, LedgerPair.canonSelfReport);
      expect(c.axis, LedgerAxis.cash);
      expect(c.severity, DiffSeverity.observational);
      expect(c.axisLabel, '현금');
      expect(c.actionLink, isNull, reason: '결과 안 = 자기 자신으로 가는 고리 0(v1.12)');
      expect(c.candidateOriginCodes, contains(OriginCodes.externalCashflow));
      expect(diff.emptyLabel, isNull);
      expect(diff.resolveLink?.deepLink, AppRoutes.m5SelfAuditResolve);
      final SelfReportResult none = ss[1].result!;
      expect(none.diffs, isEmpty);
      expect(none.emptyLabel, contains('현금'));
      expect(none.emptyLabel, contains('대조하지 않았습니다'));
      expect(none.resolveLink, isNull);
      // 허용 오차 값은 계약 · 표본에 없다(운영 설정 키 · 발주자 수치 대기 — K323).
      final String all = readFixture(FixturePaths.m6SelfReportCash2);
      expect(all, isNot(contains('tolerance')));
      expect(all, isNot(contains('허용 오차 ')));
    });

    test('C-70 ⑧ X1 리스 넘김 — 이름 1 · 인자 3 · 거부 3 · 기존 표와 서로소 · 기존 표 무변경', () {
      expect(LeaseHandoverRpcNames.values, <String>{'device_retire'});
      expect(LeaseHandoverRpcParams.values, <String>{
        'p_ticket_nonce_hash',
        'p_ticket_ttl_minutes',
        'p_ticket_nonce',
      });
      expect(LeaseHandoverResultCodes.values, <String>{
        'LEASE_TICKET_REQUIRED',
        'LEASE_TICKET_INVALID',
        'LEASE_TICKET_EXPIRED',
      });
      expect(
        ContractCodes.byDomain['lease_handover_result'],
        LeaseHandoverResultCodes.values,
      );
      expect(
        LeaseHandoverRpcNames.values.intersection(LeaseRpcNames.values),
        isEmpty,
      );
      expect(
        LeaseHandoverRpcParams.values.intersection(LeaseRpcParams.values),
        isEmpty,
      );
      expect(
        LeaseHandoverResultCodes.values.intersection(
          LeaseRpcResultCodes.values,
        ),
        isEmpty,
      );
      // 지금 SQL(E11k-e2)이 쓰는 표 = 그대로(부트스트랩 대조 시험이 서 있다 — K291 결).
      expect(LeaseRpcNames.values, <String>{
        'lease_claim',
        'lease_renew',
        'lease_revoke',
      });
      expect(LeaseRpcParams.values, hasLength(5));
      expect(LeaseRpcResultCodes.values, hasLength(5));
      for (final String p in LeaseHandoverRpcParams.values) {
        expect(p, startsWith('p_'));
      }
    });

    test('C-70 ⑨ DDL — `operator_lease` 티켓 2열 · 짝 check · RPC 서명 주석(device_retire · p_ticket_nonce)', () {
      final String d = File('${ddlDir.path}/batch_d_supabase.sql')
          .readAsStringSync();
      final RegExpMatch? t = RegExp(
        r'create table if not exists operator_lease \(([\s\S]*?)\n\);',
      ).firstMatch(d);
      expect(t, isNotNull);
      final String body = t!.group(1)!;
      expect(body, contains('ticket_hash        text,'));
      expect(body, contains('ticket_expires_at  timestamptz,'));
      expect(
        body,
        contains('check ((ticket_hash is null) = (ticket_expires_at is null))'),
      );
      expect(
        d,
        contains(
          'device_retire (p_device_id text, p_epoch bigint, p_ticket_nonce_hash text, p_ticket_ttl_minutes int)',
        ),
      );
      expect(d, contains('lease_claim 셋째 인자 p_ticket_nonce text default null'));
      for (final String c in LeaseHandoverResultCodes.values) {
        expect(d, contains(c), reason: c);
      }
      // 클라이언트 UPDATE 정책 0 그대로(쓰기 = RPC 만).
      expect(d, isNot(contains('on operator_lease for update')));
      expect(d, isNot(contains('on app_device for update')));
    });

    test('C-70 ⑩ 결정 사유 — X1 2 · 14 · kind CHECK 9 그대로(X1 kind 0)', () {
      expect(DecisionReasonCodes.x1D03Confirmed, 'X1_D03_CONFIRMED');
      expect(DecisionReasonCodes.x1EmergencyDeclared, 'X1_EMERGENCY_DECLARED');
      expect(DecisionReasonCodes.values, hasLength(14));
      expect(
        ContractCodes.byDomain['decision_reason'],
        DecisionReasonCodes.values,
      );
      final String a = File('${ddlDir.path}/batch_a_decision_mode.sql')
          .readAsStringSync();
      final RegExpMatch? m = RegExp(
        r'kind\s+TEXT\s+NOT NULL CHECK \(kind IN\s*\(([^)]*)\)\)',
      ).firstMatch(a);
      expect(m, isNotNull);
      // 숫자 낀 글자(`X1_…`)도 잡는다 — 변이 M18(첫 판 정규식이 놓쳤다).
      final Set<String> kinds = RegExp(r"'([A-Z0-9_]+)'")
          .allMatches(m!.group(1)!)
          .map((RegExpMatch e) => e.group(1)!)
          .toSet();
      expect(kinds, <String>{
        'ENTRY',
        'EXIT',
        'REBALANCE',
        'DEPOSIT',
        'WITHDRAWAL',
        'SAFETY',
        'RESUME',
        'LEDGER_FIX',
        'MANUAL',
      });
      expect(kinds.any((String k) => k.startsWith('X1')), isFalse);
    });

    test(
      'C-70 ⑪ 화면 경계 — 새 사전 · 창구는 `ui_safety` 밖 화면이 부르지 않는다 · 카운터 · 문턱 수치 0',
      () {
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
            expect(
              s,
              isNot(contains('SelfAuditResolveRepository')),
              reason: f.path,
            );
            expect(s, isNot(contains('HeldReviewResultCodes')), reason: f.path);
            expect(s, isNot(contains('heldCommandsConfirm')), reason: f.path);
          }
        }
        // 계약 lib 에 허용 오차 · 문턱 수치 키 0(운영 설정 · SPEC 02 §4 몫 — C-32).
        final String dto = File('${libDir.path}/src/dto/self_audit.dart')
            .readAsStringSync();
        expect(dto, isNot(matches(RegExp(r'tolerance|threshold|문턱\s*=\s*\d'))));
      },
    );
  });
}
