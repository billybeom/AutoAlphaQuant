// C-44 보유현황 `H6-1`~`H6-3` — 01 §17 · §7 표 C-44(🆕 계약 v1.8 · R4 선행 설계서 2026-10-20 §4-1).
//
// 정의: 「보유 화면 셋은 엔진이 묶어 준 VM 하나씩만 그린다 — 카드 수 = 목록 길이 · 가림 = 문자열·기하 null ·
//   손익은 펼칠 때만 · 화면은 묶지도 거르지도 더하지도 가리지도 않는다」. C-43 꼴 — 픽스처 불변식(A) +
//   화면 소스 스캔(B)을 한 파일에 둔다(대상이 한 패키지 세 화면).
//
// A. 픽스처·DTO 불변식(①~⑪) — 숫자 리터럴을 코드에 적지 않고 픽스처끼리 맞댄다.
//   ① 허용 키 목록(VM·카드·섹션·상세·배분 VM·게이지·보유 행·손익·배분 행·시스템 밖 행·손절선) + DTO 필드 집합 == 목록.
//   ② 손익 격리 — 기본 표본에 손익 키 0 · 펼침 표본의 손익 글자 · «열람 기록» 0(발주자 결정 ⑤).
//   ③ 표시 문자열·가림 — 글자 비지 않음 · INTEGRITY «숨김»(== journal_masked_integrity) · 시스템 밖 수량 그대로(K14) ·
//      RECON 대상 행만 끝 «?»(대상 = 상세 RECON 표본의 보유 · 그 슬리브 배분 행 — 픽스처끼리 · 그 밖 행 == 정상판 ·
//      대상 행에서 대상 글자의 «?» 만 떼면 정상판과 같다) · INTEGRITY 손절선 수준·기준 글자 «숨김» ·
//      INTEGRITY·L-3 가림판 보유 행 트랜치 칩 = 빈 목록(✅ K29 칩 빼기) + 정상판에는 칩이 있다.
//   ④ 정체성·일치 — holding_id 유일 · B·POT 같은 종목 표본 · holdings_6 == 펼침판 · 상세 holding == 목록 행 ·
//      펼침판 − pnl == 정상판 · 뷰어판 − 토글·섹션 == 정상판 · 링크 = 그 행의 id.
//   ⑤ 카드 구조 — 카탈로그 최상위 순·라벨 · POT 행 = A 카드 맨 끝 + sub_book_label(K17) · scope MANAGED · 빈 ⇔ 문장.
//   ⑥ 배분 — 순서(A → POT → … → CASH) · 회계 기준 · 밴드 축 짝 · 밴드 행 = B 만(K27) · 게이지 순서 · 비율 짝 ·
//      게이지 ⇔ 밴드 행 · 게이지 실측 위치 ↔ band_state(OUT_OF_BAND ⇔ 밴드 밖) ·
//      INTEGRITY 기하 0 · RECON 기하 유지 · 카드 머리 == 배분 행 · 트랜치 글자 «잔여·남은·초기·진행률» 0.
//   ⑦ 손절선 — 행 ⇔ 문장 · 등급 코드 ∈ StopTierCodes · ⑥ 수준 글자 == holdings_6 의 옛 절대 손절선.
//   ⑧ 이력 — 원천 행 JSON 그대로 · 같은 보유 · 시간 역순 · 빈 ⇔ 문장 · 이력 표본(⑥ · ⑮) 행 ≥ 1(공허 통과 방지).
//   ⑨ 미결 82(보유 몫) — 라벨 = 입금 정본 · 두 입금 픽스처 일치 · 옛 종목 0.
//   ⑩ 트랜치·배지 — 트랜치 = B 행만 · 같은 VM 안 B 행 동일 · B·POT 금 상한 배지 0.
//   ⑪ 링크 — 「비중 보기」 = holdingsAllocation(검사한 링크 ≥ 1) · 상태 칩 = handbook|null · 시스템 밖 행 링크 키 0.
//
// B. 화면 소스 스캔(⑫~⑳) — 대상 = `packages/ui_journal/lib/src/holdings_overview.dart` · `holding_detail.dart` ·
//    `holdings_allocation.dart` + `lib/src/holdings/**`(01 §17-8 · 설계서 §2-5). 전처리 = ⑫⑬⑭⑮⑰⑱ 은 `stripComments`
//    (문자열 보간 안 코드까지 본다) · ⑯ 은 `stripCommentsAndStrings`(C-4 와 같은 전처리 — Key 문자열 `'h61-…'` 의
//    `1-` 오탐 차단) · ⑲ = C-42 ⑥ 정의 + `원`·`주`. 대상 0 = 공허 통과 + 대상 수 출력(C-43 ⑩ 선례).
//   ⑫ 가드 — `packages/ui_*/lib`(셸 제외)에서 H6 전용 이름을 말하는 파일 ⊆ 대상.
//   ⑬ 호출 금지 목록 · ⑭ 구독 인자 · ⑮ 원값·키 · ⑯ 기하 산술 · ⑰ 가공·정렬·거르기·화면 가림 · ⑱ 분기·셸·포맷 낱말 ·
//   ⑲ 숫자 리터럴 · ⑳ 자체 검증(양성 = 걸린 조항 출력 · 음성 = 통과).
// 🔴 대상 파일이 아직 없으면(`R4a-Bob-H61` 전) ⑬~⑲ 은 통과한다 — 없는 파일로 실패시키지 않는다. ⑫ 가드는 늘 실대상을 본다.
// 🔴 픽스처 값(수량·비중·금액)을 이 파일에 적지 않는다 — 픽스처끼리 맞댄다. 자체 검증 스니펫의 수치는 뜻 없는 자리표시자다.

import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

// ─── A. 픽스처 ────────────────────────────────────────────────────────────────

const String _ovNormal = FixturePaths.m6HoldingsOverviewNormal;
const String _ovRecon = FixturePaths.m6HoldingsOverviewRecon;
const String _ovIntegrity = FixturePaths.m6HoldingsOverviewIntegrity;
const String _ovEmpty = FixturePaths.m6HoldingsOverviewEmpty;
const String _ovPnl = FixturePaths.m6HoldingsOverviewPnl;
const String _ovViewer = FixturePaths.m6HoldingsOverviewViewer;
const String _dtWithStops = FixturePaths.m6HoldingDetailWithStops;
const String _dtNoStop = FixturePaths.m6HoldingDetailNoStop;
const String _dtPnl = FixturePaths.m6HoldingDetailPnl;
const String _dtRecon = FixturePaths.m6HoldingDetailRecon;
const String _dtIntegrity = FixturePaths.m6HoldingDetailIntegrity;
const String _alInBand = FixturePaths.m6AllocationInBand;
const String _alOutOfBand = FixturePaths.m6AllocationOutOfBand;
const String _alTranche = FixturePaths.m6AllocationTrancheProgress;
const String _alParking = FixturePaths.m6AllocationParkingLarge;
const String _alIntegrity = FixturePaths.m6AllocationIntegrity;
const String _alRecon = FixturePaths.m6AllocationRecon;
const String _alEmpty = FixturePaths.m6AllocationEmpty;
const String _holdings6 = FixturePaths.holdings6;
const String _external2 = FixturePaths.m6ExternalHoldings2;

const List<String> _overviews = <String>[
  _ovNormal,
  _ovRecon,
  _ovIntegrity,
  _ovEmpty,
  _ovPnl,
  _ovViewer,
];
const List<String> _details = <String>[
  _dtWithStops,
  _dtNoStop,
  _dtPnl,
  _dtRecon,
  _dtIntegrity,
];
const List<String> _allocations = <String>[
  _alInBand,
  _alOutOfBand,
  _alTranche,
  _alParking,
  _alIntegrity,
  _alRecon,
  _alEmpty,
];

/// 보유 행을 싣는 표본(신설 보유 11 + 평면 창구 표본).
const List<String> _holdingFixtures = <String>[
  ..._overviews,
  ..._details,
  _holdings6,
];

/// ② `includePnl` 기본 표본(펼침판 ⑤⑧ · 평면 표본 holdings_6 제외 · 배분 7 포함).
const List<String> _defaultPnlFixtures = <String>[
  _ovNormal,
  _ovRecon,
  _ovIntegrity,
  _ovEmpty,
  _dtWithStops,
  _dtNoStop,
  _dtRecon,
  _dtIntegrity,
  _ovViewer,
  ..._allocations,
];

/// ④ 상세 → 그 holding 의 원천 보유현황 표본(같은 holding_id 행 · 손익 제외).
const Map<String, String> _detailSource = <String, String>{
  _dtWithStops: _ovNormal,
  _dtNoStop: _ovNormal,
  _dtPnl: _ovNormal,
  _dtRecon: _ovRecon,
  _dtIntegrity: _ovIntegrity,
};

/// ⑥ 카드 머리 → 같은 슬리브 배분 행의 원천(① ↔ ⑩ · ② ↔ ⑯ · ③ ↔ ⑭ · ⑤⑱ ↔ ⑩).
const Map<String, String> _cardAllocationSource = <String, String>{
  _ovNormal: _alInBand,
  _ovRecon: _alRecon,
  _ovIntegrity: _alIntegrity,
  _ovPnl: _alInBand,
  _ovViewer: _alInBand,
};

/// ⑧ 상세 → 이력 원천(일지 행 JSON 그대로).
const Map<String, String> _historySource = <String, String>{
  _dtWithStops: FixturePaths.journal30,
  _dtNoStop: FixturePaths.journal30,
  _dtPnl: FixturePaths.journal30,
  _dtRecon: FixturePaths.journal30,
  _dtIntegrity: FixturePaths.m6JournalMaskedIntegrity,
};

/// ⑥ 🔴 밴드 행 집합(K27 ✅ 2026-10-21 — SPEC `core_band.sleeve_b_band` 하나 · 집합 상수는 이 테스트 한 곳).
const Set<String> _bandSleeves = <String>{'B'};

/// ① 허용 키(🔴 목록에 없는 키 = 01 §17 개정이 먼저 · C-34 ⑧ 선례).
const Set<String> _overviewKeys = <String>{
  'cards',
  'external',
  'allocation_link',
  'pnl_toggle_label',
  'empty_label',
  'as_of',
};
const Set<String> _cardKeys = <String>{
  'sleeve',
  'title_text',
  'allocation',
  'rows',
  'rows_empty_text',
};
const Set<String> _sectionKeys = <String>{
  'title_text',
  'notice_text',
  'banner_text',
  'rows',
};
const Set<String> _detailKeys = <String>{
  'holding',
  'sleeve_label',
  'entry_decision_link',
  'stop_lines',
  'no_stop_line_text',
  'recent_entries',
  'recent_empty_label',
  'pnl_toggle_label',
  'as_of',
};
const Set<String> _allocationVmKeys = <String>{
  'rows',
  'notice_text',
  'empty_label',
  'as_of',
};
const Set<String> _gaugeKeys = <String>{
  'actual_normalized',
  'target_normalized',
  'band_low_normalized',
  'band_high_normalized',
};

/// `HoldingRow` = 기존 17 + 🆕 v1.8 7.
const Set<String> _holdingKeys = <String>{
  'symbol',
  'symbol_label',
  'sleeve',
  'account_alias',
  'quantity',
  'avg_price',
  'entry_date',
  'entry_decision',
  'entry_reasons',
  'sma_tranches',
  'gates',
  'stop_line',
  'momentum',
  'pnl',
  'scope',
  'scope_label',
  'as_of',
  'holding_id',
  'quantity_text',
  'avg_price_text',
  'weight_text',
  'pending_text',
  'sub_book_label',
  'detail_deep_link',
};

/// `HoldingPnl` = 기존 3 + 🆕 v1.8 2.
const Set<String> _pnlKeys = <String>{
  'unrealized_pnl',
  'pnl_pct',
  'disclosure_note',
  'pnl_text',
  'pnl_pct_text',
};

/// `SleeveAllocationRow` = 기존 12 + 🆕 v1.8 7.
const Set<String> _allocationRowKeys = <String>{
  'sleeve',
  'basis',
  'deployed_text',
  'parking_text',
  'deployed_ratio',
  'parking_ratio',
  'tranche_state_text',
  'deployed_pct_text',
  'parking_pct_text',
  'parent_sleeve',
  'engine_column_note',
  'parking_note_text',
  'sleeve_label',
  'sleeve_weight',
  'band_state',
  'band_state_label',
  'gauge',
  'band_note_text',
  'state_chips',
};

/// `ExternalHoldingRow` = 기존 8 + 🆕 v1.8 `quantity_text`.
const Set<String> _externalKeys = <String>{
  'external_id',
  'symbol',
  'symbol_label',
  'account_alias',
  'quantity',
  'registered_on',
  'scope_label',
  'decision',
  'quantity_text',
};

/// `StopLineNormalized` 6.
const Set<String> _stopLineKeys = <String>{
  'tier_code',
  'tier_label',
  'level',
  'level_text',
  'is_active',
  'basis_label',
};

/// ② 손익 키 — 정확 일치(C-6 `_pnlJsonKeys` 꼴 + 표시 문자열 2 · 🔵 `pnl_toggle_label` 은 토글 글자라 허용).
const Set<String> _pnlJsonKeys = <String>{
  'pnl',
  'pnl_text',
  'pnl_pct',
  'pnl_pct_text',
  'unrealized_pnl',
  'realized_pnl',
  'return_pct',
};

/// ③ 가림판의 관리 대상 행 글자 3.
const List<String> _maskedHoldingKeys = <String>[
  'quantity_text',
  'avg_price_text',
  'weight_text',
];

/// ③ 가림판의 배분 행 글자 6.
const List<String> _maskedAllocationKeys = <String>[
  'deployed_text',
  'parking_text',
  'deployed_pct_text',
  'parking_pct_text',
  'tranche_state_text',
  'band_note_text',
];

/// ③ RECON 대상 배분 행의 금액·% 글자 4.
const List<String> _reconAllocationKeys = <String>[
  'deployed_text',
  'parking_text',
  'deployed_pct_text',
  'parking_pct_text',
];

final RegExp _digit = RegExp('[0-9]');

/// ⑥ 트랜치 글자의 «끝이 있는 진행률» 낱말(02 `H6-3` 수용 (f) · P 회차).
final RegExp _trancheProgressWords = RegExp('잔여|남은|초기|진행률');

/// ⑨ 미결 82 이전의 옛 종목(입금 정본 D9 ② 에서 빠진 것).
const Set<String> _retiredSymbols = <String>{'379810', '132030', '357870'};

/// ⑩ 금 8% 상한 배지 — C 리밸런싱 한정(E14 · B·POT 행에 오지 않는다).
const Set<String> _goldCapGates = <String>{'SAF-208', 'SAF-209'};

// ─── A. 읽기 도우미 ──────────────────────────────────────────────────────────

List<Map<String, Object?>> _rows(String path) =>
    decodeEnvelope(readFixture(path)).rows;

Map<String, Object?> _vm(String path) => _rows(path).single;

List<Map<String, Object?>> _list(Object? v) => <Map<String, Object?>>[
  for (final Object? x in (v as List<Object?>?) ?? const <Object?>[])
    x! as Map<String, Object?>,
];

Map<String, Object?>? _map(Object? v) => v as Map<String, Object?>?;

Map<String, Object?> _without(Map<String, Object?> m, Set<String> keys) =>
    <String, Object?>{
      for (final MapEntry<String, Object?> e in m.entries)
        if (!keys.contains(e.key)) e.key: e.value,
    };

/// 보유 행(카드 순 · 행 순) — 평면 표본은 봉투 행 · 상세는 `holding` 1행.
List<Map<String, Object?>> _holdingRows(String path) {
  if (path == _holdings6) {
    return _rows(path);
  }
  final Map<String, Object?> vm = _vm(path);
  if (_details.contains(path)) {
    return <Map<String, Object?>>[_map(vm['holding'])!];
  }
  return <Map<String, Object?>>[
    for (final Map<String, Object?> c in _list(vm['cards']))
      ..._list(c['rows']),
  ];
}

/// 배분 행 — 배분 VM 의 `rows`.
List<Map<String, Object?>> _allocationRows(String path) =>
    _list(_vm(path)['rows']);

/// 카드 머리 배분 행.
List<Map<String, Object?>> _cardAllocations(String path) =>
    <Map<String, Object?>>[
      for (final Map<String, Object?> c in _list(_vm(path)['cards']))
        _map(c['allocation'])!,
    ];

/// 시스템 밖 행 — 보유현황 섹션 + 등록 목록 원천.
Map<String, List<Map<String, Object?>>> _externalRows() =>
    <String, List<Map<String, Object?>>>{
      for (final String p in _overviews)
        if (_map(_vm(p)['external']) case final Map<String, Object?> s)
          p: _list(s['rows']),
      _external2: _rows(_external2),
    };

/// 입금 정본의 종목 → 라벨(§3-0 대응표의 원천).
Map<String, String> _depositLabels(String path) {
  final Map<String, String> out = <String, String>{};
  void walk(Object? n) {
    if (n is Map<String, Object?>) {
      final Object? s = n['symbol'];
      final Object? l = n['symbol_label'];
      if (s is String && l is String) {
        expect(out[s] ?? l, l, reason: '$path — 같은 종목에 라벨이 둘이다: $s');
        out[s] = l;
      }
      n.values.forEach(walk);
    } else if (n is List<Object?>) {
      n.forEach(walk);
    }
  }

  walk(decodeEnvelope(readFixture(path)).rows);
  return out;
}

/// 가림 글자 — `m6/journal_masked_integrity` 의 `quantity_text`(그 픽스처 전 행이 같은 글자).
String _maskedText() {
  final Set<String> values = <String>{
    for (final Map<String, Object?> r in _rows(
      FixturePaths.m6JournalMaskedIntegrity,
    ))
      r['quantity_text']! as String,
  };
  expect(values, hasLength(1), reason: '가림 원천의 글자가 하나가 아니다: $values');
  return values.single;
}

/// 문자열 잎 전부.
Iterable<String> _strings(Object? n) sync* {
  if (n is String) {
    yield n;
  } else if (n is Map<String, Object?>) {
    for (final Object? v in n.values) {
      yield* _strings(v);
    }
  } else if (n is List<Object?>) {
    for (final Object? v in n) {
      yield* _strings(v);
    }
  }
}

/// 라우트 패턴의 파라미터 하나를 끼운 기대값(테스트 쪽 조립 · C-43 `_decisionLink` 선례).
String _link(String pattern, String param, String value) {
  expect(pattern.split(':$param'), hasLength(2), reason: pattern);
  return pattern.replaceFirst(':$param', value);
}

/// 카탈로그 최상위 행(`rolls_up_to == null`)의 (슬리브, 라벨) — `order` 순.
List<(String, String)> _catalogTop() {
  final List<Map<String, Object?>> rows =
      _rows(FixturePaths.sleeveCatalog4)
          .where((Map<String, Object?> r) => r['rolls_up_to'] == null)
          .toList()
        ..sort(
          (Map<String, Object?> a, Map<String, Object?> b) =>
              (a['order']! as int).compareTo(b['order']! as int),
        );
  return <(String, String)>[
    for (final Map<String, Object?> r in rows)
      (r['sleeve']! as String, r['label']! as String),
  ];
}

// ─── B. 화면 소스 스캔 — 대상 ─────────────────────────────────────────────────

/// `H6-*` 화면 패키지(저장소 루트 기준).
const String _h6Package = 'packages/ui_journal';

/// 공개 파일 3(배럴 `ui_journal.dart` 가 export 한다 · 01 §17-8).
const List<String> _h6PublicFiles = <String>[
  'lib/src/holdings_overview.dart',
  'lib/src/holding_detail.dart',
  'lib/src/holdings_allocation.dart',
];

/// 내부 조각 폴더(`/` 로 끝난다 · 아래 전부가 대상 · 배럴 export 0).
const String _h6InternalDir = 'lib/src/holdings/';

bool _isH6Target(String rel) =>
    _h6PublicFiles.contains(rel) || rel.startsWith(_h6InternalDir);

String? _journalRel(String repoRel) => repoRel.startsWith('$_h6Package/')
    ? repoRel.substring(_h6Package.length + 1)
    : null;

// ─── B. 정규식 ────────────────────────────────────────────────────────────────

/// ⑫ `H6-*` 전용 이름(VM 6 · 열거 1 · 창구 3 · 주입 프로바이더 2).
final RegExp _h6Name = RegExp(
  r'\b(HoldingsOverviewVm|HoldingsSleeveCard|HoldingsExternalSection|HoldingDetailVm|'
  r'SleeveAllocationVm|SleeveBandGauge|SleeveBandState|watchHoldingsOverview|'
  r'watchHoldingDetail|watchAllocation|journalHoldingsRepositoryProvider|'
  r'journalRebalanceRepositoryProvider)\b',
);

/// ⑬ 부르지 않는 것(설계서 §2-6) — 평면 창구 · 카탈로그·플래그 · 일지 전부 · 원장 · 다른 리포지토리 ·
/// 명령 전부(🔴 `recordDisclosureView` 0 = 발주자 결정 ⑤) · 초안 포트 · 안전 상태 직접 구독 · 회차 창구.
final RegExp _forbiddenCalls = RegExp(
  r'watchHoldings\(|watchSleeves|watchFlags|ConfigRepository|JournalRepository|'
  r'watchTimeline|LedgerRepository|watchExternalHoldings|PerformanceRepository|'
  r'AdviceRepository|ExecutionGapRepository|CommandApi|recordDisclosureView|DraftStore|'
  r'\.watchState\(|watchEvents|watchEvent\(',
);

/// ⑭ 구독 인자 — 리터럴 `true` 로 펼치지 않는다(State 변수로만) · 배분은 인자 없이.
final List<RegExp> _subscriptionArgs = <RegExp>[
  RegExp(r'includePnl:\s*true'),
  RegExp(r'watchAllocation\(\s*[^)\s]'),
];

/// ⑮ 원값·키(🔵 `\.weight\b` 는 `SleeveWeight.weight` 원값만 겨눈다 — 행 필드는 `sleeveWeight`).
final List<RegExp> _rawKeys = <RegExp>[
  RegExp(
    r'\.(quantity|avgPrice|unrealizedPnl|pnlPct|absoluteStop|trailStop|customStop|'
    r'highWaterMark|level|weight|targetWeight|bandLow|bandHigh|symbol|sleeve|scope|'
    r'scopeLabel|basis|tierCode|entryDecision|blockedReasonCode|code|wire|isDeviation|'
    r'kindCode)\b',
  ),
  RegExp(r'\$\{?[\w.]*\.holdingId\b'),
  RegExp(r'Text\(\s*[\w.]*\.holdingId'),
  // 🆕 검증 반영 — 보간 없이 Key 생성자에 넣는 꼴(`ValueKey(r.holdingId)` · `ObjectKey(…)` · 형 인자 포함).
  RegExp(r'Key\s*(<[^>]*>)?\s*\(\s*[\w.]*\.holdingId'),
  RegExp(r'\.(stopLine|momentum)!'),
];

/// ⑯ 기하 산술(`stripCommentsAndStrings` 뒤) — 허용 = `× 폭` 하나(`x * width` · `width * x`).
final List<RegExp> _geometryMath = <RegExp>[
  RegExp(r'(Ratio|Normalized)\s*!?\s*[-+/]'),
  RegExp(r'[-+/]\s*[\w.!?]*(Ratio|Normalized)\b'),
  // 🆕 검증 반영 — `width - width * r.deployedRatio!` 꼴(여집합·여유 폭 · 앞 정규식은 `width *` 를 못 넘는다).
  RegExp(r'[-+/]\s*[\w.!?]+\s*\*\s*[\w.!?]*(Ratio|Normalized)\b'),
  RegExp(r'(?<![\w.$])1(\.0)?\s*-\s*'),
  RegExp(r'(Ratio|Normalized)\s*!?\s*\?\?'),
  RegExp(
    r'Normalized\s*!?\s*\*\s*[\w.!?]*Ratio|Ratio\s*!?\s*\*\s*[\w.!?]*Normalized',
  ),
];

/// ⑰ 문자열 가공 · 정렬·거르기 · 고르기(C-43 ⑮ 그대로) + 묶기·화면 가림(🔵 배너 분리는 대상 밖 `JournalSafetyBanners`).
final List<RegExp> _reshape = <RegExp>[
  RegExp(
    r'(?<!Labels)\.(substring|split|replaceAll|replaceFirst|contains|startsWith|'
    r'endsWith|indexOf|padLeft|padRight)\(',
  ),
  RegExp(
    r'(?<!Labels)\.(sort|sorted|reversed|where|whereType|firstWhere|lastWhere|'
    r'singleWhere|fold|reduce|take|takeWhile|skip|skipWhile|compareTo|toSet|'
    r'last|lastOrNull|sublist|getRange|elementAt|removeAt|removeWhere|retainWhere|'
    r'shuffle)\b',
  ),
  RegExp(r'\breverse:\s*true\b'),
  RegExp(r'\bmaxLines\b'),
  RegExp(r'TextOverflow\.ellipsis'),
  RegExp(r'\.trim\('),
  RegExp(r'groupBy|FlagIds|activeFlags|markerOnly'),
];

/// ⑱ 분기·셸·포맷 낱말(C-43 ⑭ 그대로) + 카드 수·플래그·슬리브·범위·기준 축 분기 · 라우트 상수.
final RegExp _branchWords = RegExp(
  r'operatingMode|OperatingMode|RunMode|runMode|FeatureFlags|kIsWeb|Platform\.|'
  r'DateTime\.now|DateTime\.timestamp|\bclock\.now\b|Scaffold|AppBar|SafeArea|'
  r'AppLinkSchemes|toStringAsFixed|toStringAsPrecision|NumberFormat|journal_draft|'
  r'satelliteEnabled|SleeveId\.|HoldingScope\.|AllocationBasis\.|AppRoutes\.',
);

/// ⑲ 소수부가 0 이 아닌 소수 리터럴(`16.0`·`0.0`·정수는 통과 — C-42 ⑥ 과 같은 식).
final RegExp _decimalLiteral = RegExp(r'(?<![\w.])\d+\.\d*[1-9]\d*(?![\d])');

// ─── B. 규칙 묶음 ─────────────────────────────────────────────────────────────

class _Hit {
  const _Hit(this.clause, this.text);
  final String clause;
  final String text;

  @override
  String toString() => '$clause «$text»';
}

/// 대상 파일 한 벌의 위반.
List<_Hit> _scan(String source) {
  final String code = stripComments(source);
  final String bare = stripCommentsAndStrings(source);
  return <_Hit>[
    for (final RegExpMatch m in _forbiddenCalls.allMatches(code))
      _Hit('⑬', m.group(0)!),
    for (final RegExp re in _subscriptionArgs)
      for (final RegExpMatch m in re.allMatches(code)) _Hit('⑭', m.group(0)!),
    for (final RegExp re in _rawKeys)
      for (final RegExpMatch m in re.allMatches(code)) _Hit('⑮', m.group(0)!),
    for (final RegExp re in _geometryMath)
      for (final RegExpMatch m in re.allMatches(bare)) _Hit('⑯', m.group(0)!),
    for (final RegExp re in _reshape)
      for (final RegExpMatch m in re.allMatches(code)) _Hit('⑰', m.group(0)!),
    for (final RegExpMatch m in _branchWords.allMatches(code))
      _Hit('⑱', m.group(0)!),
    for (final RegExpMatch m in _decimalLiteral.allMatches(code))
      _Hit('⑲', m.group(0)!),
    for (final String lit in _stringLiterals(code))
      if (lit.contains('%') || lit.contains('원') || lit.contains('주'))
        _Hit('⑲', lit),
  ];
}

/// 주석을 지운 소스의 문자열 리터럴(따옴표 포함 · C-43 `_stringLiterals` 와 같은 토큰 규칙).
List<String> _stringLiterals(String code) {
  final List<String> out = <String>[];
  int i = 0;
  final int n = code.length;
  while (i < n) {
    final String c = code[i];
    if (c != "'" && c != '"') {
      i++;
      continue;
    }
    final bool triple = i + 2 < n && code[i + 1] == c && code[i + 2] == c;
    final String terminator = triple ? c * 3 : c;
    final int start = i;
    i += terminator.length;
    while (i < n) {
      if (code[i] == r'\') {
        i += 2;
        continue;
      }
      if (code.startsWith(terminator, i)) {
        i += terminator.length;
        break;
      }
      if (!triple && code[i] == '\n') {
        break;
      }
      i++;
    }
    out.add(code.substring(start, i > n ? n : i));
  }
  return out;
}

/// ⑫ 가드 — H6 전용 이름을 말하는데 대상이 아닌 파일(저장소 기준 경로).
List<String> _h6MentionsOutside(Map<String, String> sources) => <String>[
  for (final MapEntry<String, String> e in sources.entries)
    if (!(_journalRel(e.key) != null && _isH6Target(_journalRel(e.key)!)) &&
        _h6Name.hasMatch(stripComments(e.value)))
      e.key,
];

// ─── B. 실대상 ────────────────────────────────────────────────────────────────

/// ⑫ 가드 대상 — `packages/ui_*/lib`(셸 제외 — 홈 블록 4·셸 배선 자리 · 저장소 기준 경로 → 원문).
final Map<String, String> _guardSources = <String, String>{
  for (final String p in uiPackageNames)
    if (p != 'ui_shell')
      for (final File f in dartSourcesIn(
        Directory('${repoRoot.path}/packages/$p/lib'),
      ))
        shortPath(f): f.readAsStringSync(),
};

/// `H6-*` 대상 파일(저장소 기준 경로 → 원문). 없으면 빈 지도(공허 통과).
final Map<String, String> _targets = <String, String>{
  for (final MapEntry<String, String> e in _guardSources.entries)
    if (_journalRel(e.key) != null && _isH6Target(_journalRel(e.key)!))
      e.key: e.value,
};

/// [clause] 의 실대상 위반.
List<String> _violations(String clause) => <String>[
  for (final MapEntry<String, String> f in _targets.entries)
    for (final _Hit h in _scan(f.value))
      if (h.clause == clause) '${f.key}: $h',
];

/// 출력(카드 0단계·C4 가 «대상 N파일»을 확인한다).
void _say(String line) {
  // ignore: avoid_print
  print(line);
}

// ─── B. ⑳ 자체 검증 스니펫 ───────────────────────────────────────────────────

/// 양성 — (스니펫, 반드시 걸려야 하는 조항).
const List<(String, String)> _positives = <(String, String)>[
  (r"Text('${r.quantity}주')", '⑮'),
  (r"Text('${r.quantity}주')", '⑲'),
  ('final double s = row.deployedRatio! + row.parkingRatio!;', '⑯'),
  ('final double p = 1 - a.deployedRatio!;', '⑯'),
  ('rows.where((r) => r.sleeve == SleeveId.a)', '⑰'),
  ('rows.where((r) => r.sleeve == SleeveId.a)', '⑮'),
  ('rows.where((r) => r.sleeve == SleeveId.a)', '⑱'),
  ('repo.watchHoldings()', '⑬'),
  ('repo.watchHoldingsOverview(includePnl: true)', '⑭'),
  ('repo.watchAllocation(range)', '⑭'),
  ('final bool masked = flags.activeFlags.any((f) => true);', '⑰'),
  ('if (flags.satelliteEnabled) {}', '⑱'),
  ('Text(h.holdingId)', '⑮'),
  (r"ValueKey('h61-row-${r.holdingId}')", '⑮'),
  ('final k = ValueKey(r.holdingId);', '⑮'),
  ('final double w100 = w.weight * 100;', '⑮'),
  ('final double x = r.sleeveWeight!.weight;', '⑮'),
  ('final double d = r.deployedRatio ?? 0;', '⑯'),
  ('final double z = g.actualNormalized * r.deployedRatio!;', '⑯'),
  ('final double gap = g.bandHighNormalized - g.actualNormalized;', '⑯'),
  ('final double parkW = width - width * r.deployedRatio!;', '⑯'),
  ('final double rest = width - width * g.actualNormalized;', '⑯'),
  ('cards.sort((a, b) => 0);', '⑰'),
  ("Text('80%')", '⑲'),
  ("Text('1,000원')", '⑲'),
  ('const double k = 0.42;', '⑲'),
  ('link.open(AppRoutes.holdingsAllocation);', '⑱'),
  ('ref.watch(x).watchState()', '⑬'),
  ('api.recordDisclosureView(e)', '⑬'),
  ('ref.watch(journalTimelineRepositoryProvider).watchTimeline()', '⑬'),
  ('ref.watch(ledger).watchExternalHoldings()', '⑬'),
  ('ref.watch(config).watchSleeves()', '⑬'),
  ('Text(stop.levelText); final l = stop.level;', '⑮'),
  ('if (r.scope == x) {}', '⑮'),
  ('final m = h.momentum!.label;', '⑮'),
  ('DateTime.now()', '⑱'),
  ('Text(t.symbolLabel, maxLines: 1)', '⑰'),
];

/// 음성 — 어느 조항에도 걸리지 않아야 한다.
const List<String> _negatives = <String>[
  'final double w0 = width * g.actualNormalized;',
  'final double w1 = g.bandLowNormalized * width;',
  'final double w2 = width * r.deployedRatio!;',
  'final double w3 = (c.maxWidth - 32) * g.actualNormalized;',
  'if (r.parentSleeve != null) {}',
  r"ValueKey('h61-card-$i')",
  r"ValueKey('h61-row-$c-$r')",
  "Text(card.allocation.sleeveWeight?.label ?? '')",
  'if (r.sleeveWeight case final SleeveWeight w?) { Text(w.label); }',
  'Text(r.quantityText)',
  'if (vm.allocationLink case final LinkAction l?) { opener.open(l.deepLink); }',
  'ref.watch(journalHoldingsRepositoryProvider).watchHoldingsOverview(includePnl: _expanded)',
  'ref.watch(journalHoldingsRepositoryProvider).watchHoldingDetail(widget.holdingId, includePnl: key.\$2)',
  'ref.watch(journalHoldingsRepositoryProvider).watchAllocation()',
  'ref.watch(journalRebalanceRepositoryProvider).watchNext()',
  'JournalSafetyBanners(safety: s)',
  'ref.watch(journalSafetyStateProvider)',
  'Text(entry.tradeDate.yyyyMmDd)',
  'Text(row.entryDate.yyyyMmDd)',
  'for (final (i, c) in vm.cards.indexed) {}',
  'if (vm.cards.isEmpty) {}',
  'Text(vm.cards.length.toString())',
  'Text(stop.levelText)',
  'Text(r.subBookLabel ?? r.weightText)',
  'const EdgeInsets.all(16.0)',
  '/* 1 - x 금지 */ const SizedBox(height: 12)',
  "Text(JournalLabels.holdingsStopLines) // '80%' 아님",
  'switch (r.bandState) { case SleeveBandState.inBand: break; }',
  'if (entry.detailDeepLink case final String l?) { opener.open(l); }',
];

void main() {
  group('C-44 보유현황 H6-1~H6-3 (01 §17 · 계약 v1.8)', () {
    // ═══ A. 픽스처·DTO 불변식 ═══════════════════════════════════════════════

    test(
      'C-44 ① 허용 키 목록 — VM·카드·섹션·상세·배분·보유 행·손익·시스템 밖·손절선 + DTO 필드 집합 == 목록',
      () {
        void keysOf(String at, Map<String, Object?> m, Set<String> allowed) {
          expect(
            m.keys.toSet().difference(allowed),
            isEmpty,
            reason: '$at — 허용 목록 밖 키(합계·손익 류 키가 붙었다 · 필드 추가 = 01 §17 개정이 먼저).',
          );
        }

        void holdingRow(String at, Map<String, Object?> r) {
          keysOf(at, r, _holdingKeys);
          if (_map(r['pnl']) case final Map<String, Object?> p) {
            keysOf('$at.pnl', p, _pnlKeys);
          }
        }

        void allocationRow(String at, Map<String, Object?> r) {
          keysOf(at, r, _allocationRowKeys);
          if (_map(r['gauge']) case final Map<String, Object?> g) {
            keysOf('$at.gauge', g, _gaugeKeys);
          }
        }

        int seen = 0;
        for (final String p in _overviews) {
          final Map<String, Object?> vm = _vm(p);
          keysOf(p, vm, _overviewKeys);
          for (final Map<String, Object?> c in _list(vm['cards'])) {
            keysOf('$p card', c, _cardKeys);
            allocationRow('$p card.allocation', _map(c['allocation'])!);
            for (final Map<String, Object?> r in _list(c['rows'])) {
              holdingRow('$p ${r['holding_id']}', r);
            }
          }
          if (_map(vm['external']) case final Map<String, Object?> s) {
            keysOf('$p external', s, _sectionKeys);
            for (final Map<String, Object?> r in _list(s['rows'])) {
              keysOf('$p external.rows', r, _externalKeys);
            }
          }
          seen++;
        }
        for (final String p in _details) {
          final Map<String, Object?> vm = _vm(p);
          keysOf(p, vm, _detailKeys);
          holdingRow('$p holding', _map(vm['holding'])!);
          for (final Map<String, Object?> s in _list(vm['stop_lines'])) {
            keysOf('$p stop_lines', s, _stopLineKeys);
          }
          seen++;
        }
        for (final String p in _allocations) {
          final Map<String, Object?> vm = _vm(p);
          keysOf(p, vm, _allocationVmKeys);
          for (final Map<String, Object?> r in _list(vm['rows'])) {
            allocationRow('$p ${r['sleeve']}', r);
          }
          seen++;
        }
        for (final Map<String, Object?> r in _rows(_holdings6)) {
          holdingRow('$_holdings6 ${r['holding_id']}', r);
        }
        for (final Map<String, Object?> r in _rows(_external2)) {
          keysOf(_external2, r, _externalKeys);
        }
        expect(seen, 18, reason: 'v1.8 신설 표본 18벌(01 §17-10).');

        // DTO 필드 집합 == 허용 목록(🔴 필드를 더하면 이 목록과 01 §17 이 함께 바뀐다 · include_if_null 기본).
        final HoldingsOverviewVm normal = HoldingsOverviewVm.fromJson(
          _vm(_ovNormal),
        );
        final HoldingsOverviewVm pnl = HoldingsOverviewVm.fromJson(_vm(_ovPnl));
        final HoldingDetailVm detail = HoldingDetailVm.fromJson(
          _vm(_dtWithStops),
        );
        final SleeveAllocationVm band = SleeveAllocationVm.fromJson(
          _vm(_alInBand),
        );
        final List<(String, Set<String>, Set<String>)>
        fields = <(String, Set<String>, Set<String>)>[
          ('HoldingsOverviewVm', normal.toJson().keys.toSet(), _overviewKeys),
          (
            'HoldingsSleeveCard',
            normal.cards.first.toJson().keys.toSet(),
            _cardKeys,
          ),
          (
            'HoldingsExternalSection',
            normal.external!.toJson().keys.toSet(),
            _sectionKeys,
          ),
          (
            'ExternalHoldingRow',
            normal.external!.rows.first.toJson().keys.toSet(),
            _externalKeys,
          ),
          (
            'HoldingRow',
            normal.cards.first.rows.first.toJson().keys.toSet(),
            _holdingKeys,
          ),
          (
            'HoldingPnl',
            pnl.cards.first.rows.first.pnl!.toJson().keys.toSet(),
            _pnlKeys,
          ),
          ('HoldingDetailVm', detail.toJson().keys.toSet(), _detailKeys),
          (
            'StopLineNormalized',
            detail.stopLines.first.toJson().keys.toSet(),
            _stopLineKeys,
          ),
          ('SleeveAllocationVm', band.toJson().keys.toSet(), _allocationVmKeys),
          (
            'SleeveAllocationRow',
            band.rows.first.toJson().keys.toSet(),
            _allocationRowKeys,
          ),
          (
            'SleeveBandGauge',
            <String>{
              for (final SleeveAllocationRow r in band.rows)
                if (r.gauge case final SleeveBandGauge g) ...g.toJson().keys,
            },
            _gaugeKeys,
          ),
        ];
        for (final (String type, Set<String> got, Set<String> allowed)
            in fields) {
          expect(
            got,
            allowed,
            reason:
                '$type 의 필드 집합이 허용 목록과 다르다 — 필드를 더했으면 01 §17 과 이 목록을 함께 고친다.',
          );
        }
      },
    );

    test('C-44 ② 손익 격리 — 기본 표본 손익 키 0 · 펼침 표본 글자 · «열람 기록» 0(결정 ⑤)', () {
      for (final String p in _defaultPnlFixtures) {
        final List<String> offenders = <String>[];
        walkJson(_vm(p), (String jsonPath, String key, Object? value) {
          if (_pnlJsonKeys.contains(key) && value != null) {
            offenders.add('$p $jsonPath');
          }
        });
        expect(
          offenders,
          isEmpty,
          reason: '$p — includePnl 기본(false) 표본에 손익이 실렸다(결정 8 · 02 수용 (e)).',
        );
      }
      for (final String p in <String>[_ovPnl, _dtPnl]) {
        int withPnl = 0;
        for (final Map<String, Object?> r in _holdingRows(p)) {
          final Map<String, Object?>? pnl = _map(r['pnl']);
          if (pnl == null) {
            continue;
          }
          withPnl++;
          for (final String k in <String>[
            'pnl_text',
            'pnl_pct_text',
            'disclosure_note',
          ]) {
            expect(
              (pnl[k] as String?) ?? '',
              isNotEmpty,
              reason:
                  '$p ${r['holding_id']}.$k — 손익 줄은 표시 문자열과 고지를 늘 함께 싣는다(02 §2-3).',
            );
          }
        }
        expect(withPnl, greaterThan(0), reason: '$p — 펼침 표본에 손익이 없다.');
      }
      expect(
        _holdingRows(_ovPnl)
            .where((Map<String, Object?> r) => r['pnl'] == null),
        isNotEmpty,
        reason: '전 행에 손익이 실리면 «엔진이 요청한 행에만 준다»(C-6)가 사라진다.',
      );
      for (final String p in _holdingFixtures) {
        for (final Map<String, Object?> r in _holdingRows(p)) {
          final Object? note = _map(r['pnl'])?['disclosure_note'];
          expect(
            note is String && note.contains('열람 기록'),
            isFalse,
            reason:
                '$p ${r['holding_id']} — 보유 손익 펼침은 열람 기록을 남기지 않는다(발주자 결정 ⑤ · K5).',
          );
        }
      }
    });

    test('C-44 ③ 표시 문자열·가림 — 글자 · INTEGRITY «숨김» · 시스템 밖 수량 그대로 · RECON 대상만 «?»', () {
      final String masked = _maskedText();
      expect(_digit.hasMatch(masked), isFalse, reason: '가림 글자에 숫자가 있다.');
      for (final String p in _holdingFixtures) {
        for (final Map<String, Object?> r in _holdingRows(p)) {
          for (final String k in _maskedHoldingKeys) {
            expect(
              (r[k] as String?) ?? '',
              isNotEmpty,
              reason: '$p ${r['holding_id']}.$k — 표시 문자열이 비었다(원값을 그리게 된다).',
            );
          }
        }
      }
      final Map<String, List<Map<String, Object?>>> externals = _externalRows();
      for (final MapEntry<String, List<Map<String, Object?>>> e
          in externals.entries) {
        for (final Map<String, Object?> r in e.value) {
          expect(
            (r['quantity_text'] as String?) ?? '',
            isNotEmpty,
            reason: '${e.key} ${r['external_id']}',
          );
        }
      }

      // INTEGRITY — 관리 대상 행 3글자 · 손절선 수준 · 배분 6글자 = 가림 글자 · 반영 대기 칩 부재.
      for (final String p in <String>[_ovIntegrity, _dtIntegrity]) {
        for (final Map<String, Object?> r in _holdingRows(p)) {
          for (final String k in _maskedHoldingKeys) {
            expect(r[k], masked, reason: '$p ${r['holding_id']}.$k');
          }
          expect(
            r['pending_text'],
            isNull,
            reason: '$p ${r['holding_id']} — INTEGRITY 에서 반영 대기 칩으로 수량이 샌다.',
          );
          expect(
            r['sma_tranches'],
            <Object?>[],
            reason:
                '$p ${r['holding_id']} — INTEGRITY·L-3 가림판의 트랜치 칩은 빈 목록이어야 한다(✅ K29 · 단계·채운 날이 진행을 드러낸다).',
          );
        }
      }
      // K29 짝 — 정상판에는 칩이 있다(가림판의 빈 목록이 «원래 없음» 이 아니라 «뺌» 임을 픽스처끼리 보인다).
      expect(
        _holdingRows(_ovNormal).where(
          (Map<String, Object?> r) => _list(r['sma_tranches']).isNotEmpty,
        ),
        isNotEmpty,
        reason: '$_ovNormal — 트랜치 칩이 있는 행이 없다(K29 대조가 공허하다).',
      );
      for (final Map<String, Object?> s in _list(
        _vm(_dtIntegrity)['stop_lines'],
      )) {
        expect(s['level_text'], masked, reason: '$_dtIntegrity 손절선 수준 글자');
        expect(
          s['basis_label'],
          masked,
          reason: '$_dtIntegrity 손절선 기준 글자(매수가 대비 % — 평균 매수가가 샌다)',
        );
      }
      for (final (String at, List<Map<String, Object?>> rows)
          in <(String, List<Map<String, Object?>>)>[
            (_alIntegrity, _allocationRows(_alIntegrity)),
            (
              '$_ovIntegrity cards[].allocation',
              _cardAllocations(_ovIntegrity),
            ),
          ]) {
        expect(rows, isNotEmpty, reason: at);
        for (final Map<String, Object?> r in rows) {
          for (final String k in _maskedAllocationKeys) {
            expect(r[k], masked, reason: '$at ${r['sleeve']}.$k');
          }
        }
      }
      // K14 — 시스템 밖 수량은 사람이 등록한 값이라 INTEGRITY 에서도 그대로다.
      final Map<String, Object?> normalById = <String, Object?>{
        for (final Map<String, Object?> r in externals[_ovNormal]!)
          r['external_id']! as String: r['quantity_text'],
      };
      final List<Map<String, Object?>> integrityExternal =
          externals[_ovIntegrity] ?? const <Map<String, Object?>>[];
      expect(integrityExternal, isNotEmpty, reason: '$_ovIntegrity 섹션이 없다.');
      for (final Map<String, Object?> r in integrityExternal) {
        expect(
          r['quantity_text'],
          normalById[r['external_id']],
          reason:
              '${r['external_id']} — 시스템 밖 수량은 가림 대상이 아니다(K14 ✅ · 02 §2-2 B18 ①).',
        );
      }

      // RECON — 대상 행만 글자 끝 «?»(대상 = 상세 RECON 표본의 보유 · 그 슬리브의 배분 행 — 픽스처끼리) ·
      // 대상 행에서 대상 글자의 «?» 만 떼면 정상판과 같다 · 그 밖 행 == 정상판(«?» 0).
      final Map<String, Object?> reconHolding = _map(_vm(_dtRecon)['holding'])!;
      void reconRows(
        String at,
        List<Map<String, Object?>> recon,
        List<Map<String, Object?>> normal,
        String idKey,
        List<String> reconPaths,
        Set<Object?> expected,
      ) {
        expect(recon.length, normal.length, reason: at);
        final Set<Object?> targets = <Object?>{};
        for (int i = 0; i < recon.length; i++) {
          final Map<String, Object?> a = recon[i];
          final Map<String, Object?> b = normal[i];
          expect(a[idKey], b[idKey], reason: '$at — 행 순서가 정상판과 다르다.');
          if (!expected.contains(a[idKey])) {
            expect(
              a,
              b,
              reason: '$at ${a[idKey]} — RECON 대상이 아닌 행이 정상판과 다르다(가림 범위 혼동).',
            );
            expect(
              _strings(a).where((String s) => s.contains('?')),
              isEmpty,
              reason: '$at ${a[idKey]} — RECON 대상이 아닌 행에 «?» 가 있다.',
            );
            continue;
          }
          targets.add(a[idKey]);
          for (final String k in reconPaths) {
            final Object? v = _at(a, k);
            if (v == null) {
              expect(
                _at(b, k),
                isNull,
                reason: '$at ${a[idKey]}.$k — 대상 글자가 사라졌다.',
              );
              continue;
            }
            expect(
              (v as String).endsWith('?'),
              isTrue,
              reason: '$at ${a[idKey]}.$k — RECON 대상 행의 글자 끝에 «?» 가 없다.',
            );
          }
          expect(
            _stripQuestionAt(a, reconPaths),
            b,
            reason:
                '$at ${a[idKey]} — RECON 대상 행은 대상 글자의 «?» 를 떼면 정상판과 같아야 한다(기하·그 밖 글자 유지).',
          );
        }
        expect(
          targets,
          expected,
          reason: '$at — RECON 대상 행 집합이 상세 RECON 표본과 다르다(§3-1 ② «대상 1종목»).',
        );
      }

      const List<String> holdingReconPaths = <String>[
        'quantity_text',
        'weight_text',
        'pending_text',
      ];
      reconRows(
        _ovRecon,
        _holdingRows(_ovRecon),
        _holdingRows(_ovNormal),
        'holding_id',
        holdingReconPaths,
        <Object?>{reconHolding['holding_id']},
      );
      reconRows(
        _dtRecon,
        _holdingRows(_dtRecon),
        _holdingRows(_dtNoStop),
        'holding_id',
        holdingReconPaths,
        <Object?>{reconHolding['holding_id']},
      );
      reconRows(
        _alRecon,
        _allocationRows(_alRecon),
        _allocationRows(_alInBand),
        'sleeve',
        <String>[..._reconAllocationKeys, 'sleeve_weight.label'],
        <Object?>{reconHolding['sleeve']},
      );
    });

    test(
      'C-44 ④ 정체성·일치 — holding_id 유일 · B·POT 같은 종목 · 목록 ↔ 1건 · 펼침·뷰어판 · 링크',
      () {
        int duplicatedSymbolSamples = 0;
        for (final String p in <String>[..._overviews, _holdings6]) {
          final List<Map<String, Object?>> rows = _holdingRows(p);
          final List<Object?> ids = <Object?>[
            for (final Map<String, Object?> r in rows) r['holding_id'],
          ];
          expect(
            ids.toSet(),
            hasLength(ids.length),
            reason: '$p — holding_id 중복',
          );
          final List<Object?> symbols = <Object?>[
            for (final Map<String, Object?> r in rows) r['symbol'],
          ];
          if (symbols.toSet().length < symbols.length) {
            duplicatedSymbolSamples++;
          }
        }
        expect(
          duplicatedSymbolSamples,
          greaterThan(0),
          reason: '같은 종목이 두 보유(B·POT)에 있는 표본이 없다 — holding_id 의 존재 이유 표본(K7).',
        );

        // holdings_6 == 펼침판의 같은 holding_id 행(평면 창구와 묶인 창구가 같은 행을 준다).
        final Map<String, Map<String, Object?>> pnlById =
            <String, Map<String, Object?>>{
              for (final Map<String, Object?> r in _holdingRows(_ovPnl))
                r['holding_id']! as String: r,
            };
        final Map<String, Map<String, Object?>> flatById =
            <String, Map<String, Object?>>{
              for (final Map<String, Object?> r in _rows(_holdings6))
                r['holding_id']! as String: r,
            };
        // 🔵 `as_of` 는 맞대지 않는다(관측 시각 — C-43 ④ 선례) · 그 밖 JSON 은 전부 같다.
        expect(
          _noAsOf(flatById),
          _noAsOf(pnlById),
          reason: '$_holdings6 행 ≠ $_ovPnl 의 같은 행(pnl 포함).',
        );

        // 상세 holding == 원천 보유현황의 같은 행(손익 제외) · 펼침 상세의 손익 == 펼침판의 같은 행.
        for (final MapEntry<String, String> e in _detailSource.entries) {
          final Map<String, Object?> h = _map(_vm(e.key)['holding'])!;
          final Map<String, Object?>? src = _holdingRows(e.value)
              .cast<Map<String, Object?>?>()
              .firstWhere(
                (Map<String, Object?>? r) =>
                    r!['holding_id'] == h['holding_id'],
                orElse: () => null,
              );
          expect(
            src,
            isNotNull,
            reason: '${e.key} — ${e.value} 에 같은 holding_id 행이 없다.',
          );
          expect(
            _noAsOf(_without(h, <String>{'pnl'})),
            _noAsOf(_without(src!, <String>{'pnl'})),
            reason: '${e.key} holding ≠ ${e.value} 의 같은 행(목록·1건 모순).',
          );
          if (h['pnl'] != null) {
            expect(h['pnl'], pnlById[h['holding_id']]!['pnl'], reason: e.key);
          }
        }

        // 펼침판 − pnl == 정상판 · 뷰어판 − 토글·섹션 == 정상판 − 토글·섹션(뷰어판엔 둘 다 없다).
        final Map<String, Object?> strippedPnl = _vm(_ovPnl);
        for (final Map<String, Object?> c in _list(strippedPnl['cards'])) {
          for (final Map<String, Object?> r in _list(c['rows'])) {
            r.remove('pnl');
          }
        }
        expect(
          _noAsOf(strippedPnl),
          _noAsOf(_vm(_ovNormal)),
          reason: '$_ovPnl − pnl ≠ $_ovNormal',
        );
        final Map<String, Object?> viewer = _vm(_ovViewer);
        expect(
          viewer['pnl_toggle_label'],
          isNull,
          reason: '뷰어 = 토글 부재(K15 ✅).',
        );
        expect(
          viewer['external'],
          isNull,
          reason: '뷰어 = 시스템 밖 섹션 부재(K14 ⓑ ✅).',
        );
        expect(
          _noAsOf(_without(viewer, <String>{'pnl_toggle_label', 'external'})),
          _noAsOf(
            _without(_vm(_ovNormal), <String>{'pnl_toggle_label', 'external'}),
          ),
          reason: '$_ovViewer − 토글·섹션 ≠ $_ovNormal',
        );

        // 링크 = 그 행의 id · 매수 결정 링크는 상세마다 늘 있다(K16 ⓔ).
        for (final String p in _holdingFixtures) {
          for (final Map<String, Object?> r in _holdingRows(p)) {
            expect(
              r['detail_deep_link'],
              _link(
                AppRoutes.holdingsDetail,
                'holdingId',
                r['holding_id']! as String,
              ),
              reason: '$p ${r['holding_id']} — 엉뚱한 상세로 간다.',
            );
          }
        }
        for (final String p in _details) {
          final Map<String, Object?> vm = _vm(p);
          final Map<String, Object?>? link = _map(vm['entry_decision_link']);
          expect(
            link,
            isNotNull,
            reason: '$p — 「매수 결정 보기」가 늘 있다(02 `H6-2` 수용 (c)).',
          );
          final Map<String, Object?> decision = _map(
            _map(vm['holding'])!['entry_decision'],
          )!;
          expect(
            link!['deep_link'],
            _link(
              AppRoutes.journalDecision,
              'decisionId',
              decision['decision_id']! as String,
            ),
            reason: '$p — 매수 결정 링크가 그 보유의 결정이 아니다.',
          );
        }
      },
    );

    test('C-44 ⑤ 카드 구조 — 카탈로그 순·라벨 · POT = A 카드 맨 끝(K17) · scope MANAGED · 빈 ⇔ 문장', () {
      final List<(String, String)> top = _catalogTop();
      final Map<String, Object?> potRow = _rows(FixturePaths.sleeveCatalog4)
          .singleWhere((Map<String, Object?> r) => r['rolls_up_to'] != null);
      final String potParent = potRow['rolls_up_to']! as String;
      final String potSleeve = potRow['sleeve']! as String;
      for (final String p in _overviews) {
        final Map<String, Object?> vm = _vm(p);
        final List<Map<String, Object?>> cards = _list(vm['cards']);
        expect(
          cards.isEmpty,
          vm['empty_label'] != null,
          reason: '$p — cards 빈 ⇔ empty_label non-null(K26).',
        );
        if (_map(vm['external']) case final Map<String, Object?> s) {
          expect(
            _list(s['rows']),
            isNotEmpty,
            reason: '$p — 빈 섹션 금지(null 로 온다).',
          );
        }
        if (cards.isEmpty) {
          continue;
        }
        expect(
          <(String, String)>[
            for (final Map<String, Object?> c in cards)
              (c['sleeve']! as String, c['title_text']! as String),
          ],
          top,
          reason:
              '$p — 카드 = 카탈로그 최상위 행(rolls_up_to == null)의 order 순 · 제목 = 그 라벨.',
        );
        for (final Map<String, Object?> c in cards) {
          final String sleeve = c['sleeve']! as String;
          final Map<String, Object?> alloc = _map(c['allocation'])!;
          expect(alloc['sleeve'], sleeve, reason: '$p 카드 $sleeve 머리');
          expect(<String>{'POT', 'CASH'}, isNot(contains(sleeve)), reason: p);
          final List<Map<String, Object?>> rows = _list(c['rows']);
          expect(
            rows.isEmpty,
            c['rows_empty_text'] != null,
            reason: '$p 카드 $sleeve — rows 빈 ⇔ rows_empty_text non-null.',
          );
          bool seenPot = false;
          for (final Map<String, Object?> r in rows) {
            final String at = '$p 카드 $sleeve ${r['holding_id']}';
            expect(
              r['scope'],
              'MANAGED',
              reason: '$at — 시스템 밖 행은 섹션으로 온다(K14).',
            );
            if (r['sleeve'] == potSleeve) {
              expect(
                sleeve,
                potParent,
                reason: '$at — POT 행은 회계 소속(A) 카드에 온다(K17).',
              );
              expect(
                r['sub_book_label'],
                isNotNull,
                reason: '$at — POT 칩 상시(K17).',
              );
              seenPot = true;
            } else {
              expect(r['sleeve'], sleeve, reason: '$at — 다른 슬리브 행이 섞였다.');
              expect(r['sub_book_label'], isNull, reason: at);
              expect(
                seenPot,
                isFalse,
                reason: '$at — POT 행은 A 카드 펼침 안 맨 끝이다(K17).',
              );
            }
          }
        }
      }
    });

    test('C-44 ⑥ 배분 — 순서 · 회계 기준 · 밴드 축 짝 · 밴드 행 = B 만(K27) · 가림 기하 · 카드 머리 == 배분 행', () {
      for (final String p in _allocations) {
        final Map<String, Object?> vm = _vm(p);
        final List<Map<String, Object?>> rows = _list(vm['rows']);
        expect(
          rows.isEmpty,
          vm['empty_label'] != null,
          reason: '$p — rows 빈 ⇔ empty_label.',
        );
        if (rows.isEmpty) {
          continue;
        }
        final List<Object?> sleeves = <Object?>[
          for (final Map<String, Object?> r in rows) r['sleeve'],
        ];
        expect(
          sleeves.indexOf('POT'),
          sleeves.indexOf('A') + 1,
          reason: '$p — POT 는 A 바로 뒤.',
        );
        expect(rows[sleeves.indexOf('POT')]['parent_sleeve'], 'A', reason: p);
        expect(sleeves.last, 'CASH', reason: '$p — 현금 대기는 마지막.');
        final Set<Object?> bandRows = <Object?>{};
        for (final Map<String, Object?> r in rows) {
          final String at = '$p ${r['sleeve']}';
          final Map<String, Object?>? w = _map(r['sleeve_weight']);
          final Map<String, Object?>? g = _map(r['gauge']);
          expect(
            r['basis'],
            'ACCOUNTING',
            reason: '$at — 회계 기준만(02 `H6-3` 수용 (a)).',
          );
          expect(
            w == null,
            r['band_state'] == null,
            reason: '$at — sleeve_weight ⇔ band_state',
          );
          expect(
            r['band_state'] == null,
            r['band_state_label'] == null,
            reason: '$at — band_state ⇔ band_state_label',
          );
          expect(
            g != null,
            w != null,
            reason:
                '$at — 게이지 ⇔ 밴드 행(밴드 판정이 있으면 게이지도 온다 · null = 판정 없음·INTEGRITY 가림).',
          );
          expect(
            w == null,
            r['band_note_text'] != null,
            reason: '$at — sleeve_weight null ⇔ band_note_text',
          );
          expect(
            r['deployed_ratio'] == null,
            r['parking_ratio'] == null,
            reason: '$at — 두 비율은 둘 다 있거나 둘 다 없다(여집합 계산 금지).',
          );
          if (w != null) {
            bandRows.add(r['sleeve']);
            expect(
              w['basis'],
              'ACCOUNTING',
              reason: '$at — 밴드 문장도 회계 기준(C-31).',
            );
            expect(
              (w['label']! as String).contains('%'),
              isTrue,
              reason: '$at — 밴드 문장에 % 가 없다.',
            );
          } else if (p != _alIntegrity) {
            expect(
              (r['band_note_text']! as String).contains('%'),
              isTrue,
              reason:
                  '$at — 밴드 없는 행의 현재 비중 글자는 band_note_text 가 유일한 출구다(04:464).',
            );
          }
          if (g != null) {
            final double low = (g['band_low_normalized']! as num).toDouble();
            final double target = (g['target_normalized']! as num).toDouble();
            final double high = (g['band_high_normalized']! as num).toDouble();
            expect(
              low <= target && target <= high,
              isTrue,
              reason: '$at — 게이지 순서',
            );
            final double actual = (g['actual_normalized']! as num).toDouble();
            expect(
              low <= actual && actual <= high,
              r['band_state'] != 'OUT_OF_BAND',
              reason:
                  '$at — 게이지 실측 위치가 밴드 판정과 모순(OUT_OF_BAND ⇔ 밴드 밖 · IN_BAND·NEAR_EDGE ⇔ 밴드 안).',
            );
          }
          expect(
            _trancheProgressWords.hasMatch(r['tranche_state_text']! as String),
            isFalse,
            reason: '$at — 트랜치 글자를 끝이 있는 진행률로 쓰지 않는다(02 수용 (f) · P 회차).',
          );
        }
        if (p == _alIntegrity) {
          expect(bandRows, isEmpty, reason: '$p — INTEGRITY 는 밴드 축·기하가 없다.');
          for (final Map<String, Object?> r in rows) {
            expect(r['gauge'], isNull, reason: p);
            expect(r['deployed_ratio'], isNull, reason: p);
          }
        } else {
          expect(
            bandRows,
            _bandSleeves,
            reason:
                '$p — 밴드 행 = B 만(K27 ✅ — SPEC 밴드는 B 하나 · A·C 는 band_note_text).',
          );
        }
      }
      bool hasOut(String p) => _allocationRows(p)
          .any((Map<String, Object?> r) => r['band_state'] == 'OUT_OF_BAND');
      expect(
        hasOut(_alOutOfBand),
        isTrue,
        reason: '$_alOutOfBand — 이탈 표본에 OUT_OF_BAND 가 없다.',
      );
      expect(
        hasOut(_alInBand),
        isFalse,
        reason: '$_alInBand — 밴드 내 표본에 이탈이 있다.',
      );
      // RECON = 기하·band_state 유지(글자만 «?» — K10).
      final Map<Object?, Map<String, Object?>> inBand = _bySleeve(_alInBand);
      for (final Map<String, Object?> r in _allocationRows(_alRecon)) {
        for (final String k in <String>[
          'deployed_ratio',
          'parking_ratio',
          'gauge',
          'band_state',
        ]) {
          expect(
            r[k],
            inBand[r['sleeve']]![k],
            reason: '$_alRecon ${r['sleeve']}.$k — RECON 은 기하를 유지한다.',
          );
        }
      }
      // 카드 머리 == 같은 화면의 H6-3 행(JSON).
      for (final MapEntry<String, String> e in _cardAllocationSource.entries) {
        final Map<Object?, Map<String, Object?>> by = _bySleeve(e.value);
        for (final Map<String, Object?> a in _cardAllocations(e.key)) {
          expect(
            a,
            by[a['sleeve']],
            reason: '${e.key} 카드 ${a['sleeve']} 머리 ≠ ${e.value} 의 같은 행.',
          );
        }
      }
    });

    test('C-44 ⑦ 손절선 — 행 ⇔ 문장 · 등급 코드 ∈ StopTierCodes · ⑥ 수준 == holdings_6 옛 절대 손절선', () {
      for (final String p in _details) {
        final Map<String, Object?> vm = _vm(p);
        final List<Map<String, Object?>> lines = _list(vm['stop_lines']);
        expect(
          lines.isEmpty,
          vm['no_stop_line_text'] != null,
          reason: '$p — 손절선 0행 ⇔ no_stop_line_text(게이지 없는 «없음» 0 대체 금지).',
        );
        for (final Map<String, Object?> s in lines) {
          expect(
            StopTierCodes.values,
            contains(s['tier_code']),
            reason: '$p — 등급 코드 오기',
          );
          expect((s['level_text'] as String?) ?? '', isNotEmpty, reason: p);
          expect((s['tier_label'] as String?) ?? '', isNotEmpty, reason: p);
        }
      }
      for (final String p in <String>[_dtWithStops, _dtIntegrity]) {
        expect(
          _list(_vm(p)['stop_lines']),
          hasLength(1),
          reason: '$p — 손절선 1행(TIER_1B · 보존 경로 · K16 ⓓ).',
        );
      }
      for (final String p in <String>[_dtNoStop, _dtPnl, _dtRecon]) {
        expect(_list(_vm(p)['stop_lines']), isEmpty, reason: p);
      }
      final Map<String, Object?> vm = _vm(_dtWithStops);
      final Object? hid = _map(vm['holding'])!['holding_id'];
      final Map<String, Object?> flat = _rows(_holdings6)
          .singleWhere((Map<String, Object?> r) => r['holding_id'] == hid);
      expect(
        (_list(vm['stop_lines']).single['level_text']! as String).replaceAll(
          RegExp('[^0-9]'),
          '',
        ),
        _map(flat['stop_line'])!['absolute_stop'],
        reason:
            '$_dtWithStops — 손절선 수준 글자가 holdings_6 같은 보유의 옛 절대 손절선과 다르다(지어내지 않는다).',
      );
    });

    test('C-44 ⑧ 이력 — 원천 일지 행 JSON 그대로 · 같은 보유 · 시간 역순 · 빈 ⇔ 문장 · 표본 하한', () {
      final Map<String, int> compared = <String, int>{};
      for (final MapEntry<String, String> e in _historySource.entries) {
        compared[e.key] = 0;
        final Map<String, Object?> vm = _vm(e.key);
        final Map<String, Object?> h = _map(vm['holding'])!;
        final List<Map<String, Object?>> entries = _list(vm['recent_entries']);
        expect(
          entries.isEmpty,
          vm['recent_empty_label'] != null,
          reason: '${e.key} — recent_entries 빈 ⇔ recent_empty_label.',
        );
        final Map<Object?, Map<String, Object?>> source =
            <Object?, Map<String, Object?>>{
              for (final Map<String, Object?> r in _rows(e.value))
                r['entry_id']: r,
            };
        String? previous;
        for (final Map<String, Object?> r in entries) {
          final String at = '${e.key} ${r['entry_id']}';
          expect(
            source.containsKey(r['entry_id']),
            isTrue,
            reason: '$at — ${e.value} 에 없는 체결(지어낸 체결).',
          );
          expect(
            r,
            source[r['entry_id']],
            reason: '$at — 원천 일지 행과 JSON 이 다르다.',
          );
          compared[e.key] = compared[e.key]! + 1;
          expect(r['symbol'], h['symbol'], reason: '$at — 다른 종목의 체결');
          expect(r['sleeve'], h['sleeve'], reason: '$at — 다른 보유(슬리브)의 체결');
          final String date = r['trade_date']! as String;
          if (previous != null) {
            expect(
              date.compareTo(previous) <= 0,
              isTrue,
              reason: '$at — 시간 역순이 아니다.',
            );
          }
          previous = date;
        }
      }
      // 이력 있는 표본(⑥ = journal_30 의 069500 3행 · ⑮ = 가림 원천 2행 — 설계서 §3-1)이 비면 위 대조가 공허해진다.
      for (final String p in <String>[_dtWithStops, _dtIntegrity]) {
        expect(
          compared[p],
          greaterThan(0),
          reason: '$p — 이력 표본이 비었다(⑧ 공허 통과 방지).',
        );
      }
    });

    test('C-44 ⑨ 미결 82(보유 몫) — 라벨 = 입금 정본 · 두 입금 픽스처 일치 · 옛 종목 0', () {
      final Map<String, String> deposit = _depositLabels(
        FixturePaths.depositPlan1,
      );
      final Map<String, String> screen = _depositLabels(
        FixturePaths.m7M7DepositPlanDefault,
      );
      expect(deposit, isNotEmpty);
      for (final MapEntry<String, String> e in screen.entries) {
        if (deposit.containsKey(e.key)) {
          expect(
            e.value,
            deposit[e.key],
            reason: '두 입금 픽스처의 ${e.key} 라벨이 다르다.',
          );
        }
      }
      for (final String p in _holdingFixtures) {
        for (final Map<String, Object?> r in _holdingRows(p)) {
          final String symbol = r['symbol']! as String;
          expect(
            _retiredSymbols,
            isNot(contains(symbol)),
            reason: '$p — 옛 종목 $symbol(미결 82).',
          );
          expect(
            deposit.containsKey(symbol),
            isTrue,
            reason: '$p — 대응표 밖 종목 $symbol.',
          );
          expect(
            r['symbol_label'],
            deposit[symbol],
            reason: '$p $symbol — 라벨이 입금 정본과 다르다(K4).',
          );
        }
      }
    });

    test('C-44 ⑩ 트랜치·배지 — 트랜치 = B 행만 · 같은 VM 안 B 행 동일 · B·POT 금 상한 배지 0', () {
      for (final String p in _holdingFixtures) {
        final List<Object?> bTranches = <Object?>[];
        for (final Map<String, Object?> r in _holdingRows(p)) {
          final String at = '$p ${r['holding_id']}';
          final List<Map<String, Object?>> tranches = _list(r['sma_tranches']);
          if (tranches.isNotEmpty) {
            expect(
              r['sleeve'],
              'B',
              reason: '$at — SMA 트랜치는 슬리브 B 의 규칙이다(P 회차 · K18).',
            );
          }
          if (r['sleeve'] == 'B') {
            bTranches.add(r['sma_tranches']);
          }
          if (r['sleeve'] == 'B' || r['sleeve'] == 'POT') {
            final Set<Object?> codes = <Object?>{
              for (final Map<String, Object?> g in _list(r['gates'])) g['code'],
            };
            expect(
              codes.intersection(_goldCapGates),
              isEmpty,
              reason: '$at — 금 8% 상한은 C 리밸런싱 한정이다(E14).',
            );
          }
        }
        for (final Object? t in bTranches) {
          expect(
            t,
            bTranches.first,
            reason: '$p — 같은 VM 안 B 행들의 트랜치 단계가 다르다(슬리브 단위 규칙).',
          );
        }
      }
    });

    test('C-44 ⑪ 링크 — 「비중 보기」 = holdingsAllocation · 상태 칩 = handbook|null · 시스템 밖 행 링크 키 0', () {
      int links = 0;
      for (final String p in _overviews) {
        final Map<String, Object?>? link = _map(_vm(p)['allocation_link']);
        if (link != null) {
          links++;
          expect(link['deep_link'], AppRoutes.holdingsAllocation, reason: p);
        }
      }
      expect(links, greaterThan(0), reason: '「비중 보기」 링크 표본이 없다(⑪ 공허 통과 방지).');
      final List<(String, List<Map<String, Object?>>)> allocs =
          <(String, List<Map<String, Object?>>)>[
            for (final String p in _allocations) (p, _allocationRows(p)),
            for (final String p in _overviews) (p, _cardAllocations(p)),
          ];
      int chips = 0;
      for (final (String p, List<Map<String, Object?>> rows) in allocs) {
        for (final Map<String, Object?> r in rows) {
          for (final Map<String, Object?> c in _list(r['state_chips'])) {
            chips++;
            final Object? link = c['detail_deep_link'];
            expect(
              link == null ||
                  (link is String && link.startsWith('handbook://')),
              isTrue,
              reason: '$p ${r['sleeve']} — 상태 칩은 핸드북으로만 간다(앱 안 이동 0): $link',
            );
          }
        }
      }
      expect(chips, greaterThan(0), reason: '상태 칩 표본이 없다(K13 — 보류 칩).');
      for (final MapEntry<String, List<Map<String, Object?>>> e
          in _externalRows().entries) {
        for (final Map<String, Object?> r in e.value) {
          expect(
            r.keys.where((String k) => k.endsWith('link')),
            isEmpty,
            reason: '${e.key} ${r['external_id']} — 시스템 밖 행에는 이동이 없다.',
          );
        }
      }
    });

    // ═══ B. 화면 소스 스캔 ═══════════════════════════════════════════════════

    test('C-44 ⑫ 대상 수 · 가드 — H6 전용 이름은 대상 파일에만', () {
      expect(
        _guardSources.keys.where(
          (String p) => p.startsWith('$_h6Package/lib/'),
        ),
        isNotEmpty,
        reason: 'ui_journal/lib 를 못 읽었다 — 경로가 낡았다(빈 입력은 늘 통과한다).',
      );
      expect(
        _guardSources.keys.where(
          (String p) => p.startsWith('packages/ui_shell/'),
        ),
        isEmpty,
        reason: '셸(ui_shell)은 홈 블록 4·배선 자리라 가드에서 뺀다.',
      );
      final List<String> files = _targets.keys.toList()..sort();
      _say(
        'C-44 ⑫ 대상 H6 ${files.length}파일 — $_h6Package/{${_h6PublicFiles.join(', ')}} + '
        '$_h6Package/$_h6InternalDir**'
        '${files.isEmpty ? ' — ⑬~⑲ 공허 통과' : '\n    ${files.join('\n    ')}'}',
      );
      final List<String> bad = _h6MentionsOutside(_guardSources);
      expect(
        bad,
        isEmpty,
        reason:
            'H6 전용 VM·창구·주입 이름을 말하는 `ui_*/lib` 파일은 대상(공개 3 + `$_h6InternalDir**`)에만 둔다 — '
            '밖에 두면 ⑬~⑲ 가 그 파일을 보지 않는다(셸은 제외).\n${bad.join('\n')}',
      );
    });

    test('C-44 ⑬ 호출 금지 목록 0 — 평면 창구·카탈로그·일지·원장·명령·안전 상태 직접 구독', () {
      final List<String> bad = _violations('⑬');
      expect(
        bad,
        isEmpty,
        reason:
            'H6 는 `watchHoldingsOverview` · `watchHoldingDetail` · `watchAllocation` · `watchNext` + '
            '`journalSafetyStateProvider`·링크·시계 주입만 쓴다(01 §17-8 호출 표 · 🔴 `recordDisclosureView` 0 = 결정 ⑤).'
            '\n${bad.join('\n')}',
      );
    });

    test('C-44 ⑭ 구독 인자 — includePnl 리터럴 true 0 · 배분은 인자 없이', () {
      final List<String> bad = _violations('⑭');
      expect(
        bad,
        isEmpty,
        reason:
            '펼침은 State 변수로만 재구독한다(기본 false 의 증명 = 카드 테스트의 가짜 `calls` 첫 값 · 02 수용 (e)).'
            '\n${bad.join('\n')}',
      );
    });

    test('C-44 ⑮ 원값·키 0 — 수량·가격·손익·밴드 원값 · 슬리브·범위·기준 · holdingId 표시·Key', () {
      final List<String> bad = _violations('⑮');
      expect(
        bad,
        isEmpty,
        reason:
            '그리는 것은 `*Text`·`*Label`·칩·배지뿐이다 — 원값·키로 표시·분기하지 않는다 · `holdingId` 는 Key 에도 '
            '넣지 않는다(Key = 순번).\n${bad.join('\n')}',
      );
    });

    test('C-44 ⑯ 기하 산술 0 — 여집합·차·0 대입·두 막대 곱 · × 폭만', () {
      final List<String> bad = _violations('⑯');
      expect(
        bad,
        isEmpty,
        reason:
            '`*Ratio`·`*Normalized` 는 `× 폭` 하나로만 쓴다(01 §13-2) — `1 −`·더하기·빼기·나누기·`?? 0`·게이지 × 계좌 막대 0.'
            '\n${bad.join('\n')}',
      );
    });

    test('C-44 ⑰ 가공·정렬·거르기·화면 가림 0', () {
      final List<String> bad = _violations('⑰');
      expect(
        bad,
        isEmpty,
        reason:
            '받은 순서 그대로 그린다 — 묶기·거르기·재정렬·글자 가공·플래그 보고 가리기 0(`.indexed`·`.map`·`.length`·'
            '`.isEmpty`·`[0]` 은 허용 · 배너 분리는 대상 밖 `JournalSafetyBanners`).\n${bad.join('\n')}',
      );
    });

    test('C-44 ⑱ 분기·셸·포맷 낱말 0 — 플래그·슬리브·라우트 상수', () {
      final List<String> bad = _violations('⑱');
      expect(
        bad,
        isEmpty,
        reason:
            '카드 수 = 데이터(K16 ⓐ) · 플래그·플랫폼·슬리브·범위·기준 분기 0 · 시계 직접 0 · 셸 위젯 0 · 숫자 포맷 0 · '
            '라우트 상수 0(데이터 링크만 — K12).\n${bad.join('\n')}',
      );
    });

    test('C-44 ⑲ 숫자 리터럴 — 소수 리터럴·%·원·주 문자열 0', () {
      final List<String> bad = _violations('⑲');
      expect(
        bad,
        isEmpty,
        reason:
            '값·비율·임계·단위는 엔진 글자로 온다(`N.0`·정수 레이아웃 상수 허용).\n${bad.join('\n')}',
      );
    });

    test('C-44 ⑳ 자체 검증 — 양성은 걸리고 음성은 통과한다', () {
      for (final (String snippet, String clause) in _positives) {
        final Set<String> got = <String>{
          for (final _Hit h in _scan(snippet)) h.clause,
        };
        expect(
          got,
          contains(clause),
          reason: '양성 스니펫을 못 잡았다($clause): $snippet',
        );
        _say('C-44 ⑳ 양성 $snippet → ${(got.toList()..sort()).join('')}');
      }
      for (final String snippet in _negatives) {
        expect(_scan(snippet), isEmpty, reason: '음성 스니펫을 잘못 잡았다: $snippet');
      }
      // ⑲ 문자열 추출 — 주석 속 `%` 는 대상이 아니고 문자열 속 `%` 는 대상이다.
      expect(
        _stringLiterals(stripComments("// 10% 아님\nText('a%b');\n")),
        <String>["'a%b'"],
      );
      // ⑫ 가드 — 대상 밖 경로만 걸린다(주석 속 언급은 통과).
      expect(
        _h6MentionsOutside(<String, String>{
          '$_h6Package/${_h6PublicFiles.first}':
              'void f(HoldingsOverviewVm v) {}\n',
          '$_h6Package/${_h6InternalDir}card.dart':
              'void f(HoldingsSleeveCard c) {}\n',
          '$_h6Package/lib/src/common/x.dart': 'void f(HoldingDetailVm v) {}\n',
          '$_h6Package/lib/src/timeline.dart':
              '// HoldingsOverviewVm 은 H6 만 말한다\n',
          'packages/ui_analytics/lib/a.dart':
              'final p = journalHoldingsRepositoryProvider;\n',
        }),
        <String>[
          '$_h6Package/lib/src/common/x.dart',
          'packages/ui_analytics/lib/a.dart',
        ],
      );
      _say('C-44 ⑳ 양성 [대상 밖 lib/src/common/x.dart] HoldingDetailVm → ⑫');
    });
  });
}

/// [path] 의 값(점 경로 `a.b` = 한 단계 안쪽 맵).
Object? _at(Map<String, Object?> row, String path) {
  final List<String> parts = path.split('.');
  Object? v = row;
  for (final String k in parts) {
    v = (v as Map<String, Object?>?)?[k];
  }
  return v;
}

/// RECON 대상 행에서 [paths] 글자의 끝 «?» 만 뗀 사본(그 밖 글자는 그대로 — 대상 밖 글자의 «?» 는 정상판 대조가 잡는다).
Map<String, Object?> _stripQuestionAt(
  Map<String, Object?> row,
  List<String> paths,
) {
  Object? strip(Object? v) =>
      v is String && v.endsWith('?') ? v.substring(0, v.length - 1) : v;
  Map<String, Object?> walk(Map<String, Object?> m, List<String> parts) {
    final Map<String, Object?> out = <String, Object?>{...m};
    final String k = parts.first;
    if (!out.containsKey(k)) {
      return out;
    }
    if (parts.length == 1) {
      out[k] = strip(out[k]);
    } else if (out[k] case final Map<String, Object?> inner) {
      out[k] = walk(inner, parts.sublist(1));
    }
    return out;
  }

  Map<String, Object?> out = row;
  for (final String p in paths) {
    out = walk(out, p.split('.'));
  }
  return out;
}

/// `as_of`(관측 시각) 키를 모든 깊이에서 뺀 사본 — ④ 의 «같은 행» 대조는 관측 시각을 맞대지 않는다.
Object? _noAsOf(Object? n) {
  if (n is Map<String, Object?>) {
    return <String, Object?>{
      for (final MapEntry<String, Object?> e in n.entries)
        if (e.key != 'as_of') e.key: _noAsOf(e.value),
    };
  }
  if (n is List<Object?>) {
    return <Object?>[for (final Object? v in n) _noAsOf(v)];
  }
  return n;
}

/// 배분 표본의 슬리브 → 행.
Map<Object?, Map<String, Object?>> _bySleeve(
  String path,
) => <Object?, Map<String, Object?>>{
  for (final Map<String, Object?> r in _allocationRows(path)) r['sleeve']: r,
};
