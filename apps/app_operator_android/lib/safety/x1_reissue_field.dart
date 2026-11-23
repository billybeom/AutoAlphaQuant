// X1-3 재발급 값 칸 — 슬롯 `SECRET_X1_REISSUE` 에 조립 앱이 끼운다(E16t3c · 설계 13 §8 R244 · 01 §42 K274 · 06 X1-3).
//
// 🔴 엔진은 남은 시크릿 항목 가운데 한 행에만 이 자리를 준다(같은 슬롯 이름 — 값이 어느 행 것인지 섞이지 않게) · 기록 버튼 = 그 행의
//    `recordAction`(화면 것) · 이 칸은 값만 쥔다(`SecretHandoff`) · 기록 동작이 지문(sha256 앞 8)만 남기고 칸을 비운다 · 값 저장 0.
// 🔴 자동 완성 · 맞춤법 제안 · 키보드 학습 0 · 캡처 막기(FLAG_SECURE).

import 'package:core_engine/core_engine.dart' show X1ScreenTexts;
import 'package:flutter/material.dart';

import '../app/secure_screen.dart' show SecureScope, SecureScreen;
import '../secret/secret_handoff.dart' show SecretHandoff, X1SecretDraftSource;

/// 재발급 값 칸.
class X1ReissueField extends StatefulWidget {
  /// 만든다.
  const X1ReissueField({
    super.key,
    required this.handoff,
    required this.secure,
  });

  /// 값 넘김.
  final SecretHandoff handoff;

  /// 캡처 막기.
  final SecureScreen secure;

  @override
  State<X1ReissueField> createState() => _X1ReissueFieldState();
}

class _X1ReissueFieldState extends State<X1ReissueField>
    implements X1SecretDraftSource {
  final TextEditingController _value = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.handoff.attachX1Reissue(this);
  }

  @override
  void dispose() {
    widget.handoff.detachX1Reissue(this);
    _value.clear();
    _value.dispose();
    super.dispose();
  }

  @override
  String? current() => _value.text.trim().isEmpty ? null : _value.text.trim();

  @override
  void clear() => _value.clear();

  @override
  Widget build(BuildContext context) => SecureScope(
    screen: widget.secure,
    child: TextField(
      key: const Key('x1-reissue-value'),
      controller: _value,
      obscureText: true,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      autofillHints: null,
      keyboardType: TextInputType.visiblePassword,
      decoration: const InputDecoration(
        labelText: X1ScreenTexts.reissueInputLabel,
        helperText: X1ScreenTexts.reissueInputGuide,
      ),
    ),
  );
}
