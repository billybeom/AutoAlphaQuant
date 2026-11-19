// O-04 ③ 생체 서명 칸 — 슬롯 `BIOMETRIC_SIGN` 에 조립 앱이 끼운다(E11p4j · 설계 13 §8 R159 · 06 M4-11 ① ·
// 플랫폼 몫 = 시크릿 칸 `KisKeySetField` 선례 · 계약 0줄).
//
// 🔴 버튼 하나 + 결과 한 줄 — 글자 = 엔진(`BiometricSignTexts` · 결과 문장) · 화면이 판정하지 않는다.
// 🔴 서명되면 마무리 읽기 모델이 ③ 을 확인됨으로 바꾸고 이 칸은 사라진다(슬롯 = 열린 단계만).
// 🔴 플랫폼 오류 = «생체 확인을 할 수 없어 진행하지 않았습니다.»(지어낸 성공 0 · 다시 누를 수 있다).

import 'package:core_engine/core_engine.dart'
    show BiometricOutcome, BiometricSignTexts, biometricSignResultText;
import 'package:flutter/material.dart';

/// ③ 생체 서명 칸.
class BiometricSignField extends StatefulWidget {
  /// 만든다 — [sign] = 서명 동작(결과 문장을 돌려준다).
  const BiometricSignField({super.key, required this.sign});

  /// 서명 동작.
  final Future<String> Function() sign;

  @override
  State<BiometricSignField> createState() => _BiometricSignFieldState();
}

class _BiometricSignFieldState extends State<BiometricSignField> {
  bool _busy = false;
  String? _result;

  Future<void> _tap() async {
    setState(() => _busy = true);
    String text;
    try {
      text = await widget.sign();
    } on Object {
      text = biometricSignResultText(BiometricOutcome.unavailable);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? r = _result;
    return Column(
      key: const Key('m5-bio'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FilledButton(
          key: const Key('m5-bio-sign'),
          onPressed: _busy ? null : _tap,
          child: const Text(BiometricSignTexts.button),
        ),
        if (r != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(r, key: const Key('m5-bio-result')),
          ),
      ],
    );
  }
}
