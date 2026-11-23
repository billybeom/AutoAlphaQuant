// X1-3 비상 복구 코드 칸 — 슬롯 `SECRET_X1_RECOVERY_CODE` 에 조립 앱이 끼운다(E16t3c · 설계 13 §8 R244 · 01 §42 K274 · K276 ·
// 06 X1-3 · O-04 ⑤ `recovery_checksum_field.dart` 선례 — 계약 0줄).
//
// 🔴 두 칸: ① 옛 종이의 복구 코드(평문 = 이 칸의 컨트롤러에만 · 시작 동작이 한 번 쓰고 비운다 — `SecretHandoff`) ② 새 복구 카드
//    (엔진이 낸 카드 줄 · 종이에 옮겨 적고 종이를 보고 다시 입력 → 해시 대조 · 누르면 곧바로 비운다).
// 🔴 «비상 복구 시작» 버튼은 화면(VM `startAction`)의 것 — 이 칸은 값만 쥔다. 새 카드 확인 전 시작 = 엔진 거부 글자.
// 🔴 자동 완성 · 맞춤법 제안 · 키보드 학습 0 · 이 칸이 서 있는 동안 캡처 막기(FLAG_SECURE · 비상 라우트 통째 막기와 겹쳐 센다).

import 'package:core_engine/core_engine.dart'
    show RecoveryCardTexts, X1ScreenTexts;
import 'package:flutter/material.dart';

import '../app/secure_screen.dart' show SecureScope, SecureScreen;
import '../secret/secret_handoff.dart' show SecretHandoff, X1SecretDraftSource;

/// 비상 복구 코드 칸.
class X1RecoveryCodeField extends StatefulWidget {
  /// 만든다 — [cardLines] = 새 카드 줄(엔진 · 이미 시작 = 빈 목록) · [confirmCard] = 새 카드 종이 확인 · [confirmed] = 확인했나 ·
  /// [handoff] = 옛 코드 넘김 · [secure] = 캡처 막기.
  const X1RecoveryCodeField({
    super.key,
    required this.cardLines,
    required this.confirmCard,
    required this.confirmed,
    required this.handoff,
    required this.secure,
  });

  /// 새 카드 줄.
  final List<String> Function() cardLines;

  /// 새 카드 확인(맞음 = true).
  final bool Function(String typed) confirmCard;

  /// 새 카드를 확인했나.
  final bool Function() confirmed;

  /// 옛 코드 넘김.
  final SecretHandoff handoff;

  /// 캡처 막기.
  final SecureScreen secure;

  @override
  State<X1RecoveryCodeField> createState() => _X1RecoveryCodeFieldState();
}

class _X1RecoveryCodeFieldState extends State<X1RecoveryCodeField>
    implements X1SecretDraftSource {
  final TextEditingController _old = TextEditingController();
  final TextEditingController _typed = TextEditingController();
  String? _result;

  @override
  void initState() {
    super.initState();
    widget.handoff.attachX1RecoveryCode(this);
  }

  @override
  void dispose() {
    widget.handoff.detachX1RecoveryCode(this);
    _old.clear();
    _typed.clear();
    _old.dispose();
    _typed.dispose();
    super.dispose();
  }

  @override
  String? current() => _old.text.isEmpty ? null : _old.text;

  @override
  void clear() => _old.clear();

  void _confirm() {
    // 🔴 누르자마자 칸을 비운다 — 값은 이 한 번의 확인에만.
    final String typed = _typed.text;
    _typed.clear();
    final bool ok = widget.confirmCard(typed);
    setState(
      () => _result = ok
          ? X1ScreenTexts.newCardConfirmed
          : RecoveryCardTexts.mismatch,
    );
  }

  static TextField _secretField(
    String key,
    TextEditingController c,
    String label, {
    String? helper,
    VoidCallback? onSubmitted,
  }) => TextField(
    key: Key(key),
    controller: c,
    autocorrect: false,
    enableSuggestions: false,
    enableIMEPersonalizedLearning: false,
    autofillHints: null,
    keyboardType: TextInputType.visiblePassword,
    textCapitalization: TextCapitalization.characters,
    decoration: InputDecoration(
      labelText: label,
      helperText: helper,
      helperMaxLines: 3,
    ),
    onSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
  );

  @override
  Widget build(BuildContext context) {
    final List<String> lines = widget.cardLines();
    final String? r = _result;
    return SecureScope(
      screen: widget.secure,
      child: Column(
        key: const Key('x1-rc'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _secretField(
            'x1-rc-old',
            _old,
            X1ScreenTexts.oldCodeLabel,
            helper: RecoveryCardTexts.inputGuide,
          ),
          if (lines.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(X1ScreenTexts.newCardHeadline, key: const Key('x1-rc-new')),
            for (int i = 0; i < lines.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(lines[i], key: Key('x1-rc-line-$i')),
              ),
            if (!widget.confirmed()) ...<Widget>[
              const SizedBox(height: 8),
              _secretField(
                'x1-rc-typed',
                _typed,
                X1ScreenTexts.newCardInputLabel,
                onSubmitted: _confirm,
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('x1-rc-confirm'),
                onPressed: _confirm,
                child: const Text(X1ScreenTexts.newCardConfirmButton),
              ),
            ],
          ],
          if (r != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(r, key: const Key('x1-rc-result')),
            ),
        ],
      ),
    );
  }
}
