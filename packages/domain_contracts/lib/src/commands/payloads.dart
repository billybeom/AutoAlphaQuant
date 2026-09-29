// 01 §4-2 · §5-4 — 명령 인자 DTO(기존 5종 계열).
//
// 🔴 인자가 2개를 넘는 명령은 전부 DTO 로 받는다 — `@DecimalStringConverter()` 는
//    **필드 어노테이션**이라 메서드 인자에 붙여도 아무 일도 하지 않고, 직렬화 규약이
//    사라진 payload 가 만들어진다.
// 🔴 payload 에 `idempotencyKey` 를 두지 않는다(A9) — 멱등은 봉투가 보장한다
//    (`command_queue.command_id` + `unique(kind, nonce)`).
// ⏸ H-6 — 이 4종에 `CommandContext` 를 붙일지는 M2-8 물음(§8-21)이며 「붙인다」가 권고
//    확정이다. ⏸ 사유 = `command_queue` 3컬럼이 전 명령에 걸리므로 배치 D 와 같은 창이어야
//    성립한다 → 확정 전까지 여기에 `context` 필드를 만들지 않는다.
//
// 🔴 X7 8종은 `payloads_x7.dart` 에 있다(파일 크기 규약상 분리 · 계약상 같은 §5-4 표).

import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../primitives/money.dart';

part 'payloads.freezed.dart';
part 'payloads.g.dart';

/// 실입금 등록(§2-6 · 플래너 계획 스냅샷 소비).
@freezed
abstract class DepositRegistration with _$DepositRegistration {
  const factory DepositRegistration({
    /// 🔴 만료된 계획이면 엔진이 거부한다(§2-6) — 화면이 만료를 미리 판정하지 않는다.
    required String planId,

    /// JSON 은 문자열이다.
    /// 🔴 금액은 **엔진 설정값**(`ConfigRepository.watchContributionSetting`)에서 오며
    ///    화면·계약이 상수로 적지 않는다(§2-6 · C-32).
    @DecimalStringConverter() required Decimal amount,
    @TradeDateConverter() required TradeDate valueDate,
  }) = _DepositRegistration;

  factory DepositRegistration.fromJson(Map<String, dynamic> json) =>
      _$DepositRegistrationFromJson(json);
}

/// ✅ H-1 — 사전 작성 저널 초안(결정 9b · 폰은 사전 작성 / viewer 는 초안).
@freezed
abstract class JournalDraft with _$JournalDraft {
  const factory JournalDraft({
    required String decisionId,
    required String rationaleBefore,
    required String expectedOutcome,

    /// 🔴 **엔진 제공 목록의 코드**다(자유 입력 금지). 선택지는
    ///    `JournalDraftFormSpec.ruleCitedOptions`(E-4)가 준다.
    required String ruleCited,
    String? note,
  }) = _JournalDraft;

  factory JournalDraft.fromJson(Map<String, dynamic> json) =>
      _$JournalDraftFromJson(json);
}

/// ✅ H-2 — 사후 blind 리뷰 점수(결정 9b).
@freezed
abstract class BlindReviewScore with _$BlindReviewScore {
  const factory BlindReviewScore({
    required String decisionId,

    /// 문항 id → 점수.
    /// 🔴 문항·선택지 문구는 `BlindReviewCard`(E-5)가 준다 — 화면이 짓지 않는다.
    required Map<String, int> answers,
  }) = _BlindReviewScore;

  factory BlindReviewScore.fromJson(Map<String, dynamic> json) =>
      _$BlindReviewScoreFromJson(json);
}

/// ✅ H-3 — 성과 열람 기록(결정 8 · G-42). 🆕 v1.3 — 세 값의 뜻(01 §13-6).
@freezed
abstract class DisclosureViewEvent with _$DisclosureViewEvent {
  const factory DisclosureViewEvent({
    /// 어느 화면의 열람인가 — 값은 `DisclosureSurfaceCodes` 가 정본이다.
    required String surfaceCode,

    /// 「그래도 보기」를 누른 순간의 주입 시계 값(`Clock.nowUtc()`) — 관측 시각이며 참고값이다.
    /// 🔴 집계 키 `yyyy_mm` 을 화면이 넣지 않는다 — 집계 월은 엔진이 접수·서버 시각으로
    ///    확정한다(G-42).
    required DateTime viewedAt,

    /// 🆕 v1.3 — 진입 시점 기록은 **0**. 화면은 이 값을 적지 않는다(열람 길이 = 미결 60).
    @Default(0) int durationSec,
  }) = _DisclosureViewEvent;

  factory DisclosureViewEvent.fromJson(Map<String, dynamic> json) =>
      _$DisclosureViewEventFromJson(json);
}
