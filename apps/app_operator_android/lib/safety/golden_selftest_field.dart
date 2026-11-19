// O-04 ④ 골든벡터 셀프테스트 칸 — 슬롯 `SELFTEST_RUN` 에 조립 앱이 끼운다(E11o-d · 설계 13 §8 R167 · R161 O8 · 미결 201 ·
// ③ 생체 서명 칸 · 시크릿 칸 선례 · 계약 0줄).
//
// 🔴 S10 골든 카드 `selftestGoldenRun{}` 과 같은 실행기(엔진 `kDeviceGoldenSuite` · 백그라운드) — 기록 = 온보딩 sim 파일.
// 🔴 버튼 하나 + 결과 한 줄 — 글자 = 엔진(`GoldenSelfTestTexts` · 결과 문장) · 화면이 판정하지 않는다.
// 🔴 전량 통과면 마무리 읽기 모델이 ④ 를 확인됨으로 바꾸고 이 칸은 사라진다(슬롯 = 열린 단계만).
// 🔴 실행 실패 = «골든벡터를 돌리지 못했습니다»(지어낸 성공 0 · 다시 누를 수 있다).

import 'package:core_engine/core_engine.dart' show GoldenSelfTestTexts;
import 'package:flutter/material.dart';

/// ④ 골든벡터 셀프테스트 칸.
class GoldenSelfTestField extends StatefulWidget {
  /// 만든다 — [run] = 실행(결과 문장을 돌려준다).
  const GoldenSelfTestField({super.key, required this.run});

  /// 실행.
  final Future<String> Function() run;

  @override
  State<GoldenSelfTestField> createState() => _GoldenSelfTestFieldState();
}

class _GoldenSelfTestFieldState extends State<GoldenSelfTestField> {
  bool _busy = false;
  String? _result;

  Future<void> _tap() async {
    setState(() => _busy = true);
    String text;
    try {
      text = await widget.run();
    } on Object {
      text = GoldenSelfTestTexts.runFailed;
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
      key: const Key('m4-golden'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FilledButton(
          key: const Key('m4-golden-run'),
          onPressed: _busy ? null : _tap,
          child: Text(
            _busy ? GoldenSelfTestTexts.running : GoldenSelfTestTexts.runLabel,
          ),
        ),
        if (r != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(r, key: const Key('m4-golden-result')),
          ),
      ],
    );
  }
}
