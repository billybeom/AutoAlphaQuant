// 🆕 R280 — `M5-13` 원장 실사 «해소» 게이트 operator 조립(01 §8 미결 226 ⓖ · 계약 v1.37 §46 K318~K322 · 엔진 = core
// `ops/self_audit_resolve.dart` · 원장 = data_sync `SqliteSelfAuditResolveSource` · 설계 13 §8 R280).
//
// 🔴 읽기(`watchResolve`) = 부작용 0 · 원장 변경 · 주기마다 다시 낸다(두 카운터는 시간만 흘러도 바뀐다 · 같은 값 = 다시 내지 않음).
// 🔴 카운터 = 투자 안내 모드에서만 두 줄 · 오늘 = 신뢰 시각(모르면 «세지 않았습니다» — 기기 시계로 대신하지 않는다).
// 🔴 쓰기 = 일괄 확정 하나(`run(heldCommandsConfirm, {review_id})` — 엔진 판정 · 한 트랜잭션 · 버림 0) · 플래그 해제 동작 0
//    (해제 = 실사 기록 트랜잭션이 스스로 — `OperatorSelfReport.submit`).
// 🔴 생체 = 구현 0(M5 안전 동작 선례 · 01 §8 미결 169 · `BiometricPurpose` 에 보관 확정 목적 없음 → 계약 창 — 01 §8 미결 258).

import 'package:core_engine/core_engine.dart'
    show
        SelfAuditGap,
        StoredLedgerDiff,
        heldReviewResultOf,
        kstDateText,
        selfAuditCounterLinesOf,
        selfAuditGapOf,
        selfAuditLinksOf,
        selfAuditResolveVmOf,
        selfReportAccountsOf,
        selfReportReauditLinkOf;
import 'package:data_sync/data_sync.dart'
    show HeldReviewWrite, SqliteSelfAuditResolveSource, watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        LinkAction,
        SafetyActionResult,
        SelfAuditResolveRepository,
        SelfAuditResolveVm,
        TradeDate;

import 'operator_runtime.dart';
import 'operator_view.dart';
import 'view_stream.dart';

/// `M5-13` 읽기(operator).
class OperatorSelfAuditResolveRepository implements SelfAuditResolveRepository {
  /// 만든다 — [tick] = 시간만 흐를 때 다시 읽는 주기.
  OperatorSelfAuditResolveRepository(
    this._rt, {
    this.tick = const Duration(minutes: 1),
  });

  final OperatorRuntime _rt;

  /// 다시 읽는 주기.
  final Duration tick;

  /// 지금 VM — 부작용 0.
  SelfAuditResolveVm resolveOf(OperatorView v) {
    final SqliteSelfAuditResolveSource src = SqliteSelfAuditResolveSource(v.db);
    final List<String> accounts = selfReportAccountsOf(
      _rt.humanDecision?.inputs.accountByStrategy ?? const <String, String>{},
    );
    final DateTime? trusted = _rt.trusted.trustedNowUtc();
    final Map<String, TradeDate> zero = src.latestZeroError();
    int? unprocessed;
    SelfAuditGap? gap;
    if (trusted != null) {
      final TradeDate today = TradeDate(kstDateText(trusted));
      unprocessed = src.unprocessedGap(
        accounts: accounts,
        today: today,
        kr: _rt.calendars.kr,
      );
      gap = selfAuditGapOf(
        accounts: accounts,
        lastVerified: src.lastVerifiedByAccount(),
        today: today,
      );
    }
    final DateTime? flagAt = src.unverifiedSetAt();
    final List<StoredLedgerDiff> open = src.openSelfReportDiffs();
    return selfAuditResolveVmOf(
      flagSetAtUtc: flagAt,
      counterLines: selfAuditCounterLinesOf(
        operatingMode: v.flags.operatingMode,
        trustedKnown: trusted != null,
        unprocessed: unprocessed,
        auditGap: gap,
      ),
      openDiffs: open,
      auditLinks: selfAuditLinksOf(
        flagSetDay: flagAt == null ? null : TradeDate(kstDateText(flagAt)),
        accounts: accounts,
        latestZeroError: zero,
        kr: _rt.calendars.kr,
        rowLinks: <String>{
          for (final StoredLedgerDiff d in open)
            if (selfReportReauditLinkOf(d) case final LinkAction l) l.deepLink,
        },
      ),
      held: src.heldCommands(),
      integrityActive: src.integrityActive(),
      nowUtc: _rt.clock.nowUtc(),
    );
  }

  @override
  Stream<SelfAuditResolveVm> watchResolve() => followView<SelfAuditResolveVm>(
    view: _rt.view,
    changes: (OperatorView v) => watchLedgerQuery<SelfAuditResolveVm>(
      v.db,
      SqliteSelfAuditResolveSource.watchedTables,
      () => resolveOf(v),
    ),
    now: resolveOf,
    tick: tick,
    noView: () => StateError('원장 실사 해소: 화면 상태 없음(온보딩 전)'),
  );
}

/// 🔴 보관 명령 일괄 확정(K319) — 화면 원장 · 엔진 판정 · 결과 글자 = 엔진 · 화면 상태 없음 = 오류.
SafetyActionResult operatorHeldCommandsConfirm(
  OperatorRuntime rt,
  String actionRunId,
  Map<String, String> args,
) {
  final OperatorView? v = rt.view.value;
  if (v == null) throw StateError('보관 확정: 화면 상태 없음(온보딩 전)');
  final HeldReviewWrite w = SqliteSelfAuditResolveSource(v.db)
      .confirmHeld(args: args, nowUtc: rt.clock.nowUtc());
  return heldReviewResultOf(
    actionRunId: actionRunId,
    code: w.code,
    confirmed: w.confirmed,
  );
}
