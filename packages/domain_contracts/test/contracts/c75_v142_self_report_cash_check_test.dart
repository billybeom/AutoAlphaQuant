// C-75 실사 현금 판정 원장 기록 — 01 §51
// (🆕 계약 v1.42 · 발주자 위임 2026-11-14 — 권고대로 · K373~ · 01 §8 미결 256 · 13 §8 R278 D9 · R281).
//
// 정의: 「`L-3` 정기 실사 한 건의 현금 축 판정을 제출 순간 실사 행에 같이 적는다 — 배치 F `self_report_balance` +=
//        `cash_check`(NOT NULL · 3값 · «대조함 ⇔ 허용 오차 값» 짝) · `cash_tolerance_krw`(0 이상 · 대조함일 때만) ·
//        계약 열거 `SelfReportCashCheck` 3 = CHECK · 기존 9칸 무변경 · 기본값 0(엔진이 늘 적는다) · 화면 · DTO 0」.
//   ① 판 · 표본 ② 칸 · 차례 ③ CHECK · 짝 ④ 열거 ⑤ 기본값 · 수치 0 ⑥ 화면 · DTO 경계.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

String _batchF() =>
    File('${ddlDir.path}/batch_f_x7_advisory.sql').readAsStringSync();

/// 주석(`-- …` 줄 끝까지)을 뺀 배치 F.
String _batchFCode() => _batchF().replaceAll(RegExp(r'--[^\n]*'), '');

/// `self_report_balance` 의 `CREATE TABLE` 본문(주석 뺌 · 괄호 안).
String _body() {
  final RegExpMatch? m = RegExp(
    r'CREATE TABLE IF NOT EXISTS self_report_balance \(([\s\S]*?)\n\);',
  ).firstMatch(_batchFCode());
  expect(m, isNotNull);
  return m!.group(1)!;
}

/// 본문의 칸 이름(차례 그대로 · 이어지는 CHECK 줄 뺌).
List<String> _columns() => <String>[
  for (final String line in _body().split('\n'))
    if (RegExp(r'^    ([a-z_]+)\s+(TEXT|REAL|INTEGER)\b').hasMatch(line))
      RegExp(r'^    ([a-z_]+)').firstMatch(line)!.group(1)!,
];

/// 한 칸의 정의(그 칸 줄 + 이어지는 들여쓴 줄 · 공백 하나로).
String _columnDef(String column) {
  final List<String> lines = _body().split('\n');
  final int at = lines.indexWhere(
    (String l) => RegExp('^    $column\\s').hasMatch(l),
  );
  expect(at, greaterThanOrEqualTo(0), reason: column);
  final StringBuffer b = StringBuffer(lines[at]);
  for (int i = at + 1; i < lines.length; i++) {
    if (RegExp(r'^    [a-z_]+\s').hasMatch(lines[i])) break;
    b.write(' ${lines[i]}');
  }
  return b.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

void main() {
  group('C-75 실사 현금 판정 원장 기록 (01 §51)', () {
    test('C-75 ① 판 · 표본 — 1.42.0 · 402(버전 줄만) · 봉투 판 = 계약 판', () {
      expect(contractVersion, '1.42.0');
      expect(FixturePaths.all, hasLength(402));
      expect(allFixtureFilesOnDisk(), hasLength(402));
      for (final String path in FixturePaths.all) {
        final Map<String, Object?> meta =
            (jsonDecode(readFixture(path)) as Map<String, Object?>)['meta']!
                as Map<String, Object?>;
        expect(meta['contract_version'], contractVersion, reason: path);
      }
    });

    test('C-75 ② 칸 · 차례 — 기존 9칸 그대로 뒤에 판정 2칸', () {
      expect(_columns(), <String>[
        'report_id',
        'as_of_trade_date',
        'account_alias',
        'session_started_at',
        'cash_krw',
        'declared_complete',
        'device_id',
        'command_id',
        'reported_at',
        'cash_check',
        'cash_tolerance_krw',
      ]);
      expect(_columnDef('cash_check'), startsWith('cash_check TEXT NOT NULL'));
      expect(
        _columnDef('cash_tolerance_krw'),
        startsWith('cash_tolerance_krw REAL'),
      );
      expect(
        _columnDef('cash_tolerance_krw'),
        isNot(contains('NOT NULL')),
        reason: '대조하지 않은 실사 = 허용 오차 없음(null)',
      );
    });

    test('C-75 ③ CHECK — 판정 3값 · «대조함 ⇔ 허용 오차 값» 짝 · 허용 오차 0 이상', () {
      final List<CheckConstraint> checks = <CheckConstraint>[
        for (final CheckConstraint c in parseCheckConstraints(
          File('${ddlDir.path}/batch_f_x7_advisory.sql'),
        ))
          if (c.table == 'self_report_balance') c,
      ];
      expect(checks.map((CheckConstraint c) => c.column).toSet(), <String>{
        'declared_complete',
        'cash_check',
      });
      expect(
        checks
            .singleWhere((CheckConstraint c) => c.column == 'cash_check')
            .values
            .toSet(),
        <String>{'COMPARED', 'NO_TOLERANCE', 'LEDGER_UNKNOWN'},
      );
      expect(
        _columnDef('cash_check'),
        contains(
          "((cash_check = 'COMPARED') = (cash_tolerance_krw IS NOT NULL))",
        ),
      );
      expect(
        _columnDef('cash_tolerance_krw'),
        contains(
          'CHECK (cash_tolerance_krw IS NULL OR cash_tolerance_krw >= 0)',
        ),
      );
    });

    test('C-75 ④ 열거 — 3값 · wire = CHECK · 차례 고정', () {
      expect(
        SelfReportCashCheck.values.map((SelfReportCashCheck c) => c.wire),
        <String>['COMPARED', 'NO_TOLERANCE', 'LEDGER_UNKNOWN'],
      );
      expect(SelfReportCashCheck.compared.wire, 'COMPARED');
      expect(SelfReportCashCheck.noTolerance.wire, 'NO_TOLERANCE');
      expect(SelfReportCashCheck.ledgerUnknown.wire, 'LEDGER_UNKNOWN');
    });

    test('C-75 ⑤ 기본값 · 수치 0 — 엔진이 늘 적는다 · 허용 오차 값은 계약에 없다', () {
      expect(_columnDef('cash_check'), isNot(contains('DEFAULT')));
      expect(_columnDef('cash_tolerance_krw'), isNot(contains('DEFAULT')));
      // 허용 오차 값 = 운영 설정 `self_report_cash_tolerance_krw`(발주자 수치 대기) — 계약 · DDL 에 숫자 0.
      expect(
        RegExp(r'\d').hasMatch(
          _columnDef('cash_tolerance_krw')
              .replaceAll('cash_tolerance_krw >= 0', ''),
        ),
        isFalse,
      );
      final String all = _batchF();
      expect(all, contains('해시 모집단 밖'));
      expect(all, contains('hash_format_version` 무변경'));
    });

    test('C-75 ⑥ 경계 — 판정 열거는 화면 · DTO · 표본이 쓰지 않는다(엔진 · 원장 전용)', () {
      final Directory pkgs = Directory('${repoRoot.path}/packages');
      final List<String> hits = <String>[
        for (final FileSystemEntity e in pkgs.listSync(recursive: true))
          if (e is File &&
              e.path.endsWith('.dart') &&
              !e.path.contains('${Platform.pathSeparator}.dart_tool') &&
              (e.path.contains('${Platform.pathSeparator}ui_') ||
                  e.path
                      .replaceAll(r'\', '/')
                      .contains('domain_contracts/lib/src/dto/')) &&
              e.readAsStringSync().contains('SelfReportCashCheck'))
            e.path,
      ];
      expect(hits, isEmpty);
      for (final String path in FixturePaths.all) {
        expect(readFixture(path), isNot(contains('cash_check')), reason: path);
      }
    });
  });
}
