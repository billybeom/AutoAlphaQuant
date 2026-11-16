// E11p4a — 온보딩 진척 저장 · 읽기(설계 13 §8 R122) — 실 SQLite(로컬 원장 스키마).

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show OnboardingStepFact, onboardingStepsVmOf;
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, GateState, OperatingMode, RunMode, StepState;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late SqliteOnboardingProgressStore store;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_onbp_');
    clock = _Clock(DateTime.utc(2026, 11, 15, 1));
    db = openLocalLedger(dir.path, RunMode.simInternal, clock: () => clock.now);
    store = SqliteOnboardingProgressStore(db, clock: clock);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  List<Row> rows() =>
      db.select('SELECT * FROM onboarding_progress ORDER BY step_id').toList();

  test('🔴 빈 표 = 사실 없음 · 쓰면 FRESH 한 행 · 다시 쓰면 덮어쓴다(이력 아님)', () {
    expect(store.facts(), isEmpty);
    store.record('o_02', StepState.inProgress);
    clock.now = clock.now.add(const Duration(minutes: 5));
    store.record('o_02', StepState.verified);
    final Row r = rows().single;
    expect(
      (r['step_id'], r['track'], r['state'], r['failure_reason_code']),
      ('o_02', 'FRESH', 'VERIFIED', null),
    );
    expect(r['verified_at'], '2026-11-15T01:05:00.000Z');
    expect(r['updated_at'], '2026-11-15T01:05:00.000Z');
    final OnboardingStepFact f = store.facts()['o_02']!;
    expect(f.state, StepState.verified);
  });

  test('🔴 실패 · 기한 = 그대로 읽힌다 · VERIFIED 아님 = 검증 시각 비움', () {
    store.record(
      'o_05',
      StepState.failed,
      failureReasonCode: 'PERMISSION_DENIED',
    );
    store.record(
      'o_08',
      StepState.expired,
      verifiedUntil: DateTime.utc(2026, 8, 30),
      failureReasonCode: 'TOKEN_EXPIRED',
    );
    final Map<String, OnboardingStepFact> f = store.facts();
    expect(f['o_05']!.state, StepState.failed);
    expect(f['o_05']!.failureReasonCode, 'PERMISSION_DENIED');
    expect(f['o_08']!.verifiedUntil, DateTime.utc(2026, 8, 30));
    expect(rows().every((Row r) => r['verified_at'] == null), true);
  });

  test('🔴 카탈로그 밖 id · VERIFIED + 실패 코드 = 오류(한 행도 안 쓴다)', () {
    expect(() => store.record('o_99', StepState.verified), throwsArgumentError);
    expect(
      () => store.record('o_02', StepState.verified, failureReasonCode: 'X'),
      throwsArgumentError,
    );
    expect(rows(), isEmpty);
  });

  test('🔴 단계 목록 VM 의 사실로 바로 쓰인다 — 게이트 차례: 앞 단계 막힘 > 원천 없음 > 열림', () {
    GateState? o3() => onboardingStepsVmOf(
      mode: OperatingMode.autoTrade,
      facts: store.facts(),
      nowUtc: clock.now,
    ).rows.singleWhere((s) => s.stepId == 'o_03').gate?.state;
    expect(o3(), GateState.block);
    store.record('o_02', StepState.verified);
    // 앞 단계는 끝났지만 o_03 자체의 사실이 없다 = 원천 없음(막힘 — 마무리로 못 간다).
    expect(o3(), GateState.unknown);
    store.record('o_03', StepState.inProgress);
    expect(o3(), GateState.pass);
  });

  test('🔴 마지막 기록(R129) = 상태 · 기록 시각 · 실패 코드 · 없음 = null', () {
    expect(store.lastRecord('o_02'), isNull);
    store.record(
      'o_02',
      StepState.failed,
      failureReasonCode: 'CREDENTIAL_REJECTED',
    );
    clock.now = clock.now.add(const Duration(minutes: 3));
    store.record('o_05', StepState.verified);
    final OnboardingProgressRecord r = store.lastRecord('o_02')!;
    expect(r.state, StepState.failed);
    expect(r.updatedAtUtc, DateTime.utc(2026, 11, 15, 1));
    expect(r.failureReasonCode, 'CREDENTIAL_REJECTED');
    expect(
      store.lastRecord('o_05')!.updatedAtUtc,
      DateTime.utc(2026, 11, 15, 1, 3),
    );
  });

  test('감시 표 = 진척 · 선택(단계 목록이 다시 읽는다)', () {
    expect(SqliteOnboardingProgressStore.watchedTables, <String>{
      'onboarding_progress',
      'onboarding_choice',
    });
  });
}
