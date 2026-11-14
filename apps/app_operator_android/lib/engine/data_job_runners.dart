// 데이터 잡 실물(E11p3c-1 · 설계 13 §8 R97 · 06 M1-28 · R47 F4 · F5) — `daily_signal` · `us_data`.
//
// 🔴 본체는 data_sync 그대로 — 여기는 부품을 넣고 `runOccurrence`(세션일 · 마감 = 회차 값)로 감싸기만 한다.
//    보고의 알림 코드는 `JobBody.alerts` 로 넘긴다(R42 S2 · trading_runtime ↛ data_sync).
// 🔴 사람 값(A 종목 · 계좌)이 드는 잡(daily_data · equity_snapshot · seasonal_a · monthly_rebalance)은 여기 없다 — p3c-2.
// 🔴 수집 실패는 회차를 실패시키지 않는다(본체 규칙 · P1 `DATA_SOURCE_DOWN`). 일봉 원천을 **못 만들면**(KIS 키 없음) 회차 실패.

import 'package:core_engine/core_engine.dart' show DailyQuoteFeed;
import 'package:data_sync/data_sync.dart'
    show
        DailySignalJob,
        DailySignalReport,
        FredClient,
        MacroCollector,
        OfrClient,
        QuoteCollector,
        UsDataJob,
        UsDataReport;
import 'package:domain_contracts/domain_contracts.dart' show RunMode, TradeDate;
import 'package:trading_runtime/trading_runtime.dart'
    show JobBody, JobOccurrence;

import 'job_runners.dart' show JobContext, JobRunner, runOccurrence;

/// 실물 잡이 쓰는 바깥 부품(조립 앱이 한 번 만든다 · 시험이 가짜를 넣는다).
class JobParts {
  /// 만든다.
  const JobParts({
    required this.quoteFeed,
    required this.fred,
    required this.ofr,
    required this.regimeConfigHash,
  });

  /// 🔴 [RunMode] 의 일봉 원천(KIS · 모드 세트) — 못 만들면 던진다(그 회차 실패).
  final Future<DailyQuoteFeed> Function(RunMode mode) quoteFeed;

  /// FRED(키 없음 = CSV · R47).
  final FredClient fred;

  /// OFR 금융스트레스지수.
  final OfrClient ofr;

  /// 국면 설정 지문(`p0sRegimeConfigHash` · 사람 값 없음).
  final String regimeConfigHash;
}

/// `daily_signal`(20:00 KST) — 저장된 시세 · 계열 → 국면 → `regime_score_daily`(네트워크 0).
JobRunner dailySignalRunner(JobContext c, JobParts p) =>
    (JobOccurrence o) =>
        runOccurrence<DailySignalReport>(c, o, (TradeDate day) async {
          final DailySignalReport r = await DailySignalJob(
            c.db,
            configHash: p.regimeConfigHash,
          ).run(day);
          return JobBody<DailySignalReport>(r, alerts: r.alerts);
        });

/// `us_data`(07:30 KST · 앞 XNYS 세션) — US 국면 대상 4(KIS 해외 · 모드 세트) + 매크로(FRED · OFR).
JobRunner usDataRunner(JobContext c, JobParts p) =>
    (JobOccurrence o) => runOccurrence<UsDataReport>(c, o, (
      TradeDate day,
    ) async {
      final DailyQuoteFeed feed = await p.quoteFeed(c.runMode);
      final UsDataReport r = await UsDataJob(
        collector: QuoteCollector(
          c.db,
          feed: feed,
          clock: c.clock,
          kr: c.calendars.kr,
          us: c.calendars.us,
        ),
        macro: MacroCollector(c.db, fred: p.fred, ofr: p.ofr, clock: c.clock),
      ).run(day);
      return JobBody<UsDataReport>(r, alerts: r.alerts);
    });

/// 🔴 실물 칸(잡 → 만들기) — 여기 없는 잡은 미조립(설계 Q7).
const Map<String, JobRunner Function(JobContext, JobParts)> kAssembledRunners =
    <String, JobRunner Function(JobContext, JobParts)>{
      'daily_signal': dailySignalRunner,
      'us_data': usDataRunner,
    };
