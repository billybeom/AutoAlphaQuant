// E11p3d-5f — M9 `S07` 연결 관리 VM 짓기(설계 13 §8 R140 · 앱 05 S07 · 01 §27 K-n · K-r).
//
// 🔴 글자 = 엔진(표본 `m9/connections*` · `m8/incident_token_expired` 꼴) — 화면은 세지도 · 고르지도 않는다.
// 🔴 행 = 원천이 있는 연결만 · 차례 = 증권사 → Supabase → GitHub → 생존 신호(표본 `incident_token_expired` 차례).
//    · 알림 채널(텔레그램 · 카카오톡) = 엔진에 바깥 채널이 없다 → 행 부재(받을 채널 «정확히 1 선택»을 지어낼 수 없다).
//    · 구글 캘린더 = `calendarEnabled == false` 면 행 0(계약 머리 글).
// 🔴 버튼(연결 테스트 · 지금 동기화) = operator 동작 구현 전 → 빈 목록(누르면 실패하는 버튼을 만들지 않는다).
// 🔵 Supabase · GitHub = 아직 연결 전(E11k · 아카이브 쓰기 배선 전) → «연결 안 됨» INFO(모의 체험에는 필요 없다 — 경보로 만들지 않는다).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        AsOf,
        AsOfSource,
        ConnectionRow,
        ConnectionTargetCodes,
        ConnectionsVm,
        RunMode,
        RunModeIsSim,
        StepState,
        TradeDate,
        UiLevel;

import '../onboarding/credential_list.dart' show PaperCredentialFacts;
import 'ledger_views.dart' show kstDateText;
import 'watchdog_ports.dart' show RemoteCheck, RemoteCheckStatus;

/// 연결 화면 신선도(표본 93600초 = 26시간).
const Duration kConnectionsStaleAfter = Duration(hours: 26);

/// 연결 상태 코드(표본 사전 · 🔴 화면 미참조).
abstract final class ConnectionStatusCodes {
  /// 정상.
  static const String ok = 'OK';

  /// 연결 전.
  static const String notSet = 'NOT_SET';

  /// 실패(검증 거절 · 신호 끊김).
  static const String failed = 'FAILED';

  /// 검증 기록 없음.
  static const String unverified = 'UNVERIFIED';

  /// 바깥을 읽지 못함.
  static const String unreadable = 'UNREADABLE';

  /// 체크 없음.
  static const String noChecks = 'NO_CHECKS';

  /// 유예 안(늦음).
  static const String late = 'LATE';

  /// 첫 신호 대기.
  static const String waiting = 'WAITING';
}

/// healthchecks 에 닿았나.
enum HealthchecksReach {
  /// 연결 전(클라이언트 없음 · 읽기 키 없음).
  notSet,

  /// 읽지 못함(네트워크 · 응답 이상).
  unreadable,

  /// 읽음.
  read,
}

/// 연결 화면 사실.
class ConnectionsFacts {
  /// 사실을 만든다.
  const ConnectionsFacts({
    required this.runMode,
    required this.kis,
    required this.healthchecks,
    required this.hasBody,
    this.checks = const <RemoteCheck>[],
  });

  /// 지금 실행 모드.
  final RunMode runMode;

  /// 증권사 키(모의 세트 — 지금 엔진에 있는 유일한 세트).
  final PaperCredentialFacts kis;

  /// healthchecks 에 닿았나.
  final HealthchecksReach healthchecks;

  /// 읽은 체크([healthchecks] == read 일 때만).
  final List<RemoteCheck> checks;

  /// 조립 앱에 이 라우트의 본문이 있나(없으면 링크를 싣지 않는다).
  final bool Function(String route) hasBody;
}

String _two(int n) => n.toString().padLeft(2, '0');

String _kstShort(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  return '${_two(k.month)}-${_two(k.day)} ${_two(k.hour)}:${_two(k.minute)}';
}

/// «방금» · «n분 전» · «n시간 전» · «n일 전»(미래 시각 = «방금»).
String connectionAgoText(DateTime atUtc, DateTime nowUtc) {
  final Duration d = nowUtc.toUtc().difference(atUtc.toUtc());
  if (d.inMinutes < 1) return '방금';
  if (d.inHours < 1) return '${d.inMinutes}분 전';
  if (d.inDays < 1) return '${d.inHours}시간 전';
  return '${d.inDays}일 전';
}

/// 증권사 연결 행 — 키 검증 기록(S02 와 같은 원천).
ConnectionRow connectionKisRowOf(
  PaperCredentialFacts k, {
  required RunMode runMode,
  String? route,
}) {
  final DateTime? at = k.lastAtUtc;
  final bool failed = k.lastState == StepState.failed;
  final bool ok = k.stored && k.lastState == StepState.verified;
  final String code;
  final String status;
  final String lastOk;
  final UiLevel level;
  String? detail;
  if (failed) {
    code = ConnectionStatusCodes.failed;
    status = '검증 실패';
    lastOk = '최근 성공 기록 없음';
    level = UiLevel.act;
    detail = at == null
        ? null
        : '${_kstShort(at)} 검증 거절(${k.lastFailureCode ?? '코드 없음'})';
  } else if (ok) {
    code = ConnectionStatusCodes.ok;
    status = '정상';
    lastOk = at == null ? '검증 시각 모름' : '${_kstShort(at)} 검증 통과';
    level = UiLevel.ok;
  } else if (k.stored) {
    code = ConnectionStatusCodes.unverified;
    status = '검증 기록 없음';
    lastOk = '검증한 적 없음';
    level = UiLevel.watch;
  } else {
    code = ConnectionStatusCodes.notSet;
    status = '연결 안 됨';
    lastOk = '연결한 적 없음';
    // 모의 실행에는 모의 키가 필수 — 실전에서는 선택(S02 «필수/선택»과 같은 축).
    level = runMode.isSim ? UiLevel.act : UiLevel.info;
  }
  return ConnectionRow(
    target: ConnectionTargetCodes.brokerKis,
    label: '증권사 연결(모의투자)',
    statusCode: code,
    statusLabel: status,
    lastOkText: lastOk,
    detailLine: detail,
    level: level,
    route: route,
  );
}

ConnectionRow _notSet(String target, String label, String detail) =>
    ConnectionRow(
      target: target,
      label: label,
      statusCode: ConnectionStatusCodes.notSet,
      statusLabel: '연결 안 됨',
      lastOkText: '연결한 적 없음',
      detailLine: detail,
      level: UiLevel.info,
    );

/// 생존 신호 행 — 바깥 체크 목록 요약(목록 = `W-01`).
ConnectionRow connectionHealthchecksRowOf(
  HealthchecksReach reach,
  List<RemoteCheck> checks, {
  required DateTime nowUtc,
  String? route,
}) {
  const String label = '생존 신호(healthchecks)';
  ConnectionRow row(
    String code,
    String status,
    String lastOk,
    UiLevel level,
    String? detail,
  ) => ConnectionRow(
    target: ConnectionTargetCodes.healthchecks,
    label: label,
    statusCode: code,
    statusLabel: status,
    lastOkText: lastOk,
    detailLine: detail,
    level: level,
    route: route,
  );
  switch (reach) {
    case HealthchecksReach.notSet:
      return row(
        ConnectionStatusCodes.notSet,
        '연결 안 됨',
        '연결한 적 없음',
        UiLevel.info,
        '읽기 키를 넣으면 체크 상태를 여기서 봅니다',
      );
    case HealthchecksReach.unreadable:
      return row(
        ConnectionStatusCodes.unreadable,
        '읽지 못했습니다',
        '확인할 수 없음',
        UiLevel.watch,
        '네트워크나 읽기 키를 확인하세요',
      );
    case HealthchecksReach.read:
      break;
  }
  if (checks.isEmpty) {
    return row(
      ConnectionStatusCodes.noChecks,
      '체크 없음',
      '받은 적 없음',
      UiLevel.watch,
      'healthchecks 에 체크를 아직 만들지 않았습니다',
    );
  }
  int count(RemoteCheckStatus s) =>
      checks.where((RemoteCheck c) => c.status == s).length;
  final int down = count(RemoteCheckStatus.down);
  final int grace = count(RemoteCheckStatus.grace);
  final int fresh =
      count(RemoteCheckStatus.fresh) + count(RemoteCheckStatus.unknown);
  final int paused = count(RemoteCheckStatus.paused);
  final int n = checks.length;
  DateTime? last;
  for (final RemoteCheck c in checks) {
    final DateTime? p = c.lastPingUtc;
    if (p != null && (last == null || p.isAfter(last))) last = p;
  }
  final String ago = last == null
      ? '받은 적 없음'
      : '${connectionAgoText(last, nowUtc)}에 ${down > 0 ? '마지막 수신' : '수신'}';
  if (down > 0) {
    return row(
      ConnectionStatusCodes.failed,
      '신호 끊김',
      ago,
      UiLevel.blocked,
      '체크 $n개 중 $down개 유예 초과',
    );
  }
  if (grace > 0) {
    return row(
      ConnectionStatusCodes.late,
      '늦음',
      ago,
      UiLevel.watch,
      '체크 $n개 중 $grace개 유예 중',
    );
  }
  if (fresh > 0) {
    // 첫 잡이 돌면 저절로 풀린다 — 사람이 고칠 것이 없어 경보로 만들지 않는다.
    return row(
      ConnectionStatusCodes.waiting,
      '첫 신호 대기',
      ago,
      UiLevel.info,
      '체크 $n개 중 $fresh개 첫 신호 전',
    );
  }
  return row(
    ConnectionStatusCodes.ok,
    '정상',
    ago,
    UiLevel.ok,
    paused > 0 ? '체크 $n개 정상 · $paused개 일시정지' : '체크 $n개 모두 정상',
  );
}

/// 🔴 `S07` 연결 관리.
ConnectionsVm connectionsVmOf(ConnectionsFacts f, {required DateTime nowUtc}) {
  String? link(String route) => f.hasBody(route) ? route : null;
  final DateTime k = nowUtc.toUtc().add(const Duration(hours: 9));
  return ConnectionsVm(
    rows: <ConnectionRow>[
      connectionKisRowOf(
        f.kis,
        runMode: f.runMode,
        route: link(AppRoutes.settingsCredentials),
      ),
      _notSet(
        ConnectionTargetCodes.supabase,
        '미러(Supabase)',
        '프로젝트 연결 전 — 실전 전에 필요합니다(운영 리스 · 읽기 미러)',
      ),
      _notSet(
        ConnectionTargetCodes.githubArchive,
        '아카이브(GitHub)',
        '아카이브 저장소 · 접근 토큰 등록 전',
      ),
      connectionHealthchecksRowOf(
        f.healthchecks,
        f.checks,
        nowUtc: nowUtc,
        route: link(AppRoutes.opsWatchdog),
      ),
    ],
    asOf: AsOf(
      observedAt: nowUtc.toUtc(),
      tradeDate: TradeDate(kstDateText(nowUtc)),
      source: AsOfSource.localSqlite,
      staleAfter: kConnectionsStaleAfter,
      label: '연결 기준 ${kstDateText(nowUtc)} ${_two(k.hour)}:${_two(k.minute)}',
    ),
  );
}
