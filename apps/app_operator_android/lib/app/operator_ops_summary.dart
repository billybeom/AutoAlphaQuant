// E11p3d-2b — H-01 운영 홈 · H-02 운영 리듬 읽기 모델(설계 13 §8 R133 · 발주자 «H-01 맡아» 2026-11-16).
//
// 🔴 오늘 요약 · 리듬 = 화면 상태(마지막 깨어남의 원장 · 모드)의 `SqliteOpsHomeSource` — 원장이 바뀌면 · 1분마다(날짜 ·
//    D-day 넘어감) · 화면 상태가 바뀌면 다시 낸다(`followView`).
// 🔴 신뢰 시각 = 아직 없음(Supabase 리스 전 · E11k) → 재량 예산 = 엔진 문장 «신뢰 시각 확인 중».
// 🔴 홈의 나머지 셋(안내 요약 · 슬리브 비중 · 원장 실사 배지)은 원천이 없다 — 지어내지 않고 «원천 없음» 오류를 낸다
//    (안내 · 실사 = 블록 부재 · 비중 = 블록 다시 시도 · 04 §4-1 표시 조건 그대로).

import 'package:data_sync/data_sync.dart'
    show SqliteHoldingsOverviewSource, SqliteOpsHomeSource, watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AdviceInboxSummary,
        AdviceItem,
        AdviceRepository,
        AdviceStatus,
        DateRange,
        HoldingDetailVm,
        HoldingRow,
        HoldingsOverviewVm,
        HoldingsRepository,
        LedgerTrustBadge,
        LedgerTrustRepository,
        ListResult,
        ManualFillFormSpec,
        OpsDailySummary,
        OpsRhythmRow,
        OpsSummaryRepository,
        SelfReportSession,
        SleeveAllocationVm,
        TradeJournalEntry;

import '../engine/fgs_status_source.dart' show UnknownTrustedClock;
import 'operator_runtime.dart';
import 'operator_view.dart';
import 'view_stream.dart';

/// 홈 오늘 요약 · 운영 리듬(operator).
class OperatorOpsSummaryRepository implements OpsSummaryRepository {
  /// 만든다 — [tick] = 날짜 · D-day 넘어감 확인 주기.
  OperatorOpsSummaryRepository(
    this._rt, {
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 다시 읽는 주기.
  final Duration tick;

  SqliteOpsHomeSource _src(OperatorView v) => SqliteOpsHomeSource(
    v.db,
    clock: _rt.clock,
    trusted: const UnknownTrustedClock(),
    kr: _rt.calendars.kr,
    runMode: v.flags.runMode,
    operatingMode: v.flags.operatingMode,
  );

  Stream<T> _follow<T>(T Function(SqliteOpsHomeSource s) read, String what) =>
      followView<T>(
        view: _rt.view,
        changes: (OperatorView v) => watchLedgerQuery<T>(
          v.db,
          SqliteOpsHomeSource.watchedTables,
          () => read(_src(v)),
        ),
        now: (OperatorView v) => read(_src(v)),
        tick: tick,
        noView: () => StateError('$what: 화면 상태 없음(온보딩 전)'),
      );

  @override
  Stream<OpsDailySummary> watchToday() =>
      _follow((SqliteOpsHomeSource s) => s.today(), '운영 홈');

  @override
  Stream<ListResult<OpsRhythmRow>> watchRhythm() =>
      _follow((SqliteOpsHomeSource s) => s.rhythm(), '운영 리듬');
}

Stream<T> _none<T>(String what) =>
    Stream<T>.error(UnsupportedError('$what: 원천 없음(R133)'));

Future<T> _noneNow<T>(String what) =>
    Future<T>.error(UnsupportedError('$what: 원천 없음(R133)'));

/// 안내(X7) — 원천 없음(엔진 E18 전 · 홈 블록 3b = 부재).
class OperatorAdviceRepository implements AdviceRepository {
  /// 만든다.
  const OperatorAdviceRepository();

  @override
  Stream<ListResult<AdviceItem>> watchInbox({
    AdviceStatus? status,
    int limit = 50,
  }) => _none('watchInbox');

  @override
  Stream<AdviceInboxSummary> watchSummary() => _none('watchSummary');

  @override
  Future<AdviceItem?> findById(String adviceId) => _noneNow('findById');

  @override
  Stream<ListResult<AdviceItem>> watchHistory({required DateRange range}) =>
      _none('watchHistory');

  @override
  Stream<ManualFillFormSpec> watchManualFillFormSpec() =>
      _none('watchManualFillFormSpec');

  @override
  Future<List<TradeJournalEntry>> fillsOfAdvice(String adviceId) =>
      _noneNow('fillsOfAdvice');
}

/// 보유 · 슬리브 비중 — 🆕 E11q1(R171) H6-1 보유 현황 = 원장(모의 = 가상 현금 · 엔진 VM) · 나머지 셋 = 원천 없음
/// (H6-2 상세 · H6-3 배분 = q1 다음 조각 · 홈 블록 4 = 다시 시도).
///
/// 🔴 H6-1 = 화면 상태의 원장 — 원장이 바뀌면 · 1분마다(기준 줄) · 화면 상태가 바뀌면 다시 낸다(`followView`) ·
///    손익 펼침([includePnl])은 아직 원천이 없어 같은 VM(펼침 글자 = 엔진이 내지 않음) · 링크 = 등록된 화면만([hasBody]).
class OperatorHoldingsRepository implements HoldingsRepository {
  /// 만든다 — [hasBody] = 셸 레지스트리에 본문이 있나 · [tick] = 기준 줄 갱신 주기.
  OperatorHoldingsRepository(
    this._rt, {
    required this.hasBody,
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  /// 다시 읽는 주기.
  final Duration tick;

  SqliteHoldingsOverviewSource _src(OperatorView v) =>
      SqliteHoldingsOverviewSource(
        v.db,
        clock: _rt.clock,
        kr: _rt.calendars.kr,
        runMode: v.flags.runMode,
        accountLabels:
            _rt.humanDecision?.accountLabels ?? const <String, String>{},
        hasBody: hasBody,
      );

  @override
  Stream<ListResult<HoldingRow>> watchHoldings({bool includePnl = false}) =>
      _none('watchHoldings');

  @override
  Stream<HoldingsOverviewVm> watchHoldingsOverview({bool includePnl = false}) =>
      followView<HoldingsOverviewVm>(
        view: _rt.view,
        changes: (OperatorView v) => watchLedgerQuery<HoldingsOverviewVm>(
          v.db,
          SqliteHoldingsOverviewSource.watchedTables,
          () => _src(v).overview(),
        ),
        now: (OperatorView v) => _src(v).overview(),
        tick: tick,
        noView: () => StateError('보유 현황: 화면 상태 없음(온보딩 전)'),
      );

  @override
  Stream<HoldingDetailVm> watchHoldingDetail(
    String holdingId, {
    bool includePnl = false,
  }) => _none('watchHoldingDetail');

  @override
  Stream<SleeveAllocationVm> watchAllocation() => _none('watchAllocation');
}

/// 원장 신뢰 배지 · 실사 — 원천 없음(X7 실사 전 · 홈 블록 9b = 부재).
class OperatorLedgerTrustRepository implements LedgerTrustRepository {
  /// 만든다.
  const OperatorLedgerTrustRepository();

  @override
  Stream<LedgerTrustBadge> watchGrade() => _none('watchGrade');

  @override
  Stream<SelfReportSession> watchSelfReportSession(
    String yyyyMm,
    String accountAlias,
  ) => _none('watchSelfReportSession');
}
