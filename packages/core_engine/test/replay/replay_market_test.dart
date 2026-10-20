// E6a 재현 시장 번들 — 참조 엔진(백테스트6)과 세션·월말·합성 시세·가격 패널이 비트까지 같은가.
//
// 정답지 = `fixtures/market_parity.json`(tool/export_replay_market.py — 참조 엔진 market.build 본문 +
// apply_p0_market + Backtest(Config(preset="P0S"))._prep 를 그대로 돌린 산출의 해시·표본 값).

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

import 'replay_csv.dart';
import 'replay_market.dart';

String _fhash(List<double> values) {
  final ByteData b = ByteData(8 * values.length);
  for (int i = 0; i < values.length; i++) {
    final double v = values[i];
    if (v.isNaN) {
      b.setUint64(8 * i, 0x7ff8000000000000, Endian.little);
    } else {
      b.setFloat64(8 * i, v, Endian.little);
    }
  }
  return sha256.convert(b.buffer.asUint8List()).toString();
}

String _lineHash(Iterable<String> lines) => sha256
    .convert(utf8.encode(lines.map((String l) => '$l\n').join()))
    .toString();

final RegExp _iso = RegExp(r'^\d{4}-\d{2}-\d{2}$');

void main() {
  final Map<String, Object?> want = jsonDecode(
    File('test/replay/fixtures/market_parity.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final ReplayMarket m = ReplayMarket.build();

  Map<String, Object?> obj(Object? o) => o! as Map<String, Object?>;

  void expectSeries(DatedSeries got, Object? spec, String what) {
    final Map<String, Object?> w = obj(spec);
    expect(got.length, w['n'], reason: '$what 길이');
    expect(got.dates.first, w['first'], reason: '$what 첫날');
    expect(got.dates.last, w['last'], reason: '$what 끝날');
    expect(
      got.values.where((double v) => v.isNaN).length,
      w['nan'],
      reason: '$what 결측',
    );
    for (final MapEntry<String, Object?> s in obj(w['samples']).entries) {
      final double? v = got.at(s.key);
      expect(v, isNotNull, reason: '$what ${s.key}');
      final String w = s.value! as String; // 파이썬 repr — 결측은 'nan'
      if (w == 'nan') {
        expect(v!.isNaN, isTrue, reason: '$what ${s.key}');
      } else {
        expect(v, double.parse(w), reason: '$what ${s.key}');
      }
    }
    expect(_lineHash(got.dates), w['dates_sha256'], reason: '$what 날짜');
    expect(_fhash(got.values), w['values_sha256'], reason: '$what 값');
  }

  test('번들 날짜는 전부 YYYY-MM-DD(문자열 비교 = 날짜 비교)', () {
    for (final String name in <String>[
      'gspc', 'kq11', 'qqq', 'ndx', 'gold_fut', 'usdkrw_fred', 'usdkrw_fdr',
      'kr_3m', 'dgs3mo', 't10y3m', //
    ]) {
      final ReplayFrame f = loadReplayCsv(name);
      expect(f.index.every(_iso.hasMatch), isTrue, reason: name);
    }
  });

  group('세션 — 데이터 날짜(설계 13 §8 R15)', () {
    final Map<String, Object?> s = obj(want['sessions']);
    test('전체 US·KR 세션', () {
      expect(m.usIndex.dates, hasLength(obj(s['us_all'])['n']));
      expect(_lineHash(m.usIndex.dates), obj(s['us_all'])['sha256']);
      expect(m.kosdaq.dates, hasLength(obj(s['kr_all'])['n']));
      expect(_lineHash(m.kosdaq.dates), obj(s['kr_all'])['sha256']);
    });
    test('기간 안 US 6,694 · KR 6,561 · 합집합 6,900', () {
      expect(m.us, hasLength(obj(s['us'])['n']));
      expect(_lineHash(m.us), obj(s['us'])['sha256']);
      expect(m.kr, hasLength(obj(s['kr'])['n']));
      expect(_lineHash(m.kr), obj(s['kr'])['sha256']);
      expect(m.allDays, hasLength(obj(s['all_days'])['n']));
      expect(_lineHash(m.allDays), obj(s['all_days'])['sha256']);
    });
    test('월말 KR · US 320 — 기간 끝 2026-08-14 도 «월말»', () {
      expect(m.usMonthEnds, hasLength(obj(s['us_month_ends'])['n']));
      expect(
        _lineHash(m.usMonthEnds.toList()..sort()),
        obj(s['us_month_ends'])['sha256'],
      );
      expect(m.krMonthEnds, hasLength(obj(s['kr_month_ends'])['n']));
      expect(
        _lineHash(m.krMonthEnds.toList()..sort()),
        obj(s['kr_month_ends'])['sha256'],
      );
      expect(m.krMonthEnds, contains('2026-08-14'));
    });
    test('월 마지막 3 세션 표', () {
      final List<String> keys = m.krTail.keys.toList()..sort();
      expect(keys, hasLength(obj(s['kr_tail'])['n']));
      expect(
        _lineHash(<String>[
          for (final String d in keys)
            '$d,${m.krTail[d]!.$1},${m.krTail[d]!.$2}',
        ]),
        obj(s['kr_tail'])['sha256'],
      );
    });
    test('2026-06-03 · 07-17 은 KR 세션이 아니다(휴장 — 데이터에 행이 없다)', () {
      expect(m.kr, isNot(contains('2026-06-03')));
      expect(m.kr, isNot(contains('2026-07-17')));
    });
  });

  group('합성 시세 — 비트 일치', () {
    final Map<String, Object?> s = obj(want['series']);
    test('환율(FRED 우선 · 빈 날만 FDR)', () => expectSeries(m.fx, s['fx'], 'fx'));
    test('133690 미국 날짜(QQQ ← ^NDX 소급 · 원화 · 첫 값 100)', () {
      expectSeries(
        m.sleeveBUs['133690']!,
        s['sleeve_b_us_133690'],
        '133690 US',
      );
    });
    test('411060 미국 날짜(금 선물 · 원화)', () {
      expectSeries(
        m.sleeveBUs['411060']!,
        s['sleeve_b_us_411060'],
        '411060 US',
      );
    });
    test('133690 · 411060 한국 세션(엄격히 앞선 미국 종가)', () {
      expectSeries(
        m.sleeveBKr['133690']!,
        s['sleeve_b_kr_133690'],
        '133690 KR',
      );
      expectSeries(
        m.sleeveBKr['411060']!,
        s['sleeve_b_kr_411060'],
        '411060 KR',
      );
    });
    test('원화 현금 지수(경과일 일할 복리)', () {
      expectSeries(m.krwCash, s['krw_cash'], 'krw_cash');
    });
    test('UST10(DGS3MO + T10Y3M · D 8.4 · C 85)', () {
      expectSeries(m.ust10, s['ust10'], 'ust10');
    });
    test('금 USD(US 세션에 정확히 맞춘 뒤 앞으로 채움)', () {
      expectSeries(m.iau, s['iau'], 'iau');
    });
    test('KOSDAQ 종가', () {
      expectSeries(m.kosdaq.closeSeries, s['kosdaq_close'], 'kosdaq');
    });
  });

  group('가격 패널(합집합 6,900일 · 그날 이하 마지막 값)', () {
    for (final MapEntry<String, Object?> e in obj(want['px']).entries) {
      test(e.key, () => expectSeries(m.px[e.key]!, e.value, 'PX ${e.key}'));
    }
  });

  group('슬리브 B 월봉(잘라내지 않은 전체 · 그달 마지막 값)', () {
    for (final MapEntry<String, Object?> e in obj(want['b_monthly']).entries) {
      test(e.key, () {
        final Map<String, Object?> w = obj(e.value);
        final DatedSeries got = m.bMonthly[e.key]!;
        expect(got.length, w['n']);
        expect(_lineHash(got.dates), w['keys_sha256']);
        expect(_fhash(got.values), w['values_sha256']);
        final List<Object?> last = w['last']! as List<Object?>;
        expect(got.dates.last, last[0]);
        expect(got.values.last, double.parse(last[1]! as String));
      });
    }
  });
}
