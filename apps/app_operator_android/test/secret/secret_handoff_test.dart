// E11p3d-5b 시크릿 넘김 · 클립보드 정리 · 붙여넣기 판정(설계 13 §8 R115 · 05 §4 6원칙). 값 = 연습 값만(실키 0).

import 'package:app_operator_android/secret/secret_handoff.dart';
import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentials, KisEnvironment, KisKeySet;
import 'package:domain_contracts/domain_contracts.dart' show OnboardingSlotIds;
import 'package:flutter_test/flutter_test.dart';

const String _key = 'PSTESTAPPKEY0000000000001';

class _Src implements KisDraftSource {
  KisCredentials? value;
  int cleared = 0;
  @override
  KisCredentials? current() => value;
  @override
  void clear() => cleared++;
}

void main() {
  group('🔴 붙여넣기 판정(원칙 6)', () {
    test('앱키 · 시크릿 = 영숫자 16자 이상 · 앞뒤 빈칸은 뗀다', () {
      expect(kisPasteProblem(KisPasteField.appKey, _key), isNull);
      expect(kisPasteProblem(KisPasteField.appSecret, '  $_key\n'), isNull);
      expect(
        kisPasteProblem(KisPasteField.appKey, 'PSSHORT123'),
        KisPasteProblem.notAppKey,
      );
      expect(
        kisPasteProblem(KisPasteField.appKey, 'PS키값TEST0000000000000'),
        KisPasteProblem.notAppKey,
      );
    });

    test('빈 값 · 빈칸 · 줄바꿈 · 따옴표 = 거부', () {
      expect(
        kisPasteProblem(KisPasteField.appKey, '   '),
        KisPasteProblem.empty,
      );
      for (final String v in <String>[
        'PSTEST APPKEY000000001',
        'PSTEST\nAPPKEY00000001',
        '"PSTESTAPPKEY00000001"',
        "PSTESTAPPKEY0000001'",
      ]) {
        expect(
          kisPasteProblem(KisPasteField.appKey, v),
          KisPasteProblem.whitespace,
          reason: v,
        );
      }
    });

    test('다른 서비스의 키 꼴 = 거부(세 칸 모두)', () {
      for (final String v in <String>[
        'eyJhbGciOiJIUzI1NiJ9.service_role.sig',
        'ghp_0000000000000000000000000000',
        'github_pat_00000000000000000000',
        'ya29.a0AfH6SMB000000000000',
        '1//0gTESTTOKEN000000000',
        'sb_secret_0000000000000000',
        'xoxb-000000000000-000000',
        'https://hc-ping.com/00000000',
      ]) {
        for (final KisPasteField f in KisPasteField.values) {
          expect(
            kisPasteProblem(f, v),
            KisPasteProblem.foreignKey,
            reason: '$f $v',
          );
        }
      }
    });

    test('계좌 = 숫자 8자리 · `-` 뒤 2자리 선택 · 상품코드를 가른다', () {
      expect(kisPasteProblem(KisPasteField.account, '12345678'), isNull);
      expect(kisPasteProblem(KisPasteField.account, '12345678-02'), isNull);
      for (final String v in <String>[
        '1234567',
        '123456789',
        '12345678-1',
        '1234567a',
        '12345678-01-1',
      ]) {
        expect(
          kisPasteProblem(KisPasteField.account, v),
          KisPasteProblem.notAccount,
          reason: v,
        );
      }
      expect(splitKisAccount('12345678'), ('12345678', null));
      expect(splitKisAccount(' 12345678-02 '), ('12345678', '02'));
    });
  });

  test('🔴 슬롯 이름 → 키 세트 = 엔진에 있는 세트만', () {
    expect(kisKeySetOfSlot(OnboardingSlotIds.secretKisMock), KisKeySet.paper);
    for (final String s in OnboardingSlotIds.values) {
      if (s == OnboardingSlotIds.secretKisMock) continue;
      expect(kisKeySetOfSlot(s), isNull, reason: s);
    }
    expect(kisKeySetOfSlot('SECRET_KIS_LIVE'), isNull);
  });

  group('🔴 넘김(원칙 3 — 값을 복사해 두지 않는다)', () {
    test('붙은 위젯에게 묻는다 · 떨어지면 없음 · 다른 위젯은 떼지 못한다', () {
      final SecretHandoff h = SecretHandoff();
      final _Src a = _Src(), b = _Src();
      expect(h.draftOf(KisKeySet.paper), isNull);
      h.attach(KisKeySet.paper, a);
      expect(h.draftOf(KisKeySet.paper), isNull);
      final KisCredentials c = KisCredentials(
        environment: KisEnvironment.mock,
        appKey: _key,
        appSecret: _key,
        accountNo: '12345678',
      );
      a.value = c;
      expect(identical(h.draftOf(KisKeySet.paper), c), true);
      a.value = null;
      expect(h.draftOf(KisKeySet.paper), isNull);
      h.detach(KisKeySet.paper, b);
      expect(h.isOnScreen(KisKeySet.paper), true);
      a.value = c;
      expect(h.draftOf(KisKeySet.paper), isNotNull);
      h.clearAfterSave(KisKeySet.paper);
      expect(a.cleared, 1);
      h.detach(KisKeySet.paper, a);
      expect(h.isOnScreen(KisKeySet.paper), false);
      expect(h.draftOf(KisKeySet.paper), isNull);
      h.clearAfterSave(KisKeySet.paper);
      expect(a.cleared, 1);
    });
  });

  group('🔴 클립보드 정리(원칙 1)', () {
    late String? board;
    late List<String> writes;
    ClipboardJanitor janitor() => ClipboardJanitor(
      after: const Duration(milliseconds: 20),
      read: () async => board,
      write: (String t) async {
        writes.add(t);
        board = t;
      },
    );

    setUp(() {
      board = _key;
      writes = <String>[];
    });

    test('그대로면 시간 뒤 비운다 · 그 전에는 두지 않는다', () async {
      janitor().pasted(_key);
      expect(writes, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(writes, <String>['']);
    });

    test('그 사이 다른 것을 복사했으면 둔다', () async {
      janitor().pasted(_key);
      board = '다른 메모';
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(writes, isEmpty);
    });

    test('못 읽으면 비운다(안전 쪽)', () async {
      board = null;
      janitor().pasted(_key);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(writes, <String>['']);
    });

    test('다시 붙여넣으면 다시 센다 · flush = 지금 · dispose = 정리 안 함', () async {
      final ClipboardJanitor j = janitor()..pasted(_key);
      await Future<void>.delayed(const Duration(milliseconds: 12));
      j.pasted(_key);
      await Future<void>.delayed(const Duration(milliseconds: 12));
      expect(writes, isEmpty);
      await j.flush();
      expect(writes, <String>['']);
      writes.clear();
      board = _key;
      j
        ..pasted(_key)
        ..dispose();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(writes, isEmpty);
    });
  });
}
