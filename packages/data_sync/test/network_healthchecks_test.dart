// E11c — healthchecks.io 실호출 스모크(설계 13 §8 R45 C10) · `network` 태그 = 기본 건너뜀(dart_test.yaml).
//
// 🔴 발주자 승인 뒤에만 돌린다(`AAQ_NETWORK=1` 이 없으면 아무것도 부르지 않는다). 키는 저장소 밖 파일
//    `AAQ_HEALTHCHECKS_KEY_FILE`(예 `%USERPROFILE%\aaq-secrets\healthchecks.env` · 줄 `HC_PING_KEY=…` · `HC_API_KEY=…`)에서
//    읽고 화면 · 기록에 내지 않는다. 시험 체크 슬러그 = `AAQ_HC_SLUG`(발주자가 미리 만든 체크 — 🔴 이 시험은 체크를 만들지 않는다).
// 🔵 보는 것(06 M1-12 게이트 앞 몫): start → success 핑(같은 rid) 이 200 이고, 관리 API 에서 그 체크의 last_ping 이 움직였나.

@Tags(<String>['network'])
library;

import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

Map<String, String> _env(String? path) {
  if (path == null || !File(path).existsSync()) return const <String, String>{};
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
  return v;
}

void main() {
  final bool on = Platform.environment['AAQ_NETWORK'] == '1';
  final Map<String, String> keys = _env(
    Platform.environment['AAQ_HEALTHCHECKS_KEY_FILE'],
  );
  final String? slug = Platform.environment['AAQ_HC_SLUG'];
  final bool ready =
      on &&
      slug != null &&
      (keys['HC_PING_KEY'] ?? '').isNotEmpty &&
      (keys['HC_API_KEY'] ?? '').isNotEmpty;

  test('start → success(같은 rid) = 200 · 관리 API 에서 last_ping 이 움직인다', () async {
    final http.Client c = http.Client();
    addTearDown(c.close);
    final HealthchecksClient hc = HealthchecksClient(
      c,
      MemorySecretVault(<String, String>{
        'healthchecks.ping_key': keys['HC_PING_KEY']!,
        'healthchecks.api_key': keys['HC_API_KEY']!,
      }),
    );
    final DateTime t0 = DateTime.now().toUtc();
    final String rid = runIdForSmoke(slug!, t0);
    await hc.ping(slug, PingStatus.start, rid: rid);
    await hc.ping(slug, PingStatus.success, note: 'E11c 스모크', rid: rid);
    final RemoteCheck mine = (await hc.checks()).singleWhere(
      (RemoteCheck r) => r.slug == slug,
    );
    expect(mine.lastPingUtc, isNotNull);
    expect(
      mine.lastPingUtc!.isAfter(t0.subtract(const Duration(minutes: 2))),
      isTrue,
    );
    printOnFailure('$mine');
  }, skip: ready ? false : 'AAQ_NETWORK=1 · 키 파일 · AAQ_HC_SLUG 필요');
}

/// 스모크용 rid(정규 UUID 꼴 — trading_runtime `runIdFor` 와 같은 꼴 · data_sync 는 trading_runtime 을 의존하지 않는다).
String runIdForSmoke(String slug, DateTime t) {
  final String h =
      secretFingerprint('$slug|${t.toIso8601String()}') +
      secretFingerprint('$slug#2|${t.toIso8601String()}') +
      secretFingerprint('$slug#3|${t.toIso8601String()}') +
      secretFingerprint('$slug#4|${t.toIso8601String()}');
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-4${h.substring(13, 16)}-'
      '8${h.substring(17, 20)}-${h.substring(20, 32)}';
}
