// 01 §2-6(요구 6 핸드북) · m2-8 D-9 — 04 §8 이 렌더하는 핸드북.
//
// 🔴 `ReasonChip.detailDeepLink`(`handbook://…`)의 **도착지**다.
// 🔴 **C-13 의 `config_hash` 메타를 싣는 주체**이며, 픽스처의 `config_hash` 와
//    어긋나면 계약 테스트가 실패한다 — 화면이 두 값을 비교하지 않는다.
// 🔴 본문 문구는 전부 원고(엔진·핸드북 소스)에서 오며 화면이 문장을 짓지 않는다.
// 🆕 계약 v1.17(01 §26 · R16 선행 · 발주자 결정 2026-11-04 ④) — 목차 상태·자식·링크 · 뒤처짐 글자 · 모르는 앵커 · live 블록:
//    ① «설명이 규칙보다 뒤처졌다» 판정 = **엔진**(원고 메타 해시 ↔ 지금 config 대조) — 결과는 [HandbookIndex.outdatedNotice]·
//       [HandbookPage.outdatedNotice] 글자로만 온다(숨김·닫기 0 · P1 알림 = 엔진). 뒤처짐 표본도 `config_hash` = 봉투 meta(C-13 ⓐ).
//    ② 목차 항목 수·차례·접힘 = 받은 그대로(8 리터럴 0) · 링크 = [HandbookEntry.deepLink](화면이 `handbook://$anchor` 를 짓지 않는다).
//    ③ 모르는 앵커 = [HandbookPage.missingLabel](값 · 스트림 에러 아님) · 앵커 별칭 해석 = 엔진.
//    ④ live «현재 상태» 블록이 하나라도 있으면 [HandbookPage.asOf] non-null(엔진 의무) — 지금 값을 보이므로 조회 화면이다.
//       live 가 없으면 asOf 0(문서 콘텐츠 · K20).
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/handbook.dart';
import '../enums/ui.dart';
import '../primitives/as_of.dart';

part 'handbook.freezed.dart';
part 'handbook.g.dart';

/// m2-8 D-9 — 핸드북 목차.
@freezed
abstract class HandbookIndex with _$HandbookIndex {
  const factory HandbookIndex({
    required List<HandbookEntry> entries,
    required String configHash,

    /// 🆕 v1.17 — 뒤처짐 고지(엔진 판정 글자). null = 고지 없음.
    String? outdatedNotice,
  }) = _HandbookIndex;

  factory HandbookIndex.fromJson(Map<String, dynamic> json) =>
      _$HandbookIndexFromJson(json);
}
// JSON 키: entries · config_hash · outdated_notice

/// m2-8 D-9 — 목차 1행. 🔴 `order` 는 엔진이 정한다(화면이 정렬하지 않는다).
@freezed
abstract class HandbookEntry with _$HandbookEntry {
  const factory HandbookEntry({
    required String anchor,
    required String title,
    required int order,

    /// 🆕 v1.17 — 아이콘·색에만. 키가 없는 옛 표본 = [HandbookEntryState.ready].
    @Default(HandbookEntryState.ready) HandbookEntryState state,

    /// 🆕 v1.17 — «준비 중» · «보관됨»(엔진). `ready` 면 null.
    String? stateLabel,

    /// 🆕 v1.17 — 탭 목적지(`handbook://…` · 엔진 완성). null = 탭 부재(준비 중).
    String? deepLink,

    /// 🆕 v1.17 — 하위 항목(② 슬리브 A·B·C · 보관된 새틀라이트 — 받은 차례). 키 없음 = [].
    @Default(<HandbookEntry>[]) List<HandbookEntry> children,
  }) = _HandbookEntry;

  factory HandbookEntry.fromJson(Map<String, dynamic> json) =>
      _$HandbookEntryFromJson(json);
}
// JSON 키: anchor · title · order · state · state_label · deep_link · children

/// m2-8 D-9 — 핸드북 한 쪽.
@freezed
abstract class HandbookPage with _$HandbookPage {
  const factory HandbookPage({
    required String anchor,
    required String title,
    required List<HandbookBlock> blocks,
    required String configHash,

    /// 🆕 v1.17 — 뒤처짐 고지(엔진 판정 글자 · 맨 위 · 숨김 0). null = 없음.
    String? outdatedNotice,

    /// 🆕 v1.17 — 모르는 앵커 문장(엔진). non-null ⇔ [blocks] 0.
    String? missingLabel,

    /// 🆕 v1.17(발주자 결정 2026-11-04 ④ R16b ⑨) — live 블록이 하나라도 있으면 non-null(엔진 의무) · 없으면 null.
    AsOf? asOf,
  }) = _HandbookPage;

  factory HandbookPage.fromJson(Map<String, dynamic> json) =>
      _$HandbookPageFromJson(json);
}
// JSON 키: anchor · title · blocks · config_hash · outdated_notice · missing_label · as_of

/// m2-8 D-9 — 본문 블록 1개. 🔴 `kind` 는 엔진이 준 블록 종류 코드이며 화면이
/// 이 값으로 문구를 고르지 않는다(C-5).
@freezed
abstract class HandbookBlock with _$HandbookBlock {
  const factory HandbookBlock({
    required String kind,
    required String text,
    String? deepLink,

    /// 🆕 v1.17 — «현재 상태» 라이브 값(라벨 = 엔진 · 등급 = 아이콘·색만). null = 일반 블록.
    HandbookLiveValue? live,
  }) = _HandbookBlock;

  factory HandbookBlock.fromJson(Map<String, dynamic> json) =>
      _$HandbookBlockFromJson(json);
}
// JSON 키: kind · text · deep_link · live

/// 🆕 v1.17(01 §26 · K13) — 블록의 «현재 상태» 값(예 «금 비중이 상한에 가깝습니다» · WATCH).
@freezed
abstract class HandbookLiveValue with _$HandbookLiveValue {
  const factory HandbookLiveValue({
    /// 값·라벨 — 엔진(🔴 화면 숫자 0).
    required String label,

    /// 아이콘·색에만.
    required UiLevel level,
  }) = _HandbookLiveValue;

  factory HandbookLiveValue.fromJson(Map<String, dynamic> json) =>
      _$HandbookLiveValueFromJson(json);
}
// JSON 키: label · level
