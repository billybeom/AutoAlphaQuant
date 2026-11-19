// 05 GV 계열 처리 구분표 — 기기판 G-GV 의 «전량»이 무엇인지 한 곳에 적는다(E11o-c2 · 설계 13 §8 R165 · §7 P-2 · E3c R166).
//
// 🔴 정본 = 05 v1.23(설계 커밋 `66aad71`) §B 표 · 게이트 표 + 설계 13 §7 **P-2**(Dart G-GV «전량» = 활성 AC-B 179건 +
//    엔진 관련 AC-S 게이트 + GV-P0S — 빼는 것: 비활성 7행 · P0S 에서 안 도는 25건 · GV-12b · E5b 보류 69건).
// 🔴 [GvDisposition.gap] = P-2 범위인데 아직 엔진 · 실행기에 없다 — 하나라도 있으면 «전량»이 아니다
//    (`kDeviceGoldenSuite.complete` 는 [goldenCoverageComplete] 와 같아야 한다 · golden_coverage_test).
// 🔴 이 표는 판정 재료가 아니다 — 실행기가 무엇을 돌고 무엇을 왜 안 도는지 밝히는 장부다(05 · P-2 가 바뀌면 함께 고친다).

/// 05 계열 처리 구분.
enum GvDisposition {
  /// 기기판 실행기가 돈다(시험도 같은 케이스).
  device,

  /// 시험 · CI 에서만 돈다(26년 재현 — 기기 밖 · R161 O1).
  ciOnly,

  /// P-2 로 Dart G-GV 밖(사유 = 비활성 · P0S 에서 안 돈다 · 보류).
  excluded,

  /// P-2 범위인데 아직 없다 — «전량»을 막는다.
  gap,
}

/// 계열 한 줄.
class GvCoverage {
  /// 만든다.
  const GvCoverage(this.id, this.ac, this.disposition, this.note);

  /// 05 계열 id(«GV-12b» 꼴 · 실행기 케이스 id 머리와 같은 표기).
  final String id;

  /// 05 채점 · 게이트 항목.
  final String ac;

  /// 처리 구분.
  final GvDisposition disposition;

  /// 사유 · 어디서 도는가.
  final String note;
}

const GvDisposition _d = GvDisposition.device;
const GvDisposition _ci = GvDisposition.ciOnly;
const GvDisposition _x = GvDisposition.excluded;

/// 05 v1.23 GV 계열 전부(차례 = 번호).
const List<GvCoverage> kGoldenCoverage = <GvCoverage>[
  GvCoverage('GV-1', 'AC-B01', _d, '국면 스코어 1a~1e'),
  GvCoverage('GV-2', 'AC-B02', _d, '기술 지표 2a~2f'),
  GvCoverage('GV-3', 'AC-B03', _d, '익스포저 게이트 · 3c'),
  GvCoverage('GV-4', 'AC-B04', _d, '히스테리시스 4~4g'),
  GvCoverage(
    'GV-5',
    'AC-B05',
    _x,
    'P-2 — P0S 에서 안 돈다(팩터 순위 · 개별주 선정 · E2c 보류)',
  ),
  GvCoverage(
    'GV-6',
    'AC-B06',
    _x,
    'P-2 — P0S 에서 안 돈다(추세템플릿 · 개별주 선정 · E2c 보류)',
  ),
  GvCoverage('GV-7', 'AC-B07', _x, 'P-2 — P0S 미사용(위험 기여도 · E3a 보류)'),
  GvCoverage(
    'GV-8',
    'AC-B08',
    _d,
    '05 v2.31 비활성(채점 외)이지만 M1-1 Decimal 게이트(P-2) — 8a~8f',
  ),
  GvCoverage('GV-9', 'AC-B09', _d, '멱등키 · GV-13 형식'),
  GvCoverage('GV-10', 'AC-B10', _x, '05 v2.31 비활성 7(새틀 TIER 청산)'),
  GvCoverage('GV-11', 'AC-B11', _d, '거래비용 11a~11e'),
  GvCoverage('GV-12', 'AC-B12', _d, '거래일 · 12c(lib 동결 달력)'),
  GvCoverage('GV-12b', 'AC-B12', _x, 'P-2 — P0S 미국 주문 0(E4)'),
  GvCoverage('GV-13', 'AC-S13', _d, '발주 횟수(05 «mock» = 엔진 결정론 가짜)'),
  GvCoverage(
    'GV-14',
    'AC-B10',
    _x,
    '비활성 AC-B10 소속(쿨다운) — calendar_test 의 «20거래일» 검산은 달력 단위 시험',
  ),
  GvCoverage('GV-15', 'AC-B07', _x, 'P-2 — P0S 미사용(N_eff · E3a 보류)'),
  GvCoverage('GV-16', 'AC-S11', _d, 'pit_percentile 룩어헤드 · 워밍업(E11o-c2 신규 이식)'),
  GvCoverage('GV-17', 'AC-S14', _d, '입력 누락 fail-closed(x3 = v2.30 판정 밖 · R11)'),
  GvCoverage('GV-18', 'AC-B03', _d, '슬리브별 승수'),
  GvCoverage('GV-19', 'AC-B11', _d, '비용의 손익 반영'),
  GvCoverage('GV-20', 'AC-B13', _d, '슬리브 B 3-트랜치 SMA'),
  GvCoverage('GV-21', 'AC-B14', _x, '05 v2.31 비활성 7(새틀 선정)'),
  GvCoverage('GV-22', 'AC-B15', _d, '슬리브 C 통화 분리 · 금 상한'),
  GvCoverage(
    'GV-23',
    'AC-B16',
    _d,
    '부분 청산 — v2.19 폐기 경로지만 GV-38-4 때문에 범위(P-2)',
  ),
  GvCoverage('GV-24', 'AC-B17', _d, '보유비용 · 가중 총보수'),
  GvCoverage(
    'GV-25',
    'AC-B18',
    _x,
    'P-2 — E5b 보류(동적 ETF · selection_mode fixed)',
  ),
  GvCoverage('GV-26', 'AC-B19', _x, '05 v2.31 비활성 7(새틀 월 교체)'),
  GvCoverage('GV-27', 'AC-B20', _x, '05 v2.31 비활성 7(새틀 비례 축소)'),
  GvCoverage('GV-28w', 'AC-B21', _x, 'P-2 — E5b 보류(인출 w1~w3)'),
  GvCoverage('GV-28d', 'AC-B21', _d, '납입 배분 d1~d8'),
  GvCoverage('GV-29', 'AC-B22', _x, '05 v2.31 비활성 7(시총 하위 필터)'),
  GvCoverage('GV-30', 'AC-B23', _d, '계절성 분할 집행'),
  GvCoverage('GV-31', 'AC-S16', _d, '서킷브레이커 · s_h5_1'),
  GvCoverage('GV-32', 'AC-S17', _d, '한도 판정 · 동시 발동'),
  GvCoverage('GV-33', 'AC-B24', _x, 'P-2 — E5b 보류(새틀 밴드 · 33b 포함)'),
  GvCoverage('GV-34', 'AC-B25', _x, '05 v2.31 비활성 7(새틀 진입 집행)'),
  GvCoverage('GV-35', 'AC-B26', _d, '슬리브 C 분모 = 달러 잔액'),
  GvCoverage('GV-36', 'AC-B26', _d, '조달 상대 = 잉여 큰 순 · B 제외'),
  GvCoverage('GV-37', 'AC-B26', _d, '코어 밴드 전액 자동 · 연금 한도 다리'),
  GvCoverage('GV-38', 'AC-B26', _d, '4월 청산 기본값 = 전량'),
  GvCoverage('GV-39', 'AC-B27', _d, 'P2 검사 순서 trace'),
  GvCoverage(
    'GV-40a',
    'AC-B28',
    _d,
    '일간 경고 한도(SAF 202 · 208 · 302 · 305 · 307 · E3c) — 05 대기 세부 = 참조 생성기 판(208 분모 = 새틀 부분 공분산)',
  ),
  GvCoverage(
    'GV-40b',
    'AC-B28',
    _d,
    '월간 경고 한도(SAF 201 · 306 · E3c) — 05 대기 세부 = 참조 생성기 판(306 = 누계 입력 비교만)',
  ),
  GvCoverage(
    'GV-40c',
    'AC-B28',
    _d,
    '리밸런싱 경고 한도(SAF 204 · 205 · E3c) — 05 대기 세부 = 참조 생성기 판(205 먼저 → 204)',
  ),
  GvCoverage('GV-40d', 'AC-S18', _d, '기동 통제(SAF-405)'),
  GvCoverage('GV-40e', 'AC-S18', _d, '재량 예산(SAF-409)'),
  GvCoverage(
    'GV-41',
    'AC-B29',
    _x,
    'P-2 — P0S 에서 안 돈다(월중 전이 · 03 v2.31 비활성 · E2c 보류)',
  ),
  GvCoverage('GV-42', 'AC-B30', _d, '자본 배분 설정 검증'),
  GvCoverage('GV-P0', '게이트', _x, '이력(05 v1.16 · P0 규칙셋) — 현행 정본 = GV-P0S'),
  GvCoverage(
    'GV-P0S',
    '게이트',
    _ci,
    '26년 재현(test/replay · 3.5MB 시세 사본 · 세후 S7 · 금 비중 · 실현 배분) — CI 가 PR 마다(R161 O1)',
  ),
];

/// 아직 없는 계열(«전량»을 막는 것).
List<GvCoverage> get goldenCoverageGaps => <GvCoverage>[
  for (final GvCoverage c in kGoldenCoverage)
    if (c.disposition == GvDisposition.gap) c,
];

/// 🔴 «전량» — P-2 범위에 빠진 계열이 0 일 때만 참.
bool get goldenCoverageComplete => goldenCoverageGaps.isEmpty;

final RegExp _caseHead = RegExp(r'^(GV-(\d+)([a-z]?))');

/// 실행기 케이스 id → 표의 계열(«GV-12c …» = GV-12 · «GV-28d …» = GV-28d · 없으면 null).
GvCoverage? goldenCoverageOfCase(String caseId) {
  final RegExpMatch? m = _caseHead.firstMatch(caseId);
  if (m == null) return null;
  final String withLetter = m.group(1)!;
  final String number = 'GV-${m.group(2)}';
  GvCoverage? find(String id) {
    for (final GvCoverage c in kGoldenCoverage) {
      if (c.id == id) return c;
    }
    return null;
  }

  return find(withLetter) ?? find(number);
}
