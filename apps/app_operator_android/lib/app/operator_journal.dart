// 🆕 E11q-q4a — M6 매매일지 «읽기» 저장소(operator · J-1 타임라인 · 필터 · 배지 · J-2 거래 상세 · J-3R 사전 저널 읽기 ·
// 회차 범위 · 설계 13 §8 · 나눔 계획 R169 q4a).
//
// 🔴 셈 · 글자 = 엔진(`journalTimelineOf` …) · 원천 = `SqliteJournalSource`(원장 원문) · 여기는 흐름만 잇는다
//    (원장 변경 · 주기 · 화면 상태마다 다시 읽는다 — q1 `OperatorHoldingsRepository` 꼴 · 바뀐 값만).
// 🔴 운영 폰의 일지 = 엔진이 지금 쓰는 원장 한 파일(모의 기간 = 모의 원장 · 파일이 모드 경계 · 01 §9-1) —
//    `mode` 인자는 쓰지 않는다: J-1 이 인자를 넘기지 않아 늘 LIVE 로 오고(01 §8 미결 89), 거르면 모의 체험의 일지가 빈다.
//    행마다 `mode` 가 모의 배지를 말한다(02 §3-1).
// 🔴 링크 = 셸 레지스트리에 본문이 있는 화면만(엔진 `hasBody`).
// 🆕 E11q-q4b — J-5 미해소 보드(같은 원천 · 같은 감시 표).
// 🆕 미결 220 ⓔ — J-3 사전 저널 폼 스펙(키 = 저널 id · 갈래 = 엔진 `SqliteJournalDraftStore.targetOf` · 모르는 키 = 오류 ·
//    서약 줄 = sim 원장의 지금 서약(R157 · 재량 예산을 쓰는 목적에만 — 엔진) · 재량 배지 = 재량 예산(신뢰 시각 모름 = 머리만)) ·
//    J-3R = 저널 id 먼저(엔진 `decisionJournalVmOf`).
//    조각 조회 셋(`findByDecisionId` · `chainOf` · `fillChain`)은 J-2 가 쓰지 않는다(그 화면은 상세 하나만 구독) → 원천 없음.
// 🆕 E11q-j4 — J-4 blind 리뷰 큐 · 카드(같은 원천 · 같은 감시 표 · 엔진 `blindReviewQueueOf` · `blindReviewCardOf`) —
//    K24 = 이 원장의 모드(화면 상태의 실행 모드)와 인자가 모두 LIVE 일 때만 대상(모의 기간 = 해당 없음 빈 문장) ·
//    카드 = 모르는 · 대상 아닌 결정 = 오류. 🆕 E11q-j4s 채점 기록 = 명령 API(`SqliteBlindReviewStore` · SPEC v2.47) — 그 갱신에서
//    큐 · 배지 이탈 + 카드 결과(감시 표 `blind_review_score` · 엔진 `blindReviewCardOf`).

import 'package:core_engine/core_engine.dart'
    show JournalDraftTarget, journalDraftFormSpecOf, journalKeyOf;
import 'package:data_sync/data_sync.dart'
    show
        SqliteDiscretionStore,
        SqliteJournalDraftStore,
        SqliteJournalSource,
        SqlitePledgeStore,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        BlindReviewCard,
        DateRange,
        DecisionDetailVm,
        DecisionJournalVm,
        FillOrigin,
        JournalDraftFormSpec,
        JournalFilterCatalog,
        JournalRebalanceScope,
        JournalRepository,
        JournalStatus,
        JournalTimelineBadge,
        ListResult,
        RunMode,
        SleeveId,
        TradeJournalEntry,
        UnknownBoardVm;
import 'package:flutter/foundation.dart' show listEquals;

import 'operator_runtime.dart';
import 'operator_self_report.dart' show OperatorSelfReportSessions, mergeKicks;
import 'operator_view.dart';
import 'view_stream.dart';

/// 매매일지 읽기 저장소(J-1 · J-2 · J-3R).
class OperatorJournalRepository implements JournalRepository {
  /// 만든다 — [hasBody] = 셸 레지스트리에 본문이 있나 · [tick] = 기준 줄 · 날짜 갱신 주기.
  OperatorJournalRepository(
    this._rt, {
    required this.hasBody,
    this.tick = const Duration(minutes: 1),
    this.selfReportSessions,
  });

  final OperatorRuntime _rt;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  /// 다시 읽는 주기.
  final Duration tick;

  /// 🆕 E11q-q6 — `L-3` 실사 세션 장부(열린 동안 = «숨김» · 바뀌면 곧바로 다시 읽는다 · 없음 = 가림 0).
  final OperatorSelfReportSessions? selfReportSessions;

  SqliteJournalSource _src(OperatorView v) => SqliteJournalSource(
    v.db,
    clock: _rt.clock,
    kr: _rt.calendars.kr,
    runMode: v.flags.runMode,
    accountLabels: _rt.humanDecision?.accountLabels ?? const <String, String>{},
    hasBody: hasBody,
    selfReportSessionOpen: selfReportSessions?.anyOpen,
  );

  Stream<T> _follow<T>(
    T Function(SqliteJournalSource s) read,
    String what, {
    bool Function(T a, T b)? equals,
  }) => followView<T>(
    view: _rt.view,
    changes: (OperatorView v) => mergeKicks<T>(
      watchLedgerQuery<T>(
        v.db,
        SqliteJournalSource.watchedTables,
        () => read(_src(v)),
      ),
      selfReportSessions?.changes ?? const Stream<void>.empty(),
      () => read(_src(v)),
    ),
    now: (OperatorView v) => read(_src(v)),
    tick: tick,
    noView: () => StateError('$what: 화면 상태 없음(온보딩 전)'),
    equals: equals,
  );

  @override
  Stream<ListResult<TradeJournalEntry>> watchTimeline({
    required DateRange range,
    SleeveId? sleeve,
    String? symbol,
    JournalStatus? status,
    FillOrigin? origin,
    String? rebalanceEventId,
    RunMode mode = RunMode.live,
    int limit = 100,
  }) => _follow(
    (SqliteJournalSource s) => s.timeline(
      range: range,
      sleeve: sleeve,
      symbol: symbol,
      status: status,
      origin: origin,
      rebalanceEventId: rebalanceEventId,
      limit: limit,
    ),
    '매매일지',
  );

  @override
  Stream<JournalFilterCatalog> watchFilterCatalog() =>
      _follow((SqliteJournalSource s) => s.filterCatalog(), '일지 필터');

  @override
  Stream<List<JournalTimelineBadge>> watchTimelineBadges({
    RunMode mode = RunMode.live,
  }) => _follow(
    (SqliteJournalSource s) => s.badges(),
    '일지 배지',
    equals: listEquals,
  );

  @override
  Stream<DecisionDetailVm> watchDecisionDetail(String decisionId) =>
      _follow((SqliteJournalSource s) => s.decisionDetail(decisionId), '거래 상세');

  @override
  Stream<DecisionJournalVm> watchDecisionJournal(String decisionId) => _follow(
    (SqliteJournalSource s) => s.decisionJournal(decisionId),
    '사전 저널',
  );

  @override
  Stream<JournalRebalanceScope?> watchRebalanceScope(String rebalanceEventId) =>
      _follow(
        (SqliteJournalSource s) => s.rebalanceScope(rebalanceEventId),
        '회차 범위',
      );

  // ── 원천 없음(사전 저널 쓰기 = 계약 창 · blind 리뷰 = 실전 전 · J-2 가 쓰지 않는 조각 조회) ──

  @override
  Future<TradeJournalEntry?> findByDecisionId(String decisionId) =>
      _noneNow('findByDecisionId');

  @override
  Future<List<TradeJournalEntry>> chainOf(String decisionId) =>
      _noneNow('chainOf');

  @override
  Future<List<TradeJournalEntry>> fillChain(String entryId) =>
      _noneNow('fillChain');

  /// 🆕 미결 220 ⓔ — J-3 폼 스펙(키 = 저널 id · 모르는 키 · 화면 상태 없음 = 오류).
  @override
  Future<JournalDraftFormSpec> draftFormSpec(String decisionId) async {
    final OperatorView? v = _rt.view.value;
    if (v == null) throw StateError('사전 저널 폼: 화면 상태 없음(온보딩 전)');
    final String key = journalKeyOf(decisionId);
    final JournalDraftTarget? t = SqliteJournalDraftStore(
      v.db,
      clock: _rt.clock,
    ).targetOf(key);
    if (t == null) throw StateError('사전 저널 폼: 모르는 키 $key');
    return journalDraftFormSpecOf(
      t,
      pledgeLines: SqlitePledgeStore(
        _rt.files.sim,
        clock: _rt.clock,
        trusted: _rt.trusted,
      ).pledgeLines(),
      budget: SqliteDiscretionStore(
        v.db,
        clock: _rt.clock,
        trusted: _rt.trusted,
      ).budget(),
      nowUtc: _rt.clock.nowUtc(),
    );
  }

  /// 🆕 E11q-q4b — J-5 미해소 보드.
  @override
  Stream<UnknownBoardVm> watchUnknownBoard() =>
      _follow((SqliteJournalSource s) => s.unknownBoard(), '미해소 보드');

  /// 🆕 E11q-j4 — J-4 대기 목록(K24 · 모의 원장 = 해당 없음 빈 봉투).
  @override
  Stream<ListResult<BlindReviewCard>> watchBlindReviewQueue({
    RunMode mode = RunMode.live,
  }) => _follow(
    (SqliteJournalSource s) => s.blindReviewQueue(mode: mode),
    'blind 리뷰 대기',
  );

  /// 🆕 E11q-j4 — J-4 카드 1건(모르는 · 대상 아닌 결정 = 오류).
  @override
  Stream<BlindReviewCard> watchBlindReviewCard(String decisionId) => _follow(
    (SqliteJournalSource s) => s.blindReviewCard(decisionId),
    'blind 리뷰 카드',
  );
}

Future<T> _noneNow<T>(String what) =>
    Future<T>.error(UnsupportedError('$what: 원천 없음(계약 창 · 실전 전)'));
