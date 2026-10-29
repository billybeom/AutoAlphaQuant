// E8d2b — KIS 일봉 → core_engine 포트(설계 13 §8 R30 N2·N6·N7). 픽스처 = 실험 5 실응답 본문(test/fixtures/kis/).
//
// 🔵 잡는 것: ① 저장 이름 → KIS 코드(`^GSPC` → SPX · `KQ11` → 1001 · `SPY` → AMS) · 수정/원 인자 ② 대응표 밖 =
//    ArgumentError(요청 0) ③ 쪽 본문 = 받은 원문 그대로 · 받은 순서 · 시도 수 ④ 실패 3종 → QuoteFeedDown(사유에
//    키·시크릿·계좌·토큰 없음).

import 'dart:convert';
import 'dart:io';

import 'package:broker_gateway/broker_gateway.dart';
import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show MarketDataSource;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

String _fxText(String name) =>
    File('test/fixtures/kis/$name.json').readAsStringSync();

http.Response _text(String body, [int status = 200]) => http.Response.bytes(
  utf8.encode(body),
  status,
  headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
);

final KisCredentials _keys = KisCredentials(
  environment: KisEnvironment.mock,
  appKey: 'PSfakeAppKey0123456789',
  appSecret: 'fakeSecret0123456789',
  accountNo: '50123456',
);

const String _tokenValue = 'eyFAKE-TOKEN';

void main() {
  late List<http.Request> seen;
  setUp(() => seen = <http.Request>[]);

  KisQuoteFeed feed(
    http.Response Function(http.Request r) get, {
    http.Response? token,
  }) {
    DateTime t = DateTime.utc(2026, 10, 29, 9);
    return KisQuoteFeed(
      KisRestClient(
        MockClient((http.Request r) async {
          if (r.url.path == '/oauth2/tokenP') {
            return token ??
                _text(
                  jsonEncode(<String, Object>{
                    'access_token': _tokenValue,
                    'expires_in': 86400,
                  }),
                );
          }
          seen.add(r);
          return get(r);
        }),
        _keys,
        environment: KisEnvironment.mock,
        now: () => t,
        sleep: (Duration d) async => t = t.add(d),
      ),
    );
  }

  test('원천 = KIS', () {
    expect(feed((_) => _text('{}')).source, MarketDataSource.kis);
  });

  group('저장 이름 → KIS 코드', () {
    test('US ^GSPC 지수 → SPX · 거래량 0 그대로 · 쪽 본문 = 원문', () async {
      final String body = _fxText('us_index_daily_spx_recent');
      final QuoteFetch f = await feed((_) => _text(body)).daily(
        market: Market.us,
        symbol: '^GSPC',
        kind: QuoteKind.stockIndex,
        from: '2026-06-08',
        to: '2026-10-28',
      );
      expect(seen.single.headers['tr_id'], 'FHKST03030100');
      expect(seen.single.url.queryParameters['FID_COND_MRKT_DIV_CODE'], 'N');
      expect(seen.single.url.queryParameters['FID_INPUT_ISCD'], 'SPX');
      expect(f.bars, hasLength(100));
      expect(f.bars.first.date, '2026-06-08');
      expect(f.bars.last.date, '2026-10-28');
      expect(f.bars.every((QuoteBar b) => b.volume == 0), isTrue);
      expect(f.bars.last.open, isNotNull);
      expect(f.pageBodies, <String>[body]);
      expect(f.attempts, 1);
    });

    test('KR KQ11 지수 → 업종 1001', () async {
      final QuoteFetch f =
          await feed((_) => _text(_fxText('kr_index_daily_1001_recent'))).daily(
            market: Market.kr,
            symbol: 'KQ11',
            kind: QuoteKind.stockIndex,
            from: '2026-08-13',
            to: '2026-10-28',
          );
      expect(seen.single.headers['tr_id'], 'FHKUP03500100');
      expect(seen.single.url.queryParameters['FID_INPUT_ISCD'], '1001');
      expect(f.bars, hasLength(50));
      expect(f.bars.last.tradeValue, isNotNull);
    });

    test('US SPY → 거래소 AMS · 원 MODP 0 · 수정 MODP 1', () async {
      final KisQuoteFeed k = feed(
        (http.Request r) => _text(
          _fxText(
            r.url.queryParameters['MODP'] == '1'
                ? 'us_daily_SPY_modp1_latest'
                : 'us_daily_SPY_modp0_latest',
          ),
        ),
      );
      final QuoteFetch raw = await k.daily(
        market: Market.us,
        symbol: 'SPY',
        kind: QuoteKind.stock,
        from: '2026-06-08',
        to: '2026-10-28',
      );
      final QuoteFetch adj = await k.daily(
        market: Market.us,
        symbol: 'SPY',
        kind: QuoteKind.stock,
        adjust: PriceAdjust.adjusted,
        from: '2026-06-08',
        to: '2026-10-28',
      );
      expect(seen[0].headers['tr_id'], 'HHDFS76240000');
      expect(seen[0].url.queryParameters['EXCD'], 'AMS');
      expect(seen[0].url.queryParameters['SYMB'], 'SPY');
      expect(seen[0].url.queryParameters['MODP'], '0');
      expect(seen[1].url.queryParameters['MODP'], '1');
      expect(raw.bars.last.volume, greaterThan(0));
      // 수정 종가는 분배금만큼 원보다 작거나 같다(배당 수정).
      expect(adj.bars.first.close, lessThan(raw.bars.first.close));
    });

    test('KR 종목 → 수정(FID_ORG_ADJ_PRC 0) · 원(1)', () async {
      final KisQuoteFeed k = feed(
        (http.Request r) => _text(
          _fxText(
            r.url.queryParameters['FID_ORG_ADJ_PRC'] == '0'
                ? 'kr_daily_133690_adj0'
                : 'kr_daily_133690_adj1',
          ),
        ),
      );
      final QuoteFetch adj = await k.daily(
        market: Market.kr,
        symbol: '133690',
        kind: QuoteKind.stock,
        adjust: PriceAdjust.adjusted,
        from: '2026-06-02',
        to: '2026-10-28',
      );
      await k.daily(
        market: Market.kr,
        symbol: '133690',
        kind: QuoteKind.stock,
        from: '2026-06-02',
        to: '2026-10-28',
      );
      expect(seen[0].headers['tr_id'], 'FHKST03010100');
      expect(seen[0].url.queryParameters['FID_INPUT_ISCD'], '133690');
      expect(seen[0].url.queryParameters['FID_ORG_ADJ_PRC'], '0');
      expect(seen[1].url.queryParameters['FID_ORG_ADJ_PRC'], '1');
      expect(adj.bars, hasLength(100));
    });

    test('대응표 밖 = ArgumentError · 요청 0', () async {
      final KisQuoteFeed k = feed((_) => _text('{}'));
      for (final (Market m, String s, QuoteKind kind, PriceAdjust a)
          in <(Market, String, QuoteKind, PriceAdjust)>[
            (Market.us, 'QQQ', QuoteKind.stock, PriceAdjust.raw),
            (Market.us, '^NDX', QuoteKind.stockIndex, PriceAdjust.raw),
            (Market.kr, 'KS11', QuoteKind.stockIndex, PriceAdjust.raw),
            (Market.kr, '13369', QuoteKind.stock, PriceAdjust.raw),
            (Market.kr, 'kodex1', QuoteKind.stock, PriceAdjust.raw),
            (Market.us, '^GSPC', QuoteKind.stockIndex, PriceAdjust.adjusted),
            (Market.kr, 'KQ11', QuoteKind.stockIndex, PriceAdjust.adjusted),
          ]) {
        await expectLater(
          k.daily(
            market: m,
            symbol: s,
            kind: kind,
            adjust: a,
            from: '2026-10-01',
            to: '2026-10-28',
          ),
          throwsArgumentError,
          reason: '$m $s $kind $a',
        );
      }
      expect(seen, isEmpty);
    });
  });

  test('창 밀기 — 쪽마다 본문 하나 · 받은 순서 · 시도 수 합', () async {
    final String body = _fxText('us_index_daily_spx_recent');
    const String empty = '{"rt_cd":"0","msg_cd":"MCA00000","output2":[]}';
    final QuoteFetch f =
        await feed(
          (http.Request r) =>
              r.url.queryParameters['FID_INPUT_DATE_2'] == '20261028'
              ? _text(body)
              : _text(empty),
        ).daily(
          market: Market.us,
          symbol: '^GSPC',
          kind: QuoteKind.stockIndex,
          from: '2026-01-02',
          to: '2026-10-28',
        );
    expect(seen, hasLength(2));
    // 다음 쪽 = 받은 가장 이른 날(06-08)의 전날(달력일).
    expect(seen[1].url.queryParameters['FID_INPUT_DATE_2'], '20260607');
    expect(f.pageBodies, <String>[body, empty]);
    expect(f.attempts, 2);
    expect(f.bars, hasLength(100));
  });

  group('실패 → QuoteFeedDown', () {
    void noSecrets(QuoteFeedDown e) {
      for (final String s in <String>[..._keys.secrets, _tokenValue]) {
        expect(e.reason, isNot(contains(s)));
        expect(e.toString(), isNot(contains(s)));
      }
      expect(e.reason, isNot(contains('koreainvestment')));
    }

    Future<QuoteFeedDown> down(KisQuoteFeed k) async {
      try {
        await k.daily(
          market: Market.us,
          symbol: 'SPY',
          kind: QuoteKind.stock,
          from: '2026-10-01',
          to: '2026-10-28',
        );
      } on QuoteFeedDown catch (e) {
        return e;
      }
      fail('QuoteFeedDown 이 나야 한다');
    }

    test('재시도 소진(503 네 번) — 시도 4', () async {
      final QuoteFeedDown e = await down(feed((_) => _text('', 503)));
      expect(e.reason, contains('503'));
      expect(e.attempts, 4);
      noSecrets(e);
    });

    test('업무 거절 — TR · 코드 · 서버 문장 · 시도 1', () async {
      final QuoteFeedDown e = await down(
        feed(
          (_) => _text(
            jsonEncode(<String, String>{
              'rt_cd': '1',
              'msg_cd': 'EGW02006',
              'msg1': '모의투자 TR 이 아닙니다.',
            }),
          ),
        ),
      );
      expect(e.reason, '업무 거절 HHDFS76240000 EGW02006 모의투자 TR 이 아닙니다.');
      expect(e.attempts, 1);
      noSecrets(e);
    });

    test('토큰 발급 실패(1분 1회) — 요청 0', () async {
      final QuoteFeedDown e = await down(
        feed(
          (_) => _text('{}'),
          token: _text(
            jsonEncode(<String, String>{
              'error_code': 'EGW00133',
              'error_description': '접근토큰 발급 잠시 후 다시 시도하세요(1분당 1회)',
            }),
            403,
          ),
        ),
      );
      expect(e.reason, '토큰 발급 실패 · EGW00133 · 1분 1회 제한');
      expect(e.attempts, 0);
      expect(seen, isEmpty);
      noSecrets(e);
    });
  });
}
