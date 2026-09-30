// 01 §4-1 — 플래그·슬리브 카탈로그·구간 프리셋·운영 파라미터 읽기 창구.
//
// 🔴 화면이 「지금 슬리브가 몇 칸인가」·「캘린더 화면을 그릴 것인가」를 아는 유일한 경로다.
//    상수·컴파일 타임 분기로 대체하면 플래그가 켜졌을 때 화면이 조용히 틀린다.

import '../dto/common.dart';
import '../dto/settings.dart';
import '../primitives/date_range.dart';

/// 런타임 구성 읽기.
abstract interface class ConfigRepository {
  Stream<FeatureFlags> watchFlags();

  /// 🔴 슬리브 목록은 플래그가 아니라 `SleeveCatalogEntry` 목록으로 온다 — 화면이
  ///    `SleeveId` 를 순회하며 `satellite` 를 걸러내는 코드를 쓰지 않게(거르는 규칙이
  ///    화면에 생기면 그것이 판정이다).
  Stream<List<SleeveCatalogEntry>> watchSleeves();

  /// 🆕 G-38 조회 구간 프리셋 목록 — 🔴 「최근 30일」·「이번 달」·「올해」의 `from`·`to`·
  ///    `label` 을 엔진이 **거래일 캘린더(M1-6)로** 만들어 준다. 화면이 `DateTime` 산술로
  ///    만들지 않는다. 🔴 목록의 길이·순서도 엔진이 정한다.
  Stream<List<DateRange>> watchRangePresets();

  /// 🆕 G-07 월 납입 운영값 — 🔴 「S05·S7-4·H-02 가 **같은 값 하나**를 읽는다」의 그 하나다.
  ///    값을 바꾸는 경로는 §4-3(운영 등급)이고 여기는 **읽기 전용**이다.
  /// 🆕 v1.4 정정(01 §14-10 · 03 §17-17 이 이긴다) — **S7-9 는 이 창구를 읽지 않는다.** 목표 경로
  ///    가정 카드 2줄은 `GoalPathVm.startingCapitalAssumptionText`(엔진 문장)가 준다.
  /// ✅ C-10 — 소속 리포지토리는 `ConfigRepository` 로 확정(별도 리포지토리를 만들지 않는다).
  /// 🔴 화면·계약·픽스처가 월 납입 금액을 상수로 적지 않는다(C-32).
  Stream<ContributionSetting> watchContributionSetting();
}
