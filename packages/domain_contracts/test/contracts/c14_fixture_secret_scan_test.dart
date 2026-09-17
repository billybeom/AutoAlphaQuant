// C-14 픽스처 시크릿 스캔 — 01 §7 표 C-14 · §5 · 인벤토리 §9(🟢).
//
// 정의: 「`fixtures/` 에 KIS 앱키·`ya29.`·`1//`·8자리 계좌 패턴 탐지」.
// 잡는 것: **실키 혼입**.
//
// 🔴 「없다」를 증명하려면 **스캐너가 실제로 잡는다**는 것도 함께 보여야 한다 —
//    패턴이 조용히 망가지면 「위반 0건」은 「검사하지 않았다」와 구별되지 않는다.
//    그래서 아래 두 번째 검사가 패턴마다 양성 표본을 하나씩 넣어 본다.

import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// 패턴 코드 → 그 패턴이 **반드시 잡아야 하는** 합성 표본.
///
/// 🔴 여기 있는 문자열은 전부 **가짜**다(형태만 흉내 낸다).
const Map<String, String> _positiveControls = <String, String>{
  'KIS_APP_KEY': '{"app_key": "PSaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}',
  'GOOGLE_OAUTH_ACCESS_TOKEN': '{"token": "ya29.FAKEfakeFAKE-_123"}',
  'GOOGLE_OAUTH_REFRESH_TOKEN': '{"refresh": "1//0fakeREFRESHtoken"}',
  'ACCOUNT_NUMBER_FORM': '{"acct": "123456-78"}',
  'ACCOUNT_NUMBER_FIELD': '{"account_no": "12345678"}',
  'ACCOUNT_NUMBER_IN_TEXT': '{"note": "계좌 12345678 로 이체"}',
  'BEARER_TOKEN': '{"auth": "Bearer abcdefghijklmnopqrst"}',
  'PRIVATE_KEY_BLOCK': '-----BEGIN RSA PRIVATE KEY-----',
};

void main() {
  group('C-14 픽스처 시크릿 스캔 (01 §7 · §5)', () {
    test('C-14 fixtures/ 전량에 시크릿으로 보이는 패턴이 0건이다', () {
      final List<String> findings = <String>[];
      for (final String path in FixturePaths.all) {
        for (final SecretFinding f in scanForSecrets(readFixture(path))) {
          // 🔴 걸린 원문을 그대로 로그에 남기지 않는다(로더 주석) — 앞 4자만 남긴다.
          final String masked = f.matchedText.length <= 4
              ? f.matchedText
              : '${f.matchedText.substring(0, 4)}…(${f.matchedText.length}자)';
          findings.add('$path @${f.offset} ${f.code}: $masked');
        }
      }
      expect(
        findings,
        isEmpty,
        reason:
            '픽스처는 합성 데이터다 — 실키·계좌 전체번호·비밀번호 0건, 계좌는 '
            '별칭만(01 §5 · 인벤토리 §8).',
      );
    });

    test('C-14 디스크의 모든 .json 을 스캔한다(등재 누락분도 포함)', () {
      // 🔴 `FixturePaths.all` 이 정본이지만, 등재를 잊은 파일이 스캔에서 빠지면
      //    그 파일만 실키를 담을 수 있다. C-1 이 목록 일치를 보장하고 여기서 한 번 더 본다.
      for (final String rel in allFixtureFilesOnDisk()) {
        expect(
          scanForSecrets(readFixture(rel)),
          isEmpty,
          reason: '$rel — 등재 여부와 무관하게 fixtures/ 아래는 전부 합성이어야 한다.',
        );
      }
    });

    test('C-14 스캐너가 실제로 잡는다(패턴별 양성 표본)', () {
      for (final MapEntry<String, String> control
          in _positiveControls.entries) {
        final List<SecretFinding> found = scanForSecrets(control.value);
        expect(
          found.map((SecretFinding f) => f.code),
          contains(control.key),
          reason: '${control.key} 패턴이 자기 표본을 못 잡는다 — 패턴이 망가졌다.',
        );
      }
    });

    test('C-14 모든 등재 패턴에 양성 표본이 있다', () {
      expect(
        secretPatterns.map((SecretPattern p) => p.code).toSet(),
        _positiveControls.keys.toSet(),
        reason:
            '패턴을 더하거나 지우면 양성 표본도 함께 고친다 — 표본 없는 패턴은 '
            '「돌고 있다」를 증명하지 못한다.',
      );
    });

    test('C-14 정상 픽스처 값은 시크릿으로 오탐되지 않는다', () {
      // 🔴 「8자리 이상 연속 숫자」를 그대로 잡으면 금액 문자열이 걸린다(로더 주석).
      const List<String> benign = <String>[
        '{"amount": "30000000"}',
        '{"deposit_amount": "100000"}',
        '{"config_hash": "cfg_fake_0000000000000000"}',
        '{"account_alias": "연금저축"}',
        '{"symbol": "069500", "symbol_label": "069500 KODEX 200"}',
        '{"evidence_hash": "a1b2c3d4e5f6"}',
      ];
      for (final String sample in benign) {
        expect(
          scanForSecrets(sample),
          isEmpty,
          reason: '오탐: $sample — 경보 피로는 검사를 무력화한다.',
        );
      }
    });

    test('C-14 픽스처 봉투가 합성 고지를 싣는다', () {
      for (final String path in FixturePaths.all) {
        expect(
          decodeEnvelope(readFixture(path)).meta.notice,
          contains('합성 데이터'),
          reason: '$path — 고지가 없으면 나중에 본 사람이 실데이터로 오인한다.',
        );
      }
    });

    test('C-14 픽스처 디렉터리 밖의 경로를 코드가 절대 경로로 적지 않는다', () {
      // 01 §5 — 「코드·문서 어디에도 절대 경로를 적지 않는다」.
      // 🔵 v1.1 — 드라이브 문자는 **한 글자**다. 앞이 글자면 URI 스킴(`aaq://`·`handbook://`)이지
      //    경로가 아니다(01 §4-4 내비게이션 계약의 라우트 상수가 여기 걸리지 않게 한다).
      final RegExp absolute = RegExp(
        r'(?<![A-Za-z])[A-Za-z]:[\\/]|^/(?:home|Users)/',
      );
      for (final File f in dartSourcesIn(libDir)) {
        expect(
          absolute.hasMatch(stripComments(f.readAsStringSync())),
          isFalse,
          reason: '${shortPath(f)} — 절대 경로가 코드에 들어가면 반려다(01 §5).',
        );
      }
    });
  });
}
