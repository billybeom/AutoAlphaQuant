// E11q-q6c(설계 13 §8 R240) — X7 신뢰 등급 사다리(실사 갭) · 실사 예정 · 기한 표식 계획 · 대사 → 배지 한 판정.
//
// 🔵 잡는 것: ① 표본 `m7/ledger_trust_self_audit_due` 그대로(31일 · 그 달 · 그 계좌 L-3) ② 문턱 = 문서 수치(D+60 · D-15 · 18:00
//    종가 확정) ③ 계좌 여럿 = 가장 무거운 · 긴 · 앞 ④ 기록 없음 = 표식 0 ⑤ 표식 · 알림 계획(반복 금지) ⑥ reason ↔ 링크
//    ⑦ 월간 배지 = 같은 대사 판정(as-of 만 다르다).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'golden/calendar_fixture.dart';

Map<String, dynamic> _row(String rel, [int i = 0]) =>
    ((jsonDecode(File('../domain_contracts/fixtures/$rel').readAsStringSync())
                as Map<String, dynamic>)['rows']
            as List<dynamic>)[i]
        as Map<String, dynamic>;

final ExchangeCalendar _kr = frozenCalendar(Market.kr);

const Map<String, String> _accounts = <String, String>{
  'P0S_A': '일반',
  'P0S_B': '연금저축',
  'P0S_C': '일반',
  'P0S_POT': '연금저축',
};

/// 한국 [y]-[m]-[d] [h]:00.
DateTime _kst(int y, int m, int d, [int h = 19]) =>
    DateTime.utc(y, m, d, h).subtract(const Duration(hours: 9));

SelfAuditVerdict _v(
  Map<String, String> last,
  DateTime now, {
  List<String>? accounts,
}) => selfAuditVerdictOf(
  accounts: accounts ?? selfReportAccountsOf(_accounts),
  lastVerified: <String, TradeDate>{
    for (final MapEntry<String, String> e in last.entries)
      e.key: TradeDate(e.value),
  },
  trustedNowUtc: now,
  kr: _kr,
);

void main() {
  test('문서 수치 — 기한 D+60(06 X7-3 · 04 9b) · 재고지 D-15(01 §3-5)', () {
    expect((kSelfAuditOverdueDays, kSelfAuditRenoticeDays), (60, 15));
    expect(kSelfAuditCheck, 'self_audit');
  });

  test('🔴 표본 m7/ledger_trust_self_audit_due 그대로 — 7/31 실사 · 8/31 18:00 종가 확정 뒤 = 31일 · 8월 · 연금저축', () {
    final SelfAuditVerdict v = _v(<String, String>{
      '일반': '2026-08-31',
      '연금저축': '2026-07-31',
    }, DateTime.utc(2026, 8, 31, 9));
    expect(
      (v.stage, v.accountAlias, v.yyyyMm, v.gapDays, v.link),
      (
        SelfAuditStage.due,
        '연금저축',
        '2026-08',
        31,
        'aaq://ledger/self-report/2026-08/연금저축',
      ),
    );
    expect(
      selfAuditTrustBadgeOf(v),
      LedgerTrustBadge.fromJson(_row('m7/ledger_trust_self_audit_due.json')),
    );
  });

  test('🔴 달이 닫히는 때 = 기준일 종가 확정 18:00 — 17:59 는 아직 7월(기한 안 · 기본 배지)', () {
    final SelfAuditVerdict before = _v(<String, String>{
      '일반': '2026-07-31',
      '연금저축': '2026-07-31',
    }, DateTime.utc(2026, 8, 31, 8, 59));
    expect(
      (before.stage, before.yyyyMm, before.gapDays),
      (SelfAuditStage.current, null, 31),
    );
    expect(
      selfAuditTrustBadgeOf(before),
      selfReportTrustBadgeOf(TradeDate('2026-07-31')),
    );
    expect(selfAuditTrustBadgeOf(before).actionDeepLink, isNull);
    expect(selfAuditClosedMonthOf(DateTime.utc(2026, 8, 31, 8, 59), _kr), (
      '2026-07',
      TradeDate('2026-07-31'),
    ));
    expect(selfAuditClosedMonthOf(_kst(2026, 9, 10), _kr), (
      '2026-08',
      TradeDate('2026-08-31'),
    ));
  });

  test('단계 문턱 — 44일 = 예정 · 45일 = 재고지 · 59일 = 재고지 · 60일 = 기한 초과(같은 달 링크)', () {
    SelfAuditVerdict at(int y, int m, int d) => _v(
      <String, String>{'연금저축': '2026-07-31'},
      _kst(y, m, d),
      accounts: <String>['연금저축'],
    );
    expect(
      (at(2026, 9, 13).stage, at(2026, 9, 13).gapDays),
      (SelfAuditStage.due, 44),
    );
    expect(
      (at(2026, 9, 14).stage, at(2026, 9, 14).gapDays),
      (SelfAuditStage.renotice, 45),
    );
    expect(at(2026, 9, 28).stage, SelfAuditStage.renotice);
    final SelfAuditVerdict over = at(2026, 9, 29);
    expect(
      (over.stage, over.gapDays, over.yyyyMm),
      (SelfAuditStage.overdue, 60, '2026-08'),
    );
    final LedgerTrustBadge b = selfAuditTrustBadgeOf(over);
    expect(
      b,
      LedgerTrustBadge(
        grade: LedgerTrustGrade.drifting,
        level: UiLevel.act,
        label: '어긋나는 중',
        consequenceLine: '마지막 실사 후 60일 경과 — 실사 1회로 회복됩니다',
        upgradeHint: '실사를 마치면 등급이 회복됩니다.',
        lastVerifiedOn: TradeDate('2026-07-31'),
        actionDeepLink: 'aaq://ledger/self-report/2026-08/연금저축',
      ),
    );
    // 표본 ledger_trust_4 셋째 행의 라벨 · 회복 길 · 등급 · 레벨 그대로(까닭 줄 = 카운터 · B22).
    final LedgerTrustBadge drifting = LedgerTrustBadge.fromJson(
      _row('m7/ledger_trust_4.json', 2),
    );
    expect(
      (b.grade, b.level, b.label, b.upgradeHint),
      (drifting.grade, drifting.level, drifting.label, drifting.upgradeHint),
    );
    // 01 §2-11 예 글자(63일) — 다음 달이 닫히면 링크 = 그 달.
    final SelfAuditVerdict v63 = at(2026, 10, 2);
    expect(
      (selfAuditTrustBadgeOf(v63).consequenceLine, v63.yyyyMm),
      ('마지막 실사 후 63일 경과 — 실사 1회로 회복됩니다', '2026-09'),
    );
  });

  test('계좌 여럿 = 가장 무거운 단계 · 같으면 갭이 긴 · 같으면 계좌 차례 앞', () {
    final DateTime now = _kst(2026, 9, 14);
    expect(
      _v(<String, String>{
        '일반': '2026-07-31',
        '연금저축': '2026-08-31',
      }, now).accountAlias,
      '일반',
    );
    expect(
      _v(<String, String>{
        '일반': '2026-07-31',
        '연금저축': '2026-07-30',
      }, now).accountAlias,
      '연금저축',
    );
    expect(
      _v(<String, String>{
        '일반': '2026-07-31',
        '연금저축': '2026-07-31',
      }, now).accountAlias,
      '일반',
    );
    // 기록 없는 계좌는 보지 않는다 — 다른 계좌가 기한 안이면 기한 안.
    final SelfAuditVerdict one = _v(<String, String>{
      '연금저축': '2026-08-31',
    }, now);
    expect((one.stage, one.accountAlias), (SelfAuditStage.current, '연금저축'));
  });

  test('🔴 실사 기록 없음 = 셀 기준이 없다(표식 0 · 기본 배지 · 링크 0) · 신뢰 시각이 달력 밖 = 갭만', () {
    final SelfAuditVerdict none = _v(
      const <String, String>{},
      _kst(2026, 9, 14),
    );
    expect(
      (none.stage, none.accountAlias, none.link),
      (SelfAuditStage.noAnchor, null, null),
    );
    expect(selfAuditTrustBadgeOf(none), selfReportTrustBadgeOf(null));
    expect(
      selfAuditFlagPlanOf(
        verdict: none,
        dueActive: true,
        alertedSinceRenotice: false,
      ),
      isA<SelfAuditFlagPlan>().having(
        (SelfAuditFlagPlan p) => (p.due, p.overdue, p.alert),
        'p',
        (false, false, false),
      ),
    );
  });

  test('재고지 시작 = 기한 15일 전 날의 한국 0시', () {
    expect(
      selfAuditRenoticeStartUtc(
        _v(<String, String>{'연금저축': '2026-07-31'}, _kst(2026, 9, 1)),
      ),
      DateTime.utc(2026, 9, 13, 15),
    );
    expect(
      selfAuditRenoticeStartUtc(
        const SelfAuditVerdict(stage: SelfAuditStage.noAnchor),
      ),
      isNull,
    );
  });

  group('표식 · 알림 계획(반복 알림 금지)', () {
    (bool, bool, bool, String?) plan(
      SelfAuditVerdict? v, {
      bool dueActive = false,
      bool alerted = false,
    }) {
      final SelfAuditFlagPlan p = selfAuditFlagPlanOf(
        verdict: v,
        dueActive: dueActive,
        alertedSinceRenotice: alerted,
      );
      return (p.due, p.overdue, p.alert, p.reason);
    }

    final SelfAuditVerdict due = _v(
      <String, String>{'연금저축': '2026-07-31'},
      _kst(2026, 9, 1),
      accounts: <String>['연금저축'],
    );
    final SelfAuditVerdict renotice = _v(
      <String, String>{'연금저축': '2026-07-31'},
      _kst(2026, 9, 14),
      accounts: <String>['연금저축'],
    );
    final SelfAuditVerdict over = _v(
      <String, String>{'연금저축': '2026-07-31'},
      _kst(2026, 9, 29),
      accounts: <String>['연금저축'],
    );
    const String l3 = 'aaq://ledger/self-report/2026-08/연금저축';

    test('예정 — 새로 서면 알림 1 · 서 있으면 0', () {
      expect(plan(due), (true, false, true, l3));
      expect(plan(due, dueActive: true), (true, false, false, l3));
    });

    test('재고지 — 재고지 시작 뒤 알림이 없을 때만 1(새로 서는 날이면 그 1건이 재고지)', () {
      expect(plan(renotice, dueActive: true), (true, false, true, l3));
      expect(plan(renotice, dueActive: true, alerted: true), (
        true,
        false,
        false,
        l3,
      ));
      expect(plan(renotice, alerted: true), (true, false, true, l3));
    });

    test('기한 초과 — DUE → OVERDUE · 알림 코드 없음', () {
      expect(plan(over, dueActive: true), (false, true, false, l3));
      expect(plan(over), (false, true, false, l3));
    });

    test('투자 안내 아님 · 기한 안 = 둘 다 내림 · 알림 0', () {
      expect(plan(null, dueActive: true), (false, false, false, null));
      expect(
        plan(
          _v(<String, String>{'연금저축': '2026-08-31'}, _kst(2026, 9, 14)),
          dueActive: true,
        ),
        (false, false, false, null),
      );
    });
  });

  test('reason ↔ 링크 — L-3 꼴만 목적지 · 달을 모르면 까닭 글자', () {
    const String l3 = 'aaq://ledger/self-report/2026-08/연금저축';
    expect(selfAuditLinkOfReason(l3), l3);
    expect(selfAuditLinkOfReason(null), isNull);
    expect(selfAuditLinkOfReason('aaq://ledger/trust'), isNull);
    const SelfAuditVerdict noMonth = SelfAuditVerdict(
      stage: SelfAuditStage.overdue,
      accountAlias: '연금저축',
      gapDays: 70,
    );
    expect(selfAuditReasonOf(noMonth), '원장 실사 기한(목적지 없음 · 달 모름)');
    expect(selfAuditLinkOfReason(selfAuditReasonOf(noMonth)), isNull);
    const SelfAuditVerdict badAlias = SelfAuditVerdict(
      stage: SelfAuditStage.due,
      accountAlias: '연금/저축',
      yyyyMm: '2026-08',
      gapDays: 31,
    );
    expect(badAlias.link, isNull);
    expect(selfAuditReasonOf(badAlias), '원장 실사 기한(목적지 없음 · 2026-08)');
  });

  group('대사 → 배지 한 판정(R231 · 지금)', () {
    final List<(DateTime, ReconAction)> checks = <(DateTime, ReconAction)>[
      (DateTime.utc(2026, 8, 28, 22), ReconAction.matched),
      (DateTime.utc(2026, 9, 2, 22), ReconAction.blocked),
    ];

    test('월간 = 같은 함수(as-of = 그 달 마감) · 지금 = 전부', () {
      expect(
        monthlyLedgerTrustOf(checks: checks, monthEnd: TradeDate('2026-08-31')),
        reconLedgerTrustOf(
          checks: checks,
          throughDay: '2026-08-31',
          noReconLine: MonthlyTrustTexts.noReconLine,
        ),
      );
      final LedgerTrustBadge now = reconLedgerTrustOf(
        checks: checks,
        throughDay: null,
        noReconLine: LedgerTrustTexts.noReconNowLine,
      );
      expect(
        (now.grade, now.lastVerifiedOn),
        (LedgerTrustGrade.drifting, TradeDate('2026-08-29')),
      );
    });

    test('지금까지 대사 0 = 확인 불가 · «아직» 줄', () {
      final LedgerTrustBadge b = reconLedgerTrustOf(
        checks: const <(DateTime, ReconAction)>[],
        throughDay: null,
        noReconLine: LedgerTrustTexts.noReconNowLine,
      );
      expect(
        (b.grade, b.level, b.label, b.consequenceLine),
        (
          LedgerTrustGrade.unverifiable,
          UiLevel.watch,
          MonthlyTrustTexts.unverifiableLabel,
          '아직 브로커 대사 기록이 없습니다.',
        ),
      );
    });
  });
}
