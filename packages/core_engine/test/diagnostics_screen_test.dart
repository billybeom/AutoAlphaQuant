// E11p4k — M9 S10 진단 감싸개 · 무결성 결과(설계 13 §8 R160) — 기대값 = 계약 표본(`m9/diagnostics_screen*` · `m9/selftest_action_results`).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Map<String, dynamic> _row(String name) =>
    ((jsonDecode(
                  File('../domain_contracts/fixtures/m9/$name')
                      .readAsStringSync(),
                ) as Map<String, dynamic>)['rows']
                as List<Object?>)
            .first!
        as Map<String, dynamic>;

final DateTime _now = DateTime.utc(2026, 11, 18, 6);
final DateTime _lastOk = DateTime.utc(2026, 11, 17, 18, 10); // KST 11-18 03:10

void main() {
  test(
    '🔴 표본 기본(지금 실물 꼴) = 골든 판정 보류 · 버튼 부재 · 무결성 마지막 검증 · 버튼 · 보드 그대로 · 권장 배너',
    () {
      final DiagnosticsScreenVm want = DiagnosticsScreenVm.fromJson(
        _row('diagnostics_screen.json'),
      );
      final DiagnosticsScreenVm got = diagnosticsScreenVmOf(
        DiagnosticsScreenFacts(
          board: want.board,
          lastIntegrityOkUtc: _lastOk,
          integrityBlocked: false,
          openDiffs: false,
          canRun: true,
          nowUtc: _now,
        ),
      );
      expect(got, want);
    },
  );

  test('🔴 열린 차이 = 차이 상세 링크(글자 · 목적지 = 엔진) · 버튼 낼 수 없음 = 버튼 부재', () {
    final DiagnosticsScreenVm locked = DiagnosticsScreenVm.fromJson(
      _row('diagnostics_screen_locked.json'),
    );
    final DiagnosticsScreenVm got = diagnosticsScreenVmOf(
      DiagnosticsScreenFacts(
        board: locked.board,
        lastIntegrityOkUtc: _lastOk,
        integrityBlocked: false,
        openDiffs: true,
        canRun: false,
        nowUtc: _now,
      ),
    );
    expect(got.diffsLink, locked.diffsLink);
    expect(got.integrity.runAction, isNull);
    expect(got.golden.runAction, isNull);
  });

  test('🔴 무결성 카드 — 기록 없음 = WATCH «아직 검증하지 않았습니다» · 대조 실패로 막힘 = BLOCKED', () {
    final DiagnosticsVm board = DiagnosticsScreenVm.fromJson(
      _row('diagnostics_screen.json'),
    ).board;
    DiagnosticsScreenVm vm({DateTime? ok, bool blocked = false}) =>
        diagnosticsScreenVmOf(
          DiagnosticsScreenFacts(
            board: board,
            lastIntegrityOkUtc: ok,
            integrityBlocked: blocked,
            openDiffs: false,
            canRun: true,
            nowUtc: _now,
          ),
        );
    expect(vm().integrity.statusLabel, DiagnosticsScreenTexts.integrityNever);
    expect(vm().integrity.level, UiLevel.watch);
    expect(vm(ok: _lastOk, blocked: true).integrity.level, UiLevel.blocked);
    expect(vm(blocked: true).integrity.level, UiLevel.blocked);
    expect(vm(ok: _lastOk).integrity.level, UiLevel.ok);
  });

  test(
    '🔴 무결성 결과 = 표본 글자에서 «(합성) » 만 뺀 그대로(일치 OK · 사유 7 BLOCKED · 코드 = 사유)',
    () {
      int seen = 0;
      for (final Map<String, dynamic> r
          in ((jsonDecode(
                    File(
                      '../domain_contracts/fixtures/m9/selftest_action_results.json',
                    ).readAsStringSync(),
                  ) as Map<String, dynamic>)['rows']
                  as List<Object?>)
              .cast<Map<String, dynamic>>()) {
        final ActionResult want = ActionResult.fromJson(r);
        if (want.id != SettingsActionId.selftestIntegrityRun ||
            want.reasonCode == 'BIOMETRIC_UNAVAILABLE') {
          continue;
        }
        seen++;
        final LedgerIntegrityReason? reason = want.reasonCode == null
            ? null
            : LedgerIntegrityReason.values.singleWhere(
                (LedgerIntegrityReason x) => x.code == want.reasonCode,
              );
        final ActionResult got = selftestIntegrityResultOf(
          actionRunId: want.actionRunId,
          reason: reason,
        );
        expect(
          got,
          want.copyWith(headline: want.headline.replaceFirst('(합성) ', '')),
          reason: '${want.reasonCode}',
        );
      }
      expect(seen, 1 + LedgerIntegrityReason.values.length);
    },
  );
}
