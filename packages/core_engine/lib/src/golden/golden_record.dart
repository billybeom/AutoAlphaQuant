// 골든 기기 실행 기록 · 결과 문장 · S10 카드 · O-04 ④ 사실(E11o-d · 설계 13 §8 R167 · R161 O4 · O6 · O7 · 01 §33 K114 · 미결 198 · 201).
//
// 🔴 기록 = `reconciliation_log` 1행(해시 모집단 밖 · 무결성 검사 선례) — `recon_id` = `gv-{시각}#{일련}` ·
//    `action_taken` = `GOLDEN_OK` / `GOLDEN_FAILED` · `discrepancies` = 결과 JSON(지문 · 통과 · 전체 · 실패 id).
//    다른 읽기(브로커 대사 `rc-` · 무결성 `INTEGRITY_OK`)는 접두 · 값으로 걸러 읽어 섞이지 않는다.
// 🔴 ④ 사실 = 지금 묶음 지문과 같은 마지막 기록의 (통과, 전체) — 앱이 업데이트돼 묶음이 바뀌면 (0, 전체)로 돌아간다(R161 O7).
// 🔴 글자 = 표본(`m9/diagnostics_screen*` · `m9/selftest_action_results`)에서 «(합성) » 만 뺀 그대로 · «n/m» = 엔진 글자 안에서만.
// 🔴 실행기가 «전량»이 아니면(`complete` 거짓) 카드 = «판정 보류» · 버튼 부재(부분 실행으로 «통과»를 지어내지 않는다 · R161 O5).

import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:domain_contracts/domain_contracts.dart'
    show
        ActionResult,
        SelfTestCard,
        SettingsActionCall,
        SettingsActionId,
        UiLevel;

import 'golden_runner.dart' show GoldenRunResult, GvFailure;

/// `reconciliation_log.action_taken` — 전량 통과.
const String kGoldenOk = 'GOLDEN_OK';

/// `reconciliation_log.action_taken` — 실패 있음.
const String kGoldenFailed = 'GOLDEN_FAILED';

/// `reconciliation_log.recon_id` 접두.
const String kGoldenReconPrefix = 'gv-';

/// 골든 셀프테스트 글자(엔진).
abstract final class GoldenSelfTestTexts {
  /// 카드 제목.
  static const String title = '골든벡터 셀프테스트';

  /// 실행기 «전량» 전 · 자산을 읽기 전.
  static const String pending = '골든벡터 판정 보류';

  /// [pending] 요약.
  static const String pendingSummary = '실행기를 준비하는 중이라 아직 돌릴 수 없습니다.';

  /// 기록 없음.
  static const String never = '아직 실행하지 않았습니다';

  /// 마지막 기록이 다른 묶음(앱 업데이트 뒤).
  static const String stale = '앱이 바뀌어 다시 돌려야 합니다';

  /// 실행 중.
  static const String running = '실행 중';

  /// 통과.
  static const String passed = '통과';

  /// 통과 요약.
  static const String passedSummary = '전량 통과';

  /// 불일치.
  static const String failed = '불일치';

  /// 실행 버튼.
  static const String runLabel = '골든벡터 실행';

  /// 결과 — 전량 통과.
  static const String okHeadline = '골든벡터 셀프테스트를 전량 통과했습니다.';

  /// 실행하지 못함(자산 · 기록 실패 — 칸이 보여 준다 · 통과를 지어내지 않는다).
  static const String runFailed = '골든벡터를 돌리지 못했습니다 — 다시 시도해 주세요.';

  /// 결과 — 불일치.
  static const String actHeadline =
      '골든벡터 셀프테스트에서 불일치가 나왔습니다. 실전 전환과 업데이트를 멈추고 확인해 주세요.';
}

String _two(int v) => v.toString().padLeft(2, '0');

/// «마지막 실행 MM-DD HH:mm»(한국 시각 · 표본 꼴).
String goldenLastRunText(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  return '마지막 실행 ${_two(k.month)}-${_two(k.day)} ${_two(k.hour)}:${_two(k.minute)}';
}

/// «통과 n/전체 m»(불일치 요약 · O-04 ④ 줄과 같은 꼴).
String goldenCountText(int passed, int total) => '통과 $passed/전체 $total';

/// 기록 한 행의 `discrepancies` JSON.
String goldenDiscrepanciesJson(GoldenRunResult r) =>
    jsonEncode(<String, Object?>{
      'digest': r.digest,
      'passed': r.passed,
      'total': r.total,
      'complete': r.complete,
      'failed': <String>[for (final GvFailure f in r.failures) f.caseId],
    });

/// 기록 한 행을 읽은 것.
class GoldenRecordView {
  /// 만든다.
  const GoldenRecordView({
    required this.runAtUtc,
    required this.ok,
    required this.digest,
    required this.passed,
    required this.total,
  });

  /// 실행 시각.
  final DateTime runAtUtc;

  /// 전량 통과였나(`GOLDEN_OK`).
  final bool ok;

  /// 묶음 지문.
  final String digest;

  /// 통과 수.
  final int passed;

  /// 전체 수.
  final int total;
}

/// 🔴 행 → 기록 — 꼴이 틀리면 null(읽지 못한 기록 = «실행하지 않음»으로 본다 · 통과를 지어내지 않는다).
GoldenRecordView? goldenRecordOf({
  required String runAt,
  required String? actionTaken,
  required String? discrepancies,
}) {
  if (actionTaken != kGoldenOk && actionTaken != kGoldenFailed) return null;
  try {
    final Object? j = jsonDecode(discrepancies ?? '');
    if (j is! Map<String, Object?>) return null;
    final Object? digest = j['digest'];
    final Object? passed = j['passed'];
    final Object? total = j['total'];
    if (digest is! String || passed is! int || total is! int) return null;
    final bool ok = actionTaken == kGoldenOk;
    if (ok && (passed != total || total <= 0)) return null;
    return GoldenRecordView(
      runAtUtc: DateTime.parse(runAt).toUtc(),
      ok: ok,
      digest: digest,
      passed: passed,
      total: total,
    );
  } on FormatException {
    return null;
  }
}

/// 실행 결과 → 동작 결과(표본 `m9/selftest_action_results` ar_s10_01 · 02 글자).
ActionResult selftestGoldenResultOf({
  required String actionRunId,
  required GoldenRunResult result,
}) => ActionResult(
  actionRunId: actionRunId,
  id: SettingsActionId.selftestGoldenRun,
  level: result.allPassed ? UiLevel.ok : UiLevel.act,
  headline: result.allPassed
      ? GoldenSelfTestTexts.okHeadline
      : GoldenSelfTestTexts.actHeadline,
  reasonCode: null, // 계약 — 통과 · 불일치 = headline 만(코드를 지어내지 않는다)
  retryable: false,
);

/// S10 골든 카드 사실.
class GoldenCardFacts {
  /// 만든다.
  const GoldenCardFacts({
    required this.ready,
    required this.currentDigest,
    required this.last,
    required this.running,
    required this.canRun,
  });

  /// 실행기 «전량» 전 · 자산을 읽기 전(= 판정 보류).
  const GoldenCardFacts.pending()
    : ready = false,
      currentDigest = null,
      last = null,
      running = false,
      canRun = false;

  /// 🔴 실행기가 «전량»이고 자산을 읽었나.
  final bool ready;

  /// 지금 묶음 지문.
  final String? currentDigest;

  /// 마지막 기록(없으면 null).
  final GoldenRecordView? last;

  /// 지금 돌고 있나.
  final bool running;

  /// 실행 동작을 낼 수 있나(폰 · 대상 원장 있음).
  final bool canRun;
}

/// 🔴 S10 골든 카드(표본 `m9/diagnostics_screen` · `_running` · `_diff` 꼴).
SelfTestCard goldenSelfTestCardOf(GoldenCardFacts f) {
  if (!f.ready || f.currentDigest == null) {
    return const SelfTestCard(
      title: GoldenSelfTestTexts.title,
      statusLabel: GoldenSelfTestTexts.pending,
      level: UiLevel.watch,
      summaryText: GoldenSelfTestTexts.pendingSummary,
    );
  }
  final GoldenRecordView? last = f.last;
  final String? lastRun = last == null
      ? null
      : goldenLastRunText(last.runAtUtc);
  if (f.running) {
    return SelfTestCard(
      title: GoldenSelfTestTexts.title,
      statusLabel: GoldenSelfTestTexts.running,
      level: UiLevel.info,
      lastRunText: lastRun,
    );
  }
  final SettingsActionCall? run = f.canRun
      ? const SettingsActionCall(
          id: SettingsActionId.selftestGoldenRun,
          args: <String, String>{},
          label: GoldenSelfTestTexts.runLabel,
        )
      : null;
  if (last == null) {
    return SelfTestCard(
      title: GoldenSelfTestTexts.title,
      statusLabel: GoldenSelfTestTexts.never,
      level: UiLevel.watch,
      runAction: run,
    );
  }
  if (last.digest != f.currentDigest) {
    return SelfTestCard(
      title: GoldenSelfTestTexts.title,
      statusLabel: GoldenSelfTestTexts.stale,
      level: UiLevel.watch,
      lastRunText: lastRun,
      runAction: run,
    );
  }
  return last.ok
      ? SelfTestCard(
          title: GoldenSelfTestTexts.title,
          statusLabel: GoldenSelfTestTexts.passed,
          level: UiLevel.ok,
          lastRunText: lastRun,
          summaryText: GoldenSelfTestTexts.passedSummary,
          runAction: run,
        )
      : SelfTestCard(
          title: GoldenSelfTestTexts.title,
          statusLabel: GoldenSelfTestTexts.failed,
          level: UiLevel.act,
          lastRunText: lastRun,
          summaryText: goldenCountText(last.passed, last.total),
          runAction: run,
        );
}

/// 🔴 O-04 ④ 사실 — 지금 지문과 같은 마지막 기록의 (통과, 전체) · 없으면 (0, 전체) · 지문 · 전체를 모르면 null(원천 없음).
(int, int)? goldenSelftestFactOf({
  required String? currentDigest,
  required int? total,
  required GoldenRecordView? last,
}) {
  final String? d = currentDigest;
  final int? m = total;
  if (d == null || m == null || m <= 0) return null;
  final GoldenRecordView? r = last;
  if (r == null || r.digest != d) return (0, m);
  return (r.passed, r.total);
}
