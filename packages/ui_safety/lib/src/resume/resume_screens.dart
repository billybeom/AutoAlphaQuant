// 🆕 E11q-b2a — X2 재개 리포트 · 재개 게이트(설계 13 §8 R186 · 01 §31 K64 · §34 K156 · 06 X2-6 · 표본 `x2/resume_*`).
//
// 🔴 머리 · 모드 · 시각 · 단계 · 항목 · 사유 · 버튼 글자 = 엔진 VM 그대로(받은 차례 · 화면이 D+n · 합계 · 멈춤 사유를 짓지 않는다) · 손익 0.
// 🔴 계절 3택 = 행이 준 동작만(엔진이 완성 · 고르는 창구가 없거나 잠기면 엔진이 비운다) · 결과 = 엔진 `headline` + `reasonCode` 원문 ·
//    제출 자체 실패 = 정적 문장(접수증 아님) · 확인 대화 0.
// 🔴 리포트 링크 = 엔진 완성(null = 버튼 부재).

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/level_look.dart';
import '../kill_switch/kill_switch_screen.dart' show safetyLinkOpenerProvider;
import '../pledge/pledge_panel.dart' show safetyActionsProvider;

/// X2 재개 화면 읽기 창구(조립 앱이 주입 · 게이트 + 리포트).
final Provider<ResumeGateRepository> safetyResumeGateRepositoryProvider =
    Provider<ResumeGateRepository>(
      (Ref ref) => throw UnimplementedError(
        'safetyResumeGateRepositoryProvider must be overridden',
      ),
    );

final AutoDisposeStreamProvider<ResumeReportVm> _reportProvider =
    StreamProvider.autoDispose<ResumeReportVm>(
      (Ref ref) => ref.watch(safetyResumeGateRepositoryProvider).watchReport(),
    );

final AutoDisposeStreamProvider<ResumeGateVm> _gateProvider =
    StreamProvider.autoDispose<ResumeGateVm>(
      (Ref ref) => ref.watch(safetyResumeGateRepositoryProvider).watchGate(),
    );

Widget _loadingOr(AsyncValue<Object?> data, String failed, String key) =>
    data.hasError
    ? Center(child: Text(failed, key: Key('$key-read-failed')))
    : Center(child: CircularProgressIndicator(key: Key('$key-loading')));

Widget _asOf(BuildContext context, AsOf asOf, String key) => Padding(
  padding: const EdgeInsets.only(top: 16),
  child: Text(
    asOf.label,
    key: Key(key),
    style: Theme.of(context).textTheme.bodySmall,
  ),
);

Widget _section(BuildContext context, String title) => Padding(
  padding: const EdgeInsets.only(top: 20, bottom: 4),
  child: Text(title, style: Theme.of(context).textTheme.titleSmall),
);

/// X2 재개 리포트 한 화면(가장 최근 끝난 회차).
class ResumeReportScreen extends ConsumerWidget {
  /// 만든다.
  const ResumeReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ResumeReportVm> data = ref.watch(_reportProvider);
    final ResumeReportVm? vm = data.valueOrNull;
    if (vm == null) {
      return _loadingOr(data, SafetyLabels.resumeReportReadFailed, 'x2r');
    }
    final ThemeData theme = Theme.of(context);
    final ResumeReport? r = vm.report;
    return ListView(
      key: const Key('x2r-root'),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        if (r == null && vm.emptyLabel != null)
          Text(vm.emptyLabel!, key: const Key('x2r-empty')),
        if (r != null) ...<Widget>[
          Text(
            r.headline,
            key: const Key('x2r-headline'),
            style: theme.textTheme.titleMedium,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(r.modeLabel, key: const Key('x2r-mode')),
          ),
          if (vm.periodText != null)
            Text(
              vm.periodText!,
              key: const Key('x2r-period'),
              style: theme.textTheme.bodySmall,
            ),
          if (vm.phaseLabel != null)
            Text(
              vm.phaseLabel!,
              key: const Key('x2r-phase'),
              style: theme.textTheme.bodySmall,
            ),
          if (r.items.isNotEmpty)
            _section(context, SafetyLabels.resumeReportItems),
          for (final ResumeItem i in r.items) _ReportItem(item: i),
          if (r.unrecoverableGaps.isNotEmpty)
            _section(context, SafetyLabels.resumeReportGaps),
          for (final DataGapRow g in r.unrecoverableGaps)
            Padding(
              key: Key('x2r-gap-${g.gapId}'),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(g.label),
            ),
        ],
        _asOf(context, vm.asOf, 'x2r-asof'),
      ],
    );
  }
}

class _ReportItem extends StatelessWidget {
  const _ReportItem({required this.item});

  final ResumeItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      key: Key('x2r-item-${item.workId}'),
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(item.oneLine, style: theme.textTheme.titleSmall),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(item.plannedLine, style: theme.textTheme.bodySmall),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(item.reevaluatedLine),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(item.verdictLabel, style: theme.textTheme.labelLarge),
            ),
          ],
        ),
      ),
    );
  }
}

/// X2 재개 게이트 한 화면(막힌 계획 · 계절 3택).
class ResumeGateScreen extends ConsumerStatefulWidget {
  /// 만든다.
  const ResumeGateScreen({super.key});

  @override
  ConsumerState<ResumeGateScreen> createState() => _ResumeGateScreenState();
}

class _ResumeGateScreenState extends ConsumerState<ResumeGateScreen> {
  /// 행마다 마지막 결과(엔진 글자) · 제출 자체 실패 = null 값으로 표시.
  final Map<String, SafetyActionResult?> _results =
      <String, SafetyActionResult?>{};
  final Set<String> _pending = <String>{};

  Future<void> _run(String workId, SafetyActionCall a) async {
    final SafetyActions? actions = ref.read(safetyActionsProvider);
    if (actions == null || _pending.contains(workId)) return;
    setState(() => _pending.add(workId));
    SafetyActionResult? r;
    try {
      r = await actions.run(a.id, args: a.args);
    } on Object {
      r = null;
    }
    if (!mounted) return;
    setState(() {
      _pending.remove(workId);
      _results[workId] = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ResumeGateVm> data = ref.watch(_gateProvider);
    final ResumeGateVm? vm = data.valueOrNull;
    if (vm == null) {
      return _loadingOr(data, SafetyLabels.x2GateReadFailed, 'x2g');
    }
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      vm.level,
    );
    final bool canRun = ref.watch(safetyActionsProvider) != null;
    return ListView(
      key: const Key('x2g-root'),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8, top: 2),
              child: Icon(icon, color: tone),
            ),
            Expanded(
              child: Text(
                vm.headline,
                key: const Key('x2g-headline'),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(vm.modeLabel, key: const Key('x2g-mode')),
        ),
        if (vm.lockedLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(vm.lockedLabel!, key: const Key('x2g-locked')),
          ),
        for (final ResumeGateRow r in vm.rows)
          _GateRow(
            row: r,
            canRun: canRun,
            pending: _pending.contains(r.workId),
            hasResult: _results.containsKey(r.workId),
            result: _results[r.workId],
            onRun: (SafetyActionCall a) => _run(r.workId, a),
          ),
        if (vm.reportLink != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: const Key('x2g-report'),
                onPressed: () => ref
                    .read(safetyLinkOpenerProvider)
                    .open(vm.reportLink!.deepLink),
                child: Text(vm.reportLink!.label),
              ),
            ),
          ),
        _asOf(context, vm.asOf, 'x2g-asof'),
      ],
    );
  }
}

class _GateRow extends StatelessWidget {
  const _GateRow({
    required this.row,
    required this.canRun,
    required this.pending,
    required this.hasResult,
    required this.result,
    required this.onRun,
  });

  final ResumeGateRow row;
  final bool canRun;
  final bool pending;
  final bool hasResult;
  final SafetyActionResult? result;
  final void Function(SafetyActionCall a) onRun;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      row.level,
    );
    return Card(
      key: Key('x2g-row-${row.workId}'),
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
                  child: Text(row.oneLine, style: theme.textTheme.titleSmall),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(row.reasonLabel),
            ),
            if (canRun && row.actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: <Widget>[
                    for (final SafetyActionCall a in row.actions)
                      OutlinedButton(
                        key: Key(
                          'x2g-act-${row.workId}-${a.args['choice'] ?? a.label}',
                        ),
                        onPressed: pending ? null : () => onRun(a),
                        child: Text(a.label),
                      ),
                  ],
                ),
              ),
            if (hasResult && result != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  result!.reasonCode == null
                      ? result!.headline
                      : '${result!.headline} (${result!.reasonCode})',
                  key: Key('x2g-result-${row.workId}'),
                ),
              ),
            if (hasResult && result == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  SafetyLabels.submitNotAccepted,
                  key: Key('x2g-result-failed-${row.workId}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
