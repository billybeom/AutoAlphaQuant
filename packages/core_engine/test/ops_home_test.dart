// E11p3d-2b — H-01 오늘 요약 · H-02 운영 리듬(설계 13 §8 R133) — 동결 KR 달력.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);

// 2026-08-31(월 · 8월 마지막 세션) 09:00 KST.
final DateTime _monthEnd = DateTime.utc(2026, 8, 31);

OpsHomeFacts _facts({
  OperatingMode mode = OperatingMode.autoTrade,
  int orders = 3,
  int failed = 1,
  DiscretionBudget? discretion = const DiscretionBudget(
    used: 1,
    max: 4,
    nextRecoveryDate: '2027-03-02',
  ),
  DateTime? last,
  LinkAction? resume,
}) => OpsHomeFacts(
  operatingMode: mode,
  ordersToday: orders,
  failedJobsToday: failed,
  discretion: discretion,
  lastActivityUtc: last,
  resumeLine: resume,
);

void main() {
  test(
    '🔴 자동 매매 = 주문 · 오류 = 센 수 · 신호 일치 · 연속 = 판정 보류 · 재량 = 엔진 문장 · 다음 회차 = 달력일',
    () {
      final OpsDailySummary s = opsDailySummaryOf(
        _facts(last: DateTime.utc(2026, 8, 30, 23, 50)),
        kr: _kr,
        nowUtc: _monthEnd,
      );
      expect(s.todayOrdersText, '오늘 주문 3건');
      expect(s.todayErrorsText, '오늘 오류 1건');
      expect(s.signalMatchText, '신호 일치 판정 보류');
      expect(s.streakText, '규칙 준수 판정 보류');
      expect(
        s.discretionBudgetText,
        '재량 예산 12개월 4회 중 1회 사용 · 다음 회복 2027-03-02',
      );
      // 월말 판정 08-31 → 집행 09-01 = 달력일 1(K23 · 표본 «D-6» 은 미결 84).
      expect(s.nextRebalanceDDayText, 'D-1');
      expect(s.resumeLine, isNull);
    },
  );

  test('🔴 투자 안내 = 기록 · 안내 기록 = 판정 보류(X7 원천 없음) · 오류는 그대로 센다', () {
    final OpsDailySummary s = opsDailySummaryOf(
      _facts(mode: OperatingMode.advisory, orders: 9, failed: 2),
      kr: _kr,
      nowUtc: _monthEnd,
    );
    expect(s.todayOrdersText, '오늘 기록 판정 보류');
    expect(s.signalMatchText, '안내 기록 판정 보류');
    expect(s.todayErrorsText, '오늘 오류 2건');
    expect(s.streakText, '규칙 준수 판정 보류');
  });

  test('🔴 신뢰 시각 모름 = 재량 예산 «확인 중»(엔진 문장) · 소진 = 엔진 문장', () {
    expect(
      opsDailySummaryOf(
        _facts(discretion: null),
        kr: _kr,
        nowUtc: _monthEnd,
      ).discretionBudgetText,
      '재량 예산 — 신뢰 시각 확인 중',
    );
    expect(
      opsDailySummaryOf(
        _facts(
          discretion: const DiscretionBudget(
            used: 4,
            max: 4,
            nextRecoveryDate: '2026-12-01',
          ),
        ),
        kr: _kr,
        nowUtc: _monthEnd,
      ).discretionBudgetText,
      '재량 예산 소진 — 12개월 4회 중 4회 사용 · 다음 회복 2026-12-01',
    );
  });

  test('🔴 X2 한 줄 = 받은 그대로', () {
    const LinkAction line = LinkAction(
      label: '마지막 성공 거래일 D+2 · 대기 작업 1건',
      deepLink: AppRoutes.x2ResumeReport,
    );
    expect(
      opsDailySummaryOf(
        _facts(resume: line),
        kr: _kr,
        nowUtc: _monthEnd,
      ).resumeLine,
      line,
    );
  });

  test('🔴 리듬 = 원천 있는 둘 · 같은 날 = 리밸런싱 먼저 · 경로 · 글자', () {
    expect(opsRhythmRowsOf(kr: _kr, nowUtc: _monthEnd), <OpsRhythmRow>[
      const OpsRhythmRow(
        code: 'MONTHLY_REBALANCE',
        title: '월간 정기 리밸런싱',
        whenText: '매월 첫 거래일',
        dDayText: 'D-1',
        route: AppRoutes.rebalancePreview,
      ),
      const OpsRhythmRow(
        code: 'MONTHLY_CONTRIBUTION',
        title: '월 납입',
        whenText: '매월 첫 거래일',
        dDayText: 'D-1',
        route: AppRoutes.planDeposit,
      ),
    ]);
  });

  test('🔴 집행 세션 주문 시각(09:10) 전 = 리밸런싱 D-day · 납입 = 다음 달(당일 제외) · 날짜 순', () {
    // 2026-09-01 08:00 KST.
    final List<OpsRhythmRow> r = opsRhythmRowsOf(
      kr: _kr,
      nowUtc: DateTime.utc(2026, 8, 31, 23),
    );
    expect(
      r.map((OpsRhythmRow x) => (x.code, x.dDayText)).toList(),
      <(String, String?)>[
        ('MONTHLY_REBALANCE', 'D-day'),
        ('MONTHLY_CONTRIBUTION', 'D-30'),
      ],
    );
    // 같은 날 10:00 KST = 주문 시각 지남 → 둘 다 다음 달.
    expect(
      opsRhythmRowsOf(
        kr: _kr,
        nowUtc: DateTime.utc(2026, 9, 1, 1),
      ).map((OpsRhythmRow x) => x.dDayText).toList(),
      <String?>['D-30', 'D-30'],
    );
  });

  test('🔴 오늘 요약의 upcoming = 리듬 표 앞 ≤3 과 같은 값(C-47 ⑤) · 다음 회차 글자 = 리밸런싱 행', () {
    final DateTime now = DateTime.utc(2026, 8, 31, 23);
    final OpsDailySummary s = opsDailySummaryOf(_facts(), kr: _kr, nowUtc: now);
    final ListResult<OpsRhythmRow> rhythm = opsRhythmOf(
      kr: _kr,
      nowUtc: now,
      lastActivityUtc: null,
    );
    expect(s.upcoming, rhythm.rows.take(3).toList());
    expect(s.nextRebalanceDDayText, 'D-day');
  });

  test('🔴 달력 범위 밖 = 행 0 · 다음 회차 «아직 없음» · 리듬 빈 글자(지어내지 않는다)', () {
    final DateTime late = DateTime.utc(2027, 12, 30);
    final OpsDailySummary s = opsDailySummaryOf(
      _facts(),
      kr: _kr,
      nowUtc: late,
    );
    expect(s.upcoming, isEmpty);
    expect(s.nextRebalanceDDayText, '예정된 회차가 아직 없습니다');
    final ListResult<OpsRhythmRow> r = opsRhythmOf(
      kr: _kr,
      nowUtc: late,
      lastActivityUtc: null,
    );
    expect(r.rows, isEmpty);
    expect(
      (r.emptyKind, r.emptyLabel, r.hasMore),
      (EmptyKind.noData, '예정된 운영 일정이 없습니다', false),
    );
    expect(
      opsRhythmOf(kr: _kr, nowUtc: _monthEnd, lastActivityUtc: null).emptyLabel,
      isNull,
    );
  });

  test('🔴 기준 = 마지막 엔진 활동(KST 날) · 없으면 지금 · 26시간 · 로컬 SQLite', () {
    final AsOf a = opsDailySummaryOf(
      _facts(last: DateTime.utc(2026, 8, 30, 14, 59)),
      kr: _kr,
      nowUtc: _monthEnd,
    ).asOf;
    expect(a.observedAt, DateTime.utc(2026, 8, 30, 14, 59));
    expect(a.tradeDate, TradeDate('2026-08-30'));
    expect(a.label, '운영 홈 기준 2026-08-30');
    expect(a.staleAfter, const Duration(hours: 26));
    expect(a.source, AsOfSource.localSqlite);
    final AsOf b = opsRhythmOf(
      kr: _kr,
      nowUtc: _monthEnd,
      lastActivityUtc: null,
    ).asOf;
    expect(b.observedAt, _monthEnd);
    expect(b.label, '운영 리듬 기준 2026-08-31');
  });

  test('D-day 글자 — 달력일 · 같은 날 = D-day · 지난 날 = 오류', () {
    expect(opsDDayText('2026-08-31', '2026-08-31'), 'D-day');
    expect(opsDDayText('2026-08-31', '2026-12-31'), 'D-122');
    expect(() => opsDDayText('2026-09-01', '2026-08-31'), throwsArgumentError);
  });

  test('표본과 같은 꼴 — 계약 JSON 키가 `ops_home_resume_gap7`(X2 한 줄 칸 포함) · 리듬 행 키가 `ops_rhythm_rows` 와 같다(글자는 엔진)', () {
    Map<String, Object?> fx(String n) => jsonDecode(
      File('../domain_contracts/fixtures/m8/$n.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final Map<String, Object?> home =
        (fx('ops_home_resume_gap7')['rows']! as List<Object?>).first!
            as Map<String, Object?>;
    final Map<String, Object?> ours = jsonDecode(
      jsonEncode(
        opsDailySummaryOf(_facts(), kr: _kr, nowUtc: _monthEnd).toJson(),
      ),
    ) as Map<String, Object?>;
    expect(ours.keys.toSet(), home.keys.toSet());
    final Map<String, Object?> row =
        (fx('ops_rhythm_rows')['rows']! as List<Object?>).first!
            as Map<String, Object?>;
    expect(
      opsRhythmRowsOf(kr: _kr, nowUtc: _monthEnd).first.toJson().keys.toSet(),
      row.keys.toSet(),
    );
  });
}
