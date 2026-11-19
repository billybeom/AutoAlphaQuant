// M9 S10 진단 화면 VM(감싸개) · 무결성 자가진단 결과(E11p4k · 설계 13 §8 R160 · 01 §33 K113~K117 · K137 · K138 · K143).
//
// 🔴 [diagnosticsScreenVmOf] = 감싸개 — `board` 는 H-01 블록 6 과 같은 값(엔진 `LedgerDiagnosticsSource` 하나 · 두 벌 0).
// 🔴 골든 카드 = 🆕 E11o-d(R167) 엔진 `goldenSelfTestCardOf`(기록 · 지문 · 실행 중) — 실행기 «전량» 전 · 사실 없음 = «판정 보류» + 버튼 부재(K114).
// 🔴 무결성 카드 = 정본 자가 대조(K115) · 상태 = «마지막 검증 …»(`checkpointLabelOf` · K137) · 대조 실패로 막혀 있으면 BLOCKED.
// 🔴 [selftestIntegrityResultOf] = 결과 문장(표본 `m9/selftest_action_results` 꼴 · 사유 7 = 엔진 `LedgerIntegrityReason`).
// 🔴 글자 = 엔진 · 총계 · «n/m» 상수 0(05 §8-1).

import 'package:domain_contracts/domain_contracts.dart'
    show
        ActionResult,
        AppRoutes,
        AsOf,
        AsOfSource,
        DiagnosticsScreenVm,
        DiagnosticsVm,
        LinkAction,
        SelfTestCard,
        SettingsActionCall,
        SettingsActionId,
        TradeDate,
        UiLevel;

import '../golden/golden_record.dart'
    show GoldenCardFacts, GoldenSelfTestTexts, goldenSelfTestCardOf;
import '../safety/safety_text.dart' show checkpointLabelOf;
import 'ledger_integrity.dart' show LedgerIntegrityReason;
import 'ledger_views.dart' show kstDateText;

/// 진단 화면 기준 유효 시간(표본 26시간).
const Duration kDiagnosticsScreenStaleAfter = Duration(hours: 26);

/// S10 글자(엔진).
abstract final class DiagnosticsScreenTexts {
  /// 골든 카드 제목(= [GoldenSelfTestTexts.title]).
  static const String goldenTitle = GoldenSelfTestTexts.title;

  /// 골든 실행기 전 상태(= [GoldenSelfTestTexts.pending]).
  static const String goldenPending = GoldenSelfTestTexts.pending;

  /// 골든 실행기 전 요약(= [GoldenSelfTestTexts.pendingSummary]).
  static const String goldenPendingSummary = GoldenSelfTestTexts.pendingSummary;

  /// 무결성 카드 제목.
  static const String integrityTitle = '무결성 자가진단';

  /// 무결성 검증 기록 없음.
  static const String integrityNever = '아직 검증하지 않았습니다';

  /// 무결성 실행 버튼.
  static const String integrityRun = '무결성 자가진단 실행';

  /// 차이 상세 링크.
  static const String diffsLink = '차이 상세 보기';

  /// 진입 권장 배너.
  static const String recommend =
      '앱 업데이트 후 · 기기 이전 후 · 실전 전환 직전에 한 번씩 확인해 주세요.';

  /// 무결성 일치.
  static const String integrityOk = '정본 자가 대조가 일치합니다.';

  /// 무결성 어긋남 앞머리(뒤 = 사유).
  static const String integrityBlocked = '정본 자가 대조가 어긋나 신규 주문을 막았습니다 — ';
}

/// 사유 → 쉬운 말(표본 글자).
String integrityReasonText(LedgerIntegrityReason r) => switch (r) {
  LedgerIntegrityReason.formatVersion => '해시 형식 판이 다릅니다.',
  LedgerIntegrityReason.dateGap => '장부 날이 이어지지 않습니다.',
  LedgerIntegrityReason.chainBroken => '해시 사슬이 끊겼습니다.',
  LedgerIntegrityReason.dayHashMismatch => '다시 센 하루 해시가 다릅니다.',
  LedgerIntegrityReason.rowsBeforeFirstStamp => '첫 마감 앞 날에 기록이 끼어들었습니다.',
  LedgerIntegrityReason.attribution => '기록을 날짜에 나누지 못했습니다.',
  LedgerIntegrityReason.sqliteIntegrity => '장부 파일 점검에서 오류가 나왔습니다.',
};

/// S10 사실.
class DiagnosticsScreenFacts {
  /// 만든다.
  const DiagnosticsScreenFacts({
    required this.board,
    required this.lastIntegrityOkUtc,
    required this.integrityBlocked,
    required this.openDiffs,
    required this.canRun,
    required this.nowUtc,
    this.golden = const GoldenCardFacts.pending(),
  });

  /// 🆕 E11o-d(R167) — 골든 카드 사실(없음 = 판정 보류).
  final GoldenCardFacts golden;

  /// 5칸 대조 보드(H-01 과 같은 값).
  final DiagnosticsVm board;

  /// 마지막 `INTEGRITY_OK`(없으면 null).
  final DateTime? lastIntegrityOkUtc;

  /// `LEDGER_INTEGRITY` 차단이 서 있나.
  final bool integrityBlocked;

  /// 열린 원장 차이가 있나(있으면 차이 상세 링크).
  final bool openDiffs;

  /// 무결성 실행을 낼 수 있나(폰 · 화면 상태 있음).
  final bool canRun;

  /// 지금(기준 줄).
  final DateTime nowUtc;
}

/// 🔴 S10 감싸개 VM.
DiagnosticsScreenVm diagnosticsScreenVmOf(DiagnosticsScreenFacts f) {
  final DateTime? ok = f.lastIntegrityOkUtc;
  final String day = kstDateText(f.nowUtc);
  return DiagnosticsScreenVm(
    golden: goldenSelfTestCardOf(f.golden),
    integrity: SelfTestCard(
      title: DiagnosticsScreenTexts.integrityTitle,
      statusLabel: ok == null
          ? DiagnosticsScreenTexts.integrityNever
          : checkpointLabelOf(ok),
      level: f.integrityBlocked
          ? UiLevel.blocked
          : ok == null
          ? UiLevel.watch
          : UiLevel.ok,
      runAction: f.canRun
          ? const SettingsActionCall(
              id: SettingsActionId.selftestIntegrityRun,
              args: <String, String>{},
              label: DiagnosticsScreenTexts.integrityRun,
            )
          : null,
    ),
    board: f.board,
    diffsLink: f.openDiffs
        ? const LinkAction(
            label: DiagnosticsScreenTexts.diffsLink,
            deepLink: AppRoutes.ledgerDiffs,
          )
        : null,
    recommendText: DiagnosticsScreenTexts.recommend,
    asOf: AsOf(
      observedAt: f.nowUtc.toUtc(),
      tradeDate: TradeDate(day),
      source: AsOfSource.localSqlite,
      staleAfter: kDiagnosticsScreenStaleAfter,
      label: '진단 기준 $day',
    ),
  );
}

/// 🔴 무결성 자가진단 결과 — [reason] null = 일치(OK) · 그 밖 = 막힘(BLOCKED · 코드 = 사유 표기).
ActionResult selftestIntegrityResultOf({
  required String actionRunId,
  required LedgerIntegrityReason? reason,
}) {
  final LedgerIntegrityReason? r = reason;
  return ActionResult(
    actionRunId: actionRunId,
    id: SettingsActionId.selftestIntegrityRun,
    level: r == null ? UiLevel.ok : UiLevel.blocked,
    headline: r == null
        ? DiagnosticsScreenTexts.integrityOk
        : '${DiagnosticsScreenTexts.integrityBlocked}${integrityReasonText(r)}',
    reasonCode: r?.code,
    retryable: false,
  );
}
