// E13g1 — 규칙 변경 게이트 판정 · SAF-405(설계 13 §8 R66).
//
// 🔵 잡는 것: ① 요청 = 언제든(DD · 12월 안 봄) · 칸 · 기준 낡음 · config · 저널 차례 ② 취소 = 있음 ∧ 미결정
//    ③ 승인 차례 전 갈래 · 냉각 경계(= 끝 통과) · 12월(한국 달 — 11-30 15:00Z = 12-01) · DD 락 경계(−0.10 = 락)
//    ④ 첫 승인 = 12월 · DD 무관 · 냉각 · 칸 · 제3자는 그대로 ⑤ 저널 연결 5갈래 ⑥ SAF-405 = live 만 ⑦ 유형 저장 값.
import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show RunMode;
import 'package:test/test.dart';

// 한국 2026-12-10 09:00.
final DateTime _dec = DateTime.utc(2026, 12, 10);

String? _req({
  DateTime? now,
  bool unknown = false,
  String before = 'h0',
  String after = 'h1',
  String reason = '사유',
  String rollback = 'h0 로 되돌린다',
  String current = 'h0',
  bool afterKnown = true,
  bool journal = true,
}) => ruleChangeRequestRejectCode(
  nowUtc: unknown ? null : (now ?? _dec),
  hashBefore: before,
  hashAfter: after,
  reason: reason,
  rollbackMethod: rollback,
  currentApproved: current,
  afterKnown: afterKnown,
  journalLinked: journal,
);

RuleChangeRequestFacts _facts({
  DateTime? at,
  String before = 'h0',
  bool decided = false,
}) => RuleChangeRequestFacts(
  requestedAtUtc: at ?? _dec.subtract(const Duration(days: 31)),
  hashBefore: before,
  decided: decided,
);

String? _approve({
  DateTime? now,
  bool unknown = false,
  RuleChangeRequestFacts? request,
  bool noRequest = false,
  String current = 'h0',
  double dd = -0.05,
  bool? golden = false,
  String? approver = '본인',
  bool third = true,
}) => ruleChangeApproveRejectCode(
  nowUtc: unknown ? null : (now ?? _dec),
  request: noRequest ? null : (request ?? _facts()),
  currentApproved: current,
  drawdown: dd,
  goldenChanged: golden,
  approver: approver,
  thirdPartyNotified: third,
);

void main() {
  test('🔴 요청 = 언제든 — 차례: 신뢰 시각 → 칸 → 기준 낡음 → config → 저널', () {
    expect(_req(), isNull);
    // 12월 밖 · 깊은 DD 와 무관(판정에 들어가지도 않는다).
    expect(_req(now: DateTime.utc(2026, 3, 1)), isNull);
    expect(_req(unknown: true, reason: ''), 'TRUSTED_TIME_UNKNOWN');
    for (final String? r in <String?>[
      _req(before: ' '),
      _req(after: ''),
      _req(after: 'h0'),
      _req(reason: '  '),
      _req(rollback: ''),
    ]) {
      expect(r, 'RULE_CHANGE_FIELDS_MISSING');
    }
    expect(_req(reason: '', current: 'hX'), 'RULE_CHANGE_FIELDS_MISSING');
    expect(_req(current: 'hX', afterKnown: false), 'RULE_CHANGE_BASE_STALE');
    expect(
      _req(afterKnown: false, journal: false),
      'RULE_CHANGE_CONFIG_UNKNOWN',
    );
    expect(_req(journal: false), 'RULE_CHANGE_JOURNAL_MISSING');
    // 첫 요청 = 전 hash `NONE`.
    expect(_req(before: 'NONE', current: 'NONE'), isNull);
    expect(_req(before: 'h0', current: 'NONE'), 'RULE_CHANGE_BASE_STALE');
  });

  test('취소 = 있음 ∧ 미결정(쉽게)', () {
    expect(ruleChangeCancelRejectCode(nowUtc: _dec, request: _facts()), isNull);
    expect(
      ruleChangeCancelRejectCode(nowUtc: null, request: _facts()),
      'TRUSTED_TIME_UNKNOWN',
    );
    expect(
      ruleChangeCancelRejectCode(nowUtc: _dec, request: null),
      'RULE_CHANGE_NOT_FOUND',
    );
    expect(
      ruleChangeCancelRejectCode(nowUtc: _dec, request: _facts(decided: true)),
      'RULE_CHANGE_DECIDED',
    );
  });

  test('승인 차례 — 신뢰 시각 → 없음 → 결정됨 → 기준 → 냉각 → 12월 → DD → 칸 → 제3자', () {
    expect(_approve(), isNull);
    expect(_approve(unknown: true, noRequest: true), 'TRUSTED_TIME_UNKNOWN');
    expect(_approve(noRequest: true, golden: null), 'RULE_CHANGE_NOT_FOUND');
    expect(
      _approve(request: _facts(decided: true), current: 'hX'),
      'RULE_CHANGE_DECIDED',
    );
    expect(
      _approve(
        current: 'hX',
        request: _facts(at: _dec),
      ),
      'RULE_CHANGE_BASE_STALE',
    );
    expect(
      _approve(
        request: _facts(at: _dec),
        now: DateTime.utc(2026, 3, 1).add(const Duration(days: 30)),
      ),
      'RULE_CHANGE_COOLING',
    );
    expect(
      _approve(now: DateTime.utc(2027, 1, 20), dd: -0.3),
      'RULE_CHANGE_OUT_OF_WINDOW',
    );
    expect(_approve(dd: -0.3, golden: null), 'RULE_CHANGE_DD_LOCKED');
    expect(
      _approve(golden: null, third: false),
      'RULE_CHANGE_APPROVAL_FIELDS_MISSING',
    );
    expect(_approve(approver: '  '), 'RULE_CHANGE_APPROVAL_FIELDS_MISSING');
    expect(_approve(approver: null), 'RULE_CHANGE_APPROVAL_FIELDS_MISSING');
    expect(_approve(third: false), 'RULE_CHANGE_THIRD_PARTY_MISSING');
    expect(_approve(golden: true), isNull);
  });

  test('냉각 경계 — 요청 + 30일 1µs 전 = 냉각 · 끝 = 통과', () {
    final RuleChangeRequestFacts f = _facts(at: DateTime.utc(2026, 11, 20));
    final DateTime end = f.coolingEndsAtUtc;
    expect(end, DateTime.utc(2026, 12, 20));
    expect(
      _approve(request: f, now: end.subtract(const Duration(microseconds: 1))),
      'RULE_CHANGE_COOLING',
    );
    expect(_approve(request: f, now: end), isNull);
  });

  test('12월 = 한국 달 — 11-30 14:59Z(한국 23:59) 밖 · 15:00Z(한국 12-01) 안 · 12-31 15:00Z(한국 1월) 밖', () {
    final RuleChangeRequestFacts f = _facts(at: DateTime.utc(2026, 10, 1));
    expect(
      _approve(request: f, now: DateTime.utc(2026, 11, 30, 14, 59)),
      'RULE_CHANGE_OUT_OF_WINDOW',
    );
    expect(_approve(request: f, now: DateTime.utc(2026, 11, 30, 15)), isNull);
    expect(
      _approve(request: f, now: DateTime.utc(2026, 12, 31, 14, 59)),
      isNull,
    );
    expect(
      _approve(request: f, now: DateTime.utc(2026, 12, 31, 15)),
      'RULE_CHANGE_OUT_OF_WINDOW',
    );
  });

  test('🔴 DD 락 경계 포함 — −0.10 = 락 · −0.0999 = 통과', () {
    expect(_approve(dd: -0.10), 'RULE_CHANGE_DD_LOCKED');
    expect(_approve(dd: -0.0999), isNull);
    expect(_approve(dd: 0), isNull);
  });

  test('🔴 첫 승인 = 12월 · DD 무관 — 냉각 · 칸 · 제3자는 그대로', () {
    final RuleChangeRequestFacts f = _facts(
      before: 'NONE',
      at: DateTime.utc(2026, 1, 1),
    );
    expect(isFirstApproval('NONE'), isTrue);
    expect(isFirstApproval('h0'), isFalse);
    expect(
      _approve(
        request: f,
        current: 'NONE',
        now: DateTime.utc(2026, 3, 1),
        dd: -0.5,
      ),
      isNull,
    );
    expect(
      _approve(
        request: f,
        current: 'NONE',
        now: DateTime.utc(2026, 1, 30, 23, 59),
      ),
      'RULE_CHANGE_COOLING',
    );
    expect(
      _approve(
        request: f,
        current: 'NONE',
        now: DateTime.utc(2026, 3, 1),
        third: false,
      ),
      'RULE_CHANGE_THIRD_PARTY_MISSING',
    );
    expect(
      _approve(
        request: f,
        current: 'NONE',
        now: DateTime.utc(2026, 3, 1),
        golden: null,
      ),
      'RULE_CHANGE_APPROVAL_FIELDS_MISSING',
    );
  });

  test('🔴 저널 연결 = 행 · 사전 3필드 · 요청 하나 = 저널 하나', () {
    bool j({
      bool exists = true,
      String? a = '근거',
      String? b = '기대',
      String? c = '규칙',
      bool used = false,
    }) => ruleChangeJournalLinked(
      exists: exists,
      rationaleBefore: a,
      expectedOutcome: b,
      ruleCited: c,
      alreadyUsed: used,
    );
    expect(j(), isTrue);
    expect(j(exists: false), isFalse);
    expect(j(a: ' '), isFalse);
    expect(j(b: null), isFalse);
    expect(j(c: ''), isFalse);
    expect(j(used: true), isFalse);
  });

  test('🔴 SAF-405 = live 만 — 모의는 미승인 · 행 없음이어도 기동', () {
    for (final RunMode m in <RunMode>[RunMode.simInternal, RunMode.simBroker]) {
      for (final int? a in <int?>[null, 0, 1]) {
        final StartupGate g = startupConfigGate(runMode: m, approved: a);
        expect(g.start, isTrue, reason: '$m $a');
        expect(g.triggered, isEmpty);
      }
    }
    expect(
      startupConfigGate(runMode: RunMode.live, approved: 2).start,
      isFalse,
    );
    expect(
      startupConfigGate(runMode: RunMode.live, approved: 0).triggered,
      <String>['SAF-405'],
    );
  });

  test('유형 저장 값 · 상수', () {
    expect(RuleChangeType.values.map((RuleChangeType t) => t.wire), <String>[
      'INFRA',
      'STRATEGY_RULE',
      'BUGFIX',
    ]);
    expect(RuleChangeType.fromWire('BUGFIX'), RuleChangeType.bugfix);
    expect(() => RuleChangeType.fromWire('HOTFIX'), throwsFormatException);
    expect(
      (kRuleChangeCooling, kRuleChangeWindowMonth, kRuleChangeDrawdownLock),
      (const Duration(days: 30), 12, -0.10),
    );
    expect((kNoApprovedConfig, kSaf405), ('NONE', 'SAF-405'));
  });
}
