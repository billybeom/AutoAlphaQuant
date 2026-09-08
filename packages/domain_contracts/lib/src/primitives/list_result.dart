// 01 §2-1 «목록 스트림의 봉투» 원문.
//
// 🔴 계약 3조 ③ «없는 것»·«못 받은 것»·«해당 없음» 의 구별을 **타입으로** 강제한다 —
//    빈 목록에도 `asOf`·`emptyKind`·`emptyLabel`·`hasMore` 가 실려 오므로 화면이 빈 상태를
//    지어낼 필요가 없다.
// 🔴 `rows` 는 **엔진이 이미 정렬해서** 준다 — 화면 재정렬 금지(인벤토리 §4 말미).
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/ui.dart';
import 'as_of.dart';

part 'list_result.freezed.dart';

/// 🔴 `fromJson`/`toJson` 을 두지 않는다 — 픽스처 봉투는 영역 F 의 로더가
/// `decodeList<T>(String json, T Function(Map<String,Object?>) rowFrom)` 로 조립한다
/// (인벤토리 §8-5). 제네릭 팩토리를 계약에 열면 행 타입마다 생성기 설정이 갈린다.
@freezed
abstract class ListResult<T> with _$ListResult<T> {
  const factory ListResult({
    /// 엔진이 이미 정렬해서 준다 — 화면 재정렬 금지.
    required List<T> rows,
    required AsOf asOf,

    /// `rows` 가 비어 있을 때의 갈래.
    required EmptyKind emptyKind,

    /// 「아직 기록된 거래가 없습니다 · 다음 리밸런싱 D-6」 — 엔진 생성(01 §1-5).
    String? emptyLabel,

    /// 더 받을 것이 남았는가(01 §4-1 페이징 — 커서가 아니라 `limit` 증가 재구독).
    required bool hasMore,
  }) = _ListResult<T>;
}
