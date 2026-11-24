// 🆕 E15f3a — simToAuto 2단 커밋 1단계 순수 몫(게이트 차례 · 개시 현금 · id · S5 코드 · 문구 · 설계 13 §8 R98 AG2~AG10).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

final ExchangeCalendar _kr = frozenExchangeCalendar(Market.kr);
final LiveObservationConfig _two = LiveObservationConfig(
  requiredTradingDays: 2,
);

/// 한국 시각 → UTC.
DateTime _k(String day, int h, [int m = 0, int s = 0]) => DateTime.utc(
  int.parse(day.substring(0, 4)),
  int.parse(day.substring(5, 7)),
  int.parse(day.substring(8, 10)),
  h,
  m,
  s,
).subtract(const Duration(hours: 9));

const SimTrialReport _done = SimTrialReport(
  started: true,
  items: <SimTrialItemResult>[],
  complete: true,
  needsWarning: false,
  counters: SimTrialCounters.zero,
  headline: '체험 5항목을 모두 채웠습니다.',
);

/// 생체 = 01-12 10:00 → 냉각 끝 01-13 10:00 → 기한 01-14 10:00 · 확정 = 01-13 11:00.
final DateTime _opened = _k('2027-01-12', 10);
final DateTime _now = _k('2027-01-13', 11);

SimToAutoReport _report({DateTime? now}) => judgeSimToAuto(
  SimToAutoFacts(
    trustedNowUtc: now ?? _now,
    simRunMode: RunMode.simInternal,
    simClosed: false,
    operatingMode: OperatingMode.autoTrade,
    trial: _done,
    goldenVectorPassed: true,
    liveKeysVerified: true,
    accountByStrategy: const <String, String>{
      P0sStrategyIds.sleeveA: 'general',
      P0sStrategyIds.sleeveB: 'pension',
      P0sStrategyIds.sleeveC: 'general',
      P0sStrategyIds.pot: 'general',
    },
    fate: SimLedgerFate.keep,
    sessionOpenedAtUtc: _opened,
    killSwitchActive: false,
    blockingFlags: const <String>[],
  ),
  kr: _kr,
  observation: _two,
);

HandoverSessionRecord _session({
  HandoverSessionKind kind = HandoverSessionKind.wizard,
  HandoverPath? path = HandoverPath.simToAuto,
  DateTime? closed,
}) => HandoverSessionRecord(
  sessionId: 'HS-1',
  kind: kind,
  path: path,
  deviceId: 'device-1',
  leaseEpoch: 1,
  openedAtUtc: _opened,
  expiresAtUtc: _opened.add(kHandoverSessionTtl),
  closedAtUtc: closed,
  closeCode: closed == null ? null : HandoverCloseCode.cancelled,
);

LiveAccountProbe _p(
  String alias, {
  int holdings = 0,
  int? cash = 1000000,
  int activity = 0,
  DateTime? at,
  String? mark,
}) => LiveAccountProbe(
  alias: alias,
  accountMark: mark ?? 'mark-$alias',
  holdingsCount: holdings,
  orderableCashKrw: cash,
  activityToday: activity,
  fetchedAtUtc: at ?? _now.subtract(const Duration(minutes: 2)),
);

const Set<String> _aliases = <String>{'general', 'pension'};

const LeaseSnapshot _lease = LeaseSnapshot(
  verdict: LeaseVerdict.valid,
  epoch: 1,
  deviceId: 'device-1',
);

String? _reject({
  bool noNow = false,
  DateTime? now,
  HandoverSessionRecord? session,
  bool noSession = false,
  int rows = 0,
  SimToAutoReport? report,
  bool noReport = false,
  Set<String> aliases = _aliases,
  List<LiveAccountProbe>? probes,
  LeaseSnapshot lease = _lease,
  String? approved = 'cfg-1',
  String config = 'cfg-1',
}) => simToAutoCommitReject(
  trustedNowUtc: noNow ? null : (now ?? _now),
  session: noSession ? null : (session ?? _session()),
  lease: lease,
  liveModeRows: rows,
  approvedConfigHash: approved,
  configHash: config,
  report: noReport ? null : (report ?? _report(now: now)),
  aliases: aliases,
  probes: probes ?? <LiveAccountProbe>[_p('general'), _p('pension')],
);

void main() {
  test('id · 사유 · 낸 곳 · S5 코드 왕복', () {
    expect(liveOpeningDecisionId(_now), 'LIVEOPEN-20270113-110000');
    expect(
      simLedgerFateDecisionId(_k('2027-01-12', 23, 59, 7), 12),
      'SIMFATE-20270112-235907-012',
    );
    expect(kHandoverCommitCheck, 'handover-commit');
    expect(kLiveOpeningSeedReason, 'LIVE_OPENING');
    expect(simLedgerFateReasonCode(SimLedgerFate.keep), 'SIM_LEDGER_KEEP');
    expect(
      simLedgerFateReasonCode(SimLedgerFate.discard),
      'SIM_LEDGER_DISCARD',
    );
    for (final SimLedgerFate f in SimLedgerFate.values) {
      expect(simLedgerFateOfReasonCode(simLedgerFateReasonCode(f)), f);
    }
    expect(simLedgerFateOfReasonCode('OPENING_BALANCE'), isNull);
    expect(kLiveOpeningReason.contains('DRY_RUN'), isFalse);
  });

  test('세션 쓰임 = 위저드 ∧ SIM_TO_AUTO ∧ 안 닫힘 ∧ 만료 전', () {
    expect(simToAutoSessionUsable(_session(), _now), isTrue);
    expect(simToAutoSessionUsable(null, _now), isFalse);
    expect(
      simToAutoSessionUsable(
        _session(kind: HandoverSessionKind.gate, path: null),
        _now,
      ),
      isFalse,
    );
    expect(
      simToAutoSessionUsable(_session(kind: HandoverSessionKind.gate), _now),
      isFalse,
    );
    expect(
      simToAutoSessionUsable(_session(path: HandoverPath.freshAuto), _now),
      isFalse,
    );
    expect(simToAutoSessionUsable(_session(closed: _now), _now), isFalse);
    expect(
      simToAutoSessionUsable(_session(), _opened.add(kHandoverSessionTtl)),
      isFalse,
    );
  });

  test('개시 현금 = 대응 별칭만 · 0원 · 모름 제외 · 별칭 순', () {
    expect(
      liveOpeningCash(
        <LiveAccountProbe>[
          _p('pension', cash: 500000),
          _p('general', cash: 1200000),
          _p('isa', cash: 9000000),
          _p('zero', cash: 0),
        ],
        <String>{'general', 'pension', 'zero'},
      ).entries.map((MapEntry<String, int> e) => '${e.key}=${e.value}'),
      <String>['general=1200000', 'pension=500000'],
    );
    expect(
      liveOpeningCash(<LiveAccountProbe>[_p('general', cash: null)], _aliases),
      isEmpty,
    );
  });

  test('게이트 차례 — 시각 → 세션 → 이미 커밋 → (승인 config) → 재판정 → 조회 → 신선도 → 보유 → 활동 → 예수금 → 합계', () {
    expect(
      _reject(noNow: true, noSession: true, rows: 1),
      SimToAutoCodes.trustedTimeUnavailable,
    );
    expect(
      _reject(noSession: true, rows: 1),
      HandoverSessionCodes.sessionInvalid,
    );
    expect(
      _reject(session: _session(closed: _now), rows: 1),
      HandoverSessionCodes.sessionInvalid,
    );
    expect(
      _reject(rows: 1, noReport: true),
      SimToAutoCommitCodes.alreadyCommitted,
    );
    expect(_reject(noReport: true), SimToAutoCodes.notSimAuto);
    // 냉각 중 = 재판정 코드 그대로.
    final DateTime cool = _k('2027-01-12', 20);
    expect(
      _reject(
        now: cool,
        report: _report(now: cool),
      ),
      SimToAutoCodes.cooling,
    );
    expect(_reject(aliases: <String>{}), SimToAutoCommitCodes.probeMissing);
    expect(
      _reject(probes: <LiveAccountProbe>[_p('general')]),
      SimToAutoCommitCodes.probeMissing,
    );
    expect(
      _reject(
        probes: <LiveAccountProbe>[
          _p(
            'general',
            at: _now.subtract(const Duration(minutes: 5, seconds: 1)),
          ),
          _p('pension', holdings: 3),
        ],
      ),
      SimToAutoCommitCodes.snapshotStale,
    );
    expect(
      _reject(
        probes: <LiveAccountProbe>[
          _p('general', at: _now.add(const Duration(seconds: 1))),
          _p('pension'),
        ],
      ),
      SimToAutoCommitCodes.snapshotStale,
    );
    expect(
      _reject(
        probes: <LiveAccountProbe>[
          _p('general', holdings: 1, activity: 2, cash: null),
          _p('pension'),
        ],
      ),
      SimToAutoCommitCodes.holdingsNotZero,
    );
    expect(
      _reject(
        probes: <LiveAccountProbe>[
          _p('general'),
          _p('pension', activity: 1, cash: null),
        ],
      ),
      SimToAutoCommitCodes.brokerActivityToday,
    );
    expect(
      _reject(
        probes: <LiveAccountProbe>[_p('general'), _p('pension', cash: null)],
      ),
      SimToAutoCommitCodes.cashUnknown,
    );
    expect(
      _reject(
        probes: <LiveAccountProbe>[_p('general'), _p('pension', cash: -1)],
      ),
      SimToAutoCommitCodes.cashUnknown,
    );
    expect(
      _reject(
        probes: <LiveAccountProbe>[
          _p('general', cash: 0),
          _p('pension', cash: 0),
        ],
      ),
      SimToAutoCommitCodes.zeroCash,
    );
  });

  test('🆕 R262 A-2(미결 233 ⓐ) — 다른 별칭 = 같은 계좌(종합계좌 · 상품코드) = ACCOUNT_DUPLICATE · 조회 다 있은 뒤 · 신선도 · 보유 앞 · 엔진 예약 코드', () {
    // 실전 칸에 연금저축 번호(-22)를 넣은 옛 꼴 — general · pension 이 같은 22 계좌를 봄.
    final String p22 = liveAccountMark(
      accountNo: '12345678',
      productCode: '22',
    );
    final String g01 = liveAccountMark(
      accountNo: '12345678',
      productCode: '01',
    );
    expect(
      _reject(
        probes: <LiveAccountProbe>[
          _p('general', mark: p22),
          _p('pension', mark: p22),
        ],
      ),
      SimToAutoCommitCodes.accountDuplicate,
    );
    // 신선도 · 보유 · 예수금보다 먼저(계좌 세트가 틀리면 그 계좌 사실을 볼 까닭이 없다).
    expect(
      _reject(
        probes: <LiveAccountProbe>[
          _p(
            'general',
            mark: p22,
            holdings: 2,
            at: _now.subtract(const Duration(minutes: 9)),
          ),
          _p('pension', mark: p22, cash: null),
        ],
      ),
      SimToAutoCommitCodes.accountDuplicate,
    );
    // 조회가 빠지면 = 조회 없음이 먼저.
    expect(
      _reject(probes: <LiveAccountProbe>[_p('general', mark: p22)]),
      SimToAutoCommitCodes.probeMissing,
    );
    // 같은 종합계좌의 위탁 01 · 연금저축 22 = 다른 계좌(통과).
    expect(
      _reject(
        probes: <LiveAccountProbe>[
          _p('general', mark: g01),
          _p('pension', mark: p22),
        ],
      ),
      isNull,
    );
    // 대응 밖 별칭의 같은 계좌는 보지 않는다(대응 계좌만 판정).
    expect(
      _reject(
        probes: <LiveAccountProbe>[
          _p('general', mark: g01),
          _p('pension', mark: p22),
          _p('isa', mark: g01),
        ],
      ),
      isNull,
    );
    expect(
      SimToAutoCommitCodes.accountDuplicate,
      'SIM_TO_AUTO_ACCOUNT_DUPLICATE',
    );
    // 🔵 엔진 예약 — 계약 사전 등재 = 다음 계약 창(그 전 화면 = headline 만).
    expect(
      SimToAutoCommitResultCodes.values,
      isNot(contains(SimToAutoCommitCodes.accountDuplicate)),
    );
    final String h = simToAutoCommitHeadline(
      SimToAutoCommitCodes.accountDuplicate,
    );
    expect(h, contains('같은 계좌'));
    expect(h, isNot(contains('12345678')));
  });

  test(
    '🆕 R262 계좌 표지 = 지문 + 상품코드(값 0) · 같은 계좌 = 같은 표지 · 상품코드 · 번호가 다르면 다름',
    () {
      final String a = liveAccountMark(
        accountNo: '12345678',
        productCode: '01',
      );
      expect(liveAccountMark(accountNo: ' 12345678 ', productCode: '01'), a);
      expect(
        liveAccountMark(accountNo: '12345678', productCode: '22'),
        isNot(a),
      );
      expect(
        liveAccountMark(accountNo: '87654321', productCode: '01'),
        isNot(a),
      );
      expect(a, isNot(contains('12345678')));
      expect(a, endsWith('-01'));
    },
  );

  test('🆕 f4a 리스 — 유효 아님 = LEASE_INVALID · 세대 · 기기 다름 = MISMATCH · 세션 뒤 · 이미 커밋 앞', () {
    LeaseSnapshot l(
      LeaseVerdict v, {
      int epoch = 1,
      String device = 'device-1',
    }) => LeaseSnapshot(verdict: v, epoch: epoch, deviceId: device);
    expect(simToAutoLeaseReject(_lease, _session()), isNull);
    expect(
      simToAutoLeaseReject(l(LeaseVerdict.invalid), _session()),
      'LEASE_INVALID',
    );
    expect(
      simToAutoLeaseReject(l(LeaseVerdict.unknown), _session()),
      'LEASE_INVALID',
    );
    expect(
      simToAutoLeaseReject(l(LeaseVerdict.valid, epoch: 2), _session()),
      SimToAutoCommitCodes.leaseMismatch,
    );
    expect(
      simToAutoLeaseReject(
        l(LeaseVerdict.valid, device: 'device-2'),
        _session(),
      ),
      SimToAutoCommitCodes.leaseMismatch,
    );
    // 세션이 먼저 · 리스가 이미 커밋보다 먼저.
    expect(
      _reject(noSession: true, lease: l(LeaseVerdict.unknown)),
      HandoverSessionCodes.sessionInvalid,
    );
    expect(_reject(rows: 1, lease: l(LeaseVerdict.unknown)), 'LEASE_INVALID');
    expect(
      _reject(rows: 1, lease: l(LeaseVerdict.valid, epoch: 0)),
      SimToAutoCommitCodes.leaseMismatch,
    );
    expect(SimToAutoCommitCodes.leaseMismatch, 'SIM_TO_AUTO_LEASE_MISMATCH');
    final Set<String> texts = <String>{
      simToAutoCommitHeadline('LEASE_INVALID'),
      simToAutoCommitHeadline(SimToAutoCommitCodes.leaseMismatch),
      simToAutoCommitHeadline('SOMETHING_ELSE'),
    };
    expect(texts, hasLength(3));
  });

  test('🆕 R192 승인 config(미결 205 ⓓ) — 없음 · 다른 판 = CONFIG_NOT_APPROVED · 이미 커밋 뒤 · 재판정 앞 · 엔진 예약 코드', () {
    expect(
      SimToAutoCommitCodes.configNotApproved,
      'SIM_TO_AUTO_CONFIG_NOT_APPROVED',
    );
    expect(
      simToAutoConfigApprovalReject(approvedConfigHash: 'h', configHash: 'h'),
      isNull,
    );
    expect(
      simToAutoConfigApprovalReject(approvedConfigHash: null, configHash: 'h'),
      SimToAutoCommitCodes.configNotApproved,
    );
    expect(
      simToAutoConfigApprovalReject(approvedConfigHash: 'g', configHash: 'h'),
      SimToAutoCommitCodes.configNotApproved,
    );
    expect(_reject(approved: null), SimToAutoCommitCodes.configNotApproved);
    expect(_reject(approved: 'cfg-0'), SimToAutoCommitCodes.configNotApproved);
    // 차례 — 시각 · 세션 · 리스 · 이미 커밋이 먼저 · 재판정(냉각) · 계좌 조회보다 먼저.
    expect(
      _reject(noNow: true, approved: null),
      SimToAutoCodes.trustedTimeUnavailable,
    );
    expect(
      _reject(noSession: true, approved: null),
      HandoverSessionCodes.sessionInvalid,
    );
    expect(
      _reject(
        approved: null,
        lease: const LeaseSnapshot(
          verdict: LeaseVerdict.unknown,
          epoch: 1,
          deviceId: 'device-1',
        ),
      ),
      'LEASE_INVALID',
    );
    expect(
      _reject(rows: 1, approved: null),
      SimToAutoCommitCodes.alreadyCommitted,
    );
    final DateTime cool = _k('2027-01-12', 20);
    expect(
      _reject(
        now: cool,
        report: _report(now: cool),
        approved: null,
      ),
      SimToAutoCommitCodes.configNotApproved,
    );
    expect(
      _reject(
        approved: null,
        probes: <LiveAccountProbe>[_p('general', holdings: 1), _p('pension')],
      ),
      SimToAutoCommitCodes.configNotApproved,
    );
    expect(
      simToAutoCommitHeadline(SimToAutoCommitCodes.configNotApproved),
      '지금 설정이 규칙 변경 승인을 받지 않아 확정하지 않았습니다 — 규칙 변경 게이트에서 승인(냉각 30일)을 받은 뒤 확정해 주세요.',
    );
  });

  test('통과 — 5분 정각 조회 · 대응 밖 계좌의 보유는 보지 않는다 · 한 계좌만 현금', () {
    expect(_reject(), isNull);
    expect(
      _reject(
        probes: <LiveAccountProbe>[
          _p('general', at: _now.subtract(kHandoverPlanStaleAfter)),
          _p('pension', at: _now),
          _p('isa', holdings: 5, activity: 3, cash: null),
        ],
      ),
      isNull,
    );
    expect(
      _reject(
        probes: <LiveAccountProbe>[_p('general'), _p('pension', cash: 0)],
      ),
      isNull,
    );
  });

  test('문구 — 성공 = 계좌 수 · 합계(쉼표) · 거부마다 다름 · DRY_RUN 글자 0', () {
    expect(
      simToAutoCommitHeadline(
        null,
        cash: const <String, int>{'general': 1234567, 'pension': 500000},
      ),
      '실전 자동 매매로 옮겼습니다 — 계좌 2곳 예수금 1,734,567원으로 개시했습니다. 실전은 주문 없이 관찰부터 시작합니다.',
    );
    expect(simToAutoCommitHeadline(null), contains('0원'));
    final List<String> codes = <String>[
      SimToAutoCodes.trustedTimeUnavailable,
      HandoverSessionCodes.sessionInvalid,
      SimToAutoCommitCodes.alreadyCommitted,
      SimToAutoCommitCodes.probeMissing,
      SimToAutoCommitCodes.snapshotStale,
      SimToAutoCommitCodes.holdingsNotZero,
      SimToAutoCommitCodes.brokerActivityToday,
      SimToAutoCommitCodes.cashUnknown,
      SimToAutoCommitCodes.zeroCash,
      SimToAutoCommitCodes.rolledBack,
      SimToAutoCommitCodes.configNotApproved,
      SimToAutoCodes.cooling,
    ];
    final Set<String> texts = <String>{
      for (final String c in codes) simToAutoCommitHeadline(c),
    };
    expect(texts, hasLength(codes.length));
    for (final String t in <String>[...texts, simToAutoCommitHeadline(null)]) {
      expect(t.contains('DRY_RUN'), isFalse);
    }
  });
}
