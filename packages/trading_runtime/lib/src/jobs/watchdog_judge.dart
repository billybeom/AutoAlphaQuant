// 워치독 3분법 판정(설계 13 §8 R43 B6 · 06 M1-16 · 앱 04 §7 `W-01` · 04 §5-2 v2.33).
//
// 🔴 성공 · **지연**(늦었지만 성공) · 실패를 가른다 — 폰 호스트에서는 Doze 지연이 실제 실패 모드라 «늦었지만 성공»을
//    실패로 칠하지 않는다. 🔴 일시정지는 네 번째 상태다(실패 · 결측으로 칠하지 않는다). 휴장 성공 핑은 `ok`.
// 🔵 원천 = 엔진의 실행 기록(예정 vs 실제 + 유예 · D12). healthchecks 읽기는 «바깥이 받았나» 대조(E11c 몫).

import 'package:domain_contracts/domain_contracts.dart';

import 'job_schedule.dart';

/// 회차 상태.
enum WatchdogState {
  /// 유예 전 — 아직 아니다.
  pending(UiLevel.ok),

  /// 유예 안에 성공.
  success(UiLevel.ok),

  /// 유예 지나 성공.
  late(UiLevel.watch),

  /// fail 핑 · 유예 지나도 성공 없음.
  failed(UiLevel.blocked),

  /// 휴장 성공 핑.
  holiday(UiLevel.ok),

  /// 일시정지(유지보수 창 · 집행 주체 전환).
  paused(UiLevel.info);

  const WatchdogState(this.level);

  /// 화면 모양(`WatchdogCheck.level`).
  final UiLevel level;
}

/// 회차 하나의 실행 기록(엔진 로컬).
class OccurrenceRecord {
  /// 기록을 만든다.
  const OccurrenceRecord({
    this.succeededUtc,
    this.failedUtc,
    this.holidayPing = false,
  });

  /// 성공 핑 시각(마지막).
  final DateTime? succeededUtc;

  /// fail 핑 시각(마지막).
  final DateTime? failedUtc;

  /// 성공 핑이 «휴장»이었나.
  final bool holidayPing;
}

/// 판정 결과.
class WatchdogVerdict {
  /// 결과를 만든다.
  const WatchdogVerdict(this.state, {this.lateBy});

  /// 상태.
  final WatchdogState state;

  /// 지연이면 유예 끝을 넘긴 만큼.
  final Duration? lateBy;
}

/// 회차 하나의 3분법 판정(R43 B6). [grace] 를 주면 잡 표의 잠정 유예 대신 쓴다(config · D11).
WatchdogVerdict judgeOccurrence({
  required JobOccurrence occurrence,
  required OccurrenceRecord? record,
  required DateTime nowUtc,
  bool paused = false,
  Duration? grace,
}) {
  if (paused) return const WatchdogVerdict(WatchdogState.paused);
  final DateTime deadline = occurrence.scheduledUtc.add(
    grace ?? occurrence.spec.grace,
  );
  final DateTime? ok = record?.succeededUtc;
  final DateTime? fail = record?.failedUtc;
  // 실패 뒤 다시 돌아 성공했으면 성공 쪽으로 본다(마지막 사건 기준).
  if (ok != null && (fail == null || !fail.isAfter(ok))) {
    if (record!.holidayPing) {
      return const WatchdogVerdict(WatchdogState.holiday);
    }
    if (!ok.isAfter(deadline)) {
      return const WatchdogVerdict(WatchdogState.success);
    }
    return WatchdogVerdict(WatchdogState.late, lateBy: ok.difference(deadline));
  }
  if (fail != null) return const WatchdogVerdict(WatchdogState.failed);
  return nowUtc.isAfter(deadline)
      ? const WatchdogVerdict(WatchdogState.failed)
      : const WatchdogVerdict(WatchdogState.pending);
}
