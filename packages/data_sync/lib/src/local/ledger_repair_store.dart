// X5-3 정정 쓰기 — 새 기준점(재스탬프) · 아무것도 안 하기(설계 13 §8 R126 J1~J7 · SPEC v2.45 04 §3-1 ④ · 지도 D2).
//
// 🔴 새 기준점 = `withLedgerFix` 한 트랜잭션: 안에서 다시 판정 → 경계 X5 만 → 첫 어긋난 날 이후 스탬프를 지금 원장으로
//    다시 씀 → 다시 대조가 통과해야 → `ledger_repair` + 상세 → `LEDGER_INTEGRITY` 해제. 어디서든 실패 = 전부 되돌림.
// 🔴 본문 안에서 스탬퍼 · 무결성 검사 · 알림 `emit` 을 부르지 않는다(겹친 트랜잭션) — 셈은 core 순수 함수로.
// 🔴 아무것도 안 하기 = 그 diff 하나 OPEN → ACCEPTED(플래그는 그대로).
// 🆕 E16f2 — 정본 정정 역분개(R128 K1~K11): 브로커 체결 하나를 무효(REVERSAL) · 정정(REVERSAL + RESTATEMENT) —
//    `withLedgerFix` 한 트랜잭션: 결정 → 원인 → diff(OPEN CANON_BROKER) → delta 같음 → 체결 → 열린 주문 → 정정 판정 →
//    🔴 재생 앞 = 저장 포지션 → 재생 뒤 음수 없음 → 행 넣기 → 주문 합 · 포지션 다시 셈 → `ledger_repair` + 상세 → diff RESOLVED.
//    🔴 `RECON_MISMATCH` 플래그는 그대로(해제 = 사람 `clearReconBlock`).
// 🟡 파생 FORK 기록 · 아카이브 재생성 = E16f3.
// 🆕 E16j-a(01 §8 미결 217 ⓐ · 계약 v1.32 K252~K256) — 🔴 정정 · 새 기준점 커밋 = 개입 세션 5단계: 같은 트랜잭션 안에서 세션이
//    실행 창 안인지(`interventionExecutable`) · 결정 = 3단계 저널(`decision == journalId` — 호출자가 결정 id 를 넘기지 않는다)을 보고,
//    통과하면 쓰기 끝에 5단계 통과 행을 함께 쓴다(세션이 닫힌다) · 아니면 개입 거부 코드(쓰기 0).
//    아무것도 안 하기(`acceptWithSession`) = 이 diff 의 마법사 세션 DO_NOTHING + diff ACCEPTED 한 트랜잭션.
//    거부 사전 = 계약(`BaselineApplyResultCodes` · 공용 신뢰 시각 — 01 §8 미결 212 ① repair 몫).

import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AdviceRejectCodes,
        BaselineApplyResultCodes,
        CostSource,
        DiffStatus,
        FillKind,
        FlagIds,
        LedgerPair,
        SafetyCommonResultCodes,
        hashFormatVersion;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;
import 'derived_sync_store.dart' show storedDayStampsOf;
import 'intervention_store.dart'
    show insertInterventionStep, interventionSessionOf, interventionSessionsOf;
import 'ledger_fix.dart' show withLedgerFix;
import 'ledger_hash_stamper.dart' show ledgerLinesByDay;
import 'position_replay_sql.dart' show ledgerFillRowsOf, writeReplayedPosition;

/// 새 기준점 거부 코드(core `BaselineCodes` 밖의 저장 쪽 사유 · 글자 = 계약 사전 참조 — 01 §8 미결 212 ①).
abstract final class BaselineStoreCodes {
  /// 신뢰 시각 모름.
  static const String trustedTimeUnknown =
      SafetyCommonResultCodes.trustedTimeUnknown;

  /// `LEDGER_INTEGRITY` 가 서 있지 않다.
  static const String flagNotSet = BaselineApplyResultCodes.flagNotSet;
}

/// 새 기준점 결과.
class BaselineResult {
  const BaselineResult._({this.row, this.rejectCode});

  /// 쓴 정정 행(거부 = null).
  final LedgerRepairPlanRow? row;

  /// 거부 코드(쓰기 0 · 성공 = null).
  final String? rejectCode;

  /// 성공했나.
  bool get applied => row != null;
}

/// 정정할 새 값(🔴 종목 · 방향은 고칠 수 없다 — 무효 + 새 기록 · R128 K1).
class FillRestatement {
  /// 만든다 — 수량 · 가격 0 이하 · 비용 음수 = [ArgumentError].
  FillRestatement({
    required this.quantity,
    required this.price,
    required this.commission,
    required this.tax,
  }) {
    if (quantity <= 0) throw ArgumentError.value(quantity, 'quantity', '양수');
    if (price <= 0) throw ArgumentError.value(price, 'price', '양수');
    if (commission < 0) {
      throw ArgumentError.value(commission, 'commission', '0 이상');
    }
    if (tax < 0) throw ArgumentError.value(tax, 'tax', '0 이상');
  }

  /// 새 수량.
  final int quantity;

  /// 새 가격.
  final double price;

  /// 새 수수료 · 세금(사람이 넣은 값 = `USER_ENTERED`).
  final double commission, tax;
}

/// 정본 정정 결과.
class FillCorrectionResult {
  const FillCorrectionResult._({
    this.row,
    this.rejectCode,
    this.fillIds = const <String>[],
  });

  /// 쓴 정정 행(거부 = null).
  final LedgerRepairPlanRow? row;

  /// 거부 코드(쓰기 0 · 성공 = null).
  final String? rejectCode;

  /// 넣은 체결 행 id(REVERSAL 먼저).
  final List<String> fillIds;

  /// 성공했나.
  bool get applied => row != null;
}

/// 🔴 열린 주문 상태 — 체결 동기가 누적을 다시 센다(R128 K4).
final Set<String> _openIntentStatuses = <String>{
  for (final IntentStatus s in <IntentStatus>[
    IntentStatus.reserved,
    IntentStatus.submitting,
    IntentStatus.submitted,
    IntentStatus.partial,
    IntentStatus.unknown,
  ])
    s.code,
};

/// REVERSAL · RESTATEMENT 행 id(R128 K3 — 브로커 `{주문}#{누적}` · 복구 `rcv-` 와 겹치지 않는다).
String correctionFillIdOf(String targetFillId, FillKind kind) => switch (kind) {
  FillKind.reversal => '$targetFillId|REV',
  FillKind.restatement => '$targetFillId|RST',
  FillKind.original => throw ArgumentError.value(kind, 'kind', '정정 행이 아니다'),
};

/// 🆕 E16j-a — 지금 자가 대조 판정(PRAGMA → 스탬프 사슬 · 마법사 원천 · 새 기준점 저장이 같이 쓴다 · 귀속 실패 = 불일치).
LedgerIntegrityVerdict ledgerIntegrityVerdictOf(Database db) {
  final List<String> pragma = <String>[
    for (final Row r in db.select('PRAGMA integrity_check'))
      r.values.first.toString(),
  ];
  if (pragma.length != 1 || pragma.single != 'ok') {
    return const LedgerIntegrityVerdict.failed(
      LedgerIntegrityReason.sqliteIntegrity,
      daysChecked: 0,
    );
  }
  final List<StoredDayStamp> stamps = storedDayStampsOf(db);
  if (stamps.isEmpty) {
    return const LedgerIntegrityVerdict.ok(
      daysChecked: 0,
      checkedThrough: null,
    );
  }
  try {
    return verifyLedgerChain(stamps, ledgerLinesByDay(db));
  } on LedgerHashError {
    return const LedgerIntegrityVerdict.failed(
      LedgerIntegrityReason.attribution,
      daysChecked: 0,
    );
  }
}

/// 🆕 E16j-a(01 §8 미결 217 ⓑ) — diff → 정정할 체결 후보(🔴 `correctFill` 이 받는 것만 — 브로커 체결 · 주문 끝남 · REVERSAL 아님 ·
/// 되돌려지지 않음 · 최근 것 먼저).
///
/// 고르는 열쇠 = diff `delta` — 보유 수량(`QTY`) = 그 종목(KR · 전략 전부 — 계좌 맵은 원장 밖) · 계좌 모르는 전략
/// (`UNMAPPED_STRATEGY`) = 그 전략의 그 종목 · 체결 건(`FILL_COUNT` · `GHOST_FILL`) = 그 주문 · 원장에 없는 주문(`UNKNOWN_ORDER`) = 0.
List<RepairFillCandidate> repairFillCandidatesOf(
  Database db,
  StoredLedgerDiff d,
) {
  final Object? j = jsonDecode(d.delta);
  if (j is! Map<String, Object?>) return const <RepairFillCandidate>[];
  final String? kind = j['kind'] as String?;
  final String? key = j['key'] as String?;
  final String account = (j['account'] as String?) ?? '';
  if (key == null) return const <RepairFillCandidate>[];
  final String? order =
      kind == ReconKind.fillCount.code || kind == ReconKind.ghostFill.code
      ? key
      : null;
  final String? symbol =
      kind == ReconKind.quantity.code || kind == ReconKind.unmappedStrategy.code
      ? key
      : null;
  if (order == null && symbol == null) return const <RepairFillCandidate>[];
  final String? strategy =
      kind == ReconKind.unmappedStrategy.code && account.startsWith('?')
      ? account.substring(1)
      : null;
  final ResultSet groups = order != null
      ? db.select(
          'SELECT DISTINCT i.market, i.symbol, i.strategy_id FROM broker_orders b '
          'JOIN order_intents i ON i.intent_id = b.intent_id WHERE b.broker_order_no = ?',
          <Object?>[order],
        )
      : db.select(
          'SELECT DISTINCT i.market, i.symbol, i.strategy_id FROM executions e '
          'JOIN broker_orders b ON b.broker_order_no = e.broker_order_no '
          'JOIN order_intents i ON i.intent_id = b.intent_id '
          "WHERE i.market = 'KR' AND i.symbol = ?${strategy == null ? '' : ' AND i.strategy_id = ?'} "
          'ORDER BY i.strategy_id',
          <Object?>[symbol, ?strategy],
        );
  final Map<String, String> statusOf = <String, String>{
    for (final Row r in db.select(
      'SELECT b.broker_order_no, i.status FROM broker_orders b '
      'JOIN order_intents i ON i.intent_id = b.intent_id',
    ))
      r['broker_order_no'] as String: r['status'] as String,
  };
  final List<({RepairFillCandidate c, int at})> out =
      <({RepairFillCandidate c, int at})>[];
  int seq = 0;
  for (final Row g in groups) {
    final String market = g['market'] as String;
    final String sym = g['symbol'] as String;
    final List<LedgerFillRow> rows = ledgerFillRowsOf(
      db,
      market,
      sym,
      g['strategy_id'] as String,
    );
    final Set<String> reversed = reversedFillIdsOf(rows);
    for (final LedgerFillRow r in rows) {
      seq++;
      if (r.kind == FillKind.reversal || reversed.contains(r.executionId)) {
        continue;
      }
      if (order != null && r.brokerOrderNo != order) continue;
      if (_openIntentStatuses.contains(statusOf[r.brokerOrderNo])) continue;
      out.add((
        c: RepairFillCandidate(
          fillId: r.executionId,
          tradeDate: r.tradeDate,
          side: r.side.wire,
          symbol: sym,
          quantity: r.quantity,
          price: r.price,
          restated: r.kind == FillKind.restatement,
        ),
        at: seq,
      ));
    }
  }
  out.sort((
    ({RepairFillCandidate c, int at}) a,
    ({RepairFillCandidate c, int at}) b,
  ) {
    final int t = b.c.tradeDate.compareTo(a.c.tradeDate);
    return t != 0 ? t : b.at.compareTo(a.at);
  });
  return <RepairFillCandidate>[
    for (final ({RepairFillCandidate c, int at}) x in out) x.c,
  ];
}

/// `ledger_repair` 쓰기 저장소(operator 원장).
class SqliteLedgerRepairStore {
  /// 만든다.
  SqliteLedgerRepairStore(this._db, {required this._trusted});

  final Database _db;
  final TrustedClock _trusted;

  bool _integrityFlagActive() => _db.select(
    'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
    <Object?>[FlagIds.ledgerIntegrity],
  ).isNotEmpty;

  List<StoredDayStamp> _stamps() => storedDayStampsOf(_db);

  LedgerIntegrityVerdict _verdict() => ledgerIntegrityVerdictOf(_db);

  /// 🆕 E16j-a(미결 217 ⓐ) — 커밋 관문: 세션 [sessionId] 가 5단계 차례 ∧ 실행 창 안 ∧ 결정 = 3단계 저널 · 아니면 개입 거부 코드.
  /// 🔴 트랜잭션 안에서 부른다(판정과 쓰기 사이에 세션이 바뀌지 않게).
  ({String? rejectCode, String? decisionId}) _executeGate(
    String sessionId,
    DateTime nowUtc,
  ) {
    final InterventionState? s = interventionSessionOf(_db, sessionId);
    final String? code = interventionRejectCode(
      session: s,
      otherLiveSession: false,
      stage: kExecuteStage,
      outcome: InterventionOutcome.passed,
      nowUtc: nowUtc,
      journalLinked: false,
      decisionId: s?.journalId,
    );
    if (code != null) return (rejectCode: code, decisionId: null);
    if (!interventionExecutable(s, nowUtc)) {
      throw StateError('개입 판정이 엇갈린다: $sessionId');
    }
    return (rejectCode: null, decisionId: s!.journalId);
  }

  /// 5단계 통과(세션이 닫힌다) — 커밋 트랜잭션 안.
  void _executeStep(String sessionId, DateTime at, String decisionId) =>
      insertInterventionStep(
        _db,
        sessionId: sessionId,
        stage: kExecuteStage,
        atUtc: at,
        outcome: InterventionOutcome.passed,
        decisionId: decisionId,
      );

  /// 🔴 새 기준점 선언 — 거부면 쓰기 0 · 다른 정정 중 = `LedgerFixBusy` · 다시 쓴 뒤 대조 실패 = [StateError](되돌림).
  ///
  /// [sessionId] = 개입 세션(5단계 커밋 · 결정 = 그 세션의 3단계 저널 — 미결 217 ⓐ) ·
  /// [archiveRelation] = 아카이브 체크포인트 ↔ 정본 관계(모름 = null · 호출자가 판정).
  BaselineResult applyBaseline({
    required String repairId,
    required String sessionId,
    required String originCode,
    required String clearedBy,
    DerivedRelation? archiveRelation,
  }) {
    final DateTime? now = _trusted.trustedNowUtc();
    if (now == null) {
      return const BaselineResult._(
        rejectCode: BaselineStoreCodes.trustedTimeUnknown,
      );
    }
    if (!_integrityFlagActive()) {
      return const BaselineResult._(rejectCode: BaselineStoreCodes.flagNotSet);
    }
    final DateTime at = now.toUtc();
    return withLedgerFix(
      _db,
      reason: 'X5 새 기준점 $repairId',
      atUtc: at,
      body: () {
        final ({String? rejectCode, String? decisionId}) gate = _executeGate(
          sessionId,
          at,
        );
        if (gate.rejectCode != null) {
          return BaselineResult._(rejectCode: gate.rejectCode);
        }
        final String? decisionId = gate.decisionId;
        final LedgerIntegrityVerdict verdict = _verdict();
        final LedgerBoundaryVerdict boundary = ledgerBoundaryOf(
          dbOpened: true,
          integrity: verdict,
          archiveRelation: archiveRelation,
        );
        final String? reject = baselineRejectCode(
          boundary,
          decisionId: decisionId,
          originCode: originCode,
        );
        if (reject != null) return BaselineResult._(rejectCode: reject);
        final List<StoredDayStamp> before = _stamps();
        final LedgerRepairPlanRow plan = baselinePlanOf(
          boundary,
          repairId: repairId,
          decisionId: decisionId,
          originCode: originCode,
          reasonWire: verdict.reason!.code,
          stamps: before,
          appliedAtUtc: at,
        );
        final String head = _restampFrom(plan.recomputedFrom!, before, at);
        final LedgerIntegrityVerdict after = verifyLedgerChain(
          _stamps(),
          ledgerLinesByDay(_db),
        );
        if (!after.ok) {
          throw StateError('다시 쓴 스탬프가 대조를 통과하지 못한다: ${after.reason!.code}');
        }
        final String iso = at.toIso8601String();
        _db.execute(
          'INSERT INTO ledger_repair (repair_id, diff_id, direction, origin_code, decision_id, '
          'evidence_hash, supersedes, applied_at) VALUES (?, ?, ?, ?, ?, ?, NULL, ?)',
          <Object?>[
            plan.repairId,
            plan.diffId,
            plan.direction.wire,
            plan.originCode,
            plan.decisionId,
            plan.evidenceHash,
            iso,
          ],
        );
        _db.execute(
          'INSERT INTO ledger_repair_detail (repair_id, recomputed_from, chain_hash, target_json, evidence_json) '
          'VALUES (?, ?, ?, ?, ?)',
          <Object?>[
            plan.repairId,
            plan.recomputedFrom,
            head,
            '{"kind":"LEDGER_INTEGRITY"}',
            plan.evidenceJson,
          ],
        );
        _db.execute(
          'UPDATE trading_block SET cleared_at = ?, cleared_by = ?, decision_id = ?, origin_code = ? '
          'WHERE flag_id = ? AND cleared_at IS NULL',
          <Object?>[
            iso,
            clearedBy,
            plan.decisionId,
            plan.originCode,
            FlagIds.ledgerIntegrity,
          ],
        );
        if (_db.updatedRows != 1) {
          throw StateError('LEDGER_INTEGRITY 해제가 1행이 아니다: ${_db.updatedRows}');
        }
        _executeStep(sessionId, at, plan.decisionId!);
        return BaselineResult._(
          row: LedgerRepairPlanRow(
            repairId: plan.repairId,
            diffId: plan.diffId,
            direction: plan.direction,
            originCode: plan.originCode,
            evidenceHash: plan.evidenceHash,
            appliedAtUtc: at,
            decisionId: plan.decisionId,
            recomputedFrom: plan.recomputedFrom,
            chainHash: head,
            targetJson: '{"kind":"LEDGER_INTEGRITY"}',
            evidenceJson: plan.evidenceJson,
          ),
        );
      },
    );
  }

  /// [from] ~ 원래 마지막 스탬프 날(달력일 연속)을 지금 원장으로 다시 쓴다(앞 체인부터) — 다시 쓴 마지막 체인.
  ///
  /// 첫 스탬프 앞날의 행(`ROWS_BEFORE_FIRST_STAMP`)이면 [from] 이 첫 스탬프보다 앞이라 그 날부터 새로 스탬프한다.
  String _restampFrom(String from, List<StoredDayStamp> before, DateTime at) {
    if (before.isEmpty) throw StateError('스탬프가 없다');
    final String last = before.last.authoredDate;
    if (from.compareTo(last) > 0) {
      throw StateError('다시 쓸 스탬프가 없다: $from 이후');
    }
    final List<StoredDayStamp> head = before
        .where((StoredDayStamp s) => s.authoredDate.compareTo(from) < 0)
        .toList();
    final Map<String, Map<String, List<String>>> byDay = ledgerLinesByDay(_db);
    _db.execute(
      'DELETE FROM ledger_daily_hash WHERE authored_date >= ?',
      <Object?>[from],
    );
    String prev = head.isEmpty ? kChainGenesis : head.last.chainHash;
    final String iso = at.toIso8601String();
    for (String d = from; d.compareTo(last) <= 0; d = _nextDay(d)) {
      final Map<String, List<String>> lines =
          byDay[d] ?? const <String, List<String>>{};
      final String day = dayHashOf(lines);
      final String chain = chainHashOf(prev, day);
      _db.execute(
        'INSERT INTO ledger_daily_hash(authored_date, day_hash, chain_hash, hash_format_version, '
        'row_counts, created_at) VALUES (?, ?, ?, ?, ?, ?)',
        <Object?>[d, day, chain, hashFormatVersion, rowCountsJson(lines), iso],
      );
      prev = chain;
    }
    return prev;
  }

  static String _nextDay(String ymd) {
    final DateTime d = DateTime.parse('${ymd}T00:00:00Z')
        .add(const Duration(days: 1));
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// 🆕 E16j-a(계약 v1.32 K254) — 아무것도 안 하기: 이 diff 의 마법사 세션(`x5:<diff id>:` · 닫히지 않은 것 전부) = 다음 단계
  /// DO_NOTHING + diff OPEN → ACCEPTED 한 트랜잭션 · 거부 코드(쓰기 0) 또는 null.
  ///
  /// OPEN `CANON_BROKER` 가 아니면 `REPAIR_DIFF_NOT_OPEN` · 닫을 세션이 있는데 신뢰 시각 모름 = `TRUSTED_TIME_UNKNOWN` ·
  /// 세션이 없으면 시각 없이 받아들인다(«아무것도 안 하기»는 나아가기보다 쉽다).
  String? acceptWithSession(String diffId) => inLedgerTransaction(_db, () {
    if (_db.select(
      'SELECT 1 FROM ledger_diff WHERE diff_id = ? AND pair = ? AND status = ?',
      <Object?>[diffId, LedgerPair.canonBroker.wire, DiffStatus.open.wire],
    ).isEmpty) {
      return RepairCodes.diffNotOpen;
    }
    final String prefix = x5SessionPrefixOf(diffId);
    final List<InterventionState> open = <InterventionState>[
      for (final InterventionState s in interventionSessionsOf(_db).values)
        if (s.sessionId.startsWith(prefix) && !s.closed) s,
    ];
    final DateTime? now = _trusted.trustedNowUtc()?.toUtc();
    if (open.isNotEmpty && now == null) {
      return BaselineStoreCodes.trustedTimeUnknown;
    }
    for (final InterventionState s in open) {
      insertInterventionStep(
        _db,
        sessionId: s.sessionId,
        stage: s.nextStage!,
        atUtc: now!,
        outcome: InterventionOutcome.doNothing,
      );
    }
    if (!acceptDiff(diffId)) throw StateError('diff 받아들임이 1행이 아니다: $diffId');
    return null;
  });

  /// 🔴 아무것도 안 하기 — 그 diff 하나 OPEN → ACCEPTED(OPEN 아님 = false · 플래그 그대로).
  bool acceptDiff(String diffId) {
    _db.execute(
      "UPDATE ledger_diff SET status = 'ACCEPTED' WHERE diff_id = ? AND status = 'OPEN'",
      <Object?>[diffId],
    );
    return _db.updatedRows == 1;
  }

  /// 🔴 정본 정정 — 브로커 체결 [fillId] 하나를 무효([restatement] = null) 또는 정정한다 · 거부 = 쓰기 0 ·
  /// 다른 정정 중 = `LedgerFixBusy` · 앞뒤가 안 맞는 원장 = [StateError](되돌림).
  ///
  /// [sessionId] = 개입 세션(5단계 커밋 · 결정 = 그 세션의 3단계 저널 — 미결 217 ⓐ) ·
  /// [freshDiffIds] = 호출자가 방금 다시 대사한 diff id 들 · [chainLimit] = 정정 체인 상한(config · 기본값 없음).
  FillCorrectionResult correctFill({
    required String repairId,
    required String diffId,
    required Iterable<String> freshDiffIds,
    required String fillId,
    required String sessionId,
    required String originCode,
    required int chainLimit,
    FillRestatement? restatement,
  }) {
    final DateTime? now = _trusted.trustedNowUtc();
    if (now == null) {
      return const FillCorrectionResult._(
        rejectCode: BaselineStoreCodes.trustedTimeUnknown,
      );
    }
    final DateTime at = now.toUtc();
    final String iso = at.toIso8601String();
    return withLedgerFix(
      _db,
      reason: 'X5 정본 정정 $repairId',
      atUtc: at,
      body: () {
        FillCorrectionResult reject(String code) =>
            FillCorrectionResult._(rejectCode: code);
        final ({String? rejectCode, String? decisionId}) gate = _executeGate(
          sessionId,
          at,
        );
        if (gate.rejectCode != null) return reject(gate.rejectCode!);
        final String? decisionId = gate.decisionId;
        if (decisionId == null || decisionId.trim().isEmpty) {
          return reject(RepairCodes.decisionRequired);
        }
        if (!repairOriginCodesFor(
          RepairDirection.canonCorrect,
          LedgerPair.canonBroker,
        ).contains(originCode)) {
          return reject(RepairCodes.originNotAllowed);
        }
        final ResultSet diff = _db.select(
          'SELECT delta FROM ledger_diff WHERE diff_id = ? AND pair = ? AND status = ?',
          <Object?>[diffId, LedgerPair.canonBroker.wire, DiffStatus.open.wire],
        );
        if (diff.isEmpty) return reject(RepairCodes.diffNotOpen);
        final String? changed = repairDeltaRejectCode(
          detectedDiffId: diffId,
          freshDiffIds: freshDiffIds,
        );
        if (changed != null) return reject(changed);
        final ResultSet target = _db.select(
          'SELECT i.market, i.symbol, i.strategy_id, i.status FROM executions e '
          'JOIN broker_orders b ON b.broker_order_no = e.broker_order_no '
          'JOIN order_intents i ON i.intent_id = b.intent_id WHERE e.execution_id = ?',
          <Object?>[fillId],
        );
        if (target.isEmpty) return reject(RepairCodes.fillNotBroker);
        final Row t = target.single;
        if (_openIntentStatuses.contains(t['status'])) {
          return reject(RepairCodes.orderOpen);
        }
        final String market = t['market'] as String;
        final String symbol = t['symbol'] as String;
        final String strategy = t['strategy_id'] as String;
        final List<LedgerFillRow> rows = ledgerFillRowsOf(
          _db,
          market,
          symbol,
          strategy,
        );
        final LedgerFillRow f = rows.firstWhere(
          (LedgerFillRow r) => r.executionId == fillId,
        );
        if (f.kind == FillKind.reversal ||
            reversedFillIdsOf(rows).contains(fillId)) {
          return reject(AdviceRejectCodes.amendTargetNotActive);
        }
        final FillSnapshot snap = FillSnapshot(
          fillId: fillId,
          symbol: symbol,
          side: f.side.wire,
          quantity: f.quantity,
          price: f.price,
          chainDepth: fillChainDepthOf(fillId, rows),
        );
        final List<PlannedFillRow> plan;
        if (restatement == null) {
          plan = voidFillPlan(snap);
        } else {
          final String? amend = amendFillRejectCode(
            snap,
            symbol: symbol,
            side: f.side.wire,
            quantity: restatement.quantity,
            price: restatement.price,
            chainLimit: chainLimit,
          );
          if (amend != null) return reject(amend);
          plan = amendFillPlan(
            snap,
            symbol: symbol,
            side: f.side.wire,
            quantity: restatement.quantity,
            price: restatement.price,
            chainLimit: chainLimit,
          );
        }
        final List<Object?> key = <Object?>[market, symbol, strategy];
        final ResultSet pos = _db.select(
          'SELECT quantity, avg_price FROM positions WHERE market = ? AND symbol = ? AND strategy_id = ?',
          key,
        );
        final int storedQty = pos.isEmpty ? 0 : pos.single['quantity'] as int;
        final double? storedAvg = pos.isEmpty
            ? null
            : (pos.single['avg_price'] as num).toDouble();
        final ReplayedPosition? before = replayPositionOf(
          effectiveFillsOf(rows),
        );
        if (before == null ||
            !positionReplayMatches(
              before,
              storedQuantity: storedQty,
              storedAvgPrice: storedAvg,
            )) {
          return reject(RepairCodes.positionDrift);
        }
        final List<LedgerFillRow> added = <LedgerFillRow>[
          for (final PlannedFillRow p in plan)
            LedgerFillRow(
              executionId: correctionFillIdOf(fillId, p.kind),
              kind: p.kind,
              side: f.side,
              quantity: p.quantity,
              price: p.price,
              brokerOrderNo: f.brokerOrderNo,
              tradeDate: f.tradeDate,
              decisionId: f.decisionId,
              reversesFillId: p.reversesFillId,
              restatesFillId: p.restatesFillId,
            ),
        ];
        final List<LedgerFillRow> live = effectiveFillsOf(<LedgerFillRow>[
          ...rows,
          ...added,
        ]);
        final ReplayedPosition? after = replayPositionOf(live);
        if (after == null) return reject(RepairCodes.positionNegative);

        // ── 쓰기(여기부터 실패 = 되돌림) ──
        String? restatedId;
        for (final LedgerFillRow r in added) {
          if (r.kind == FillKind.reversal) {
            // 🔴 원 행의 가격 · 수수료 · 세금 · 비용 출처를 그대로(저장 양수 · 부호 = fill_kind).
            _db.execute(
              'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, '
              'commission, tax, authored_at, fill_origin, fill_kind, reverses_fill_id, cost_source) '
              'SELECT ?, broker_order_no, executed_at, quantity, price, commission, tax, ?, '
              'fill_origin, ?, execution_id, cost_source FROM executions WHERE execution_id = ?',
              <Object?>[r.executionId, iso, FillKind.reversal.wire, fillId],
            );
          } else {
            restatedId = r.executionId;
            _db.execute(
              'INSERT INTO executions (execution_id, broker_order_no, executed_at, quantity, price, '
              'commission, tax, authored_at, fill_origin, fill_kind, restates_fill_id, cost_source) '
              'SELECT ?, broker_order_no, executed_at, ?, ?, ?, ?, ?, '
              'fill_origin, ?, execution_id, ? FROM executions WHERE execution_id = ?',
              <Object?>[
                r.executionId,
                r.quantity,
                r.price,
                restatement!.commission,
                restatement.tax,
                iso,
                FillKind.restatement.wire,
                CostSource.userEntered.wire,
                fillId,
              ],
            );
          }
          if (_db.updatedRows != 1) {
            throw StateError('체결 행을 넣지 못했다: ${r.executionId}');
          }
        }
        final ({int quantity, double? avgPrice}) totals = orderFillTotalsOf(
          live.where((LedgerFillRow r) => r.brokerOrderNo == f.brokerOrderNo),
        );
        _db.execute(
          'UPDATE broker_orders SET filled_qty = ?, avg_fill_price = ? WHERE broker_order_no = ?',
          <Object?>[totals.quantity, totals.avgPrice, f.brokerOrderNo],
        );
        if (_db.updatedRows != 1) {
          throw StateError('없는 브로커 주문: ${f.brokerOrderNo}');
        }
        writeReplayedPosition(
          _db,
          key,
          exists: pos.isNotEmpty,
          p: after,
          iso: iso,
        );
        String? supersedes;
        if (f.kind == FillKind.restatement) {
          final ResultSet prior = _db.select(
            r"SELECT repair_id FROM ledger_repair_detail WHERE json_extract(target_json, '$.restated_id') = ?",
            <Object?>[fillId],
          );
          if (prior.length != 1) {
            throw StateError(
              '다시 적은 체결의 앞 정정이 1행이 아니다: $fillId · ${prior.length}',
            );
          }
          supersedes = prior.single['repair_id'] as String;
        }
        final ResultSet stamp = _db.select(
          'SELECT chain_hash FROM ledger_daily_hash ORDER BY authored_date DESC LIMIT 1',
        );
        final String deltaText = diff.single['delta'] as String;
        final LedgerRepairPlanRow row = LedgerRepairPlanRow(
          repairId: repairId,
          diffId: diffId,
          direction: RepairDirection.canonCorrect,
          originCode: originCode,
          evidenceHash: evidenceHashOf(deltaText),
          appliedAtUtc: at,
          decisionId: decisionId,
          supersedes: supersedes,
          recomputedFrom: f.tradeDate.compareTo(kstDateText(at)) < 0
              ? f.tradeDate
              : null,
          // 적용 시점 마지막 스탬프 체인(오늘 행은 오늘 밤 스탬프) · 스탬프 없음 = 체인 시작값.
          chainHash: stamp.isEmpty
              ? kChainGenesis
              : stamp.single['chain_hash'] as String,
          targetJson: jsonEncode(<String, Object?>{
            'kind': 'QUANTITY',
            'symbol': symbol,
            'before': storedQty,
            'after': after.quantity,
            'fill_id': fillId,
            'restated_id': restatedId,
          }),
          evidenceJson: deltaText,
        );
        _db.execute(
          'INSERT INTO ledger_repair (repair_id, diff_id, direction, origin_code, decision_id, '
          'evidence_hash, supersedes, applied_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          <Object?>[
            row.repairId,
            row.diffId,
            row.direction.wire,
            row.originCode,
            row.decisionId,
            row.evidenceHash,
            row.supersedes,
            iso,
          ],
        );
        _db.execute(
          'INSERT INTO ledger_repair_detail (repair_id, recomputed_from, chain_hash, target_json, evidence_json) '
          'VALUES (?, ?, ?, ?, ?)',
          <Object?>[
            row.repairId,
            row.recomputedFrom,
            row.chainHash,
            row.targetJson,
            row.evidenceJson,
          ],
        );
        _db.execute(
          'UPDATE ledger_diff SET status = ?, origin_code = ? WHERE diff_id = ? AND status = ?',
          <Object?>[
            DiffStatus.resolved.wire,
            originCode,
            diffId,
            DiffStatus.open.wire,
          ],
        );
        if (_db.updatedRows != 1) {
          throw StateError('diff 해소가 1행이 아니다: ${_db.updatedRows}');
        }
        _executeStep(sessionId, at, decisionId);
        return FillCorrectionResult._(
          row: row,
          fillIds: <String>[for (final LedgerFillRow r in added) r.executionId],
        );
      },
    );
  }
}
