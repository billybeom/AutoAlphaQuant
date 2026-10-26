// E8b1 — 시점 정렬(PIT) lib 함수(설계 13 §8 R23 D13 · R24 B2).
//
// 🔵 잡는 것: ① 발표 지연 = 달력일 이동 · 겹치면 뒤쪽 ② 미국 → 한국 매핑 두 갈래 — 엄격(d − 1 이하 · 가격)과 같은 날짜
//    포함(국면 · 월말 판정은 다음 날 아침) — 같은 날짜 미국 값이 어느 쪽에 보이는지가 룩어헤드를 가른다 ③ as-of 는 결측을
//    먼저 버린다. 26년 비트 일치는 재현 하네스(`test/replay/`)가 이 함수들로 본다.

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

void main() {
  test('발표 지연 — 날짜를 달력일만큼 미루고 · 겹치면 뒤쪽 값 · 달력에 as-of', () {
    final DatedSeries s = DatedSeries(
      <String>['2026-09-01', '2026-09-03', '2026-09-04'],
      <double>[1, 2, 3],
    );
    final List<String> cal = <String>[
      '2026-09-02',
      '2026-09-03',
      '2026-09-04',
      '2026-09-05',
    ];
    expect(alignWithLag(s, cal).values, <double>[1, 2, 3, 3]);
    // 지연 1 — 09-01 → 09-02 · 09-03 → 09-04 · 09-04 → 09-05.
    expect(alignWithLag(s, cal, lag: 1).values, <double>[1, 1, 2, 3]);
    // 겹침: 09-01(+2) = 09-03 과 09-03(+0)… 지연은 시리즈 전체에 같이 걸리므로 겹침은 원래 날짜가 같을 때뿐 —
    //   결측(NaN)은 먼저 버린다.
    final DatedSeries withNan = DatedSeries(
      <String>['2026-09-01', '2026-09-02'],
      <double>[5, double.nan],
    );
    expect(alignWithLag(withNan, cal).values, <double>[5, 5, 5, 5]);
    expect(kPublishLagDays, <String, int>{
      'nfci': 7,
      'ofr_fsi': 1,
      'yield_curve': 1,
      'cfnai_ma3': 55,
      'sahm': 40,
    });
  });

  test('미국 → 한국: 엄격판은 같은 날짜 미국 값을 보지 않고 · 같은 날짜 포함판은 본다(D13)', () {
    final DatedSeries us = DatedSeries(
      <String>['2026-08-31', '2026-09-01', '2026-09-02'],
      <double>[100, 101, 102],
    );
    final List<String> kr = <String>['2026-09-01', '2026-09-02', '2026-09-03'];
    expect(toKrCalendar(us, kr).values, <double>[
      100,
      101,
      102,
    ], reason: 'KR 09-01 엔 미국 08-31 까지만(미국 09-01 은 KST 09-02 새벽에 끝난다)');
    expect(alignAsOfInclusive(us, kr).values, <double>[
      101,
      102,
      102,
    ], reason: 'KR 09-01 판정에 미국 09-01 — 그래서 월말 판정은 다음 날 아침에 한다');
    // 앞선 값이 없으면 NaN · 엄격판은 그 뒤 앞으로 채운다.
    final List<String> early = <String>['2026-08-31', '2026-09-01'];
    expect(toKrCalendar(us, early).values.first.isNaN, isTrue);
    expect(alignAsOfInclusive(us, early).values, <double>[100, 101]);
  });

  test('같은 날짜 포함판은 결측을 먼저 버린다(참조 엔진 국면 정렬)', () {
    final DatedSeries s = DatedSeries(
      <String>['2026-09-01', '2026-09-02', '2026-09-03'],
      <double>[1, double.nan, 3],
    );
    expect(
      alignAsOfInclusive(s, <String>['2026-09-02', '2026-09-03']).values,
      <double>[1, 3],
    );
  });

  test('날짜 도우미', () {
    expect(daysBetween('2026-12-31', '2027-01-04'), 4);
    expect(minusOneDay('2027-01-01'), '2026-12-31');
    expect(plusDays('2026-02-28', 1), '2026-03-01');
    expect(unionSorted(<String>['b', 'd'], <String>['a', 'b', 'c']), <String>[
      'a',
      'b',
      'c',
      'd',
    ]);
    expect(() => DatedSeries(<String>['a'], <double>[]), throwsArgumentError);
  });
}
