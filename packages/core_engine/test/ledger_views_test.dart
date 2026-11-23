// E13c2 — X5 읽기 쪽 순수(설계 13 §8 R59 S1~S7).
//
// 🔵 잡는 것: ① 계약 픽스처 글자 그대로(`ledger_diffs_4` · `ledger_diffs_cash_observe` — 증거 해시만 엔진 몫)
//    ② 정렬(열린 차단 → 열린 관측 → 닫힌 것 최신) · 30일 창 · 50행 · 빈 문장 ③ 5칸 = `recon_board_ok` 그대로 ·
//    `recon_board_diff` 는 자가 보고 칸만 다름(픽스처 모순 — R59 ⑦) ④ 칸 경우 전부 · 🔴 파생 `blocked` 0 · 해당 없음 ⇒ info ·
//    점검 칸 OK ⇔ ok(K3) ⑤ headline 갈래 ⑥ 라벨 사전 = 원인 코드 전부 · 모르는 코드 = 실패.
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Map<String, dynamic> _fixture(String rel) =>
    jsonDecode(File('../domain_contracts/fixtures/$rel').readAsStringSync())
        as Map<String, dynamic>;

List<Map<String, dynamic>> _rows(String rel) =>
    (_fixture(rel)['rows'] as List<dynamic>).cast<Map<String, dynamic>>();

/// 픽스처 행 → 저장 행(탐지 = «탐지 YYYY-MM-DD HH:mm» 한국 · 닫힌 날 = 상태 라벨의 날).
StoredLedgerDiff _storedOf(Map<String, dynamic> fx) {
  final String det = (fx['detected_at_text'] as String).substring(3);
  final DateTime detected = DateTime.parse(
    '${det.replaceFirst(' ', 'T')}:00+09:00',
  ).toUtc();
  final String status = fx['status_label'] as String;
  final RegExpMatch? day = RegExp(r'(\d{4}-\d{2}-\d{2})$').firstMatch(status);
  return StoredLedgerDiff(
    diffId: fx['diff_id'] as String,
    pair: LedgerPair.values.firstWhere((LedgerPair p) => p.wire == fx['pair']),
    axis: LedgerAxis.values.firstWhere((LedgerAxis a) => a.wire == fx['axis']),
    authoredDate: TradeDate(fx['authored_date'] as String),
    delta: jsonEncode(<String, Object?>{
      'candidates': fx['candidate_origin_codes'],
    }),
    deltaLabel: fx['delta_label'] as String,
    severity: DiffSeverity.values.firstWhere(
      (DiffSeverity s) => s.wire == fx['severity'],
    ),
    status: DiffStatus.values.firstWhere(
      (DiffStatus s) => s.wire == fx['status'],
    ),
    detectedAtUtc: detected,
    applicable: fx['applicable'] as bool,
    closedAtUtc: day == null
        ? null
        : DateTime.parse('${day.group(1)}T12:00:00+09:00').toUtc(),
  );
}

StoredLedgerDiff _diff(
  String id, {
  LedgerPair pair = LedgerPair.canonBroker,
  DiffSeverity severity = DiffSeverity.blocking,
  DiffStatus status = DiffStatus.open,
  required DateTime detected,
  DateTime? closed,
}) => StoredLedgerDiff(
  diffId: id,
  pair: pair,
  axis: LedgerAxis.quantity,
  authoredDate: const TradeDate('2026-08-28'),
  delta: '{"candidates":["FILL_LAG"]}',
  deltaLabel: 'x',
  severity: severity,
  status: status,
  detectedAtUtc: detected,
  applicable: true,
  closedAtUtc: closed,
);

final DateTime _now = DateTime.utc(2026, 8, 31, 9);
final AsOf _asOf = reconAsOf(lastReconUtc: _now, nowUtc: _now);

void main() {
  group('LedgerDiffRow(R59 S3 · S4) — 계약 픽스처 글자 그대로', () {
    for (final String rel in <String>[
      'ledger_diffs_4.json',
      'm6/ledger_diffs_cash_observe.json',
    ]) {
      test(rel, () {
        for (final Map<String, dynamic> fx in _rows(rel)) {
          final LedgerDiffRow expected = LedgerDiffRow.fromJson(fx);
          final LedgerDiffRow got = ledgerDiffRowOf(_storedOf(fx));
          expect(got.evidenceHash, matches(RegExp(r'^ev_[0-9a-f]{12}$')));
          // 🆕 E16j-a(01 §8 미결 217 ⓕ) — 조치 링크 = 대상 라우트 · 🆕 계약 v1.35(01 §44 K293) — 표본도 대상 라우트 글자라
          //    조치 링크까지 표본 글자 그대로(증거 해시만 엔진 몫).
          if (expected.actionLink != null) {
            expect(
              expected.actionLink!.deepLink,
              AppRoutes.x5RepairTarget.replaceFirst(
                ':targetId',
                expected.diffId,
              ),
            );
          }
          expect(
            got.copyWith(evidenceHash: expected.evidenceHash),
            expected,
            reason: fx['diff_id'] as String,
          );
        }
      });
    }

    test('뷰어(폰 아님) = 조치 링크 없음 · 닫힌 시각 모름 = 날짜 없는 «해소됨»', () {
      final StoredLedgerDiff open = _diff('a', detected: _now);
      // 🆕 E16j-a(01 §8 미결 217 ⓕ) — 대상 라우트(diff id 를 싣는다 · 허브가 아니다).
      expect(
        ledgerDiffRowOf(open).actionLink?.deepLink,
        AppRoutes.x5RepairTarget.replaceFirst(':targetId', open.diffId),
      );
      expect(
        AppRoutes.isRegistered(ledgerDiffRowOf(open).actionLink!.deepLink),
        isTrue,
      );
      expect(ledgerDiffRowOf(open, phone: false).actionLink, isNull);
      expect(
        ledgerDiffRowOf(_diff('b', status: DiffStatus.resolved, detected: _now))
            .statusLabel,
        '해소됨',
      );
      expect(statusLabelOf(DiffStatus.accepted, null), '받아들임');
      // 닫힌 차단 행 = 조치 링크 없음.
      expect(
        ledgerDiffRowOf(_diff('c', status: DiffStatus.resolved, detected: _now))
            .actionLink,
        isNull,
      );
    });
  });

  group('recentLedgerDiffsOf(R59 S1)', () {
    test('정렬 = 열린 차단 → 열린 관측 → 닫힌 것(닫힌 시각 최신 먼저) — 픽스처 차례', () {
      final List<StoredLedgerDiff> rows = <StoredLedgerDiff>[
        for (final Map<String, dynamic> fx in _rows('ledger_diffs_4.json'))
          _storedOf(fx),
      ];
      final ListResult<LedgerDiffRow> r = recentLedgerDiffsOf(
        rows.reversed.toList(),
        nowUtc: _now,
        asOf: _asOf,
      );
      expect(r.rows.map((LedgerDiffRow x) => x.diffId), <String>[
        'ld_0001',
        'ld_0002',
        'ld_0003',
        'ld_0004',
      ]);
      expect(
        (r.emptyKind, r.emptyLabel, r.hasMore, r.asOf),
        (EmptyKind.noData, null, false, _asOf),
      );
    });

    test('같은 무리 안 = 탐지 최신 먼저 · 같으면 id', () {
      final ListResult<LedgerDiffRow> r = recentLedgerDiffsOf(
        <StoredLedgerDiff>[
          _diff('b', detected: DateTime.utc(2026, 8, 1)),
          _diff('c', detected: DateTime.utc(2026, 8, 2)),
          _diff('a', detected: DateTime.utc(2026, 8, 1)),
          _diff(
            'o2',
            severity: DiffSeverity.observational,
            detected: DateTime.utc(2026, 8, 3),
          ),
          _diff(
            'o1',
            severity: DiffSeverity.observational,
            detected: DateTime.utc(2026, 8, 4),
          ),
          _diff(
            'x',
            status: DiffStatus.resolved,
            detected: DateTime.utc(2026, 8, 5),
            closed: DateTime.utc(2026, 8, 20),
          ),
          _diff(
            'y',
            status: DiffStatus.accepted,
            detected: DateTime.utc(2026, 8, 6),
            closed: DateTime.utc(2026, 8, 25),
          ),
        ],
        nowUtc: _now,
        asOf: _asOf,
      );
      expect(r.rows.map((LedgerDiffRow x) => x.diffId), <String>[
        'c',
        'a',
        'b',
        'o1',
        'o2',
        'y',
        'x',
      ]);
    });

    test('30일 창 — 닫힌 것만 거른다(닫힌 시각 · 모르면 탐지 시각) · 열린 것은 오래돼도 남는다', () {
      final ListResult<LedgerDiffRow> r = recentLedgerDiffsOf(
        <StoredLedgerDiff>[
          _diff('old-open', detected: DateTime.utc(2026, 1, 1)),
          _diff(
            'in',
            status: DiffStatus.resolved,
            detected: DateTime.utc(2026, 7, 1),
            closed: DateTime.utc(2026, 8, 1),
          ),
          _diff(
            'edge',
            status: DiffStatus.resolved,
            detected: DateTime.utc(2026, 7, 1),
            closed: DateTime.utc(2026, 7, 31, 16),
          ),
          _diff(
            'out',
            status: DiffStatus.resolved,
            detected: DateTime.utc(2026, 7, 1),
            closed: DateTime.utc(2026, 7, 31, 14),
          ),
          _diff(
            'no-close-in',
            status: DiffStatus.resolved,
            detected: DateTime.utc(2026, 8, 10),
          ),
          _diff(
            'no-close-out',
            status: DiffStatus.accepted,
            detected: DateTime.utc(2026, 7, 1),
          ),
        ],
        nowUtc: _now,
        asOf: _asOf,
      );
      // 창 = 한국 08-01 부터(08-31 18:00 KST − 30일) · 07-31T16:00Z = 한국 08-01 01:00.
      expect(r.rows.map((LedgerDiffRow x) => x.diffId).toSet(), <String>{
        'old-open',
        'in',
        'edge',
        'no-close-in',
      });
    });

    test('50행 · 넘으면 hasMore · 빈 = «최근 대조 차이가 없습니다»', () {
      final List<StoredLedgerDiff> many = <StoredLedgerDiff>[
        for (int i = 0; i < 51; i++)
          _diff(
            'd${i.toString().padLeft(2, '0')}',
            detected: DateTime.utc(2026, 8, 1).add(Duration(minutes: i)),
          ),
      ];
      final ListResult<LedgerDiffRow> r = recentLedgerDiffsOf(
        many,
        nowUtc: _now,
        asOf: _asOf,
      );
      expect(
        (r.rows.length, r.hasMore, r.rows.first.diffId),
        (50, true, 'd50'),
      );
      expect(
        recentLedgerDiffsOf(
          many.take(50).toList(),
          nowUtc: _now,
          asOf: _asOf,
        ).hasMore,
        isFalse,
      );
      final ListResult<LedgerDiffRow> e = recentLedgerDiffsOf(
        const <StoredLedgerDiff>[],
        nowUtc: _now,
        asOf: _asOf,
      );
      expect(e.rows, isEmpty);
      expect(
        (e.emptyKind, e.emptyLabel, e.hasMore),
        (EmptyKind.noData, '최근 대조 차이가 없습니다', false),
      );
    });
  });

  group('5칸 대조 보드(R59 S5 · S6)', () {
    test('🔵 recon_board_ok 그대로', () {
      final DiagnosticsVm expected = DiagnosticsVm.fromJson(
        _rows('m8/recon_board_ok.json').single,
      );
      final DiagnosticsVm got = diagnosticsOf(
        mode: OperatingMode.autoTrade,
        broker: const BrokerReconSummary(
          reconRan: true,
          lastActionCode: 'MATCHED',
        ),
        derived: <LedgerPair, DerivedPairSummary>{
          for (final LedgerPair p in <LedgerPair>[
            LedgerPair.canonSupabase,
            LedgerPair.canonGithub,
            LedgerPair.canonCalendar,
          ])
            p: const DerivedPairSummary(connected: true),
        },
        asOf: reconAsOf(lastReconUtc: _now, nowUtc: _now),
      );
      expect(got, expected);
    });

    test('recon_board_diff — 자가 보고 칸만 다르다(자동 매매 = «해당 없음» · R59 ⑦)', () {
      final DiagnosticsVm expected = DiagnosticsVm.fromJson(
        _rows('m8/recon_board_diff.json').single,
      );
      final DiagnosticsVm got = diagnosticsOf(
        mode: OperatingMode.autoTrade,
        broker: const BrokerReconSummary(
          reconRan: true,
          lastActionCode: 'BLOCKED',
          openBlockingAxes: <LedgerAxis>{LedgerAxis.quantity},
        ),
        derived: <LedgerPair, DerivedPairSummary>{
          LedgerPair.canonSupabase: const DerivedPairSummary(
            connected: true,
            openCandidates: <List<String>>[
              <String>['PUSH_LAG'],
            ],
          ),
          LedgerPair.canonGithub: const DerivedPairSummary(connected: true),
          LedgerPair.canonCalendar: const DerivedPairSummary(connected: true),
        },
        asOf: reconAsOf(lastReconUtc: _now, nowUtc: _now),
      );
      expect(got.cells.take(4).toList(), expected.cells.take(4).toList());
      expect(got.headline, expected.headline);
      expect(got.asOf, expected.asOf);
      expect(
        (got.cells.last.stateCode, got.cells.last.stateLabel),
        ('NOT_APPLICABLE', '해당 없음'),
      );
      expect(
        (expected.cells.last.stateCode, expected.cells.last.applicable),
        ('NOT_CHECKED', false),
      );
    });

    (String, String, UiLevel, bool) c(DiagnosticCell x) =>
        (x.stateCode, x.stateLabel, x.level, x.applicable);

    test('브로커 칸 — 안내 모드 · 대사 전 · 차단 축 · 대사 실패 · 현금 관측 · 일치', () {
      const BrokerReconSummary ran = BrokerReconSummary(
        reconRan: true,
        lastActionCode: 'MATCHED',
      );
      expect(c(brokerCellOf(OperatingMode.advisory, ran)), (
        'NOT_APPLICABLE',
        '해당 없음',
        UiLevel.info,
        false,
      ));
      expect(
        c(
          brokerCellOf(
            OperatingMode.autoTrade,
            const BrokerReconSummary(reconRan: false),
          ),
        ),
        ('NOT_CHECKED', '아직 대사 전 — 점검 안 함', UiLevel.info, false),
      );
      String mis(Set<LedgerAxis> a) => brokerCellOf(
        OperatingMode.autoTrade,
        BrokerReconSummary(
          reconRan: true,
          lastActionCode: 'UNAVAILABLE',
          openBlockingAxes: a,
          openObservational: true,
        ),
      ).stateLabel;
      expect(mis(<LedgerAxis>{LedgerAxis.quantity}), '수량이 어긋납니다');
      expect(mis(<LedgerAxis>{LedgerAxis.executionRow}), '체결 건이 어긋납니다');
      expect(
        mis(<LedgerAxis>{LedgerAxis.executionRow, LedgerAxis.quantity}),
        '수량 · 체결 건이 어긋납니다',
      );
      expect(
        brokerCellOf(
          OperatingMode.autoTrade,
          const BrokerReconSummary(
            reconRan: true,
            openBlockingAxes: <LedgerAxis>{LedgerAxis.quantity},
          ),
        ).level,
        UiLevel.blocked,
      );
      expect(
        c(
          brokerCellOf(
            OperatingMode.autoTrade,
            const BrokerReconSummary(
              reconRan: true,
              lastActionCode: 'UNAVAILABLE',
              openObservational: true,
            ),
          ),
        ),
        ('UNAVAILABLE', '대사하지 못했습니다', UiLevel.watch, true),
      );
      expect(
        c(
          brokerCellOf(
            OperatingMode.autoTrade,
            const BrokerReconSummary(reconRan: true, openObservational: true),
          ),
        ),
        ('CASH_OBSERVED', '현금이 기록과 다릅니다(관측)', UiLevel.watch, true),
      );
      expect(c(brokerCellOf(OperatingMode.autoTrade, ran)), (
        'OK',
        '일치',
        UiLevel.ok,
        true,
      ));
    });

    test('파생 칸 — 연결 전 · 일치 · 지연만 · 어긋남 · 섞임 · 빈 후보 · 🔴 늘 blocked 아님', () {
      expect(
        c(
          derivedCellOf(
            LedgerPair.canonGithub,
            const DerivedPairSummary(connected: false),
          ),
        ),
        ('NOT_CHECKED', '아직 연결 전 — 점검 안 함', UiLevel.info, false),
      );
      DiagnosticCell d(LedgerPair p, List<List<String>> open) => derivedCellOf(
        p,
        DerivedPairSummary(connected: true, openCandidates: open),
      );
      expect(c(d(LedgerPair.canonCalendar, const <List<String>>[])), (
        'OK',
        '일치',
        UiLevel.ok,
        true,
      ));
      expect(
        c(
          d(LedgerPair.canonGithub, <List<String>>[
            <String>['ARCHIVE_LAG'],
          ]),
        ),
        ('LAG', '아카이브가 뒤처집니다', UiLevel.watch, true),
      );
      expect(
        c(
          d(LedgerPair.canonCalendar, <List<String>>[
            <String>['CAL_WRITE_FAILED'],
          ]),
        ),
        ('MISMATCH', '캘린더가 어긋납니다', UiLevel.watch, true),
      );
      expect(
        d(LedgerPair.canonSupabase, <List<String>>[
          <String>['PUSH_LAG'],
          <String>['PUSH_FAILED'],
        ]).stateCode,
        'MISMATCH',
      );
      expect(
        d(LedgerPair.canonSupabase, <List<String>>[
          <String>['PUSH_LAG', 'SCHEMA_SKEW'],
        ]).stateCode,
        'MISMATCH',
      );
      expect(
        d(LedgerPair.canonSupabase, <List<String>>[<String>[]]).stateCode,
        'MISMATCH',
      );
      expect(
        () => derivedCellOf(
          LedgerPair.canonBroker,
          const DerivedPairSummary(connected: true),
        ),
        throwsArgumentError,
      );
      for (final LedgerPair p in <LedgerPair>[
        LedgerPair.canonSupabase,
        LedgerPair.canonGithub,
        LedgerPair.canonCalendar,
      ]) {
        for (final List<List<String>> open in <List<List<String>>>[
          const <List<String>>[],
          <List<String>>[
            <String>['PUSH_LAG'],
          ],
          <List<String>>[
            <String>['CHAIN_BROKEN'],
          ],
        ]) {
          for (final bool conn in <bool>[true, false]) {
            expect(
              derivedCellOf(
                p,
                DerivedPairSummary(connected: conn, openCandidates: open),
              ).level,
              isNot(UiLevel.blocked),
            );
          }
        }
      }
    });

    test('자가 보고 칸 — 자동 매매 «해당 없음» · 안내 모드 «점검하지 않음»', () {
      expect(c(selfReportCellOf(OperatingMode.autoTrade)), (
        'NOT_APPLICABLE',
        '해당 없음',
        UiLevel.info,
        false,
      ));
      expect(c(selfReportCellOf(OperatingMode.advisory)), (
        'NOT_CHECKED',
        '점검하지 않음',
        UiLevel.info,
        false,
      ));
    });

    test('headline 갈래 · K3 불변(해당 없음 ⇒ info · OK ⇔ ok · blocked = 브로커만)', () {
      DiagnosticsVm vm(
        OperatingMode m,
        BrokerReconSummary b,
        Map<LedgerPair, DerivedPairSummary> d,
      ) => diagnosticsOf(mode: m, broker: b, derived: d, asOf: _asOf);
      const BrokerReconSummary ran = BrokerReconSummary(reconRan: true);
      const Map<LedgerPair, DerivedPairSummary> none =
          <LedgerPair, DerivedPairSummary>{};
      DerivedPairSummary open(String code) => DerivedPairSummary(
        connected: true,
        openCandidates: <List<String>>[
          <String>[code],
        ],
      );
      final List<(DiagnosticsVm, String)> cases = <(DiagnosticsVm, String)>[
        (vm(OperatingMode.advisory, ran, none), '아직 점검한 칸이 없습니다.'),
        (vm(OperatingMode.autoTrade, ran, none), '점검한 한 칸이 모두 일치합니다.'),
        (
          vm(
            OperatingMode.autoTrade,
            const BrokerReconSummary(reconRan: false),
            <LedgerPair, DerivedPairSummary>{
              LedgerPair.canonGithub: open('ARCHIVE_LAG'),
            },
          ),
          '다섯 칸 중 한 칸이 뒤처집니다. 파생 불일치는 주문을 막지 않습니다.',
        ),
        (
          vm(
            OperatingMode.autoTrade,
            const BrokerReconSummary(
              reconRan: true,
              lastActionCode: 'UNAVAILABLE',
            ),
            none,
          ),
          '다섯 칸 중 한 칸을 확인해 주십시오.',
        ),
        (
          vm(
            OperatingMode.autoTrade,
            const BrokerReconSummary(
              reconRan: true,
              openBlockingAxes: <LedgerAxis>{LedgerAxis.quantity},
            ),
            <LedgerPair, DerivedPairSummary>{
              LedgerPair.canonCalendar: open('CAL_WRITE_FAILED'),
              LedgerPair.canonSupabase: open('PUSH_LAG'),
            },
          ),
          '다섯 칸 중 두 칸이 어긋납니다. 파생 불일치는 주문을 막지 않습니다.',
        ),
        (
          vm(
            OperatingMode.autoTrade,
            const BrokerReconSummary(
              reconRan: true,
              openBlockingAxes: <LedgerAxis>{LedgerAxis.quantity},
            ),
            none,
          ),
          '다섯 칸 중 한 칸이 어긋납니다.',
        ),
        (
          vm(OperatingMode.autoTrade, ran, <LedgerPair, DerivedPairSummary>{
            LedgerPair.canonSupabase: const DerivedPairSummary(connected: true),
            LedgerPair.canonGithub: const DerivedPairSummary(connected: true),
          }),
          '점검한 세 칸이 모두 일치합니다.',
        ),
      ];
      for (final (DiagnosticsVm v, String h) in cases) {
        expect(v.headline, h);
        expect(v.cells.map((DiagnosticCell x) => x.pair), LedgerPair.values);
        for (final DiagnosticCell x in v.cells) {
          if (!x.applicable) expect(x.level, UiLevel.info);
          if (x.applicable) expect(x.stateCode == 'OK', x.level == UiLevel.ok);
          if (x.level == UiLevel.blocked) {
            expect(x.pair, LedgerPair.canonBroker);
          }
        }
      }
      expect(diagnosticsHeadline(const <DiagnosticCell>[]), '아직 점검한 칸이 없습니다.');
    });
  });

  group('사전 · 도우미', () {
    test('원인 코드 라벨 = 열거 전부 · 모르는 코드 = 실패 · 핸드북 링크 = FILL_LAG 만', () {
      expect(kOriginLabels.keys.toSet(), OriginCodes.values);
      expect(() => originChipOf('확인함'), throwsArgumentError);
      expect(
        <String>[
          for (final String code in OriginCodes.values)
            if (originChipOf(code).detailDeepLink != null) code,
        ],
        <String>[OriginCodes.fillLag],
      );
      expect(originChipOf(OriginCodes.manualOrder).tone, ChipTone.neutral);
    });

    test('증거 해시 · delta 후보 · 시각 글자 · AsOf', () {
      expect(evidenceHashOf('{}'), evidenceHashOf('{}'));
      expect(evidenceHashOf('{}'), isNot(evidenceHashOf('{"a":1}')));
      expect(candidatesOfDelta('{"candidates":["A","B"]}'), <String>['A', 'B']);
      expect(candidatesOfDelta('{"kind":"x"}'), isEmpty);
      expect(candidatesOfDelta('[1]'), isEmpty);
      expect(
        kstMinuteText(DateTime.utc(2026, 8, 31, 15, 5)),
        '2026-09-01 00:05',
      );
      expect(kstDateText(DateTime.utc(2026, 8, 31, 14, 59)), '2026-08-31');
      final AsOf a = reconAsOf(
        lastReconUtc: null,
        nowUtc: DateTime.utc(2026, 9, 1, 15),
        prefix: '정정 이력 기준',
      );
      expect(
        (a.observedAt, a.tradeDate, a.source, a.staleAfter, a.label),
        (
          DateTime.utc(2026, 9, 1, 15),
          const TradeDate('2026-09-02'),
          AsOfSource.localSqlite,
          const Duration(seconds: 93600),
          '정정 이력 기준 2026-09-02',
        ),
      );
      final ListResult<LedgerRepairRow> e = emptyLedgerList<LedgerRepairRow>(
        a,
        '정정 이력이 없습니다',
      );
      expect(e.rows, isEmpty);
      expect(
        (e.emptyLabel, e.hasMore, e.emptyKind),
        ('정정 이력이 없습니다', false, EmptyKind.noData),
      );
      expect(
        reconAsOf(
          lastReconUtc: DateTime.utc(2026, 9, 1),
          nowUtc: DateTime.utc(2026, 9, 3),
        ).observedAt,
        DateTime.utc(2026, 9, 1),
      );
      expect(routeOf(DiffSeverity.blocking), RepairRoute.approval);
      expect(routeLabelOf(RepairRoute.x1Emergency), '긴급 경로');
      expect(severityLabelOf(DiffSeverity.blocking), '주문 차단');
    });

    test('StoredLedgerDiff.fromColumns — 모르는 열거 = FormatException · applicable 0 = false', () {
      Map<String, Object?> cols({
        String pair = 'CANON_BROKER',
        Object? applicable = 1,
      }) => <String, Object?>{
        'diff_id': 'd',
        'pair': pair,
        'axis': 'CASH',
        'authored_date': '2026-08-31',
        'delta': '{}',
        'delta_label': 'x',
        'severity': 'OBSERVATIONAL',
        'status': 'ACCEPTED',
        'detected_at': '2026-08-31T00:00:00.000Z',
        'applicable': applicable,
      };
      final StoredLedgerDiff s = StoredLedgerDiff.fromColumns(
        cols(),
        closedAtUtc: _now,
      );
      expect(
        (
          s.pair,
          s.axis,
          s.severity,
          s.status,
          s.applicable,
          s.closedAtUtc,
          s.authoredDate,
        ),
        (
          LedgerPair.canonBroker,
          LedgerAxis.cash,
          DiffSeverity.observational,
          DiffStatus.accepted,
          true,
          _now,
          const TradeDate('2026-08-31'),
        ),
      );
      expect(
        StoredLedgerDiff.fromColumns(cols(applicable: 0)).applicable,
        isFalse,
      );
      expect(
        () => StoredLedgerDiff.fromColumns(cols(pair: 'CANON_X')),
        throwsFormatException,
      );
    });
  });
}
