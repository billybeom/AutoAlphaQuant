// M9 S02 증권사 키 관리 VM 짓기 — 모의 세트 카드(E11p3d-5d · 설계 13 §8 R129 · 앱 01 §29 K6 · K7 · K11 · K29 · K35 · 05 S02).
//
// 🔴 카드 = 엔진에 있는 키 세트만(지금 = 모의 `KIS_PAPER` 하나) — 실전 · ISA · 대사 = 엔진 `KisKeySet` 확장(01 §8 미결 178) 뒤 ·
//    그 전에는 넣을 자리도 검증할 길도 없어 카드를 싣지 않는다(지어내지 않는다).
// 🔴 글자 = v1.20 표본(`m9/credentials*`) 그대로 · 상태 = 금고 저장 여부 + 마지막 검증 기록(온보딩 진척 o_02) ·
//    키 조각 칸 0(K7 — 마스킹은 슬롯 위젯 안) · 저장 동작 칸 0(K6 — 검증 통과 = 구현이 저장).
// 🔴 만료 = 원천 0(KIS 앱키 기한 기록 없음) → 줄 없음 · 키 회전 = 마법사(M4-4) 전 → 링크 없음 · 유출 런북 = 런북 원천 전 → 링크 없음 ·
//    잠김 = 생체 가드(M5) 전 → 없음.

import 'package:domain_contracts/domain_contracts.dart'
    show
        AsOf,
        AsOfSource,
        CredentialCardVm,
        CredentialKindCodes,
        CredentialListVm,
        CredentialUse,
        OnboardingSlotIds,
        RunMode,
        RunModeIsSim,
        SettingsActionCall,
        SettingsActionId,
        StepState,
        TradeDate,
        UiLevel;

import '../ops/ledger_views.dart' show kstDateText;

/// 모의 키 세트 사실.
class PaperCredentialFacts {
  /// 사실을 만든다.
  const PaperCredentialFacts({
    required this.stored,
    this.lastState,
    this.lastAtUtc,
    this.lastFailureCode,
  });

  /// 금고에 저장돼 있나.
  final bool stored;

  /// 마지막 검증 결과(VERIFIED · FAILED · 기록 없음 = null).
  final StepState? lastState;

  /// 마지막 검증 시각.
  final DateTime? lastAtUtc;

  /// 마지막 거절 코드.
  final String? lastFailureCode;
}

/// 조회 화면 신선도(표본 `stale_after_seconds` 93600 = 26시간).
const Duration kCredentialListStaleAfter = Duration(hours: 26);

String _two(int n) => n.toString().padLeft(2, '0');

/// KST «MM-DD HH:MM».
String _kstShort(DateTime utc) {
  final DateTime k = utc.toUtc().add(const Duration(hours: 9));
  return '${_two(k.month)}-${_two(k.day)} ${_two(k.hour)}:${_two(k.minute)}';
}

/// 🔴 `S02` 키 목록 — [runMode] = 지금 실행 모드(모의 계열 = 모의 키 «필수» · 실전 = «선택»).
CredentialListVm credentialListVmOf({
  required RunMode runMode,
  required PaperCredentialFacts paper,
  required DateTime nowUtc,
}) {
  final bool failed = paper.lastState == StepState.failed;
  final bool ok = paper.stored && paper.lastState == StepState.verified;
  final bool unknown = paper.stored && !failed && !ok;
  final bool required = runMode.isSim;
  final (String code, String label, UiLevel level) = failed
      ? ('INVALID', '검증 실패', UiLevel.act)
      : ok
      ? ('OK', '정상', UiLevel.ok)
      : unknown
      ? ('UNKNOWN', '검증 기록 없음', UiLevel.watch)
      : ('NOT_REGISTERED', '미등록', required ? UiLevel.act : UiLevel.info);
  final DateTime? at = paper.lastAtUtc;
  String? last;
  if (at != null && (failed || paper.lastState == StepState.verified)) {
    last = failed
        ? '마지막 검증 ${_kstShort(at)} · 거절(${paper.lastFailureCode ?? '코드 없음'})'
        : '마지막 검증 ${_kstShort(at)} · 통과';
  }
  // 저장된 키가 있으면 «다시 검증»(금고 키) · 없거나 실패면 칸 + «검증 후 저장».
  final bool reverify = ok || unknown;
  final CredentialCardVm card = CredentialCardVm(
    alias: 'kis_paper',
    kind: CredentialKindCodes.kisPaper,
    kindLabel: '모의투자',
    healthCode: code,
    healthLabel: label,
    usage: CredentialUse.full,
    usageLabel: '모의 주문 · 시세',
    level: level,
    lastVerifiedText: last,
    requirementLabel: required ? '필수' : '선택',
    credentialSlotId: reverify ? null : OnboardingSlotIds.secretKisMock,
    verifyAction: SettingsActionCall(
      id: SettingsActionId.credentialVerify,
      args: const <String, String>{'kind': CredentialKindCodes.kisPaper},
      label: reverify ? '다시 검증' : '검증 후 저장',
    ),
  );
  final DateTime k = nowUtc.toUtc().add(const Duration(hours: 9));
  return CredentialListVm(
    cards: <CredentialCardVm>[card],
    asOf: AsOf(
      observedAt: nowUtc.toUtc(),
      tradeDate: TradeDate(kstDateText(nowUtc)),
      source: AsOfSource.localSqlite,
      staleAfter: kCredentialListStaleAfter,
      label: '키 기준 ${kstDateText(nowUtc)} ${_two(k.hour)}:${_two(k.minute)}',
    ),
  );
}
