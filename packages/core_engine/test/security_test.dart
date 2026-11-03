// 키 금고 포트 · 마스킹 · 지문 · 회전 · 봉함(설계 13 §8 R44 E2~E6 · E9 · 06 M4-4 · 04_안전장치 SAF-905 · SAF-906).

import 'dart:convert';
import 'dart:typed_data';

import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:test/test.dart';

// 🔴 시험용 값 — 실물 키가 아니다(꼴만 비슷하게).
const String _oldKey = 'PSoldKEY0123456789abcdefOLDKEY9999';
const String _newKey = 'PSnewKEY0123456789abcdefNEWKEY7777';

Uint8List _b(String s) => Uint8List.fromList(utf8.encode(s));

void main() {
  group('SecretId · 금고 포트(R44 E2)', () {
    test(
      '이름 꼴 = 소문자 · 숫자 · ._- · 1~64자 — 아니면 ArgumentError(값이 이름에 섞이는 실수)',
      () {
        expect(SecretId('kis.live.app_key').value, 'kis.live.app_key');
        expect(SecretId('a').value, 'a');
        expect(SecretId('x' * 64).value, hasLength(64));
        for (final String bad in <String>[
          '',
          'Kis.live',
          '.kis',
          'kis live',
          'kis/live',
          'x' * 65,
          _oldKey,
        ]) {
          expect(() => SecretId(bad), throwsArgumentError, reason: bad);
        }
        // 🔴 꼴 오류 메시지에 값이 없다(길이만).
        try {
          SecretId(_oldKey);
        } on ArgumentError catch (e) {
          expect(e.toString().contains(_oldKey), isFalse);
        }
        expect(SecretId('a.b') == SecretId('a.b'), isTrue);
        expect(SecretId('a.b').hashCode, SecretId('a.b').hashCode);
        expect(SecretId('a.b') == SecretId('a.c'), isFalse);
      },
    );

    test(
      'readAllSecretValues = 이름 순 · 빈 값 빼고 · 🔴 한 칸이라도 못 읽으면 던진다(빠진 채 통과 금지)',
      () async {
        final MemorySecretVault v = MemorySecretVault(<String, String>{
          'b.key': 'BBBBBBBBBB',
          'a.key': 'AAAAAAAAAA',
          'c.empty': '',
        });
        expect(await readAllSecretValues(v), <String>[
          'AAAAAAAAAA',
          'BBBBBBBBBB',
        ]);
        v.failReadsOf.add('b.key');
        await expectLater(
          readAllSecretValues(v),
          throwsA(isA<SecretVaultError>()),
        );
      },
    );

    test('🔴 금고 오류 · 호출 기록에 값 0', () async {
      final MemorySecretVault v = MemorySecretVault()
        ..failWritesTo.add('kis.app_key');
      Object? err;
      try {
        await v.write(SecretId('kis.app_key'), _oldKey);
      } on Object catch (e) {
        err = e;
      }
      expect(err, isA<SecretVaultError>());
      expect(err.toString().contains(_oldKey), isFalse);
      expect(v.calls.join(' ').contains(_oldKey), isFalse);
    });
  });

  group('마스킹 · 지문 · 본문 가림(R44 E3 · E4)', () {
    test('키 = 앞 4 … 뒤 4 · 12자 미만 = 전부 가림', () {
      expect(maskSecret(_oldKey), 'PSol…9999');
      expect(maskSecret('abcdefghijkl'), 'abcd…ijkl');
      expect(maskSecret('abcdefghijk'), '••••');
      expect(maskSecret(''), '••••');
    });

    test('계좌 = 뒤 4(SAF-906) · 상품코드 떼고 · 숫자 4개 이하 = 전부 가림', () {
      expect(maskAccount('12345678'), '****5678');
      expect(maskAccount('12345678-01'), '****5678');
      expect(maskAccount('1234 5678'), '****5678');
      expect(maskAccount('12345'), '****2345');
      expect(maskAccount('1234'), '****');
      expect(maskAccount(''), '****');
    });

    test('지문 = sha256 앞 8(16진) · 같은 값 = 같은 지문 · 값이 안 나온다', () {
      // sha256("abc") = ba7816bf…
      expect(secretFingerprint('abc'), 'ba7816bf');
      expect(secretFingerprint(_oldKey), hasLength(8));
      expect(secretFingerprint(_oldKey), secretFingerprint(_oldKey));
      expect(secretFingerprint(_oldKey) == secretFingerprint(_newKey), isFalse);
      expect(
        RegExp(r'^[0-9a-f]{8}$').hasMatch(secretFingerprint(_newKey)),
        isTrue,
      );
    });

    test('본문 가림 = 알려진 값 전부 · 긴 값 먼저 · 8자 미만 무시', () {
      const String acct = '12345678';
      final String text =
          '{"appkey":"$_oldKey","acnt":"$acct","prdt":"01","again":"$_oldKey"}';
      final String out = redactSecrets(text, <String>[acct, _oldKey, '01']);
      expect(out.contains(_oldKey), isFalse);
      expect(out.contains(acct), isFalse);
      expect(out, contains('"prdt":"01"'));
      expect(kRedacted.allMatches(out), hasLength(3));
      // 긴 값 먼저 — 짧은 값이 긴 값의 일부여도 긴 값이 통째로 가려진다.
      const String long = 'ABCDEFGH12345678';
      const String part = 'ABCDEFGH';
      expect(
        redactSecrets('x $long y $part', <String>[part, long]),
        'x $kRedacted y $kRedacted',
      );
      expect(kMinRedactLength, 8);
      expect(redactSecrets('1234567', <String>['1234567']), '1234567');
      expect(redactSecrets('12345678', <String>['12345678']), kRedacted);
    });
  });

  group('회전 상태기계(R44 E5 · 06 M4-4)', () {
    test(
      'idle → staged → verified → committed — 🔴 committed 앞에서는 구키 폐기 불가',
      () {
        final KeyRotation r = KeyRotation('old0fp00');
        expect((r.stage, r.canDiscardOld), (KeyRotationStage.idle, false));
        expect(r.commit, throwsStateError);
        r.stageNew('new0fp00');
        expect(
          (r.stage, r.stagedFingerprint, r.canDiscardOld),
          (KeyRotationStage.staged, 'new0fp00', false),
        );
        expect(r.commit, throwsStateError);
        r.recordVerification(passed: true);
        expect((r.stage, r.canDiscardOld), (KeyRotationStage.verified, false));
        r.commit();
        expect(
          (r.stage, r.currentFingerprint, r.stagedFingerprint, r.canDiscardOld),
          (KeyRotationStage.committed, 'new0fp00', null, true),
        );
        expect(r.abort, throwsStateError);
      },
    );

    test(
      '검증 실패 = failed(구키 유지) → 다시 받기 · 그만두기 = idle · 같은 키 = ArgumentError',
      () {
        final KeyRotation r = KeyRotation('old0fp00');
        expect(() => r.stageNew('old0fp00'), throwsArgumentError);
        expect(() => r.recordVerification(passed: true), throwsStateError);
        r.stageNew('bad0fp00');
        expect(() => r.stageNew('bad1fp00'), throwsStateError);
        r.recordVerification(passed: false);
        expect(
          (r.stage, r.currentFingerprint, r.canDiscardOld),
          (KeyRotationStage.failed, 'old0fp00', false),
        );
        expect(r.commit, throwsStateError);
        expect(() => r.recordVerification(passed: true), throwsStateError);
        r.stageNew('new0fp00');
        expect(r.stage, KeyRotationStage.staged);
        r.abort();
        expect(
          (r.stage, r.stagedFingerprint, r.currentFingerprint),
          (KeyRotationStage.idle, null, 'old0fp00'),
        );
        r.stageNew('new1fp00');
        r.recordVerification(passed: true);
        r.abort();
        expect(
          (r.stage, r.currentFingerprint),
          (KeyRotationStage.idle, 'old0fp00'),
        );
      },
    );
  });

  group('금고 회전 rotateSecret(R44 E5)', () {
    final SecretId id = SecretId('kis.live.app_key');

    test('통과 = 임시 칸 먼저 → 검증 → 본 칸 덮기 → 임시 삭제 · 🔴 검증 때 본 칸은 아직 구키', () async {
      final MemorySecretVault v = MemorySecretVault(<String, String>{
        'kis.live.app_key': _oldKey,
      });
      String? mainDuringVerify;
      String? stagedDuringVerify;
      final RotationOutcome o = await rotateSecret(
        v,
        id,
        _newKey,
        verify: (String c) async {
          mainDuringVerify = v.peek('kis.live.app_key');
          stagedDuringVerify = v.peek('kis.live.app_key.staged');
          return c == _newKey;
        },
      );
      expect(o, RotationOutcome.committed);
      expect(mainDuringVerify, _oldKey);
      expect(stagedDuringVerify, _newKey);
      expect(v.peek('kis.live.app_key'), _newKey);
      expect(v.peek('kis.live.app_key.staged'), isNull);
      expect(v.calls, <String>[
        'read:kis.live.app_key',
        'write:kis.live.app_key.staged',
        'write:kis.live.app_key',
        'delete:kis.live.app_key.staged',
      ]);
      expect(stagedSecretId(id).value, 'kis.live.app_key.staged');
    });

    test('거절 · 예외 = 임시 칸만 지우고 구키 그대로 · 🔴 예외 내용은 결과에 없다', () async {
      final MemorySecretVault v = MemorySecretVault(<String, String>{
        'kis.live.app_key': _oldKey,
      });
      expect(
        await rotateSecret(v, id, _newKey, verify: (String c) async => false),
        RotationOutcome.verifyRejected,
      );
      expect(v.peek('kis.live.app_key'), _oldKey);
      expect(v.peek('kis.live.app_key.staged'), isNull);
      v.calls.clear();
      expect(
        await rotateSecret(
          v,
          id,
          _newKey,
          verify: (String c) async => throw StateError('401 $c'),
        ),
        RotationOutcome.verifyError,
      );
      expect(v.peek('kis.live.app_key'), _oldKey);
      expect(v.peek('kis.live.app_key.staged'), isNull);
      expect(
        v.calls.where((String c) => c == 'write:kis.live.app_key'),
        isEmpty,
      );
      expect(RotationOutcome.verifyError.toString().contains(_newKey), isFalse);
    });

    test('구키 없음 = StateError · 같은 값 = ArgumentError(아무것도 쓰지 않는다)', () async {
      final MemorySecretVault empty = MemorySecretVault();
      await expectLater(
        rotateSecret(empty, id, _newKey, verify: (String c) async => true),
        throwsStateError,
      );
      final MemorySecretVault v = MemorySecretVault(<String, String>{
        'kis.live.app_key': _oldKey,
      });
      await expectLater(
        rotateSecret(v, id, _oldKey, verify: (String c) async => true),
        throwsArgumentError,
      );
      expect(v.calls, <String>['read:kis.live.app_key']);
    });

    test('임시 칸 쓰기 실패 = 던진다 · 검증 안 부름 · 구키 그대로', () async {
      final MemorySecretVault v = MemorySecretVault(<String, String>{
        'kis.live.app_key': _oldKey,
      })..failWritesTo.add('kis.live.app_key.staged');
      bool called = false;
      await expectLater(
        rotateSecret(v, id, _newKey, verify: (String c) async => called = true),
        throwsA(isA<SecretVaultError>()),
      );
      expect(called, isFalse);
      expect(v.peek('kis.live.app_key'), _oldKey);
    });
  });

  group('봉함(R44 E6 · 01 §12-1 «해독 실패 = null»)', () {
    test('봉하고 열기 · 🔴 aad 다름 · 변조 · 잘림 · 키 소실 = null(던지지 않는다)', () async {
      final FakeSealedBox box = FakeSealedBox();
      final Uint8List s = await box.seal(_b('초안 본문'), aad: 'draft|SIM');
      expect(utf8.decode((await box.open(s, aad: 'draft|SIM'))!), '초안 본문');
      expect(await box.open(s, aad: 'draft|LIVE'), isNull);
      final Uint8List bad = Uint8List.fromList(s)..[s.length - 6] ^= 0x01;
      expect(await box.open(bad, aad: 'draft|SIM'), isNull);
      expect(await box.open(Uint8List(3), aad: 'draft|SIM'), isNull);
      box.loseKey();
      expect(await box.open(s, aad: 'draft|SIM'), isNull);
      final Uint8List s2 = await box.seal(_b('새 본문'), aad: 'draft|SIM');
      expect(utf8.decode((await box.open(s2, aad: 'draft|SIM'))!), '새 본문');
    });
  });
}
