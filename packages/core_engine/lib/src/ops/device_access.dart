// E11p3d-5h — M9 `S06` 기기 · 접근 관리 VM 짓기(설계 13 §8 R146 · 앱 05 S06 · 01 §29 K10~K35).
//
// 🔴 글자 = 엔진(표본 `m9/device_access*` 꼴) — 화면은 거르지도 · 세지도 않는다.
// 🔴 기기 = 이 폰(운영) 한 행 — 조회 전용 기기는 페어링(Supabase)으로만 생기는데 그 원천이 없다 → 0대 = 표본 빈 줄.
// 🔴 리스 = 로컬 판정(주문을 막는 그 판정의 «기록된 사실» 판 — data_sync `SqliteLeaseGate.recorded` · 🆕 리뷰 3차 C-3 · 01 §8 미결 236 ⓒ ·
//    R267 · 화면 읽기가 원격 RPC 를 부르지 않는다) 그대로 · 모름 = «확인 대기»(원격 실물 전 · 최근 원격 성공 기록 없음 — 주문 직전 잡이
//    다시 판정) · 세대 · 남은 시간 = Supabase 리스 · 신뢰 시각 전 → 없음.
// 🔴 QR 페어링 카드 = 원천 전 → 부재(«발급 버튼 XOR QR 자리» 를 지어낼 수 없다) · 기기 이전 링크 = 본문이 있을 때만 · 잠김 = 생체 가드 전 → 없음.

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        AsOf,
        AsOfSource,
        DeviceAccessVm,
        DeviceRow,
        LinkAction,
        RunMode,
        TradeDate,
        UiLevel;

import 'lease_gate.dart' show LeaseVerdict;
import 'ledger_views.dart' show kstDateText;

/// 기기 화면 신선도(표본 93600초 = 26시간).
const Duration kDeviceAccessStaleAfter = Duration(hours: 26);

/// 조회 전용 기기가 0대일 때(표본 문장).
const String kDeviceAccessNoViewers = '연결된 조회 전용 기기가 없습니다.';

/// 기기 이전 링크 글자(표본).
const String kDeviceAccessMigrationLabel = '기기 이전 · 강등 · 비상 복구';

/// 기기 화면 사실.
class DeviceAccessFacts {
  /// 사실을 만든다.
  const DeviceAccessFacts({
    required this.deviceId,
    required this.runMode,
    required this.lease,
    required this.hasBody,
  });

  /// 이 기기 id(백업 제외 자리 · 화면 미참조).
  final String deviceId;

  /// 지금 실행 모드.
  final RunMode runMode;

  /// 지금 리스 판정(주문을 막는 그 판정의 기록된 사실 판 — 원격 RPC 0).
  final LeaseVerdict lease;

  /// 조립 앱에 이 라우트의 본문이 있나(없으면 링크를 싣지 않는다).
  final bool Function(String route) hasBody;
}

String _two(int n) => n.toString().padLeft(2, '0');

/// 리스 칸 셋(누가 · 상태 · 색) + 이 폰 행 상태(글자 · 색).
(String, String, UiLevel, String, UiLevel) _leaseOf(
  LeaseVerdict v,
  RunMode run,
) => switch (v) {
  LeaseVerdict.valid => (
    '이 폰(운영)',
    run == RunMode.simInternal ? '유효 — 이 폰 단독 리스(모의)' : '유효',
    UiLevel.ok,
    '사용 중',
    UiLevel.ok,
  ),
  LeaseVerdict.invalid => (
    '없음 — 리스가 봉인됐습니다',
    '무효 — 주문이 멈춰 있습니다',
    UiLevel.blocked,
    '주문 멈춤 — 리스 없음',
    UiLevel.watch,
  ),
  LeaseVerdict.unknown => (
    '확인할 수 없음',
    '확인 대기 — 최근 리스 확인 기록이 없습니다 · 주문 직전에 다시 확인하고, 확인되지 않으면 주문이 막힙니다',
    UiLevel.blocked,
    '주문 대기 — 리스를 확인할 수 없음',
    UiLevel.watch,
  ),
};

/// 🔴 `S06` 기기 · 접근 관리.
DeviceAccessVm deviceAccessVmOf(
  DeviceAccessFacts f, {
  required DateTime nowUtc,
}) {
  final (
    String holder,
    String state,
    UiLevel leaseLevel,
    String phoneStatus,
    UiLevel phoneLevel,
  ) = _leaseOf(
    f.lease,
    f.runMode,
  );
  final DateTime k = nowUtc.toUtc().add(const Duration(hours: 9));
  return DeviceAccessVm(
    devices: <DeviceRow>[
      DeviceRow(
        deviceId: f.deviceId,
        label: '이 폰(운영)',
        roleLabel: '운영 기기',
        statusLabel: phoneStatus,
        lastSeenText: '지금',
        level: phoneLevel,
      ),
    ],
    leaseHolderLabel: holder,
    leaseStateLabel: state,
    leaseLevel: leaseLevel,
    migrationLink: f.hasBody(AppRoutes.x1Migration)
        ? const LinkAction(
            label: kDeviceAccessMigrationLabel,
            deepLink: AppRoutes.x1Migration,
          )
        : null,
    emptyLabel: kDeviceAccessNoViewers,
    asOf: AsOf(
      observedAt: nowUtc.toUtc(),
      tradeDate: TradeDate(kstDateText(nowUtc)),
      source: AsOfSource.localSqlite,
      staleAfter: kDeviceAccessStaleAfter,
      label: '기기 기준 ${kstDateText(nowUtc)} ${_two(k.hour)}:${_two(k.minute)}',
    ),
  );
}
