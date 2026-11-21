// M9 S02 증권사 키 관리 VM 짓기 — 모의 세트 카드(E11p3d-5d · 설계 13 §8 R129 · 앱 01 §29 K6 · K7 · K11 · K29 · K35 · 05 S02).
//
// 🔴 카드 = 엔진에 있는 키 세트만 — 모의 `KIS_PAPER` · 🆕 E11q-c1b(R196 · 미결 207 ⓑ · 178 실전 몫) 실전 `KIS_LIVE` · `KIS_ISA`
//    (조립 앱이 실전 세트 사실을 줄 때만 · 표본 차례 = 실전 → ISA → 모의) · 대사 전용 = X7 창 뒤.
// 🔴 🆕 K208(v1.28 · 발주자 위임 — 권고 ⓐ) SIM = 봉인 표시 그대로(`sealLabel` · 머리 줄) · 봉인 = 주문 경로만 — 미등록 · 실패 ·
//    기록 없음 카드에는 조회 검증(토큰 + 잔고 1회 · 주문 0) 자리를 싣는다(위저드 S3 «실키 등록 · 검증» 의 자리 = S02) ·
//    통과 카드 = 동작 0(봉인 해제 컨트롤 0).
// 🔴 글자 = v1.20 표본(`m9/credentials*`) 그대로 · 상태 = 금고 저장 여부 + 마지막 검증 기록(온보딩 진척 o_02) ·
//    키 조각 칸 0(K7 — 마스킹은 슬롯 위젯 안) · 저장 동작 칸 0(K6 — 검증 통과 = 구현이 저장).
// 🔴 만료 = 원천 0(KIS 앱키 기한 기록 없음) → 줄 없음 · 키 회전 = 마법사(M4-4) 전 → 링크 없음 · 유출 런북 = 부르는 쪽이 넘긴다(🆕 아래) ·
//    잠김 = 생체 가드(M5) 전 → 없음.
// 🆕 E11q-d1 — 유출 런북 링크 = 부르는 쪽이 엔진 `runbookLinkOf('secret-leak')` 로 넘긴다(그 런북 원고 · 상세 본문이 있을 때만 ·
//    지금 = 준비 중 → null · 원고가 생기면 저절로 선다 · 읽기 문서라 잠김에도 남는다).

import 'package:domain_contracts/domain_contracts.dart'
    show
        AsOf,
        AsOfSource,
        CredentialCardVm,
        CredentialKindCodes,
        CredentialListVm,
        CredentialUse,
        LinkAction,
        OnboardingResultCodes,
        OnboardingSlotIds,
        OperatingMode,
        RunMode,
        RunModeIsSim,
        SettingsActionCall,
        SettingsActionId,
        SettingsSlotIds,
        StepState,
        TradeDate,
        UiLevel;

import '../ops/ledger_views.dart' show kstDateText;
import '../ops/live_keys.dart'
    show CredentialHealthCodes, CredentialHealthRecord, kLiveKeyRegistryAlias;

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

/// 🆕 R196 — 실전 키 세트 사실(값 0).
class LiveCredentialFacts {
  /// 사실을 만든다 — [kind] = `KIS_LIVE` · `KIS_ISA`.
  const LiveCredentialFacts({
    required this.kind,
    required this.stored,
    this.record,
  });

  /// 세트.
  final String kind;

  /// 금고에 저장돼 있나.
  final bool stored;

  /// 마지막 조회 검증 기록(`credential_registry` · 없음 = null).
  final CredentialHealthRecord? record;
}

/// 🆕 R196 — 실전 세트 카드 글자(표본 `m9/credentials*` 그대로).
abstract final class LiveCredentialTexts {
  /// 세트 이름.
  static String kindLabel(String kind) =>
      kind == CredentialKindCodes.kisIsa ? 'ISA 중개형' : '실전 · 위탁 01 + 연금저축 22';

  /// 용도.
  static const String usage = '주문 · 조회';

  /// SIM 봉인 · 머리 줄.
  static const String seal = '모의투자 중 — 주문 경로 봉인됨';
  static const String simNotice =
      '모의투자 중입니다 — 실전 키의 주문 경로는 봉인돼 있습니다. 봉인은 실전 전환 절차에서만 풀립니다.';

  /// 필수 여부.
  static const String requiredLive = '필수';
  static const String requiredOnSwitch = '실전 전환 때 필수';
  static const String optional = '선택';

  /// 안내 모드 한 줄.
  static const String advisoryWhy = '투자 안내 모드에서는 주문 권한 키가 없어도 됩니다.';
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
  List<LiveCredentialFacts> live = const <LiveCredentialFacts>[],
  OperatingMode? operatingMode,
  LinkAction? leakRunbookLink,
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
    cards: <CredentialCardVm>[
      for (final LiveCredentialFacts f in live)
        _liveCard(f, runMode: runMode, operatingMode: operatingMode),
      card,
    ],
    modeNotice: runMode.isSim && live.isNotEmpty
        ? LiveCredentialTexts.simNotice
        : null,
    leakRunbookLink: leakRunbookLink,
    asOf: AsOf(
      observedAt: nowUtc.toUtc(),
      tradeDate: TradeDate(kstDateText(nowUtc)),
      source: AsOfSource.localSqlite,
      staleAfter: kCredentialListStaleAfter,
      label: '키 기준 ${kstDateText(nowUtc)} ${_two(k.hour)}:${_two(k.minute)}',
    ),
  );
}

/// 🆕 R196 · K208 — 실전 세트 카드 한 장.
CredentialCardVm _liveCard(
  LiveCredentialFacts f, {
  required RunMode runMode,
  required OperatingMode? operatingMode,
}) {
  final String? h = f.record?.health;
  final bool failed = h == CredentialHealthCodes.invalid;
  final bool ok = f.stored && h == CredentialHealthCodes.ok;
  final bool unknown = f.stored && !failed && !ok;
  final bool sim = runMode.isSim;
  final bool advisory = operatingMode == OperatingMode.advisory;
  final (String code, String label) = failed
      ? ('INVALID', '검증 실패')
      : ok
      ? ('OK', '정상')
      : unknown
      ? ('UNKNOWN', '검증 기록 없음')
      : ('NOT_REGISTERED', '미등록');
  final UiLevel level = sim
      ? (failed ? UiLevel.watch : UiLevel.info)
      : failed
      ? UiLevel.act
      : ok
      ? UiLevel.ok
      : unknown
      ? UiLevel.watch
      : advisory
      ? UiLevel.info
      : UiLevel.act;
  final DateTime? at = f.record?.lastVerifiedAtUtc;
  final String? last = at == null || !(failed || h == CredentialHealthCodes.ok)
      ? null
      : failed
      ? '마지막 검증 ${_kstShort(at)} · 거절(${OnboardingResultCodes.credentialRejected})'
      : '마지막 검증 ${_kstShort(at)} · 통과';
  // 🔴 SIM 통과 = 동작 0(봉인 해제 컨트롤 0) · 저장된 키 = «다시 검증»(칸 없음) · 미등록 · 실패 = 칸 + «검증 후 저장».
  final bool reverify = ok || unknown;
  final bool act = !(sim && ok);
  return CredentialCardVm(
    alias: kLiveKeyRegistryAlias[f.kind] ?? f.kind.toLowerCase(),
    kind: f.kind,
    kindLabel: LiveCredentialTexts.kindLabel(f.kind),
    healthCode: code,
    healthLabel: label,
    usage: CredentialUse.full,
    usageLabel: LiveCredentialTexts.usage,
    level: level,
    lastVerifiedText: last,
    requirementLabel: advisory
        ? LiveCredentialTexts.optional
        : sim
        ? LiveCredentialTexts.requiredOnSwitch
        : LiveCredentialTexts.requiredLive,
    whyLine: advisory ? LiveCredentialTexts.advisoryWhy : null,
    sealLabel: sim ? LiveCredentialTexts.seal : null,
    credentialSlotId: act && !reverify
        ? (f.kind == CredentialKindCodes.kisIsa
              ? SettingsSlotIds.secretKisIsa
              : SettingsSlotIds.secretKisLive)
        : null,
    verifyAction: act
        ? SettingsActionCall(
            id: SettingsActionId.credentialVerify,
            args: <String, String>{'kind': f.kind},
            label: reverify ? '다시 검증' : '검증 후 저장',
          )
        : null,
  );
}
