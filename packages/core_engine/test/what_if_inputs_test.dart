// E7a2-1 — What-if 앞단(06 M3-1 ⓐⓑ · v1.6 ⓐ · 설계 13 §8 R18 D-2 · D-3 · D-6 · D-10).
//
// 🔵 글자는 계약 픽스처(`domain_contracts/fixtures/m7/`)의 실제 글자와 맞댄다 — 엔진이 만든 꼴이 화면이 받을 꼴이다.
// 🔵 차단·거부 결과는 E7a0 판정 함수(C-38 ① · C-41 ①)에 건다 — 정확히 한 갈래인가.

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

Future<List<Map<String, Object?>>> _rows(String name) async {
  final Uri lib = (await Isolate.resolvePackageUri(
    Uri.parse('package:domain_contracts/domain_contracts.dart'),
  ))!;
  final File f = File.fromUri(lib.resolve('../fixtures/m7/$name.json'));
  return ((jsonDecode(f.readAsStringSync()) as Map<String, Object?>)['rows']!
          as List<Object?>)
      .cast<Map<String, Object?>>();
}

Decimal _d(String s) => Decimal.parse(s);

BlockFlag _flag(String id, {String? link}) =>
    BlockFlag.fromJson(<String, Object?>{
      'flag_id': id,
      'label': '$id 플래그',
      'set_at': '2026-08-28T01:00:00Z',
      'clear_route': 'WIZARD_ONLY',
      'clear_instruction': '해소 안내',
      'clear_deep_link': link,
    });

WhatIfState _state({
  List<BlockFlag> flags = const <BlockFlag>[],
  bool recovery = false,
  String? pension = '연금저축',
}) => WhatIfState(
  asOfTradeDate: const TradeDate('2026-08-31'),
  configHash: 'cfg_test',
  activeFlags: flags,
  recovery: recovery,
  accounts: WhatIfAccounts(pensionAlias: pension, generalAlias: '일반'),
  pensionUsedThisYear: Decimal.zero,
  observedAt: DateTime.utc(2026, 8, 31, 9),
  source: AsOfSource.localSqlite,
  sleeveValues: <SleeveId, Decimal>{
    SleeveId.a: Decimal.zero,
    SleeveId.b: Decimal.zero,
    SleeveId.c: Decimal.zero,
  },
  prices: const <String, Decimal>{},
);

void main() {
  final WhatIfConfig cfg = WhatIfConfig.defaults;

  group('글자 — 계약 픽스처의 꼴 그대로(D-6)', () {
    test('금액 만·천 꼴 · 천 단위가 아니면 쉼표 · 억', () {
      final Map<String, String> v = <String, String>{
        '100000': '10만원',
        '42000': '4만 2천원',
        '6000': '6천원',
        '18000000': '1,800만원',
        '42350': '4만 2,350원',
        '6350': '6,350원',
        '100': '100원',
        '0': '0원',
        '100000000': '1억원',
        '1000000000': '10억원',
        '123456789': '1억 2,345만 6,789원',
        '100001000': '1억 1천원',
      };
      for (final MapEntry<String, String> kv in v.entries) {
        expect(wonText(_d(kv.key)), kv.value, reason: kv.key);
      }
      expect(commaWonText(_d('19150')), '19,150원');
      expect(commaWonText(_d('128')), '128원');
      expect(sharesText(2), '2주');
      expect(koreanDateText(const TradeDate('2026-09-01')), '2026년 9월 1일');
      expect(daysToYearEnd(const TradeDate('2026-08-31')), 122);
      expect(daysToYearEnd(const TradeDate('2026-12-31')), 0);
      expect(() => wonText(_d('-1')), throwsArgumentError);
      expect(() => wonText(_d('100.5')), throwsArgumentError);
      expect(() => sharesText(-1), throwsArgumentError);
      expect(
        () => koreanDateText(const TradeDate('2026-9-1')),
        throwsArgumentError,
      );
    });

    test('입금 계획 픽스처 4벌의 금액·가격·수량·한도·마감 글자를 엔진 함수가 그대로 만든다', () async {
      int checked = 0;
      for (final String n in <String>[
        'm7_deposit_plan_default',
        'm7_deposit_plan_expired',
        'm7_deposit_plan_funding',
        'm7_deposit_plan_limit',
      ]) {
        for (final Map<String, Object?> row in await _rows(n)) {
          final DepositPlan p = DepositPlan.fromJson(
            row['plan']! as Map<String, Object?>,
          );
          expect(p.depositAmountText, wonText(p.depositAmount), reason: n);
          for (final SleeveAllocation a in p.allocations) {
            expect(
              a.amountText,
              wonText(a.amount),
              reason: '$n ${a.sleeve.wire}',
            );
            checked++;
          }
          if (p.residualKrwCashText case final String t) {
            expect(t, startsWith('${wonText(p.residualKrwCash)}은 '), reason: n);
          }
          for (final OrderDraft o in p.orderDrafts) {
            expect(o.quantityText, sharesText(o.quantity), reason: n);
            if (o.limitPrice case final Decimal lp) {
              expect(o.limitPriceText, commaWonText(lp), reason: n);
            }
          }
          if (p.costs.total > Decimal.zero) {
            expect(
              p.costs.totalText,
              '약 ${commaWonText(p.costs.total)}',
              reason: n,
            );
          }
          final PensionLimitVm l = p.pensionLimit!;
          expect(
            l.annualLimitText,
            contains(wonText(cfg.pensionAnnualLimit)),
            reason: n,
          );
          expect(
            l.taxCreditText,
            contains(wonText(cfg.taxCreditBand)),
            reason: n,
          );
          if (p.pensionLimitConsumed < cfg.pensionAnnualLimit) {
            expect(
              l.annualLimitText,
              contains('가운데 ${wonText(p.pensionLimitConsumed)}을'),
              reason: n,
            );
          }
          expect(
            l.deadlineText,
            contains('${daysToYearEnd(p.asOfTradeDate)}일 남았습니다'),
            reason: n,
          );
        }
      }
      expect(checked, greaterThanOrEqualTo(10));
    });

    test('리밸런싱 픽스처 — 회차 날짜 글자 = 날짜 + « 회차» · 다음 회차 예정일 글자', () async {
      final RebalancePreview p = RebalancePreviewResult.fromJson(
        (await _rows('m7_rebalance_preview_default')).single,
      ).preview!;
      expect(p.plannedDateText, '${koreanDateText(p.plannedDate)} 회차');
      final NextRebalanceVm next = NextRebalanceVm.fromJson(
        (await _rows('m7_next_rebalance_countdown')).single,
      );
      expect(next.expectedDateText, koreanDateText(p.plannedDate));
    });
  });

  group('금액 입력 판정(D-2)', () {
    test('받아들이는 글자 — 앞뒤 공백 · ASCII 쉼표(자리 무관) · 앞자리 0', () {
      for (final MapEntry<String, String> kv in <String, String>{
        '100000': '100000',
        ' 100,000 ': '100000',
        '1,0000': '10000',
        '000100': '100',
        '1000000000': '1000000000',
        '1': '1',
      }.entries) {
        final AmountInput a = parseAmountInput(kv.key, cfg);
        expect(a.rejectedText, isNull, reason: '«${kv.key}»');
        expect(a.amount, _d(kv.value), reason: '«${kv.key}»');
      }
    });

    test('거부 — 빈칸 · 숫자 아님 · 0 · 음수 · 범위 밖은 문장 하나', () {
      final Map<String, String> want = <String, String>{
        '': kAmountBlankText,
        '   ': kAmountBlankText,
        '10만': kAmountNotNumberText,
        '100000원': kAmountNotNumberText,
        '1e5': kAmountNotNumberText,
        '１００': kAmountNotNumberText,
        '100000.5': kAmountNotNumberText,
        '+100000': kAmountNotNumberText,
        '100 000': kAmountNotNumberText,
        '--100': kAmountNotNumberText,
        '0': kAmountNotPositiveText,
        '000': kAmountNotPositiveText,
        '0,000': kAmountNotPositiveText,
        '-1000': kAmountNotPositiveText,
        ' -1,000 ': kAmountNotPositiveText,
        '1000000001': '1원부터 10억원까지 입력할 수 있습니다.',
        '99999999999999999999': '1원부터 10억원까지 입력할 수 있습니다.',
      };
      for (final MapEntry<String, String> kv in want.entries) {
        final AmountInput a = parseAmountInput(kv.key, cfg);
        expect(a.amount, isNull, reason: '«${kv.key}»');
        expect(a.rejectedText, kv.value, reason: '«${kv.key}»');
      }
      final WhatIfConfig tight = WhatIfConfig(
        planTtl: cfg.planTtl,
        pensionAnnualLimit: cfg.pensionAnnualLimit,
        taxCreditBand: cfg.taxCreditBand,
        depositMin: _d('10000'),
        depositMax: _d('5000000'),
      );
      expect(
        parseAmountInput('9999', tight).rejectedText,
        '1만원부터 500만원까지 입력할 수 있습니다.',
      );
      expect(parseAmountInput('10000', tight).amount, _d('10000'));
      expect(parseAmountInput('5000001', tight).rejectedText, isNotNull);
    });

    test('숫자 아님 문장은 계약 픽스처 문장과 같다', () async {
      expect(
        DepositPreviewResult.fromJson(
          (await _rows('m7_deposit_plan_input_rejected')).single,
        ).inputRejectedText,
        kAmountNotNumberText,
      );
    });
  });

  group('입금 차단 표(D21 · D-3 · D-10)', () {
    const String repair = 'aaq://x5/repair-wizard';
    const String resume = 'aaq://x2/resume-report';

    test('행마다 정확히 한 갈래 — 무결성 · 복구 · 재개 미완 · 매핑 미완 · 그 밖 플래그는 영향 없음', () {
      final List<(String, WhatIfState, String?, LinkAction?)>
      rows = <(String, WhatIfState, String?, LinkAction?)>[
        ('정상', _state(), null, null),
        (
          '무결성(해소 링크 있음)',
          _state(
            flags: <BlockFlag>[_flag(FlagIds.ledgerIntegrity, link: repair)],
          ),
          DepositGateTexts.integrity,
          const LinkAction(label: '복구 위저드 열기', deepLink: repair),
        ),
        (
          '무결성(링크 없음)',
          _state(flags: <BlockFlag>[_flag(FlagIds.ledgerIntegrity)]),
          DepositGateTexts.integrity,
          null,
        ),
        ('복구 모드', _state(recovery: true), DepositGateTexts.recovery, null),
        (
          '재개 미완',
          _state(
            flags: <BlockFlag>[_flag(FlagIds.resumeIncomplete, link: resume)],
          ),
          DepositGateTexts.resume,
          const LinkAction(label: '재개 리포트 보기', deepLink: resume),
        ),
        ('매핑 미완', _state(pension: null), DepositGateTexts.mapping, null),
        (
          '겹침 — 무결성이 먼저',
          _state(
            flags: <BlockFlag>[
              _flag(FlagIds.resumeIncomplete, link: resume),
              _flag(FlagIds.ledgerIntegrity, link: repair),
            ],
            recovery: true,
            pension: null,
          ),
          DepositGateTexts.integrity,
          const LinkAction(label: '복구 위저드 열기', deepLink: repair),
        ),
        (
          '겹침 — 복구가 재개 미완보다 먼저',
          _state(
            flags: <BlockFlag>[_flag(FlagIds.resumeIncomplete, link: resume)],
            recovery: true,
          ),
          DepositGateTexts.recovery,
          null,
        ),
        (
          '표 밖 플래그',
          _state(
            flags: <BlockFlag>[
              _flag(FlagIds.journalMissing),
              _flag(FlagIds.dstWeek),
            ],
          ),
          null,
          null,
        ),
      ];
      for (final (String name, WhatIfState s, String? text, LinkAction? action)
          in rows) {
        final WhatIfGate g = depositGate(s);
        expect(g.blockedText, text, reason: name);
        expect(g.blockedAction, action, reason: name);
        final DepositPreflight pre = depositPreflight(s, '100,000', cfg);
        if (text == null) {
          expect(pre.stop, isNull, reason: name);
          expect(pre.amount, _d('100000'), reason: name);
        } else {
          expect(depositPreviewResultViolations(name, pre.stop!), isEmpty);
          expect(pre.stop!.blockedText, text, reason: name);
          expect(pre.amount, isNull, reason: name);
        }
      }
    });

    test('차단이 입력 거부보다 먼저(D-3) · 차단이 없으면 거부 문장 한 갈래', () {
      final DepositPreflight blocked = depositPreflight(
        _state(flags: <BlockFlag>[_flag(FlagIds.ledgerIntegrity)]),
        '',
        cfg,
      );
      expect(blocked.stop!.blockedText, DepositGateTexts.integrity);
      expect(blocked.stop!.inputRejectedText, isNull);
      final DepositPreflight rejected = depositPreflight(_state(), '10만', cfg);
      expect(rejected.stop!.inputRejectedText, kAmountNotNumberText);
      expect(depositPreviewResultViolations('거부', rejected.stop!), isEmpty);
    });

    test('등록 불가 — RECON > LEDGER_FIX > 만료 하나 · 차단은 아니다', () {
      final WhatIfState recon = _state(
        flags: <BlockFlag>[_flag(FlagIds.reconMismatch)],
      );
      final WhatIfState fix = _state(
        flags: <BlockFlag>[_flag(FlagIds.ledgerFix)],
      );
      final WhatIfState both = _state(
        flags: <BlockFlag>[
          _flag(FlagIds.ledgerFix),
          _flag(FlagIds.reconMismatch),
        ],
      );
      expect(depositGate(recon).blocked, isFalse);
      expect(
        depositGate(recon).registerBlockedText,
        DepositGateTexts.registerRecon,
      );
      expect(
        depositGate(fix).registerBlockedText,
        DepositGateTexts.registerLedgerFix,
      );
      expect(
        depositGate(both).registerBlockedText,
        DepositGateTexts.registerRecon,
      );
      expect(depositGate(_state()).registerBlockedText, isNull);
      expect(
        depositRegisterBlockedText(_state(), expired: true),
        DepositGateTexts.registerExpired,
      );
      expect(
        depositRegisterBlockedText(fix, expired: true),
        DepositGateTexts.registerLedgerFix,
      );
      expect(depositRegisterBlockedText(_state(), expired: false), isNull);
    });

    test('픽스처에 있는 문장은 글자 그대로 — 차단 2 · 등록 불가 2', () async {
      final List<DepositPreviewResult> b = <DepositPreviewResult>[
        for (final Map<String, Object?> r in await _rows(
          'm7_deposit_plan_blocked',
        ))
          DepositPreviewResult.fromJson(r),
      ];
      expect(b.map((DepositPreviewResult r) => r.blockedText), <String>[
        DepositGateTexts.integrity,
        DepositGateTexts.resume,
      ]);
      expect(
        b[1].blockedAction!.label,
        kGateButtonLabels[FlagIds.resumeIncomplete],
      );
      String reg(String n, List<Map<String, Object?>> rows) =>
          DepositPlan.fromJson(rows.single['plan']! as Map<String, Object?>)
              .registerBlockedText!;
      expect(
        reg('expired', await _rows('m7_deposit_plan_expired')),
        DepositGateTexts.registerExpired,
      );
      expect(
        reg('funding', await _rows('m7_deposit_plan_funding')),
        DepositGateTexts.registerRecon,
      );
    });
  });

  group('리밸런싱 차단 표(H64 · D-10)', () {
    const String repair = 'aaq://x5/repair-wizard';
    const String resume = 'aaq://x2/resume-report';

    test('행마다 정확히 한 갈래 · RECON·LEDGER_FIX 는 차단이 아니라 경고', () {
      final List<
        (String, WhatIfState, bool, String?, LinkAction?, List<String>)
      >
      rows = <(String, WhatIfState, bool, String?, LinkAction?, List<String>)>[
        ('정상', _state(), true, null, null, <String>[]),
        (
          '예정 없음',
          _state(),
          false,
          RebalanceGateTexts.noPlannedDate,
          null,
          <String>[],
        ),
        (
          '무결성',
          _state(
            flags: <BlockFlag>[_flag(FlagIds.ledgerIntegrity, link: repair)],
          ),
          true,
          RebalanceGateTexts.integrity,
          const LinkAction(label: '복구 위저드 열기', deepLink: repair),
          <String>[],
        ),
        (
          '복구 모드',
          _state(recovery: true),
          true,
          RebalanceGateTexts.recovery,
          null,
          <String>[],
        ),
        (
          '재개 미완',
          _state(
            flags: <BlockFlag>[_flag(FlagIds.resumeIncomplete, link: resume)],
          ),
          true,
          RebalanceGateTexts.resume,
          const LinkAction(label: '재개 리포트 보기', deepLink: resume),
          <String>[],
        ),
        (
          '무결성이 예정 없음보다 먼저',
          _state(flags: <BlockFlag>[_flag(FlagIds.ledgerIntegrity)]),
          false,
          RebalanceGateTexts.integrity,
          null,
          <String>[],
        ),
        (
          'RECON + LEDGER_FIX = 경고 두 줄',
          _state(
            flags: <BlockFlag>[
              _flag(FlagIds.reconMismatch),
              _flag(FlagIds.ledgerFix),
            ],
          ),
          true,
          null,
          null,
          <String>[
            RebalanceGateTexts.warnRecon,
            RebalanceGateTexts.warnLedgerFix,
          ],
        ),
        (
          '매핑 미완은 리밸런싱을 막지 않는다',
          _state(pension: null),
          true,
          null,
          null,
          <String>[],
        ),
      ];
      for (final (
            String name,
            WhatIfState s,
            bool planned,
            String? text,
            LinkAction? action,
            List<String> warn,
          )
          in rows) {
        final WhatIfGate g = rebalanceGate(s, hasPlannedDate: planned);
        expect(g.blockedText, text, reason: name);
        expect(g.blockedAction, action, reason: name);
        expect(g.warningLines, warn, reason: name);
        final RebalancePreviewResult? pre = rebalancePreflight(
          s,
          hasPlannedDate: planned,
        );
        if (text == null) {
          expect(pre, isNull, reason: name);
        } else {
          expect(rebalancePreviewResultViolations(name, pre!), isEmpty);
          expect(pre.blockedText, text, reason: name);
        }
      }
    });

    test('픽스처에 있는 문장은 글자 그대로 — 차단 2 · 예정 없음', () async {
      final List<RebalancePreviewResult> b = <RebalancePreviewResult>[
        for (final Map<String, Object?> r in await _rows(
          'm7_rebalance_preview_blocked',
        ))
          RebalancePreviewResult.fromJson(r),
      ];
      expect(b.map((RebalancePreviewResult r) => r.blockedText), <String>[
        RebalanceGateTexts.integrity,
        RebalanceGateTexts.resume,
      ]);
      expect(
        b[1].blockedAction!.label,
        kGateButtonLabels[FlagIds.resumeIncomplete],
      );
      expect(
        NextRebalanceVm.fromJson((await _rows('m7_next_rebalance_none')).single)
            .emptyLabel,
        RebalanceGateTexts.noPlannedDate,
      );
    });
  });
}
