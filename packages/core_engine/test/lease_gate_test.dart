// E14a — 리스 NR-1 0단계 · 6.9 직전 재확인 · 봉인 판정(SPEC v2.42 04 §3-1 · 설계 13 §8 R71 L1 · L2 · L4 · L8).
//
// 🔵 잡는 것: ① 0단계 = 유효만 통과 · 무효 · 모름 · 포트 예외 = REJECTED LEASE_INVALID(제출 0 · 그 키를 먹는다)
//    ② 같은 날 같은 결정 다시 = PREVENTED ③ 6.9 = 무효 · 모름 · 예외 = SKIPPED(제출 0 · 행 SKIPPED)
//    ④ 6.9 는 안내 · DRY_RUN 앞(안내 0 · DRY_RUN 사유가 아니라 LEASE_INVALID) ⑤ 정상 = 리스를 두 번 묻는다
//    ⑥ `leaseStale` 경계(29:59 = 아님 · 30:00 = 봉인 · 시계가 뒤로 = 아님) ⑦ `readLease` 예외 = 모름.
import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

/// 두 번째 물음부터 던진다.
class _ThrowsAfterFirst implements LeaseGate {
  int calls = 0;
  @override
  Future<LeaseVerdict> check() async {
    calls++;
    if (calls > 1) throw StateError('리스 읽기 실패');
    return LeaseVerdict.valid;
  }
}

void main() {
  group('0단계', () {
    for (final (String name, FakeLeaseGate lease) in <(String, FakeLeaseGate)>[
      ('무효', FakeLeaseGate(LeaseVerdict.invalid)),
      ('모름', FakeLeaseGate(LeaseVerdict.unknown)),
      ('포트 예외', FakeLeaseGate()..throwing = Exception('연결 끊김')),
    ]) {
      test('🔴 $name = REJECTED LEASE_INVALID · 제출 0 · 1단계 전에 멈춤', () async {
        final FakeOrderLedger ledger = ledgerOf();
        final FakeOrderBroker broker = FakeOrderBroker();
        final OrderIntentDraft d = draftOf();
        final List<String> steps = <String>[];
        final ExecutionOutcome o = await executeIntent(
          d,
          portfolioOk(),
          ctxOf(ledger, broker, lease: lease),
          steps: steps,
        );
        expect(
          (o.status, o.message),
          (ExecutionStatus.rejected, 'LEASE_INVALID'),
        );
        expect(steps, <String>['0']);
        expect(broker.submitCount, 0);
        final FakeIntentRecord r =
            ledger.records[intentIdFor(d.idempotencyKey)]!;
        expect(
          (r.status, r.errorMessage),
          (IntentStatus.rejected, 'LEASE_INVALID'),
        );
      });
    }

    test('🔴 키를 먹는다 — 같은 날 리스가 돌아와도 = PREVENTED(그날 보류)', () async {
      final FakeOrderLedger ledger = ledgerOf();
      final FakeOrderBroker broker = FakeOrderBroker();
      final OrderIntentDraft d = draftOf();
      final FakeLeaseGate lease = FakeLeaseGate(LeaseVerdict.invalid);
      expect(
        (await executeIntent(
          d,
          portfolioOk(),
          ctxOf(ledger, broker, lease: lease),
        )).status,
        ExecutionStatus.rejected,
      );
      lease.verdict = LeaseVerdict.valid;
      expect(
        (await executeIntent(
          d,
          portfolioOk(),
          ctxOf(ledger, broker, lease: lease),
        )).status,
        ExecutionStatus.prevented,
      );
      expect(broker.submitCount, 0);
    });

    test('유효 = 통과 · 정상 경로는 리스를 두 번 묻는다(0 · 6.9)', () async {
      final FakeLeaseGate lease = FakeLeaseGate();
      final FakeOrderBroker broker = FakeOrderBroker();
      final ExecutionOutcome o = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(ledgerOf(), broker, lease: lease),
      );
      expect(o.status, ExecutionStatus.submitted);
      expect((lease.calls, broker.submitCount), (2, 1));
    });
  });

  group('6.9 직전 재확인', () {
    for (final (String name, LeaseVerdict second) in <(String, LeaseVerdict)>[
      ('무효', LeaseVerdict.invalid),
      ('모름', LeaseVerdict.unknown),
    ]) {
      test(
        '🔴 0단계 뒤 $name = SKIPPED LEASE_INVALID · 제출 0 · 행 SKIPPED',
        () async {
          final FakeOrderLedger ledger = ledgerOf();
          final FakeOrderBroker broker = FakeOrderBroker();
          final OrderIntentDraft d = draftOf();
          final FakeLeaseGate lease = FakeLeaseGate()
            ..script.addAll(<LeaseVerdict>[LeaseVerdict.valid, second]);
          final List<String> steps = <String>[];
          final ExecutionOutcome o = await executeIntent(
            d,
            portfolioOk(),
            ctxOf(ledger, broker, lease: lease),
            steps: steps,
          );
          expect(
            (o.status, o.message),
            (ExecutionStatus.skipped, 'LEASE_INVALID'),
          );
          expect(steps.last, '6.9');
          expect(steps.first, '0');
          expect(broker.submitCount, 0);
          final FakeIntentRecord r =
              ledger.records[intentIdFor(d.idempotencyKey)]!;
          expect(
            (r.status, r.errorMessage),
            (IntentStatus.skipped, 'LEASE_INVALID'),
          );
        },
      );
    }

    test('6.9 포트 예외 = 모름 = SKIPPED', () async {
      final FakeOrderBroker broker = FakeOrderBroker();
      final ExecutionOutcome o = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(ledgerOf(), broker, lease: _ThrowsAfterFirst()),
      );
      expect((o.status, o.message), (ExecutionStatus.skipped, 'LEASE_INVALID'));
      expect(broker.submitCount, 0);
    });

    test('🔴 안내 · DRY_RUN 앞 — 안내 0 · 사유 = LEASE_INVALID', () async {
      final RecordingAdviceSink advice = RecordingAdviceSink();
      final ExecutionOutcome a = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(
          ledgerOf(),
          FakeOrderBroker(),
          mode: OperatingMode.advisory,
          advice: advice,
          lease: FakeLeaseGate()
            ..script.addAll(<LeaseVerdict>[
              LeaseVerdict.valid,
              LeaseVerdict.invalid,
            ]),
        ),
      );
      expect((a.status, a.message), (ExecutionStatus.skipped, 'LEASE_INVALID'));
      expect(advice.published, isEmpty);
      final ExecutionOutcome dry = await executeIntent(
        draftOf(),
        portfolioOk(),
        ctxOf(
          ledgerOf(),
          FakeOrderBroker(),
          execPolicy: ExecPolicy.dryRun,
          lease: FakeLeaseGate()
            ..script.addAll(<LeaseVerdict>[
              LeaseVerdict.valid,
              LeaseVerdict.unknown,
            ]),
        ),
      );
      expect(
        (dry.status, dry.message),
        (ExecutionStatus.skipped, 'LEASE_INVALID'),
      );
    });
  });

  test('leaseStale 경계 — 29:59 아님 · 30:00 봉인 · 시계가 뒤로 = 아님', () {
    final DateTime ok = DateTime.utc(2026, 11, 13, 1);
    bool stale(Duration d) => leaseStale(lastOkAtUtc: ok, nowUtc: ok.add(d));
    expect(stale(const Duration(minutes: 29, seconds: 59)), isFalse);
    expect(stale(const Duration(minutes: 30)), isTrue);
    expect(stale(const Duration(minutes: -5)), isFalse);
    expect(
      (kLeaseTtl, kLeaseRenewEvery, kLeaseInvalidCode),
      (
        const Duration(minutes: 30),
        const Duration(minutes: 10),
        'LEASE_INVALID',
      ),
    );
  });

  test('readLease — 판정 그대로 · 예외 = 모름', () async {
    expect(
      await readLease(FakeLeaseGate(LeaseVerdict.invalid)),
      LeaseVerdict.invalid,
    );
    expect(await readLease(FakeLeaseGate()), LeaseVerdict.valid);
    expect(
      await readLease(FakeLeaseGate()..throwing = Exception('x')),
      LeaseVerdict.unknown,
    );
  });
}
