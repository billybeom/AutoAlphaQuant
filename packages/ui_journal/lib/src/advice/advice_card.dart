import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/journal_common.dart';
import '../timeline.dart';

/// 안내 1건 카드 — 받은 글자와 null 여부만 그린다. 구독·명령 0.
///
/// 지난 안내 행과 A-1 행이 재사용한다.
class AdviceCard extends ConsumerWidget {
  const AdviceCard({super.key, required this.item});

  final AdviceItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? suppressed = item.suppressedLabel;
    final String? confirm = item.expiredConfirmLabel;
    final String? symbol = item.symbolLabel;
    final String? side = item.sideLabel;
    final String? phoneOnly = item.phoneOnlyLabel;
    final AdvicePriceBand? band = item.priceBand;
    final String? hold = item.holdReasonLabel;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (suppressed != null) ...<Widget>[
              Text(suppressed),
              Text(item.validityLabel),
              _reasonChips(),
            ] else ...<Widget>[
              if (confirm != null) Text(confirm),
              Row(
                children: <Widget>[
                  if (symbol != null) Expanded(child: Text(symbol)),
                  if (side != null) Text(side),
                ],
              ),
              if (phoneOnly != null) Text(phoneOnly),
              Text(item.sizingLabel),
              if (band != null) Text(band.label),
              Text(item.validityLabel),
              Text(item.progressLabel),
              Row(
                children: <Widget>[
                  if (item.isUrgent) const Icon(Icons.priority_high, size: 20),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Chip(
                      label: Text(item.statusLabel),
                      backgroundColor: journalToneColor(
                        context,
                        item.statusTone,
                      ),
                    ),
                  ),
                ],
              ),
              if (hold != null) Text(hold),
              _reasonChips(),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: <Widget>[
                for (final AdviceAction a in item.actions)
                  _AdviceActionButton(action: a),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _reasonChips() => Wrap(
    spacing: 6,
    runSpacing: 4,
    children: <Widget>[
      for (final ReasonChip c in item.reasons) JournalReasonChip(chip: c),
    ],
  );
}

class _AdviceActionButton extends ConsumerWidget {
  const _AdviceActionButton({required this.action});

  final AdviceAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? reason = action.disabledReasonLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OutlinedButton(
          onPressed: action.enabled
              ? () {
                  ref.read(journalLinkOpenerProvider).open(action.deepLink);
                }
              : null,
          child: Text(action.label),
        ),
        if (reason != null) Text(reason),
      ],
    );
  }
}
