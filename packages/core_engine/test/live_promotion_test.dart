// 🆕 E15e2 — M1-22 승격 커밋 사전 판정 · 코드 · 결정 id · 문구(설계 13 §8 R91 AD3~AD5).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

final DateTime _since = DateTime.utc(2027, 1, 12, 6); // KST 01-12 15:00
final DateTime _now = DateTime.utc(2027, 1, 14, 9); // KST 01-14 18:00

const LiveObservationReport _ok = LiveObservationReport(
  observing: true,
  observedTradingDays: 2,
  promotionAvailable: true,
  block: null,
  vm: null,
  promotionLabel: '승격 가능 — 무결 거래일을 채웠습니다(2/2)',
);

const LiveObservationReport _short = LiveObservationReport(
  observing: true,
  observedTradingDays: 1,
  promotionAvailable: false,
  block: LiveObservationBlock.notEnoughDays,
  vm: null,
  promotionLabel: '승격 불가 — 무결 거래일이 아직 모자랍니다(1/2)',
);

String? _reject({
  bool bio = true,
  bool? session,
  RunMode? run = RunMode.live,
  ExecPolicy? exec = ExecPolicy.dryRun,
  OperatingMode? op = OperatingMode.autoTrade,
  DateTime? since,
  bool noSince = false,
  DateTime? now,
  LiveObservationReport report = _ok,
  LeaseVerdict lease = LeaseVerdict.valid,
}) => livePromotionReject(
  biometricConfirmed: bio,
  sessionValid: session,
  runMode: run,
  execPolicy: exec,
  operatingMode: op,
  currentSinceUtc: noSince ? null : (since ?? _since),
  nowUtc: now ?? _now,
  lease: lease,
  report: report,
);

void main() {
  test('결정 id = PROMOTE-{한국 YYYYMMDD-HHmmss} · 코드 · 사유 문구', () {
    expect(
      livePromotionDecisionId(DateTime.utc(2027, 1, 14, 9, 5, 9)),
      'PROMOTE-20270114-180509',
    );
    expect(
      livePromotionDecisionId(DateTime.utc(2027, 1, 14, 15, 30)),
      'PROMOTE-20270115-003000',
    );
    expect(kLivePromotionReasonCode, 'LIVE_EXECUTE_PROMOTION');
    expect(kLivePromotionReason, '실전 집행 승격 — 관찰 뒤 생체 1회');
    expect(
      LivePromotionCodes.biometricUnavailable,
      SettingsResultCodes.biometricUnavailable,
    );
  });

  group('사전 판정(AD4)', () {
    test('전부 맞으면 통과 · 세션을 주지 않아도 통과', () {
      expect(_reject(), isNull);
      expect(_reject(session: true), isNull);
    });

    test('생체 없음 = 맨 먼저', () {
      expect(
        _reject(bio: false, session: false, run: null, report: _short),
        LivePromotionCodes.biometricUnavailable,
      );
    });

    test('세션 무효 = 관찰 판정보다 먼저', () {
      expect(
        _reject(session: false, exec: ExecPolicy.execute),
        LivePromotionCodes.sessionInvalid,
      );
    });

    test('관찰 중 아님 — 모드 · 집행 정책 · 시작점', () {
      for (final String? c in <String?>[
        _reject(run: RunMode.simBroker),
        _reject(run: null),
        _reject(exec: ExecPolicy.execute, op: OperatingMode.advisory),
        _reject(noSince: true),
      ]) {
        expect(c, LivePromotionCodes.notObserving);
      }
    });

    test('자동 매매 아님 · 모름 = 거부(시각보다 먼저)', () {
      expect(
        _reject(op: OperatingMode.advisory, now: _since),
        LivePromotionCodes.notAutoTrade,
      );
      expect(_reject(op: null), LivePromotionCodes.notAutoTrade);
    });

    test('시각 = 지금이 시작점 뒤여야(같음 · 앞 = 거부 · 재판정보다 먼저)', () {
      expect(
        _reject(now: _since, report: _short),
        LivePromotionCodes.clockBehind,
      );
      expect(
        _reject(now: _since.subtract(const Duration(seconds: 1))),
        LivePromotionCodes.clockBehind,
      );
      expect(_reject(now: _since.add(const Duration(microseconds: 1))), isNull);
    });

    test('🆕 E15f5 리스 — 유효 아님 = LEASE_INVALID(시각 뒤 · 재판정보다 먼저)', () {
      expect(_reject(lease: LeaseVerdict.unknown), 'LEASE_INVALID');
      expect(_reject(lease: LeaseVerdict.invalid), 'LEASE_INVALID');
      expect(
        _reject(lease: LeaseVerdict.unknown, report: _short),
        'LEASE_INVALID',
      );
      expect(
        _reject(now: _since, lease: LeaseVerdict.unknown),
        LivePromotionCodes.clockBehind,
      );
      expect(
        livePromotionHeadline('LEASE_INVALID'),
        '이 기기의 발주권(리스)을 확인할 수 없어 올리지 않았습니다.',
      );
    });

    test('재판정 막힘 = 그 사유 코드 · 사유 없으면 관찰 중 아님', () {
      expect(_reject(report: _short), 'LIVE_OBSERVATION_NOT_ENOUGH_DAYS');
      expect(
        _reject(report: LiveObservationReport.notObserving),
        LivePromotionCodes.notObserving,
      );
    });
  });

  test('머리말 — 성공 · 막힘 = 칩 문구 · 코드별 · «DRY_RUN» 글자 0', () {
    final Map<String?, String> got = <String?, String>{
      null: livePromotionHeadline(null),
      'LIVE_OBSERVATION_NOT_ENOUGH_DAYS': livePromotionHeadline(
        'LIVE_OBSERVATION_NOT_ENOUGH_DAYS',
        report: _short,
      ),
      LivePromotionCodes.biometricUnavailable: livePromotionHeadline(
        LivePromotionCodes.biometricUnavailable,
      ),
      LivePromotionCodes.sessionInvalid: livePromotionHeadline(
        LivePromotionCodes.sessionInvalid,
      ),
      LivePromotionCodes.notObserving: livePromotionHeadline(
        LivePromotionCodes.notObserving,
      ),
      LivePromotionCodes.notAutoTrade: livePromotionHeadline(
        LivePromotionCodes.notAutoTrade,
      ),
      LivePromotionCodes.clockBehind: livePromotionHeadline(
        LivePromotionCodes.clockBehind,
      ),
      LivePromotionCodes.rolledBack: livePromotionHeadline(
        LivePromotionCodes.rolledBack,
      ),
    };
    expect(got, <String?, String>{
      null: '실전 집행으로 올렸습니다 — 다음 회차부터 실제 주문을 냅니다.',
      'LIVE_OBSERVATION_NOT_ENOUGH_DAYS': '승격 불가 — 무결 거래일이 아직 모자랍니다(1/2)',
      LivePromotionCodes.biometricUnavailable: '생체 확인이 없어 올리지 않았습니다.',
      LivePromotionCodes.sessionInvalid: '확인 세션이 열려 있지 않거나 만료돼 올리지 않았습니다.',
      LivePromotionCodes.notObserving: '실전 관찰 중이 아니라 올릴 것이 없습니다.',
      LivePromotionCodes.notAutoTrade: '자동 매매가 아니라 올리지 않았습니다.',
      LivePromotionCodes.clockBehind: '기기 시각이 관찰 시작보다 앞서 올리지 않았습니다.',
      LivePromotionCodes.rolledBack:
          '실전 집행으로 올리지 못했습니다 — 바뀐 것은 없습니다. 다시 시도해 주세요.',
    });
    expect(
      livePromotionHeadline('LIVE_OBSERVATION_KILL_SWITCH'),
      '승격 불가 — 관찰 조건을 아직 채우지 못했습니다',
    );
    for (final String s in got.values) {
      expect(s, isNot(contains('DRY_RUN')));
    }
  });
}
