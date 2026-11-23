// R-01 로그인 자리(슬롯 `RECOVERY_LOGIN` · 설계 13 §8 R248 · 04 §9-6 ① · 계약 v1.29 T8 «이메일 + 비밀번호»).
//
// 🔴 새 폰은 금고가 비어 있다 → 연결(o_07 ② 주소 · 공개 키) 먼저 · 연결 뒤 로그인(③ 이메일 · 비밀번호).
// 🔴 지점 · 안내 · 버튼 글자 · 칸 이름 · 동작 = 엔진 `supabaseSignInStageOf`(o_07 상세와 한 원천) — 이 칸은 문장을 짓지 않는다.
// 🔴 칸 = 같은 슬롯 빌더(`SupabaseConnectField` · `SupabaseLoginPanel` — 붙여넣기만 · 클립보드 정리 · 캡처 막기 = 칸이 스스로).
// 🔴 제출 = `SettingsActions.run`(엔진이 완성한 id · 인자 그대로) · 결과 글자 = 동작 결과 · 끝나면 R-01 다시 읽기([onSettled]).
// 🔴 지점 사실 = 금고 연결 칸 유무([connected] · 망 0) — 모르는 동안 = 칸 0(기다림 표시만).

import 'package:core_engine/core_engine.dart'
    show SupabaseSignInStage, supabaseSignInStageOf;
import 'package:domain_contracts/domain_contracts.dart'
    show ActionResult, OnboardingAction;
import 'package:flutter/material.dart';

/// R-01 로그인 자리.
class RestartLoginSlot extends StatefulWidget {
  /// 만든다.
  const RestartLoginSlot({
    super.key,
    required this.connected,
    required this.field,
    required this.run,
    required this.onSettled,
  });

  /// 금고에 연결 칸이 있나(망 0).
  final Future<bool> Function() connected;

  /// 칸 이름 → 칸(조립 앱 슬롯 빌더).
  final Widget Function(String slotId) field;

  /// 동작 실행(null = 동작 없음 → 버튼 부재).
  final Future<ActionResult> Function(OnboardingAction action)? run;

  /// 동작이 끝났다(R-01 다시 읽기).
  final VoidCallback onSettled;

  @override
  State<RestartLoginSlot> createState() => _RestartLoginSlotState();
}

class _RestartLoginSlotState extends State<RestartLoginSlot> {
  bool? _connected;
  ActionResult? _result;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    bool on;
    try {
      on = await widget.connected();
    } on Object {
      on = false;
    }
    if (mounted) setState(() => _connected = on);
  }

  Future<void> _submit(SupabaseSignInStage stage) async {
    final Future<ActionResult> Function(OnboardingAction)? run = widget.run;
    if (run == null || _busy) return;
    setState(() => _busy = true);
    ActionResult? r;
    try {
      r = await run(stage.submit);
    } on Object {
      r = null;
    }
    bool? on = _connected;
    try {
      on = await widget.connected();
    } on Object {
      // 그대로.
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = r;
      _connected = on;
    });
    widget.onSettled();
  }

  @override
  Widget build(BuildContext context) {
    final bool? on = _connected;
    if (on == null) {
      return const Padding(
        key: Key('r01-login-wait'),
        padding: EdgeInsets.all(8),
        child: LinearProgressIndicator(),
      );
    }
    final SupabaseSignInStage stage = supabaseSignInStageOf(connected: on);
    final ActionResult? r = _result;
    return Column(
      key: ValueKey<String>('r01-login-${stage.slotId}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(stage.whereText, key: const Key('r01-login-where')),
        const SizedBox(height: 8),
        KeyedSubtree(
          key: ValueKey<String>('r01-login-field-${stage.slotId}'),
          child: widget.field(stage.slotId),
        ),
        const SizedBox(height: 8),
        if (widget.run != null)
          FilledButton(
            key: const Key('r01-login-submit'),
            onPressed: _busy ? null : () => _submit(stage),
            child: Text(stage.submit.label),
          ),
        if (r != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(r.headline, key: const Key('r01-login-result')),
          ),
      ],
    );
  }
}
