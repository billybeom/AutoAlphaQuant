// E11q-b1a — M5-1 킬스위치 화면 VM · 기록 폼 · 제출 읽기 · 접수증(설계 13 §8 R178).
//
// 🔴 표본 `m5/kill_switch_*` · `kill_checklist_receipts` · `kill_switch_activate_receipts` 와 글자 · 수준 · 차례가 같다(«(합성)» 표지 제외 ·
//    합성 시각 · 기기 · 종목 제외) · C-59 불변식(꺼짐 ⇔ 버튼 · 꺼짐 ⇒ 보고 · 폼 · 링크 0 · 폼 ⇒ 기록 전 · 링크 ⇒ 기록 뒤).

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Map<String, Object?> _row(String f) =>
    ((jsonDecode(File('../domain_contracts/fixtures/m5/$f').readAsStringSync())
                    as Map<String, Object?>)['rows']!
                as List<Object?>)
            .first!
        as Map<String, Object?>;

String _plain(String s) => s.replaceFirst('(합성) ', '');

final DateTime _at = DateTime.utc(2026, 12, 23, 1, 2); // 10:02 KST
final DateTime _now = DateTime.utc(2026, 12, 23, 2);

KillSwitchScreenVm _vm({
  KillSwitchRecord record = const KillSwitchRecord(),
  DateTime? trusted,
  KillCancelReport? cancel,
  bool canRecord = true,
  bool gate = true,
  String? locked,
}) => killSwitchScreenVmOf(
  record: record,
  trustedNowUtc: trusted,
  nowUtc: _now,
  cancel: cancel,
  canRecord: canRecord,
  hasBody: (String r) => gate && r == AppRoutes.m5ReleaseGate,
  lockedLabel: locked,
);

const KillCancelReport _three = KillCancelReport(<KillCancelItem>[
  KillCancelItem('i1', '069500', KillCancelOutcome.cancelled),
  KillCancelItem('i2', '360750', KillCancelOutcome.notCancelledUnknownIntent),
  KillCancelItem('i3', '132030', KillCancelOutcome.inFlight),
]);

void main() {
  test('꺼짐 = 표본 kill_switch_off(머리 · 수준 · 버튼 · 경로 3 · 나머지 부재)', () {
    final KillSwitchScreenVm vm = _vm();
    final KillSwitchScreenVm fx = KillSwitchScreenVm.fromJson(
      _row('kill_switch_off.json'),
    );
    expect(vm.stateLabel, fx.stateLabel);
    expect(vm.level, fx.level);
    expect(vm.activateLabel, _plain(fx.activateLabel!));
    expect(vm.pathLines, fx.pathLines.map(_plain).toList());
    expect(vm.activatedText, isNull);
    expect(vm.cancelHeadline, isNull);
    expect(vm.cancelRows, isEmpty);
    expect(vm.checklistStateLabel, isNull);
    expect(vm.form, isNull);
    expect(vm.etaText, isNull);
    expect(vm.gateLink, isNull);
    expect(vm.asOf.label, '안전 기준 2026-12-23 11:00');
    // 잠김이어도 발동 버튼은 남는다(K150).
    expect(_vm(locked: '잠김').activateLabel, isNotNull);
  });

  test(
    '켜짐 · 기록 전 = 표본 kill_switch_active_unrecorded(취소 보고 3건 · 폼 · 버튼 부재)',
    () {
      final KillSwitchScreenVm vm = _vm(
        record: KillSwitchRecord(
          activatedAtUtc: _at,
          activatedByDeviceLabel: KillSwitchScreenTexts.operatorPhone,
        ),
        cancel: _three,
      );
      final KillSwitchScreenVm fx = KillSwitchScreenVm.fromJson(
        _row('kill_switch_active_unrecorded.json'),
      );
      expect(vm.stateLabel, fx.stateLabel);
      expect(vm.level, fx.level);
      expect(vm.activateLabel, isNull);
      expect(vm.activatedText, _plain(fx.activatedText!));
      expect(vm.cancelHeadline, _plain(fx.cancelHeadline!));
      expect(
        vm.cancelRows.map(
          (KillCancelRow r) => (r.outcomeCode, r.outcomeLabel, r.level),
        ),
        fx.cancelRows.map(
          (KillCancelRow r) => (r.outcomeCode, _plain(r.outcomeLabel), r.level),
        ),
      );
      expect(vm.checklistStateLabel, fx.checklistStateLabel);
      final KillActivationFormVm f = vm.form!;
      final KillActivationFormVm ff = fx.form!;
      expect(f.items.length, 7);
      for (int i = 0; i < 7; i++) {
        expect(f.items[i].itemNo, ff.items[i].itemNo);
        expect(f.items[i].label, ff.items[i].label);
        expect(f.items[i].hintText, ff.items[i].hintText);
        expect(f.items[i].choices, ff.items[i].choices);
        expect(
          f.items[i].fixedText,
          ff.items[i].fixedText == null ? null : _plain(ff.items[i].fixedText!),
        );
      }
      expect(f.ackQueriedLabel, ff.ackQueriedLabel);
      expect(f.ackCancelledLabel, ff.ackCancelledLabel);
      expect(f.ackRemainingZeroLabel, ff.ackRemainingZeroLabel);
      expect(f.noteLabel, ff.noteLabel);
      expect(f.noticeText, _plain(ff.noticeText!));
      expect(vm.etaText, isNull);
      expect(vm.gateLink, isNull);
      expect(
        _vm(
          record: KillSwitchRecord(activatedAtUtc: _at),
          canRecord: false,
        ).form,
        isNull,
      );
      expect(
        _vm(
          record: KillSwitchRecord(activatedAtUtc: _at),
          locked: '잠김',
        ).form,
        isNull,
      );
    },
  );

  test(
    '기록 뒤 = 해제 시각 줄 · 게이트 링크(등록됐을 때만) · 수준 = 대기 WATCH · 준비 INFO · 시각 모름 WATCH',
    () {
      final DateTime confirmed = DateTime.utc(2026, 12, 23, 1, 20); // 10:20 KST
      final KillSwitchRecord r = KillSwitchRecord(
        activatedAtUtc: _at,
        checklistConfirmedAtUtc: confirmed,
      );
      final KillSwitchScreenVm waiting = _vm(record: r, trusted: _now);
      final KillSwitchScreenVm fx = KillSwitchScreenVm.fromJson(
        _row('kill_switch_recorded_waiting.json'),
      );
      expect(waiting.level, fx.level);
      expect(waiting.etaText, fx.etaText);
      expect(waiting.checklistStateLabel, fx.checklistStateLabel);
      expect(waiting.form, isNull);
      expect(waiting.gateLink!.deepLink, fx.gateLink!.deepLink);
      expect(waiting.gateLink!.label, _plain(fx.gateLink!.label));
      expect(_vm(record: r, trusted: _now, gate: false).gateLink, isNull);
      final KillSwitchScreenVm ready = _vm(
        record: r,
        trusted: confirmed.add(const Duration(hours: 49)),
      );
      expect(ready.level, UiLevel.info);
      expect(
        ready.etaText,
        KillSwitchScreenVm.fromJson(_row('kill_switch_recorded_ready.json'))
            .etaText,
      );
      final KillSwitchScreenVm unknown = _vm(record: r);
      expect(unknown.level, UiLevel.watch);
      expect(unknown.etaText, '서버 시각을 확인하지 못해 해제 시각을 셀 수 없습니다');
    },
  );

  test('취소 보고 — 읽기 실패 = 표본 문장 · 0건 · 경로 없음(NO_BROKER) 글자', () {
    expect(
      killCancelHeadline(
        const KillCancelReport(<KillCancelItem>[], candidatesError: 'X'),
      ),
      _plain(
        KillSwitchScreenVm.fromJson(_row('kill_switch_cancel_read_failed.json'))
            .cancelHeadline!,
      ),
    );
    expect(
      killCancelHeadline(const KillCancelReport(<KillCancelItem>[])),
      '미체결 주문이 없었습니다.',
    );
    final KillSwitchScreenVm vm = _vm(
      record: KillSwitchRecord(activatedAtUtc: _at),
      cancel: const KillCancelReport(<KillCancelItem>[
        KillCancelItem(
          'i1',
          '069500',
          KillCancelOutcome.failed,
          code: 'NO_BROKER',
        ),
      ]),
    );
    expect(vm.cancelRows.single.outcomeLabel, KillSwitchScreenTexts.noBroker);
    expect(vm.cancelRows.single.level, UiLevel.act);
    expect(vm.cancelHeadline, '미체결 1건 — 실패 1.');
  });

  test('제출 원문 → 엔진 답 — 고르지 않음 · 숫자 아님 · 빈 시나리오 = null · 규칙 · 감정 읽기', () {
    const KillChecklistSubmission base = KillChecklistSubmission(
      ruleAction: '행동',
      reasonKind: KillActivationReason.rule,
      resumeCondition: '조건',
      scope: KillActivationScope.newEntriesOnly,
      scenarioId: 'W3',
      note: '메모',
      openOrdersQueried: true,
    );
    final (KillActivationAnswers, KillAckAnswers) ok = killChecklistAnswersOf(
      base,
      journalDecisionId: 'J1',
    )!;
    expect(ok.$1.reasonKind, KillReasonKind.rule);
    expect(ok.$1.scope, KillScope.newEntriesOnly);
    expect(ok.$1.journalDecisionId, 'J1');
    expect(ok.$1.emotion, isNull);
    expect(ok.$2.openOrdersQueried, isTrue);
    expect(ok.$2.note, '메모');
    expect(
      killChecklistAnswersOf(
        base.copyWith(reasonKind: null),
        journalDecisionId: 'J1',
      ),
      isNull,
    );
    expect(
      killChecklistAnswersOf(
        base.copyWith(scope: null),
        journalDecisionId: 'J1',
      ),
      isNull,
    );
    expect(
      killChecklistAnswersOf(
        base.copyWith(scenarioId: ' '),
        journalDecisionId: 'J1',
      ),
      isNull,
    );
    expect(
      killChecklistAnswersOf(
        base.copyWith(scenarioId: null, scenarioNone: true),
        journalDecisionId: 'J1',
      )!.$1.scenarioNone,
      isTrue,
    );
    final KillChecklistSubmission emo = base.copyWith(
      reasonKind: KillActivationReason.emotion,
      emotion: '불안',
      intensity: '7',
      sleepHours: '4.5',
    );
    final KillActivationAnswers e = killChecklistAnswersOf(
      emo,
      journalDecisionId: 'J1',
    )!.$1;
    expect(e.reasonKind, KillReasonKind.emotion);
    expect(e.intensity, 7);
    expect(e.sleepHours, 4.5);
    expect(
      killChecklistAnswersOf(
        emo.copyWith(intensity: '많이'),
        journalDecisionId: 'J1',
      ),
      isNull,
    );
  });

  test('접수증 = 표본 kill_checklist_receipts 7행 · 발동 실행 글자 · 봉투(TTL 30분 · 요약 = 페이로드 SHA-256)', () {
    for (final Object? o
        in (jsonDecode(
              File(
                '../domain_contracts/fixtures/m5/kill_checklist_receipts.json',
              ).readAsStringSync(),
            ) as Map<String, Object?>)['rows']!
            as List<Object?>) {
      final CommandReceipt fx = CommandReceipt.fromJson(
        o! as Map<String, Object?>,
      );
      final CommandReceipt got = killCommandReceiptOf(
        kind: CommandKind.killChecklistConfirm,
        commandId: 'c',
        nonce: 'n',
        requestedAtUtc: _now,
        deviceId: 'd',
        executed: fx.state == CommandState.executed,
        reasonCode: fx.rejectReasonCode,
      );
      expect(got.stateLabel, fx.stateLabel);
      expect(got.state, fx.state);
      expect(got.rejectReasonCode, fx.rejectReasonCode);
    }
    final CommandReceipt a = killCommandReceiptOf(
      kind: CommandKind.killSwitchActivate,
      commandId: 'c',
      nonce: 'n',
      requestedAtUtc: _now,
      deviceId: 'd',
      executed: true,
    );
    expect(a.stateLabel, '켜짐 — 신규 주문을 막았습니다');
    expect(a.expiresAt.difference(a.requestedAt), kKillCommandTtl);
    expect(kKillCommandTtl, const Duration(minutes: 30), reason: '명령 선례 30분');
    expect(
      () => killCommandReceiptOf(
        kind: CommandKind.killSwitchActivate,
        commandId: 'c',
        nonce: 'n',
        requestedAtUtc: _now,
        deviceId: 'd',
        executed: false,
      ),
      throwsArgumentError,
    );
    expect(() => KillCommandTexts.rejected('NOPE'), throwsArgumentError);
    final ({String commandId, String nonce, String payloadDigest}) e =
        issueKillCommand(payload: const <String, Object?>{}, random: Random(1));
    expect(
      e.payloadDigest,
      '44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a',
    );
    expect(e.nonce, hasLength(32));
  });
}
