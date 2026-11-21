// 🆕 E16j-b — X1 기기 이전 화면(01 §42 K264~K281 · 06 X1-2~X1-6 · 표본 `x1/*`).
//
// 🔴 옛 폰 = [X1PlanWizardScreen](`x1Migration`) · 새 폰 받기 · 비상 = [X1RecoveryScreen](`x1MigrationPlan` · `x1MigrationEmergency` ·
//    같은 VM 꼴 — 엔진이 갈래를 고른다).
// 🔴 머리 · 단계 · 상태 · 줄 · 버튼 · 시각 · 해시 글자 = 엔진 VM 그대로(받은 차례 · 화면이 숫자 · 카운트다운 · 해시를 짓지 않는다) ·
//    색 = `level` 하나 · 코드 칸(`reasonCode` · `blockCode` · `code` · `gateStateCode`) = 그리지 않는다.
// 🔴 동작 = VM · 행이 준 `SafetyActionCall` 그대로 `SafetyActions.run`(확인 대화 0 · 결과 = 엔진 `headline` + `reasonCode` 원문 ·
//    제출 자체 실패 = 정적 문장) · 쓰기 주입 null = 버튼 부재.
// 🔴 `D-03` 카드 = 건너뛰기 버튼 0(06 X1-2) — 시작 버튼은 카드 아래에만 · 인쇄 · QR · 복구 코드 · 재발급 값 = 슬롯(조립 앱 · null = 자리 부재).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/level_look.dart';
import '../kill_switch/kill_switch_screen.dart' show safetyLinkOpenerProvider;
import '../pledge/pledge_panel.dart' show safetyActionsProvider;

/// X1 화면 읽기 창구(조립 앱이 주입 · 폰 전용).
final Provider<MigrationRepository> safetyMigrationRepositoryProvider =
    Provider<MigrationRepository>(
      (Ref ref) => throw UnimplementedError(
        'safetyMigrationRepositoryProvider must be overridden',
      ),
    );

/// X1 슬롯 자리(QR 표시 · 스캔 · 복구 코드 · 재발급 값 · 카드 인쇄) — null = 자리 부재(크기 0).
typedef SafetyX1SlotBuilder = Widget Function(String slotId);

/// X1 슬롯 빌더(조립 앱이 주입 · 기본 = 없음).
final Provider<SafetyX1SlotBuilder?> safetyX1SlotBuilderProvider =
    Provider<SafetyX1SlotBuilder?>((Ref ref) => null);

final AutoDisposeStreamProvider<X1PlanWizardVm> _planProvider =
    StreamProvider.autoDispose<X1PlanWizardVm>(
      (Ref ref) =>
          ref.watch(safetyMigrationRepositoryProvider).watchPlanWizard(),
    );

final AutoDisposeStreamProvider<X1RecoveryVm> _planRecoveryProvider =
    StreamProvider.autoDispose<X1RecoveryVm>(
      (Ref ref) =>
          ref.watch(safetyMigrationRepositoryProvider).watchPlanRecovery(),
    );

final AutoDisposeStreamProvider<X1RecoveryVm> _emergencyProvider =
    StreamProvider.autoDispose<X1RecoveryVm>(
      (Ref ref) =>
          ref.watch(safetyMigrationRepositoryProvider).watchEmergencyRecovery(),
    );

Widget _loadingOr(AsyncValue<Object?> data, String key) => data.hasError
    ? Center(
        child: Text(SafetyLabels.x1ReadFailed, key: Key('$key-read-failed')),
      )
    : Center(child: CircularProgressIndicator(key: Key('$key-loading')));

Widget _slot(SafetyX1SlotBuilder? b, String? slotId, String key) {
  if (b == null || slotId == null) return const SizedBox.shrink();
  return KeyedSubtree(key: Key(key), child: b(slotId));
}

Widget _head(BuildContext context, String text, UiLevel level, String key) {
  final ThemeData theme = Theme.of(context);
  final (IconData icon, Color tone) = safetyLevelLook(theme.colorScheme, level);
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsetsDirectional.only(end: 8, top: 2),
        child: Icon(icon, color: tone),
      ),
      Expanded(
        child: Text(text, key: Key(key), style: theme.textTheme.titleMedium),
      ),
    ],
  );
}

Widget _line(String text, String key, {TextStyle? style}) => Padding(
  padding: const EdgeInsets.only(top: 6),
  child: Text(text, key: Key(key), style: style),
);

Widget _section(BuildContext context, String title) => Padding(
  padding: const EdgeInsets.only(top: 20, bottom: 4),
  child: Text(title, style: Theme.of(context).textTheme.titleSmall),
);

Widget _asOf(BuildContext context, AsOf asOf, String key) => Padding(
  padding: const EdgeInsets.only(top: 16),
  child: Text(
    asOf.label,
    key: Key(key),
    style: Theme.of(context).textTheme.bodySmall,
  ),
);

/// 결과 한 줄(엔진 글자 · 제출 자체 실패 = 정적 문장).
Widget _result(bool has, SafetyActionResult? r, String key) {
  if (!has) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      r == null
          ? SafetyLabels.submitNotAccepted
          : r.reasonCode == null
          ? r.headline
          : '${r.headline} (${r.reasonCode})',
      key: Key(r == null ? '$key-failed' : key),
    ),
  );
}

/// 동작을 내고 결과를 쥐는 상태 섞개(키마다 마지막 결과 · 보내는 중 · 쓰기 주입 null = 아무것도 안 함).
mixin _X1Runner<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final Map<String, SafetyActionResult?> results =
      <String, SafetyActionResult?>{};
  final Set<String> pending = <String>{};

  bool get canRun => ref.watch(safetyActionsProvider) != null;

  Future<void> runCall(String key, SafetyActionCall a) async {
    final SafetyActions? actions = ref.read(safetyActionsProvider);
    if (actions == null || pending.contains(key)) return;
    setState(() => pending.add(key));
    SafetyActionResult? r;
    try {
      r = await actions.run(a.id, args: a.args);
    } on Object {
      r = null;
    }
    if (!mounted) return;
    setState(() {
      pending.remove(key);
      results[key] = r;
    });
  }

  Widget stepRow(String prefix, X1StepRow row) {
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      row.level,
    );
    final String key = '$prefix-row-${row.code}';
    return Card(
      key: Key(key),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Icon(icon, color: tone, size: 20),
                ),
                Expanded(
                  child: Text(row.title, style: theme.textTheme.titleSmall),
                ),
                Text(
                  row.stateLabel,
                  key: Key('$key-state'),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            for (int i = 0; i < row.lines.length; i++)
              _line(row.lines[i], '$key-line-$i'),
            if (canRun && row.actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: <Widget>[
                    for (final SafetyActionCall a in row.actions)
                      OutlinedButton(
                        key: Key('$key-act-${a.id.wire}'),
                        onPressed: pending.contains(key)
                            ? null
                            : () => runCall(key, a),
                        child: Text(a.label),
                      ),
                  ],
                ),
              ),
            _result(results.containsKey(key), results[key], '$key-result'),
          ],
        ),
      ),
    );
  }

  Widget startButton(String key, SafetyActionCall a) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (canRun)
          FilledButton(
            key: Key(key),
            onPressed: pending.contains(key) ? null : () => runCall(key, a),
            child: Text(a.label),
          ),
        _result(results.containsKey(key), results[key], '$key-result'),
      ],
    ),
  );
}

class _D03Card extends StatelessWidget {
  const _D03Card({required this.card, required this.slot});

  final EmergencyCardVm card;
  final SafetyX1SlotBuilder? slot;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      key: const Key('x1p-d03'),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(card.title, style: theme.textTheme.titleSmall),
            for (int i = 0; i < card.steps.length; i++)
              Padding(
                key: Key('x1p-d03-step-$i'),
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 36, child: Text(card.steps[i].orderText)),
                    Expanded(child: Text(card.steps[i].text)),
                  ],
                ),
              ),
            _line(card.contactLine, 'x1p-d03-contact'),
            _line(
              card.keepOnPaperNotice,
              'x1p-d03-paper',
              style: theme.textTheme.bodySmall,
            ),
            _slot(slot, card.printSlotId, 'x1p-d03-print'),
          ],
        ),
      ),
    );
  }
}

/// 옛 폰 계획 교체 마법사(`x1Migration`).
class X1PlanWizardScreen extends ConsumerStatefulWidget {
  /// 만든다.
  const X1PlanWizardScreen({super.key});

  @override
  ConsumerState<X1PlanWizardScreen> createState() => _PlanState();
}

class _PlanState extends ConsumerState<X1PlanWizardScreen>
    with _X1Runner<X1PlanWizardScreen> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<X1PlanWizardVm> data = ref.watch(_planProvider);
    final X1PlanWizardVm? vm = data.valueOrNull;
    if (vm == null) return _loadingOr(data, 'x1p');
    final ThemeData theme = Theme.of(context);
    final SafetyX1SlotBuilder? slot = ref.watch(safetyX1SlotBuilderProvider);
    final X1TicketCard? t = vm.ticket;
    return ListView(
      key: const Key('x1p-root'),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _head(context, vm.headline, vm.level, 'x1p-headline'),
        if (vm.lockedLabel != null) _line(vm.lockedLabel!, 'x1p-locked'),
        if (vm.d03Card != null) _D03Card(card: vm.d03Card!, slot: slot),
        if (vm.startAction != null) startButton('x1p-start', vm.startAction!),
        if (vm.windowText != null)
          _line(vm.windowText!, 'x1p-window', style: theme.textTheme.bodySmall),
        for (int i = 0; i < vm.warningLines.length; i++)
          _line(vm.warningLines[i], 'x1p-warning-$i'),
        if (vm.rows.isNotEmpty) _section(context, SafetyLabels.x1Steps),
        for (final X1StepRow r in vm.rows) stepRow('x1p', r),
        if (t != null)
          Card(
            key: const Key('x1p-ticket'),
            margin: const EdgeInsets.only(top: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(t.headline, style: theme.textTheme.titleSmall),
                  _slot(slot, t.ticketSlotId, 'x1p-ticket-qr'),
                  if (t.expiresText != null)
                    _line(t.expiresText!, 'x1p-ticket-expires'),
                  for (int i = 0; i < t.lines.length; i++)
                    _line(
                      t.lines[i],
                      'x1p-ticket-line-$i',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),
        if (vm.doneLabel != null) _line(vm.doneLabel!, 'x1p-done'),
        _asOf(context, vm.asOf, 'x1p-asof'),
      ],
    );
  }
}

/// 새 폰 갈래.
enum X1RecoveryRoute {
  /// 받기(`x1MigrationPlan`).
  plan,

  /// 비상(`x1MigrationEmergency`).
  emergency,
}

/// 새 폰 받기 · 비상 복구(`x1MigrationPlan` · `x1MigrationEmergency`).
class X1RecoveryScreen extends ConsumerStatefulWidget {
  /// 만든다.
  const X1RecoveryScreen({required this.route, super.key});

  /// 어느 라우트로 들어왔나.
  final X1RecoveryRoute route;

  @override
  ConsumerState<X1RecoveryScreen> createState() => _RecoveryState();
}

class _RecoveryState extends ConsumerState<X1RecoveryScreen>
    with _X1Runner<X1RecoveryScreen> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<X1RecoveryVm> data = ref.watch(
      widget.route == X1RecoveryRoute.plan
          ? _planRecoveryProvider
          : _emergencyProvider,
    );
    final X1RecoveryVm? vm = data.valueOrNull;
    if (vm == null) return _loadingOr(data, 'x1r');
    final ThemeData theme = Theme.of(context);
    final SafetyX1SlotBuilder? slot = ref.watch(safetyX1SlotBuilderProvider);
    final X1FencingCard? f = vm.fencing;
    final X1RestoreCard? rc = vm.restore;
    final X1GateCard? g = vm.gate;
    return ListView(
      key: const Key('x1r-root'),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _head(context, vm.headline, vm.level, 'x1r-headline'),
        _line(vm.kindLabel, 'x1r-kind', style: theme.textTheme.bodySmall),
        if (vm.lockedLabel != null) _line(vm.lockedLabel!, 'x1r-locked'),
        if (vm.noticeText != null) _line(vm.noticeText!, 'x1r-notice'),
        if (vm.windowText != null)
          _line(vm.windowText!, 'x1r-window', style: theme.textTheme.bodySmall),
        _slot(slot, vm.recoveryCodeSlotId, 'x1r-recovery-code'),
        if (vm.startAction != null) startButton('x1r-start', vm.startAction!),
        _slot(slot, vm.scanSlotId, 'x1r-scan'),
        if (f != null)
          _Box(
            boxKey: 'x1r-fencing',
            headline: f.headline,
            level: f.level,
            children: <Widget>[
              if (f.endsAtText != null)
                _line(f.endsAtText!, 'x1r-fencing-ends'),
              for (int i = 0; i < f.lines.length; i++)
                _line(f.lines[i], 'x1r-fencing-line-$i'),
            ],
          ),
        if (vm.reissue.isNotEmpty) _section(context, SafetyLabels.x1Reissue),
        for (final X1ReissueRow r in vm.reissue) _reissueRow(r, slot),
        if (rc != null)
          _Box(
            boxKey: 'x1r-restore',
            headline: rc.headline,
            level: rc.level,
            children: <Widget>[
              for (int i = 0; i < rc.lines.length; i++)
                _line(rc.lines[i], 'x1r-restore-line-$i'),
              if (rc.chainHashText != null)
                _line(
                  rc.chainHashText!,
                  'x1r-restore-chain',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        if (vm.steps.isNotEmpty) _section(context, SafetyLabels.x1Steps),
        for (final X1StepRow r in vm.steps) stepRow('x1r', r),
        if (g != null)
          _Box(
            boxKey: 'x1r-gate',
            headline: g.stateLabel,
            level: g.level,
            children: <Widget>[
              if (g.observeText != null)
                _line(g.observeText!, 'x1r-gate-observe'),
              _line(g.whyLine, 'x1r-gate-why'),
              if (g.actionLine != null) _line(g.actionLine!, 'x1r-gate-action'),
              for (int i = 0; i < g.checklistLines.length; i++)
                _line(g.checklistLines[i], 'x1r-gate-check-$i'),
            ],
          ),
        if (vm.restartLink != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: const Key('x1r-restart'),
                onPressed: () => ref
                    .read(safetyLinkOpenerProvider)
                    .open(vm.restartLink!.deepLink),
                child: Text(vm.restartLink!.label),
              ),
            ),
          ),
        if (vm.doneLabel != null) _line(vm.doneLabel!, 'x1r-done'),
        _asOf(context, vm.asOf, 'x1r-asof'),
      ],
    );
  }

  Widget _reissueRow(X1ReissueRow r, SafetyX1SlotBuilder? slot) {
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      r.level,
    );
    final String key = 'x1r-reissue-${r.code}';
    return Card(
      key: Key(key),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Icon(icon, color: tone, size: 20),
                ),
                Expanded(child: Text(r.label)),
                Text(r.stateLabel, key: Key('$key-state')),
              ],
            ),
            _slot(slot, r.reissueSlotId, '$key-slot'),
            if (canRun && r.recordAction != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton(
                  key: Key('$key-act'),
                  onPressed: pending.contains(key)
                      ? null
                      : () => runCall(key, r.recordAction!),
                  child: Text(r.recordAction!.label),
                ),
              ),
            _result(results.containsKey(key), results[key], '$key-result'),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.boxKey,
    required this.headline,
    required this.level,
    required this.children,
  });

  final String boxKey;
  final String headline;
  final UiLevel level;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      level,
    );
    return Card(
      key: Key(boxKey),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Icon(icon, color: tone, size: 20),
                ),
                Expanded(
                  child: Text(
                    headline,
                    key: Key('$boxKey-headline'),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
