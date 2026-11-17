// E11p3d-5h — M9 S06 기기 · 접근 관리 VM(설계 13 §8 R146) · 표본 = domain_contracts `m9/device_access*`.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

// 2026-12-01 09:00 KST.
final DateTime _now = DateTime.utc(2026, 12, 1);
const String _id = '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e';

bool _none(String _) => false;

DeviceAccessVm _vm({
  LeaseVerdict lease = LeaseVerdict.valid,
  RunMode run = RunMode.simInternal,
  bool Function(String) hasBody = _none,
}) => deviceAccessVmOf(
  DeviceAccessFacts(
    deviceId: _id,
    runMode: run,
    lease: lease,
    hasBody: hasBody,
  ),
  nowUtc: _now,
);

Map<String, Object?> _fx(String name) {
  final Map<String, Object?> env = jsonDecode(
    File('../domain_contracts/fixtures/m9/$name.json').readAsStringSync(),
  ) as Map<String, Object?>;
  return (env['rows']! as List<Object?>).first! as Map<String, Object?>;
}

void main() {
  test(
    '🔴 기기 = 이 폰(운영) 한 행 · 조회 전용 0대 = 표본 빈 줄 · 폐기 버튼 0 · 기기 id = 그대로(화면 미참조)',
    () {
      final DeviceAccessVm vm = _vm();
      expect(vm.devices, hasLength(1));
      final DeviceRow phone = vm.devices.single;
      expect(phone.deviceId, _id);
      expect(
        (phone.label, phone.roleLabel, phone.lastSeenText),
        ('이 폰(운영)', '운영 기기', '지금'),
      );
      expect(phone.revokeAction, isNull);
      expect(phone.revokeConfirmText, isNull);
      expect(vm.emptyLabel, _fx('device_access_no_viewers')['empty_label']);
    },
  );

  test('🔴 리스 유효(모의 = 이 폰 단독) = OK · 이 폰 «사용 중» · 다른 모드 유효 = «유효»', () {
    final DeviceAccessVm vm = _vm();
    expect(
      (vm.leaseHolderLabel, vm.leaseStateLabel, vm.leaseLevel),
      ('이 폰(운영)', '유효 — 이 폰 단독 리스(모의)', UiLevel.ok),
    );
    expect(
      (vm.devices.single.statusLabel, vm.devices.single.level),
      ('사용 중', UiLevel.ok),
    );
    expect(_vm(run: RunMode.live).leaseStateLabel, '유효');
    expect(_vm(run: RunMode.simBroker).leaseStateLabel, '유효');
  });

  test(
    '🔴 리스 무효(봉인) · 모름(서버 연결 전) = BLOCKED · 이 폰 = 주문 멈춤/대기 WATCH(주문을 막는 그 판정)',
    () {
      final DeviceAccessVm sealed = _vm(lease: LeaseVerdict.invalid);
      expect(
        (sealed.leaseHolderLabel, sealed.leaseStateLabel, sealed.leaseLevel),
        ('없음 — 리스가 봉인됐습니다', '무효 — 주문이 멈춰 있습니다', UiLevel.blocked),
      );
      expect(
        (sealed.devices.single.statusLabel, sealed.devices.single.level),
        ('주문 멈춤 — 리스 없음', UiLevel.watch),
      );
      final DeviceAccessVm unknown = _vm(
        lease: LeaseVerdict.unknown,
        run: RunMode.live,
      );
      expect(
        (unknown.leaseHolderLabel, unknown.leaseStateLabel, unknown.leaseLevel),
        ('확인할 수 없음', '확인 불가 — 운영 리스 서버 연결 전이라 주문이 막힙니다', UiLevel.blocked),
      );
      expect(
        (unknown.devices.single.statusLabel, unknown.devices.single.level),
        ('주문 대기 — 리스를 확인할 수 없음', UiLevel.watch),
      );
    },
  );

  test('🔴 원천 전 칸 = 없음(세대 · 남은 시간 · QR 페어링 · 잠김) · 기기 이전 링크 = 본문 있을 때만', () {
    final DeviceAccessVm vm = _vm();
    expect(vm.leaseEpochText, isNull);
    expect(vm.leaseEtaText, isNull);
    expect(vm.pairing, isNull);
    expect(vm.lockedLabel, isNull);
    expect(vm.migrationLink, isNull);
    expect(
      _vm(hasBody: (String r) => r == AppRoutes.x1Migration).migrationLink,
      const LinkAction(
        label: '기기 이전 · 강등 · 비상 복구',
        deepLink: AppRoutes.x1Migration,
      ),
    );
    expect(
      _vm(hasBody: (String r) => r != AppRoutes.x1Migration).migrationLink,
      isNull,
    );
  });

  test('기준 = 지금 · 26시간 · KST 글자', () {
    final AsOf a = _vm().asOf;
    expect(a.observedAt, _now);
    expect(a.tradeDate, const TradeDate('2026-12-01'));
    expect(a.source, AsOfSource.localSqlite);
    expect(a.staleAfter, const Duration(seconds: 93600));
    expect(a.label, '기기 기준 2026-12-01 09:00');
  });

  test('표본과 같은 꼴 — VM · 기기 행 JSON 키가 `device_access` 와 같다(값 없는 선택 칸 제외)', () {
    final Map<String, Object?> fx = _fx('device_access');
    final Map<String, Object?> ours = jsonDecode(
      jsonEncode(
        _vm(hasBody: (String r) => r == AppRoutes.x1Migration).toJson(),
      ),
    ) as Map<String, Object?>;
    expect(ours.keys.toSet(), fx.keys.toSet());
    Map<String, Object?> first(Map<String, Object?> m) =>
        (m['devices']! as List<Object?>).first! as Map<String, Object?>;
    expect(first(ours).keys.toSet(), first(fx).keys.toSet());
    // 표본의 이 폰 행 글자와 같다(조회 전용 · 리스 글자는 엔진 상황에 따라 다르다).
    expect(first(ours)['label'], first(fx)['label']);
    expect(first(ours)['role_label'], first(fx)['role_label']);
    expect(ours['migration_link'], fx['migration_link']);
  });
}
