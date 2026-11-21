// O-04 ⑤ 복구 카드 체크섬 칸(M4-10) — 슬롯 `RECOVERY_CHECKSUM` 에 조립 앱이 끼운다(E11k-e3 · 설계 13 §8 R229 F3 · 04 §9-5 ⑤ ·
// 06 M4-10 · M4-11 ① ⑤ · ③ 생체 칸 `biometric_sign_field.dart` 선례 — 계약 0줄).
//
// 🔴 체크섬 = 종이에 옮겨 적은 복구 코드를 종이를 보고 다시 입력 → 판정 = 첫 클레임 흐름(해시 대조 · 평문 비교 0 · 화면이 판정하지 않는다).
// 🔴 입력값 = 이 칸의 컨트롤러에만 · 누르면 곧바로 비운다(초안 · 저장 · 백업 · 로그 0) · 자동 완성 · 맞춤법 제안 · 키보드 학습 0.
// 🔴 이 칸이 서 있는 동안 캡처 막기(FLAG_SECURE · `SecureScope` — O-04 라우트 통째 막기와 겹쳐 센다).
// 🔴 종이 확인 뒤 서버 등록만 남았으면(대기) 입력 칸 없이 «등록 다시 시도» 하나 · 글자 = 엔진(`RecoveryCardTexts` · 결과 문장).

import 'package:core_engine/core_engine.dart'
    show FirstClaimOutcome, RecoveryCardTexts, firstClaimResultText;
import 'package:flutter/material.dart';

import '../app/secure_screen.dart' show SecureScope, SecureScreen;

/// ⑤ 복구 카드 체크섬 칸.
class RecoveryChecksumField extends StatefulWidget {
  /// 만든다 — [confirm] = 다시 입력한 코드 확인 · [retry] = 대기 행으로 다시 · [pending] = 지금 대기인가 · [secure] = 캡처 막기.
  const RecoveryChecksumField({
    super.key,
    required this.confirm,
    required this.retry,
    required this.pending,
    required this.secure,
  });

  /// 확인(결과 = 엔진 결과).
  final Future<FirstClaimOutcome> Function(String typed) confirm;

  /// 등록 다시 시도.
  final Future<FirstClaimOutcome> Function() retry;

  /// 종이 확인됨 · 등록 남음.
  final bool Function() pending;

  /// 캡처 막기.
  final SecureScreen secure;

  @override
  State<RecoveryChecksumField> createState() => _RecoveryChecksumFieldState();
}

class _RecoveryChecksumFieldState extends State<RecoveryChecksumField> {
  final TextEditingController _typed = TextEditingController();
  bool _busy = false;
  String? _result;

  @override
  void dispose() {
    _typed.clear();
    _typed.dispose();
    super.dispose();
  }

  Future<void> _run(Future<FirstClaimOutcome> Function() act) async {
    setState(() => _busy = true);
    FirstClaimOutcome o;
    try {
      o = await act();
    } on Object {
      o = FirstClaimOutcome.retryLater;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = firstClaimResultText(o);
    });
  }

  void _confirm() {
    // 🔴 누르자마자 칸을 비운다 — 값은 이 한 번의 확인에만.
    final String typed = _typed.text;
    _typed.clear();
    _run(() => widget.confirm(typed));
  }

  @override
  Widget build(BuildContext context) {
    final bool pending = widget.pending();
    final String? r = _result;
    return SecureScope(
      screen: widget.secure,
      child: Column(
        key: const Key('m4-rc'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (pending)
            FilledButton(
              key: const Key('m4-rc-retry'),
              onPressed: _busy ? null : () => _run(widget.retry),
              child: const Text(RecoveryCardTexts.retryButton),
            )
          else ...<Widget>[
            TextField(
              key: const Key('m4-rc-input'),
              controller: _typed,
              enabled: !_busy,
              autocorrect: false,
              enableSuggestions: false,
              enableIMEPersonalizedLearning: false,
              autofillHints: null,
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: RecoveryCardTexts.inputLabel,
                helperText: RecoveryCardTexts.inputGuide,
                helperMaxLines: 3,
              ),
              onSubmitted: (_) => _busy ? null : _confirm(),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('m4-rc-confirm'),
              onPressed: _busy ? null : _confirm,
              child: const Text(RecoveryCardTexts.confirmButton),
            ),
          ],
          if (r != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(r, key: const Key('m4-rc-result')),
            ),
        ],
      ),
    );
  }
}
