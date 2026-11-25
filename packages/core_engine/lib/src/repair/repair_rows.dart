// X5 정정 이력 표시 행 빌더(순수 · 설계 13 §8 R123 G1~G6 · 01 §21 K24 · K25 · 02 §5-2 · 픽스처 `m6/ledger_repairs_4`).
//
// 🔴 차례 = 엔진 — 원본의 적용 시각 역순 묶음 · 묶음 안 = 원본 → 정정 → 정정의 정정(«원본 아래 계단식»).
// 🔴 문장 · 대상 · 방향 · 원인 글자 = 엔진 — 화면은 원값을 비교하지 않는다.
// 🔴 모르는 대상 종류 · 원인 = 실패(글자를 지어내지 않는다) · 대체 고리 = `StateError`.

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart'
    show
        AppRoutes,
        ChipTone,
        LedgerRepairRow,
        LinkAction,
        OriginCodes,
        TradeDate;

import '../ops/ledger_hash.dart' show chainStampText;
import '../ops/ledger_views.dart' show kOriginLabels, kstMinuteText;
import 'repair_plan.dart' show RepairDirection;

/// 저장된 정정 한 행(`ledger_repair` + `ledger_repair_detail`).
class StoredLedgerRepair {
  /// 만든다.
  const StoredLedgerRepair({
    required this.repairId,
    required this.diffId,
    required this.direction,
    required this.originCode,
    required this.evidenceHash,
    required this.appliedAtUtc,
    required this.chainHash,
    required this.targetJson,
    this.decisionId,
    this.supersedes,
    this.recomputedFrom,
  });

  /// 정정 id.
  final String repairId;

  /// diff id.
  final String diffId;

  /// 방향 글자.
  final String direction;

  /// 원인 코드.
  final String originCode;

  /// 근거 해시(그대로 보인다).
  final String evidenceHash;

  /// 적용 시각.
  final DateTime appliedAtUtc;

  /// 적용 직후 체인(상세 · 필수).
  final String chainHash;

  /// 대상(상세 · 엔진 JSON).
  final String targetJson;

  /// 결정.
  final String? decisionId;

  /// 대체한 앞 정정.
  final String? supersedes;

  /// 다시 센 첫 날.
  final String? recomputedFrom;
}

/// 대상 종류(`target_json.kind` — 닫힌 목록).
enum RepairTargetKind {
  /// 종목 수량(정본 정정).
  quantity('QUANTITY'),

  /// 새 기준점(정본 정정 · 대상 숨김).
  ledgerIntegrity('LEDGER_INTEGRITY'),

  /// 미러 체결 행(파생 재생성).
  mirrorExecRows('MIRROR_EXEC_ROWS'),

  /// 캘린더 이벤트(파생 재생성).
  calendarEvents('CALENDAR_EVENTS'),

  /// 아카이브 날(파생 재생성).
  archiveDays('ARCHIVE_DAYS'),

  /// 🆕 미결 244 ⓑ(설계 13 §8 R271 O6) — 원격 사본 스탬프 날(`ledger_stamp` · X5 `canonSupabase` 파생 재생성).
  ledgerStamps('LEDGER_STAMPS'),

  /// 시계열 재계산(파생 재생성 — 소급 정본 사실).
  timeseries('TIMESERIES');

  const RepairTargetKind(this.wire);

  /// 글자.
  final String wire;

  /// 정본 정정 대상인가.
  bool get canon =>
      this == RepairTargetKind.quantity ||
      this == RepairTargetKind.ledgerIntegrity;

  /// 글자 → 값(모르면 [FormatException]).
  static RepairTargetKind parse(String w) => values.firstWhere(
    (RepairTargetKind k) => k.wire == w,
    orElse: () => throw FormatException('target_json.kind', w),
  );
}

/// 정본 정정 원인 구(«~으로» · «~아» — 뒤에 «수량 정정» · «앞선 정정을 다시 정정»이 붙는다).
const Map<String, String> kRepairReasonPhrases = <String, String>{
  OriginCodes.fillLag: '브로커 기준으로',
  OriginCodes.manualOrder: '수동 주문 반영으로',
  OriginCodes.dbError: '원장 기록 오류를 바로잡아',
  OriginCodes.brokerError: '브로커 응답 오류를 바로잡아',
  OriginCodes.externalCashflow: '시스템 밖 입출금 반영으로',
  OriginCodes.corporateAction: '분할 · 병합 반영으로',
  OriginCodes.chainBroken: '체인 끊김을 바로잡아',
  OriginCodes.schemaSkew: '스키마 판 어긋남을 바로잡아',
  OriginCodes.advisoryFill: '안내 체결 반영으로',
  OriginCodes.unrecordedFill: '기록 안 된 체결 반영으로',
  OriginCodes.misrecordedFill: '잘못 기록된 체결을 바로잡아',
  OriginCodes.selfReportCorrection: '자가 보고 정정으로',
  OriginCodes.externalHolding: '시스템 밖 보유 반영으로',
  OriginCodes.accountMisdeclared: '계좌 신고 오류를 바로잡아',
};

/// 대체된 행 문구.
const String kRepairSupersededLabel = '이후 정정됨';

/// 결정 링크 문구.
const String kRepairDecisionLinkLabel = '결정 당시 근거 보기';

Map<String, Object?> _target(StoredLedgerRepair r) {
  final Object? j = jsonDecode(r.targetJson);
  if (j is! Map<String, Object?>) {
    throw FormatException('target_json 이 객체가 아니다', r.repairId);
  }
  return j;
}

int _count(Map<String, Object?> t) {
  final Object? n = t['count'];
  if (n is! int || n < 0) throw FormatException('target_json.count', '$n');
  return n;
}

String _str(Map<String, Object?> t, String k) {
  final Object? v = t[k];
  if (v is! String || v.isEmpty) throw FormatException('target_json.$k', '$v');
  return v;
}

int _int(Map<String, Object?> t, String k) {
  final Object? v = t[k];
  if (v is! int) throw FormatException('target_json.$k', '$v');
  return v;
}

/// 🔴 대상 글 — 종류별(LEDGER_INTEGRITY = «숨김»).
String repairTargetTextOf(StoredLedgerRepair r) {
  final Map<String, Object?> t = _target(r);
  return switch (RepairTargetKind.parse(_str(t, 'kind'))) {
    RepairTargetKind.quantity =>
      '${_str(t, 'symbol')} 수량 ${_int(t, 'before')} → ${_int(t, 'after')}주',
    RepairTargetKind.ledgerIntegrity => '숨김',
    RepairTargetKind.mirrorExecRows => '미러 체결 행 ${_count(t)}건',
    RepairTargetKind.calendarEvents => '캘린더 이벤트 ${_count(t)}건',
    RepairTargetKind.archiveDays => '아카이브 ${_count(t)}일',
    RepairTargetKind.ledgerStamps => '원격 스탬프 ${_count(t)}일',
    RepairTargetKind.timeseries => '시계열 재계산',
  };
}

/// 🔴 엔진 문장 — 방향 · 대상 종류 · 원인 · 대체 · 다시 센 첫 날.
String repairLabelOf(StoredLedgerRepair r) {
  final RepairDirection d = RepairDirection.parse(r.direction);
  final Map<String, Object?> t = _target(r);
  final RepairTargetKind k = RepairTargetKind.parse(_str(t, 'kind'));
  if (k.canon != (d == RepairDirection.canonCorrect)) {
    throw FormatException('방향과 대상 종류가 맞지 않다', '${d.wire} ${k.wire}');
  }
  final String head = switch (k) {
    RepairTargetKind.mirrorExecRows => '미러에 체결 ${_count(t)}행을 다시 보냈습니다',
    RepairTargetKind.calendarEvents => '캘린더 이벤트 ${_count(t)}건을 다시 썼습니다',
    RepairTargetKind.archiveDays => '아카이브 ${_count(t)}일을 다시 썼습니다',
    RepairTargetKind.ledgerStamps => '원격 사본에 스탬프 ${_count(t)}일을 다시 보냈습니다',
    RepairTargetKind.timeseries => '시계열을 다시 계산했습니다',
    RepairTargetKind.ledgerIntegrity => '새 기준점 선언 · 다시 스탬프',
    RepairTargetKind.quantity => () {
      final String? phrase = kRepairReasonPhrases[r.originCode];
      if (phrase == null) {
        throw ArgumentError.value(r.originCode, 'originCode', '정본 정정 원인 사전 밖');
      }
      return r.supersedes != null ? '$phrase 앞선 정정을 다시 정정' : '$phrase 수량 정정';
    }(),
  };
  return r.recomputedFrom == null ? head : '$head · ${r.recomputedFrom}부터 재계산';
}

/// 한 행 → 표시 행([superseded] = 뒤 행 하나가 이 행을 대체한다).
LedgerRepairRow ledgerRepairRowOf(
  StoredLedgerRepair r, {
  required bool superseded,
}) {
  final RepairDirection d = RepairDirection.parse(r.direction);
  final String? originLabel = kOriginLabels[r.originCode];
  if (originLabel == null) {
    throw ArgumentError.value(r.originCode, 'originCode', '원인 사전 밖');
  }
  return LedgerRepairRow(
    repairId: r.repairId,
    diffId: r.diffId,
    directionCode: d.wire,
    directionLabel: switch (d) {
      RepairDirection.derivedResync => '파생 재생성 · 자동',
      RepairDirection.canonCorrect => '정본 정정 · 승인',
    },
    originCode: r.originCode,
    decisionId: r.decisionId,
    evidenceHash: r.evidenceHash,
    supersedes: r.supersedes,
    recomputedFrom: r.recomputedFrom == null
        ? null
        : TradeDate(r.recomputedFrom!),
    appliedAt: r.appliedAtUtc,
    label: repairLabelOf(r),
    appliedAtText: '${kstMinuteText(r.appliedAtUtc)} 적용',
    directionTone: switch (d) {
      RepairDirection.derivedResync => ChipTone.neutral,
      RepairDirection.canonCorrect => ChipTone.caution,
    },
    originLabel: originLabel,
    targetText: repairTargetTextOf(r),
    decisionLink: r.decisionId == null
        ? null
        : LinkAction(
            label: kRepairDecisionLinkLabel,
            deepLink: AppRoutes.journalDecision.replaceFirst(
              ':decisionId',
              r.decisionId!,
            ),
          ),
    supersededLabel: superseded ? kRepairSupersededLabel : null,
    chainStampText: chainStampText(r.chainHash),
  );
}

int _byTime(StoredLedgerRepair a, StoredLedgerRepair b) {
  final int t = a.appliedAtUtc.compareTo(b.appliedAtUtc);
  return t != 0 ? t : a.repairId.compareTo(b.repairId);
}

/// 🔴 정정 이력 — 원본 시각 역순 묶음 · 묶음 안 = 원본 → 정정(대체 사슬 · 시각 차례) · 대체 고리 = [StateError].
List<LedgerRepairRow> ledgerRepairRowsOf(Iterable<StoredLedgerRepair> rows) {
  final Map<String, StoredLedgerRepair> byId = <String, StoredLedgerRepair>{};
  for (final StoredLedgerRepair r in rows) {
    if (byId.containsKey(r.repairId)) {
      throw StateError('같은 정정 id 가 둘: ${r.repairId}');
    }
    byId[r.repairId] = r;
  }
  // 목록 안에 대체 대상이 있을 때만 부모(없으면 그 행이 원본).
  String? parentOf(StoredLedgerRepair r) =>
      r.supersedes != null && byId.containsKey(r.supersedes)
      ? r.supersedes
      : null;
  final Map<String, List<StoredLedgerRepair>> children =
      <String, List<StoredLedgerRepair>>{};
  for (final StoredLedgerRepair r in byId.values) {
    final String? p = parentOf(r);
    if (p != null) (children[p] ??= <StoredLedgerRepair>[]).add(r);
  }
  for (final StoredLedgerRepair r in byId.values) {
    final Set<String> seen = <String>{r.repairId};
    String? p = parentOf(r);
    while (p != null) {
      if (!seen.add(p)) throw StateError('정정 대체 고리: ${r.repairId}');
      p = parentOf(byId[p]!);
    }
  }
  final List<StoredLedgerRepair> roots =
      byId.values.where((StoredLedgerRepair r) => parentOf(r) == null).toList()
        ..sort((StoredLedgerRepair a, StoredLedgerRepair b) {
          final int t = b.appliedAtUtc.compareTo(a.appliedAtUtc);
          return t != 0 ? t : a.repairId.compareTo(b.repairId);
        });
  final List<LedgerRepairRow> out = <LedgerRepairRow>[];
  void walk(StoredLedgerRepair r) {
    final List<StoredLedgerRepair> kids =
        (children[r.repairId] ?? <StoredLedgerRepair>[])..sort(_byTime);
    out.add(ledgerRepairRowOf(r, superseded: kids.isNotEmpty));
    kids.forEach(walk);
  }

  roots.forEach(walk);
  return out;
}
