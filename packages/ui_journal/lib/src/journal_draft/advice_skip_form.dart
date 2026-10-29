import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../advice_inbox.dart';
import '../common/journal_common.dart';
import '../timeline.dart';
import 'journal_draft_form.dart';

final _adviceSkipItemProvider = FutureProvider.family<AdviceItem?, String>(
  (Ref ref, String id) =>
      ref.watch(journalAdviceRepositoryProvider).findById(id),
);

final _adviceSkipSpecProvider = StreamProvider<ManualFillFormSpec>(
  (Ref ref) =>
      ref.watch(journalAdviceRepositoryProvider).watchManualFillFormSpec(),
);

const Widget _skipLoading = JournalSkeleton(key: Key('a4-loading'));

Widget _skipFail(VoidCallback onRetry, String? lastAsOf) => JournalErrorView(
  key: const Key('a4-fail'),
  lastAsOfLabel: lastAsOf,
  onRetry: onRetry,
);

/// A-4 미이행 사유 — 사유 버튼 한 번이 곧 제출이다. 입력란 0 · operator 전용.
///
/// [adviceId] 는 셸이 라우트에서 꺼내 넘긴다.
class AdviceSkipForm extends ConsumerStatefulWidget {
  const AdviceSkipForm({super.key, required this.adviceId});

  final String adviceId;

  @override
  ConsumerState<AdviceSkipForm> createState() => _AdviceSkipFormState();
}

class _AdviceSkipFormState extends ConsumerState<AdviceSkipForm> {
  late final DraftKey _draftKey = DraftKey(
    kind: DraftKind.adviceSkip,
    targetId: widget.adviceId,
  );
  CommandReceipt? _receipt;
  StreamSubscription<CommandReceipt>? _cmdSub;
  String? _commandId;
  bool _restoreDone = false;
  bool _awaitingReceipt = false;
  bool _resubscribeFailed = false;
  bool _submitting = false;
  bool _submitNotAccepted = false;
  bool _draftCleared = false;
  bool _issuedHere = false;

  @override
  void initState() {
    super.initState();
    unawaited(_restore());
  }

  @override
  void dispose() {
    _cmdSub?.cancel();
    super.dispose();
  }

  void _report(Object e, StackTrace st) => FlutterError.reportError(
    FlutterErrorDetails(exception: e, stack: st, library: 'ui_journal'),
  );

  /// 포트 호출 감싸기 — 동기 던짐도 onError 로 모은다.
  void _port(Future<void> Function(DraftStore s) call) => unawaited(
    Future<void>.sync(() => call(ref.read(journalDraftStoreProvider)))
        .then<void>((_) {}, onError: _report),
  );

  Future<void> _restore() async {
    DraftRecord? r;
    try {
      r = await ref.read(journalDraftStoreProvider).load(_draftKey);
    } catch (e, st) {
      _report(e, st);
    }
    if (!mounted) return;
    final String? id = r?.lastCommandId;
    setState(() {
      _commandId = id;
      _awaitingReceipt = id != null;
      _restoreDone = true;
    });
    if (id != null) {
      _subscribe(id);
    }
  }

  void _subscribe(String commandId) {
    unawaited(_cmdSub?.cancel() ?? Future<void>.value());
    _cmdSub = ref
        .read(journalCommandApiProvider)
        .watchCommand(commandId)
        .listen(
          _applyReceipt,
          onError: (Object e, StackTrace st) {
            _report(e, st);
            if (mounted && _awaitingReceipt) {
              setState(() => _resubscribeFailed = true);
            }
          },
          onDone: () {
            if (mounted && _awaitingReceipt) {
              setState(() => _resubscribeFailed = true);
            }
          },
        );
  }

  void _resubscribe() {
    final String? id = _commandId;
    if (id != null) {
      setState(() {
        _resubscribeFailed = false;
      });
      _subscribe(id);
    }
  }

  void _applyReceipt(CommandReceipt r) {
    if (!mounted) return;
    setState(() {
      _receipt = r;
      _awaitingReceipt = false;
      _resubscribeFailed = false;
    });
    if (r.state == CommandState.executed && !_draftCleared) {
      _draftCleared = true;
      _port((DraftStore s) => s.clear(_draftKey));
      _afterExecuted();
    }
  }

  void _afterExecuted() {
    if (_issuedHere) {
      ref.read(journalLinkOpenerProvider).open(AppNavActions.back);
    } else {
      unawaited(_cmdSub?.cancel() ?? Future<void>.value());
      setState(() {
        _receipt = null;
        _commandId = null;
        _draftCleared = false;
      });
    }
  }

  void _onReason(ReasonOption option) {
    final String? link = option.deepLink;
    if (link != null) {
      ref.read(journalLinkOpenerProvider).open(link);
    } else {
      unawaited(_submit(option.code));
    }
  }

  Future<void> _submit(String code) async {
    setState(() {
      _submitting = true;
      _submitNotAccepted = false;
    });
    final CommandReceipt initial;
    try {
      initial = await ref
          .read(journalCommandApiProvider)
          .skipAdvice(
            AdviceSkipSubmission(
              adviceId: widget.adviceId,
              input: AdviceSkipInput.fromReasonCode(code),
            ),
          );
    } catch (e, st) {
      _report(e, st);
      if (mounted) {
        setState(() {
          _submitting = false;
          _submitNotAccepted = true;
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _commandId = initial.commandId;
      _issuedHere = true;
    });
    _port(
      (DraftStore s) => s.save(
        DraftRecord(
          key: _draftKey,
          adviceSkip: AdviceSkipInput.fromReasonCode(code),
          lastCommandId: initial.commandId,
        ),
      ),
    );
    _applyReceipt(initial);
    _subscribe(initial.commandId);
  }

  bool _locked() {
    if (!_restoreDone || _awaitingReceipt || _submitting) return true;
    final CommandReceipt? r = _receipt;
    if (r == null) return false;
    return switch (r.state) {
      CommandState.requested ||
      CommandState.received ||
      CommandState.staleContext ||
      CommandState.heldForIntegrity ||
      CommandState.pendingLeaseConfirm ||
      CommandState.noOperator ||
      CommandState.executed => true,
      CommandState.rejected || CommandState.expired => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final Clock clock = ref.watch(journalClockProvider);
    final SafetyState? safety = ref
        .watch(journalSafetyStateProvider)
        .valueOrNull;
    final AsyncValue<AdviceItem?> item = ref.watch(
      _adviceSkipItemProvider(widget.adviceId),
    );
    final AsyncValue<ManualFillFormSpec> spec = ref.watch(
      _adviceSkipSpecProvider,
    );
    if (!_restoreDone) return _skipLoading;
    return item.when(
      loading: () => _skipLoading,
      error: (Object e, StackTrace s) => _skipFail(
        () => ref.invalidate(_adviceSkipItemProvider(widget.adviceId)),
        null,
      ),
      data: (AdviceItem? v) {
        if (v == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(JournalLabels.adviceNotFound, key: Key('a4-absent')),
          );
        }
        return spec.when(
          loading: () => _skipLoading,
          error: (Object e, StackTrace s) => _skipFail(
            () => ref.invalidate(_adviceSkipSpecProvider),
            spec.valueOrNull?.asOf.label,
          ),
          data: (ManualFillFormSpec sp) =>
              _buildBody(context, v, sp, clock, safety),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AdviceItem item,
    ManualFillFormSpec spec,
    Clock clock,
    SafetyState? safety,
  ) {
    final bool stale = spec.asOf.observedAt
        .add(spec.asOf.staleAfter)
        .isBefore(clock.nowUtc());
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        JournalAsOfHeader(key: const Key('a4-asof'), asOf: spec.asOf),
        if (stale) JournalStaleBanner(asOf: spec.asOf),
        JournalSafetyBanners(safety: safety),
        if (!stale) ..._formRows(context, item, spec),
      ],
    );
  }

  List<Widget> _formRows(
    BuildContext context,
    AdviceItem item,
    ManualFillFormSpec spec,
  ) {
    final String? banner = spec.bannerText;
    final String? blocked = spec.blockedText;
    final CommandReceipt? receipt = _receipt;
    final bool locked = _locked();
    return <Widget>[
      if (banner != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(banner, key: const Key('a4-banner')),
        ),
      _SkipReferenceCard(key: const Key('a4-ref'), item: item),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(spec.skipNoticeText, key: const Key('a4-notice')),
      ),
      if (blocked != null)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(blocked, key: const Key('a4-blocked')),
        )
      else ...<Widget>[
        for (final (int i, ReasonOption o) in spec.skipReasons.indexed)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                key: ValueKey<String>('a4-reason-$i'),
                onPressed: locked
                    ? null
                    : () {
                        _onReason(o);
                      },
                child: Text(o.label),
              ),
            ),
          ),
      ],
      if (receipt != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(receipt.stateLabel, key: const Key('a4-receipt')),
        ),
      if (_submitNotAccepted)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            JournalLabels.submitNotAccepted,
            key: const Key('a4-submit-not-accepted'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      if (_resubscribeFailed)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextButton(
            key: const Key('a4-resubscribe'),
            onPressed: _resubscribe,
            child: const Text(JournalLabels.retry),
          ),
        ),
    ];
  }
}

class _SkipReferenceCard extends StatelessWidget {
  const _SkipReferenceCard({super.key, required this.item});

  final AdviceItem item;

  @override
  Widget build(BuildContext context) {
    final String? symbol = item.symbolLabel;
    final String? side = item.sideLabel;
    final AdvicePriceBand? band = item.priceBand;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (symbol != null) Text(symbol),
            if (side != null) Text(side),
            Text(item.sizingLabel),
            if (band != null) Text(band.label),
            Text(item.validityLabel),
            Text(item.progressLabel),
          ],
        ),
      ),
    );
  }
}
