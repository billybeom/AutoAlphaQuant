// E8c — 실제 원천 호출(설계 13 §8 R23 D11) · `network` 태그 = 기본 건너뜀(dart_test.yaml).
//
// 🔴 발주자 승인 뒤에만 돌린다(`AAQ_NETWORK=1` 이 없으면 아무것도 부르지 않는다). FRED 키는 저장소 밖 파일
//    (`AAQ_FRED_KEY_FILE` · 13 §5-2)에서 읽고 화면·기록에 내지 않는다 — 없으면 키 없는 CSV 길만 본다.
// 🔵 보는 것: 응답 꼴이 손으로 쓴 픽스처와 같은 해석을 통과하는가(첫 실호출 = 픽스처를 실응답으로 바꾸는 날 · D11).

@Tags(<String>['network'])
library;

import 'dart:io';

import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  final bool on = Platform.environment['AAQ_NETWORK'] == '1';
  final String? keyFile = Platform.environment['AAQ_FRED_KEY_FILE'];
  final String? key = keyFile == null || !File(keyFile).existsSync()
      ? null
      : File(keyFile).readAsStringSync().trim();
  late http.Client c;
  setUp(() => c = http.Client());
  tearDown(() => c.close());

  test('FRED 키 없는 CSV — NFCI 최근 관측', () async {
    final SeriesFetch f = await FredClient(c)
        .observations('NFCI', start: '2026-07-01');
    expect(f.source, MarketDataSource.fredCsv);
    expect(f.obs, isNotEmpty);
  }, skip: on ? false : 'AAQ_NETWORK=1 아님');

  test('FRED JSON — 키 파일이 있을 때만', () async {
    final SeriesFetch f = await FredClient(
      c,
      apiKey: key,
    ).observations('T10Y3M', start: '2026-08-01');
    expect(f.source, MarketDataSource.fred);
    expect(f.obs, isNotEmpty);
  }, skip: on && key != null ? false : 'AAQ_NETWORK=1 · 키 파일 필요');

  test('OFR FSI — 전 이력 CSV', () async {
    final SeriesFetch f = await OfrClient(c).fsi(start: '2026-07-01');
    expect(f.source, MarketDataSource.ofr);
    expect(f.obs, isNotEmpty);
  }, skip: on ? false : 'AAQ_NETWORK=1 아님');
}
