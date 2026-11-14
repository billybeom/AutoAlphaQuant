// FGS 상시 알림 문구 규약(설계 13 §8 R43 B8 · 06 M1-15 · 앱 04 §5-6 `F-01`).
//
// 🔴 완성 문자열 1개 — 화면 · OS 어댑터가 조각을 잇지 않는다. 🔴 손익 0 — 입력에 돈 칸이 없다.
// 🔴 재발행은 상태 전이 때만(배터리 · 주의력) — 문구 · 레벨 · 채널 · 링크 중 하나라도 바뀔 때.
// 🔴 P0 는 별도 채널 `ops_p0`(방해금지 관통) · 탭은 딥링크 직행.
// 🔵 OS 알림 · 채널 등록은 `app_operator_android` 어댑터 몫(E11p) — 여기는 무엇을 띄울지만 정한다.
// 🆕 E15g(R110 AO2~AO6) — 모드 표지를 본문 맨 앞에: 모의 = «모의투자 실행 중 · » · 안내 = «투자 안내 실행 중 · » ·
//    모의 × 안내 = «모의투자 · 투자 안내 실행 중 · » · 실전 × 자동 매매 = 표지 0(바이트까지 그대로) · 모드 칸 필수.

import 'package:core_engine/core_engine.dart' show kAdvisoryMarker, kSimMarker;
import 'package:domain_contracts/domain_contracts.dart';

/// FGS 알림 채널.
enum FgsChannel {
  /// 상시 — importance LOW · 무음 · 스와이프 불가.
  opsStatus('ops_status'),

  /// P0 — importance HIGH · 방해금지 관통.
  opsP0('ops_p0');

  const FgsChannel(this.id);

  /// 채널 id.
  final String id;
}

/// 문구 입력 — 🔴 돈 · 손익 칸이 없다.
class FgsStatus {
  /// 입력을 만든다.
  const FgsStatus({
    required this.level,
    required this.runMode,
    required this.operatingMode,
    this.headline,
    this.lastReconAtUtc,
    this.nextRebalanceInSessions,
    this.p0AlertId,
  });

  /// 전체 레벨.
  final UiLevel level;

  /// 🆕 E15g — 실행 모드(표지 · 🔴 필수 — 기본값이 실전이면 모의가 실전처럼 보인다).
  final RunMode runMode;

  /// 🆕 E15g — 운영 방식(투자 안내 표지).
  final OperatingMode operatingMode;

  /// 이상 문구(엔진 문장 — `ok` 가 아니면 필수).
  final String? headline;

  /// 마지막 대사 시각.
  final DateTime? lastReconAtUtc;

  /// 다음 리밸런싱까지 세션 수(D-n).
  final int? nextRebalanceInSessions;

  /// 열린 P0 알림 id(있으면 `ops_p0` · 탭 = 그 알림).
  final String? p0AlertId;
}

/// 띄울 알림.
class FgsNotice {
  /// 알림을 만든다.
  const FgsNotice({
    required this.channel,
    required this.text,
    required this.level,
    required this.link,
  });

  /// 채널.
  final FgsChannel channel;

  /// 완성 문자열 1개.
  final String text;

  /// 레벨(색 · 아이콘).
  final UiLevel level;

  /// 탭 딥링크.
  final String link;

  @override
  bool operator ==(Object other) =>
      other is FgsNotice &&
      other.channel == channel &&
      other.text == text &&
      other.level == level &&
      other.link == link;

  @override
  int get hashCode => Object.hash(channel, text, level, link);

  @override
  String toString() => '[${channel.id} ${level.wire}] $text → $link';
}

String _kstHm(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(k.hour)}:${two(k.minute)}';
}

/// 🆕 E15g — 본문 맨 앞 모드 표지(실전 × 자동 매매 = 빈 글자).
String fgsModeHead(RunMode run, OperatingMode op) {
  final bool sim = run.isSim;
  final bool advisory = op == OperatingMode.advisory;
  if (sim && advisory) return '$kSimMarker · $kAdvisoryMarker 실행 중 · ';
  if (sim) return '$kSimMarker 실행 중 · ';
  if (advisory) return '$kAdvisoryMarker 실행 중 · ';
  return '';
}

/// 문구를 만든다(R43 B8) — `ok` 가 아닌데 [FgsStatus.headline] 이 없으면 ArgumentError.
FgsNotice buildFgsNotice(FgsStatus s) {
  final bool normal = s.level == UiLevel.ok;
  final String? head = s.headline?.trim();
  if (!normal && (head == null || head.isEmpty)) {
    throw ArgumentError.value(s.level, 'level', '이상 레벨에는 엔진 문구가 있어야 한다');
  }
  final String recon = s.lastReconAtUtc == null
      ? '대사 전'
      : '마지막 대사 ${_kstHm(s.lastReconAtUtc!)}';
  final int? d = s.nextRebalanceInSessions;
  if (d != null && d < 0) {
    throw ArgumentError.value(d, 'nextRebalanceInSessions', '음수다');
  }
  final String body = normal
      ? <String>[
          '정상',
          recon,
          if (d != null) d == 0 ? '오늘 리밸런싱' : '다음 리밸런싱 D-$d',
        ].join(' · ')
      : '$head · $recon';
  final String text = '${fgsModeHead(s.runMode, s.operatingMode)}$body';
  final String? p0 = s.p0AlertId;
  final String link = p0 != null
      ? AppRoutes.alertDetail.replaceFirst(':alertId', Uri.encodeComponent(p0))
      : normal
      ? AppRoutes.opsWatchdog
      : AppRoutes.alertsInbox;
  return FgsNotice(
    channel: p0 != null ? FgsChannel.opsP0 : FgsChannel.opsStatus,
    text: text,
    level: s.level,
    link: link,
  );
}

/// 다시 띄울까 — 전이 때만(첫 알림 포함).
bool shouldRepostFgs(FgsNotice? shown, FgsNotice next) => shown != next;
