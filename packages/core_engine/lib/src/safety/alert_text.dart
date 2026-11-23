// 알림 문구 사전 · `AckState` 글자 · 인박스 · 센터 · 상세 VM 조립
// (앱 01 §2-10 `AlertItem` · §24 `AlertCenterVm` · C-49 · 앱 04 §5-1b~§5-3 · 06 M2-3 · 설계 13 §8 R69).
//
// 🔴 문구 · 등급 · 묶음 · 차례 = 엔진 — 화면은 받은 그대로 그린다(재분류 · 재정렬 · 건수 집계 0).
// 🔴 «조치가 다르면 다르게 말한다» — 같은 할 일 문장 = 같은 조치.
// 🔴 모르는 코드 = 오류(문구를 지어내지 않는다).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AckState,
        AlertCenterVm,
        AlertDetailVm,
        AlertItem,
        AlertLevel,
        AlertSection,
        AppRoutes,
        AsOf,
        AsOfSource,
        TradeDate;

import '../ops/ledger_views.dart'
    show kReconStaleAfter, kstDateText, kstMinuteText;
import 'alert_rules.dart' show alertHasLadder;

/// 알림 한 코드의 글자(R69 I1).
class AlertText {
  /// 글자를 만든다.
  const AlertText(this.title, this.body, this.action, [this.deepLink]);

  /// 제목 · 무슨 일인가 · 지금 할 일.
  final String title, body, action;

  /// 근거 링크(`AppRoutes` 상수 · null = 부재).
  final String? deepLink;
}

/// 문구 사전(R69 I1) — 픽스처 14코드 = 픽스처 글자(구체값만 일반화) · 나머지 = 초안.
const Map<String, AlertText> kAlertTexts = <String, AlertText>{
  // ── X7 안내 9 · 전환 2(앱 04 §5-1b) ──
  'ADVICE_ISSUED': AlertText(
    '오늘의 안내가 도착했습니다',
    '새 안내가 있습니다.',
    '안내함을 여십시오.',
    AppRoutes.adviceInbox,
  ),
  'ADVICE_EXIT_URGENT': AlertText(
    '즉시 확인이 필요한 청산 안내',
    '손절선에 닿은 종목이 있습니다.',
    '지금 안내함을 여십시오.',
    AppRoutes.adviceInbox,
  ),
  'ADVICE_DUE_SOON': AlertText(
    '유효기한이 오늘까지인 안내',
    '오늘 장 마감까지 유효한 안내가 있습니다.',
    '기한 전에 기록하십시오.',
    AppRoutes.adviceInbox,
  ),
  'ADVICE_EXPIRED': AlertText(
    '만료된 안내',
    '기한이 지난 안내가 있습니다.',
    '지난 안내를 확인하십시오.',
    AppRoutes.adviceHistory,
  ),
  'ADVICE_REVOKED': AlertText(
    '발행한 안내를 회수했습니다',
    '전환 커밋으로 미이행 안내가 회수되었습니다.',
    '회수 목록을 확인하십시오.',
    AppRoutes.adviceHistory,
  ),
  'ADVICE_SUPPRESSED': AlertText(
    '안내를 억제했습니다',
    '원장 확인 전이라 신규 진입 안내를 내지 않았습니다.',
    '원장을 먼저 확인하십시오.',
    AppRoutes.m5SelfAuditResolve,
  ),
  'LEDGER_TRUST_DOWNGRADE': AlertText(
    '원장 신뢰 등급이 내려갔습니다',
    '자가 보고 상태로 내려왔습니다.',
    '실사를 마치면 등급이 회복됩니다.',
    AppRoutes.ledgerTrust,
  ),
  'SELF_AUDIT_DUE': AlertText(
    '원장 실사 기한',
    '이달 원장 실사 기한이 다가옵니다.',
    '실사 일정을 확인하십시오.',
    AppRoutes.ledgerTrust,
  ),
  'MANUAL_FILL_REJECTED': AlertText(
    '수기 기록이 거부되었습니다',
    '입력한 가격이 그날 범위 밖입니다.',
    '입력값을 확인하고 다시 제출하십시오.',
    AppRoutes.adviceInbox,
  ),
  'HANDOVER_COOLING_ACTIVE': AlertText(
    '집행 주체 전환 냉각 중입니다',
    '전환 냉각 24시간이 지나야 전환을 마칠 수 있습니다.',
    '냉각이 끝난 뒤 전환 상태를 확인하십시오.',
    AppRoutes.handoverStatus,
  ),
  'HANDOVER_COMMITTED': AlertText(
    '집행 주체가 바뀌었습니다',
    '전환이 확정되어 화면의 띠와 탭이 바뀌었습니다.',
    '바뀐 집행 주체를 확인하십시오.',
    AppRoutes.handoverStatus,
  ),
  // ── 자동 매매 11 · 유지보수 2(앱 04 §5-1c) ──
  'ORDER_REJECTED': AlertText(
    '주문이 거부되었습니다',
    '증권사가 오늘 주문 일부를 거부했습니다.',
    '주문 기록에서 거부 사유를 확인하십시오.',
    AppRoutes.journalTimeline,
  ),
  'ORDER_OUTCOME_UNKNOWN': AlertText(
    '주문 결과를 확인하지 못했습니다',
    '증권사 응답이 끊겨 체결 여부를 모르는 주문이 있습니다.',
    '미확인 주문 보드를 여십시오.',
    AppRoutes.journalUnknownBoard,
  ),
  'RECON_MISMATCH': AlertText(
    '원장 대조가 어긋났습니다',
    '다시 대조해도 브로커 잔고와 원장이 맞지 않습니다.',
    '대조 보드를 여십시오.',
    AppRoutes.ledgerDiffs,
  ),
  'REBALANCE_D7': AlertText(
    '월말 리밸런싱 일주일 전입니다',
    '7일 뒤 정기 리밸런싱이 있습니다.',
    '지금 할 일은 없습니다. 전날 다시 알립니다.',
    AppRoutes.rebalancePreview,
  ),
  'REBALANCE_D1': AlertText(
    '내일 월말 리밸런싱입니다',
    '내일 정기 리밸런싱 주문이 나갑니다.',
    '리밸런싱 미리보기를 확인하십시오.',
    AppRoutes.rebalancePreview,
  ),
  'WATCHDOG_LATE': AlertText(
    '잡이 제때 돌지 않았습니다',
    '정해진 시각이 지나도 잡 신호가 오지 않았습니다.',
    '워치독 보드를 여십시오.',
    AppRoutes.opsWatchdog,
  ),
  'BROKER_AUTH_FAILED': AlertText(
    '증권사 인증에 실패했습니다',
    '토큰 또는 앱키 인증이 거부되어 주문을 낼 수 없습니다.',
    '연결 설정에서 키를 확인하십시오.',
    AppRoutes.settingsCredentials,
  ),
  'DATA_SOURCE_DOWN': AlertText(
    '시세 데이터를 받지 못했습니다',
    '데이터 소스 응답이 없어 오늘 계산에 쓸 시세가 비었습니다.',
    '워치독 보드에서 데이터 상태를 확인하십시오.',
    AppRoutes.opsWatchdog,
  ),
  'BACKUP_STALE': AlertText(
    '백업이 오래됐습니다',
    '마지막 백업이 26시간보다 오래됐습니다.',
    '백업 기록을 확인하십시오.',
    AppRoutes.opsArchive,
  ),
  'DEPOSIT_REMINDER': AlertText(
    '월 납입 날입니다',
    '이번 달 납입이 아직 기록되지 않았습니다.',
    '납입을 마쳤는지 확인하십시오.',
    AppRoutes.planDeposit,
  ),
  'STALE_ORDERS_HELD': AlertText(
    '지난 주문이 남아 있어 오늘 주문을 보류했습니다',
    '오늘 체결 조회에 지난 거래일 주문이 보입니다. 같은 종목을 두 번 사지 않도록 이 계좌의 오늘 주문을 내지 않았습니다.',
    '증권사 앱에서 지난 주문이 남아 있는지 확인하십시오.',
  ),
  'MAINTENANCE_WINDOW_OVERDUE': AlertText(
    '유지보수 창을 넘겼습니다',
    '예정한 유지보수 창이 지났습니다.',
    '유지보수 화면을 여십시오.',
    AppRoutes.opsMaintenance,
  ),
  'MAINTENANCE_RESUME_FAILED': AlertText(
    '유지보수 뒤 재개에 실패했습니다',
    '부팅 때 닫히지 않은 유지보수 창을 찾아 재개를 시도했지만 실패했습니다.',
    '유지보수 화면에서 재개 상태를 확인하십시오.',
    AppRoutes.opsMaintenance,
  ),
  // ── 운영 파라미터 1(앱 04 §5-1d) ──
  'CONTRIBUTION_CHANGED': AlertText(
    '월 납입 설정이 바뀌었습니다',
    '월 납입 운영값이 바뀌었습니다.',
    '은행 자동이체 금액도 바꿔 주십시오.',
  ),
  // ── 등재 대기 제안 3(R68 H2) ──
  'BREAKER_STOPPED': AlertText(
    '서킷브레이커가 정지 단계에 들어갔습니다',
    '드로다운이 정지 기준에 닿아 신규 주문을 전면 중단했습니다. 보유는 그대로입니다.',
    '3일 안에 postmortem 을 쓰십시오.',
    AppRoutes.m5BlockBoard,
  ),
  'LEDGER_INTEGRITY_BROKEN': AlertText(
    '원장 무결성 검사에 실패했습니다',
    '지난 날의 해시가 기록과 맞지 않아 모든 신규 주문을 막았습니다.',
    '차단 보드에서 복구 절차를 여십시오.',
    AppRoutes.m5BlockBoard,
  ),
  'STOPPED_RELEASE_ELIGIBLE': AlertText(
    '정지 단계 재개 자격을 충족했습니다',
    '회복 조건을 채워 재개 결정을 할 수 있습니다. 자동으로 풀리지 않습니다.',
    '재개 결정 전에 postmortem 과 가족 합의를 확인하십시오.',
    AppRoutes.m5BlockBoard,
  ), // ── 🆕 E14b 재개 묶음 제안 3(04 §5-3 v2.42 · R72 J9) ──
  'RESUME_COMPLETED': AlertText(
    '재개를 마쳤습니다',
    '멈춰 있던 동안의 계획을 다시 판정했습니다. 주문은 다음 주문 회차가 냅니다.',
    '재개 리포트에서 항목별 결과를 확인하십시오.',
    AppRoutes.x2ResumeReport,
  ),
  'RESUME_TRADING_HALTED': AlertText(
    '재개 뒤 매매를 멈춰 두었습니다',
    '재개 점검이 끝나지 않아 모든 신규 주문을 막아 두었습니다.',
    '재개 화면에서 막힌 이유와 할 일을 확인하십시오.',
    AppRoutes.x2ResumeGate,
  ),
  'RESUME_DATA_GAP': AlertText(
    '되살릴 수 없는 기록 공백이 있습니다',
    '멈춰 있던 동안의 기록 가운데 소급할 수 없는 것은 비운 채로 둡니다.',
    '재개 리포트에서 빈 구간을 확인하십시오.',
    AppRoutes.x2ResumeReport,
  ),
  // ── 🆕 E16f3a 파생 FORK 제안 1(04 §5-3 v2.45 · R130 L6) ──
  'DERIVED_FORK': AlertText(
    '사본 기록이 원장과 갈라졌습니다',
    '아카이브 같은 사본이 원장과 다른 기록을 가지고 있어 그 사본 쓰기를 멈췄습니다. 주문은 막지 않습니다.',
    '대조 보드에서 어긋남을 확인하십시오. 기기 복원 또는 새 기준점은 사람만 할 수 있습니다.',
    AppRoutes.ledgerDiffs,
  ),
  // ── 🆕 E3d-1 SAF 경고 제안 4(04 §1 Level 3 · §5-3 v2.46 · R177) — 주문은 막지 않는다 · 넘은 첫날 1건 ──
  'DEFENSIVE_FLOOR_BREACHED': AlertText(
    '방어 자산 비중이 하한 밑으로 내려갔습니다',
    '슬리브 C(채권 · 금)가 총자산의 하한보다 작아졌습니다. 주문은 막지 않습니다.',
    '슬리브 배분을 확인하고 다음 리밸런싱에서 바로잡을지 검토하십시오.',
    AppRoutes.holdingsAllocation,
  ),
  'GOLD_SHARE_HIGH': AlertText(
    '금 비중이 감시선을 넘었습니다',
    '금 ETF(슬리브 B · C 합)가 총자산의 감시선을 넘었습니다. 강제 매도는 하지 않습니다.',
    '슬리브 배분을 확인하고 안건으로 올릴지 검토하십시오.',
    AppRoutes.holdingsAllocation,
  ),
  'FINANCIAL_INCOME_CAP_EXCEEDED': AlertText(
    '올해 금융소득이 종합과세 기준을 넘었습니다',
    '일반계좌의 올해 누계 금융소득이 기준을 넘었습니다. 주문은 막지 않습니다.',
    '세후 리포트에서 올해 누계를 확인하고 세무 영향을 검토하십시오.',
    AppRoutes.reportAfterTax,
  ),
  'KRW_LIQUIDITY_LOW': AlertText(
    '원화 유동성이 아주 적습니다',
    '원화 현금과 파킹 자산을 합친 몫이 총자산의 하한보다 작아졌습니다.',
    '다음 납입 · 리밸런싱 때 원화 현금이 모자라지 않은지 보십시오.',
    AppRoutes.holdingsAllocation,
  ),
};

/// 코드의 글자 — 🔴 모르는 코드 = [ArgumentError](지어내지 않는다).
AlertText alertTextOf(String code) {
  final AlertText? t = kAlertTexts[code];
  if (t == null) throw ArgumentError.value(code, 'code', '문구 사전에 없는 알림 코드');
  return t;
}

/// 센터 기간(R69 I2 — 한국 날 기준 오늘 포함).
const int kAlertWindowDays = 7;

/// 빈 센터 문장(R69 I4 · 픽스처 `alert_center_empty`).
const String kAlertEmptyLabel = '새 알림이 없습니다. 이상이 생기면 바로 알립니다.';

/// 상세 없음 문장(R69 I4 · 픽스처 `alert_detail_missing`).
const String kAlertMissingLabel = '이 알림은 더 이상 없습니다. 알림 센터에서 최근 알림을 확인하십시오.';

/// 저장된 알림 한 건(+ 확인 · 사다리 단계).
class StoredAlert {
  /// 알림을 만든다.
  const StoredAlert({
    required this.alertId,
    required this.code,
    required this.level,
    required this.raisedAtUtc,
    this.ackedAtUtc,
    this.escalationSteps = 0,
    this.deepLink,
  });

  /// id · 코드.
  final String alertId, code;

  /// 🆕 E11q-q6c(R240 · 02 §3-10 · K45) — 이 알림의 목적지(null = 문구 사전의 링크). 저장소가 붙인다:
  /// `SELF_AUDIT_DUE` = 지금 서 있는 실사 표식의 그 달 · 그 계좌 `L-3`.
  final String? deepLink;

  /// 등급(저장 값).
  final AlertLevel level;

  /// 발생 시각.
  final DateTime raisedAtUtc;

  /// 확인 시각(null = 미확인).
  final DateTime? ackedAtUtc;

  /// 적힌 사다리 단계 수(0~2).
  final int escalationSteps;
}

/// `AckState`(R69 I7) — 사다리가 걸린 P0 만 · 아니면 null.
AckState? ackStateOf(StoredAlert a) {
  if (!alertHasLadder(a.code)) return null;
  final bool acked = a.ackedAtUtc != null;
  final String label = acked
      ? '수신 확인함'
      : switch (a.escalationSteps) {
          0 => '수신 확인 전',
          1 => '수신 확인 전 · 백업 채널로 보냈습니다',
          _ => '수신 확인 전 · 반복 알람을 울렸습니다',
        };
  return AckState(
    acked: acked,
    ackedAt: a.ackedAtUtc,
    stateLabel: label,
    escalationStep: a.escalationSteps,
  );
}

/// 알림 한 건의 VM(R69 I6).
AlertItem alertItemOf(StoredAlert a) {
  final AlertText t = alertTextOf(a.code);
  return AlertItem(
    alertId: a.alertId,
    level: a.level,
    raisedAt: a.raisedAtUtc,
    code: a.code,
    title: t.title,
    bodyText: t.body,
    actionLine: t.action,
    groupedCount: 1,
    deepLink: a.deepLink ?? t.deepLink,
    ack: ackStateOf(a),
    raisedAtText: kstMinuteText(a.raisedAtUtc).substring(11),
    detailDeepLink: AppRoutes.alertDetail.replaceFirst(':alertId', a.alertId),
  );
}

String _windowStart(DateTime nowUtc) {
  final String today = kstDateText(nowUtc);
  final DateTime d = DateTime.utc(
    int.parse(today.substring(0, 4)),
    int.parse(today.substring(5, 7)),
    int.parse(today.substring(8, 10)),
  ).subtract(const Duration(days: kAlertWindowDays - 1));
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

int _recentFirst(StoredAlert a, StoredAlert b) {
  final int t = b.raisedAtUtc.compareTo(a.raisedAtUtc);
  return t != 0 ? t : a.alertId.compareTo(b.alertId);
}

class _Visible {
  _Visible(Iterable<StoredAlert> rows, DateTime nowUtc) {
    final String start = _windowStart(nowUtc);
    bool inWindow(StoredAlert a) =>
        kstDateText(a.raisedAtUtc).compareTo(start) >= 0;
    final List<StoredAlert> unacked = <StoredAlert>[], acked = <StoredAlert>[];
    for (final StoredAlert a in rows) {
      if (a.level == AlertLevel.p0) {
        if (a.ackedAtUtc == null) {
          unacked.add(a);
        } else if (inWindow(a)) {
          acked.add(a);
        }
      } else if (inWindow(a)) {
        (a.level == AlertLevel.p1 ? p1 : p2).add(a);
      }
    }
    pinned = <StoredAlert>[
      ...unacked..sort(_recentFirst),
      ...acked..sort(_recentFirst),
    ];
    p1.sort(_recentFirst);
    p2.sort(_recentFirst);
  }

  late final List<StoredAlert> pinned;
  final List<StoredAlert> p1 = <StoredAlert>[], p2 = <StoredAlert>[];

  Iterable<StoredAlert> get all => <StoredAlert>[...pinned, ...p1, ...p2];
}

/// 알림 기준(R69 I8).
AsOf alertAsOf(DateTime nowUtc) {
  final String day = kstDateText(nowUtc);
  return AsOf(
    observedAt: nowUtc.toUtc(),
    tradeDate: TradeDate(day),
    source: AsOfSource.localSqlite,
    staleAfter: kReconStaleAfter,
    label: '알림 기준 $day',
  );
}

/// 인박스(R69 I5) — 고정 P0 → P1 → P2 · [min] = 그 등급까지.
List<AlertItem> alertInboxOf({
  required Iterable<StoredAlert> rows,
  required DateTime nowUtc,
  AlertLevel? min,
}) => <AlertItem>[
  for (final StoredAlert a in _Visible(rows, nowUtc).all)
    if (min == null || a.level.index <= min.index) alertItemOf(a),
];

/// 센터(R69 I2 · I3 · I4).
AlertCenterVm alertCenterOf({
  required Iterable<StoredAlert> rows,
  required DateTime nowUtc,
  required bool p0Only,
}) {
  final _Visible v = _Visible(rows, nowUtc);
  final String today = kstDateText(nowUtc);
  final List<AlertSection> sections = <AlertSection>[];
  if (!p0Only) {
    final Set<String> days = <String>{
      for (final StoredAlert a in <StoredAlert>[...v.p1, ...v.p2])
        kstDateText(a.raisedAtUtc),
    };
    for (final String day
        in days.toList()..sort((String a, String b) => b.compareTo(a))) {
      final List<AlertItem> rows1 = <AlertItem>[
        for (final StoredAlert a in v.p1)
          if (kstDateText(a.raisedAtUtc) == day) alertItemOf(a),
      ];
      final List<AlertItem> rows2 = <AlertItem>[
        for (final StoredAlert a in v.p2)
          if (kstDateText(a.raisedAtUtc) == day) alertItemOf(a),
      ];
      sections.add(
        AlertSection(
          headerText: day == today ? '오늘' : day,
          rows: rows1,
          digestLabel: rows2.isEmpty ? null : 'P2 ${rows2.length}건',
          digestRows: rows2,
        ),
      );
    }
  }
  final List<AlertItem> pinned = <AlertItem>[
    for (final StoredAlert a in v.pinned) alertItemOf(a),
  ];
  return AlertCenterVm(
    asOf: alertAsOf(nowUtc),
    pinned: pinned,
    sections: sections,
    emptyLabel: pinned.isEmpty && sections.isEmpty ? kAlertEmptyLabel : null,
  );
}

/// 상세(R69 I4) — 센터 · 인박스에 보이는 알림만 · 아니면 없음 문장.
AlertDetailVm alertDetailOf({
  required Iterable<StoredAlert> rows,
  required DateTime nowUtc,
  required String alertId,
}) {
  for (final StoredAlert a in _Visible(rows, nowUtc).all) {
    if (a.alertId == alertId) {
      return AlertDetailVm(asOf: alertAsOf(nowUtc), item: alertItemOf(a));
    }
  }
  return AlertDetailVm(
    asOf: alertAsOf(nowUtc),
    missingLabel: kAlertMissingLabel,
  );
}
