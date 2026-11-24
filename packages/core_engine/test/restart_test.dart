// R248 — R-01 기존 계정에서 다시 시작 VM(`restartVmOf`) · o_07 로그인 지점(`supabaseSignInStageOf`).
//
// 🔵 잡는 것: ① 표본 4벌(`m8/restart_vm_*`) = 엔진 출력 그대로 ② 판정표 칸마다(로그인 전 · 원장 못 읽음 · 리스 행 없음 ·
//    쥔 기기 안 보임 · 신뢰 시각 모름 · 리스 살아 있음 · 끝남 + 갭 안 · 끝남 + 갭 기준 이상(경계 = KST 달력일) · 기준 모름 ·
//    이 폰이 쥠 ± 비상 회수 기록) ③ C-50 ⑬ 불변식(로그인 자리 ⇒ 나머지 0 · 모름 ⇒ 분기 0 · 분기 ⇒ 승계 고지 · 목적지 3)
//    ④ 글자 꼴(남은 시간 · 플랫폼) ⑤ o_07 지점 = 상세 VM 과 같은 칸 · 글자 · 동작.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

RestartVm _fixture(String name) => RestartVm.fromJson(
  ((jsonDecode(
                File('../domain_contracts/fixtures/m8/$name.json')
                    .readAsStringSync(),
              ) as Map<String, Object?>)['rows']!
              as List<Object?>)
          .single!
      as Map<String, dynamic>,
);

/// 한국 시각 → UTC.
DateTime _kst(int y, int mo, int d, int h, int mi) =>
    DateTime.utc(y, mo, d, h, mi).subtract(const Duration(hours: 9));

const String _me = 'dev-new-phone';
const String _old = 'dev-old-phone';

RestartDevice _oldPhone({DateTime? seen, String? platform = 'android'}) =>
    RestartDevice(
      deviceId: _old,
      label: '거실 폰',
      status: 'ACTIVE',
      platform: platform,
      lastSeenAtUtc: seen,
    );

RestartFacts _facts({
  RestartDevice? old,
  DateTime? expires,
  DateTime? now,
  int? gap = 7,
  String holder = _old,
  List<RestartDevice> more = const <RestartDevice>[],
  bool emergency = false,
  bool claimed = false,
  bool lease = true,
}) => RestartFacts(
  signedIn: true,
  ledger: RestartLedger(
    devices: <RestartDevice>[?old, ...more],
    lease: lease
        ? RestartLease(
            deviceId: holder,
            epoch: 3,
            expiresAtUtc: expires ?? DateTime.utc(2026, 8, 31, 3),
          )
        : null,
  ),
  thisDeviceId: _me,
  trustedNowUtc: now,
  backupGapDays: gap,
  emergencyStarted: emergency,
  firstClaimRecorded: claimed,
);

List<String> _links(RestartVm vm) =>
    vm.branches.map((LinkAction b) => b.deepLink).toList();

void main() {
  final DateTime now = DateTime.utc(2026, 8, 31); // 한국 09:00

  group('표본 = 엔진', () {
    test(
      '🔴 로그인 전 = `restart_vm_logged_out`(자리 하나 · 원장 · 게이트 · 분기 · 고지 0)',
      () {
        expect(
          restartVmOf(const RestartFacts(signedIn: false)),
          _fixture('restart_vm_logged_out'),
        );
        // 로그인 전이면 원장 · 시각이 있어도 보이지 않는다.
        expect(
          restartVmOf(
            RestartFacts(
              signedIn: false,
              ledger: const RestartLedger(
                devices: <RestartDevice>[],
                lease: null,
              ),
              trustedNowUtc: now,
            ),
          ),
          _fixture('restart_vm_logged_out'),
        );
      },
    );

    test('🔴 구 폰 리스 살아 있음 = `restart_vm_lost_phone`(계획 · 비상 · 승계 고지)', () {
      expect(
        restartVmOf(
          _facts(
            old: _oldPhone(seen: _kst(2026, 8, 29, 21, 40)),
            expires: now.add(const Duration(hours: 3, minutes: 10)),
            now: now,
          ),
        ),
        _fixture('restart_vm_lost_phone'),
      );
    });

    test(
      '🔴 리스 끝남 + 마지막 접속 갭 ≥ 기준 = `restart_vm_gap7`(신규 온보딩 + 잔고 승계 · BLOCK)',
      () {
        expect(
          restartVmOf(
            _facts(
              old: _oldPhone(seen: _kst(2026, 8, 20, 8, 10)),
              expires: _kst(2026, 8, 20, 8, 40),
              now: now,
            ),
          ),
          _fixture('restart_vm_gap7'),
        );
      },
    );

    test('🔴 마지막 접속 모름 · 시각 모름 = `restart_vm_unknown`(분기 0)', () {
      expect(
        restartVmOf(_facts(old: _oldPhone(), now: null)),
        _fixture('restart_vm_unknown'),
      );
      // 리스 끝남 + 마지막 접속 모름 = 갭을 셀 수 없다 → 같은 모름.
      expect(
        restartVmOf(
          _facts(
            old: _oldPhone(),
            expires: now.subtract(const Duration(minutes: 1)),
            now: now,
          ),
        ),
        _fixture('restart_vm_unknown'),
      );
    });
  });

  group('판정표', () {
    test('원장을 못 읽음 = 모름(사실 문장 · 분기 0)', () {
      final RestartVm vm = restartVmOf(const RestartFacts(signedIn: true));
      expect(vm.loginSlotId, isNull);
      expect(vm.ledgerLines, <String>[RestartTexts.ledgerUnread]);
      expect(vm.leaseGate!.state, GateState.unknown);
      expect(vm.branches, isEmpty);
      expect(vm.inheritNotice, isNull);
    });

    test('리스 행 없음 = 이어받을 기기 없음(해당 없음 · 분기 0 · 고지 0)', () {
      final RestartVm vm = restartVmOf(
        _facts(
          old: _oldPhone(seen: now),
          now: now,
          lease: false,
        ),
      );
      expect(vm.ledgerLines, <String>[RestartTexts.noOperator]);
      expect(vm.leaseGate!.state, GateState.notApplicable);
      expect(vm.leaseGate!.label, RestartTexts.gateNoOperator);
      expect(vm.branches, isEmpty);
      expect(vm.inheritNotice, isNull);
    });

    test('리스를 쥔 기기가 원장에 안 보임 = 모름', () {
      final RestartVm vm = restartVmOf(
        _facts(
          old: _oldPhone(seen: now),
          now: now,
          holder: 'dev-elsewhere',
        ),
      );
      expect(vm.ledgerLines, <String>[RestartTexts.holderUnseen]);
      expect(vm.leaseGate!.state, GateState.unknown);
      expect(vm.branches, isEmpty);
    });

    test('신뢰 시각 모름 = 모름(마지막 접속은 보인다)', () {
      final RestartVm vm = restartVmOf(
        _facts(old: _oldPhone(seen: _kst(2026, 8, 30, 10, 0)), now: null),
      );
      expect(vm.ledgerLines, <String>[
        '구 폰: 거실 폰(Android)',
        '마지막 접속: 2026-08-30 10:00',
      ]);
      expect(vm.leaseGate!.state, GateState.unknown);
      expect(vm.branches, isEmpty);
    });

    test('리스 살아 있음 = 갭 기준을 몰라도 계획 · 비상', () {
      final RestartVm vm = restartVmOf(
        _facts(
          old: _oldPhone(seen: now.subtract(const Duration(minutes: 5))),
          expires: now.add(const Duration(minutes: 25)),
          now: now,
          gap: null,
        ),
      );
      expect(vm.leaseGate!.state, GateState.pass);
      expect(vm.ledgerLines!.last, '리스 남은 시간: 약 25분');
      expect(_links(vm), <String>[
        AppRoutes.x1MigrationPlan,
        AppRoutes.x1MigrationEmergency,
      ]);
      expect(vm.inheritNotice, RestartTexts.inherit);
    });

    test('🔴 갭 경계 = 한국 달력일 — 6일 = 계획 · 비상(끝남 줄) · 7일 = 신규 온보딩', () {
      final DateTime ended = now.subtract(const Duration(days: 1));
      final RestartVm six = restartVmOf(
        _facts(
          old: _oldPhone(seen: _kst(2026, 8, 25, 0, 0)),
          expires: ended,
          now: now,
        ),
      );
      expect(six.leaseGate!.state, GateState.pass);
      expect(six.ledgerLines!.last, RestartTexts.leaseEnded);
      expect(_links(six), <String>[
        AppRoutes.x1MigrationPlan,
        AppRoutes.x1MigrationEmergency,
      ]);
      final RestartVm seven = restartVmOf(
        _facts(
          old: _oldPhone(seen: _kst(2026, 8, 24, 23, 59)),
          expires: ended,
          now: now,
        ),
      );
      expect(seven.leaseGate!.state, GateState.block);
      expect(seven.ledgerLines!.last, '마지막 접속 뒤 7일이 지났습니다');
      // 🆕 계약 v1.39(앱 01 §48 K349 ⑤ ⑥) — 비상 이전 먼저 · 이어받지 않음 고지.
      expect(_links(seven), <String>[AppRoutes.x1MigrationEmergency]);
      expect(seven.inheritNotice, RestartTexts.freshNotice);
    });

    test('갭 기준 = 운영 설정 값 그대로(글자도 그 값)', () {
      final RestartVm vm = restartVmOf(
        _facts(
          old: _oldPhone(seen: _kst(2026, 8, 28, 9, 0)),
          expires: now.subtract(const Duration(days: 2)),
          now: now,
          gap: 3,
        ),
      );
      expect(vm.leaseGate!.state, GateState.block);
      expect(vm.ledgerLines!.last, '마지막 접속 뒤 3일이 지났습니다');
    });

    test('리스 끝남 + 갭 기준 모름 = 모름', () {
      final RestartVm vm = restartVmOf(
        _facts(
          old: _oldPhone(seen: _kst(2026, 8, 30, 9, 0)),
          expires: now.subtract(const Duration(hours: 1)),
          now: now,
          gap: null,
        ),
      );
      expect(vm.leaseGate!.state, GateState.unknown);
      expect(vm.branches, isEmpty);
    });

    test('🔴 이 폰이 쥠 · 비상 회수 기록 없음 · 첫 클레임 기록 있음 = 해당 없음 · 분기 0(이미 운영 기기)', () {
      final RestartVm vm = restartVmOf(
        _facts(
          old: _oldPhone(seen: now),
          now: now,
          holder: _me,
          claimed: true,
        ),
      );
      expect(vm.ledgerLines, <String>[RestartTexts.thisPhoneHolds]);
      expect(vm.leaseGate!.state, GateState.notApplicable);
      expect(vm.leaseGate!.label, RestartTexts.gateThisPhone);
      expect(vm.branches, isEmpty);
      expect(vm.inheritNotice, isNull);
    });

    test(
      '🔴 이 폰이 쥠 + 비상 회수 기록 = «비상 이전 이어 하기»(구 폰 = 회수된 기기 중 마지막 접속이 늦은 것)',
      () {
        RestartDevice revoked(String id, String label, DateTime? seen) =>
            RestartDevice(
              deviceId: id,
              label: label,
              status: kDeviceStatusRevoked,
              platform: 'android',
              lastSeenAtUtc: seen,
            );
        final RestartVm vm = restartVmOf(
          _facts(
            now: now,
            holder: _me,
            emergency: true,
            more: <RestartDevice>[
              revoked('dev-a', '옛 폰 A', _kst(2026, 3, 1, 9, 0)),
              revoked('dev-b', '거실 폰', _kst(2026, 8, 29, 21, 40)),
              revoked('dev-c', '옛 폰 C', null),
              RestartDevice(
                deviceId: _me,
                label: '운영 폰',
                status: kDeviceStatusRevoked,
                lastSeenAtUtc: now,
              ),
            ],
          ),
        );
        expect(vm.ledgerLines, <String>[
          '구 폰: 거실 폰(Android)',
          '마지막 접속: 2026-08-29 21:40',
          RestartTexts.thisPhoneHolds,
        ]);
        expect(vm.leaseGate!.state, GateState.pass);
        expect(vm.branches, const <LinkAction>[
          LinkAction(
            label: RestartTexts.branchEmergencyResume,
            deepLink: AppRoutes.x1MigrationEmergency,
          ),
        ]);
        expect(vm.inheritNotice, RestartTexts.inherit);
        // 회수된 다른 기기가 없으면 구 폰 줄 0 · 링크는 그대로.
        final RestartVm bare = restartVmOf(
          _facts(now: now, holder: _me, emergency: true),
        );
        expect(bare.ledgerLines, <String>[RestartTexts.thisPhoneHolds]);
        expect(_links(bare), <String>[AppRoutes.x1MigrationEmergency]);
      },
    );

    // 🆕 리뷰 3차 D-04(미결 236 ⓓ · R267) — 서버가 lease_revoke 를 커밋했는데 응답을 잃음 → 이 폰에 회수 기록 0 · 첫 클레임 기록 0.
    test(
      '🔴 이 폰이 쥠 · 회수 기록 0 · 첫 클레임 기록 0(회수 응답 유실) = «비상 이전 이어 하기» + 새 카드 안내',
      () {
        final RestartVm vm = restartVmOf(
          _facts(
            now: now,
            holder: _me,
            more: <RestartDevice>[
              RestartDevice(
                deviceId: 'dev-b',
                label: '거실 폰',
                status: kDeviceStatusRevoked,
                platform: 'android',
                lastSeenAtUtc: _kst(2026, 8, 29, 21, 40),
              ),
            ],
          ),
        );
        expect(vm.ledgerLines, <String>[
          '구 폰: 거실 폰(Android)',
          '마지막 접속: 2026-08-29 21:40',
          RestartTexts.thisPhoneHolds,
          RestartTexts.revokeAnswerLost,
        ]);
        expect(vm.leaseGate!.state, GateState.pass);
        expect(_links(vm), <String>[AppRoutes.x1MigrationEmergency]);
        expect(vm.inheritNotice, RestartTexts.inherit);
        // 회수 기록이 있으면 안내 줄 0(그 기록이 이어 하기의 근거).
        final RestartVm done = restartVmOf(
          _facts(now: now, holder: _me, emergency: true),
        );
        expect(
          done.ledgerLines,
          isNot(contains(RestartTexts.revokeAnswerLost)),
        );
        // 첫 클레임 대기 · 실행됨 = 이미 운영 기기(분기 0) — 아래 «첫 클레임 기록 있음».
        expect(
          restartVmOf(_facts(now: now, holder: _me, claimed: true)).branches,
          isEmpty,
        );
      },
    );

    test('이 폰 id 를 모르면 «이 폰이 쥠»으로 보지 않는다', () {
      final RestartVm vm = restartVmOf(
        RestartFacts(
          signedIn: true,
          ledger: RestartLedger(
            devices: <RestartDevice>[_oldPhone(seen: now)],
            lease: RestartLease(
              deviceId: _old,
              epoch: 1,
              expiresAtUtc: now.add(const Duration(minutes: 10)),
            ),
          ),
          trustedNowUtc: now,
          backupGapDays: 7,
          emergencyStarted: true,
        ),
      );
      expect(_links(vm), <String>[
        AppRoutes.x1MigrationPlan,
        AppRoutes.x1MigrationEmergency,
      ]);
    });
  });

  test('🔴 C-50 ⑬ 불변식 — 엔진이 내는 VM 전부', () {
    final List<RestartVm> all = <RestartVm>[
      restartVmOf(const RestartFacts(signedIn: false)),
      restartVmOf(const RestartFacts(signedIn: true)),
      for (final int? gap in <int?>[null, 7])
        for (final DateTime? t in <DateTime?>[null, now])
          for (final DateTime exp in <DateTime>[
            now.add(const Duration(minutes: 20)),
            now.subtract(const Duration(days: 1)),
          ])
            for (final DateTime? seen in <DateTime?>[
              null,
              now.subtract(const Duration(days: 1)),
              now.subtract(const Duration(days: 30)),
            ])
              for (final String holder in <String>[_old, _me, 'dev-x'])
                for (final bool e in <bool>[false, true])
                  for (final bool c in <bool>[false, true])
                    restartVmOf(
                      _facts(
                        old: _oldPhone(seen: seen),
                        expires: exp,
                        now: t,
                        gap: gap,
                        holder: holder,
                        emergency: e,
                        claimed: c,
                      ),
                    ),
      restartVmOf(_facts(old: _oldPhone(), now: now, lease: false)),
    ];
    const Set<String> allowed = <String>{
      AppRoutes.x1MigrationPlan,
      AppRoutes.x1MigrationEmergency,
      AppRoutes.onboardingModePick,
    };
    final Set<GateState> seen = <GateState>{};
    for (final RestartVm vm in all) {
      expect(vm.headline, RestartTexts.headline);
      if (vm.loginSlotId != null) {
        expect(vm.loginSlotId, OnboardingSlotIds.recoveryLogin);
        expect(vm.ledgerLines, isNull);
        expect(vm.leaseGate, isNull);
        expect(vm.branches, isEmpty);
        expect(vm.inheritNotice, isNull);
      } else {
        expect(vm.ledgerLines, isNotEmpty);
        expect(vm.leaseGate, isNotNull);
        expect(vm.leaseGate!.code, kRestartLeaseGateCode);
        seen.add(vm.leaseGate!.state);
      }
      if (vm.leaseGate?.state == GateState.unknown) {
        expect(vm.branches, isEmpty);
      }
      expect(vm.branches.isNotEmpty, vm.inheritNotice != null);
      for (final LinkAction b in vm.branches) {
        expect(allowed, contains(b.deepLink));
      }
      // 🔴 «초기화» 선택지 0.
      expect(
        vm.branches.where((LinkAction b) => b.label.contains('초기화')),
        isEmpty,
      );
    }
    expect(seen, GateState.values.toSet());
  });

  test('글자 꼴 — 남은 시간 · 플랫폼', () {
    expect(
      RestartTexts.leaseLeft(const Duration(minutes: 59, seconds: 59)),
      '리스 남은 시간: 약 59분',
    );
    expect(
      RestartTexts.leaseLeft(const Duration(minutes: 61)),
      '리스 남은 시간: 약 1시간',
    );
    expect(
      RestartTexts.leaseLeft(const Duration(seconds: 30)),
      '리스 남은 시간: 1분 미만',
    );
    expect(RestartTexts.oldPhone('a', null), '구 폰: a');
    expect(RestartTexts.oldPhone('a', 'ios'), '구 폰: a(iOS)');
    expect(RestartTexts.oldPhone('a', 'web'), '구 폰: a(web)');
    expect(RestartTexts.lastSeen(null), RestartTexts.lastSeenUnknown);
  });

  test('🔴 R-01 로그인 지점 = o_07 상세와 같은 칸 · 글자 · 동작(연결 전 ② · 연결 뒤 ③)', () {
    OnboardingStepDetailVm detail(StepState? s) => onboardingStepDetailVmOf(
      stepId: 'o_07',
      mode: OperatingMode.autoTrade,
      facts: <String, OnboardingStepFact>{
        if (s != null) 'o_07': OnboardingStepFact(state: s),
      },
      nowUtc: now,
    );
    for (final (bool connected, StepState? s) in <(bool, StepState?)>[
      (false, null),
      (true, StepState.inProgress),
    ]) {
      final SupabaseSignInStage st = supabaseSignInStageOf(
        connected: connected,
      );
      final OnboardingStepDetailVm d = detail(s);
      expect(st.slotId, d.secretSlotId);
      expect(st.whereText, d.whereText);
      expect(st.howText, d.howText);
      expect(st.submit, d.verify);
    }
    expect(
      supabaseSignInStageOf(connected: false).slotId,
      OnboardingSlotIds.supabaseConnect,
    );
    expect(
      supabaseSignInStageOf(connected: true).submit.id,
      SettingsActionId.supabaseSignIn,
    );
  });
}
