// 🆕 E11q-b1a — M5-1 킬스위치 화면 원천(설계 13 §8 R178): 원장 원문 → 엔진 VM.
//
// 🔴 상태 = `kill_switch_state` · 취소 보고 = 지금 발동 뒤의 마지막 CANCEL_REPORT(발동 전 보고 = 무시 · 시각 비교) ·
//    기록 확인 = 신뢰 시각(모르면 거부 — 엔진) · 화면 = 해제 시각 줄 · 게이트 링크(등록됐을 때만).

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show
        KillAckAnswers,
        KillActivationAnswers,
        KillCancelOutcome,
        KillReasonKind,
        KillScope,
        KillSwitchScreenTexts,
        OrderBroker,
        ResumeChecklist,
        TrustedClock;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 12, 23, 1, 2); // 10:02 KST

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late _Trusted trusted;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e11qb1_');
    db = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _t0);
    clock = _Clock(_t0);
    trusted = _Trusted(null);
  });

  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  SqliteKillSwitchScreenSource src({bool gate = true, bool record = true}) =>
      SqliteKillSwitchScreenSource(
        db,
        clock: clock,
        trusted: trusted,
        canRecord: record,
        hasBody: (String r) => gate && r == AppRoutes.m5ReleaseGate,
      );

  SqliteKillSwitchStore store() =>
      SqliteKillSwitchStore(db, clock: clock, trusted: trusted);

  void report(
    DateTime at,
    List<Map<String, Object?>> items, {
    String id = 'r',
  }) => db.execute(
    'INSERT INTO kill_switch_event(event_id, occurred_at, kind, channel, decision_id, summary) '
    "VALUES (?, ?, 'CANCEL_REPORT', NULL, NULL, ?)",
    <Object?>[
      id,
      at.toIso8601String(),
      jsonEncode(<String, Object?>{'items': items}),
    ],
  );

  test('꺼짐 = 발동 버튼 · 경로 · 보고 0', () {
    final KillSwitchScreenVm vm = src().screen();
    expect(vm.activateLabel, KillSwitchScreenTexts.activate);
    expect(vm.cancelHeadline, isNull);
  });

  test('발동(취소 경로 없음) → 켜짐 · 기록 전 폼 · 마지막 보고만(발동 전 보고 무시) · 경로 없음 글자', () async {
    report(_t0.subtract(const Duration(days: 3)), <Map<String, Object?>>[
      <String, Object?>{
        'intent_id': 'old',
        'symbol': '111111',
        'outcome': 'CANCELLED',
      },
    ], id: 'old');
    await store().activateLocal(
      commandId: 'c1',
      payloadDigest: 'd',
      brokers: const <String, OrderBroker>{},
      channel: 'app',
      deviceLabel: KillSwitchScreenTexts.operatorPhone,
    );
    final KillSwitchScreenVm a = src().screen();
    expect(a.activateLabel, isNull);
    expect(a.activatedText, '발동 12-23 10:02 · 운영 폰');
    expect(a.cancelHeadline, '미체결 주문이 없었습니다.', reason: '발동 전 보고는 이 발동의 것이 아니다');
    expect(a.form, isNotNull);
    expect(src(record: false).screen().form, isNull);
    report(_t0.add(const Duration(minutes: 1)), <Map<String, Object?>>[
      <String, Object?>{
        'intent_id': 'i1',
        'symbol': '069500',
        'outcome': KillCancelOutcome.failed.wire,
        'code': 'NO_BROKER',
      },
    ], id: 'new');
    final KillSwitchScreenVm b = src().screen();
    expect(b.cancelRows.single.symbolText, '069500');
    expect(b.cancelRows.single.outcomeLabel, KillSwitchScreenTexts.noBroker);
  });

  test('발동 전 보고만 있으면 보고 부재(이 발동의 보고가 아니다)', () async {
    report(_t0.subtract(const Duration(days: 3)), <Map<String, Object?>>[
      <String, Object?>{
        'intent_id': 'old',
        'symbol': '111111',
        'outcome': 'CANCELLED',
      },
    ], id: 'old');
    // 엔진 발동 함수를 거치지 않은 상태 행(취소 보고 0) — 보고 읽기 규칙만 본다.
    await store().activate(atUtc: _t0, channel: 'app');
    final KillSwitchScreenVm vm = src().screen();
    expect(vm.activateLabel, isNull);
    expect(vm.cancelHeadline, isNull);
    expect(vm.cancelRows, isEmpty);
  });

  test(
    '기록 확인 — 신뢰 시각 모름 = 거부(기록 전 그대로) · 앎 = 해제 시각 줄 · 게이트 링크(등록됐을 때만)',
    () async {
      await store().activateLocal(
        commandId: 'c1',
        payloadDigest: 'd',
        brokers: const <String, OrderBroker>{},
        channel: 'app',
      );
      const KillActivationAnswers ans = KillActivationAnswers(
        ruleAction: '규칙대로 신규 진입을 멈춘다',
        reasonKind: KillReasonKind.rule,
        scenarioId: 'W3',
        resumeCondition: '체결 오류 0',
        scope: KillScope.newEntriesOnly,
        journalDecisionId: 'KS-CHK-1',
      );
      const KillAckAnswers ack = KillAckAnswers(
        openOrdersQueried: true,
        openOrdersCancelled: true,
        remainingCountZero: true,
        note: '한 줄',
      );
      expect(
        store()
            .confirmChecklist(
              commandId: 'k1',
              payloadDigest: 'd',
              answers: ans,
              ack: ack,
            )
            .reasonCode,
        'TRUSTED_TIME_UNKNOWN',
      );
      expect(src().screen().form, isNotNull);
      trusted.at = _t0.add(const Duration(minutes: 18)); // 10:20 KST
      expect(
        store()
            .confirmChecklist(
              commandId: 'k2',
              payloadDigest: 'd',
              answers: ans,
              ack: ack,
            )
            .executed,
        isTrue,
      );
      final KillSwitchScreenVm vm = src().screen();
      expect(vm.form, isNull);
      expect(vm.checklistStateLabel, '체크리스트 확인 12-23 10:20');
      expect(vm.etaText, '해제 가능 예정 12-25 10:20');
      expect(vm.gateLink?.deepLink, AppRoutes.m5ReleaseGate);
      expect(src(gate: false).screen().gateLink, isNull);
      // 🆕 R179 — 재개 게이트 재생 = 이 발동 뒤 기록 원문(같은 번호) · 6번 = 기록 확인 줄 · 7번 = 없음.
      final KillResumeGateVm g = src().gate(ResumeChecklist.empty);
      expect(g.items[0].replayText, '그때 적은 행동: 규칙대로 신규 진입을 멈춘다');
      expect(g.items[1].replayText, '그때: 규칙이라고 적었다');
      expect(g.items[2].replayText, '그때 짚은 시나리오: W3');
      expect(g.items[3].replayText, '그때 적은 재개 조건: 체결 오류 0');
      expect(g.items[4].replayText, '그때 고른 범위: 신규 진입 차단만');
      expect(g.items[5].replayText, '체크리스트 확인 12-23 10:20');
      expect(g.items[6].replayText, isNull);
    },
  );
}
