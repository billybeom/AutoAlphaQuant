// C-38 플래너 표시 계약 — 01 §14-1~§14-8 · §7 표 C-38(🆕 계약 v1.4 · 설계 Δ4 · D3·D5·D9·D20).
//
// 정의: 「S7-4 입금 플래너 화면이 **받은 글자를 받은 자리에** 그리기만 하면 되게, 엔진이 보내는
//        `DepositPreviewResult`·`DepositPlan` 이 스스로 완결되고 서로 맞는다」.
// 픽스처 면(대상 = `DepositPreviewResult` 행 전부 + 코어 `DepositPlan` 2건 · 등록부가 타입으로 고른다):
//   ① 래퍼는 `plan`·`input_rejected_text`·`blocked_text` 가운데 **정확히 하나** non-null ·
//      `blocked_action` 은 `blocked_text` 가 있을 때만.
//   ② `*_text`·`*_label`·`label`·제목·고지가 비지 않는다 · `residual_krw_cash_text == null ⇔
//      residual_krw_cash == 0` · `orders_empty_text != null ⇔ order_drafts == []` ·
//      `limit_price_text == null ⇔ limit_price == null`.
//   ③ DepositPlan 픽스처 전부의 `preview_notice` 가 «미리보기입니다»로 시작하고 **같은 문자열**이다
//      (고지 전용 · 01 §14-5). 🔴 인출(`WithdrawalPlan`)은 v1.5 라 대상이 아니다.
//   ④ `funding_steps` 는 null 이거나 비지 않는다 · order 는 1부터 연속 · expected_proceeds > 0.
//   ⑤ Σ allocations.amount + residual_krw_cash == deposit_amount.
//   ⑥ 슬리브별 Σ(수량 × 지정가, BUY 초안) ≤ 그 슬리브 충당액.
//   ⑦ 슬리브 B 행(충당·초안)의 `account_alias` ∈ `kFixturePensionAccountAliases` · 계획의 모든
//      `account_alias` ∈ `kFixtureAccountAliases`(정본 = `fixtures/README.md` «픽스처 계좌 별칭 표» · D9 ⑧).
//   ⑧ 사유 칩 코드 ∈ `ContractCodes`.
//   ⑨ 입금 등록 접수증 픽스처의 전 행이 `DEPOSIT_REGISTER` 다.
// ui 스캔(🔴 CI 계약 테스트 안에서 돈다 · 정규식 자체 검증 스니펫 포함):
//   ⑩ 플래너 파일(`lib/planner.dart`·`lib/src/planner/**`)이 «읽지 않는 필드»(D5 목록 = DTO 의
//      `/// 🔴 ui 미참조(C-38 ⑩)` 표식 + `ReasonChip.detailDeepLink`(D20 · 플래너 한정))를 참조하지 않는다.
//   ⑪ 플래너 파일이 `estimateCosts`·`findPlan`·`previewRebalance` 를 부르지 않는다(D8 호출 표).
//   ⑫ `ui_analytics/lib` 전체(`labels.dart`·주석 포함)에 세율·기대 수치 리터럴과 월 납입 금액 리터럴이
//      없다(C-32 정의에 맞춘 판 · 01 §14-13).
// 🔴 플래너 파일이 아직 없으면(R11a 전) ⑩⑪ 은 통과한다 — 없는 파일로 실패시키지 않는다.
// 🔴 테스트 쪽 산술(⑤⑥ 의 Decimal 합)은 여기(domain_contracts/test)에서만 한다 — 화면은 하지 않는다.
// 🔴 검사마다 **망가뜨린 사본**(메모리 안)으로 실패하는 것을 맨 끝 테스트가 고정한다.

import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_fixture_registry.dart';
import 'c00_support.dart';
import 'support/fixture_accounts.dart';

/// 입력 바닥 — 래퍼 픽스처(6)와 계획을 싣는 픽스처(래퍼 4 + 코어 2).
/// 🔴 검사는 이 목록이 아니라 등록부가 **타입으로 고른 것**을 본다 — 이 목록은 «찾은 것이 줄지 않았는가».
const List<String> _knownWrapperFixtures = <String>[
  FixturePaths.m7M7DepositPlanBlocked,
  FixturePaths.m7M7DepositPlanDefault,
  FixturePaths.m7M7DepositPlanExpired,
  FixturePaths.m7M7DepositPlanFunding,
  FixturePaths.m7M7DepositPlanInputRejected,
  FixturePaths.m7M7DepositPlanLimit,
];
const List<String> _knownCorePlanFixtures = <String>[
  FixturePaths.depositPlan1,
  FixturePaths.depositPlanFunding1,
];

/// ③ 고지 문장의 머리.
const String _previewNoticeHead = '미리보기입니다';

/// ⑩ «읽지 않는 필드» — D5 목록과 **같은 목록**(`plan.dart`·`settings.dart` 의 `ui 미참조(C-38 ⑩)` 표식 +
/// `ReasonChip.detailDeepLink`). `\b` 때문에 `amountText`·`amountInputText`·`quantityText`·`sideLabel`·
/// `totalText`·`depositAmountText`·`limitPriceText`·`residualKrwCashText` 는 걸리지 않는다.
final RegExp _unreadField = RegExp(
  r'\.(expiresAt|computedAt|asOfTradeDate|depositAmount|residualKrwCash|'
  r'pensionLimitConsumed|quantity|limitPrice|side|commission|tax|total|'
  r'expectedProceeds|sourceSleeve|ruleCited|amount|detailDeepLink)\b',
);

/// ⑪ 플래너가 부르지 않는 창구(D8).
final RegExp _forbiddenCall = RegExp(
  r'\b(estimateCosts|findPlan|previewRebalance)\b',
);

/// ⑫ 세율·기대 수치 리터럴(C-32 정의에 맞춘 판 · 설계 Δ4 ⑫).
final RegExp _rateLiteral = RegExp(
  r'(?<![0-9.])(16\.5|0\.165|9\.7|10\.2|10\.63|10\.85|10\.91|10\.96|11\.13|'
  r'12\.5[0-9]|12\.60)(?![0-9])',
);

/// ⑫ 월 납입 금액 리터럴(C-32 · 01:2733 — 100000·90000·97000·124000(+`_` 형)·'10만'·'9.7만' 을 넓힌 판).
final List<RegExp> _amountLiterals = <RegExp>[
  RegExp(r'(?<![0-9])(100|90|97|124)_?000(?![0-9])'),
  RegExp(r'(?<![0-9.])(10|9|9\.7|12\.4)만'),
  RegExp(r'[0-9,]+만\s*원'),
  RegExp(r'[0-9]+억'),
];

/// ⑩ 자체 검증 — 반드시 걸려야 하는 것.
const List<String> _unreadPositives = <String>[
  'final d = plan.expiresAt;',
  'plan.computedAt.isAfter(now)',
  'Text(plan.asOfTradeDate.yyyyMmDd)',
  'final a = plan.depositAmount;',
  'if (plan.residualKrwCash == Decimal.zero) {}',
  'plan.pensionLimitConsumed',
  r"Text('${o.quantity}주')",
  'o.limitPrice!',
  'o.side == OrderSide.buy',
  'plan.costs.commission',
  'plan.costs.tax',
  'plan.costs.total',
  'step.expectedProceeds',
  'step.sourceSleeve',
  'Text(step.ruleCited)',
  'alloc.amount',
  'setting.amount',
  'opener.open(chip.detailDeepLink!)',
];

/// ⑩ 자체 검증 — 통과해야 하는 것(같은 뜻의 표시 필드).
const List<String> _unreadNegatives = <String>[
  'Text(plan.depositAmountText)',
  'Text(o.quantityText)',
  'Text(o.sideLabel)',
  'Text(plan.costs.totalText)',
  'controller.text = setting.amountInputText;',
  'Text(alloc.amountText)',
  'Text(o.limitPriceText ?? o.pendingNoteText!)',
  'Text(limit.taxCreditText)',
  'Text(plan.residualKrwCashText!)',
  'Text(chip.label)',
  'Text(step.label)',
  'Text(plan.asOf.label)',
];

/// ⑫ 자체 검증.
const List<String> _literalPositives = <String>[
  'const int kDefault = 100000;',
  'const int k = 100_000;',
  "static const String a = '9.7만';",
  "static const String b = '월 10만원 납입';",
  "static const String c = '연 10.2% 안팎';",
  '// 세율 16.5% 를 가정',
  "static const String d = '1억 원';",
  "static const String e = '2,000만 원';",
  'final r = 0.165;',
  "static const String f = '12.55%';",
];
const List<String> _literalNegatives = <String>[
  'const SizedBox(height: 10)',
  'final int n = 1000000;',
  "static const String v = 'v1.10.2';",
  'final double w = 12.5;',
  'final double x = 110.2;',
  "static const String g = '만원 단위';",
  'final double y = 0.1650;',
];

/// ⑩⑪ 의 대상 — `packages/ui_analytics` 기준 상대 경로.
const String _plannerLib = 'lib/planner.dart';
const String _plannerDir = 'lib/src/planner/';

void main() {
  group('C-38 플래너 표시 계약 (01 §14 · 계약 v1.4)', () {
    test('C-38 대상 — 래퍼·계획 픽스처와 갈래 표본을 빠짐없이 찾았다', () {
      final List<_WrapperRow> wrappers = _wrapperRows();
      final List<_PlanRow> plans = _planRows();
      expect(
        <String>{for (final _WrapperRow r in wrappers) r.path},
        containsAll(_knownWrapperFixtures),
        reason: '래퍼 픽스처가 검사 입력에서 빠졌다 — 입력 없는 검사는 늘 통과한다.',
      );
      expect(
        <String>{for (final _PlanRow r in plans) r.path},
        containsAll(<String>[
          ..._knownCorePlanFixtures,
          FixturePaths.m7M7DepositPlanDefault,
          FixturePaths.m7M7DepositPlanLimit,
          FixturePaths.m7M7DepositPlanExpired,
          FixturePaths.m7M7DepositPlanFunding,
        ]),
      );
      // 갈래 표본 — 없으면 해당 조항이 아무것도 보지 않는다.
      final List<DepositPreviewResult> w = <DepositPreviewResult>[
        for (final _WrapperRow r in wrappers) r.result,
      ];
      expect(w.where((DepositPreviewResult r) => r.plan != null), isNotEmpty);
      expect(
        w.where((DepositPreviewResult r) => r.inputRejectedText != null),
        isNotEmpty,
      );
      expect(
        w.where((DepositPreviewResult r) => r.blockedText != null),
        hasLength(greaterThanOrEqualTo(2)),
        reason: '차단 표본 2(이동 버튼 없음 · 있음).',
      );
      expect(
        w.where((DepositPreviewResult r) => r.blockedAction != null),
        isNotEmpty,
      );
      final List<DepositPlan> p = <DepositPlan>[
        for (final _PlanRow r in plans) r.plan,
      ];
      expect(p.where((DepositPlan x) => x.ordersEmptyText != null), isNotEmpty);
      expect(
        p.where((DepositPlan x) => x.residualKrwCashText == null),
        isNotEmpty,
      );
      expect(
        p.where((DepositPlan x) => x.registerBlockedText != null),
        isNotEmpty,
      );
      expect(
        p.where(
          (DepositPlan x) => (x.fundingSteps ?? <FundingStep>[]).isNotEmpty,
        ),
        isNotEmpty,
      );
      expect(
        p
            .expand((DepositPlan x) => x.orderDrafts)
            .where((OrderDraft o) => o.limitPrice == null),
        isNotEmpty,
        reason: '지정가 없는 초안(«limitPriceText null 행») 표본.',
      );
    });

    test('C-38 ① 래퍼는 plan·입력 거부·차단 가운데 정확히 하나다', () {
      final List<String> bad = <String>[
        for (final _WrapperRow r in _wrapperRows())
          ..._wrapperViolations(r.where, r.result),
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('C-38 ② 글자가 비지 않고 null 짝(잔여·빈 초안·지정가)이 맞다', () {
      _expectCleanPlans(_textViolations);
    });

    test('C-38 ③ DepositPlan 의 preview_notice 는 «미리보기입니다…» 한 문장이다', () {
      final List<String> bad = _noticeViolations(<(String, DepositPlan)>[
        for (final _PlanRow r in _planRows()) (r.where, r.plan),
      ]);
      expect(bad, isEmpty, reason: bad.join('\n'));
    });

    test('C-38 ④ 조달 단계는 null 이거나 1부터 연속이고 매각 대금이 0 보다 크다', () {
      _expectCleanPlans(_fundingViolations);
    });

    test('C-38 ⑤ 충당액 합 + 잔여 == 입금액', () {
      _expectCleanPlans(_sumViolations);
    });

    test('C-38 ⑥ 슬리브별 매수 초안 합 ≤ 그 슬리브 충당액', () {
      _expectCleanPlans(_buyWithinAllocationViolations);
    });

    test('C-38 ⑦ 슬리브 B 는 연금 계좌 · 모든 별칭은 픽스처 별칭 표 안', () {
      _expectCleanPlans(_accountViolations);
    });

    test('C-38 ⑧ 사유 칩 코드는 계약 코드 사전에 있다', () {
      _expectCleanPlans(_reasonCodeViolations);
    });

    test('C-38 ⑨ 입금 등록 접수증 픽스처는 전 행 DEPOSIT_REGISTER 다', () {
      final List<CommandReceipt> rows = _receipts(
        FixturePaths.m7M7DepositRegisterReceipts4,
      );
      expect(_receiptViolations('receipts', rows), isEmpty);
      // 입력 확인 — 행 순서가 뜻인 네 상태(요청 → 기록 / 만료 / 무결성 보류).
      expect(rows.map((CommandReceipt r) => r.state).toSet(), <CommandState>{
        CommandState.requested,
        CommandState.executed,
        CommandState.expired,
        CommandState.heldForIntegrity,
      });
    });

    test('C-38 ⑩ 플래너 파일이 «읽지 않는 필드»를 참조하지 않는다', () {
      for (final String s in _unreadPositives) {
        expect(_unreadField.hasMatch(s), isTrue, reason: '양성 스니펫을 못 잡았다: $s');
      }
      for (final String s in _unreadNegatives) {
        expect(_unreadField.hasMatch(s), isFalse, reason: '음성 스니펫을 잘못 잡았다: $s');
      }
      expect(_isPlannerTarget(_plannerLib), isTrue);
      expect(_isPlannerTarget('lib/src/planner/deposit_step_two.dart'), isTrue);
      expect(
        _isPlannerTarget('lib/src/screens/monthly_report_screen.dart'),
        isFalse,
      );
      expect(_isPlannerTarget('lib/ui_analytics.dart'), isFalse);
      // 스캔 함수 자체 검증 — 주석 속 언급은 통과, 문자열 보간 안의 참조는 걸린다.
      expect(
        _scan(<String, String>{
          'a.dart': '// plan.expiresAt 를 시계와 비교하지 않는다\nText(plan.depositAmountText);\n',
          'b.dart':
              r"Text('${o.quantity}');"
              '\n',
        }, _unreadField),
        <String>['b.dart'],
      );
      // 🔴 대상 파일이 아직 없으면(R11a 전) 통과한다.
      expect(
        _scan(_plannerSources(), _unreadField),
        isEmpty,
        reason:
            '플래너는 엔진이 만든 `*Text`·`*Label` 만 그린다 — 원값(금액·수량·지정가·시각·비용 내역)과 '
            '사유 칩의 핸드북 링크는 읽지 않는다(01 §14-4 · D5 · D20).',
      );
    });

    test(
      'C-38 ⑪ 플래너 파일이 estimateCosts·findPlan·previewRebalance 를 부르지 않는다',
      () {
        for (final String s in <String>[
          'await api.estimateCosts(drafts)',
          'final p = await api.findPlan(id);',
          'api.previewRebalance()',
        ]) {
          expect(_forbiddenCall.hasMatch(s), isTrue, reason: '양성 스니펫: $s');
        }
        for (final String s in <String>[
          'await api.simulateDeposit(amountInput: text)',
          'final plans = findPlanner;',
        ]) {
          expect(_forbiddenCall.hasMatch(s), isFalse, reason: '음성 스니펫: $s');
        }
        expect(
          _scan(_plannerSources(), _forbiddenCall),
          isEmpty,
          reason:
              '플래너는 `simulateDeposit` 과 `registerDeposit` 만 부른다(01 §14-8 호출 표 · D8) — 비용·계획 '
              '조회·리밸런스 미리보기는 부르지 않는다.',
        );
      },
    );

    test('C-38 ⑫ ui_analytics/lib 에 세율·기대 수치·월 납입 금액 리터럴이 없다', () {
      final List<RegExp> all = <RegExp>[_rateLiteral, ..._amountLiterals];
      for (final String s in _literalPositives) {
        expect(
          all.any((RegExp r) => r.hasMatch(s)),
          isTrue,
          reason: '양성 스니펫을 못 잡았다: $s',
        );
      }
      for (final String s in _literalNegatives) {
        expect(
          all.where((RegExp r) => r.hasMatch(s)),
          isEmpty,
          reason: '음성 스니펫을 잘못 잡았다: $s',
        );
      }
      final Directory lib = Directory(
        '${repoRoot.path}/packages/ui_analytics/lib',
      );
      final List<File> files = dartSourcesIn(lib);
      expect(files, isNotEmpty, reason: 'ui_analytics/lib 를 못 읽었다 — 경로가 낡았다.');
      expect(
        files.map(shortPath),
        contains(endsWith('lib/l10n/labels.dart')),
        reason: '🔴 labels.dart 도 대상이다(01 §14-13 · C-32 ui 면).',
      );
      final List<String> hits = <String>[
        for (final File f in files)
          ..._literalHits(shortPath(f), f.readAsStringSync(), all),
      ];
      expect(
        hits,
        isEmpty,
        reason:
            '세율·정직 기대·월 납입 금액은 엔진이 문장으로 준다 — 화면(labels.dart·주석 포함)에 숫자로 '
            '적지 않는다(01 §2-6 · §14-13 · C-32).\n${hits.join('\n')}',
      );
    });

    test('C-38 자체 검증 — 망가뜨린 사본은 검사에 걸린다', () {
      final _WrapperRow blocked = _wrapperRow(
        FixturePaths.m7M7DepositPlanBlocked,
      );
      final _WrapperRow rejected = _wrapperRow(
        FixturePaths.m7M7DepositPlanInputRejected,
      );
      final _WrapperRow def = _wrapperRow(FixturePaths.m7M7DepositPlanDefault);
      final _PlanRow dp = _planRow(FixturePaths.m7M7DepositPlanDefault);
      final _PlanRow limit = _planRow(FixturePaths.m7M7DepositPlanLimit);
      final _PlanRow funding = _planRow(FixturePaths.m7M7DepositPlanFunding);
      final _PlanRow core = _planRow(FixturePaths.depositPlan1);

      // ① 래퍼.
      final List<
        (String, String, _WrapperRow, void Function(Map<String, Object?>))
      >
      wrapperCases =
          <(String, String, _WrapperRow, void Function(Map<String, Object?>))>[
            (
              '① 둘이 함께 non-null',
              '정확히 하나',
              rejected,
              (Map<String, Object?> j) {
                j['blocked_text'] = '미리보기를 계산하지 않습니다.';
              },
            ),
            (
              '① 셋 다 null',
              '정확히 하나',
              rejected,
              (Map<String, Object?> j) {
                j.remove('input_rejected_text');
              },
            ),
            (
              '① 차단 없이 이동 버튼',
              'blocked_action',
              def,
              (Map<String, Object?> j) {
                j['blocked_action'] = <String, Object?>{
                  'label': '재개 리포트 보기',
                  'deep_link': 'aaq://x2/resume-report',
                };
              },
            ),
          ];
      for (final (
            String name,
            String hit,
            _WrapperRow row,
            void Function(Map<String, Object?>) edit,
          )
          in wrapperCases) {
        expect(
          _wrapperViolations(row.where, row.result),
          isEmpty,
          reason: name,
        );
        expect(
          _wrapperViolations(row.where, row.mutated(edit)),
          contains(contains(hit)),
          reason: '$name — 망가뜨렸는데 검사가 통과한다.',
        );
      }
      expect(_wrapperViolations(blocked.where, blocked.result), isEmpty);

      final List<_Mutation> mutations = <_Mutation>[
        // ②
        _Mutation('② 빈 초안 글자', 'quantity_text', _textViolations, dp, (
          Map<String, Object?> j,
        ) {
          _objs(j, 'order_drafts')[0]['quantity_text'] = ' ';
        }),
        _Mutation('② 빈 경고 줄', 'warning_lines[0]', _textViolations, limit, (
          Map<String, Object?> j,
        ) {
          (j['warning_lines']! as List<Object?>)[0] = '';
        }),
        _Mutation(
          '② 잔여가 있는데 잔여 글자 없음',
          'residual_krw_cash_text',
          _textViolations,
          dp,
          (Map<String, Object?> j) {
            j.remove('residual_krw_cash_text');
          },
        ),
        _Mutation(
          '② 잔여 0 인데 잔여 글자',
          'residual_krw_cash_text',
          _textViolations,
          funding,
          (Map<String, Object?> j) {
            j['residual_krw_cash_text'] = '원화 현금으로 대기합니다.';
          },
        ),
        _Mutation(
          '② 초안이 있는데 빈 초안 문장',
          'orders_empty_text',
          _textViolations,
          dp,
          (Map<String, Object?> j) {
            j['orders_empty_text'] = '주문 초안이 없습니다.';
          },
        ),
        _Mutation(
          '② 초안이 없는데 빈 초안 문장 없음',
          'orders_empty_text',
          _textViolations,
          limit,
          (Map<String, Object?> j) {
            j.remove('orders_empty_text');
          },
        ),
        _Mutation(
          '② 지정가 글자만 있다',
          'limit_price_text',
          _textViolations,
          funding,
          (Map<String, Object?> j) {
            _objs(j, 'order_drafts')[3]['limit_price_text'] = '10,250원';
          },
        ),
        _Mutation('② 지정가만 있고 글자 없음', 'limit_price_text', _textViolations, dp, (
          Map<String, Object?> j,
        ) {
          _objs(j, 'order_drafts')[1].remove('limit_price_text');
        }),
        // ④
        _Mutation('④ 조달 단계 빈 목록', '빈 목록', _fundingViolations, funding, (
          Map<String, Object?> j,
        ) {
          j['funding_steps'] = <Object?>[];
        }),
        _Mutation('④ 조달 순서가 2부터', 'order', _fundingViolations, funding, (
          Map<String, Object?> j,
        ) {
          _objs(j, 'funding_steps')[0]['order'] = 2;
        }),
        _Mutation('④ 0원 조달', 'expected_proceeds', _fundingViolations, funding, (
          Map<String, Object?> j,
        ) {
          _objs(j, 'funding_steps')[0]['expected_proceeds'] = '0';
        }),
        // ⑤
        _Mutation('⑤ 충당 합이 모자란다', '≠ 입금액', _sumViolations, dp, (
          Map<String, Object?> j,
        ) {
          _objs(j, 'allocations')[2]['amount'] = '31000';
        }),
        // ⑥
        _Mutation(
          '⑥ 매수 초안이 충당을 넘는다',
          '슬리브 B',
          _buyWithinAllocationViolations,
          dp,
          (Map<String, Object?> j) {
            _objs(j, 'order_drafts')[1]['quantity'] = 3;
          },
        ),
        _Mutation(
          '⑥ 충당 없는 슬리브의 매수 초안',
          '슬리브 B',
          _buyWithinAllocationViolations,
          limit,
          (Map<String, Object?> j) {
            (j['order_drafts']! as List<Object?>).add(
              _deepCopy(_objs(dp.json, 'order_drafts')[1]),
            );
            j.remove('orders_empty_text');
          },
        ),
        // ⑦
        _Mutation('⑦ 슬리브 B 가 일반 계좌', '슬리브 B', _accountViolations, dp, (
          Map<String, Object?> j,
        ) {
          _objs(j, 'allocations')[1]['account_alias'] = '일반';
        }),
        _Mutation('⑦ 표 밖 별칭', '표 밖', _accountViolations, core, (
          Map<String, Object?> j,
        ) {
          _objs(j, 'order_drafts')[3]['account_alias'] = 'ISA';
        }),
        // ⑧
        _Mutation('⑧ 사전 밖 사유 코드', 'MADE_UP', _reasonCodeViolations, dp, (
          Map<String, Object?> j,
        ) {
          _objs(_objs(j, 'order_drafts')[0], 'reasons')[0]['code'] = 'MADE_UP';
        }),
      ];
      final Set<String> covered = <String>{'①'};
      for (final _Mutation m in mutations) {
        expect(
          m.rule(m.row.where, m.row.plan),
          isEmpty,
          reason: '${m.name} — 고치기 전 원본이 이미 걸린다(변이 확인이 뜻을 잃는다).',
        );
        expect(
          m.rule(m.row.where, m.row.mutated(m.edit)),
          contains(contains(m.hit)),
          reason: '${m.name} — 망가뜨렸는데 검사가 통과한다(검사가 늘 참이다).',
        );
        covered.add(m.name.split(' ').first);
      }

      // ③ — 계획 여럿에 걸친 규칙.
      final List<(String, DepositPlan)> notices = <(String, DepositPlan)>[
        for (final _PlanRow r in _planRows()) (r.where, r.plan),
      ];
      expect(_noticeViolations(notices), isEmpty);
      expect(
        _noticeViolations(<(String, DepositPlan)>[
          ...notices,
          (
            'mut',
            dp.mutated((Map<String, Object?> j) {
              j['preview_notice'] = '미리보기입니다. 잔여 현금 6천원은 대기합니다.';
            }),
          ),
        ]),
        contains(contains('같은 문자열')),
      );
      expect(
        _noticeViolations(<(String, DepositPlan)>[
          (
            'mut',
            dp.mutated((Map<String, Object?> j) {
              j['preview_notice'] = '계획이 만료되었습니다.';
            }),
          ),
        ]),
        contains(contains(_previewNoticeHead)),
      );
      covered.add('③');

      // ⑨ — 접수증.
      final List<CommandReceipt> receipts = _receipts(
        FixturePaths.m7M7DepositRegisterReceipts4,
      );
      expect(
        _receiptViolations('mut', <CommandReceipt>[
          ...receipts,
          receipts.first.copyWith(kind: CommandKind.alertAck),
        ]),
        contains(contains('DEPOSIT_REGISTER')),
      );
      covered.add('⑨');

      // ⑫ — 리터럴 스캔 함수.
      expect(
        _literalHits(
          'labels.dart',
          "static const String x = '월 10만원';\n",
          <RegExp>[_rateLiteral, ..._amountLiterals],
        ),
        isNotEmpty,
      );

      expect(covered, <String>{'①', '②', '③', '④', '⑤', '⑥', '⑦', '⑧', '⑨'});
    });
  });
}

// ─── 대상 고르기 ───────────────────────────────────────────────────────────────

/// 래퍼 1행.
class _WrapperRow {
  const _WrapperRow(this.path, this.index, this.json);

  final String path;
  final int index;
  final Map<String, Object?> json;

  String get where => '$path rows[$index]';

  DepositPreviewResult get result => DepositPreviewResult.fromJson(json);

  DepositPreviewResult mutated(void Function(Map<String, Object?> json) edit) {
    final Map<String, Object?> copy = _deepCopy(json);
    edit(copy);
    return DepositPreviewResult.fromJson(copy);
  }
}

/// 계획 1건(래퍼의 `plan` 또는 코어 `DepositPlan` 행).
class _PlanRow {
  const _PlanRow(this.path, this.index, this.json, {required this.wrapped});

  final String path;
  final int index;

  /// 계획 원문(래퍼면 `plan` 객체). 🔴 고치지 않는다.
  final Map<String, Object?> json;
  final bool wrapped;

  String get where =>
      wrapped ? '$path rows[$index].plan' : '$path rows[$index]';

  DepositPlan get plan => DepositPlan.fromJson(json);

  DepositPlan mutated(void Function(Map<String, Object?> json) edit) {
    final Map<String, Object?> copy = _deepCopy(json);
    edit(copy);
    return DepositPlan.fromJson(copy);
  }
}

List<String> _pathsOfType(String typeName) => <String>[
  for (final MapEntry<String, FixtureBinding> e in fixtureBindings.entries)
    if (e.value.rows.typeName == typeName) e.key,
]..sort();

List<_WrapperRow> _wrapperRows() => <_WrapperRow>[
  for (final String path in _pathsOfType('DepositPreviewResult'))
    for (final (int i, Map<String, Object?> row) in decodeEnvelope(
      readFixture(path),
    ).rows.indexed)
      _WrapperRow(path, i, row),
];

List<_PlanRow> _planRows() => <_PlanRow>[
  for (final _WrapperRow w in _wrapperRows())
    if (w.json['plan'] case final Map<String, Object?> plan)
      _PlanRow(w.path, w.index, plan, wrapped: true),
  for (final String path in _pathsOfType('DepositPlan'))
    for (final (int i, Map<String, Object?> row) in decodeEnvelope(
      readFixture(path),
    ).rows.indexed)
      _PlanRow(path, i, row, wrapped: false),
];

_WrapperRow _wrapperRow(String path) =>
    _wrapperRows().firstWhere((_WrapperRow r) => r.path == path);

_PlanRow _planRow(String path) =>
    _planRows().firstWhere((_PlanRow r) => r.path == path);

List<CommandReceipt> _receipts(String path) =>
    decodeEnvelope(readFixture(path)).rows
        .map(CommandReceipt.fromJson)
        .toList(growable: false);

Map<String, Object?> _deepCopy(Map<String, Object?> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, Object?>;

List<Map<String, Object?>> _objs(Map<String, Object?> json, String key) =>
    (json[key]! as List<Object?>).cast<Map<String, Object?>>();

// ─── 규칙 ─────────────────────────────────────────────────────────────────────

typedef _PlanRule = List<String> Function(String where, DepositPlan p);

class _Mutation {
  const _Mutation(this.name, this.hit, this.rule, this.row, this.edit);

  final String name;

  /// 걸려야 하는 조항의 글자(엉뚱한 조항에 걸려 통과하는 것을 막는다).
  final String hit;
  final _PlanRule rule;
  final _PlanRow row;
  final void Function(Map<String, Object?> json) edit;
}

void _expectCleanPlans(_PlanRule rule) {
  final List<_PlanRow> rows = _planRows();
  expect(rows, hasLength(greaterThanOrEqualTo(6)));
  final List<String> bad = <String>[
    for (final _PlanRow r in rows) ...rule(r.where, r.plan),
  ];
  expect(bad, isEmpty, reason: bad.join('\n'));
}

/// ① 래퍼.
List<String> _wrapperViolations(String where, DepositPreviewResult r) {
  final List<String> bad = <String>[];
  final int n = <Object?>[
    r.plan,
    r.inputRejectedText,
    r.blockedText,
  ].where((Object? x) => x != null).length;
  if (n != 1) {
    bad.add(
      '$where — plan·input_rejected_text·blocked_text 가 $n개 non-null(정확히 하나여야 한다)',
    );
  }
  if (r.blockedAction != null && r.blockedText == null) {
    bad.add('$where — blocked_text 없이 blocked_action 이 있다');
  }
  for (final (String key, String? text) in <(String, String?)>[
    ('input_rejected_text', r.inputRejectedText),
    ('blocked_text', r.blockedText),
    ('blocked_action.label', r.blockedAction?.label),
  ]) {
    if (text != null && text.trim().isEmpty) {
      bad.add('$where — $key 가 빈 글자다');
    }
  }
  return bad;
}

/// ② 글자 · null 짝.
List<String> _textViolations(String where, DepositPlan p) {
  final List<String> bad = <String>[];
  walkJson(jsonDecode(jsonEncode(p.toJson())), (
    String jsonPath,
    String key,
    Object? value,
  ) {
    final bool textKey =
        key == 'label' ||
        key.endsWith('_label') ||
        key.endsWith('_text') ||
        key == 'order_drafts_title' ||
        key == 'preview_notice' ||
        key == 'basis_note';
    if (textKey && value is String && value.trim().isEmpty) {
      bad.add('$where $jsonPath — 빈 글자다');
    }
  });
  for (int i = 0; i < p.warningLines.length; i++) {
    if (p.warningLines[i].trim().isEmpty) {
      bad.add('$where warning_lines[$i] — 빈 글자다');
    }
  }
  final bool zeroResidual = p.residualKrwCash == Decimal.zero;
  if ((p.residualKrwCashText == null) != zeroResidual) {
    bad.add(
      '$where — residual_krw_cash ${p.residualKrwCash} · residual_krw_cash_text '
      '${p.residualKrwCashText == null ? '없음' : '있음'}(null ⇔ 잔여 0)',
    );
  }
  if ((p.ordersEmptyText != null) != p.orderDrafts.isEmpty) {
    bad.add(
      '$where — order_drafts ${p.orderDrafts.length}건 · orders_empty_text '
      '${p.ordersEmptyText == null ? '없음' : '있음'}(non-null ⇔ 빈 목록)',
    );
  }
  for (int i = 0; i < p.orderDrafts.length; i++) {
    final OrderDraft o = p.orderDrafts[i];
    if ((o.limitPriceText == null) != (o.limitPrice == null)) {
      bad.add(
        '$where order_drafts[$i] — limit_price ${o.limitPrice} · limit_price_text '
        '${o.limitPriceText}(둘은 함께 비거나 함께 온다)',
      );
    }
  }
  return bad;
}

/// ③ 고지 전용 · 같은 문자열(계획 여럿에 걸친다).
List<String> _noticeViolations(List<(String, DepositPlan)> plans) {
  final List<String> bad = <String>[];
  final Set<String> distinct = <String>{};
  for (final (String where, DepositPlan p) in plans) {
    distinct.add(p.previewNotice);
    if (!p.previewNotice.startsWith(_previewNoticeHead)) {
      bad.add(
        '$where — preview_notice 가 «$_previewNoticeHead»로 시작하지 않는다: ${p.previewNotice}',
      );
    }
  }
  if (distinct.length > 1) {
    bad.add('preview_notice 가 같은 문자열이 아니다(고지 전용 — 경고·만료를 싣지 않는다): $distinct');
  }
  return bad;
}

/// ④ 조달 단계.
List<String> _fundingViolations(String where, DepositPlan p) {
  final List<FundingStep>? steps = p.fundingSteps;
  if (steps == null) {
    return const <String>[];
  }
  if (steps.isEmpty) {
    return <String>['$where — funding_steps 가 빈 목록이다(null 이거나 비지 않아야 한다)'];
  }
  final List<String> bad = <String>[];
  for (int i = 0; i < steps.length; i++) {
    if (steps[i].order != i + 1) {
      bad.add(
        '$where funding_steps[$i] — order ${steps[i].order} ≠ ${i + 1}(1부터 연속)',
      );
    }
    if (steps[i].expectedProceeds <= Decimal.zero) {
      bad.add(
        '$where funding_steps[$i] — expected_proceeds ${steps[i].expectedProceeds} ≤ 0(0원 단계 금지)',
      );
    }
  }
  return bad;
}

/// ⑤ 충당 합 + 잔여 == 입금액.
List<String> _sumViolations(String where, DepositPlan p) {
  final Decimal sum = p.allocations.fold(
    p.residualKrwCash,
    (Decimal acc, SleeveAllocation a) => acc + a.amount,
  );
  return <String>[
    if (sum != p.depositAmount)
      '$where — 충당 합 + 잔여 $sum ≠ 입금액 ${p.depositAmount}',
  ];
}

/// ⑥ 슬리브별 매수 초안 합 ≤ 충당액.
List<String> _buyWithinAllocationViolations(String where, DepositPlan p) {
  final List<String> bad = <String>[];
  final Map<SleeveId, Decimal> buys = <SleeveId, Decimal>{};
  for (int i = 0; i < p.orderDrafts.length; i++) {
    final OrderDraft o = p.orderDrafts[i];
    if (o.side != OrderSide.buy) {
      continue;
    }
    if (o.limitPrice == null) {
      bad.add(
        '$where order_drafts[$i] — 매수 초안에 지정가가 없다(슬리브 ${o.sleeve.wire} 합을 볼 수 없다)',
      );
      continue;
    }
    buys[o.sleeve] =
        (buys[o.sleeve] ?? Decimal.zero) +
        o.limitPrice! * Decimal.fromInt(o.quantity);
  }
  for (final MapEntry<SleeveId, Decimal> e in buys.entries) {
    final Decimal allocated = p.allocations
        .where((SleeveAllocation a) => a.sleeve == e.key)
        .fold(
          Decimal.zero,
          (Decimal acc, SleeveAllocation a) => acc + a.amount,
        );
    if (e.value > allocated) {
      bad.add('$where — 슬리브 ${e.key.wire} 매수 초안 합 ${e.value} > 충당액 $allocated');
    }
  }
  return bad;
}

/// ⑦ 계좌 별칭.
List<String> _accountViolations(String where, DepositPlan p) {
  final List<String> bad = <String>[];
  final List<(String, SleeveId, String?)> aliases =
      <(String, SleeveId, String?)>[
        for (final (int i, SleeveAllocation a) in p.allocations.indexed)
          ('allocations[$i]', a.sleeve, a.accountAlias),
        for (final (int i, OrderDraft o) in p.orderDrafts.indexed)
          ('order_drafts[$i]', o.sleeve, o.accountAlias),
      ];
  for (final (String at, SleeveId sleeve, String? alias) in aliases) {
    if (sleeve == SleeveId.b &&
        !kFixturePensionAccountAliases.contains(alias)) {
      bad.add('$where $at — 슬리브 B 가 연금 계좌가 아니다: $alias(SPEC v2.23 가드)');
    }
    if (alias != null && !kFixtureAccountAliases.contains(alias)) {
      bad.add(
        '$where $at — 픽스처 별칭 표 밖 별칭: $alias(fixtures/README.md «픽스처 계좌 별칭 표»)',
      );
    }
  }
  return bad;
}

/// ⑧ 사유 칩 코드.
List<String> _reasonCodeViolations(String where, DepositPlan p) => <String>[
  for (final (int i, OrderDraft o) in p.orderDrafts.indexed)
    for (final ReasonChip c in o.reasons)
      if (!ContractCodes.isRegistered(c.code))
        '$where order_drafts[$i] — 사유 코드 ${c.code} 가 ContractCodes 에 없다',
];

/// ⑨ 접수증.
List<String> _receiptViolations(String where, List<CommandReceipt> rows) =>
    <String>[
      if (rows.isEmpty) '$where — 행이 없다',
      for (final (int i, CommandReceipt r) in rows.indexed)
        if (r.kind != CommandKind.depositRegister)
          '$where rows[$i] — kind ${r.kind.wire} ≠ DEPOSIT_REGISTER',
    ];

// ─── ui 스캔 ──────────────────────────────────────────────────────────────────

bool _isPlannerTarget(String rel) =>
    rel == _plannerLib || rel.startsWith(_plannerDir);

/// 플래너 파일(`packages/ui_analytics` 기준) — 없으면 빈 지도.
Map<String, String> _plannerSources() {
  final Directory root = Directory('${repoRoot.path}/packages/ui_analytics');
  final String base = root.path.replaceAll(r'\', '/');
  return <String, String>{
    for (final File f in dartSourcesIn(Directory('${root.path}/lib')))
      if (_isPlannerTarget(
        f.path.replaceAll(r'\', '/').substring(base.length + 1),
      ))
        shortPath(f): f.readAsStringSync(),
  };
}

/// 주석을 지운 소스에서 [re] 가 걸린 파일 이름.
///
/// 🔴 문자열은 남긴다 — `'${o.quantity}'` 같은 보간 안의 참조가 가장 흔한 위반 꼴이다.
List<String> _scan(Map<String, String> sources, RegExp re) => <String>[
  for (final MapEntry<String, String> e in sources.entries)
    if (re.hasMatch(stripComments(e.value))) e.key,
];

/// ⑫ 원문(주석 포함) 한 줄씩 — `파일:줄: 글자`.
List<String> _literalHits(String name, String source, List<RegExp> res) {
  final List<String> out = <String>[];
  final List<String> lines = source.split('\n');
  for (int i = 0; i < lines.length; i++) {
    if (res.any((RegExp r) => r.hasMatch(lines[i]))) {
      out.add('$name:${i + 1}: ${lines[i].trim()}');
    }
  }
  return out;
}
