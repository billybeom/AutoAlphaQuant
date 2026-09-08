// 01 §2-6(요구 6 핸드북) · m2-8 D-9 — 04 §8 이 렌더하는 핸드북.
//
// 🔴 `ReasonChip.detailDeepLink`(`handbook://…`)의 **도착지**다.
// 🔴 **C-13 의 `config_hash` 메타를 싣는 주체**이며, 픽스처의 `config_hash` 와
//    어긋나면 계약 테스트가 실패한다 — 화면이 두 값을 비교하지 않는다.
// 🔴 본문 문구는 전부 원고(엔진·핸드북 소스)에서 오며 화면이 문장을 짓지 않는다.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'handbook.freezed.dart';
part 'handbook.g.dart';

/// m2-8 D-9 — 핸드북 목차.
@freezed
abstract class HandbookIndex with _$HandbookIndex {
  const factory HandbookIndex({
    required List<HandbookEntry> entries,
    required String configHash,
  }) = _HandbookIndex;

  factory HandbookIndex.fromJson(Map<String, dynamic> json) =>
      _$HandbookIndexFromJson(json);
}

/// m2-8 D-9 — 목차 1행. 🔴 `order` 는 엔진이 정한다(화면이 정렬하지 않는다).
@freezed
abstract class HandbookEntry with _$HandbookEntry {
  const factory HandbookEntry({
    required String anchor,
    required String title,
    required int order,
  }) = _HandbookEntry;

  factory HandbookEntry.fromJson(Map<String, dynamic> json) =>
      _$HandbookEntryFromJson(json);
}

/// m2-8 D-9 — 핸드북 한 쪽.
@freezed
abstract class HandbookPage with _$HandbookPage {
  const factory HandbookPage({
    required String anchor,
    required String title,
    required List<HandbookBlock> blocks,
    required String configHash,
  }) = _HandbookPage;

  factory HandbookPage.fromJson(Map<String, dynamic> json) =>
      _$HandbookPageFromJson(json);
}

/// m2-8 D-9 — 본문 블록 1개. 🔴 `kind` 는 엔진이 준 블록 종류 코드이며 화면이
/// 이 값으로 문구를 고르지 않는다(C-5).
@freezed
abstract class HandbookBlock with _$HandbookBlock {
  const factory HandbookBlock({
    required String kind,
    required String text,
    String? deepLink,
  }) = _HandbookBlock;

  factory HandbookBlock.fromJson(Map<String, dynamic> json) =>
      _$HandbookBlockFromJson(json);
}
