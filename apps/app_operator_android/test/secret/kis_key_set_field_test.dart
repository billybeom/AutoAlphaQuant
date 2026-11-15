// E11p3d-5b KIS 키 세트 시크릿 칸(설계 13 §8 R115 · 05 §4 6원칙 · M4-4). 값 = 연습 값만(실키 0).

import 'package:app_operator_android/app/secure_screen.dart';
import 'package:app_operator_android/secret/kis_key_set_field.dart';
import 'package:app_operator_android/secret/secret_handoff.dart';
import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentials, KisEnvironment, KisKeySet;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const String _key = 'PSTESTAPPKEY0000000000001';
const String _secret = 'TESTSECRETVALUEabcdefghijklmnop9876';

void main() {
  late String? board;
  late List<String> writes;
  late List<bool> secureCalls;
  late SecretHandoff handoff;
  late ClipboardJanitor janitor;

  setUp(() {
    board = null;
    writes = <String>[];
    secureCalls = <bool>[];
    handoff = SecretHandoff();
    janitor = ClipboardJanitor(
      read: () async => board,
      write: (String t) async {
        writes.add(t);
        board = t;
      },
    );
  });

  Future<void> pump(WidgetTester tester, {Widget? other}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child:
                other ??
                KisKeySetField(
                  set: KisKeySet.paper,
                  handoff: handoff,
                  janitor: janitor,
                  secure: SecureScreen((bool on) async => secureCalls.add(on)),
                  readClipboard: () async => board,
                ),
          ),
        ),
      ),
    );
  }

  Future<void> paste(
    WidgetTester tester,
    KisPasteField f,
    String? value,
  ) async {
    board = value;
    await tester.tap(find.byKey(Key('m4-secret-${f.name}-paste')));
    await tester.pump();
  }

  String shown(WidgetTester tester, KisPasteField f) =>
      tester.widget<Text>(find.byKey(Key('m4-secret-${f.name}-shown'))).data!;

  /// 화면 글자 전부(값이 새지 않았는지).
  List<String> texts(WidgetTester tester) => <String>[
    for (final Text t in tester.widgetList<Text>(find.byType(Text)))
      t.data ?? '',
  ];

  testWidgets('🔴 붙여넣기 → 엔진 마스킹 표시 · 전체 값은 화면 어디에도 없다', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    expect(shown(tester, KisPasteField.appKey), SecretLabels.empty);
    await paste(tester, KisPasteField.appKey, _key);
    await paste(tester, KisPasteField.appSecret, _secret);
    await paste(tester, KisPasteField.account, '12345678-02');
    expect(shown(tester, KisPasteField.appKey), 'PSTE…0001');
    expect(shown(tester, KisPasteField.appSecret), 'TEST…9876');
    expect(shown(tester, KisPasteField.account), '****5678 · 상품 02');
    final List<String> all = texts(tester);
    expect(all, isNotEmpty);
    for (final String t in all) {
      expect(t.contains(_key), false);
      expect(t.contains(_secret), false);
      expect(t.contains('12345678'), false);
    }
    await tester.pump(const Duration(seconds: 60));
  });

  testWidgets('🔴 글자 입력 칸 0 · 확인(한 번 더) 칸 0 · 열람 버튼 0', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    expect(find.byType(EditableText), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextButton), findsNWidgets(KisPasteField.values.length));
  });

  testWidgets('🔴 거부 = 사유 문구 · 값은 그대로(원칙 6)', (WidgetTester tester) async {
    await pump(tester);
    await paste(tester, KisPasteField.appKey, _key);
    await paste(tester, KisPasteField.appKey, 'eyJhbGciOi.service_role.sig');
    expect(shown(tester, KisPasteField.appKey), 'PSTE…0001');
    expect(
      find.text(SecretLabels.problem(KisPasteProblem.foreignKey)),
      findsOneWidget,
    );
    await paste(tester, KisPasteField.account, '1234-5678');
    expect(shown(tester, KisPasteField.account), SecretLabels.empty);
    expect(
      find.text(SecretLabels.problem(KisPasteProblem.notAccount)),
      findsOneWidget,
    );
    // 맞는 값을 다시 붙여넣으면 사유가 걷힌다.
    await paste(tester, KisPasteField.appKey, _key);
    expect(
      find.text(SecretLabels.problem(KisPasteProblem.foreignKey)),
      findsNothing,
    );
    await paste(tester, KisPasteField.appSecret, null);
    expect(find.text(SecretLabels.clipboardEmpty), findsOneWidget);
    await tester.pump(const Duration(seconds: 60));
  });

  testWidgets('🔴 넘김 = 세 칸이 다 찬 뒤에만 · 상품코드 기본 01 · 비우기 · 내려가면 떨어진다', (
    WidgetTester tester,
  ) async {
    expect(handoff.isOnScreen(KisKeySet.paper), false);
    await pump(tester);
    expect(handoff.isOnScreen(KisKeySet.paper), true);
    expect(handoff.draftOf(KisKeySet.paper), isNull);
    // 앞뒤 빈칸 · 줄바꿈은 떼고 받는다(메모장 복사 꼴).
    await paste(tester, KisPasteField.appKey, '  $_key\n');
    await paste(tester, KisPasteField.appSecret, _secret);
    expect(handoff.draftOf(KisKeySet.paper), isNull);
    await paste(tester, KisPasteField.account, '12345678');
    final KisCredentials c = handoff.draftOf(KisKeySet.paper)!;
    expect(c.environment, KisEnvironment.mock);
    expect(c.appKey, _key);
    expect(c.appSecret, _secret);
    expect(c.accountNo, '12345678');
    expect(c.productCode, '01');
    expect(c.toString(), isNot(contains(_key)));
    handoff.clearAfterSave(KisKeySet.paper);
    await tester.pump();
    expect(handoff.draftOf(KisKeySet.paper), isNull);
    expect(shown(tester, KisPasteField.appKey), SecretLabels.empty);
    await paste(tester, KisPasteField.appKey, _key);
    await pump(tester, other: const SizedBox());
    expect(handoff.isOnScreen(KisKeySet.paper), false);
    expect(handoff.draftOf(KisKeySet.paper), isNull);
    await tester.pump(const Duration(seconds: 60));
  });

  testWidgets('🔴 클립보드 = 붙여넣고 60초 뒤 비운다(그 전 0)', (WidgetTester tester) async {
    await pump(tester);
    await paste(tester, KisPasteField.appKey, _key);
    await tester.pump(const Duration(seconds: 59));
    expect(writes, isEmpty);
    await tester.pump(const Duration(seconds: 2));
    expect(writes, <String>['']);
  });

  testWidgets('🔴 칸이 서 있는 동안 캡처 막기(FLAG_SECURE) · 내려가면 끈다', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    await tester.pump();
    expect(secureCalls, <bool>[true]);
    await pump(tester, other: const SizedBox());
    await tester.pump();
    expect(secureCalls, <bool>[true, false]);
  });
}
