// 01 §12-1 — 🆕 계약 v1.2. 기기 로컬 **입력 초안**의 키·봉투·본문.
//
// 🔴 초안 = **사람이 친 입력의 원문**이다. 원장 사실도, 명령도 아니다(제출은 여전히 CommandApi 뿐).
// 🔴 본문 필드 규칙(C-35 ④)
//    ① 이름 = 그 명령 인자(`JournalDraft`·`ManualFillRecord`·`AdviceSkip`·`SelfReportBalance`)의 필드 이름.
//    ② 화면이 만들 수 없는 타입(`Decimal`·`int` 수량)은 **원문 문자열** `<인자 이름>Text`(trim·파싱·0 채움 없음).
//    ③ 담지 않는다 — `CommandContext`(구현이 채운다 · G-19) · 대상 id(키에 있다) · 확인값 3종
//       (`duplicateAck`·`offHourTrade`·`declaredComplete` — «그 순간의 확인»은 복원되면 확인이 아니다) ·
//       세션값(`sessionStartedAt` — 새 세션이 준다) · 엔진 문구(`*Label`) · 모드·기기·시각.
//    ④ **추가형으로만 진화**한다 — 모든 필드는 nullable 이거나 `@Default` 다. 필드를 지우거나 이름·타입을
//       바꾸면 앱 업데이트 전에 저장된 초안이 읽히지 않는다(= 초안 유실 · C17 위반). C-35 ④ 가
//       `fromJson(<String, dynamic>{})` 성공으로 검사한다.
// 🔴 로그·오류 보고·분석 이벤트에 본문 값을 싣지 않는다(자유 서술 칸에 무엇이 붙여 넣어졌을지 모른다).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/advice.dart';
import '../enums/draft.dart';
import '../enums/order.dart';
import '../primitives/money.dart';

part 'drafts.freezed.dart';
part 'drafts.g.dart';

/// 초안 하나의 자리 = (종류, 대상 id).
///
/// 🔴 화면은 [targetId] 를 **위젯 생성자 인자 그대로** 넣는다(셸이 라우트 파라미터에서 꺼낸 값 —
///    01 §11-10). 링크 조립이 아니다. 대상 id 표(01 §12-1): `journalDraft` = `decisionId` ·
///    `manualFillRecord`·`adviceSkip` = `adviceId` · `selfReportBalance` = `SelfReportPurpose.wire`.
/// 🔴 모드(계열)는 키에 **없다** — 구현이 계열별로 저장 공간을 가른다(화면은 모드를 모른다 · A7).
@freezed
abstract class DraftKey with _$DraftKey {
  const factory DraftKey({
    required DraftKind kind,

    /// 빈 문자열 금지.
    required String targetId,
  }) = _DraftKey;

  factory DraftKey.fromJson(Map<String, dynamic> json) =>
      _$DraftKeyFromJson(json);
}

/// 초안 1건.
///
/// 🔴 본문 칸은 **정확히 하나**만 non-null 이고 그것이 `key.kind` 의 칸이다 — 아니면 `DraftStore.save`
///    가 `Future` 에러(`ArgumentError`)로 거절한다(구현·받침대 공통 · C-35 ①).
@freezed
abstract class DraftRecord with _$DraftRecord {
  const factory DraftRecord({
    required DraftKey key,

    /// `kind == journalDraft`(`J-3`).
    JournalDraftInput? journal,

    /// `kind == manualFillRecord`(`A-3`).
    ManualFillInput? manualFill,

    /// `kind == adviceSkip`(`A-4`).
    AdviceSkipInput? adviceSkip,

    /// `kind == selfReportBalance`(`L-3` · `O-04` 재사용 포함).
    SelfReportInput? selfReport,

    /// 이 초안으로 **마지막으로 접수된** 명령. null = 아직 접수증이 없다.
    /// 🔴 non-null 이면 화면은 복원 때 `CommandApi.watchCommand(lastCommandId)` 를 다시 구독하고
    ///    첫 접수증 전까지 입력을 잠근다(재시작 뒤 이중 제출 차단 · 01 §8 미결 51 ②).
    String? lastCommandId,
  }) = _DraftRecord;

  factory DraftRecord.fromJson(Map<String, dynamic> json) =>
      _$DraftRecordFromJson(json);
}

/// `J-3` 사전 저널 초안 — [JournalDraft] 에서 `decisionId` 를 뺀 것(C-35 ④).
@freezed
abstract class JournalDraftInput with _$JournalDraftInput {
  const factory JournalDraftInput({
    /// 원문(trim 전).
    @Default('') String rationaleBefore,
    @Default('') String expectedOutcome,

    /// 고른 `JournalDraftFormSpec.ruleCitedOptions[].code`. null = 미선택.
    /// 🔴 복원 때 그 시점의 선택지와 **code 로** 대조하고, 없으면 미선택(문구 없음).
    String? ruleCited,

    /// 원문. '' = 비어 있음(제출 때 `note: null` 로 바꾸는 것은 화면 — 01 §11-10).
    @Default('') String note,
  }) = _JournalDraftInput;

  factory JournalDraftInput.fromJson(Map<String, dynamic> json) =>
      _$JournalDraftInputFromJson(json);
}

/// `A-3` 수기 체결 초안 — [ManualFillRecord] 에서 `adviceId`(키)·`context`·`offHourTrade`·
/// `duplicateAck`(확인값)를 뺐다. 🔴 복원 = 사람이 친 값만(A1 — 안내 값 프리필이 아니다).
@freezed
abstract class ManualFillInput with _$ManualFillInput {
  const factory ManualFillInput({
    @TradeDateConverter() TradeDate? tradeDate,

    /// `ManualFillFormSpec.symbols[].symbol`.
    String? symbol,
    OrderSide? side,
    @Default('') String quantityText,
    @Default('') String priceText,

    /// '' = 비움(«모름» — 0 이 아니다 · 인자의 `commission: null` 과 같은 뜻).
    @Default('') String commissionText,
    @Default('') String taxText,

    /// `ManualFillFormSpec.accounts[].alias`. 🔴 계좌 전체번호를 싣지 않는다.
    String? accountAlias,

    /// A1 — 「안내 수량 채우기」를 쓴 필드(인자와 같은 뜻 · 원문 그대로 복원).
    @Default(<String>[]) List<String> prefilledFields,
    @Default('') String deviationNote,
  }) = _ManualFillInput;

  factory ManualFillInput.fromJson(Map<String, dynamic> json) =>
      _$ManualFillInputFromJson(json);
}

/// `A-4` 미이행 사유 초안 — [AdviceSkip] 에서 `adviceId`(키)·`context` 를 뺐다.
@freezed
abstract class AdviceSkipInput with _$AdviceSkipInput {
  const factory AdviceSkipInput({
    AdviceSkipReason? reason,
    @Default('') String note,
  }) = _AdviceSkipInput;

  factory AdviceSkipInput.fromJson(Map<String, dynamic> json) =>
      _$AdviceSkipInputFromJson(json);
}

/// `L-3` 원장 실사 초안 — [SelfReportBalance] 에서 `purpose`(키)·`sessionStartedAt`(세션값)·
/// `declaredComplete`(확인값)·`context` 를 뺐다. ⏸ `asOfTradeDate` 는 실사 세션 VM 이 정해지는
/// X7 창에서 «사람이 고르는 값»이면 추가형으로 더한다(01 §8 미결 52).
/// 🔴 복원값 = 사람이 전에 적은 값뿐(원장 현재값 프리필 금지 — 앵커링 · 02 §3-10).
@freezed
abstract class SelfReportInput with _$SelfReportInput {
  const factory SelfReportInput({
    @Default(<SelfReportLineInput>[]) List<SelfReportLineInput> lines,
    @Default('') String cashKrwText,
    String? accountAlias,
  }) = _SelfReportInput;

  factory SelfReportInput.fromJson(Map<String, dynamic> json) =>
      _$SelfReportInputFromJson(json);
}

/// `L-3` 한 종목 행. 🔴 `quantityText == ''` = 아직 안 적음(0 으로 바꾸지 않는다 — «0» 은 사람이 적은 0).
@freezed
abstract class SelfReportLineInput with _$SelfReportLineInput {
  const factory SelfReportLineInput({
    required String symbol,
    @Default('') String quantityText,
  }) = _SelfReportLineInput;

  factory SelfReportLineInput.fromJson(Map<String, dynamic> json) =>
      _$SelfReportLineInputFromJson(json);
}
