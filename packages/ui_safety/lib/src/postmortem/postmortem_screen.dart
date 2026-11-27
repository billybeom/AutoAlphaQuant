// 🆕 미결 243 ⓐ — `M5-4` 안전 사건 postmortem 목록 + 쓰기 한 화면(설계 13 §8 R282 · R243 P4 · 계약 v1.39 K345 · 표본 `m5/postmortem_list_*`).
//
// 🔴 머리 · 행 · 기한 · 상태 · 쓴 글 · 칸 글자 · 버튼 글자 = 엔진 VM 그대로(받은 차례 · 거르기 · 세기 0 · 카운트다운 0 — 기한이 지나면
//    엔진이 새 VM).
// 🔴 쓰기 = 행의 `form` 이 있을 때만 · 제출 = `SafetyActions.runPostmortem(PostmortemSubmission{행 incidentId 그대로, 칸 원문})`
//    (화면 검증 · 손질 0 — 빈 글 = 엔진 `POSTMORTEM_BLANK`) · 결과 = 엔진 `headline` + `reasonCode` 원문 · 제출 자체 실패 = 정적 문장 ·
//    확인 대화 0 · 쓰기 주입 null(뷰어 · 기기 id 없음) = 동작 0.
// 🔴 한 번만 쓴다 — 쓴 행 = 글 읽기 전용 · SEV1 링크(«STOPPED 결정으로») = 엔진이 본문 있을 때만 싣는다 · 여는 곳 = 셸 링크 열기.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/labels.dart';
import '../common/level_look.dart';
import '../kill_switch/kill_switch_screen.dart' show safetyLinkOpenerProvider;
import '../pledge/pledge_panel.dart' show safetyActionsProvider;

/// `M5-4` 읽기 창구(조립 앱이 주입).
final Provider<PostmortemRepository> safetyPostmortemRepositoryProvider =
    Provider<PostmortemRepository>(
      (Ref ref) => throw UnimplementedError(
        'safetyPostmortemRepositoryProvider must be overridden',
      ),
    );

final AutoDisposeStreamProvider<PostmortemListVm> _listProvider =
    StreamProvider.autoDispose<PostmortemListVm>(
      (Ref ref) =>
          ref.watch(safetyPostmortemRepositoryProvider).watchPostmortems(),
    );

/// `M5-4` postmortem 한 화면.
class PostmortemScreen extends ConsumerStatefulWidget {
  /// 만든다.
  const PostmortemScreen({super.key});

  @override
  ConsumerState<PostmortemScreen> createState() => _PostmortemScreenState();
}

class _PostmortemScreenState extends ConsumerState<PostmortemScreen> {
  /// 칸 원문(사건 id → 입력).
  final Map<String, TextEditingController> _text =
      <String, TextEditingController>{};

  /// 결과(사건 id → 결과 · 제출 자체 실패 = null 값).
  final Map<String, SafetyActionResult?> _results =
      <String, SafetyActionResult?>{};
  bool _busy = false;

  @override
  void dispose() {
    for (final TextEditingController c in _text.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerOf(String id) =>
      _text.putIfAbsent(id, TextEditingController.new);

  Future<void> _submit(String id) async {
    final SafetyActions? actions = ref.read(safetyActionsProvider);
    if (actions == null || _busy) return;
    setState(() => _busy = true);
    SafetyActionResult? r;
    try {
      r = await actions.runPostmortem(
        PostmortemSubmission(incidentId: id, text: _controllerOf(id).text),
      );
    } on Object {
      r = null;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _results[id] = r;
    });
  }

  Widget _result(String id) {
    if (!_results.containsKey(id)) return const SizedBox.shrink();
    final SafetyActionResult? r = _results[id];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: r == null
          ? Text(
              SafetyLabels.submitNotAccepted,
              key: Key('m54-result-failed-$id'),
            )
          : Text(
              r.reasonCode == null
                  ? r.headline
                  : '${r.headline} (${r.reasonCode})',
              key: Key('m54-result-$id'),
            ),
    );
  }

  Widget _row(PostmortemRow r, bool canRun) {
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      r.level,
    );
    final PostmortemForm? form = r.form;
    final LinkAction? next = r.nextLink;
    return Card(
      key: Key('m54-row-${r.incidentId}'),
      margin: const EdgeInsets.only(top: 12),
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
                Expanded(
                  child: Text(
                    '${r.severityLabel} · ${r.title}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(r.occurredText, style: theme.textTheme.bodySmall),
            ),
            if (r.dueText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  r.dueText!,
                  key: Key('m54-due-${r.incidentId}'),
                  style: r.overdue
                      ? theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        )
                      : theme.textTheme.bodyMedium,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(r.stateLabel, key: Key('m54-state-${r.incidentId}')),
            ),
            if (r.writtenText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  r.writtenText!,
                  key: Key('m54-written-${r.incidentId}'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (form != null && canRun) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(form.promptText, style: theme.textTheme.labelLarge),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  key: Key('m54-text-${r.incidentId}'),
                  controller: _controllerOf(r.incidentId),
                  minLines: 3,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: form.hintText,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              if (form.noticeText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    form.noticeText!,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton(
                  key: Key('m54-submit-${r.incidentId}'),
                  onPressed: _busy ? null : () => _submit(r.incidentId),
                  child: Text(form.buttonLabel),
                ),
              ),
            ],
            if (next != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  key: Key('m54-next-${r.incidentId}'),
                  onPressed: () =>
                      ref.read(safetyLinkOpenerProvider).open(next.deepLink),
                  child: Text(next.label),
                ),
              ),
            _result(r.incidentId),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PostmortemListVm> data = ref.watch(_listProvider);
    final PostmortemListVm? vm = data.valueOrNull;
    if (vm == null) {
      return data.hasError
          ? const Center(
              child: Text(
                SafetyLabels.postmortemReadFailed,
                key: Key('m54-read-failed'),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(key: Key('m54-loading')),
            );
    }
    final ThemeData theme = Theme.of(context);
    final (IconData icon, Color tone) = safetyLevelLook(
      theme.colorScheme,
      vm.level,
    );
    final bool canRun = ref.watch(safetyActionsProvider) != null;
    return ListView(
      key: const Key('m54-root'),
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
                key: const Key('m54-headline'),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        if (vm.emptyLabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(vm.emptyLabel!, key: const Key('m54-empty')),
          ),
        for (final PostmortemRow r in vm.rows) _row(r, canRun),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            vm.asOf.label,
            key: const Key('m54-asof'),
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
