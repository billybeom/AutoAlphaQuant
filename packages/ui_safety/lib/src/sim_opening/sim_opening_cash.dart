// M5-14 가상 초기금 1칸(O-04 ⑥ 자동 매매 갈래 · 라우트 `AppRoutes.m5SimOpeningCash` · 06 M5-14 · 01 §25 K3 ·
// 01 §8 미결 154 · 설계 13 §8 R156).
//
// 🔴 기본값 없음 — 빈칸에서 시작한다(프리필 0 · 초안 저장 0).
// 🔴 화면 검증 0(01 §21-3 K4) — 빈칸 · 꼴 · 0 이하도 그대로 낸다. 거부는 명령 구현 · 엔진이 하고, 화면은 접수증
//    `stateLabel`(엔진 문장)을 그대로 보인다. 맥락(`CommandContext`) · 와이어를 짓지 않는다(G-19 · C-46 ⑳).
// 🔴 실행되면 칸 · 버튼을 잠근다(같은 화면에서 두 번 선언하지 않는다) — 돌아가기 = 셸 페이지 뒤로(마무리가 개시
//    결정을 다시 읽어 ⑥ «DRY_RUN 시작» 동작을 연다 · R127).
// 🔴 주입이 null 이면(기기 id 없음) 제출 버튼 부재(셸 알림 확인 선례).
// 🔴 operator 전용 — 배럴(`ui_safety.dart`) 밖 `sim_opening.dart` 로만 나간다(C-35 ⑥ · 뷰어 조립 import 0).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';

/// M5-14 명령 API 주입 — 조립 앱이 공급한다(operator 전용 · null = 제출 버튼 부재).
///
/// 🔴 주입 프로바이더: throw 기본값(규칙 10).
final Provider<CommandApi?> safetySimOpeningCommandApiProvider =
    Provider<CommandApi?>(
      (Ref ref) => throw UnimplementedError(
        'safetySimOpeningCommandApiProvider must be overridden',
      ),
    );

/// 끝난 상태인가(C-12 — 전부 받기 없이 값마다).
bool _terminal(CommandState s) => switch (s) {
  CommandState.executed ||
  CommandState.rejected ||
  CommandState.expired => true,
  CommandState.requested ||
  CommandState.received ||
  CommandState.staleContext ||
  CommandState.heldForIntegrity ||
  CommandState.pendingLeaseConfirm ||
  CommandState.noOperator => false,
};

/// M5-14 가상 초기금 화면 본문.
class SimOpeningCash extends ConsumerStatefulWidget {
  /// 만든다.
  const SimOpeningCash({super.key});

  @override
  ConsumerState<SimOpeningCash> createState() => _SimOpeningCashState();
}

class _SimOpeningCashState extends ConsumerState<SimOpeningCash> {
  final TextEditingController _cash = TextEditingController();
  StreamSubscription<CommandReceipt>? _follow;
  CommandReceipt? _receipt;
  bool _submitting = false;
  bool _notAccepted = false;

  bool get _waiting => _receipt != null && !_terminal(_receipt!.state);

  bool get _done => _receipt?.state == CommandState.executed;

  bool get _locked => _submitting || _waiting || _done;

  @override
  void dispose() {
    unawaited(_follow?.cancel());
    _cash.dispose();
    super.dispose();
  }

  void _apply(CommandReceipt r) {
    if (!mounted) return;
    setState(() => _receipt = r);
  }

  Future<void> _submit() async {
    final CommandApi? api = ref.read(safetySimOpeningCommandApiProvider);
    if (api == null) return;
    setState(() {
      _submitting = true;
      _notAccepted = false;
    });
    final CommandReceipt r;
    try {
      r = await api.submitSelfReportBalance(
        SelfReportSubmission(
          purpose: SelfReportPurpose.simOpening,
          input: SelfReportInput(cashKrwText: _cash.text),
          declaredComplete: true,
        ),
      );
    } on Object {
      if (mounted) {
        setState(() {
          _submitting = false;
          _notAccepted = true;
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _receipt = r;
    });
    if (!_terminal(r.state)) {
      await _follow?.cancel();
      _follow = api
          .watchCommand(r.commandId)
          .listen(
            _apply,
            onError: (Object _) {
              if (mounted) setState(() => _notAccepted = true);
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final CommandApi? api = ref.watch(safetySimOpeningCommandApiProvider);
    final CommandReceipt? r = _receipt;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ListView(
      key: const Key('m5-14'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            SafetyLabels.simOpeningCashTitle,
            key: const Key('m5-14-title'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(SafetyLabels.simOpeningCashNote, key: Key('m5-14-note')),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            key: const Key('m5-14-cash'),
            controller: _cash,
            enabled: !_locked,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: SafetyLabels.simOpeningCashField,
            ),
          ),
        ),
        if (r != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              r.stateLabel,
              key: const Key('m5-14-receipt'),
              style: r.state == CommandState.executed || !_terminal(r.state)
                  ? null
                  : TextStyle(color: scheme.error),
            ),
          ),
        if (_notAccepted)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              SafetyLabels.submitNotAccepted,
              key: const Key('m5-14-not-accepted'),
              style: TextStyle(color: scheme.error),
            ),
          ),
        if (api != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: FilledButton(
              key: const Key('m5-14-submit'),
              onPressed: _locked ? null : () => unawaited(_submit()),
              child: const Text(SafetyLabels.simOpeningCashSubmit),
            ),
          ),
      ],
    );
  }
}
