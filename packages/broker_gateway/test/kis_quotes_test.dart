// E8d2a — KIS 시세 6종 · 해석 · 창 밀기(설계 13 §8 R29 L6~L9). 픽스처 = 실험 5 실응답 본문(test/fixtures/kis/).
//
// 🔵 잡는 것: ① 요청 인자·TR_ID 가 실험 5 와 같다 ② 실응답 본문을 해석한다(날짜 ISO · 수 · 꼬리 행) ③ 국내 수정(0)/원(1) ·
//    해외 원(MODP 0)/수정(1) ④ ^GSPC 거래량 0 은 그대로(R28 K5) ⑤ 휴장일 모의 미지원 = 업무 거절 ⑥ 창 밀기(50·100행)가
//    빠짐·중복 없이 범위를 채운다.

import 'dart:convert';
import 'dart:io';

import 'package:broker_gateway/broker_gateway.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

Map<String, Object?> _fx(String name) =>
    jsonDecode(File('test/fixtures/kis/$name.json').readAsStringSync())
        as Map<String, Object?>;

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
);

final Map<String, Object> _token = <String, Object>{
  'access_token': 'eyFAKE-TOKEN',
  'expires_in': 86400,
};

void main() {
  late List<http.Request> seen;
  setUp(() => seen = <http.Request>[]);

  KisQuotes quotes(http.Response Function(http.Request r) get) {
    DateTime t = DateTime.utc(2026, 10, 29, 9);
    return KisQuotes(
      KisRestClient(
        MockClient((http.Request r) async {
          if (r.url.path == '/oauth2/tokenP') return _json(_token);
          seen.add(r);
          return get(r);
        }),
        KisCredentials(
          environment: KisEnvironment.mock,
          appKey: 'PSfakeAppKey0123456789',
          appSecret: 'fakeSecret0123456789',
          accountNo: '50123456',
        ),
        environment: KisEnvironment.mock,
        now: () => t,
        sleep: (Duration d) async => t = t.add(d),
      ),
    );
  }

  test('국내 일봉 — 수정(0)·원(1) · TR · 인자 · 100행 해석', () async {
    final KisQuotes q = quotes(
      (http.Request r) => _json(
        _fx(
          r.url.queryParameters['FID_ORG_ADJ_PRC'] == '0'
              ? 'kr_daily_133690_adj0'
              : 'kr_daily_133690_adj1',
        ),
      ),
    );
    final List<KisBar> adj = await q.domesticDaily(
      '133690',
      from: '2026-06-02',
      to: '2026-10-28',
      adjusted: true,
    );
    final List<KisBar> orig = await q.domesticDaily(
      '133690',
      from: '2026-06-02',
      to: '2026-10-28',
      adjusted: false,
    );
    expect(seen.first.headers['tr_id'], 'FHKST03010100');
    expect(seen.first.url.queryParameters, <String, String>{
      'FID_COND_MRKT_DIV_CODE': 'J',
      'FID_INPUT_ISCD': '133690',
      'FID_INPUT_DATE_1': '20260602',
      'FID_INPUT_DATE_2': '20261028',
      'FID_PERIOD_DIV_CODE': 'D',
      'FID_ORG_ADJ_PRC': '0',
    });
    expect(adj, hasLength(100));
    expect(adj.first.date, '2026-06-02');
    expect(adj.last.date, '2026-10-28');
    expect(adj.last.close, 176360);
    expect(adj.last.volume, isNotNull);
    // 07 §6-2 — 2026-07-29 이전은 원/수정 = 1.00144(분배금 수정) · 그 뒤는 같다.
    final Map<String, double> o = <String, double>{
      for (final KisBar b in orig) b.date: b.close,
    };
    expect(
      o['2026-07-29']! /
          adj.firstWhere((KisBar b) => b.date == '2026-07-29').close,
      closeTo(1.00144, 2e-5),
    );
    expect(o['2026-10-28'], adj.last.close);
  });

  test('영문 섞인 종목코드(0085P0)도 그대로 보낸다', () async {
    final KisQuotes q = quotes((_) => _json(_fx('kr_daily_0085P0_adj0')));
    final List<KisBar> b = await q.domesticDaily(
      '0085P0',
      from: '2026-06-02',
      to: '2026-10-28',
      adjusted: true,
    );
    expect(seen.first.url.queryParameters['FID_INPUT_ISCD'], '0085P0');
    expect(b, hasLength(100));
  });

  test('국내 현재가', () async {
    final KisQuotes q = quotes((_) => _json(_fx('kr_price_133690')));
    final KisPrice p = await q.domesticPrice('133690');
    expect(seen.single.headers['tr_id'], 'FHKST01010100');
    expect(p.price, 176360);
  });

  test('KOSDAQ 지수 일봉 — 50행 · 업종 U · 1001', () async {
    final KisQuotes q = quotes((_) => _json(_fx('kr_index_daily_1001_recent')));
    final List<KisBar> b = await q.domesticIndexDaily(
      '1001',
      from: '2026-08-13',
      to: '2026-10-28',
    );
    expect(seen.first.headers['tr_id'], 'FHKUP03500100');
    expect(seen.first.url.queryParameters['FID_COND_MRKT_DIV_CODE'], 'U');
    expect(b, hasLength(50));
    expect(b.first.date, '2026-08-13');
  });

  test('SPY 일봉 — 거래소 AMS · MODP 0(원)·1(배당 수정) · 거래량 있음', () async {
    final KisQuotes q = quotes(
      (http.Request r) => _json(
        _fx(
          r.url.queryParameters['MODP'] == '1'
              ? 'us_daily_SPY_modp1_latest'
              : 'us_daily_SPY_modp0_latest',
        ),
      ),
    );
    final List<KisBar> raw = await q.overseasDaily(
      'AMS',
      'SPY',
      from: '2026-06-08',
      to: '2026-10-28',
      adjusted: false,
    );
    final List<KisBar> adj = await q.overseasDaily(
      'AMS',
      'SPY',
      from: '2026-06-08',
      to: '2026-10-28',
      adjusted: true,
    );
    expect(seen.first.headers['tr_id'], 'HHDFS76240000');
    expect(seen.first.url.queryParameters, <String, String>{
      'AUTH': '',
      'EXCD': 'AMS',
      'SYMB': 'SPY',
      'GUBN': '0',
      'BYMD': '20261028',
      'MODP': '0',
    });
    expect(raw, hasLength(100));
    expect(
      raw.every((KisBar b) => (b.volume ?? 0) > 0),
      isTrue,
      reason: 'dist_days 거래량(R27 I1)',
    );
    expect(
      adj.first.close,
      lessThan(raw.first.close),
      reason: '9월 배당만큼 앞날이 낮다',
    );
    // 🔴 실측(2026-10-29 00:41 KST = 미국 10-28 장중): 마지막 행은 **장중 값**이라 두 요청 사이에 움직였다(원 771.47 ·
    //    수정 771.465 · 그 앞날은 같다) — 확정 종가가 아니다. 저장은 끝난 세션만(E8d2b 수집기 · 13 §8 R29).
    expect(adj.last.close, closeTo(raw.last.close, raw.last.close * 1e-5));
  });

  test('🔴 S&P500 지수 일봉 — 종가는 오고 거래량은 0 그대로(R28 K5)', () async {
    final KisQuotes q = quotes((_) => _json(_fx('us_index_daily_spx_recent')));
    final List<KisBar> b = await q.overseasIndexDaily(
      'SPX',
      from: '2026-06-08',
      to: '2026-10-28',
    );
    expect(seen.first.headers['tr_id'], 'FHKST03030100');
    expect(seen.first.url.queryParameters['FID_COND_MRKT_DIV_CODE'], 'N');
    expect(b, hasLength(100));
    expect(b.last.close, 7739.97);
    expect(b.every((KisBar x) => x.volume == 0), isTrue);
  });

  test('RSP 수정종가', () async {
    final KisQuotes q = quotes((_) => _json(_fx('us_daily_RSP_modp1_latest')));
    final List<KisBar> b = await q.overseasDaily(
      'AMS',
      'RSP',
      from: '2026-06-08',
      to: '2026-10-28',
      adjusted: true,
    );
    expect(b, hasLength(100));
  });

  test('휴장일 — 모의 미지원(EGW02006) = 업무 거절 · 다시 보내지 않음', () async {
    final KisQuotes q = quotes((_) => _json(_fx('kr_holiday'), 500));
    final Object e = await q
        .domesticHolidays('2026-10-29')
        .then<Object>((_) => 'no', onError: (Object e) => e);
    expect(e, isA<KisRejected>());
    expect((e as KisRejected).msgCd, 'EGW02006');
    expect(e.msg1, '모의투자 TR 이 아닙니다.');
    expect(seen, hasLength(1));
    expect(
      parseKisHolidays(<String, Object?>{
        'output': <Object?>[
          <String, String>{
            'bass_dt': '20261029',
            'opnd_yn': 'Y',
            'bzdy_yn': 'Y',
            'tr_day_yn': 'Y',
          },
          <String, String>{
            'bass_dt': '20261031',
            'opnd_yn': 'N',
            'bzdy_yn': 'N',
            'tr_day_yn': 'N',
          },
        ],
      }).map((KisHoliday h) => '${h.date}:${h.marketOpen}'),
      <String>['2026-10-29:true', '2026-10-31:false'],
    );
  });

  group('L9 창 밀기', () {
    // 서버 흉내 — 평일 140일 · [DATE_1, DATE_2] 안에서 최근 [n] 행만 준다.
    final List<String> days = <String>[
      for (
        DateTime d = DateTime.utc(2026, 4, 1);
        d.isBefore(DateTime.utc(2026, 11, 1));
        d = d.add(const Duration(days: 1))
      )
        if (d.weekday <= 5) d.toIso8601String().substring(0, 10),
    ];
    http.Response serve(http.Request r, int n) {
      final String a = r.url.queryParameters['FID_INPUT_DATE_1']!;
      final String b = r.url.queryParameters['FID_INPUT_DATE_2']!;
      final List<String> in_ = <String>[
        for (final String d in days)
          if (d.replaceAll('-', '').compareTo(a) >= 0 &&
              d.replaceAll('-', '').compareTo(b) <= 0)
            d,
      ];
      final List<String> page = in_
          .sublist(in_.length > n ? in_.length - n : 0)
          .reversed
          .toList();
      return _json(<String, Object>{
        'rt_cd': '0',
        'msg_cd': 'MCA00000',
        'msg1': '정상',
        'output2': <Object>[
          for (final String d in page)
            <String, String>{
              'stck_bsop_date': d.replaceAll('-', ''),
              'bstp_nmix_prpr': '800.5',
              'acml_vol': '1',
            },
          <String, String>{'stck_bsop_date': '', 'bstp_nmix_prpr': ''},
        ],
      });
    }

    test('50행씩 세 번 — 빠짐·중복 없이 범위 전부 · 오름차순', () async {
      final KisQuotes q = quotes((http.Request r) => serve(r, 50));
      final List<KisBar> b = await q.domesticIndexDaily(
        '1001',
        from: '2026-05-01',
        to: '2026-10-30',
      );
      final List<String> want = <String>[
        for (final String d in days)
          if (d.compareTo('2026-05-01') >= 0 && d.compareTo('2026-10-30') <= 0)
            d,
      ];
      expect(b.map((KisBar x) => x.date), want);
      expect(want.length, greaterThan(100));
      expect(seen, hasLength((want.length / 50).ceil()));
      expect(
        seen[1].url.queryParameters['FID_INPUT_DATE_2'],
        isNot(seen[0].url.queryParameters['FID_INPUT_DATE_2']),
      );
    });

    test('pageBack — 진전이 없으면 멈춘다 · 범위 밖은 버린다', () async {
      int calls = 0;
      final List<KisBar> b = await pageBack('2026-01-01', '2026-03-31', (
        String cursor,
      ) async {
        calls++;
        return const <KisBar>[
          KisBar(date: '2026-04-02', close: 1),
          KisBar(date: '2026-03-31', close: 2),
          KisBar(date: '2026-03-30', close: 3),
        ];
      });
      expect(b.map((KisBar x) => x.date), <String>['2026-03-30', '2026-03-31']);
      expect(calls, 2, reason: '두 번째에 같은 날만 와서(새 cursor 이하 0행) 멈춤');
    });
  });

  test('해석 — 빈 꼬리 행 · 종가 없는 행 버림 · 수 = pandas 변환', () {
    final List<KisBar> b = parseKisBars(<String, Object?>{
      'output2': <Object?>[
        <String, String>{
          'xymd': '20261028',
          'clos': '686.1300',
          'tvol': '61234567',
          'open': '',
          'high': '690',
          'low': '680',
        },
        <String, String>{'xymd': '20261027', 'clos': ''},
        <String, String>{'xymd': '', 'clos': ''},
        'x',
      ],
    }, KisBarKeys.overseas);
    expect(b, hasLength(1));
    expect(b.single.date, '2026-10-28');
    expect(b.single.close, 686.13);
    expect(b.single.open, isNull);
    expect(b.single.volume, 61234567);
    expect(parseKisBars(<String, Object?>{}, KisBarKeys.overseas), isEmpty);
    expect(
      () => parseKisPrice(<String, Object?>{'output': <String, String>{}}),
      throwsFormatException,
    );
  });
}
