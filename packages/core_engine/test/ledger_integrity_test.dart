// E13c1 — 체인 자가 대조 순수(설계 13 §8 R58 C2 · C3) · 쌍 심각도 · 원인 코드 화이트리스트(C7 · C8).
//
// 🔵 잡는 것: ① 스탬프 0 = 통과 · 마지막 스탬프 뒤 행 = 대상 밖 ② 첫 스탬프 앞 행 = 소급 삽입 ③ 형식 판 · 날 빠짐 ·
//    재계산 다름 · 체인 다름(행과 day_hash 를 함께 고쳐도) ④ 첫 어긋난 날 · 대조한 날 수 · 요약 JSON(금액 0)
//    ⑤ 파생 · 자가 보고 = 늘 관측 · 브로커 = 수량 · 체결만 차단 ⑥ 쌍마다 원인 코드 = 열거 계열 그대로.
import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Map<String, List<String>> _day(List<String> exec) => <String, List<String>>{
  if (exec.isNotEmpty) 'executions': exec,
};

/// 날 → 줄로 스탬프 체인을 만든다(스탬퍼와 같은 셈).
List<StoredDayStamp> _stamp(
  List<String> days,
  Map<String, Map<String, List<String>>> lines,
) {
  String chain = kChainGenesis;
  return <StoredDayStamp>[
    for (final String d in days)
      () {
        final String day = dayHashOf(
          lines[d] ?? const <String, List<String>>{},
        );
        chain = chainHashOf(chain, day);
        return StoredDayStamp(
          authoredDate: d,
          dayHash: day,
          chainHash: chain,
          hashFormatVersion: hashFormatVersion,
        );
      }(),
  ];
}

StoredDayStamp _with(
  StoredDayStamp s, {
  String? dayHash,
  String? chainHash,
  int? version,
}) => StoredDayStamp(
  authoredDate: s.authoredDate,
  dayHash: dayHash ?? s.dayHash,
  chainHash: chainHash ?? s.chainHash,
  hashFormatVersion: version ?? s.hashFormatVersion,
);

void main() {
  const List<String> days = <String>['2026-11-02', '2026-11-03', '2026-11-04'];
  late Map<String, Map<String, List<String>>> lines;
  late List<StoredDayStamp> stamps;
  setUp(() {
    lines = <String, Map<String, List<String>>>{
      '2026-11-02': _day(<String>['{"a":1}', '{"a":2}']),
      // 11-03 = 행 없는 날(빈 입력의 해시).
      '2026-11-04': _day(<String>['{"a":3}']),
    };
    stamps = _stamp(days, lines);
  });

  (String?, String?, int, String?) shape(LedgerIntegrityVerdict v) =>
      (v.reason?.code, v.firstBadDate, v.daysChecked, v.checkedThrough);

  group('verifyLedgerChain(R58 C2 · C3)', () {
    test('스탬프 0 = 통과(검사할 것 없음 · 행이 있어도 아직 스탬프 전)', () {
      final LedgerIntegrityVerdict v = verifyLedgerChain(
        const <StoredDayStamp>[],
        lines,
      );
      expect((v.ok, shape(v)), (true, (null, null, 0, null)));
    });

    test('일치 = 날 수 · 마지막 날 · 마지막 스탬프 뒤 행은 대상 밖', () {
      expect(shape(verifyLedgerChain(stamps, lines)), (
        null,
        null,
        3,
        '2026-11-04',
      ));
      lines['2026-11-05'] = _day(<String>['{"later":1}']);
      expect(verifyLedgerChain(stamps, lines).ok, isTrue);
    });

    test('🔴 첫 스탬프 앞 날의 행 = 소급 삽입', () {
      // 넣은 차례와 날 차례가 달라도 가장 앞 날.
      lines['2026-10-31'] = _day(<String>['{"old":2}']);
      lines['2026-10-30'] = _day(<String>['{"old":1}']);
      expect(shape(verifyLedgerChain(stamps, lines)), (
        'ROWS_BEFORE_FIRST_STAMP',
        '2026-10-30',
        0,
        null,
      ));
    });

    test('🔴 지난날 행을 고침 = 재계산 다름 · 그날까지 센 수', () {
      lines['2026-11-04'] = _day(<String>['{"a":4}']);
      expect(shape(verifyLedgerChain(stamps, lines)), (
        'DAY_HASH_MISMATCH',
        '2026-11-04',
        2,
        '2026-11-03',
      ));
      lines['2026-11-04'] = _day(<String>['{"a":3}']);
      lines['2026-11-03'] = _day(<String>['{"new":1}']);
      expect(shape(verifyLedgerChain(stamps, lines)), (
        'DAY_HASH_MISMATCH',
        '2026-11-03',
        1,
        '2026-11-02',
      ));
    });

    test('🔴 행과 day_hash 를 함께 고쳐도 체인이 잡는다', () {
      lines['2026-11-02'] = _day(<String>['{"a":9}']);
      stamps[0] = _with(stamps[0], dayHash: dayHashOf(lines['2026-11-02']!));
      expect(shape(verifyLedgerChain(stamps, lines)), (
        'CHAIN_BROKEN',
        '2026-11-02',
        0,
        null,
      ));
    });

    test('🔴 체인 칸만 고침 = 체인 다름(그날)', () {
      stamps[1] = _with(stamps[1], chainHash: stamps[2].chainHash);
      expect(shape(verifyLedgerChain(stamps, lines)), (
        'CHAIN_BROKEN',
        '2026-11-03',
        1,
        '2026-11-02',
      ));
    });

    test('🔴 스탬프 날이 빠짐 = 날 빠짐(빠진 날)', () {
      stamps.removeAt(1);
      expect(shape(verifyLedgerChain(stamps, lines)), (
        'DATE_GAP',
        '2026-11-03',
        1,
        '2026-11-02',
      ));
    });

    test('🔴 형식 판이 다름 · 판 인자', () {
      stamps[2] = _with(stamps[2], version: hashFormatVersion + 1);
      expect(shape(verifyLedgerChain(stamps, lines)), (
        'FORMAT_VERSION',
        '2026-11-04',
        2,
        '2026-11-03',
      ));
      expect(
        verifyLedgerChain(
          _stamp(days, lines),
          lines,
          formatVersion: hashFormatVersion + 1,
        ).reason,
        LedgerIntegrityReason.formatVersion,
      );
    });

    test('요약 JSON = 날 · 사유 · 날 수만', () {
      lines['2026-11-02'] = _day(<String>['{"a":0}']);
      final Map<String, dynamic> j = jsonDecode(
        verifyLedgerChain(stamps, lines).summaryJson(),
      ) as Map<String, dynamic>;
      expect(j, <String, Object?>{
        'kind': 'LEDGER_INTEGRITY',
        'ok': false,
        'reason': 'DAY_HASH_MISMATCH',
        'first_bad_date': '2026-11-02',
        'days_checked': 0,
        'checked_through': null,
      });
      expect(
        (jsonDecode(verifyLedgerChain(_stamp(days, lines), lines).summaryJson())
            as Map<String, dynamic>)['ok'],
        isTrue,
      );
    });

    test('사유 코드 = 7 · 알림 제안 코드', () {
      expect(
        LedgerIntegrityReason.values.map((LedgerIntegrityReason r) => r.code),
        <String>[
          'FORMAT_VERSION',
          'DATE_GAP',
          'CHAIN_BROKEN',
          'DAY_HASH_MISMATCH',
          'ROWS_BEFORE_FIRST_STAMP',
          'ATTRIBUTION',
          'SQLITE_INTEGRITY',
        ],
      );
      expect(kLedgerIntegrityAlertCode, 'LEDGER_INTEGRITY_BROKEN');
    });
  });

  group('쌍 심각도(R58 C8) · 원인 코드 쓰기 화이트리스트(C7)', () {
    test('🔴 차단 = 브로커 수량 · 체결뿐 — 파생 · 자가 보고 = 어느 축이든 관측', () {
      final List<(LedgerPair, LedgerAxis)> blocking =
          <(LedgerPair, LedgerAxis)>[
            for (final LedgerPair p in LedgerPair.values)
              for (final LedgerAxis a in LedgerAxis.values)
                if (diffSeverityFor(p, a) == DiffSeverity.blocking) (p, a),
          ];
      expect(blocking, <(LedgerPair, LedgerAxis)>[
        (LedgerPair.canonBroker, LedgerAxis.quantity),
        (LedgerPair.canonBroker, LedgerAxis.executionRow),
      ]);
    });

    test('쌍마다 원인 코드 = 열거 계열 그대로 · 옛 CORP_ACTION 없음 · 합 = writable', () {
      expect(
        writableOriginCodesFor(LedgerPair.canonBroker),
        kReconClearOriginCodes,
      );
      expect(
        writableOriginCodesFor(LedgerPair.canonBroker),
        isNot(contains(OriginCodes.corpActionLegacy)),
      );
      expect(
        writableOriginCodesFor(LedgerPair.canonBroker),
        containsAll(<String>[
          OriginCodes.corporateAction,
          OriginCodes.manualOrder,
          OriginCodes.advisoryFill,
        ]),
      );
      for (final LedgerPair p in <LedgerPair>[
        LedgerPair.canonSupabase,
        LedgerPair.canonGithub,
        LedgerPair.canonCalendar,
      ]) {
        expect(writableOriginCodesFor(p), OriginCodes.derived);
      }
      expect(
        writableOriginCodesFor(LedgerPair.canonSelfReport),
        OriginCodes.x7,
      );
      expect(<String>{
        for (final LedgerPair p in LedgerPair.values)
          ...writableOriginCodesFor(p),
      }, OriginCodes.writable);
    });
  });
}
