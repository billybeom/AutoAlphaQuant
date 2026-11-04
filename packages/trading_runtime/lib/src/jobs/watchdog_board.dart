// 워치독 보드 · 바깥 대조 · 자기 점검(설계 13 §8 R45 C7 · C8 · C9 · 06 M1-12 · 지도 D12 · 앱 04 §7 `W-01`).
//
// 🔴 정본 = 엔진 로컬 판정(E11b `judgeOccurrence` · 예정 vs 실제 + 유예 · D12). healthchecks 읽기는 «바깥이 받았나» 대조다 —
//    바깥을 못 읽어도 행은 로컬 판정 그대로 그린다(머리 문구만 바뀐다).
// 🔴 문구 = 계약 표본 꼴(`m8/watchdog_*.json`) · 지연을 실패색으로 칠하지 않는다 · 일시정지 = 네 번째 상태(info).
// 🔴 슬러그 · 핑 URL · 키 · uuid 는 보드에 나가지 않는다(04 §7 · C-49 ⑪) — `checkId` 는 차례(`wd_0001`…)다.
// 🔴 유예는 받은 값(config)을 글자로 옮길 뿐이다 — 유예 리터럴을 두지 않는다(04 §7 수용 기준 (e)).

import 'package:core_engine/core_engine.dart'
    show RemoteCheck, RemoteCheckStatus;
import 'package:domain_contracts/domain_contracts.dart';

import 'job_contract.dart' show kstDateOf;
import 'watchdog_judge.dart';

/// 하단 한계 고지(늘 싣는다 · 04 §7 «한계·이력»).
const String kWatchdogLimitNotice =
    'healthchecks.io 자체 장애 때는 경보가 오지 않습니다 — 이메일 2차 채널로 받습니다.';

/// 휴장일 고지(휴장일만).
const String kWatchdogHolidayNotice = '휴장일의 쉼은 결측이 아닙니다.';

/// 빈 보드 문구.
const String kWatchdogEmptyLabel = '등록된 워치독 체크가 아직 없습니다.';

/// 바깥이 «받았다»로 칠 여유 — 바깥 `last_ping` 이 로컬 핑보다 이만큼 넘게 앞서면 못 받은 것(R45 C8).
const Duration kWatchdogReceiptTolerance = Duration(seconds: 60);

/// 보드 기준일 신선도(26시간 · 계약 표본).
const Duration kWatchdogStaleAfter = Duration(hours: 26);

/// 보드 한 행의 재료.
class WatchdogBoardInput {
  /// 재료를 만든다.
  const WatchdogBoardInput({
    required this.label,
    required this.slug,
    required this.verdict,
    required this.grace,
    this.record,
  });

  /// 화면 이름표(엔진 문구).
  final String label;

  /// 바깥 대조용 슬러그 — 🔴 보드에 나가지 않는다.
  final String slug;

  /// 로컬 판정(E11b).
  final WatchdogVerdict verdict;

  /// 이 체크의 유예(config).
  final Duration grace;

  /// 마지막 신호(로컬 기록).
  final OccurrenceRecord? record;
}

String _two(int n) => n.toString().padLeft(2, '0');

DateTime _kst(DateTime utc) => utc.toUtc().add(const Duration(hours: 9));

/// «오늘 09:03» · «어제 23:40» · «11월 2일 16:05»(KST).
String _when(DateTime atUtc, DateTime nowUtc) {
  final DateTime a = _kst(atUtc), n = _kst(nowUtc);
  final DateTime ad = DateTime.utc(a.year, a.month, a.day);
  final DateTime nd = DateTime.utc(n.year, n.month, n.day);
  final String hm = '${_two(a.hour)}:${_two(a.minute)}';
  final int days = nd.difference(ad).inDays;
  if (days == 0) return '오늘 $hm';
  if (days == 1) return '어제 $hm';
  return '${a.month}월 ${a.day}일 $hm';
}

/// «30분» · «2시간» · «1시간 30분».
String _span(Duration d) {
  final int m = d.inMinutes;
  if (m < 60) return '$m분';
  final int h = m ~/ 60, r = m % 60;
  return r == 0 ? '$h시간' : '$h시간 $r분';
}

/// 마지막 신호 문구(R45 C7) — 실패 · 휴장 · 성공 중 나중 것.
String _lastPingText(OccurrenceRecord? r, DateTime nowUtc) {
  final DateTime? ok = r?.succeededUtc, bad = r?.failedUtc;
  if (bad != null && (ok == null || bad.isAfter(ok))) {
    return '${_when(bad, nowUtc)}에 실패 신호';
  }
  if (ok != null) {
    return r!.holidayPing
        ? '${_when(ok, nowUtc)}에 휴장 확인'
        : '${_when(ok, nowUtc)}에 확인';
  }
  return '아직 신호가 없습니다';
}

/// 로컬 판정 → (코드 · 문구 · 레벨 · 유예 문구).
(String, String, UiLevel, String?) _local(WatchdogBoardInput i) {
  final WatchdogVerdict v = i.verdict;
  final String g = _span(i.grace);
  return switch (v.state) {
    WatchdogState.pending => ('WAITING', '기다리는 중', UiLevel.ok, '유예 $g 안입니다'),
    WatchdogState.success => ('OK', '정상', UiLevel.ok, null),
    WatchdogState.late => (
      'DELAYED',
      '지연(${_span(v.lateBy ?? Duration.zero)})',
      UiLevel.watch,
      '유예 $g을 넘겨 도착했습니다',
    ),
    WatchdogState.failed => (
      'FAILED',
      '실패',
      UiLevel.blocked,
      i.record?.failedUtc == null ? '유예 $g이 지났습니다' : null,
    ),
    WatchdogState.holiday => ('OK', '휴장일 확인 — 정상', UiLevel.ok, null),
    WatchdogState.paused => (
      'PAUSED',
      '유지보수로 일시정지',
      UiLevel.info,
      '유지보수 창이 끝나면 다시 봅니다',
    ),
  };
}

/// 바깥 대조 결과(행 하나).
enum _Outside { fine, missing, ambiguous, notReceived, paused }

_Outside _outside(
  WatchdogBoardInput i,
  List<RemoteCheck> remote,
  Duration tolerance,
) {
  final WatchdogState s = i.verdict.state;
  final bool reached =
      s == WatchdogState.success ||
      s == WatchdogState.late ||
      s == WatchdogState.holiday;
  if (!reached) return _Outside.fine;
  final List<RemoteCheck> hits = <RemoteCheck>[
    for (final RemoteCheck r in remote)
      if (r.slug == i.slug) r,
  ];
  if (hits.isEmpty) return _Outside.missing;
  if (hits.length > 1) return _Outside.ambiguous;
  final RemoteCheck r = hits.single;
  if (r.status == RemoteCheckStatus.paused) return _Outside.paused;
  final DateTime? local = i.record?.succeededUtc;
  final DateTime? seen = r.lastPingUtc;
  if (local != null &&
      (seen == null || seen.isBefore(local.subtract(tolerance)))) {
    return _Outside.notReceived;
  }
  return _Outside.fine;
}

/// 보드를 만든다(R45 C7 · C8).
///
/// [remote] = 바깥 체크 목록 · **null = 바깥을 못 읽음**(행은 로컬 그대로 · 머리 문구만). [holiday] = 오늘 KR 비세션.
WatchdogBoardVm buildWatchdogBoard({
  required List<WatchdogBoardInput> rows,
  required DateTime nowUtc,
  required bool holiday,
  required List<RemoteCheck>? remote,
  Duration receiptTolerance = kWatchdogReceiptTolerance,
}) {
  final List<WatchdogCheck> out = <WatchdogCheck>[];
  for (int k = 0; k < rows.length; k++) {
    final WatchdogBoardInput i = rows[k];
    var (String code, String label, UiLevel level, String? grace) = _local(i);
    if (remote != null) {
      final _Outside o = _outside(i, remote, receiptTolerance);
      if (o != _Outside.fine) {
        level = UiLevel.watch;
        (code, label) = switch (o) {
          _Outside.missing => ('OUTSIDE_MISSING', '$label — 바깥 감시에 체크가 없습니다'),
          _Outside.ambiguous => (
            'OUTSIDE_AMBIGUOUS',
            '$label — 바깥 감시에 같은 이름 체크가 여럿입니다',
          ),
          _Outside.notReceived => (
            'OUTSIDE_NOT_RECEIVED',
            '$label — 바깥 감시가 못 받았습니다',
          ),
          _Outside.paused => ('OUTSIDE_PAUSED', '$label — 바깥 감시가 일시정지돼 있습니다'),
          _Outside.fine => (code, label),
        };
      }
    }
    out.add(
      WatchdogCheck(
        checkId: 'wd_${(k + 1).toString().padLeft(4, '0')}',
        label: i.label,
        stateCode: code,
        stateLabel: label,
        level: level,
        lastPingText: _lastPingText(i.record, nowUtc),
        graceText: grace,
      ),
    );
  }
  final TradeDate today = kstDateOf(nowUtc);
  String? lastReceived;
  if (remote == null) {
    lastReceived = '마지막 수신 — 바깥 감시를 읽지 못했습니다';
  } else {
    DateTime? latest;
    for (final RemoteCheck r in remote) {
      final DateTime? t = r.lastPingUtc;
      if (t != null && (latest == null || t.isAfter(latest))) latest = t;
    }
    if (latest != null) {
      final String w = _when(latest, nowUtc);
      lastReceived = '마지막 수신 ${w.startsWith('오늘 ') ? w.substring(3) : w}';
    }
  }
  return WatchdogBoardVm(
    rows: out,
    asOf: AsOf(
      observedAt: nowUtc.toUtc(),
      tradeDate: today,
      source: AsOfSource.localSqlite,
      staleAfter: kWatchdogStaleAfter,
      label: '워치독 기준 ${today.yyyyMmDd}',
    ),
    emptyLabel: out.isEmpty ? kWatchdogEmptyLabel : null,
    holidayNotice: holiday ? kWatchdogHolidayNotice : null,
    limitNotice: kWatchdogLimitNotice,
    lastReceivedText: lastReceived,
  );
}

/// 자기 점검 결과 종류(R45 C9 · 06 M1-12 게이트 «체크 active 자기 점검»).
enum RemoteAuditKind {
  /// 기대한 슬러그가 바깥에 없다.
  missing,

  /// 같은 슬러그가 여럿(슬러그 핑 409).
  duplicate,

  /// 멈춰 있다.
  paused,

  /// 한 번도 못 받았다(new).
  neverPinged,

  /// 유예를 넘겼다(down).
  down,

  /// 기대 밖 슬러그(옛 모드 이름 등).
  unexpected,
}

/// 자기 점검 한 건.
class RemoteAuditFinding {
  /// 한 건을 만든다.
  const RemoteAuditFinding(this.kind, this.slug);

  /// 종류.
  final RemoteAuditKind kind;

  /// 슬러그(엔진 기록용 — 화면 몫 아님).
  final String slug;

  @override
  bool operator ==(Object other) =>
      other is RemoteAuditFinding && other.kind == kind && other.slug == slug;

  @override
  int get hashCode => Object.hash(kind, slug);

  @override
  String toString() => '${kind.name}:$slug';
}

/// 기대 슬러그 [expected] 와 바깥 목록 [remote] 를 맞춘다 — 빈 목록 = 통과(R45 C9).
List<RemoteAuditFinding> auditRemoteChecks(
  Set<String> expected,
  List<RemoteCheck> remote,
) {
  final List<RemoteAuditFinding> out = <RemoteAuditFinding>[];
  final List<String> want = expected.toList()..sort();
  for (final String slug in want) {
    final List<RemoteCheck> hits = <RemoteCheck>[
      for (final RemoteCheck r in remote)
        if (r.slug == slug) r,
    ];
    if (hits.isEmpty) {
      out.add(RemoteAuditFinding(RemoteAuditKind.missing, slug));
      continue;
    }
    if (hits.length > 1) {
      out.add(RemoteAuditFinding(RemoteAuditKind.duplicate, slug));
    }
    final RemoteCheckStatus s = hits.first.status;
    final RemoteAuditKind? k = switch (s) {
      RemoteCheckStatus.paused => RemoteAuditKind.paused,
      RemoteCheckStatus.fresh => RemoteAuditKind.neverPinged,
      RemoteCheckStatus.down => RemoteAuditKind.down,
      _ => null,
    };
    if (k != null) out.add(RemoteAuditFinding(k, slug));
  }
  final List<String> extra = <String>{
    for (final RemoteCheck r in remote)
      if (!expected.contains(r.slug)) r.slug,
  }.toList()..sort();
  for (final String slug in extra) {
    out.add(RemoteAuditFinding(RemoteAuditKind.unexpected, slug));
  }
  return out;
}
