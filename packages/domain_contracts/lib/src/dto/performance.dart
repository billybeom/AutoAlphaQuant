// 01 §2-4 — 수익률(M7 요구 2) · 세후 사다리 · §2-6 M7 뷰모델(G-41).
//
// 🔴 화면은 TWR/MWR 을 계산하지 않고 누적곱도 하지 않는다. 세율 곱셈·층 간
//    차액도 금지이며 C-30 이 이것을 검사한다(01 §2-4 말미).
// 🔴 «정직 기대»·사다리 4자리 수치를 코드·라벨·주석에 옮기지 않는다 —
//    인용처는 픽스처 `aftertax_ladder_1.json` 과 골든 `aftertax_full_S7` 뿐이다.
// 🔴 `PerfMetric.twr` 은 외부 현금흐름 «보정판»이다(01 §2-4 P 회차 실측).
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/performance.dart';
import '../enums/sleeve.dart';
import '../primitives/as_of.dart';
import '../primitives/money.dart';
import 'ledger_trust.dart';

part 'performance.freezed.dart';
part 'performance.g.dart';

/// 01 §2-4 — 수익률 시리즈. 🔴 누적/비누적 토글도 엔진이 두 시리즈를 주거나
/// `cumulative` 로 재요청한다(화면 누적곱은 단일 산식 원칙 위반).
@freezed
abstract class PerformanceSeries with _$PerformanceSeries {
  const factory PerformanceSeries({
    required PerfMetric metric,
    required PerfGranularity granularity,
    required bool cumulative,

    /// 🔴 결측·재개로 분절된 구간들.
    required List<PerfSegment> segments,
    required List<PerfPoint> points,

    /// 표본 크기 고지·인터스티셜 문구·열람 횟수(01 §2-4).
    required PerfDisclosure disclosure,
    required AsOf asOf,

    /// 🆕 v1.3 — 본선의 이름(범례). "내 계좌 · 시간가중 · 누적" — 엔진 생성.
    required String seriesLabel,

    /// 🆕 v1.3 — 이 시리즈가 덮는 기간. "2024년 9월 ~ 2026년 8월" — 엔진 생성.
    /// `range == null` 요청에서 엔진이 고른 구간을 말하는 유일한 글자다.
    required String periodLabel,

    /// 🆕 v1.3 — 세로축 눈금(아래 → 위 순서). 비면 눈금 없음. 많아야 5개다(C-36 ④).
    @Default(<PerfAxisTick>[]) List<PerfAxisTick> yTicks,

    /// 🆕 v1.3 — non-null ⇔ `points` 가 비어 있다(C-36 ⑤). 그때는 차트·눈금·범례·값 표
    /// 대신 **이 문장 카드 1장**이다. `segments`·`yTicks` 도 비고 `benchmark` 는 null 이다.
    /// 기록이 비었든 차단으로 가렸든 엔진이 이 필드로 말한다.
    /// 🔴 화면은 점을 세거나 훑어 상태를 고르지 않는다. 점이 하나라도 오면 그중 하나는
    ///    값이 있다.
    String? unavailableLabel,

    /// KOSPI 50% + S&P500(KRW) 50% — m2-8 F-9.
    BenchmarkSeries? benchmark,

    /// 🆕 P 회차 — 세후는 «층»이다. 단일 스칼라 필드를 만들지 않는다.
    AfterTaxLadder? afterTax,
  }) = _PerformanceSeries;

  factory PerformanceSeries.fromJson(Map<String, dynamic> json) =>
      _$PerformanceSeriesFromJson(json);
}

/// 01 §2-4 · §13-1 — 시계열 1점. 🔴 `value == null` 은 결측이며 **보간 금지**(C-10).
@freezed
abstract class PerfPoint with _$PerfPoint {
  const factory PerfPoint({
    @TradeDateConverter() required TradeDate date,

    /// 🆕 v1.3 — 가로 자리(0.0 = 그림 영역 왼쪽 끝 · 1.0 = 오른쪽 끝). 🔴 그래프 기하 전용.
    /// 점의 순서대로 **오름차순**으로 온다. 점이 1개면 0.5 다.
    required double xNormalized,

    /// 🆕 v1.3 — 이 점을 가리키는 날짜 글자("2026-08-31" · "2026년 8월" · "2026년").
    /// 주기에 맞춰 엔진이 만든다. 화면이 `date` 를 자르거나 포맷하지 않는다.
    required String dateText,

    /// 🆕 v1.3 — **표시의 정본**("1.42%"). 결측 점에도 온다("산출 불가" · "합산 제외").
    required String valueText,

    /// 🆕 v1.3 — 세로 자리(0.0 = 아래 끝 · 1.0 = 위 끝). 🔴 그래프 기하 전용.
    /// null = 결측 — 선을 끊는다. `value == null` 과 언제나 함께 온다(C-10 ⑤).
    /// 🔴 본선과 벤치마크는 **같은 축**으로 정규화돼 온다 — 화면은 축 범위를 모른다.
    double? yNormalized,

    /// 🔴 v1.3 — 골든 대조·회귀 전용. `ui_*` 에서 참조하지 않는다(C-36 ⑦). null = 결측.
    /// 결측은 공백으로 그린다 — 이어 붙이지 않는다.
    double? value,

    /// `EQUITY_SNAPSHOT_MISSING` · `RESUME_GAP` · 🆕 v1.3 `SIM_EXCLUDED`(인벤토리 §6-14).
    String? gapReasonCode,
  }) = _PerfPoint;

  factory PerfPoint.fromJson(Map<String, dynamic> json) =>
      _$PerfPointFromJson(json);
}

/// 01 §2-4 · §13-3 — 분절 구간. 🔴 `manualExecuted` 는 `simExcluded` 와 달리 합산에
/// 포함되고 경계는 실선이다(D6). 겹치면 `freshAuto` 절단선이 이긴다.
@freezed
abstract class PerfSegment with _$PerfSegment {
  const factory PerfSegment({
    @TradeDateConverter() required TradeDate from,
    @TradeDateConverter() required TradeDate to,
    required SegmentKind kind,

    /// "7거래일 미실행 — 산출 불가" — 엔진 생성.
    required String label,

    /// 🆕 v1.3 — 띠의 가로 범위(그림 영역 폭에 대한 비율 · start ≤ end). 🔴 기하 전용.
    /// 엔진이 «덮는 점의 앞뒤 반 칸»까지 넓혀서 준다(0.0~1.0 으로 자른다).
    /// 화면은 `from`·`to` 를 점의 날짜와 **비교하지 않는다**.
    /// 구간은 받은 순서대로이고 서로 겹치지 않는다(C-36 ④b).
    required double startNormalized,
    required double endNormalized,
  }) = _PerfSegment;

  factory PerfSegment.fromJson(Map<String, dynamic> json) =>
      _$PerfSegmentFromJson(json);
}

/// 🆕 v1.3 · 01 §13-1 — 세로축 눈금 1개.
@freezed
abstract class PerfAxisTick with _$PerfAxisTick {
  const factory PerfAxisTick({
    /// 세로 자리(0.0~1.0). 🔴 기하 전용.
    required double normalized,

    /// "0%" · "4%" — 엔진 생성.
    required String label,

    /// 0 기준선인가. 한 시리즈에 많아야 하나다(C-36 ④).
    @Default(false) bool isBaseline,
  }) = _PerfAxisTick;

  factory PerfAxisTick.fromJson(Map<String, dynamic> json) =>
      _$PerfAxisTickFromJson(json);
}

/// 01 §2-4 · m2-8 F-9 — 벤치마크 시리즈.
@freezed
abstract class BenchmarkSeries with _$BenchmarkSeries {
  const factory BenchmarkSeries({
    required String label,

    /// 🆕 v1.3 — 본선(`PerformanceSeries.points`)과 **같은 길이 · 같은 날짜 순서 ·
    /// 같은 `xNormalized`** 로 온다(C-36 ②). `yNormalized` 도 본선과 같은 축이다.
    required List<PerfPoint> points,

    /// 구성 고지 한 줄 — 엔진 생성.
    required String compositionNote,
  }) = _BenchmarkSeries;

  factory BenchmarkSeries.fromJson(Map<String, dynamic> json) =>
      _$BenchmarkSeriesFromJson(json);
}

/// 01 §2-6 · m2-8 F-8 — 기대치 문구의 유일한 운반처(🔴 **M7 화면 한정**).
/// 🔴 M8 온보딩·핸드북은 같은 문자열을 **각자의 뷰모델 필드**로 받는다 —
///    성과 타입을 건너 참조하지 않는 것이 C-3 규약이다.
@freezed
abstract class PerfDisclosure with _$PerfDisclosure {
  const factory PerfDisclosure({
    required String sampleSizeLine,
    required String interstitialText,

    /// 🔴 명령 테이블(append-only)의 이번 달 집계 — 화면이 세지 않는다(G-42).
    required int viewCountThisMonth,
    required String honestExpectationLine,
    String? drawdownCaveatLine,
  }) = _PerfDisclosure;

  factory PerfDisclosure.fromJson(Map<String, dynamic> json) =>
      _$PerfDisclosureFromJson(json);
}

/// 01 §2-4 · m2-8 A-7 · F-16 — 세후 사다리의 한 층.
/// 🔴 `valueText` 가 **표시의 정본**이다. `cagrPct`·`endMult` 는 골든 대조·회귀
///    전용이며 `ui_*` 위젯트리에서 참조하면 C-30 이 실패한다.
@freezed
abstract class AfterTaxStep with _$AfterTaxStep {
  const factory AfterTaxStep({
    /// `PRETAX`·`AFTER_POT`·`AFTER_POT_C`·`WD_5P5`·`WD_16P5`·`HONEST`
    /// (인벤토리 §6-13 · 영역 E 의 상수 목록이 정본).
    required String stepCode,

    /// "② 전 계좌 세후 — 연금 인출세 16.5%" — 엔진 생성.
    required String label,

    /// 🔴 표시의 정본. 엔진이 포맷한 완성 문자열.
    required String valueText,

    /// 🔴 골든 대조 전용 — 화면 참조 금지(C-30).
    double? cagrPct,

    /// 🔴 같음 — 층 간 차액을 빼는 경로를 데이터 형태로도 열지 않는다.
    double? endMult,
    String? noteLine,
  }) = _AfterTaxStep;

  factory AfterTaxStep.fromJson(Map<String, dynamic> json) =>
      _$AfterTaxStepFromJson(json);
}

/// 01 §2-4 — 세후 사다리. 🔴 갈래는 **계좌 배치가 정한다**(SAF-309) —
/// 화면·인자로 고르는 경로를 만들지 않는다.
@freezed
abstract class AfterTaxLadder with _$AfterTaxLadder {
  const factory AfterTaxLadder({
    required TaxLadderBranch branch,

    /// "POT = 절세계좌(명세 준수)" — 엔진 생성.
    required String branchLabel,

    /// 🔴 순서 그대로 그린다. 층을 합치거나 건너뛰지 않는다.
    required List<AfterTaxStep> steps,

    /// 🔴 숫자 상수 금지 — 엔진 생성 문장을 그대로 그린다.
    required String honestExpectationLine,
    required String basisNote,

    /// 🔴 §8-18 확정 전에는 **항상 true**(골든 참고치이지 실계좌 산출이 아니다).
    /// 🔴 SIM 에서도 이 라벨을 유지한다(01 §9-4).
    required bool isReferenceOnly,
    required String configHash,
    required AsOf asOf,
  }) = _AfterTaxLadder;

  factory AfterTaxLadder.fromJson(Map<String, dynamic> json) =>
      _$AfterTaxLadderFromJson(json);
}

/// 01 §2-6 · m2-8 F-7 — 월간 1페이지 리포트(`S7-1`).
/// 🔴 **단일 `afterTaxPct` 필드를 만들지 않는다** — 세후는 `AfterTaxLadder` 로만
///    실어 나른다. 🔴 반사실 항목을 14번째로 늘리지 않는다(C-25).
@freezed
abstract class MonthlyReport with _$MonthlyReport {
  const factory MonthlyReport({
    required String yyyyMm,

    /// 🔴 **13항목 고정 배열**. 결측에서도 자리를 유지하며 항목을 더하거나
    ///    빼지 않는다(03 §3 · C-25).
    required List<ReportItem> items,
    required String goalLine,

    /// 🔴 화면이 「n회」를 숫자로 조립하지 않는다(G-42).
    required String disclosureViewCountText,

    /// X7 — 헤더 배지(01 §2-11 · G-97).
    required LedgerTrustBadge trust,
    required AsOf asOf,

    /// 세후 사다리. 🔴 13항목 배열에는 넣지 않는다(03 §3).
    AfterTaxLadder? afterTax,

    /// 전월 소급 정정 각주 — 🔴 마감된 달을 재계산하지 않는다(G-97).
    String? backdateFootnote,

    /// 🆕 v1.1(§8 미결 40) — 미생성 달의 한 문장: "9월 1일 생성일에 만들어집니다 · D-4".
    /// 🔴 non-null 이면 헤더 아래에 그대로 그린다. 화면이 D-day 를 계산하지 않는다.
    String? pendingNoticeText,

    /// 🆕 v1.1(§8 미결 43) — "2026-09-01 생성" · 미생성이면 null.
    String? generatedAtText,

    /// 🆕 v1.1(§8 미결 43) — 이 리포트를 만든 설정의 해시(모노스페이스 축약 표시용).
    /// 🔴 화면이 다른 해시와 비교하지 않는다(contract_version.dart 말미 조문). 미생성이면 null.
    String? configHash,

    /// 🆕 v1.4(01 §14-9) — «목표 경로 보기» 버튼의 목적지(`AppRoutes.reportGoalPath` 꼴 · C-33).
    /// null = **버튼 부재**(자리표시자 없음). 엔진은 과거 달·가림·미생성 달이면 null 로 둘 수 있다.
    /// 🔴 화면은 이 문자열을 해석·조립하지 않고 `AppLinkOpener.open` 에 그대로 넘긴다.
    String? goalDeepLink,
  }) = _MonthlyReport;

  factory MonthlyReport.fromJson(Map<String, dynamic> json) =>
      _$MonthlyReportFromJson(json);
}

/// ⚠️ **M2-8 미확정** — `m2-8_naming.md` F-7 이 `List<ReportItem>` 이라는 **이름만**
/// 확정했고 필드 축은 어느 문서에도 없다. 아래는 03 §3(13항목 고정 배열 · 섹션
/// A~G · 「결측에서도 자리를 유지」 · 전부 엔진 완성 문자열)에서 읽어낸 **임시
/// 최소 축**이며, `AnnualReviewSection`(F-6)·`OpsRhythmRow`(G-2)와 같은 모양이다.
/// 🔴 화면 담당은 이 타입을 픽스처 고정 모드로만 쓰고, 축 확정 전에는 항목을
///    코드로 세거나 순서를 재정렬하지 않는다.
@freezed
abstract class ReportItem with _$ReportItem {
  const factory ReportItem({
    required String code,

    /// 🔴 13항목의 고정 순서. 화면이 정렬 키를 만들지 않는다.
    required int order,

    /// 섹션 A~G(03 §3).
    required String sectionCode,
    required String title,

    /// 🔴 엔진 완성 문자열 — 결측이면 그 사실도 이 문자열이 말한다.
    /// 🔴 차단 시 가림도 엔진 읽기 경로가 끝낸다(01 §2-10) — 화면은 바꾸지 않는다.
    required String valueText,
    String? noteText,

    /// 🆕 v1.1(§8 미결 41) — 이 항목의 「자세히」 목적지. 🔴 **non-null 인 항목에만** 버튼을
    ///    그린다. 어느 항목에 링크가 붙는지는 엔진이 정한다 — 화면이 `order`·`code`·
    ///    `OperatingMode` 로 판정하지 않는다.
    String? detailDeepLink,
  }) = _ReportItem;

  factory ReportItem.fromJson(Map<String, dynamic> json) =>
      _$ReportItemFromJson(json);
}

/// 01 §2-6 · m2-8 F-1 — 월간 리포트 아카이브(`S7-1b`). 🔴 **수치 필드 0건**.
@freezed
abstract class ReportArchiveVm with _$ReportArchiveVm {
  const factory ReportArchiveVm({
    /// 🆕 v1.3 — 엔진이 **최신 달부터** 정렬해서 준다. 화면은 받은 순서 그대로 그린다.
    required List<ReportArchiveRow> rows,
    required AsOf asOf,
    String? emptyLabel,
  }) = _ReportArchiveVm;

  factory ReportArchiveVm.fromJson(Map<String, dynamic> json) =>
      _$ReportArchiveVmFromJson(json);
}

/// m2-8 F-1 — 아카이브 1행. 🔴 수치 컬럼이 없다(`rm_report_archive`).
@freezed
abstract class ReportArchiveRow with _$ReportArchiveRow {
  const factory ReportArchiveRow({
    required String yyyyMm,
    required String label,
    required bool generated,

    /// 🔴 모드 표시도 엔진 문자열이다 — 화면이 `RunMode` 로 분기하지 않는다.
    required String modeLabel,
    String? reasonLabel,
    String? route,

    /// 🆕 v1.3 — non-null 이면 **이 행 위에** 머리글 1줄을 그린다("2026년" · "2025년 · 모의투자").
    /// 🔴 화면은 앞 행과 비교하지 않는다 — 묶음의 첫 행에만 엔진이 실어 준다.
    String? sectionLabel,
  }) = _ReportArchiveRow;

  factory ReportArchiveRow.fromJson(Map<String, dynamic> json) =>
      _$ReportArchiveRowFromJson(json);
}

/// 01 §4-1 · m2-8 F-2 — 성과 열람 게이트(`S7-2G`).
/// 🔴 `viewCountThisMonth` 숫자 필드를 두지 않는다 — 화면이 「n회」를 조립하지
///    않게 `viewCountText` 하나만 온다.
@freezed
abstract class DisclosureGateVm with _$DisclosureGateVm {
  const factory DisclosureGateVm({
    /// 🆕 v1.3(뜻 확정 · 01 §13-5) — **엔진이 지금 진입을 허용하는가.**
    /// false 면 「그래도 보기」가 없다(「돌아가기」만). «게이트를 건너뛴다»는 뜻이 아니다.
    required bool gateOpen,

    /// 게이트 머리 문장 — 엔진 생성. 닫힌 게이트에서는 **닫힌 까닭**을 말한다.
    required String headline,
    required String viewCountText,
    required AsOf asOf,

    /// 🆕 v1.3(뜻 확정) — null = **그 줄이 없다**(자리표시자·빈 줄을 그리지 않는다).
    String? frictionLine,

    /// 🆕 v1.3(뜻 확정) — `gateOpen` 의 링크 표현이다(`gateOpen == (route != null)` · C-37 ①).
    /// **게이트 밖 진입점용**이며 🔴 게이트 화면은 이 링크를 열지 않는다
    /// (열면 자기 자신이 다시 뜬다).
    String? route,
  }) = _DisclosureGateVm;

  factory DisclosureGateVm.fromJson(Map<String, dynamic> json) =>
      _$DisclosureGateVmFromJson(json);
}

/// 01 §2-6 · m2-8 F-3 — 드로다운 맥락(`S7-3`).
/// 🔴 `referenceBandCaveatText` 가 null 이면 그 줄을 **그리지 않는다**
///    («최대낙폭은 하한»의 단서이며 화면이 대신 문장을 짓지 않는다).
@freezed
abstract class DrawdownContextVm with _$DrawdownContextVm {
  const factory DrawdownContextVm({
    /// "최근 24개월" — `range == null` 이면 엔진 기본 구간이고 그 결과를 이 문구가 말한다.
    required String periodLabel,

    // 🔴 아래 세 값은 짧은 숫자가 아니라 **제목을 포함한 엔진 완성 문장**이다(C4 R2-Gem-S73
    //    교훈). 화면이 제목을 따로 달면 같은 말을 두 번 하게 되고, 좁은 칸에 넣으면
    //    들어가지 않는다 — 전체 폭 한 줄씩 그린다. `FittedBox` 로 줄이지 않는다.
    /// "현재 낙폭 −2.1%"
    required String currentDdText,

    /// "최대 낙폭 −6.4%"
    required String maxDdText,

    /// "회복까지 걸린 최장 기간 3개월"
    required String tuwText,

    /// 🔴 게이지 폭 전용 정규값(0.0~1.0). 표시는 `*Text` 필드다.
    required double ddNormalized,
    required AsOf asOf,
    String? referenceBandText,
    String? referenceBandCaveatText,
  }) = _DrawdownContextVm;

  factory DrawdownContextVm.fromJson(Map<String, dynamic> json) =>
      _$DrawdownContextVmFromJson(json);
}

/// 01 §2-6 · m2-8 F-4 — **슬리브 기여 분해**(`S7-3b` · 03 §10).
/// 🔴 `MonthlyContributionVm`(월 납입 운영값 카드 · `settings.dart`)과 **다른
///    타입**이며 이름을 공유하지 않는다(01 §2-6 이름 충돌 방지 조문 · N-01).
/// 🔴 **종목 단위 행 없음**.
@freezed
abstract class ContributionVm with _$ContributionVm {
  const factory ContributionVm({
    required String periodLabel,
    required List<ContributionRow> rows,
    required String methodNoteText,
    required AsOf asOf,
    String? fxNoteText,
  }) = _ContributionVm;

  factory ContributionVm.fromJson(Map<String, dynamic> json) =>
      _$ContributionVmFromJson(json);
}

/// m2-8 F-4 — 슬리브 1행. 🔴 `normalized` 는 막대 폭 전용이고 표시는
/// `contributionText` 다(화면이 비율로 문장을 만들지 않는다).
@freezed
abstract class ContributionRow with _$ContributionRow {
  const factory ContributionRow({
    required SleeveId sleeve,

    /// "A · 국내 지수 ETF" — 엔진 생성(화면이 `sleeve` 로 문구를 고르지 않는다)
    required String label,

    /// "+0.42%p" · 산출 불가면 "산출 불가" — 엔진 생성
    required String contributionText,

    /// 막대 폭 전용(0.0~1.0). 🔴 [unavailableLabel] 이 non-null 이면 **0.0** 으로 온다.
    required double normalized,

    /// 🆕 v1.1(§8 미결 45) — 「이 슬리브는 산출할 수 없다」의 사유 한 줄
    ///    ("8월 12~14일 가격 결측 — 산출 불가"). 🔴 non-null 이면 **막대를 그리지 않고**
    ///    이 문장을 그린다. 🔴 화면이 나머지 행을 100% 로 재정규화하지 않는다(03 §8).
    String? unavailableLabel,
  }) = _ContributionRow;

  factory ContributionRow.fromJson(Map<String, dynamic> json) =>
      _$ContributionRowFromJson(json);
}

/// 01 §2-6 · m2-8 F-6 — 연간 리뷰(`S7-7`). 🔴 **묶음이지 재집계가 아니다** —
/// 화면이 `windowState` 를 «달»로 판정하지 않는다.
/// 🔴 세후는 `AfterTaxLadder` 를 그대로 실어 나르고 재계산하지 않는다(M1-20b).
@freezed
abstract class AnnualReviewVm with _$AnnualReviewVm {
  const factory AnnualReviewVm({
    required String year,
    required String windowStateCode,
    required String windowStateLabel,
    required List<AnnualReviewSection> sections,
    required AsOf asOf,
  }) = _AnnualReviewVm;

  factory AnnualReviewVm.fromJson(Map<String, dynamic> json) =>
      _$AnnualReviewVmFromJson(json);
}

/// m2-8 F-6 — 연간 리뷰 섹션. 🔴 `lines` 는 전부 엔진 완성 문자열이다.
@freezed
abstract class AnnualReviewSection with _$AnnualReviewSection {
  const factory AnnualReviewSection({
    required String code,
    required String title,
    required List<String> lines,
    String? route,
  }) = _AnnualReviewSection;

  factory AnnualReviewSection.fromJson(Map<String, dynamic> json) =>
      _$AnnualReviewSectionFromJson(json);
}

/// 01 §2-6 · m2-8 F-15 · 🆕 v1.4 01 §14-10 — 목표 경로(`S7-9`).
/// 🔴 **01 §14-10 «필드 → 자리» 대응표가 정본**이다. 화면은 필드마다 정해진 한 자리에만 그린다.
/// 🔴 v1.4 — C-4 «`basisText`·`backtestBasisText` 를 동시에 그리지 않는다» 조문은 **폐기**됐다
///    (03 §14 가정 카드가 두 줄을 요구한다). 대신 역할을 고정한다: `basisText` = 판정 근거 줄 ·
///    `backtestBasisText` = 가정 카드 1줄 · `startingCapitalAssumptionText` = 가정 카드 2줄
///    (03 §14·§17-17 의 `contributionAssumptionText` 를 대체 · 01 §14 결정 뒤집기 기록).
/// 🔴 `honestExpectationText`·`honestExpectationWorstText` 는 세후 사다리 마지막 층을 인용하는
///    **완성 문장**이지 스칼라가 아니다 — 01 §2-6 «`PerfDisclosure` = 기대치 문구의 유일한
///    운반처(M7 한정)»의 **명시 예외**(01 §14 · 문자열 출처는 같은 엔진 상수 블록). 화면은 숫자를
///    옮겨 적지 않는다.
/// 🔴 `planned`·`actual` 은 `PerfPoint` 를 재사용한다(01 §13 세 식 준용 · C-39). 화면이 두 목록을
///    합치거나 차액·달성률을 계산하지 않는다.
/// 🔴 S7-9 는 `ConfigRepository` 를 읽지 않는다(03 §17-17 이 이긴다).
@freezed
abstract class GoalPathVm with _$GoalPathVm {
  const factory GoalPathVm({
    /// 🆕 v1.4 — 이 경로의 달(`yyyy-MM`). Key 용 · 🔴 표시 금지.
    required String yyyyMm,

    /// 🆕 v1.4 — «유지»/«이탈»/«판정 유보» 문장 — 엔진 생성.
    required String judgementText,

    /// 역할 고정(v1.4): **판정 근거 줄**.
    required String basisText,

    /// 🆕 v1.4 — 이탈 문장(구 봉투 `lag_notice` 승격) — null = 줄 부재.
    String? deviationText,

    /// 🆕 v1.4 — 이 경로가 덮는 기간 — 엔진 생성.
    required String periodLabel,

    /// 🆕 v1.4 — 범례: 계획선.
    required String plannedLabel,

    /// 🆕 v1.4 — 범례: 실제선.
    required String actualLabel,

    /// 🆕 v1.4 — 계획선. 🔴 `yNormalized` 결측 없음 · [actual] 과 같은 길이·date·xNormalized(C-39 ②).
    required List<PerfPoint> planned,

    /// 🆕 v1.4 — 실제선. 결측(`yNormalized == null`)은 선을 끊는다 — 보간 금지(C-10 준용).
    required List<PerfPoint> actual,

    /// 🆕 v1.4 — 세로축 눈금(아래 → 위) · 많아야 5개(C-39 ④).
    required List<PerfAxisTick> yTicks,

    /// 🆕 v1.4 — 갭·SIM 제외 띠 — 받은 순서 · 겹침 없음(C-39 ⑤).
    required List<PerfSegment> segments,

    /// 🆕 v1.4 — non-null ⇔ [planned]·[actual]·[yTicks]·[segments] 가 모두 빈 목록(C-39 ③).
    /// 그때는 차트 대신 이 문장 카드 1장이고 [deviationText] 는 null 이다.
    String? chartUnavailableLabel,

    /// 역할 고정(v1.4): **가정 카드 1줄**(백테스트 기준 실행).
    required String backtestBasisText,

    /// 역할 고정(v1.4): **가정 카드 2줄**(당신의 현재 원금·납입).
    required String startingCapitalAssumptionText,

    /// 🆕 v1.4 — 정직 기대 본값 **인용 문장**(위 예외 조문).
    required String honestExpectationText,

    /// 최악 가정 한 문장(인용 문장 · 위 예외 조문).
    required String honestExpectationWorstText,

    /// 🆕 v1.4 — «보증하지 않습니다» 엔진 고지.
    required String disclaimerText,
    required AsOf asOf,
  }) = _GoalPathVm;

  factory GoalPathVm.fromJson(Map<String, dynamic> json) =>
      _$GoalPathVmFromJson(json);
}
