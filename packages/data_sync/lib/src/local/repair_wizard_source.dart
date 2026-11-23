// 🆕 E16j-a — X5 정정 마법사 원천(01 §8 미결 217 ⓑⓔ · 계약 v1.32 K249 `RepairWizardRepository` · 설계 13 §8 R227).
//
// 🔴 원장 → 엔진 사실(`RepairWizardFacts`) → 엔진 VM(`repairWizardVmOf`) — 글자 · 차례 · 동작 = 엔진 · 여기서는 읽기만(쓰기 0).
// 🔴 무결성 판정(PRAGMA · 사슬) = `LEDGER_INTEGRITY` 가 서 있을 때만 돈다(경계 = 표시가 섰을 때만 본다 · 매 판 비용을 줄인다).
// 🔴 서약 문장(2단계 재생) · 아카이브 관계 = 조립 앱이 넘긴다(서약 = sim 원장 · 아카이브 체크포인트 = E11n 전 없음 → 모름).
// 🔴 신뢰 시각 모름 = 단계 동작 0(엔진) · 재량 예산 = 모름이면 소진 아님으로 본다(3단계 판정은 쓰기 쪽이 다시 한다).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, DiffStatus, FlagIds, LedgerPair, RepairWizardVm;
import 'package:sqlite3/sqlite3.dart';

import 'discretion_store.dart' show SqliteDiscretionStore;
import 'intervention_store.dart' show interventionSessionsOf;
import 'ledger_read_model.dart' show storedLedgerDiffs;
import 'ledger_repair_store.dart'
    show ledgerIntegrityVerdictOf, repairFillCandidatesOf;

List<String> _noPledge() => const <String>[];

DerivedRelation? _noArchive() => null;

/// 정정 마법사 원천(operator 원장).
class SqliteRepairWizardSource {
  /// 만든다 — [writable] = 쓰기 창구가 있고 잠김이 아닌가 · [hasBody] = 셸 레지스트리에 본문이 있나 ·
  /// [pledgeLines] = 지금 서약 문장(없음 = 빈 목록) · [archiveRelation] = 아카이브 관계(모름 = null).
  SqliteRepairWizardSource(
    this._db, {
    required this._clock,
    required this._trusted,
    required this.writable,
    required this.hasBody,
    List<String> Function()? pledgeLines,
    DerivedRelation? Function()? archiveRelation,
  }) : _pledge = pledgeLines ?? _noPledge,
       _archive = archiveRelation ?? _noArchive;

  final Database _db;
  final Clock _clock;
  final TrustedClock _trusted;
  final List<String> Function() _pledge;
  final DerivedRelation? Function() _archive;

  /// 쓰기 창구가 있고 잠김이 아닌가.
  final bool writable;

  /// 조립 앱에 이 라우트의 본문이 있나.
  final bool Function(String route) hasBody;

  /// 바뀌면 다시 읽을 표(diff · 차단 · 개입 · 저널 · 스탬프 · 체결 · 주문 · 정정 · 재량).
  static const Set<String> watchedTables = <String>{
    'ledger_diff',
    'trading_block',
    'intervention_step',
    'decision_journal',
    'ledger_daily_hash',
    'executions',
    'broker_orders',
    'order_intents',
    'ledger_repair',
    'discretion_adjustment',
  };

  bool _integrityFlag() => _db.select(
    'SELECT 1 FROM trading_block WHERE flag_id = ? AND cleared_at IS NULL',
    <Object?>[FlagIds.ledgerIntegrity],
  ).isNotEmpty;

  /// 지금 사실 — [targetId] = 대상 화면(그 diff · 체결 후보까지 읽는다).
  RepairWizardFacts facts({String? targetId}) {
    final List<StoredLedgerDiff> diffs = storedLedgerDiffs(_db);
    final StoredLedgerDiff? target = targetId == null
        ? null
        : diffs.where((StoredLedgerDiff d) => d.diffId == targetId).firstOrNull;
    final bool flag = _integrityFlag();
    final DateTime? trusted = _trusted.trustedNowUtc()?.toUtc();
    final bool repairable =
        target != null &&
        target.status == DiffStatus.open &&
        target.pair == LedgerPair.canonBroker;
    return RepairWizardFacts(
      openDiffs: <StoredLedgerDiff>[
        for (final StoredLedgerDiff d in diffs)
          if (d.status == DiffStatus.open && d.pair == LedgerPair.canonBroker)
            d,
      ],
      integrityFlag: flag,
      integrity: flag
          ? ledgerIntegrityVerdictOf(_db)
          : const LedgerIntegrityVerdict.ok(
              daysChecked: 0,
              checkedThrough: null,
            ),
      archiveRelation: flag ? _archive() : null,
      sessions: interventionSessionsOf(_db),
      pledgeLines: _pledge(),
      budgetExhausted:
          trusted != null &&
          discretionBudgetOf(
            SqliteDiscretionStore(
              _db,
              clock: _clock,
              trusted: _trusted,
            ).useDates(),
            kstDateText(trusted),
          ).exhausted,
      trustedNowUtc: trusted,
      nowUtc: _clock.nowUtc(),
      writable: writable,
      hasBody: hasBody,
      targetDiff: target,
      fills: repairable
          ? repairFillCandidatesOf(_db, target)
          : const <RepairFillCandidate>[],
    );
  }

  /// 🔴 한 판 — [targetId] null = 허브.
  RepairWizardVm vm({String? targetId}) =>
      repairWizardVmOf(facts(targetId: targetId), targetId: targetId);
}
