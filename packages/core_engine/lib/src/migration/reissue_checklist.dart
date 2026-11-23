// X1-3 비상 재발급 6종 체크리스트 · 키 재사용 거부(순수 · 설계 13 §8 R119 C4~C6 · 06 :265 · 08 그림 9-2 :463).
//
// 🔴 KIS 앱키 = 늘 필수(펜싱 2 그 자체) · 그 밖 = 이 계정에서 쓰는 서비스만(안 쓰면 «해당 없음»).
// 🔴 보관해 둔 옛 문자열을 다시 넣는 길은 없다 — 새 값의 지문이 옛 지문 가운데 하나면 `KEY_REUSED`.
//    값은 받지 않는다(지문만 · core `secretFingerprint` = sha256 앞 8).
// 🔴 시각 = 신뢰 시각 · 모르면 받지 않는다.

import 'package:domain_contracts/domain_contracts.dart'
    show SafetyCommonResultCodes, X1ReissueItemCodes, X1ReissueResultCodes;

final RegExp _fp = RegExp(r'^[0-9a-f]{8}$');

/// 재발급 항목(차례 = 06 X1-3 차례).
enum ReissueItem {
  /// KIS 앱키(새 키 지문 필수 · 늘 필수).
  kisAppKey(X1ReissueItemCodes.kisAppKey, '한국투자증권 앱키', hasSecret: true),

  /// 메신저 토큰.
  messengerToken(
    X1ReissueItemCodes.messengerToken,
    '알림 메신저 토큰',
    hasSecret: true,
  ),

  /// 워치독 핑 키(문서 «워치독 슬러그» — 슬러그만 바꿔서는 옛 폰 핑이 막히지 않는다).
  watchdogPingKey(
    X1ReissueItemCodes.watchdogPingKey,
    '감시 핑 키',
    hasSecret: true,
  ),

  /// GitHub PAT.
  githubPat(X1ReissueItemCodes.githubPat, '깃허브 접근 토큰', hasSecret: true),

  /// Supabase 세션 철회(값 없음 — 확인만).
  supabaseSession(
    X1ReissueItemCodes.supabaseSession,
    'Supabase 로그인',
    hasSecret: false,
  ),

  /// 구 기기 Google 액세스 철회 + 새 기기 재인증(값 없음 — 확인만).
  googleAccess(X1ReissueItemCodes.googleAccess, '구글 접근', hasSecret: false);

  const ReissueItem(this.wire, this.label, {required this.hasSecret});

  /// 글자.
  final String wire;

  /// 문구(🆕 E16t3c — 표본 `x1/recovery_emergency_fencing` 글자에서 «(합성)»만 뺀 것 · 화면 `X1ReissueRow.label`).
  final String label;

  /// 새 값 지문이 필요한가(아니면 철회 · 재로그인 확인만).
  final bool hasSecret;
}

/// 재발급 거부 코드(글자 = 계약 `X1ReissueResultCodes` ∪ 공용 `SafetyCommonResultCodes` 참조 · 미결 212).
abstract final class ReissueCodes {
  /// 🔴 옛 값과 같은 값.
  static const String keyReused = X1ReissueResultCodes.keyReused;

  /// 이 계정에서 쓰지 않는 항목.
  static const String notApplicable = X1ReissueResultCodes.notApplicable;

  /// 이미 받은 항목.
  static const String duplicate = X1ReissueResultCodes.duplicate;

  /// 값이 필요한 항목인데 지문이 없다 · 꼴이 틀렸다.
  static const String fingerprintRequired =
      X1ReissueResultCodes.fingerprintRequired;

  /// 확인만 하는 항목에 지문이 왔다.
  static const String fingerprintUnexpected =
      X1ReissueResultCodes.fingerprintUnexpected;

  /// 신뢰 시각 모름.
  static const String trustedTimeUnknown =
      SafetyCommonResultCodes.trustedTimeUnknown;
}

/// 받은 항목 하나.
class ReissueEntry {
  const ReissueEntry._(this.item, this.fingerprint, this.atUtc);

  /// 항목.
  final ReissueItem item;

  /// 새 값 지문(확인만 = null).
  final String? fingerprint;

  /// 받은 신뢰 시각.
  final DateTime atUtc;
}

/// 재발급 체크리스트(불변 · [accept] 가 새 판을 돌려준다).
class ReissueChecklist {
  ReissueChecklist._(this.applicable, this.entries);

  /// 시작 — [usedServices] = 이 계정에서 쓰는 항목(🔴 KIS 앱키는 넣지 않아도 늘 들어간다).
  factory ReissueChecklist.start(Set<ReissueItem> usedServices) =>
      ReissueChecklist._(<ReissueItem>{
        ReissueItem.kisAppKey,
        ...usedServices,
      }, const <ReissueItem, ReissueEntry>{});

  /// 해야 하는 항목.
  final Set<ReissueItem> applicable;

  /// 받은 항목.
  final Map<ReissueItem, ReissueEntry> entries;

  /// 해당 없음 항목(06 차례).
  List<ReissueItem> get notApplicable => ReissueItem.values
      .where((ReissueItem i) => !applicable.contains(i))
      .toList();

  /// 남은 항목(06 차례).
  List<ReissueItem> get remaining => ReissueItem.values
      .where(
        (ReissueItem i) => applicable.contains(i) && !entries.containsKey(i),
      )
      .toList();

  /// 다 했나.
  bool get complete => remaining.isEmpty;

  /// 🔴 [item] 을 받는다 — 거부면 (null, 코드) · 받으면 (새 판, null).
  ///
  /// [priorFingerprints] = 옛 값들의 지문(보관 문자열 · 백업 · 금고) · [fingerprint] = 새 값 지문(확인만 항목 = null).
  (ReissueChecklist?, String?) accept(
    ReissueItem item, {
    required String? fingerprint,
    required Set<String> priorFingerprints,
    required DateTime? trustedNowUtc,
  }) {
    if (!applicable.contains(item)) return (null, ReissueCodes.notApplicable);
    if (entries.containsKey(item)) return (null, ReissueCodes.duplicate);
    if (item.hasSecret) {
      if (fingerprint == null || !_fp.hasMatch(fingerprint)) {
        return (null, ReissueCodes.fingerprintRequired);
      }
      if (priorFingerprints.contains(fingerprint)) {
        return (null, ReissueCodes.keyReused);
      }
    } else if (fingerprint != null) {
      return (null, ReissueCodes.fingerprintUnexpected);
    }
    if (trustedNowUtc == null) return (null, ReissueCodes.trustedTimeUnknown);
    return (
      ReissueChecklist._(applicable, <ReissueItem, ReissueEntry>{
        ...entries,
        item: ReissueEntry._(item, fingerprint, trustedNowUtc.toUtc()),
      }),
      null,
    );
  }
}
