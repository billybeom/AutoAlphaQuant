// 🆕 E11q-c0 — M5-9 규칙 변경 게이트 원천(operator · 설계 13 §8 R188 · 01 §35 K177~K179 · 미결 205 ⓐ).
//
// 🔴 셈 · 문장 = 엔진(`ruleChangeGateVmOf` · `ruleChangeCandidateOf`) · 여기는 원장 원문만 모은다: 승인된 지문(`config_versions`) ·
//    지금 지문의 등재 여부 · 열린 요청(`queue()`) · 지금 DD(승인과 같은 원천).
// 🔴 요청 · 큐 · 승인이 사는 파일 = 지금 운영 파일(모의 기간 = 모의 파일 · 실전 파일로 옮기기 = c1 · 미결 205 ⓒ).
// 🔴 시각 = 신뢰 시각(냉각 · 승인 판정 — 모르면 엔진이 그렇게 말한다) · 관측 시각 = 기기 시계.

import 'package:core_engine/core_engine.dart'
    show
        RuleChangeCandidate,
        RuleChangeGateItem,
        TrustedClock,
        ruleChangeCandidateOf,
        ruleChangeGateVmOf;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, RuleChangeGateVm;
import 'package:sqlite3/sqlite3.dart';

import 'rule_change_store.dart' show RuleChangeQueueItem, SqliteRuleChangeStore;

/// M5-9 규칙 변경 게이트 원천.
class SqliteRuleChangeGateSource {
  /// 원천을 만든다 — [currentConfigHash] = 지금 쓰는 설정 지문(조립 앱 · 없으면 null) · [canWrite] = 요청 · 승인 · 취소를 낼
  /// 창구가 있나 · [lockedLabel] = 운영 등급 생체 축소(지금 조립 = null).
  SqliteRuleChangeGateSource(
    this._db, {
    required this._clock,
    required this._trusted,
    required this._currentConfigHash,
    required this._canWrite,
    this._lockedLabel,
  });

  final Database _db;
  final Clock _clock;
  final TrustedClock _trusted;
  final String? _currentConfigHash;
  final bool _canWrite;
  final String? _lockedLabel;

  /// 다시 낼 표.
  static const Set<String> watchedTables = <String>{
    'rule_change_request',
    'rule_change_decision',
    'config_versions',
    'equity_snapshot',
  };

  SqliteRuleChangeStore get _store =>
      SqliteRuleChangeStore(_db, clock: _clock, trusted: _trusted);

  List<RuleChangeGateItem> _open() => <RuleChangeGateItem>[
    for (final RuleChangeQueueItem q in _store.queue())
      RuleChangeGateItem(
        requestId: q.requestId,
        changeType: q.changeType,
        hashBefore: q.hashBefore,
        hashAfter: q.hashAfter,
        requestedAtUtc: q.requestedAtUtc,
      ),
  ];

  bool _registered(String? hash) =>
      hash != null &&
      hash.trim().isNotEmpty &&
      _db.select(
        'SELECT 1 FROM config_versions WHERE config_hash = ?',
        <Object?>[hash.trim()],
      ).isNotEmpty;

  /// 지금의 첫 승인 후보(요청 경로가 제출 `candidateId` 와 맞춰 본다) · 없으면 null.
  RuleChangeCandidate? candidate() => ruleChangeCandidateOf(
    approvedHash: _store.approvedConfigHash(),
    currentHash: _currentConfigHash,
    currentRegistered: _registered(_currentConfigHash),
    open: _open(),
  );

  /// M5-9 한 화면.
  RuleChangeGateVm gate() => ruleChangeGateVmOf(
    approvedHash: _store.approvedConfigHash(),
    currentHash: _currentConfigHash,
    currentRegistered: _registered(_currentConfigHash),
    open: _open(),
    drawdown: _store.currentDrawdown(),
    trustedNowUtc: _trusted.trustedNowUtc(),
    nowUtc: _clock.nowUtc(),
    canWrite: _canWrite,
    lockedLabel: _lockedLabel,
  );
}
