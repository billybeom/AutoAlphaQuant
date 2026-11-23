// 🆕 E16t3c(설계 13 §8 R244) — X1-3 비상 슬롯 칸 둘: 복구 코드(`SECRET_X1_RECOVERY_CODE`) · 재발급 값(`SECRET_X1_REISSUE`).
//
// 🔵 잡는 것: ① 옛 코드 칸 = 넘김에 붙는다 · 값 = 칸에만 · 비우기 · 내려가면 떨어진다 ② 새 카드 줄 = 엔진 · 확인 = 입력 그대로 대조 ·
//    누르면 곧바로 비운다 · 결과 = 엔진 글자 · 확인 뒤 확인 칸 0 · 카드 없음(이미 시작) = 새 카드 칸 0 ③ 재발급 칸 = 값 = 칸에만(앞뒤 공백 뺌) ·
//    가림 ④ 자동 완성 · 제안 · 키보드 학습 0 ⑤ 서 있는 동안 캡처 막기(켬 → 끔).

import 'package:app_operator_android/app/secure_screen.dart';
import 'package:app_operator_android/safety/x1_recovery_code_field.dart';
import 'package:app_operator_android/safety/x1_reissue_field.dart';
import 'package:app_operator_android/secret/secret_handoff.dart';
import 'package:core_engine/core_engine.dart'
    show RecoveryCardTexts, X1ScreenTexts;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const String _code = 'ABCD-EFGH-JKLM-NPQR-STUV';

void _noLearning(TextField f) {
  expect(f.autocorrect, isFalse);
  expect(f.enableSuggestions, isFalse);
  expect(f.enableIMEPersonalizedLearning, isFalse);
  expect(f.autofillHints, isNull);
}

void main() {
  testWidgets(
    '🔴 복구 코드 칸 — 옛 코드 = 넘김 · 새 카드 줄 · 확인 = 대조 · 곧바로 비움 · 결과 글자 · 캡처 막기',
    (WidgetTester t) async {
      final List<bool> sets = <bool>[];
      final SecretHandoff h = SecretHandoff();
      final List<String> typed = <String>[];
      bool confirmed = false;
      List<String> lines = <String>['복구 코드: $_code', '종이에만 적으십시오'];
      final SecureScreen screen = SecureScreen((bool on) async => sets.add(on));
      Widget field() => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: X1RecoveryCodeField(
              cardLines: () => lines,
              confirmCard: (String s) {
                typed.add(s);
                confirmed = s == _code;
                return confirmed;
              },
              confirmed: () => confirmed,
              handoff: h,
              secure: screen,
            ),
          ),
        ),
      );
      await t.pumpWidget(field());
      await t.pump();
      expect(sets, <bool>[true]);
      expect(find.text(X1ScreenTexts.oldCodeLabel), findsOneWidget);
      expect(find.text(X1ScreenTexts.newCardHeadline), findsOneWidget);
      expect(find.text('복구 코드: $_code'), findsOneWidget);
      for (final String k in <String>['x1-rc-old', 'x1-rc-typed']) {
        _noLearning(t.widget<TextField>(find.byKey(Key(k))));
      }
      // 옛 코드 = 칸에만 · 넘김이 읽는다 · 비우기.
      expect(h.x1RecoveryCodeDraft(), isNull);
      await t.enterText(find.byKey(const Key('x1-rc-old')), 'OLD1-OLD2');
      expect(h.x1RecoveryCodeDraft(), 'OLD1-OLD2');
      h.clearX1RecoveryCode();
      expect(h.x1RecoveryCodeDraft(), isNull);
      // 틀린 확인 = 엔진 글자 · 칸 비움.
      await t.enterText(find.byKey(const Key('x1-rc-typed')), 'WRONG');
      await t.tap(find.byKey(const Key('x1-rc-confirm')));
      await t.pump();
      expect(typed, <String>['WRONG']);
      expect(find.text(RecoveryCardTexts.mismatch), findsOneWidget);
      expect(
        t
            .widget<TextField>(find.byKey(const Key('x1-rc-typed')))
            .controller!
            .text,
        isEmpty,
      );
      // 맞는 확인 = 확인됨 글자 · 확인 칸 사라짐.
      await t.enterText(find.byKey(const Key('x1-rc-typed')), _code);
      await t.tap(find.byKey(const Key('x1-rc-confirm')));
      await t.pump();
      expect(find.text(X1ScreenTexts.newCardConfirmed), findsOneWidget);
      expect(find.byKey(const Key('x1-rc-typed')), findsNothing);
      // 이미 시작(카드 없음) = 새 카드 칸 0.
      lines = const <String>[];
      await t.pumpWidget(field());
      expect(find.text(X1ScreenTexts.newCardHeadline), findsNothing);
      await t.pumpWidget(const SizedBox());
      await t.pump();
      expect(sets.last, isFalse);
      expect(h.x1RecoveryCodeDraft(), isNull);
    },
  );

  testWidgets('🔴 재발급 칸 — 값 = 칸에만(공백 뺌) · 가림 · 학습 0 · 내려가면 떨어짐 · 캡처 막기', (
    WidgetTester t,
  ) async {
    final List<bool> sets = <bool>[];
    final SecretHandoff h = SecretHandoff();
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: X1ReissueField(
            handoff: h,
            secure: SecureScreen((bool on) async => sets.add(on)),
          ),
        ),
      ),
    );
    await t.pump();
    expect(sets, <bool>[true]);
    expect(find.text(X1ScreenTexts.reissueInputLabel), findsOneWidget);
    final TextField f = t.widget<TextField>(
      find.byKey(const Key('x1-reissue-value')),
    );
    expect(f.obscureText, isTrue);
    _noLearning(f);
    expect(h.x1ReissueDraft(), isNull);
    await t.enterText(find.byKey(const Key('x1-reissue-value')), '  new-key  ');
    expect(h.x1ReissueDraft(), 'new-key');
    h.clearX1Reissue();
    expect(h.x1ReissueDraft(), isNull);
    await t.enterText(find.byKey(const Key('x1-reissue-value')), 'v2');
    await t.pumpWidget(const SizedBox());
    await t.pump();
    expect(sets.last, isFalse);
    expect(h.x1ReissueDraft(), isNull);
  });
}
