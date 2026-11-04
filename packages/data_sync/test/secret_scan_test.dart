// 시크릿 스캔 게이트(설계 13 §8 R44 E7 · 06 M4-6 «고의 혼입 픽스처가 차단되는지» · 지도 D16).
//
// 🔴 토큰 꼴 문자열은 파일에 그대로 두지 않고 시험 안에서 이어 붙여 만든다 — 저장소에 토큰 꼴이 남으면
//    GitHub 쪽 검사 · 우리 스캐너가 저장소 자체를 막는다.

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:test/test.dart';

String _rep(String unit, int n) => List<String>.filled(n, unit).join();

// 시험용 가짜 값(실물 아님).
final String _appKey = 'PS${_rep('Ab3', 12)}';
final String _appSecret = _rep('xY9+', 45);
const String _account = '87654321';
final String _ya29 = 'ya29.${_rep('a1B_', 10)}';
final String _refresh = '1//${_rep('0c-Z', 8)}';
final String _ghp = 'gh${'p_'}${_rep('A1b2', 9)}';
final String _ghPat = 'github${'_pat_'}${_rep('11ABC_', 12)}';

List<SecretFindingKind> _kinds(SecretScanResult r) =>
    r.findings.map((SecretFinding f) => f.kind).toList();

void main() {
  group('정확 값(R44 E7 ①)', () {
    test('금고 값이 어디에 있든 잡는다 · 지문만 싣는다 · 8자 미만 무시', () {
      final String text =
          'line one\n{"CANO":"$_account","ACNT_PRDT_CD":"01"}\nkey=$_appKey 끝';
      final SecretScanResult r = scanForSecrets(
        text,
        exactValues: <String>[_account, _appKey, '01'],
        source: 'archive/2026-11-04.jsonl',
      );
      expect(r.blocked, isTrue);
      expect(r.findings, <SecretFinding>[
        SecretFinding(
          kind: SecretFindingKind.exactValue,
          line: 2,
          column: 10,
          fingerprint: secretFingerprint(_account),
        ),
        SecretFinding(
          kind: SecretFindingKind.exactValue,
          line: 3,
          column: 5,
          fingerprint: secretFingerprint(_appKey),
        ),
      ]);
    });

    test('같은 값 두 번 = 두 건 · 빈 목록 = 정확 값 검사 없음', () {
      final SecretScanResult r = scanForSecrets(
        '$_account / $_account',
        exactValues: <String>[_account, _account],
      );
      expect(r.findings.map((SecretFinding f) => f.column), <int>[1, 12]);
      expect(
        scanForSecrets(_account, exactValues: const <String>[]).blocked,
        isFalse,
      );
    });

    test('금고에서 바로 — readAllSecretValues 와 이어 쓴다', () async {
      final MemorySecretVault v = MemorySecretVault(<String, String>{
        'kis.live.app_key': _appKey,
        'kis.live.account_no': _account,
      });
      final SecretScanResult r = scanForSecrets(
        'x $_appKey y',
        exactValues: await readAllSecretValues(v),
      );
      expect(r.findings.single.fingerprint, secretFingerprint(_appKey));
    });
  });

  group('접두 패턴(R44 E7 ②)', () {
    test('ya29. · 1// · ghp_ · github_pat_ · Bearer — 금고에 없어도 잡는다', () {
      final String text = <String>[
        'g=$_ya29',
        'r=$_refresh',
        'h=$_ghp',
        'p=$_ghPat',
        'Authorization: Bearer ${_rep('tok3n', 6)}',
      ].join('\n');
      final SecretScanResult r = scanForSecrets(
        text,
        exactValues: const <String>[],
      );
      expect(_kinds(r), <SecretFindingKind>[
        SecretFindingKind.googleAccessToken,
        SecretFindingKind.googleRefreshToken,
        SecretFindingKind.githubToken,
        SecretFindingKind.githubToken,
        SecretFindingKind.bearerToken,
      ]);
      expect(r.findings.map((SecretFinding f) => f.line), <int>[1, 2, 3, 4, 5]);
    });

    test('짧은 꼴 · URL 의 // · 본문 «bearer» 낱말 = 통과', () {
      final String text = <String>[
        'ya29.short',
        'https://openapivts.koreainvestment.com:29443/uapi',
        'gh${'p_'}abc',
        'the bearer of bad news',
        'Bearer short',
      ].join('\n');
      expect(
        scanForSecrets(text, exactValues: const <String>[]).blocked,
        isFalse,
      );
    });
  });

  group('시크릿 필드(R44 E7 ③ · SAF-904)', () {
    test('JSON · 키=값 — KIS 키 꼴을 몰라도 appkey · appsecret · access_token · hashkey 를 잡는다', () {
      final String text = <String>[
        '{"appkey":"$_appKey","appsecret":"$_appSecret"}',
        '{"access_token":"${_rep('eyJ0', 10)}","token_type":"Bearer"}',
        '{"HASHKEY": "${_rep('h4sh', 4)}"}',
        'KIS_APP_KEY=$_appKey',
        'refresh_token: ${_rep('r3fr', 5)}',
        '{"approval_key":"${_rep('appr', 5)}"}',
      ].join('\n');
      final SecretScanResult r = scanForSecrets(
        text,
        exactValues: const <String>[],
      );
      expect(
        r.findings.map((SecretFinding f) => '${f.line}:${f.field}'),
        <String>[
          '1:appkey',
          '1:appsecret',
          '2:access_token',
          '3:hashkey',
          '4:app_key',
          '5:refresh_token',
          '6:approval_key',
        ],
      );
      expect(
        r.findings.every(
          (SecretFinding f) => f.kind == SecretFindingKind.secretField,
        ),
        isTrue,
      );
    });

    test('🔴 가림 값 · 빈 값 · 짧은 값 = 통과(가린 기록이 매일 P1 을 내지 않게)', () {
      final String text = <String>[
        '{"appkey":"$kRedacted","appsecret":"***","access_token":""}',
        '{"appkey":"${maskSecret(_appKey)}","hashkey":"••••"}',
        '{"authorization":"REDACTED","appsecret":"xxxxxxxxxxxx"}',
        'app_key=<가림> access_token=short',
      ].join('\n');
      expect(
        scanForSecrets(text, exactValues: const <String>[]).blocked,
        isFalse,
      );
    });

    test('같은 자리 = 한 번만(정확 값이 이기고 지문이 남는다)', () {
      final SecretScanResult r = scanForSecrets(
        '{"appkey":"$_appKey"}',
        exactValues: <String>[_appKey],
      );
      expect(r.findings.single.kind, SecretFindingKind.exactValue);
      expect(r.findings.single.fingerprint, secretFingerprint(_appKey));
      expect(r.findings.single.column, 12);
    });
  });

  group('🔴 오탐 0(D16 · 경보 피로 규칙)', () {
    test('체결조회 ord_dt · 주문번호 · 8자리 숫자 · 연속조회 키 = 통과(8자리 숫자 패턴 없음)', () {
      const String text =
          '{"ord_dt":"20261104","odno":"0000012345","orgn_odno":"",'
          '"pdno":"133690","ord_qty":"1","tot_ccld_qty":"1",'
          '"ctx_area_fk100":"12345678^87654321^01^^^^^","ctx_area_nk100":"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",'
          '"rt_cd":"0","msg_cd":"KIOK0000","tr_id":"VTTC8001R","date":"20261104","seq":"12345678"}';
      final SecretScanResult r = scanForSecrets(
        text,
        exactValues: const <String>[],
      );
      expect(r.blocked, isFalse, reason: r.toString());
    });

    test('큰 base64 덩어리에서도 빨리 끝난다(되짚기 폭주 없음)', () {
      final String blob = _rep('QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVo', 3000);
      final Stopwatch sw = Stopwatch()..start();
      final SecretScanResult r = scanForSecrets(
        'data=$blob\n',
        exactValues: <String>[_appKey],
      );
      sw.stop();
      expect(r.blocked, isFalse);
      expect(sw.elapsed, lessThan(const Duration(seconds: 2)));
    });
  });

  group('🔴 결과에 값 0(R44 E9)', () {
    test('찾은 것 · 결과 문자열에 값 · 발췌가 없다', () {
      final String text = <String>[
        '{"appkey":"$_appKey","CANO":"$_account"}',
        'g=$_ya29 h=$_ghp',
        'KIS_APP_SECRET=$_appSecret',
      ].join('\n');
      final SecretScanResult r = scanForSecrets(
        text,
        exactValues: <String>[_account],
        source: 'archive/x.jsonl',
      );
      expect(r.findings, hasLength(5));
      final String s = r.toString();
      for (final String secret in <String>[
        _appKey,
        _account,
        _ya29,
        _ghp,
        _appSecret,
      ]) {
        expect(s.contains(secret), isFalse);
        expect(
          s.contains(
            secret.substring(0, secret.length < 12 ? secret.length : 12),
          ),
          isFalse,
        );
      }
      expect(s, startsWith('SecretScan(archive/x.jsonl): 막음 5건'));
      expect(
        scanForSecrets('ok', exactValues: const <String>[]).toString(),
        'SecretScan(): 통과',
      );
    });
  });
}
