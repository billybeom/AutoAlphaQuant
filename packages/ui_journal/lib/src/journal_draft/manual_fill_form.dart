import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../advice_inbox.dart';
import '../common/journal_common.dart';
import '../timeline.dart';
import 'journal_draft_form.dart';

final _manualFillItemProvider = FutureProvider.family<AdviceItem?, String>(
  (Ref ref, String id) =>
      ref.watch(journalAdviceRepositoryProvider).findById(id),
);

final _manualFillSpecProvider = StreamProvider<ManualFillFormSpec>(
  (Ref ref) =>
      ref.watch(journalAdviceRepositoryProvider).watchManualFillFormSpec(),
);

const Widget _fillLoading = JournalSkeleton(key: Key('a3-loading'));

Widget _fillFail(VoidCallback onRetry, String? lastAsOf) => JournalErrorView(
  key: const Key('a3-fail'),
  lastAsOfLabel: lastAsOf,
  onRetry: onRetry,
);

/// A-3 수기 체결 기록 폼 — operator 전용.
class ManualFillForm extends ConsumerStatefulWidget {
  const ManualFillForm({super.key, required this.adviceId});

  final String adviceId;

  @override
  ConsumerState<ManualFillForm> createState() => _ManualFillFormState();
}

class _ManualFillFormState extends ConsumerState<ManualFillForm> {
  late final DraftKey _draftKey = DraftKey(
    kind: DraftKind.manualFillRecord,
    targetId: widget.adviceId,
  );
  final TextEditingController _quantityCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _commissionCtrl = TextEditingController();
  final TextEditingController _taxCtrl = TextEditingController();

  TradeDate? _tradeDate;
  String? _symbol;
  OrderSide? _side;
  String? _account;
  bool _prefilledQuantity = false;
  List<String> _retryCodes = <String>[];

  CommandReceipt? _receipt;
  StreamSubscription<CommandReceipt>? _cmdSub;
  String? _commandId;
  bool _restoreDone = false;
  bool _applyingRestore = false;
  bool _awaitingReceipt = false;
  bool _resubscribeFailed = false;
  bool _submitting = false;
  bool _submitNotAccepted = false;
  bool _draftCleared = false;
  bool _issuedHere = false;
  DraftRecord? _lastPersisted;

  @override
  void initState() {
    super.initState();
    _quantityCtrl.addListener(_onInputChanged);
    _priceCtrl.addListener(_onInputChanged);
    _commissionCtrl.addListener(_onInputChanged);
    _taxCtrl.addListener(_onInputChanged);
    unawaited(_restore());
  }

  @override
  void dispose() {
    _cmdSub?.cancel();
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _commissionCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {});
    _persist();
  }

  void _report(Object e, StackTrace st) => FlutterError.reportError(
    FlutterErrorDetails(exception: e, stack: st, library: 'ui_journal'),
  );

  void _port(Future<void> Function(DraftStore s) call) => unawaited(
    Future<void>.sync(() => call(ref.read(journalDraftStoreProvider)))
        .then<void>((_) {}, onError: _report),
  );

  ManualFillInput _input() => ManualFillInput(
    tradeDate: _tradeDate,
    symbol: _symbol,
    side: _side,
    quantityText: _quantityCtrl.text,
    priceText: _priceCtrl.text,
    commissionText: _commissionCtrl.text,
    taxText: _taxCtrl.text,
    accountAlias: _account,
    prefilledFields: <String>[
      if (_prefilledQuantity) ManualFillPrefillFields.quantity,
    ],
  );

  void _persist() {
    if (!_restoreDone || _applyingRestore) return;
    final DraftRecord record = DraftRecord(
      key: _draftKey,
      manualFill: _input(),
      lastCommandId: _commandId,
    );
    if (record == _lastPersisted) return;
    _lastPersisted = record;
    _port((DraftStore s) => s.save(record));
  }

  Future<void> _restore() async {
    DraftRecord? r;
    try {
      r = await ref.read(journalDraftStoreProvider).load(_draftKey);
    } catch (e, st) {
      _report(e, st);
    }
    if (!mounted) return;
    final ManualFillInput? m = r?.manualFill;
    if (m != null) {
      _applyingRestore = true;
      _quantityCtrl.text = m.quantityText;
      _priceCtrl.text = m.priceText;
      _commissionCtrl.text = m.commissionText;
      _taxCtrl.text = m.taxText;
      _tradeDate = m.tradeDate;
      _symbol = m.symbol;
      _side = m.side;
      _account = m.accountAlias;
      _prefilledQuantity = m.prefilledFields.contains(
        ManualFillPrefillFields.quantity,
      );
      _applyingRestore = false;
    }
    _lastPersisted =
        r ?? DraftRecord(key: _draftKey, manualFill: const ManualFillInput());
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

  void _onPrefill(String text) {
    setState(() {
      _prefilledQuantity = true;
    });
    _quantityCtrl.text = text;
  }

  String? _known(String? v, List<String> values) {
    for (final String x in values) {
      if (x == v) {
        return v;
      }
    }
    return null;
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
        _applyingRestore = true;
        _quantityCtrl.text = '';
        _priceCtrl.text = '';
        _commissionCtrl.text = '';
        _taxCtrl.text = '';
        _tradeDate = null;
        _symbol = null;
        _side = null;
        _account = null;
        _prefilledQuantity = false;
        _retryCodes = <String>[];
        _applyingRestore = false;
        _lastPersisted = DraftRecord(
          key: _draftKey,
          manualFill: const ManualFillInput(),
        );
        _receipt = null;
        _commandId = null;
        _draftCleared = false;
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _submitNotAccepted = false;
    });
    final CommandReceipt initial;
    try {
      initial = await ref
          .read(journalCommandApiProvider)
          .recordManualFill(
            ManualFillSubmission(
              adviceId: widget.adviceId,
              input: _input(),
              retryCodes: _retryCodes,
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
    _persist();
    _applyReceipt(initial);
    _subscribe(initial.commandId);
  }

  void _retry(String? code) {
    if (code != null) {
      _retryCodes = <String>[..._retryCodes, code];
    }
    unawaited(_submit());
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
      _manualFillItemProvider(widget.adviceId),
    );
    final AsyncValue<ManualFillFormSpec> spec = ref.watch(
      _manualFillSpecProvider,
    );
    if (!_restoreDone) return _fillLoading;
    return item.when(
      loading: () => _fillLoading,
      error: (Object e, StackTrace s) => _fillFail(
        () => ref.invalidate(_manualFillItemProvider(widget.adviceId)),
        null,
      ),
      data: (AdviceItem? v) {
        if (v == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(JournalLabels.adviceNotFound, key: Key('a3-absent')),
          );
        }
        return spec.when(
          loading: () => _fillLoading,
          error: (Object e, StackTrace s) => _fillFail(
            () => ref.invalidate(_manualFillSpecProvider),
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
        JournalAsOfHeader(key: const Key('a3-asof'), asOf: spec.asOf),
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
    final bool locked = _locked();
    final String? blocked = spec.blockedText;
    final String? banner = spec.bannerText;
    final String? prefillLabel = item.prefillQuantityLabel;
    final String? prefillText = item.prefillQuantityText;
    final CommandReceipt? receipt = _receipt;
    final String? retryLabel = receipt?.retryLabel;
    final String? retryCode = receipt?.retryCode;

    return <Widget>[
      if (banner != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(banner, key: const Key('a3-banner')),
        ),
      _FillReferenceCard(key: const Key('a3-ref'), item: item),
      if (prefillLabel != null && prefillText != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: OutlinedButton(
            key: const Key('a3-prefill'),
            onPressed: locked
                ? null
                : () {
                    _onPrefill(prefillText);
                  },
            child: Text(prefillLabel),
          ),
        ),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(JournalLabels.manualFillTradeDate),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: <Widget>[
            for (final (int i, TradeDateOption o)
                in spec.tradeDateOptions.indexed)
              ChoiceChip(
                key: ValueKey<String>('a3-date-$i'),
                label: Text(o.label),
                selected: _tradeDate == o.date,
                onSelected: locked
                    ? null
                    : (bool _) {
                        setState(() {
                          _tradeDate = o.date;
                        });
                        _persist();
                      },
              ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: DropdownButton<String>(
          key: const Key('a3-symbol'),
          isExpanded: true,
          hint: const Text(JournalLabels.manualFillSymbol),
          value: _known(
            _symbol,
            <String>[for (final SymbolOption s in spec.symbols) s.symbol],
          ),
          items: <DropdownMenuItem<String>>[
            for (final SymbolOption s in spec.symbols)
              DropdownMenuItem<String>(value: s.symbol, child: Text(s.label)),
          ],
          onChanged: locked
              ? null
              : (String? v) {
                  setState(() {
                    _symbol = v;
                  });
                  _persist();
                },
        ),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(JournalLabels.manualFillSide),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: <Widget>[
            for (final (int i, SideOption o) in spec.sides.indexed)
              ChoiceChip(
                key: ValueKey<String>('a3-side-$i'),
                label: Text(o.label),
                selected: _side == o.side,
                onSelected: locked
                    ? null
                    : (bool _) {
                        setState(() {
                          _side = o.side;
                        });
                        _persist();
                      },
              ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: TextField(
          key: const Key('a3-quantity'),
          controller: _quantityCtrl,
          enabled: !locked,
          decoration: const InputDecoration(
            labelText: JournalLabels.manualFillQuantity,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: TextField(
          key: const Key('a3-price'),
          controller: _priceCtrl,
          enabled: !locked,
          decoration: InputDecoration(
            labelText: JournalLabels.manualFillPrice,
            helperText: spec.priceHintLabel,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: TextField(
          key: const Key('a3-commission'),
          controller: _commissionCtrl,
          enabled: !locked,
          decoration: const InputDecoration(
            labelText: JournalLabels.commission,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: TextField(
          key: const Key('a3-tax'),
          controller: _taxCtrl,
          enabled: !locked,
          decoration: const InputDecoration(labelText: JournalLabels.tax),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: DropdownButton<String>(
          key: const Key('a3-account'),
          isExpanded: true,
          hint: const Text(JournalLabels.manualFillAccount),
          value: _known(
            _account,
            <String>[for (final AccountOption a in spec.accounts) a.alias],
          ),
          items: <DropdownMenuItem<String>>[
            for (final AccountOption a in spec.accounts)
              DropdownMenuItem<String>(value: a.alias, child: Text(a.label)),
          ],
          onChanged: locked
              ? null
              : (String? v) {
                  setState(() {
                    _account = v;
                  });
                  _persist();
                },
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(spec.appendOnlyNotice, key: const Key('a3-append-notice')),
      ),
      if (receipt != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(receipt.stateLabel, key: const Key('a3-receipt')),
        ),
      if (retryLabel != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: OutlinedButton(
            key: const Key('a3-retry'),
            onPressed: locked
                ? null
                : () {
                    _retry(retryCode);
                  },
            child: Text(retryLabel),
          ),
        ),
      if (_submitNotAccepted)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            JournalLabels.submitNotAccepted,
            key: const Key('a3-submit-not-accepted'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      if (_resubscribeFailed)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextButton(
            key: const Key('a3-resubscribe'),
            onPressed: _resubscribe,
            child: const Text(JournalLabels.retry),
          ),
        ),
      if (blocked == null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            key: const Key('a3-submit'),
            onPressed: locked
                ? null
                : () {
                    unawaited(_submit());
                  },
            child: const Text(JournalLabels.draftSubmit),
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(blocked, key: const Key('a3-blocked')),
        ),
    ];
  }
}

class _FillReferenceCard extends StatelessWidget {
  const _FillReferenceCard({super.key, required this.item});

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
