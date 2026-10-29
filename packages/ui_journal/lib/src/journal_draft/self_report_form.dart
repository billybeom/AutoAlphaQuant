import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/journal_common.dart';
import '../ledger_diffs.dart';
import '../timeline.dart';
import 'journal_draft_form.dart';

/// L-3 실사 세션 여닫기 — operator 앱이 override 한다(01 §21-4 · K9 · K10 · initState 에서 한 번 읽어 State 필드에 둔다).
final journalSettingsActionsProvider = Provider<SettingsActions>(
  (Ref ref) => throw UnimplementedError('journalSettingsActionsProvider'),
);

final _selfReportSessionProvider =
    StreamProvider.family<SelfReportSession, (String, String)>(
      (Ref ref, (String, String) key) => ref
          .watch(journalLedgerTrustRepositoryProvider)
          .watchSelfReportSession(key.$1, key.$2),
    );

const Widget _selfReportLoading = JournalSkeleton(key: Key('l3-loading'));

Widget _selfReportFail(VoidCallback onRetry, String? lastAsOf) =>
    JournalErrorView(
      key: const Key('l3-fail'),
      lastAsOfLabel: lastAsOf,
      onRetry: onRetry,
    );

Widget _l3Header(AsOf asOf) =>
    JournalAsOfHeader(key: const Key('l3-asof'), asOf: asOf);

Widget _l3Title(String text) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Text(text, key: const Key('l3-title')),
);

/// L-3 원장 실사 폼 — operator 전용.
class SelfReportForm extends ConsumerStatefulWidget {
  const SelfReportForm({
    super.key,
    required this.yyyyMm,
    required this.accountAlias,
  });

  final String yyyyMm;
  final String accountAlias;

  @override
  ConsumerState<SelfReportForm> createState() => _SelfReportFormState();
}

class _SelfReportFormState extends ConsumerState<SelfReportForm> {
  late final SettingsActions _actions;
  late final DraftKey _draftKey = DraftKey(
    kind: DraftKind.selfReportBalance,
    targetId: '${widget.yyyyMm}/${widget.accountAlias}',
  );
  final Map<String, TextEditingController> _lineCtrls =
      <String, TextEditingController>{};
  final TextEditingController _cashCtrl = TextEditingController();
  Map<String, String> _restoredLines = <String, String>{};
  bool _declared = false;

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
    _actions = ref.read(journalSettingsActionsProvider);
    unawaited(
      _actions
          .run(SettingsActionId.selfReportSessionStart, args: _sessionArgs())
          .then<void>((_) {}, onError: (Object _, StackTrace _) {}),
    );
    _cashCtrl.addListener(_onInputChanged);
    unawaited(_restore());
  }

  @override
  void dispose() {
    unawaited(_cmdSub?.cancel() ?? Future<void>.value());
    for (final TextEditingController c in _lineCtrls.values) {
      c.dispose();
    }
    _cashCtrl.dispose();
    unawaited(
      _actions
          .run(SettingsActionId.selfReportSessionStop, args: _sessionArgs())
          .then<void>((_) {}, onError: (Object _, StackTrace _) {}),
    );
    super.dispose();
  }

  Map<String, String> _sessionArgs() => <String, String>{
    'yyyy_mm': widget.yyyyMm,
    'account_alias': widget.accountAlias,
  };

  TextEditingController _lineCtrl(String symbol) =>
      _lineCtrls.putIfAbsent(symbol, () {
        final TextEditingController c = TextEditingController(
          text: _restoredLines[symbol] ?? '',
        );
        c.addListener(_onInputChanged);
        return c;
      });

  SelfReportInput _input() => SelfReportInput(
    lines: <SelfReportLineInput>[
      for (final MapEntry<String, TextEditingController> e
          in _lineCtrls.entries)
        SelfReportLineInput(symbol: e.key, quantityText: e.value.text),
    ],
    cashKrwText: _cashCtrl.text,
    accountAlias: widget.accountAlias,
  );

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

  void _persist() {
    if (!_restoreDone || _applyingRestore) return;
    final DraftRecord record = DraftRecord(
      key: _draftKey,
      selfReport: _input(),
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
    final SelfReportInput? s = r?.selfReport;
    if (s != null) {
      _restoredLines = <String, String>{
        for (final SelfReportLineInput l in s.lines) l.symbol: l.quantityText,
      };
      _applyingRestore = true;
      _cashCtrl.text = s.cashKrwText;
      _applyingRestore = false;
    }
    _lastPersisted =
        r ??
        DraftRecord(
          key: _draftKey,
          selfReport: SelfReportInput(accountAlias: widget.accountAlias),
        );
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
    if (!_issuedHere) {
      setState(() {
        _applyingRestore = true;
        for (final TextEditingController c in _lineCtrls.values) {
          c.text = '';
        }
        _cashCtrl.text = '';
        _restoredLines = <String, String>{};
        _applyingRestore = false;
        _declared = false;
        _lastPersisted = DraftRecord(
          key: _draftKey,
          selfReport: SelfReportInput(accountAlias: widget.accountAlias),
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
          .submitSelfReportBalance(
            SelfReportSubmission(
              purpose: SelfReportPurpose.periodicAudit,
              yyyyMm: widget.yyyyMm,
              input: _input(),
              declaredComplete: _declared,
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
    if (!_restoreDone) return _selfReportLoading;

    final Clock clock = ref.watch(journalClockProvider);
    final SafetyState? safety = ref
        .watch(journalSafetyStateProvider)
        .valueOrNull;
    final AsyncValue<SelfReportSession> s = ref.watch(
      _selfReportSessionProvider((widget.yyyyMm, widget.accountAlias)),
    );

    return s.when(
      data: (SelfReportSession session) {
        final String? closed = session.sessionClosedText;
        if (closed != null) {
          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _l3Header(session.asOf),
              JournalSafetyBanners(safety: safety),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(closed, key: const Key('l3-closed')),
              ),
            ],
          );
        }

        final SelfReportResult? result = session.result;
        if (result != null) {
          final LinkAction? resolve = result.resolveLink;
          final LinkAction? next = result.nextAccountLink;
          final String? empty = result.emptyLabel;
          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _l3Header(session.asOf),
              JournalSafetyBanners(safety: safety),
              _l3Title(session.titleText),
              for (final (int i, LedgerDiffRow d) in result.diffs.indexed)
                LedgerDiffTile(key: ValueKey<String>('l3-diff-$i'), row: d),
              if (empty != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(empty, key: const Key('l3-result-empty')),
                ),
              if (resolve != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      key: const Key('l3-resolve'),
                      onPressed: () {
                        ref
                            .read(journalLinkOpenerProvider)
                            .open(resolve.deepLink);
                      },
                      child: Text(resolve.label),
                    ),
                  ),
                ),
              if (next != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      key: const Key('l3-next-account'),
                      onPressed: () {
                        ref.read(journalLinkOpenerProvider).open(next.deepLink);
                      },
                      child: Text(next.label),
                    ),
                  ),
                ),
            ],
          );
        }

        final bool isStale = session.asOf.observedAt
            .add(session.asOf.staleAfter)
            .isBefore(clock.nowUtc());
        if (isStale) {
          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _l3Header(session.asOf),
              JournalStaleBanner(asOf: session.asOf),
              JournalSafetyBanners(safety: safety),
            ],
          );
        }

        final bool locked = _locked();
        final String? blocked = session.blockedText;
        final CommandReceipt? receipt = _receipt;

        return ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _l3Header(session.asOf),
            JournalSafetyBanners(safety: safety),
            _l3Title(session.titleText),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(session.noticeText, key: const Key('l3-notice')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(session.accountLabel, key: const Key('l3-account')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                session.asOfTradeDateText,
                key: const Key('l3-trade-date'),
              ),
            ),
            for (final (int i, SymbolOption s) in session.symbols.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: TextField(
                  key: ValueKey<String>('l3-line-$i'),
                  controller: _lineCtrl(s.symbol),
                  enabled: !locked,
                  decoration: InputDecoration(labelText: s.label),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                key: const Key('l3-cash'),
                controller: _cashCtrl,
                enabled: !locked,
                decoration: InputDecoration(labelText: session.cashHintLabel),
              ),
            ),
            CheckboxListTile(
              key: const Key('l3-declare'),
              value: _declared,
              title: Text(session.declareCompleteLabel),
              onChanged: locked
                  ? null
                  : (bool? v) {
                      setState(() {
                        _declared = v ?? false;
                      });
                    },
            ),
            if (receipt != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(receipt.stateLabel, key: const Key('l3-receipt')),
              ),
            if (_submitNotAccepted)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  JournalLabels.submitNotAccepted,
                  key: const Key('l3-submit-not-accepted'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (_resubscribeFailed)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TextButton(
                  key: const Key('l3-resubscribe'),
                  onPressed: _resubscribe,
                  child: const Text(JournalLabels.retry),
                ),
              ),
            if (blocked == null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: FilledButton(
                  key: const Key('l3-submit'),
                  onPressed: (locked || !_declared)
                      ? null
                      : () {
                          unawaited(_submit());
                        },
                  child: const Text(JournalLabels.draftSubmit),
                ),
              ),
            if (blocked != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(blocked, key: const Key('l3-blocked')),
              ),
          ],
        );
      },
      error: (Object _, StackTrace _) => _selfReportFail(
        () => ref.invalidate(
          _selfReportSessionProvider((widget.yyyyMm, widget.accountAlias)),
        ),
        s.valueOrNull?.asOf.label,
      ),
      loading: () => _selfReportLoading,
    );
  }
}
