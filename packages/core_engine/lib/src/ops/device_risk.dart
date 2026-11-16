// E11p3d-2c — `H-03` 물리 리스크 점검(설계 13 §8 R136 · 발주자 «H-03 맡아» 2026-11-17 · 앱 04 §4-6 · 01 §26 K17).
//
// 🔴 측정 = 플랫폼 API(조립 앱) · 임계 · 판정 · 문구 = 여기(엔진) — 화면은 비교 · 남은 일수 계산을 하지 않는다.
// 🔴 잰 값이 없는 항목은 싣지 않는다(지어내지 않는다) — 0행 = 빈 줄(엔진 문장).
// 🔵 임계는 잠정(R136) — 운영 폰 실측 뒤 바꿀 수 있다. 앞 띠(WATCH)는 임계에 닿기 전에 «계획 교체»를 잡게 한다.
// 🔵 «로그 로테이션» = 기기 안 아카이브가 아직 없다(아카이브 쓰기 = 기기 id · GitHub 뒤) → 행 부재.
// 🔵 «OS 보안 지원 종료일» = 어느 API 에도 없다(제조사 정책) → 보안 패치 날짜의 나이로 잰다(지원이 끝나면 패치가 멈춘다).

import 'package:domain_contracts/domain_contracts.dart'
    show AsOf, AsOfSource, DeviceRiskItem, DeviceRiskVm, TradeDate, UiLevel;

import 'ledger_views.dart' show kstDateText;

/// 배터리 상태 코드(조립 앱이 `BatteryManager.BATTERY_HEALTH_*` 를 이 글자로 옮긴다).
abstract final class DeviceBatteryHealth {
  /// 양호.
  static const String good = 'GOOD';

  /// 과열.
  static const String overheat = 'OVERHEAT';

  /// 저온.
  static const String cold = 'COLD';

  /// 수명 다함.
  static const String dead = 'DEAD';

  /// 과전압.
  static const String overVoltage = 'OVER_VOLTAGE';

  /// 기타 고장.
  static const String failure = 'FAILURE';
}

/// 기기 측정값 — null = 이 기기에서 못 잼(그 항목 행 부재).
class DeviceRiskFacts {
  /// 측정값을 만든다.
  const DeviceRiskFacts({
    required this.measuredAtUtc,
    this.storageFreeBytes,
    this.batteryHealth,
    this.batteryCycleCount,
    this.batteryTempTenthsC,
    this.securityPatch,
  });

  /// 잰 시각.
  final DateTime measuredAtUtc;

  /// 원장이 사는 저장소의 남은 바이트.
  final int? storageFreeBytes;

  /// 배터리 상태([DeviceBatteryHealth] 글자 · 모르는 값 = 고장으로 본다).
  final String? batteryHealth;

  /// 배터리 충전 횟수(Android 14+).
  final int? batteryCycleCount;

  /// 배터리 온도(0.1도 단위 — `EXTRA_TEMPERATURE`).
  final int? batteryTempTenthsC;

  /// 보안 패치 날짜(`Build.VERSION.SECURITY_PATCH` · YYYY-MM-DD).
  final String? securityPatch;
}

/// 저장공간 임계(잠정) — 남은 공간이 이보다 적으면 할 일.
const int kDeviceStorageActBytes = 2000000000;

/// 저장공간 앞 띠 — 이보다 적으면 지켜봄.
const int kDeviceStorageWatchBytes = 4000000000;

/// 저장공간 막힘 — 원장 기록이 실패할 수 있는 선.
const int kDeviceStorageBlockedBytes = 500000000;

/// 배터리 충전 횟수 임계(잠정).
const int kDeviceBatteryCyclesAct = 800;

/// 배터리 충전 횟수 앞 띠.
const int kDeviceBatteryCyclesWatch = 500;

/// 보안 패치 나이 임계(일 · 잠정 — 약 6개월).
const int kDevicePatchActDays = 183;

/// 보안 패치 나이 앞 띠(일 · 약 3개월).
const int kDevicePatchWatchDays = 92;

/// 기기 온도 임계(0.1도 — 45도 넘음).
const int kDeviceTempActTenths = 450;

/// 기기 온도 앞 띠(0.1도 — 40도부터).
const int kDeviceTempWatchTenths = 400;

/// 측정 신선도(표본 93600초 = 26시간).
const Duration kDeviceRiskStaleAfter = Duration(hours: 26);

/// 늘 싣는 안내(표본 문장).
const String kDeviceRiskGuidance =
    '이 항목들은 비상 복구가 아니라 계획 교체의 신호입니다. 임계에 닿기 전에 교체·정리 일정을 잡으세요.';

/// 잰 항목이 하나도 없을 때(표본 문장).
const String kDeviceRiskEmptyLabel =
    '점검할 기기 항목을 아직 받지 못했습니다. 폰에서 앱을 열면 다시 잽니다.';

/// 오래된 측정(표본 문장).
const String kDeviceRiskStaleLabel = '기기 점검 값이 오래됐습니다. 폰에서 앱을 열면 다시 잽니다.';

/// 조치가 필요 없을 때.
const String kDeviceRiskNoAction = '조치 필요 없음';

String _two(int n) => n.toString().padLeft(2, '0');

DateTime _kst(DateTime utc) => utc.toUtc().add(const Duration(hours: 9));

/// 바이트 → «3.1GB»(10진 · 소수 한 자리 · 1GB 아래 = «850MB»).
String deviceBytesText(int bytes) {
  if (bytes < 1000000000) return '${bytes ~/ 1000000}MB';
  final int tenths = bytes ~/ 100000000;
  return tenths % 10 == 0
      ? '${tenths ~/ 10}GB'
      : '${tenths ~/ 10}.${tenths % 10}GB';
}

/// 0.1도 → «36.5도».
String deviceTempText(int tenths) =>
    tenths % 10 == 0 ? '${tenths ~/ 10}도' : '${tenths / 10}도';

DeviceRiskItem? _storage(int? free, String last) {
  if (free == null) return null;
  final (UiLevel level, String action) = free < kDeviceStorageBlockedBytes
      ? (UiLevel.blocked, '원장 기록이 실패할 수 있습니다 — 지금 사진·동영상 등을 지워 공간을 비우세요')
      : free < kDeviceStorageActBytes
      ? (UiLevel.act, '사진·동영상 등 다른 앱 데이터를 정리해 2GB 넘게 비우세요')
      : free < kDeviceStorageWatchBytes
      ? (UiLevel.watch, '여유가 줄고 있습니다 — 정리 일정을 잡으세요')
      : (UiLevel.ok, kDeviceRiskNoAction);
  return DeviceRiskItem(
    label: '저장공간',
    currentText: '남은 공간 ${deviceBytesText(free)}',
    thresholdText: '임계 ${deviceBytesText(kDeviceStorageActBytes)} 미만',
    actionText: action,
    lastCheckedText: last,
    level: level,
  );
}

String _healthText(String h) => switch (h) {
  DeviceBatteryHealth.good => '상태 양호',
  DeviceBatteryHealth.overheat => '과열',
  DeviceBatteryHealth.cold => '저온',
  DeviceBatteryHealth.dead => '수명 다함',
  DeviceBatteryHealth.overVoltage => '과전압',
  _ => '고장 신호',
};

DeviceRiskItem? _battery(String? health, int? cycles, String last) {
  if (health == null && cycles == null) return null;
  final List<String> now = <String>[
    if (cycles != null) '충전 $cycles회',
    if (health != null) _healthText(health),
  ];
  final bool broken =
      health != null &&
      health != DeviceBatteryHealth.good &&
      health != DeviceBatteryHealth.cold &&
      health != DeviceBatteryHealth.overheat;
  final (UiLevel level, String action) = broken
      ? (UiLevel.act, '배터리 교체 또는 예비 폰 준비를 계획하세요')
      : health == DeviceBatteryHealth.overheat
      ? (UiLevel.act, '충전기를 빼고 식히세요 — 되풀이되면 배터리 교체를 계획하세요')
      : cycles != null && cycles >= kDeviceBatteryCyclesAct
      ? (UiLevel.act, '배터리 교체 또는 예비 폰 준비를 계획하세요')
      : cycles != null && cycles >= kDeviceBatteryCyclesWatch
      ? (UiLevel.watch, '배터리 교체 시기를 계획에 넣으세요')
      : health == DeviceBatteryHealth.cold
      ? (UiLevel.watch, '따뜻한 실내에 두세요')
      : (UiLevel.ok, kDeviceRiskNoAction);
  return DeviceRiskItem(
    label: '배터리 열화',
    currentText: cycles == null
        ? '${now.join(' · ')}(충전 횟수 모름)'
        : now.join(' · '),
    thresholdText: '임계 충전 $kDeviceBatteryCyclesAct회 또는 상태 이상',
    actionText: action,
    lastCheckedText: last,
    level: level,
  );
}

final RegExp _ymd = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

DeviceRiskItem? _patch(String? patch, DateTime nowUtc, String last) {
  final RegExpMatch? m = patch == null ? null : _ymd.firstMatch(patch.trim());
  if (m == null) return null;
  final DateTime at = DateTime.utc(
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!),
  );
  final DateTime k = _kst(nowUtc);
  final int age = DateTime.utc(k.year, k.month, k.day).difference(at).inDays;
  final (UiLevel level, String action) = age > kDevicePatchActDays
      ? (UiLevel.act, '제조사 보안 지원이 끝났을 수 있습니다 — 새 폰 이전 일정을 잡으세요(X1 기기 이전)')
      : age > kDevicePatchWatchDays
      ? (UiLevel.watch, '시스템 업데이트가 있는지 확인하세요')
      : (UiLevel.ok, kDeviceRiskNoAction);
  return DeviceRiskItem(
    label: 'OS 보안 패치',
    currentText: '보안 패치 ${patch!.trim()}',
    thresholdText: '임계 패치가 6개월 넘게 멈춤',
    actionText: action,
    lastCheckedText: last,
    level: level,
  );
}

DeviceRiskItem? _temp(int? tenths, String last) {
  if (tenths == null) return null;
  final (UiLevel level, String action) = tenths > kDeviceTempActTenths
      ? (UiLevel.act, '충전기를 빼고 그늘로 옮기세요')
      : tenths >= kDeviceTempWatchTenths
      ? (UiLevel.watch, '통풍이 되는 곳에 두세요')
      : (UiLevel.ok, kDeviceRiskNoAction);
  return DeviceRiskItem(
    label: '기기 온도',
    currentText: '현재 ${deviceTempText(tenths)}',
    thresholdText: '임계 ${deviceTempText(kDeviceTempActTenths)} 넘음',
    actionText: action,
    lastCheckedText: last,
    level: level,
  );
}

/// 🔴 `H-03` — 잰 항목만 · 차례 = 저장공간 → 배터리 → 보안 패치 → 온도(표본 차례 · 로그 = 부재).
DeviceRiskVm deviceRiskVmOf(DeviceRiskFacts f, {required DateTime nowUtc}) {
  final DateTime at = f.measuredAtUtc.toUtc();
  final DateTime k = _kst(at);
  final String last =
      '마지막 점검 ${_two(k.month)}-${_two(k.day)} ${_two(k.hour)}:${_two(k.minute)}';
  final List<DeviceRiskItem> rows = <DeviceRiskItem>[
    ?_storage(f.storageFreeBytes, last),
    ?_battery(f.batteryHealth, f.batteryCycleCount, last),
    ?_patch(f.securityPatch, nowUtc, last),
    ?_temp(f.batteryTempTenthsC, last),
  ];
  return DeviceRiskVm(
    rows: rows,
    guidanceText: kDeviceRiskGuidance,
    emptyLabel: rows.isEmpty ? kDeviceRiskEmptyLabel : null,
    asOf: AsOf(
      observedAt: at,
      tradeDate: TradeDate(kstDateText(at)),
      source: AsOfSource.localSqlite,
      staleAfter: kDeviceRiskStaleAfter,
      label: '기기 점검 기준 ${kstDateText(at)} ${_two(k.hour)}:${_two(k.minute)}',
      staleLabel: kDeviceRiskStaleLabel,
    ),
  );
}
