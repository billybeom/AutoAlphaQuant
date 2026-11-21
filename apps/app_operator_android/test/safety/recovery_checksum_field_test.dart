// E11k-e3 — O-04 ⑤ 복구 카드 체크섬 칸(M4-10 · 설계 13 §8 R229).
//
// 🔵 잡는 것: ① 입력 칸 + 확인 버튼 · 글자 = 엔진 ② 누르면 칸을 곧바로 비운다 · 확인에 간 값 = 입력 그대로 · 결과 = 엔진 문장 ③ 대기 =
//    입력 칸 없이 «등록 다시 시도» ④ 묻는 동안 잠금 · 오류 = «잠시 뒤» 문장(성공을 지어내지 않는다) ⑤ 서 있는 동안 캡처 막기(켬 → 끔)
//    ⑥ 자동 완성 · 제안 · 키보드 학습 0.

import 'dart:async';

import 'package:app_operator_android/app/secure_screen.dart';
import 'package:app_operator_android/safety/recovery_checksum_field.dart';
import 'package:core_engine/core_engine.dart'
    show FirstClaimOutcome, RecoveryCardTexts;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Rig {
  final List<bool> sets = <bool>[];
  late final SecureScreen screen = SecureScreen(
    (bool on) async => sets.add(on),
  );
  final List<String> typed = <String>[];
  int retries = 0;
  bool pending = false;
  Future<FirstClaimOutcome> Function() answer = () async =>
      FirstClaimOutcome.claimed;

  Widget widget() => MaterialApp(
    home: Scaffold(
      body: RecoveryChecksumField(
        confirm: (String t) {
          typed.add(t);
          return answer();
        },
        retry: () {
          retries++;
          return answer();
        },
        pending: () => pending,
        secure: screen,
      ),
    ),
  );
}

FilledButton _button(WidgetTester t, String key) =>
    t.widget<FilledButton>(find.byKey(Key(key)));

void main() {
  testWidgets(
    '🔴 처음 = 입력 칸 + 확인(엔진 글자) · 결과 줄 없음 · 자동 완성 · 제안 · 학습 0 · 캡처 막기 켬',
    (WidgetTester t) async {
      final _Rig r = _Rig();
      await t.pumpWidget(r.widget());
      await t.pump();
      expect(find.text(RecoveryCardTexts.confirmButton), findsOneWidget);
      expect(find.text(RecoveryCardTexts.inputLabel), findsOneWidget);
      expect(find.byKey(const Key('m4-rc-retry')), findsNothing);
      expect(find.byKey(const Key('m4-rc-result')), findsNothing);
      final TextField f = t.widget<TextField>(
        find.byKey(const Key('m4-rc-input')),
      );
      expect(f.autocorrect, isFalse);
      expect(f.enableSuggestions, isFalse);
      expect(f.enableIMEPersonalizedLearning, isFalse);
      expect(f.autofillHints, isNull);
      expect(r.sets, <bool>[true]);
      await t.pumpWidget(const SizedBox());
      await t.pump();
      expect(r.sets, <bool>[true, false]);
    },
  );

  testWidgets('🔴 누르면 칸을 곧바로 비운다 · 확인에 간 값 = 입력 그대로 · 결과 = 엔진 문장', (
    WidgetTester t,
  ) async {
    final _Rig r = _Rig()..answer = () async => FirstClaimOutcome.mismatch;
    await t.pumpWidget(r.widget());
    await t.enterText(find.byKey(const Key('m4-rc-input')), 'abcd-efgh');
    await t.tap(find.byKey(const Key('m4-rc-confirm')));
    await t.pump();
    await t.pump();
    expect(r.typed, <String>['abcd-efgh']);
    expect(
      t
          .widget<TextField>(find.byKey(const Key('m4-rc-input')))
          .controller!
          .text,
      isEmpty,
    );
    expect(
      t.widget<Text>(find.byKey(const Key('m4-rc-result'))).data,
      RecoveryCardTexts.mismatch,
    );
  });

  testWidgets('🔴 묻는 동안 잠금 · 오류 = «잠시 뒤» 문장(지어낸 성공 0)', (WidgetTester t) async {
    final Completer<FirstClaimOutcome> wait = Completer<FirstClaimOutcome>();
    final _Rig r = _Rig()..answer = () => wait.future;
    await t.pumpWidget(r.widget());
    await t.tap(find.byKey(const Key('m4-rc-confirm')));
    await t.pump();
    expect(_button(t, 'm4-rc-confirm').onPressed, isNull);
    wait.completeError(StateError('net'));
    await t.pump();
    await t.pump();
    expect(find.text(RecoveryCardTexts.retryLater), findsOneWidget);
    expect(_button(t, 'm4-rc-confirm').onPressed, isNotNull);
  });

  testWidgets('🔴 대기 = 입력 칸 없이 «등록 다시 시도» 하나 → retry', (WidgetTester t) async {
    final _Rig r = _Rig()..pending = true;
    await t.pumpWidget(r.widget());
    expect(find.byKey(const Key('m4-rc-input')), findsNothing);
    expect(find.text(RecoveryCardTexts.retryButton), findsOneWidget);
    await t.tap(find.byKey(const Key('m4-rc-retry')));
    await t.pump();
    await t.pump();
    expect(r.retries, 1);
    expect(r.typed, isEmpty);
    expect(find.text(RecoveryCardTexts.claimed), findsOneWidget);
  });
}
