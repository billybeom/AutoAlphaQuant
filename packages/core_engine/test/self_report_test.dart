// E11q-q6 — `L-3` 정기 실사 엔진 몫(앱 계약 01 §21-3 · §21-4 · 02 §3-10 · 표본 `m6/self_report_*`).

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'golden/calendar_fixture.dart';

Map<String, dynamic> _row(String rel) =>
    ((jsonDecode(File('../domain_contracts/fixtures/$rel').readAsStringSync())
                    as Map<String, dynamic>)['rows']
                as List<dynamic>)
            .first
        as Map<String, dynamic>;

List<Map<String, dynamic>> _rows(String rel) => <Map<String, dynamic>>[
  for (final Object? r
      in (jsonDecode(
            File('../domain_contracts/fixtures/$rel').readAsStringSync(),
          ) as Map<String, dynamic>)['rows']
          as List<dynamic>)
    r! as Map<String, dynamic>,
];

const String _dev = '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e';

const CommandContext _ctx = CommandContext(
  runMode: RunMode.live,
  operatingMode: OperatingMode.advisory,
  leaseEpoch: 2,
  deviceId: _dev,
);

const Map<String, String> _accounts = <String, String>{
  'P0S_A': '일반',
  'P0S_B': '연금저축',
  'P0S_C': '일반',
  'P0S_POT': '연금저축',
};

final ExchangeCalendar _kr = frozenCalendar(Market.kr);

List<SymbolOption> _fixtureSymbols() => <SymbolOption>[
  for (final Object? s in _row(FixturePaths.m6SelfReport1)['symbols'] as List)
    SymbolOption.fromJson(s! as Map<String, dynamic>),
];

final SelfReportOpenSession _open = SelfReportOpenSession(
  yyyyMm: '2026-08',
  accountAlias: '연금저축',
  asOf: const TradeDate('2026-08-31'),
  startedAtUtc: DateTime.utc(2026, 8, 31, 9),
);

SelfReportSubmission _sub({
  Map<String, String>? lines,
  String cash = '1,250,000',
  bool complete = true,
  String? alias = '연금저축',
  SelfReportPurpose purpose = SelfReportPurpose.periodicAudit,
}) => SelfReportSubmission(
  purpose: purpose,
  yyyyMm: '2026-08',
  input: SelfReportInput(
    lines: <SelfReportLineInput>[
      for (final MapEntry<String, String> e
          in (lines ??
                  <String, String>{
                    '069500': '0',
                    '133690': '242',
                    '411060': '1,050',
                    '0085P0': ' 12 ',
                  })
              .entries)
        SelfReportLineInput(symbol: e.key, quantityText: e.value),
    ],
    cashKrwText: cash,
    accountAlias: alias,
  ),
  declaredComplete: complete,
);

SelfReportWireResult _wire(SelfReportSubmission s) => selfReportWireOf(
  s,
  session: _open,
  symbols: _fixtureSymbols(),
  context: _ctx,
);

String _invalid(SelfReportWireResult w) => switch (w) {
  SelfReportInputInvalid(:final String stateLabel) => stateLabel,
  SelfReportWireReady() => fail('와이어가 섰다'),
};

StoredLedgerDiff _stored(SelfReportDiffRow d, {DiffStatus? status}) =>
    StoredLedgerDiff(
      diffId: d.diffId,
      pair: LedgerPair.canonSelfReport,
      axis: d.axis,
      authoredDate: const TradeDate('2026-08-31'),
      delta: d.delta,
      deltaLabel: d.deltaLabel,
      severity: d.severity,
      status: status ?? DiffStatus.open,
      detectedAtUtc: DateTime.utc(2026, 8, 31, 3, 10),
      applicable: true,
    );

void main() {
  group('세션 VM = 표본', () {
    test('🔴 열린 세션 = `self_report_1` 그대로(원장 현재값 0 · 기준일 글자만)', () {
      final SelfReportSession vm = selfReportSessionVmOf(
        yyyyMm: '2026-08',
        accountAlias: '연금저축',
        asOf: const TradeDate('2026-08-31'),
        symbols: _fixtureSymbols(),
        closedText: null,
        result: null,
        lastVerifiedOn: const TradeDate('2026-08-31'),
        observedAtUtc: DateTime.utc(2026, 8, 31, 9),
      );
      expect(vm, SelfReportSession.fromJson(_row(FixturePaths.m6SelfReport1)));
    });

    test('🔴 닫힌 세션 = `self_report_session_closed` 그대로', () {
      final SelfReportSession vm = selfReportSessionVmOf(
        yyyyMm: '2026-08',
        accountAlias: '연금저축',
        asOf: const TradeDate('2026-08-31'),
        symbols: _fixtureSymbols(),
        closedText: SelfReportTexts.sessionClosed,
        result: null,
        lastVerifiedOn: const TradeDate('2026-08-31'),
        observedAtUtc: DateTime.utc(2026, 8, 31, 9),
      );
      expect(
        vm,
        SelfReportSession.fromJson(_row('m6/self_report_session_closed.json')),
      );
    });

    test('🔴 결과가 있으면 닫힘 문장을 싣지 않는다(화면은 닫힘을 먼저 본다)', () {
      final SelfReportSession vm = selfReportSessionVmOf(
        yyyyMm: '2026-08',
        accountAlias: '연금저축',
        asOf: const TradeDate('2026-08-31'),
        symbols: _fixtureSymbols(),
        closedText: SelfReportTexts.sessionClosed,
        result: const SelfReportResult(
          diffs: <LedgerDiffRow>[],
          emptyLabel: SelfReportTexts.resultEmpty,
        ),
        lastVerifiedOn: null,
        observedAtUtc: DateTime.utc(2026, 9, 2),
      );
      expect(vm.sessionClosedText, isNull);
      expect(vm.result?.emptyLabel, '실사 결과가 원장과 맞습니다');
      expect(vm.trust.lastVerifiedOn, isNull);
    });

    test('달을 모르면 제목 · 기준일 글자 = 모름(지어내지 않는다)', () {
      final SelfReportSession vm = selfReportSessionVmOf(
        yyyyMm: '2026-8',
        accountAlias: '일반',
        asOf: null,
        symbols: const <SymbolOption>[],
        closedText: SelfReportTexts.closedUnknownMonth,
        result: null,
        lastVerifiedOn: null,
        observedAtUtc: DateTime.utc(2026, 9, 2, 1),
      );
      expect(vm.titleText, '정기 실사');
      expect(vm.asOfTradeDateText, '기준일을 정하지 못했습니다');
      expect(vm.accountLabel, '일반 계좌');
      expect(vm.asOf.tradeDate, const TradeDate('2026-09-02'));
    });
  });

  group('결과 · 차이', () {
    test('🔴 수량 차이 → 저장 행 → 결과 행(표본 글자 · 쌍 · 축 · 심각도 · 후보 · 탐지 · 행 링크 0)', () {
      final List<SelfReportQuantityDiff> diffs = selfReportQuantityDiffsOf(
        ledger: <String, int>{'133690': 245, '411060': 1050},
        reported: const <SelfReportLine>[
          SelfReportLine(symbol: '069500', symbolLabel: 'A', quantity: 0),
          SelfReportLine(symbol: '133690', symbolLabel: 'B', quantity: 242),
          SelfReportLine(symbol: '411060', symbolLabel: 'G', quantity: 1050),
        ],
      );
      expect(diffs, const <SelfReportQuantityDiff>[
        SelfReportQuantityDiff(symbol: '133690', ledger: 245, reported: 242),
      ]);
      final List<SelfReportDiffRow> rows = selfReportDiffRowsOf(
        asOf: const TradeDate('2026-08-31'),
        alias: '연금저축',
        diffs: diffs,
      );
      final SelfReportResult r = selfReportResultOf(
        diffs: <StoredLedgerDiff>[_stored(rows.single)],
        yyyyMm: '2026-08',
        nextAlias: '일반',
        resolveRegistered: true,
        cashSkipped: null,
      );
      final Map<String, dynamic> fx =
          _row(FixturePaths.m6SelfReportDiffResult)['result']
              as Map<String, dynamic>;
      final Map<String, dynamic> d0 =
          (fx['diffs'] as List<dynamic>).single as Map<String, dynamic>;
      final LedgerDiffRow row = r.diffs.single;
      expect(row.deltaLabel, d0['delta_label']);
      expect(row.pair.wire, d0['pair']);
      expect(row.axis.wire, d0['axis']);
      expect(row.severity.wire, d0['severity']);
      expect(row.candidateOriginCodes, d0['candidate_origin_codes']);
      expect(row.status.wire, d0['status']);
      expect(row.pairLabel, d0['pair_label']);
      expect(row.axisLabel, d0['axis_label']);
      expect(row.severityLabel, d0['severity_label']);
      expect(row.statusLabel, d0['status_label']);
      expect(row.detectedAtText, d0['detected_at_text']);
      expect(row.authoredDate.yyyyMmDd, d0['authored_date']);
      expect(row.actionLink, isNull);
      expect(row.applicable, isTrue);
      // 🔵 경로 = L-1 과 같은 엔진 규칙(관측 = 자동 · R59 S4) — 같은 차이가 두 화면에서 같게 읽힌다.
      expect(row.route, RepairRoute.auto);
      // 🆕 R280(01 §8 미결 226 ⓗ · K320) — 옛 표본 `APPROVAL` «승인 필요» 정정 → 표본 = 엔진 경로 · 글자 «다시 실사로 해소».
      expect(row.route.wire, d0['route']);
      expect(row.routeLabel, d0['route_label']);
      expect(row.routeLabel, '다시 실사로 해소');
      expect(r.emptyLabel, isNull);
      expect(
        r.resolveLink,
        LinkAction.fromJson(fx['resolve_link'] as Map<String, dynamic>),
      );
      expect(
        r.nextAccountLink?.deepLink,
        (fx['next_account_link'] as Map<String, dynamic>)['deep_link'],
      );
      expect(r.nextAccountLink?.label, '다음 계좌 실사 — 일반 계좌');
    });

    test('차이 글자 부호 · 원장에 없는 종목 = 0', () {
      expect(
        SelfReportTexts.quantityDelta('133690', 245, 242),
        '133690 수량 −3주 (원장 245 / 자가 보고 242)',
      );
      expect(
        SelfReportTexts.quantityDelta('411060', 10, 12),
        '411060 수량 +2주 (원장 10 / 자가 보고 12)',
      );
      expect(
        selfReportQuantityDiffsOf(
          ledger: const <String, int>{},
          reported: const <SelfReportLine>[
            SelfReportLine(symbol: 'X', symbolLabel: 'X', quantity: 3),
            SelfReportLine(symbol: 'Y', symbolLabel: 'Y', quantity: 0),
          ],
        ),
        const <SelfReportQuantityDiff>[
          SelfReportQuantityDiff(symbol: 'X', ledger: 0, reported: 3),
        ],
      );
    });

    test('저장 행 = CANON_SELF_REPORT 관측 · delta 에 계좌 · 후보 · id 는 기준일 · 계좌 · 종목마다 다르다', () {
      final List<SelfReportDiffRow> rows = selfReportDiffRowsOf(
        asOf: const TradeDate('2026-08-31'),
        alias: '연금저축',
        diffs: const <SelfReportQuantityDiff>[
          SelfReportQuantityDiff(symbol: '133690', ledger: 245, reported: 242),
        ],
      );
      expect(rows.single.severity, DiffSeverity.observational);
      expect(selfReportAccountOfDelta(rows.single.delta), '연금저축');
      expect(candidatesOfDelta(rows.single.delta), <String>[
        'UNRECORDED_FILL',
        'SELF_REPORT_CORRECTION',
      ]);
      final String a = selfReportDiffIdOf(
        const TradeDate('2026-08-31'),
        '연금저축',
        '133690',
      );
      expect(a, startsWith('ld_sr_'));
      expect(
        a,
        selfReportDiffIdOf(const TradeDate('2026-08-31'), '연금저축', '133690'),
      );
      expect(<String>{
        a,
        selfReportDiffIdOf(const TradeDate('2026-08-31'), '일반', '133690'),
        selfReportDiffIdOf(const TradeDate('2026-07-31'), '연금저축', '133690'),
        selfReportDiffIdOf(const TradeDate('2026-08-31'), '연금저축', '411060'),
      }, hasLength(4));
      expect(selfReportAccountOfDelta('{"x":1}'), isNull);
      expect(selfReportAccountOfDelta('[]'), isNull);
    });

    test('결과 — 차이 0 = 맞음 문장 · 해소 링크는 열린 차이 + 본문 있을 때만 · 다음 계좌 없음 = null', () {
      final SelfReportResult empty = selfReportResultOf(
        diffs: const <StoredLedgerDiff>[],
        yyyyMm: '2026-08',
        nextAlias: null,
        resolveRegistered: true,
        cashSkipped: null,
      );
      expect(empty.diffs, isEmpty);
      expect(empty.emptyLabel, '실사 결과가 원장과 맞습니다');
      expect(empty.resolveLink, isNull);
      expect(empty.nextAccountLink, isNull);
      final SelfReportDiffRow row = selfReportDiffRowsOf(
        asOf: const TradeDate('2026-08-31'),
        alias: '연금저축',
        diffs: const <SelfReportQuantityDiff>[
          SelfReportQuantityDiff(symbol: '133690', ledger: 245, reported: 242),
        ],
      ).single;
      expect(
        selfReportResultOf(
          diffs: <StoredLedgerDiff>[_stored(row)],
          yyyyMm: '2026-08',
          nextAlias: null,
          resolveRegistered: false,
          cashSkipped: null,
        ).resolveLink,
        isNull,
      );
      expect(
        selfReportResultOf(
          diffs: <StoredLedgerDiff>[_stored(row, status: DiffStatus.resolved)],
          yyyyMm: '2026-08',
          nextAlias: null,
          resolveRegistered: true,
          cashSkipped: null,
        ).resolveLink,
        isNull,
      );
    });

    test('다음 계좌 = 차례상 뒤 먼저 · 앞으로 돈다 · 다 했으면 null · 링크 = 그 달 · 그 별칭', () {
      const List<String> accounts = <String>['일반', '연금저축', 'ISA'];
      expect(
        selfReportNextAccountOf(
          accounts: accounts,
          current: '연금저축',
          audited: <String>{'연금저축'},
        ),
        'ISA',
      );
      expect(
        selfReportNextAccountOf(
          accounts: accounts,
          current: 'ISA',
          audited: <String>{'ISA'},
        ),
        '일반',
      );
      expect(
        selfReportNextAccountOf(
          accounts: accounts,
          current: '연금저축',
          audited: <String>{'연금저축', 'ISA'},
        ),
        '일반',
      );
      expect(
        selfReportNextAccountOf(
          accounts: accounts,
          current: '일반',
          audited: <String>{'일반', '연금저축', 'ISA'},
        ),
        isNull,
      );
      expect(
        selfReportLinkOf('2026-08', '연금저축'),
        'aaq://ledger/self-report/2026-08/연금저축',
      );
      expect(selfReportLinkOf('2026-08', 'a/b'), isNull);
      expect(selfReportLinkOf('2026-08', 'a?b'), isNull);
      expect(selfReportLinkOf('2026-08', 'a#b'), isNull);
      expect(selfReportLinkOf('2026-08', ''), isNull);
    });
  });

  group('🆕 R278 현금 축(01 §8 미결 227 · §46 K323)', () {
    const TradeDate asOf = TradeDate('2026-08-31');
    Decimal won(int v) => Decimal.fromInt(v);

    test('🔴 현금 차이 → 저장 행 → 결과 = 표본 `self_report_cash_2` 첫 행(글자 · 쌍 · 축 · 심각도 · 후보 · 행 링크 0 · 해소 링크)', () {
      final SelfReportCashVerdict v = selfReportCashVerdictOf(
        toleranceKrw: Decimal.zero,
        ledgerKrw: won(412300),
        reportedKrw: won(405300),
      );
      final SelfReportDiffRow row = selfReportCashDiffRowsOf(
        asOf: asOf,
        alias: '연금저축',
        verdict: v,
      ).single;
      expect(row.axis, LedgerAxis.cash);
      final SelfReportResult r = selfReportResultOf(
        diffs: <StoredLedgerDiff>[_stored(row)],
        yyyyMm: '2026-08',
        nextAlias: '일반',
        resolveRegistered: true,
        cashSkipped: null,
      );
      final Map<String, dynamic> fx =
          _rows(FixturePaths.m6SelfReportCash2)[0]['result']
              as Map<String, dynamic>;
      final Map<String, dynamic> d0 =
          (fx['diffs'] as List<dynamic>).single as Map<String, dynamic>;
      final LedgerDiffRow got = r.diffs.single;
      expect(got.deltaLabel, d0['delta_label']);
      expect(got.pair.wire, d0['pair']);
      expect(got.axis.wire, d0['axis']);
      expect(got.severity.wire, d0['severity']);
      expect(got.candidateOriginCodes, d0['candidate_origin_codes']);
      expect(got.status.wire, d0['status']);
      expect(got.route.wire, d0['route']);
      expect(got.pairLabel, d0['pair_label']);
      expect(got.axisLabel, d0['axis_label']);
      expect(got.severityLabel, d0['severity_label']);
      expect(got.statusLabel, d0['status_label']);
      expect(got.actionLink, isNull, reason: '결과 안 = 자기 자신으로 가는 고리 0');
      // 🔵 경로 글자 «다시 실사로 해소» · 칩 글자 = 미결 226 ⓕ(자가 보고 행 글자) 몫 — 여기는 L-1 엔진 사전 그대로.
      expect(r.emptyLabel, isNull);
      expect(
        r.resolveLink,
        LinkAction.fromJson(fx['resolve_link'] as Map<String, dynamic>),
      );
    });

    test('🔴 차이 0 · 현금 미대조 = 표본 둘째 행 빈 문장 그대로 · 모름 = 엔진 문장 · 대조함 = 맞음 · 차이 있으면 빈 문장 0', () {
      SelfReportResult res(SelfReportCashSkip? skip, {bool withRow = false}) =>
          selfReportResultOf(
            diffs: <StoredLedgerDiff>[
              if (withRow)
                _stored(
                  selfReportDiffRowsOf(
                    asOf: asOf,
                    alias: '연금저축',
                    diffs: const <SelfReportQuantityDiff>[
                      SelfReportQuantityDiff(
                        symbol: '133690',
                        ledger: 245,
                        reported: 242,
                      ),
                    ],
                  ).single,
                ),
            ],
            yyyyMm: '2026-08',
            nextAlias: '일반',
            resolveRegistered: true,
            cashSkipped: skip,
          );
      final Map<String, dynamic> fx =
          _rows(FixturePaths.m6SelfReportCash2)[1]['result']
              as Map<String, dynamic>;
      final SelfReportResult none = res(SelfReportCashSkip.noTolerance);
      expect(none.diffs, isEmpty);
      expect(none.emptyLabel, fx['empty_label']);
      expect(none.resolveLink, isNull);
      expect(
        none.nextAccountLink?.deepLink,
        (fx['next_account_link'] as Map<String, dynamic>)['deep_link'],
      );
      expect(
        res(SelfReportCashSkip.ledgerUnknown).emptyLabel,
        '수량은 원장과 맞습니다 · 현금은 계좌별 원장 현금을 셀 수 없어 대조하지 않았습니다(적은 값은 기록에 남습니다)',
      );
      expect(res(null).emptyLabel, '실사 결과가 원장과 맞습니다');
      for (final SelfReportCashSkip? s in <SelfReportCashSkip?>[
        null,
        ...SelfReportCashSkip.values,
      ]) {
        expect(res(s, withRow: true).emptyLabel, isNull);
      }
    });

    test('🔴 허용 오차 — 표식 = 0원(설정 값보다 앞) · 설정 값 · 둘 다 없음 = null(엔진 기본값 0) · 음수 = ArgumentError', () {
      expect(
        selfReportCashToleranceOf(configuredKrw: 5000, patternMarker: true),
        Decimal.zero,
      );
      expect(
        selfReportCashToleranceOf(configuredKrw: null, patternMarker: true),
        Decimal.zero,
      );
      expect(
        selfReportCashToleranceOf(configuredKrw: 5000, patternMarker: false),
        won(5000),
      );
      expect(
        selfReportCashToleranceOf(configuredKrw: 0, patternMarker: false),
        Decimal.zero,
      );
      expect(
        selfReportCashToleranceOf(configuredKrw: null, patternMarker: false),
        isNull,
      );
      expect(
        () => selfReportCashToleranceOf(configuredKrw: -1, patternMarker: true),
        throwsArgumentError,
      );
    });

    test('🔴 대조 안 하는 까닭 차례 = 허용 오차 → 원장 현금(제출 판정 · 결과 글자 같은 차례)', () {
      expect(
        selfReportCashSkipOf(toleranceKrw: null, ledgerKnown: false),
        SelfReportCashSkip.noTolerance,
      );
      expect(
        selfReportCashSkipOf(toleranceKrw: null, ledgerKnown: true),
        SelfReportCashSkip.noTolerance,
      );
      expect(
        selfReportCashSkipOf(toleranceKrw: Decimal.zero, ledgerKnown: false),
        SelfReportCashSkip.ledgerUnknown,
      );
      expect(
        selfReportCashSkipOf(toleranceKrw: Decimal.zero, ledgerKnown: true),
        isNull,
      );
      SelfReportCashSkip? reason(SelfReportCashVerdict v) => switch (v) {
        SelfReportCashSkipped(:final SelfReportCashSkip reason) => reason,
        SelfReportCashWithin() || SelfReportCashMismatch() => null,
      };
      expect(
        reason(
          selfReportCashVerdictOf(
            toleranceKrw: null,
            ledgerKrw: null,
            reportedKrw: won(1),
          ),
        ),
        SelfReportCashSkip.noTolerance,
      );
      expect(
        reason(
          selfReportCashVerdictOf(
            toleranceKrw: won(10),
            ledgerKrw: null,
            reportedKrw: won(1),
          ),
        ),
        SelfReportCashSkip.ledgerUnknown,
      );
    });

    test('🔴 판정 — 경계(= 허용 오차 = 안 · 넘으면 차이) · 원장 = 원 단위 반올림 · 음수 원장 글자', () {
      SelfReportCashVerdict v(String ledger, int reported, int tol) =>
          selfReportCashVerdictOf(
            toleranceKrw: won(tol),
            ledgerKrw: Decimal.parse(ledger),
            reportedKrw: won(reported),
          );
      expect(v('1000', 1000, 0), isA<SelfReportCashWithin>());
      expect(v('1500', 1000, 500), isA<SelfReportCashWithin>());
      expect(v('500', 1000, 500), isA<SelfReportCashWithin>());
      expect(v('1501', 1000, 500), isA<SelfReportCashMismatch>());
      expect(v('405300.4', 405300, 0), isA<SelfReportCashWithin>());
      final SelfReportCashMismatch m =
          v('405300.5', 405300, 0) as SelfReportCashMismatch;
      expect(m.ledgerKrw, won(405301));
      expect(m.reportedKrw, won(405300));
      expect(m.toleranceKrw, Decimal.zero);
      expect(
        selfReportCashDiffRowsOf(
          asOf: asOf,
          alias: '일반',
          verdict: m,
        ).single.deltaLabel,
        '원화 현금이 기록과 다릅니다 (원장 405,301원 / 자가 보고 405,300원)',
      );
      expect(
        SelfReportTexts.cashDelta(won(-12000), won(0)),
        '원화 현금이 기록과 다릅니다 (원장 −12,000원 / 자가 보고 0원)',
      );
      expect(
        SelfReportTexts.cashDelta(won(1234567890), won(999)),
        '원화 현금이 기록과 다릅니다 (원장 1,234,567,890원 / 자가 보고 999원)',
      );
    });

    test('🔴 저장 행 — CANON_SELF_REPORT 관측 · delta = 계좌 · 두 값 · 적용 허용 오차 · 후보(표본 차례) · id = 기준일 · 계좌 · 안 · 미대조 = 0행', () {
      final SelfReportDiffRow row = selfReportCashDiffRowsOf(
        asOf: asOf,
        alias: '연금저축',
        verdict: SelfReportCashMismatch(
          ledgerKrw: won(412300),
          reportedKrw: won(405300),
          toleranceKrw: won(1000),
        ),
      ).single;
      expect(row.severity, DiffSeverity.observational);
      expect(selfReportAccountOfDelta(row.delta), '연금저축');
      expect(candidatesOfDelta(row.delta), <String>[
        'EXTERNAL_CASHFLOW',
        'UNRECORDED_FILL',
        'SELF_REPORT_CORRECTION',
      ]);
      expect(kSelfReportCashDiffCandidates, candidatesOfDelta(row.delta));
      final Map<String, dynamic> delta =
          jsonDecode(row.delta) as Map<String, dynamic>;
      expect(delta['axis'], 'CASH');
      expect(delta['ledger_krw'], '412300');
      expect(delta['reported_krw'], '405300');
      expect(delta['tolerance_krw'], '1000');
      expect(row.diffId, selfReportCashDiffIdOf(asOf, '연금저축'));
      expect(row.diffId, startsWith('ld_sr_'));
      expect(<String>{
        row.diffId,
        selfReportCashDiffIdOf(asOf, '일반'),
        selfReportCashDiffIdOf(const TradeDate('2026-07-31'), '연금저축'),
        selfReportDiffIdOf(asOf, '연금저축', '133690'),
        selfReportDiffIdOf(asOf, '연금저축', 'CASH'),
      }, hasLength(5));
      expect(
        selfReportCashDiffRowsOf(
          asOf: asOf,
          alias: '연금저축',
          verdict: SelfReportCashWithin(toleranceKrw: Decimal.zero),
        ),
        isEmpty,
      );
      for (final SelfReportCashSkip s in SelfReportCashSkip.values) {
        expect(
          selfReportCashDiffRowsOf(
            asOf: asOf,
            alias: '연금저축',
            verdict: SelfReportCashSkipped(s),
          ),
          isEmpty,
        );
      }
    });

    test('🔴 원장 현금 = 현금 흐름 합 + 체결(매도 = 대금 − 비용 · 매수 = −(대금 + 비용) · 되돌림 = 음수) · 모름 = null', () {
      const List<SimExecution> fills = <SimExecution>[
        SimExecution(
          side: OrderSide.sell,
          quantity: 10,
          price: 1000,
          commission: 15,
          tax: 20,
        ),
        SimExecution(
          side: OrderSide.buy,
          quantity: 5,
          price: 2000,
          commission: 10,
          tax: 0,
        ),
        // 위 매수의 되돌림(수량 · 비용 음수).
        SimExecution(
          side: OrderSide.buy,
          quantity: -5,
          price: 2000,
          commission: -10,
          tax: 0,
        ),
      ];
      expect(
        selfReportLedgerCashOf(
          const SelfReportCashFacts(
            cashFlowSum: 1000000,
            executions: fills,
            unattributed: false,
          ),
        ),
        won(1009965),
      );
      expect(
        selfReportLedgerCashOf(
          const SelfReportCashFacts(
            cashFlowSum: 1000000,
            executions: fills,
            unattributed: true,
          ),
        ),
        isNull,
      );
      expect(
        selfReportLedgerCashOf(
          const SelfReportCashFacts(
            cashFlowSum: 0,
            executions: <SimExecution>[],
            unattributed: false,
          ),
        ),
        Decimal.zero,
      );
    });

    test('🆕 R281 🔴 판정 → 실사 행 두 칸(대조함 = 적용 허용 오차 · 대조 안 함 = 까닭 · null) → 결과 까닭(대조함 = null)', () {
      ({SelfReportCashCheck check, double? toleranceKrw}) rec(
        SelfReportCashVerdict v,
      ) => selfReportCashRecordOf(v);
      expect(
        rec(
          selfReportCashVerdictOf(
            toleranceKrw: won(1000),
            ledgerKrw: won(1500),
            reportedKrw: won(1000),
          ),
        ),
        (check: SelfReportCashCheck.compared, toleranceKrw: 1000.0),
      );
      expect(
        rec(
          selfReportCashVerdictOf(
            toleranceKrw: Decimal.zero,
            ledgerKrw: won(2),
            reportedKrw: won(1),
          ),
        ),
        (check: SelfReportCashCheck.compared, toleranceKrw: 0.0),
      );
      expect(rec(const SelfReportCashSkipped(SelfReportCashSkip.noTolerance)), (
        check: SelfReportCashCheck.noTolerance,
        toleranceKrw: null,
      ));
      expect(
        rec(const SelfReportCashSkipped(SelfReportCashSkip.ledgerUnknown)),
        (check: SelfReportCashCheck.ledgerUnknown, toleranceKrw: null),
      );
      expect(selfReportCashSkipOfCheck(SelfReportCashCheck.compared), isNull);
      expect(
        selfReportCashSkipOfCheck(SelfReportCashCheck.noTolerance),
        SelfReportCashSkip.noTolerance,
      );
      expect(
        selfReportCashSkipOfCheck(SelfReportCashCheck.ledgerUnknown),
        SelfReportCashSkip.ledgerUnknown,
      );
      // 왕복: 대조 안 함 까닭은 기록 → 읽기에서 그대로 돌아온다.
      for (final SelfReportCashSkip k in SelfReportCashSkip.values) {
        expect(
          selfReportCashSkipOfCheck(rec(SelfReportCashSkipped(k)).check),
          k,
        );
      }
      final SelfReportCashWithin w = selfReportCashVerdictOf(
        toleranceKrw: won(10),
        ledgerKrw: won(5),
        reportedKrw: won(0),
      ) as SelfReportCashWithin;
      expect(w.toleranceKrw, won(10));
    });

    test('🔴 0오차(K321 ④) = 수량 전부 일치 ∧ 현금은 대조한 때만 센다', () {
      const List<SelfReportQuantityDiff> q = <SelfReportQuantityDiff>[
        SelfReportQuantityDiff(symbol: '133690', ledger: 245, reported: 242),
      ];
      final SelfReportCashMismatch m = SelfReportCashMismatch(
        ledgerKrw: won(2),
        reportedKrw: won(1),
        toleranceKrw: Decimal.zero,
      );
      for (final SelfReportCashSkip s in SelfReportCashSkip.values) {
        expect(
          selfReportZeroErrorOf(
            quantity: const <SelfReportQuantityDiff>[],
            cash: SelfReportCashSkipped(s),
          ),
          isTrue,
        );
      }
      expect(
        selfReportZeroErrorOf(
          quantity: const <SelfReportQuantityDiff>[],
          cash: SelfReportCashWithin(toleranceKrw: Decimal.zero),
        ),
        isTrue,
      );
      expect(
        selfReportZeroErrorOf(
          quantity: const <SelfReportQuantityDiff>[],
          cash: m,
        ),
        isFalse,
      );
      expect(
        selfReportZeroErrorOf(
          quantity: q,
          cash: SelfReportCashWithin(toleranceKrw: Decimal.zero),
        ),
        isFalse,
      );
    });
  });

  group('세션 시작 판정', () {
    SelfReportStartVerdict start({
      String m = '2026-08',
      String alias = '연금저축',
      OperatingMode? mode = OperatingMode.advisory,
      Map<String, String> accounts = _accounts,
      DateTime? trusted,
    }) => selfReportStartOf(
      yyyyMm: m,
      accountAlias: alias,
      operatingMode: mode,
      accountByStrategy: accounts,
      trustedNowUtc: trusted,
      kr: _kr,
    );

    String refused(SelfReportStartVerdict v) => switch (v) {
      SelfReportStartRefused(:final String text) => text,
      SelfReportStartOpen() => fail('열렸다'),
    };

    final DateTime after = DateTime.utc(2026, 8, 31, 9);

    test('🔴 기준일 = 그 달 마지막 KR 세션 · 꼴 틀림 · 달력 밖 = null', () {
      expect(selfReportAsOfOf('2026-08', _kr), const TradeDate('2026-08-31'));
      expect(selfReportAsOfOf('2026-10', _kr), const TradeDate('2026-10-30'));
      expect(selfReportAsOfOf('2026-8', _kr), isNull);
      expect(selfReportAsOfOf('2026-13', _kr), isNull);
      expect(selfReportAsOfOf('2026-00', _kr), isNull);
      expect(selfReportAsOfOf('x', _kr), isNull);
      expect(selfReportAsOfOf('1900-01', _kr), isNull);
      expect(selfReportMonthOf('2026-08'), 8);
      expect(selfReportMonthOf('2026-12'), 12);
    });

    test('🔴 차례 = 운영 방식 → 계좌 대응 → 별칭 → 달 → 신뢰 시각 → 기준일 종가 확정', () {
      expect(
        refused(start(mode: OperatingMode.autoTrade, trusted: after)),
        SelfReportTexts.closedAutoTrade,
      );
      expect(
        refused(start(mode: null, trusted: after)),
        SelfReportTexts.closedAutoTrade,
      );
      expect(
        refused(start(accounts: const <String, String>{}, trusted: after)),
        SelfReportTexts.closedNoAccounts,
      );
      expect(
        refused(start(alias: '모르는', trusted: after)),
        SelfReportTexts.closedUnknownAccount,
      );
      expect(
        refused(start(m: '2026-8', trusted: after)),
        SelfReportTexts.closedUnknownMonth,
      );
      final SelfReportStartVerdict noTime = start();
      expect(refused(noTime), SelfReportTexts.closedTrustedTimeUnknown);
      expect(
        (noTime as SelfReportStartRefused).asOf,
        const TradeDate('2026-08-31'),
      );
      // 17:59 KST = 아직 확정 전(값 확정 18:00 · N3).
      expect(
        refused(start(trusted: DateTime.utc(2026, 8, 31, 8, 59))),
        '2026-08-31 종가가 아직 확정되지 않았습니다 · 그날 18시 뒤에 실사하십시오',
      );
      final SelfReportStartVerdict ok = start(trusted: after);
      expect(ok, isA<SelfReportStartOpen>());
      expect((ok as SelfReportStartOpen).asOf, const TradeDate('2026-08-31'));
      expect(ok.startedAtUtc, after);
      // 지난 달도 연다(기한 지난 실사 · 기준일 = 그 달 말).
      final SelfReportStartVerdict late = start(
        m: '2026-07',
        trusted: DateTime.utc(2026, 9, 3),
      );
      expect((late as SelfReportStartOpen).asOf, const TradeDate('2026-07-31'));
    });
  });

  group('원문 → 와이어', () {
    test('🔴 전 종목 줄(목록 차례 · 0 포함 · 쉼표 · 공백) · 현금 · 세션 값 · 맥락 = 와이어', () {
      final SelfReportWireResult w = _wire(_sub());
      final SelfReportBalance wire = (w as SelfReportWireReady).wire;
      expect(wire.purpose, SelfReportPurpose.periodicAudit);
      expect(wire.asOfTradeDate, const TradeDate('2026-08-31'));
      expect(wire.sessionStartedAt, DateTime.utc(2026, 8, 31, 9));
      expect(wire.accountAlias, '연금저축');
      expect(wire.cashKrw, Decimal.fromInt(1250000));
      expect(wire.declaredComplete, isTrue);
      expect(wire.context, _ctx);
      expect(wire.lines, const <SelfReportLine>[
        SelfReportLine(
          symbol: '069500',
          symbolLabel: '069500 KODEX 200',
          quantity: 0,
        ),
        SelfReportLine(
          symbol: '133690',
          symbolLabel: '133690 TIGER 미국나스닥100',
          quantity: 242,
        ),
        SelfReportLine(
          symbol: '411060',
          symbolLabel: '411060 ACE KRX금현물',
          quantity: 1050,
        ),
        SelfReportLine(
          symbol: '0085P0',
          symbolLabel: '0085P0 ACE 미국10년국채액티브',
          quantity: 12,
        ),
      ]);
      expect(
        selfReportPayloadDigestOf(wire),
        matches(RegExp(r'^[0-9a-f]{64}$')),
      );
    });

    test('🔴 로컬 거부 글자(어느 칸) — 계좌 → 목록 밖 → 빈칸(빈칸 ≠ 0) → 꼴 → 현금 → 확인', () {
      String l(String what) => SelfReportTexts.inputInvalid(what);
      expect(
        _invalid(_wire(_sub(alias: '일반'))),
        l(SelfReportTexts.accountMismatch),
      );
      expect(
        _invalid(_wire(_sub(alias: null))),
        l(SelfReportTexts.accountMismatch),
      );
      expect(
        _invalid(
          _wire(
            _sub(
              lines: <String, String>{
                '069500': '0',
                '133690': '1',
                '411060': '1',
                '0085P0': '1',
                '999999': '1',
              },
            ),
          ),
        ),
        l(SelfReportTexts.unknownLine),
      );
      expect(
        _invalid(
          _wire(
            _sub(
              lines: <String, String>{
                '069500': '0',
                '133690': '',
                '411060': '1',
                '0085P0': '1',
              },
            ),
          ),
        ),
        '거부됨 — 133690 TIGER 미국나스닥100 수량 칸이 비어 있습니다 — 보유하지 않으면 0 을 적으십시오. 입력값은 그대로 남아 있습니다',
      );
      expect(
        _invalid(
          _wire(
            _sub(
              lines: <String, String>{
                '069500': '0',
                '133690': '1',
                '411060': '1',
              },
            ),
          ),
        ),
        l(SelfReportTexts.quantityBlank('0085P0 ACE 미국10년국채액티브')),
      );
      for (final String bad in <String>['-1', '1.5', 'abc', '1,00', '+3']) {
        expect(
          _invalid(
            _wire(
              _sub(
                lines: <String, String>{
                  '069500': bad,
                  '133690': '1',
                  '411060': '1',
                  '0085P0': '1',
                },
              ),
            ),
          ),
          l(SelfReportTexts.quantityMalformed('069500 KODEX 200')),
          reason: bad,
        );
      }
      expect(
        _invalid(_wire(_sub(cash: ' '))),
        '거부됨 — 현금 칸을 숫자로 적으십시오. 입력값은 그대로 남아 있습니다',
      );
      expect(
        _invalid(_wire(_sub(cash: '12a'))),
        l(SelfReportTexts.cashMalformed),
      );
      expect(
        _invalid(_wire(_sub(cash: '-5'))),
        l(SelfReportTexts.cashNegative),
      );
      expect(
        _invalid(_wire(_sub(cash: '100.5'))),
        l(SelfReportTexts.cashFraction),
      );
      expect(
        _invalid(_wire(_sub(complete: false))),
        l(SelfReportTexts.notDeclared),
      );
      expect(
        (_wire(_sub(cash: '0')) as SelfReportWireReady).wire.cashKrw,
        Decimal.zero,
      );
      expect(
        (_wire(_sub(cash: '100.0')) as SelfReportWireReady).wire.cashKrw,
        Decimal.fromInt(100),
      );
      expect(
        () => _wire(_sub(purpose: SelfReportPurpose.simOpening)),
        throwsArgumentError,
      );
    });
  });

  group('종목 목록', () {
    test(
      '🔴 유니버스 전 종목(계좌 무관) — 슬리브 차례 → 코드 · 금 = B 먼저 · 파킹 = B · 원장에 남은 설정 밖 종목도',
      () {
        final P0sOpsConfig cfg = P0sOpsConfig.of(
          P0sHumanInputs(aSymbol: '069500', accountByStrategy: _accounts),
        );
        final List<SymbolOption> s = selfReportSymbolsOf(
          cfg,
          held: const <String, SleeveId>{
            '305080': SleeveId.c,
            '133690': SleeveId.c,
          },
        );
        expect(
          <(String, SleeveId)>[
            for (final SymbolOption o in s) (o.symbol, o.sleeve),
          ],
          <(String, SleeveId)>[
            ('069500', SleeveId.a),
            ('133690', SleeveId.b),
            ('214980', SleeveId.b),
            ('411060', SleeveId.b),
            ('0085P0', SleeveId.c),
            ('305080', SleeveId.c),
          ],
        );
        expect(s[1].label, '133690 TIGER 미국나스닥100');
        expect(s.first.label, '069500');
        expect(s.last.label, '305080');
      },
    );

    test('계좌 차례 · 계좌에 묶인 전략 · 전략 → 슬리브', () {
      expect(selfReportAccountsOf(_accounts), <String>['일반', '연금저축']);
      expect(selfReportAccountsOf(const <String, String>{}), isEmpty);
      expect(selfReportStrategiesOf(_accounts, '연금저축'), <String>[
        'P0S_B',
        'P0S_POT',
      ]);
      expect(selfReportStrategiesOf(_accounts, '일반'), <String>[
        'P0S_A',
        'P0S_C',
      ]);
      expect(selfReportSleeveOfStrategy('P0S_A'), SleeveId.a);
      expect(selfReportSleeveOfStrategy('P0S_POT'), SleeveId.pot);
      expect(selfReportSleeveOfStrategy('P0S'), isNull);
    });
  });

  group('접수증 · 배지 = 표본', () {
    test('🔴 접수증 글자 · 상태 · 사유 = `self_report_receipts_5`', () {
      final SimOpeningCommand c = SimOpeningCommand.issue(
        deviceId: _dev,
        nowUtc: DateTime.utc(2026, 8, 31, 12, 5),
        random: Random(7),
      );
      final List<Map<String, dynamic>> fx = _rows(
        FixturePaths.m6SelfReportReceipts5,
      );
      final Map<String, Map<String, dynamic>> byState =
          <String, Map<String, dynamic>>{
            for (final Map<String, dynamic> r in fx)
              '${r['state']}/${r['reject_reason_code']}': r,
          };
      void same(CommandReceipt r, String key) {
        final Map<String, dynamic> f = byState[key]!;
        expect(r.state.wire, f['state'], reason: key);
        expect(r.stateLabel, f['state_label'], reason: key);
        expect(r.rejectReasonCode, f['reject_reason_code'], reason: key);
        expect(r.kind, CommandKind.selfReportBalance);
      }

      same(selfReportReceiptOf(c, SelfReportOutcome.executed), 'EXECUTED/null');
      same(
        selfReportReceiptOf(c, SelfReportOutcome.held),
        'HELD_FOR_INTEGRITY/null',
      );
      same(
        selfReportReceiptOf(c, SelfReportOutcome.outsideSession),
        'REJECTED/SELF_REPORT_OUTSIDE_SESSION',
      );
      same(
        c.inputInvalid(
          SelfReportTexts.inputInvalid(SelfReportTexts.cashMalformed),
        ),
        'REJECTED/INPUT_INVALID',
      );
      expect(
        selfReportReceiptOf(
          c,
          SelfReportOutcome.operatingModeMismatch,
        ).rejectReasonCode,
        AdviceRejectCodes.operatingModeMismatch,
      );
      expect(
        selfReportReceiptOf(c, SelfReportOutcome.leaseExpired).rejectReasonCode,
        AdviceRejectCodes.leaseExpired,
      );
      final CommandReceipt t = selfReportReceiptOf(
        c,
        SelfReportOutcome.trustedTimeUnknown,
      );
      expect(t.rejectReasonCode, 'TRUSTED_TIME_UNKNOWN');
      expect(t.state, CommandState.rejected);
      expect(t.stateLabel, SelfReportTexts.trustedTimeUnknown);
    });

    test('🔴 배지 = 자가 보고(실패 아님 · 실사 경로의 상한) — 표본 `self_report_1` trust', () {
      expect(
        selfReportTrustBadgeOf(const TradeDate('2026-08-31')),
        LedgerTrustBadge.fromJson(
          _row(FixturePaths.m6SelfReport1)['trust'] as Map<String, dynamic>,
        ),
      );
      expect(selfReportTrustBadgeOf(null).lastVerifiedOn, isNull);
      expect(selfReportTrustBadgeOf(null).actionDeepLink, isNull);
    });
  });
}
