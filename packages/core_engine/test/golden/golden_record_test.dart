// 골든 기기 실행 기록 · 결과 문장 · S10 카드 · O-04 ④ 사실(E11o-d · 설계 13 §8 R167).
//
// 🔴 카드 · 결과 글자 = 표본(`m9/diagnostics_screen*` · `m9/selftest_action_results`)에서 «(합성) » 만 뺀 그대로.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _fx = '../domain_contracts/fixtures/m9';

Map<String, Object?> _row(String file) =>
    ((jsonDecode(File('$_fx/$file').readAsStringSync())
                    as Map<String, Object?>)['rows']!
                as List<Object?>)
            .first!
        as Map<String, Object?>;

SelfTestCard _fixtureGolden(String file) =>
    SelfTestCard.fromJson(_row(file)['golden']! as Map<String, Object?>);

GoldenRunResult _result({int passed = 349, int total = 349}) => GoldenRunResult(
  digest: 'd1',
  passed: passed,
  total: total,
  failures: <GvFailure>[
    for (int i = 0; i < total - passed; i++) GvFailure('GV-1a', 'x'),
  ],
  complete: true,
);

/// 🆕 미결 237 — 앱 설치 판(시험 고정).
const String _b = '0.1.0+1@1732400000000';

/// 표본 «마지막 실행 11-17 09:00»(KST) = 2026-11-17T00:00Z.
final DateTime _fixtureRun = DateTime.utc(2026, 11, 17);

GoldenRecordView _rec({bool ok = true, String digest = 'd1', int p = 349}) =>
    GoldenRecordView(
      runAtUtc: _fixtureRun,
      ok: ok,
      digest: digest,
      passed: p,
      total: 349,
    );

void main() {
  group('S10 골든 카드 = 표본 그대로', () {
    test('판정 보류(실행기 전 · 자산 전) = 기본 표본', () {
      expect(
        goldenSelfTestCardOf(const GoldenCardFacts.pending()),
        _fixtureGolden('diagnostics_screen.json'),
      );
      expect(
        goldenSelfTestCardOf(
          GoldenCardFacts(
            ready: false,
            currentDigest: 'd1',
            last: _rec(),
            running: false,
            canRun: true,
          ),
        ),
        _fixtureGolden('diagnostics_screen.json'),
        reason: '«전량» 아님 = 기록이 있어도 판정 보류 · 버튼 부재',
      );
    });

    test('실행 중 = 표본(_running)', () {
      expect(
        goldenSelfTestCardOf(
          GoldenCardFacts(
            ready: true,
            currentDigest: 'd1',
            last: _rec(),
            running: true,
            canRun: true,
          ),
        ),
        _fixtureGolden('diagnostics_screen_running.json'),
      );
    });

    test('통과 = 표본(_diff 버튼 있음 · _locked 버튼 없음)', () {
      GoldenCardFacts f(bool canRun) => GoldenCardFacts(
        ready: true,
        currentDigest: 'd1',
        last: _rec(),
        running: false,
        canRun: canRun,
      );
      expect(
        goldenSelfTestCardOf(f(true)),
        _fixtureGolden('diagnostics_screen_diff.json'),
      );
      expect(
        goldenSelfTestCardOf(f(false)),
        _fixtureGolden('diagnostics_screen_locked.json'),
      );
    });

    test('기록 없음 · 앱 바뀜 · 불일치', () {
      final SelfTestCard never = goldenSelfTestCardOf(
        const GoldenCardFacts(
          ready: true,
          currentDigest: 'd1',
          last: null,
          running: false,
          canRun: true,
        ),
      );
      expect(never.statusLabel, GoldenSelfTestTexts.never);
      expect(never.level, UiLevel.watch);
      expect(never.runAction?.id, SettingsActionId.selftestGoldenRun);
      expect(never.runAction?.args, isEmpty);

      final SelfTestCard stale = goldenSelfTestCardOf(
        GoldenCardFacts(
          ready: true,
          currentDigest: 'd2',
          last: _rec(),
          running: false,
          canRun: true,
        ),
      );
      expect(stale.statusLabel, GoldenSelfTestTexts.stale);
      expect(stale.level, UiLevel.watch);
      expect(stale.lastRunText, '마지막 실행 11-17 09:00');
      expect(stale.summaryText, isNull, reason: '옛 묶음의 통과를 지금 통과로 말하지 않는다');

      final SelfTestCard bad = goldenSelfTestCardOf(
        GoldenCardFacts(
          ready: true,
          currentDigest: 'd1',
          last: _rec(ok: false, p: 347),
          running: false,
          canRun: true,
        ),
      );
      expect(bad.statusLabel, GoldenSelfTestTexts.failed);
      expect(bad.level, UiLevel.act);
      expect(bad.summaryText, '통과 347/전체 349');
    });
  });

  group('결과 문장 = 표본(selftest_action_results)', () {
    Map<String, Object?> fx(String id) =>
        ((jsonDecode(
                  File('$_fx/selftest_action_results.json').readAsStringSync(),
                ) as Map<String, Object?>)['rows']!
                as List<Object?>)
            .cast<Map<String, Object?>>()
            .firstWhere((Map<String, Object?> r) => r['action_run_id'] == id);
    String plain(Object? h) => (h! as String).replaceFirst('(합성) ', '');

    test('전량 통과 = OK · 불일치 = ACT · 코드 null', () {
      final ActionResult ok = selftestGoldenResultOf(
        actionRunId: 'a1',
        result: _result(),
      );
      expect(ok.id, SettingsActionId.selftestGoldenRun);
      expect(ok.level, UiLevel.ok);
      expect(ok.headline, plain(fx('ar_s10_01')['headline']));
      expect(ok.reasonCode, isNull);
      expect(ok.retryable, isFalse);
      final ActionResult act = selftestGoldenResultOf(
        actionRunId: 'a2',
        result: _result(passed: 348),
      );
      expect(act.level, UiLevel.act);
      expect(act.headline, plain(fx('ar_s10_02')['headline']));
      expect(act.reasonCode, isNull);
    });

    test('미완성 실행 결과는 «통과» 가 아니다', () {
      final ActionResult r = selftestGoldenResultOf(
        actionRunId: 'a3',
        result: const GoldenRunResult(
          digest: 'd',
          passed: 3,
          total: 3,
          failures: <GvFailure>[],
          complete: false,
        ),
      );
      expect(r.level, UiLevel.act);
    });
  });

  group('기록 행 ↔ 기록', () {
    test('JSON 왕복 · OK/FAILED · 꼴 틀림 = null', () {
      final String j = goldenDiscrepanciesJson(
        _result(passed: 348),
        appBuild: _b,
      );
      final Map<String, Object?> m = jsonDecode(j) as Map<String, Object?>;
      expect(m['failed'], <String>['GV-1a']);
      final GoldenRecordView? r = goldenRecordOf(
        runAt: '2026-11-17T00:00:00.000Z',
        actionTaken: kGoldenFailed,
        discrepancies: j,
      );
      expect(r?.ok, isFalse);
      expect(r?.passed, 348);
      expect(r?.total, 349);
      // 🔴 미결 237 — 기록 지문 = 앱 판 지문(묶음 지문 'd1' 그대로가 아니다) · 재료 = vectors · build.
      expect(r?.digest, goldenRunDigestOf(vectorsDigest: 'd1', appBuild: _b));
      expect(r?.digest, isNot('d1'));
      expect(m['vectors'], 'd1');
      expect(m['build'], _b);
      expect(r?.runAtUtc, _fixtureRun);
      expect(
        goldenRecordOf(
          runAt: '2026-11-17T00:00:00Z',
          actionTaken: kGoldenOk,
          discrepancies: goldenDiscrepanciesJson(_result(), appBuild: _b),
        )?.ok,
        isTrue,
      );
      expect(
        goldenRecordOf(
          runAt: '2026-11-17T00:00:00Z',
          actionTaken: 'INTEGRITY_OK',
          discrepancies: goldenDiscrepanciesJson(_result(), appBuild: _b),
        ),
        isNull,
      );
      expect(
        goldenRecordOf(
          runAt: '2026-11-17T00:00:00Z',
          actionTaken: kGoldenOk,
          discrepancies: '{',
        ),
        isNull,
      );
      expect(
        goldenRecordOf(
          runAt: '2026-11-17T00:00:00Z',
          actionTaken: kGoldenOk,
          discrepancies: goldenDiscrepanciesJson(
            _result(passed: 348),
            appBuild: _b,
          ),
        ),
        isNull,
        reason: 'OK 인데 통과 ≠ 전체 = 읽지 못한 기록',
      );
    });

    test('🔴 미결 237(G-2) — 앱 판 지문: 같은 벡터 · 다른 판 = 다른 지문 · 같은 재료 = 같은 지문 · 빈 재료 = 던짐 · 옛 기록(묶음 지문만) = stale', () {
      final String a = goldenRunDigestOf(vectorsDigest: 'd1', appBuild: _b);
      expect(a, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(goldenRunDigestOf(vectorsDigest: 'd1', appBuild: _b), a);
      expect(
        goldenRunDigestOf(vectorsDigest: 'd1', appBuild: '0.1.0+1@1'),
        isNot(a),
        reason: '엔진 코드만 바뀐 업데이트(벡터 무변경) = 다른 지문',
      );
      expect(
        goldenRunDigestOf(vectorsDigest: 'd2', appBuild: _b),
        isNot(a),
        reason: '벡터가 바뀌면 다른 지문(전과 같음)',
      );
      // 재료 경계가 섞이지 않는다(NUL 구분).
      expect(
        goldenRunDigestOf(vectorsDigest: 'd1x', appBuild: 'y'),
        isNot(goldenRunDigestOf(vectorsDigest: 'd1', appBuild: 'xy')),
      );
      expect(
        () => goldenRunDigestOf(vectorsDigest: 'd1', appBuild: ''),
        throwsArgumentError,
      );
      expect(
        () => goldenRunDigestOf(vectorsDigest: '', appBuild: _b),
        throwsArgumentError,
      );
      // 이 고침 전 기록(`digest` = 묶음 지문 'd1') → 지금 앱 판 지문과 다름 = S10 «앱이 바뀌어…» · ④ (0, 전체).
      final GoldenRecordView old = _rec();
      expect(
        goldenSelfTestCardOf(
          GoldenCardFacts(
            ready: true,
            currentDigest: a,
            last: old,
            running: false,
            canRun: true,
          ),
        ).statusLabel,
        GoldenSelfTestTexts.stale,
      );
      expect(goldenSelftestFactOf(currentDigest: a, total: 349, last: old), (
        0,
        349,
      ));
      // 새 꼴 기록(같은 판) = 통과.
      final GoldenRecordView now = goldenRecordOf(
        runAt: '2026-11-17T00:00:00Z',
        actionTaken: kGoldenOk,
        discrepancies: goldenDiscrepanciesJson(_result(), appBuild: _b),
      )!;
      expect(goldenSelftestFactOf(currentDigest: a, total: 349, last: now), (
        349,
        349,
      ));
    });
  });

  group('O-04 ④ 사실', () {
    test('지문 같음 = 기록 값 · 다름 · 없음 = (0, 전체) · 모름 = null', () {
      expect(
        goldenSelftestFactOf(currentDigest: 'd1', total: 349, last: _rec()),
        (349, 349),
      );
      expect(
        goldenSelftestFactOf(
          currentDigest: 'd1',
          total: 349,
          last: _rec(ok: false, p: 340),
        ),
        (340, 349),
      );
      expect(
        goldenSelftestFactOf(currentDigest: 'd2', total: 349, last: _rec()),
        (0, 349),
      );
      expect(
        goldenSelftestFactOf(currentDigest: 'd1', total: 349, last: null),
        (0, 349),
      );
      expect(
        goldenSelftestFactOf(currentDigest: null, total: 349, last: _rec()),
        isNull,
      );
      expect(
        goldenSelftestFactOf(currentDigest: 'd1', total: 0, last: _rec()),
        isNull,
      );
    });

    test('마지막 실행 줄 = 한국 시각', () {
      expect(
        goldenLastRunText(DateTime.utc(2026, 11, 17, 15, 5)),
        '마지막 실행 11-18 00:05',
      );
      expect(goldenCountText(1, 2), '통과 1/전체 2');
    });
  });
}
