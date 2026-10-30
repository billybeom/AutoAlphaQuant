// lib/src/alerts/alert_ack.dart
//
// AlertAckBlock — 확인 버튼 + 접수증 글자 + 실패 글자.
// 배럴 export 0 — 두 화면이 상대 경로로 import.

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../shell_providers.dart';

/// 확인 버튼 + 접수증 글자 조각.
///
/// [ack] 가 null 이면 SizedBox.shrink().
/// 주입 [shellAlertCommandApiProvider] 가 null 이면 버튼 부재(뷰어).
class AlertAckBlock extends ConsumerStatefulWidget {
  const AlertAckBlock({
    super.key,
    required this.keyBase,
    required this.alertId,
    required this.ack,
  });

  final String keyBase;
  final String alertId;
  final AckState? ack;

  @override
  ConsumerState<AlertAckBlock> createState() => _AlertAckBlockState();
}

class _AlertAckBlockState extends ConsumerState<AlertAckBlock> {
  bool _busy = false;
  bool _failed = false;
  String? _label;

  @override
  void didUpdateWidget(AlertAckBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alertId != widget.alertId) {
      _busy = false;
      _failed = false;
      _label = null;
    }
  }

  Future<void> _ack(CommandApi api) async {
    final String id = widget.alertId;
    setState(() => _busy = true);
    try {
      final CommandReceipt r = await api.acknowledgeAlert(id);
      if (!mounted || widget.alertId != id) return;
      setState(() {
        _busy = false;
        _failed = false;
        _label = r.stateLabel;
      });
    } catch (_) {
      if (!mounted || widget.alertId != id) return;
      setState(() {
        _busy = false;
        _failed = true;
        _label = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AckState? a = widget.ack;
    if (a == null) return const SizedBox.shrink();
    final CommandApi? api = ref.watch(shellAlertCommandApiProvider);
    final String base = widget.keyBase;
    final String? label = _label;
    return Padding(
      padding: const EdgeInsets.fromLTRB(44, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(a.stateLabel, key: ValueKey<String>('$base-state')),
          if (!a.acked && api != null)
            FilledButton(
              key: ValueKey<String>('$base-ack'),
              onPressed: _busy ? null : () { unawaited(_ack(api)); },
              child: const Text(ShellLabels.alertsAck),
            ),
          if (label != null) Text(label, key: ValueKey<String>('$base-receipt')),
          if (_failed)
            Text(
              ShellLabels.alertsAckNotAccepted,
              key: ValueKey<String>('$base-ack-fail'),
            ),
        ],
      ),
    );
  }
}
