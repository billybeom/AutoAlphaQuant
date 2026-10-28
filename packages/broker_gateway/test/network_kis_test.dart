// E8d2a — KIS 모의 서버 실호출(설계 13 §8 R29 L10) · `network` 태그 = 기본 건너뜀(dart_test.yaml).
//
// 🔴 발주자 승인 뒤에만 돌린다(`AAQ_NETWORK=1` 이 없으면 아무것도 부르지 않는다). 키는 저장소 밖 파일
//    `AAQ_KIS_MOCK_KEY_FILE`(실험 5 절차서 14 §3 의 `kis_mock.env` 꼴)에서 읽고 화면·기록에 내지 않는다.
//    토큰은 그 옆 `kis_tokens.json` 에 둔다(발급 1분 1회 · 알림톡 — 24시간 안에는 다시 쓴다).
// 🔵 보는 것: 실응답이 픽스처와 같은 해석을 통과하는가(시세 3종 · 짧은 창).

@Tags(<String>['network'])
library;

import 'dart:io';

import 'package:broker_gateway/broker_gateway.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

KisCredentials? _keys(String? path) {
  if (path == null || !File(path).existsSync()) return null;
  final Map<String, String> v = <String, String>{};
  for (final String raw in File(path).readAsLinesSync()) {
    final String line = raw.trim();
    if (line.isEmpty || line.startsWith('#') || !line.contains('=')) continue;
    final int i = line.indexOf('=');
    v[line.substring(0, i).trim()] = line
        .substring(i + 1)
        .trim()
        .replaceAll('"', '')
        .replaceAll("'", '');
  }
  final String acct = (v['KIS_PAPER_ACCOUNT'] ?? '').replaceAll(' ', '');
  final String cano = acct.contains('-') ? acct.split('-').first : acct;
  return KisCredentials(
    environment: KisEnvironment.mock,
    appKey: v['KIS_PAPER_APP_KEY'] ?? '',
    appSecret: v['KIS_PAPER_APP_SECRET'] ?? '',
    accountNo: cano.length >= 8 ? cano.substring(0, 8) : cano,
  );
}

void main() {
  final bool on = Platform.environment['AAQ_NETWORK'] == '1';
  final String? keyFile = Platform.environment['AAQ_KIS_MOCK_KEY_FILE'];
  final KisCredentials? keys = on ? _keys(keyFile) : null;
  late http.Client h;
  late KisQuotes q;
  setUp(() {
    h = http.Client();
    q = KisQuotes(
      KisRestClient(
        h,
        keys!,
        environment: KisEnvironment.mock,
        tokens: FileKisTokenStore(
          File('${File(keyFile!).parent.path}/kis_tokens.json'),
        ),
      ),
    );
  });
  tearDown(() => h.close());
  final String? skip = keys == null
      ? 'AAQ_NETWORK=1 · AAQ_KIS_MOCK_KEY_FILE 가 없다'
      : null;

  test('KOSDAQ 지수 일봉 — 최근 2주', () async {
    final List<KisBar> b = await q.domesticIndexDaily(
      '1001',
      from: _ago(14),
      to: _ago(0),
    );
    expect(b, isNotEmpty);
    expect(b.every((KisBar x) => x.close > 0), isTrue);
  }, skip: skip);

  test('SPY 일봉(배당 수정) — 최근 2주 · 거래량 있음', () async {
    final List<KisBar> b = await q.overseasDaily(
      'AMS',
      'SPY',
      from: _ago(14),
      to: _ago(0),
      adjusted: true,
    );
    expect(b, isNotEmpty);
    expect(b.every((KisBar x) => (x.volume ?? 0) > 0), isTrue);
  }, skip: skip);

  test('S&P500 지수 일봉 — 종가 있음 · 거래량은 여전히 0 인가(실험 5)', () async {
    final List<KisBar> b = await q.overseasIndexDaily(
      'SPX',
      from: _ago(14),
      to: _ago(0),
    );
    expect(b, isNotEmpty);
    expect(
      b.every((KisBar x) => x.volume == 0),
      isTrue,
      reason: '바뀌었으면 R27 I1 을 다시 본다',
    );
  }, skip: skip);
}

String _ago(int days) => DateTime.now()
    .toUtc()
    .add(const Duration(hours: 9))
    .subtract(Duration(days: days))
    .toIso8601String()
    .substring(0, 10);
