// simToAuto 2단 커밋 2단계 · 기동 복구 — 모의 파일 처리 판정(설계 13 §8 R98 AG1 f3b · R100 AH1~AH7).
//
// 🔴 판정만 한다 — 모의 CLOSE 쓰기 · 파일 지우기는 data_sync(`finishSimToAuto` · `deleteClosedSimLedger`).
// 🔴 실전 커밋이 없으면 아무것도 하지 않는다 · 고름이 없으면 지우지 않는다(남기는 쪽 · 되돌릴 수 없는 일은 명시 고름만).

import 'sim_to_auto.dart' show SimLedgerFate;

/// 모의 파일 처리.
enum SimLedgerFinish {
  /// 할 일 없음(실전 커밋 없음 · 모의 행 없음).
  none,

  /// 닫고 남긴다(보관 · 고름 없음).
  keep,

  /// 닫고 지운다(고름 = 지움).
  discard,
}

/// 2단계 판정 결과.
class SimLedgerFinishPlan {
  /// 결과를 만든다.
  const SimLedgerFinishPlan({required this.closeSim, required this.finish});

  /// 모의 CLOSE 를 써야 하나.
  final bool closeSim;

  /// 처리.
  final SimLedgerFinish finish;
}

/// 2단계 · 기동 복구 판정(AH3) — [liveCommitted] = 실전 파일 현재 행이 live ·
/// [simHasRows] = 모의 파일에 모드 행이 있다(없거나 빈 파일 = false) · [simClosed] = CLOSE 행 있음 · [fate] = S5 고름.
SimLedgerFinishPlan simLedgerFinishOf({
  required bool liveCommitted,
  required bool simHasRows,
  required bool simClosed,
  required SimLedgerFate? fate,
}) {
  if (!liveCommitted || !simHasRows) {
    return const SimLedgerFinishPlan(
      closeSim: false,
      finish: SimLedgerFinish.none,
    );
  }
  return SimLedgerFinishPlan(
    closeSim: !simClosed,
    finish: fate == SimLedgerFate.discard
        ? SimLedgerFinish.discard
        : SimLedgerFinish.keep,
  );
}

/// 모의 파일 지우기 결과(AH2 · 엔진 문자열 — 1.20.0 후보).
enum SimLedgerDeleteResult {
  /// 지웠다(본체 · `-wal` · `-shm`).
  deleted('SIM_LEDGER_DELETED'),

  /// 파일이 없다.
  missing('SIM_LEDGER_MISSING'),

  /// 닫히지 않았다(지우지 않음).
  notClosed('SIM_LEDGER_NOT_CLOSED'),

  /// 고름이 지움이 아니다(지우지 않음).
  notDiscard('SIM_LEDGER_NOT_DISCARD'),

  /// 파일 시스템이 거부했다(연결이 열려 있는 등) — 다음 기동에 다시.
  deleteFailed('SIM_LEDGER_DELETE_FAILED');

  const SimLedgerDeleteResult(this.code);

  /// 결과 코드.
  final String code;
}
