// E11q-s71b — M7 S7-1b 월간 리포트 보관함 VM(설계 13 §8 R253 · 03 §4) — S7-1 과 같은 «닫힌 달» 판정 · 표본 글자 대조.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

ReportArchiveVm _fixture(String name) {
  final Map<String, Object?> doc = jsonDecode(
    File('../domain_contracts/fixtures/m7/m7_report_archive_$name.json')
        .readAsStringSync(),
  ) as Map<String, Object?>;
  final Map<String, Object?> body =
      (doc['rows']! as List<Object?>).single! as Map<String, Object?>;
  return ReportArchiveVm.fromJson(body);
}

DateTime _kst(int y, int m, int d, int h) =>
    DateTime.utc(y, m, d, h).subtract(const Duration(hours: 9));

bool _all(String _) => true;

void main() {
  final ExchangeCalendar kr = frozenExchangeCalendar(Market.kr);

  ReportArchiveVm vm({
    RunMode run = RunMode.simInternal,
    OperatingMode op = OperatingMode.autoTrade,
    String? opening,
    String? pastSim,
    required DateTime now,
    bool Function(String) hasBody = _all,
  }) => reportArchiveVmOf(
    ReportArchiveFacts(
      runMode: run,
      operatingMode: op,
      openingDate: opening,
      pastSimOpeningDate: pastSim,
      nowUtc: now,
      hasBody: hasBody,
    ),
    kr: kr,
  );

  List<String> months(ReportArchiveVm v) =>
      v.rows.map((ReportArchiveRow r) => r.yyyyMm).toList();

  test('🔴 개시 0 = 행 0 + 빈 글자(표본 _empty 그대로) · 기준 줄', () {
    final ReportArchiveVm v = vm(now: _kst(2026, 8, 31, 18));
    final ReportArchiveVm f = _fixture('empty');
    expect(v.rows, isEmpty);
    expect(v.emptyLabel, f.emptyLabel);
    expect(v.asOf.label, f.asOf.label);
    expect(v.asOf.staleAfter, f.asOf.staleAfter);
  });

  test(
    '🔴 모의 운영 = 지금 원장의 닫힌 달만 · 최신 달부터 · 이번 달 0 · 머리글 = 묶음 첫 행 · 링크 = 그 달 S7-1',
    () {
      final ReportArchiveVm v = vm(
        opening: '2026-07-01',
        now: _kst(2026, 11, 19, 9),
      );
      expect(months(v), <String>['2026-10', '2026-09', '2026-08', '2026-07']);
      expect(v.emptyLabel, isNull);
      expect(
        v.rows.first,
        const ReportArchiveRow(
          yyyyMm: '2026-10',
          label: '2026년 10월',
          generated: true,
          modeLabel: '모의투자',
          route: 'aaq://report/2026-10',
          sectionLabel: '2026년 · 모의투자',
        ),
      );
      expect(
        v.rows.skip(1).map((ReportArchiveRow r) => r.sectionLabel).toSet(),
        <String?>{null},
      );
      for (final ReportArchiveRow r in v.rows) {
        expect(
          r.route,
          AppRoutes.reportMonthly.replaceFirst(':yyyyMm', r.yyyyMm),
        );
      }
    },
  );

  test('🔴 «닫힘» = S7-1 판정 — 월말 세션 날 = 아직(10-30 금) · 다음 날 = 닫힘 · 개시 달부터', () {
    expect(
      months(vm(opening: '2026-10-05', now: _kst(2026, 10, 30, 20))),
      isEmpty,
    );
    expect(
      months(vm(opening: '2026-10-05', now: _kst(2026, 10, 31, 9))),
      <String>['2026-10'],
    );
    expect(
      reportArchiveMonthsOf(
        kr: kr,
        openingDate: '2026-10-05',
        nowUtc: _kst(2026, 12, 2, 9),
      ),
      <String>['2026-11', '2026-10'],
    );
  });

  test('🔴 투자 안내 = 링크 0 · 생성 아님 · 사유 · 본문 없음 = 링크 0(사유 0)', () {
    final ReportArchiveVm adv = vm(
      op: OperatingMode.advisory,
      opening: '2026-09-01',
      now: _kst(2026, 11, 19, 9),
    );
    for (final ReportArchiveRow r in adv.rows) {
      expect(
        (r.route, r.generated, r.reasonLabel),
        (null, false, ReportArchiveTexts.advisory),
      );
    }
    final ReportArchiveVm bare = vm(
      opening: '2026-09-01',
      now: _kst(2026, 11, 19, 9),
      hasBody: (String _) => false,
    );
    for (final ReportArchiveRow r in bare.rows) {
      expect((r.route, r.generated, r.reasonLabel), (null, true, null));
    }
  });

  test('🔴 실전 = 실전 달(링크) + 옛 모의 달(링크 0 · 표본 사유 · 실전 첫 달 앞까지) · 연도 · 모드 머리글(표본 _18 행 대조)', () {
    // 표본 꼴: 모의 2025-03 ~ 05 · 실전 2025-06 ~ 2026-08 · 기준 = 2026-09 초.
    final ReportArchiveVm v = vm(
      run: RunMode.live,
      opening: '2025-06-02',
      pastSim: '2025-03-04',
      now: _kst(2026, 9, 6, 9),
    );
    final ReportArchiveVm f = _fixture('18');
    expect(months(v).first, '2026-08');
    expect(months(v).last, '2025-03');
    expect(v.rows, hasLength(18));
    // 표본의 미생성 두 달(07 · 06 — «원장이 모자라») 은 읽을 때 짓기에서 나오지 않는 갈래 — 그 밖 행은 글자까지 같다.
    for (final ReportArchiveRow want in f.rows) {
      if (!want.generated) continue;
      expect(
        v.rows.singleWhere((ReportArchiveRow r) => r.yyyyMm == want.yyyyMm),
        want,
        reason: want.yyyyMm,
      );
    }
    // 실전 첫 달이 같은 달이면 모의 행 0(같은 달 두 행 0 — 화면 Key = 달).
    final ReportArchiveVm same = vm(
      run: RunMode.live,
      opening: '2027-01-12',
      pastSim: '2026-12-21',
      now: _kst(2027, 3, 10, 9),
    );
    expect(months(same), <String>['2027-02', '2027-01', '2026-12']);
    expect(
      same.rows.map((ReportArchiveRow r) => r.sectionLabel).toList(),
      <String?>['2027년', null, '2026년 · 모의투자'],
    );
    expect(same.rows.last.route, isNull);
    // 실전 개시 0 = 이번 달 앞까지의 옛 모의 달만.
    expect(
      months(
        vm(run: RunMode.live, pastSim: '2026-12-21', now: _kst(2027, 2, 3, 9)),
      ),
      <String>['2027-01', '2026-12'],
    );
    // 모의 운영 중엔 옛 모의 칸을 보지 않는다.
    expect(
      months(vm(pastSim: '2025-01-02', now: _kst(2026, 11, 19, 9))),
      isEmpty,
    );
  });

  test('🔴 행 = 수치 칸 0(7필드) · «DRY_RUN» · 손익 글자 0', () {
    final String all = jsonEncode(
      vm(
        run: RunMode.live,
        opening: '2025-06-02',
        pastSim: '2025-03-04',
        now: _kst(2026, 9, 6, 9),
      ).toJson(),
    );
    for (final String banned in <String>['DRY_RUN', '수익', '손익', '%']) {
      expect(all.contains(banned), isFalse, reason: banned);
    }
  });
}
