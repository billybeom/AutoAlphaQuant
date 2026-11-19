// E11p4j — O-04 ③ 생체 서명 칸(설계 13 §8 R159).

import 'dart:async';

import 'package:app_operator_android/safety/biometric_sign_field.dart';
import 'package:core_engine/core_engine.dart' show BiometricSignTexts;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Future<String> Function() sign) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BiometricSignField(sign: sign)),
      ),
    );

FilledButton _button(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byKey(const Key('m5-bio-sign')));

void main() {
  testWidgets('🔴 처음 = 엔진 글자 버튼 하나 · 결과 줄 없음', (WidgetTester tester) async {
    await _pump(tester, () async => 'x');
    expect(find.text(BiometricSignTexts.button), findsOneWidget);
    expect(_button(tester).onPressed, isNotNull);
    expect(find.byKey(const Key('m5-bio-result')), findsNothing);
  });

  testWidgets('🔴 누르면 묻는 동안 잠금 · 결과 = 동작이 준 문장 그대로 · 다시 누를 수 있다', (
    WidgetTester tester,
  ) async {
    final Completer<String> wait = Completer<String>();
    int calls = 0;
    await _pump(tester, () {
      calls++;
      return wait.future;
    });
    await tester.tap(find.byKey(const Key('m5-bio-sign')));
    await tester.pump();
    expect(calls, 1);
    expect(_button(tester).onPressed, isNull);
    wait.complete(BiometricSignTexts.canceled);
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('m5-bio-result'))).data,
      BiometricSignTexts.canceled,
    );
    expect(_button(tester).onPressed, isNotNull);
  });

  testWidgets('🔴 플랫폼 오류 = «할 수 없음» 문장(성공을 지어내지 않는다)', (
    WidgetTester tester,
  ) async {
    await _pump(tester, () async => throw StateError('channel'));
    await tester.tap(find.byKey(const Key('m5-bio-sign')));
    await tester.pump();
    await tester.pump();
    expect(find.text(BiometricSignTexts.unavailable), findsOneWidget);
    expect(_button(tester).onPressed, isNotNull);
  });
}
