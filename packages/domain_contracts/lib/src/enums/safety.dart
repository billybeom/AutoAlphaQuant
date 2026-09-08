// 01 §2-10 «알림·브레이커» 축(인벤토리 §2-10).
//
// 🔴 소유 경계는 타입이 아니라 «무엇을 그리는가» 다(01 §2-10 표) — 상태 표시는 허용,
//    **상태를 바꾸는 경로를 만드는 것은 금지**. C-7 이 그 표대로 검사한다.
import 'package:freezed_annotation/freezed_annotation.dart';

/// 01 §2-10 — 알림 등급.
/// 🔴 **표시 계층의 사적 재분류 금지**(결정 7c). 배치 E 가 구 `INFO`/`ALERT`/`DIGEST` 를
///    이 3값으로 개편한다.
enum AlertLevel {
  @JsonValue('P0')
  p0('P0'),
  @JsonValue('P1')
  p1('P1'),
  @JsonValue('P2')
  p2('P2');

  const AlertLevel(this.wire);

  /// JSON·DDL 표기(01 §1-2).
  final String wire;
}

/// 01 §2-10 — 브레이커 단계.
/// 🔵 `stopped` 의 자격 판정은 명세 v2.29 조문이 정한다 — 화면은 `stoppedReleaseEligible`
///    필드를 그대로 그리고 자격을 재판정하지 않는다.
enum BreakerLevel {
  @JsonValue('NORMAL')
  normal('NORMAL'),
  @JsonValue('ALERT')
  alert('ALERT'),
  @JsonValue('REDUCED')
  reduced('REDUCED'),
  @JsonValue('HALTED')
  halted('HALTED'),
  @JsonValue('STOPPED')
  stopped('STOPPED');

  const BreakerLevel(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}

/// 01 §2-10·§3-5 — 차단 플래그의 해제 경로.
/// 🔴 해제 문구는 **플래그마다 다르다**(`BlockFlag.clearInstruction`) — 화면이 경로로
///    문구를 고르지 않는다.
enum ClearRoute {
  @JsonValue('AUTOMATIC')
  automatic('AUTOMATIC'),
  @JsonValue('CAUSE_CODE_REQUIRED')
  causeCodeRequired('CAUSE_CODE_REQUIRED'),
  @JsonValue('NO_MANUAL_PATH')
  noManualPath('NO_MANUAL_PATH'),
  @JsonValue('WIZARD_ONLY')
  wizardOnly('WIZARD_ONLY');

  const ClearRoute(this.wire);

  /// JSON·DDL 표기.
  final String wire;
}
