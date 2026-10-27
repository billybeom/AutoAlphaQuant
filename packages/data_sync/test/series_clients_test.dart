// E8c — FRED · OFR 클라이언트(설계 13 §8 R23 D1·D10·D11 · R26 H6 · FR-110 · FR-111). 네트워크 0(`MockClient`).
//
// 🔵 잡는 것: ① 응답 꼴 해석(FRED JSON `.` = 결측 · fredgraph 머리 두 꼴 · OFR `OFR FSI` 칸 · 날짜 두 꼴 · 시작일 거름 ·
//    같은 날 두 번 = 틀린 응답) ② 재시도 = 429·5xx·타임아웃·연결 실패만 · 1→2→4s · 최대 3회 더 ③ 4xx 는 다시 하지 않고
//    바로 다음 길 ④ FRED 키 있으면 JSON → 실패면 CSV(`FRED_CSV`) · 키 없으면 CSV 만 ⑤ 🔴 오류 문장에 키·주소가 없다.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const String _key = 'k3y-should-never-leak';

String _fx(String p) => File('test/fixtures/$p').readAsStringSync();

/// 호출 기록 + 차례대로 내줄 응답.
class _Script {
  _Script(this.steps);

  final List<Future<http.Response> Function(http.Request)> steps;
  final List<Uri> calls = <Uri>[];
  final List<Duration> slept = <Duration>[];

  MockClient get client => MockClient((http.Request r) {
    calls.add(r.url);
    if (calls.length > steps.length) {
      throw StateError('예정보다 많이 불렀다: ${r.url.host}');
    }
    return steps[calls.length - 1](r);
  });

  Future<void> sleep(Duration d) async => slept.add(d);
}

Future<http.Response> Function(http.Request) _ok(String body) =>
    (http.Request _) async => http.Response.bytes(utf8.encode(body), 200);

Future<http.Response> Function(http.Request) _status(int code) =>
    (http.Request _) async => http.Response('', code);

Future<http.Response> Function(http.Request) _throw(Exception e) =>
    (http.Request _) async => throw e;

void main() {
  group('응답 꼴', () {
    test('FRED JSON — `.` 는 행 없음 · 시작일 이후만 · 날짜 오름차순', () {
      final List<SeriesObs> o = parseFredJson(
        _fx('fred/NFCI.json'),
        start: '2026-08-07',
      );
      expect(o.map((SeriesObs x) => x.toString()), <String>[
        '2026-08-07=-0.549',
        '2026-08-14=-0.552',
        '2026-08-28=-0.555',
        '2026-09-04=-0.551',
      ]);
    });

    test(
      'fredgraph CSV — 머리 `observation_date` · `DATE` 둘 다 · 빈 칸·`.` = 행 없음',
      () {
        expect(
          parseFredCsv(
            _fx('fred_csv/T10Y3M.csv'),
            start: '2026-08-14',
          ).map((SeriesObs x) => x.toString()),
          <String>['2026-08-14=0.82', '2026-08-17=0.85', '2026-08-19=0.79'],
        );
        expect(
          parseFredCsv(
            _fx('fred_csv/NFCI.csv'),
            start: '2026-08-01',
          ).map((SeriesObs x) => x.toString()),
          <String>['2026-08-07=-0.549', '2026-08-14=-0.552'],
        );
      },
    );

    test('OFR — `OFR FSI` 칸 · CRLF · 날짜 M/D/YYYY 도 받는다', () {
      expect(
        parseOfrCsv(_fx('ofr/fsi.csv'), start: '2026-08-14'),
        hasLength(2),
      );
      final List<SeriesObs> us = parseOfrCsv(
        'Date,OFR FSI,Credit\r\n8/13/2026,-2.782,-1.161\r\n8/14/2026,-2.801,-1.158\r\n',
        start: '2026-08-01',
      );
      expect(us.map((SeriesObs x) => x.toString()), <String>[
        '2026-08-13=-2.782',
        '2026-08-14=-2.801',
      ]);
    });

    test('틀린 응답은 FormatException — 칸 없음 · 칸 수 · 같은 날 두 번 · 숫자 아님 · 날짜 꼴', () {
      final List<void Function()> bad = <void Function()>[
        () => parseOfrCsv('Date,FSI\n2026-08-13,1\n', start: '2026-01-01'),
        () => parseFredCsv('DATE,A,B\n2026-08-13,1,2\n', start: '2026-01-01'),
        () => parseFredCsv(
          'DATE,A\n2026-08-13,1\n2026-08-13,2\n',
          start: '2026-01-01',
        ),
        () => parseFredCsv('DATE,A\n2026-08-13,1.2.3\n', start: '2026-01-01'),
        () => parseFredCsv('DATE,A\n13.08.2026,1\n', start: '2026-01-01'),
        () => parseFredJson('{"error_code":400}', start: '2026-01-01'),
        () => parseFredJson(
          '{"observations":[{"date":"2026-08-13","value":1}]}',
          start: '2026-01-01',
        ),
      ];
      for (int i = 0; i < bad.length; i++) {
        expect(bad[i], throwsA(isA<FormatException>()), reason: '$i');
      }
    });
  });

  group('재시도', () {
    const HttpRetryPolicy fast = HttpRetryPolicy(
      timeout: Duration(milliseconds: 50),
    );

    test('503 → 429 → 연결 실패 → 받음: 기다림 1·2·4s · 시도 4', () async {
      final _Script s = _Script(<Future<http.Response> Function(http.Request)>[
        _status(503),
        _status(429),
        _throw(http.ClientException('boom')),
        _ok('DATE,NFCI\n2026-08-07,-0.549\n'),
      ]);
      final HttpBody b = await getWithRetry(
        s.client,
        FredClient.csvUri('NFCI', '2026-08-01'),
        sleep: s.sleep,
      );
      expect(b.attempts, 4);
      expect(s.slept, const <Duration>[
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 4),
      ]);
      expect(b.sha256Hex, hasLength(64));
    });

    test('5xx 네 번이면 실패 — 시도 4 · 기다림 3', () async {
      final _Script s = _Script(<Future<http.Response> Function(http.Request)>[
        for (int i = 0; i < 4; i++) _status(502),
      ]);
      await expectLater(
        getWithRetry(s.client, OfrClient.fsiUri, sleep: s.sleep),
        throwsA(
          isA<HttpFetchError>()
              .having((HttpFetchError e) => e.attempts, 'attempts', 4)
              .having((HttpFetchError e) => e.reason, 'reason', 'HTTP 502'),
        ),
      );
      expect(s.slept, hasLength(3));
    });

    test('타임아웃도 다시 한다', () async {
      final _Script s = _Script(<Future<http.Response> Function(http.Request)>[
        (http.Request _) => Completer<http.Response>().future,
        _ok('x'),
      ]);
      final HttpBody b = await getWithRetry(
        s.client,
        OfrClient.fsiUri,
        policy: fast,
        sleep: s.sleep,
      );
      expect(b.attempts, 2);
      expect(b.text, 'x');
    });

    test('404 는 다시 하지 않는다', () async {
      final _Script s = _Script(<Future<http.Response> Function(http.Request)>[
        _status(404),
      ]);
      await expectLater(
        getWithRetry(s.client, OfrClient.fsiUri, sleep: s.sleep),
        throwsA(
          isA<HttpFetchError>().having(
            (HttpFetchError e) => e.attempts,
            'attempts',
            1,
          ),
        ),
      );
      expect(s.slept, isEmpty);
    });
  });

  group('FRED 길(FR-111)', () {
    test('키 있음 — JSON 받음 · source FRED · 주소에 키 · 시작일', () async {
      final _Script s = _Script(<Future<http.Response> Function(http.Request)>[
        _ok(_fx('fred/NFCI.json')),
      ]);
      final SeriesFetch f = await FredClient(
        s.client,
        apiKey: _key,
        sleep: s.sleep,
      ).observations('NFCI', start: '2026-08-07');
      expect(f.source, MarketDataSource.fred);
      expect(f.obs, hasLength(4));
      expect(f.fallbackReason, isNull);
      expect(s.calls.single.host, 'api.stlouisfed.org');
      expect(s.calls.single.queryParameters, <String, String>{
        'series_id': 'NFCI',
        'api_key': _key,
        'file_type': 'json',
        'observation_start': '2026-08-07',
      });
    });

    test(
      '키 있음 — JSON 400(다시 안 함) → CSV 로 옮김 · source FRED_CSV · 까닭에 키 없음',
      () async {
        final _Script s = _Script(
          <Future<http.Response> Function(http.Request)>[
            _status(400),
            _ok(_fx('fred_csv/NFCI.csv')),
          ],
        );
        final SeriesFetch f = await FredClient(
          s.client,
          apiKey: _key,
          sleep: s.sleep,
        ).observations('NFCI', start: '2026-08-07');
        expect(f.source, MarketDataSource.fredCsv);
        expect(f.fallbackReason, 'FRED: HTTP 400');
        expect(f.attempts, 2);
        expect(s.calls.last.host, 'fred.stlouisfed.org');
        expect(s.calls.last.queryParameters, <String, String>{
          'id': 'NFCI',
          'cosd': '2026-08-07',
        });
        expect(s.slept, isEmpty);
      },
    );

    test('키 있음 — JSON 꼴이 틀리면 CSV 로', () async {
      final _Script s = _Script(<Future<http.Response> Function(http.Request)>[
        _ok('{"error_message":"Bad Request"}'),
        _ok(_fx('fred_csv/NFCI.csv')),
      ]);
      final SeriesFetch f = await FredClient(
        s.client,
        apiKey: _key,
        sleep: s.sleep,
      ).observations('NFCI', start: '2026-08-07');
      expect(f.source, MarketDataSource.fredCsv);
      expect(f.fallbackReason, startsWith('FRED: 응답 꼴'));
    });

    test('키 없음 — JSON 을 부르지 않고 CSV 만', () async {
      final _Script s = _Script(<Future<http.Response> Function(http.Request)>[
        _ok(_fx('fred_csv/T10Y3M.csv')),
      ]);
      final SeriesFetch f = await FredClient(
        s.client,
        sleep: s.sleep,
      ).observations('T10Y3M', start: '2026-08-14');
      expect(f.source, MarketDataSource.fredCsv);
      expect(f.fallbackReason, isNull);
      expect(s.calls.single.host, 'fred.stlouisfed.org');
    });

    test(
      '🔴 두 길 다 실패 — SourceDownError(FRED) · 까닭 두 개 · 시도 합 · 키·주소 없음',
      () async {
        final _Script s = _Script(
          <Future<http.Response> Function(http.Request)>[
            for (int i = 0; i < 4; i++) _status(500),
            for (int i = 0; i < 4; i++)
              _throw(
                http.ClientException(
                  'down',
                  Uri.parse('https://x/?api_key=$_key'),
                ),
              ),
          ],
        );
        await expectLater(
          FredClient(
            s.client,
            apiKey: _key,
            sleep: s.sleep,
          ).observations('NFCI', start: '2026-08-07'),
          throwsA(
            isA<SourceDownError>()
                .having(
                  (SourceDownError e) => e.source,
                  'source',
                  MarketDataSource.fred,
                )
                .having(
                  (SourceDownError e) => e.reason,
                  'reason',
                  'FRED: HTTP 500 · FRED_CSV: 연결 실패',
                )
                .having((SourceDownError e) => e.attempts, 'attempts', 8)
                .having(
                  (SourceDownError e) => '$e'.contains(_key),
                  '키',
                  isFalse,
                ),
          ),
        );
      },
    );
  });

  group('OFR', () {
    test('받음 · source OFR · 브라우저 꼴 UA', () async {
      final List<String?> ua = <String?>[];
      final MockClient c = MockClient((http.Request r) async {
        ua.add(r.headers['User-Agent']);
        return http.Response.bytes(utf8.encode(_fx('ofr/fsi.csv')), 200);
      });
      final SeriesFetch f = await OfrClient(c).fsi(start: '2026-08-13');
      expect(f.source, MarketDataSource.ofr);
      expect(f.obs.first.toString(), '2026-08-13=-2.782');
      expect(f.obs, hasLength(3));
      expect(ua.single, startsWith('Mozilla/5.0'));
    });

    test('칸이 없으면 SourceDownError(OFR)', () async {
      final MockClient c = MockClient(
        (http.Request _) async =>
            http.Response('Date,FSI\n2026-08-13,1\n', 200),
      );
      await expectLater(
        OfrClient(c).fsi(start: '2026-08-01'),
        throwsA(
          isA<SourceDownError>().having(
            (SourceDownError e) => e.source,
            'source',
            MarketDataSource.ofr,
          ),
        ),
      );
    });
  });
}
