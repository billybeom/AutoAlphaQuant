// E11p3d-2c — H-03 물리 리스크 점검(설계 13 §8 R135) · 표본 = domain_contracts `m8/device_risk_*`.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

// 2026-11-17 08:55 KST.
final DateTime _at = DateTime.utc(2026, 11, 16, 23, 55);

DeviceRiskVm _vm({
  int? free,
  String? health,
  int? cycles,
  int? temp,
  String? patch,
  DateTime? now,
}) => deviceRiskVmOf(
  DeviceRiskFacts(
    measuredAtUtc: _at,
    storageFreeBytes: free,
    batteryHealth: health,
    batteryCycleCount: cycles,
    batteryTempTenthsC: temp,
    securityPatch: patch,
  ),
  nowUtc: now ?? _at,
);

DeviceRiskItem _one(DeviceRiskVm vm) => vm.rows.single;

Map<String, Object?> _fx(String name) {
  final Map<String, Object?> env = jsonDecode(
    File('../domain_contracts/fixtures/m8/$name.json').readAsStringSync(),
  ) as Map<String, Object?>;
  return (env['rows']! as List<Object?>).first! as Map<String, Object?>;
}

void main() {
  test('🔴 저장공간 — 띠 넷(4GB 이상 OK · 2~4GB WATCH · 2GB 미만 ACT · 0.5GB 미만 BLOCKED) · 경계 = 미만', () {
    DeviceRiskItem at(int b) => _one(_vm(free: b));
    expect(at(3100000000).currentText, '남은 공간 3.1GB');
    expect(at(3100000000).thresholdText, '임계 2GB 미만');
    expect(at(3100000000).level, UiLevel.watch);
    expect(at(3100000000).actionText, '여유가 줄고 있습니다 — 정리 일정을 잡으세요');
    expect(at(4000000000).level, UiLevel.ok);
    expect(at(4000000000).actionText, '조치 필요 없음');
    expect(at(3999999999).level, UiLevel.watch);
    expect(at(2000000000).level, UiLevel.watch);
    expect(at(1999999999).level, UiLevel.act);
    expect(at(1999999999).actionText, '사진·동영상 등 다른 앱 데이터를 정리해 2GB 넘게 비우세요');
    expect(at(500000000).level, UiLevel.act);
    expect(at(499999999).level, UiLevel.blocked);
    expect(at(400000000).currentText, '남은 공간 400MB');
    expect(at(400000000).label, '저장공간');
  });

  test('바이트 · 온도 글자 — 10진 · 소수 한 자리 내림 · «.0» 없음', () {
    expect(deviceBytesText(999999999), '999MB');
    expect(deviceBytesText(1000000000), '1GB');
    expect(deviceBytesText(1099999999), '1GB');
    expect(deviceBytesText(1100000000), '1.1GB');
    expect(deviceBytesText(12345678901), '12.3GB');
    expect(deviceTempText(365), '36.5도');
    expect(deviceTempText(450), '45도');
    expect(deviceTempText(-5), '-0.5도');
  });

  test('🔴 배터리 열화 — 충전 횟수 띠(500 WATCH · 800 ACT) · 상태 이상 = ACT · 저온 = WATCH · 모르는 상태 = 고장 신호', () {
    DeviceRiskItem at({String? h, int? c}) => _one(_vm(health: h, cycles: c));
    final DeviceRiskItem good = at(h: DeviceBatteryHealth.good, c: 312);
    expect(good.currentText, '충전 312회 · 상태 양호');
    expect(good.thresholdText, '임계 충전 800회 또는 상태 이상');
    expect((good.level, good.actionText), (UiLevel.ok, '조치 필요 없음'));
    expect(at(h: DeviceBatteryHealth.good, c: 499).level, UiLevel.ok);
    expect(at(h: DeviceBatteryHealth.good, c: 500).level, UiLevel.watch);
    expect(at(h: DeviceBatteryHealth.good, c: 799).level, UiLevel.watch);
    expect(at(h: DeviceBatteryHealth.good, c: 800).level, UiLevel.act);
    expect(
      at(h: DeviceBatteryHealth.good, c: 800).actionText,
      '배터리 교체 또는 예비 폰 준비를 계획하세요',
    );
    for (final String bad in <String>[
      DeviceBatteryHealth.dead,
      DeviceBatteryHealth.overVoltage,
      DeviceBatteryHealth.failure,
      'SOMETHING_NEW',
    ]) {
      expect(at(h: bad, c: 10).level, UiLevel.act, reason: bad);
    }
    expect(at(h: 'SOMETHING_NEW').currentText, '고장 신호(충전 횟수 모름)');
    expect(at(h: DeviceBatteryHealth.dead).currentText, '수명 다함(충전 횟수 모름)');
    final DeviceRiskItem hot = at(h: DeviceBatteryHealth.overheat, c: 10);
    expect((hot.level, hot.currentText), (UiLevel.act, '충전 10회 · 과열'));
    expect(hot.actionText, '충전기를 빼고 식히세요 — 되풀이되면 배터리 교체를 계획하세요');
    final DeviceRiskItem cold = at(h: DeviceBatteryHealth.cold, c: 10);
    expect((cold.level, cold.actionText), (UiLevel.watch, '따뜻한 실내에 두세요'));
    // 저온이라도 충전 횟수가 임계면 ACT(더 무거운 쪽).
    expect(at(h: DeviceBatteryHealth.cold, c: 900).level, UiLevel.act);
    expect(at(h: DeviceBatteryHealth.good).currentText, '상태 양호(충전 횟수 모름)');
    expect(at(c: 900).currentText, '충전 900회');
    expect(at(c: 900).level, UiLevel.act);
    expect(at(h: DeviceBatteryHealth.good, c: 10).label, '배터리 열화');
  });

  test(
    '🔴 OS 보안 패치 — 나이(한국 날짜) 92일 넘음 WATCH · 183일 넘음 ACT · 못 읽은 날짜 = 행 부재',
    () {
      // 지금 = 2026-11-17(KST).
      DeviceRiskItem at(String p) => _one(_vm(patch: p));
      final DeviceRiskItem fresh = at('2026-10-05');
      expect(fresh.currentText, '보안 패치 2026-10-05');
      expect(fresh.thresholdText, '임계 패치가 6개월 넘게 멈춤');
      expect(fresh.level, UiLevel.ok);
      expect(fresh.label, 'OS 보안 패치');
      expect(at('2026-08-17').level, UiLevel.ok); // 92일
      expect(at('2026-08-16').level, UiLevel.watch); // 93일
      expect(at('2026-08-16').actionText, '시스템 업데이트가 있는지 확인하세요');
      expect(at('2026-05-18').level, UiLevel.watch); // 183일
      expect(at('2026-05-17').level, UiLevel.act); // 184일
      expect(
        at('2026-05-17').actionText,
        '제조사 보안 지원이 끝났을 수 있습니다 — 새 폰 이전 일정을 잡으세요(X1 기기 이전)',
      );
      expect(at(' 2026-10-05 ').currentText, '보안 패치 2026-10-05');
      expect(_vm(patch: '2026-10').rows, isEmpty);
      expect(_vm(patch: '').rows, isEmpty);
      // 나이 = 측정 시각이 아니라 지금(오래 둔 측정이 «신선한 패치»로 남지 않게).
      expect(
        _one(_vm(patch: '2026-10-05', now: DateTime.utc(2027, 4, 7))).level,
        UiLevel.act,
      );
    },
  );

  test('🔴 기기 온도 — 40도부터 WATCH · 45도 넘음 ACT', () {
    DeviceRiskItem at(int t) => _one(_vm(temp: t));
    expect(at(365).currentText, '현재 36.5도');
    expect(at(365).thresholdText, '임계 45도 넘음');
    expect(at(399).level, UiLevel.ok);
    expect(at(400).level, UiLevel.watch);
    expect(at(400).actionText, '통풍이 되는 곳에 두세요');
    expect(at(450).level, UiLevel.watch);
    expect(at(451).level, UiLevel.act);
    expect(at(470).actionText, '충전기를 빼고 그늘로 옮기세요');
    expect(at(470).label, '기기 온도');
  });

  test('🔴 차례 = 저장공간 → 배터리 → 보안 패치 → 온도 · 잰 것만 · 0행 = 빈 줄(표본 문장)', () {
    final DeviceRiskVm all = _vm(
      free: 5000000000,
      health: DeviceBatteryHealth.good,
      cycles: 100,
      patch: '2026-11-01',
      temp: 300,
    );
    expect(all.rows.map((DeviceRiskItem r) => r.label).toList(), <String>[
      '저장공간',
      '배터리 열화',
      'OS 보안 패치',
      '기기 온도',
    ]);
    expect(all.emptyLabel, isNull);
    expect(
      all.rows.map((DeviceRiskItem r) => r.lastCheckedText).toSet(),
      <String>{'마지막 점검 11-17 08:55'},
    );
    expect(_vm(free: 5000000000, temp: 300).rows.length, 2);
    final DeviceRiskVm none = _vm();
    expect(none.rows, isEmpty);
    expect(none.emptyLabel, _fx('device_risk_empty')['empty_label']);
    expect(none.guidanceText, _fx('device_risk_empty')['guidance_text']);
  });

  test('기준 = 잰 시각 · 26시간 · KST 글자 · 오래됨 글자(표본)', () {
    final AsOf a = _vm(free: 5000000000).asOf;
    expect(a.observedAt, _at);
    expect(a.tradeDate, const TradeDate('2026-11-17'));
    expect(a.source, AsOfSource.localSqlite);
    expect(a.staleAfter, const Duration(seconds: 93600));
    expect(a.label, '기기 점검 기준 2026-11-17 08:55');
    expect(
      a.staleLabel,
      (_fx('device_risk_items')['as_of']!
          as Map<String, Object?>)['stale_label'],
    );
  });

  test(
    '표본과 같은 꼴 — VM · 항목 · 기준 JSON 키가 `device_risk_items` 와 같다 · 안내 = 표본 문장',
    () {
      final Map<String, Object?> fx = _fx('device_risk_items');
      final Map<String, Object?> ours = jsonDecode(
        jsonEncode(
          _vm(
            free: 5000000000,
            health: DeviceBatteryHealth.good,
            cycles: 1,
            patch: '2026-11-01',
            temp: 300,
          ).toJson(),
        ),
      ) as Map<String, Object?>;
      expect(ours.keys.toSet(), fx.keys.toSet());
      Map<String, Object?> first(Map<String, Object?> m) =>
          (m['rows']! as List<Object?>).first! as Map<String, Object?>;
      expect(first(ours).keys.toSet(), first(fx).keys.toSet());
      // 기준 = 표본 키 전부 + 값 없는 선택 칸(`stale_reason_code` — 표본은 null 칸을 적지 않았다).
      final Map<String, Object?> asOf = ours['as_of']! as Map<String, Object?>;
      expect(
        asOf.keys.where((String k) => asOf[k] != null).toSet(),
        (fx['as_of']! as Map<String, Object?>).keys.toSet(),
      );
      expect(ours['guidance_text'], fx['guidance_text']);
    },
  );
}
