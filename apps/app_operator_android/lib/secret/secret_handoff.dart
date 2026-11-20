// 시크릿 값 넘김 · 클립보드 정리 · 붙여넣기 형식 판정(E11p3d-5b · 설계 13 §8 R115 · 06 M4-4 · 05 §4).
//
// 🔴 원칙 3(단일 저장 경로) — 붙여넣은 값은 **위젯 상태에만** 있다. 이 파일의 어떤 객체도 값을 복사해 두지 않는다:
//    [SecretHandoff] = 지금 붙어 있는 위젯을 가리킬 뿐(검증 직전에 위젯에게 묻는다) · [ClipboardJanitor] = 값의 지문만.
// 🔴 원칙 4(검증 전 저장 금지) — 금고 저장은 검증 동작(`credentialVerify` — operator `SettingsActions` 구현 · 다음 조각)이
//    통과한 뒤에만 · 이 조각에는 저장 호출이 없다.
// 🔴 원칙 1(붙여넣기 우선) — 클립보드는 붙여넣은 뒤 60초에 비운다(그 사이 다른 것을 복사했으면 두고 · 못 읽으면 비운다).
// 🔴 원칙 6(형식 감지 거부) — 다른 서비스의 키 꼴 · 빈칸 · 줄바꿈 · 짧은 값은 입력 단계에서 거부(진짜 확인 = 검증 · 원칙 5).

import 'dart:async';

import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentials, KisKeySet;
import 'package:core_engine/core_engine.dart' show secretFingerprint;
import 'package:domain_contracts/domain_contracts.dart'
    show OnboardingSlotIds, SettingsSlotIds;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

/// 🔴 슬롯 이름 → KIS 키 세트(엔진에 있는 세트만 · 없으면 null = 자리 부재) · 🆕 R196 실전 2(`SECRET_KIS_LIVE` · `SECRET_KIS_ISA`).
KisKeySet? kisKeySetOfSlot(String slotId) {
  if (slotId == OnboardingSlotIds.secretKisMock) return KisKeySet.paper;
  if (slotId == SettingsSlotIds.secretKisLive) return KisKeySet.live;
  if (slotId == SettingsSlotIds.secretKisIsa) return KisKeySet.isa;
  return null;
}

/// 붙여넣은 값의 원천 — 값은 이 원천(위젯 상태) 안에만 있다.
abstract interface class KisDraftSource {
  /// 지금 값 — 세 칸이 다 차고 엔진 형식(`KisCredentials`)을 지나면 · 아니면 null.
  KisCredentials? current();

  /// 값을 비운다(저장 뒤 · 취소).
  void clear();
}

/// 🔴 위젯 ↔ 검증 동작 사이의 넘김(조립 앱 내부 · 계약 칸 0 · 01 §29 K5).
class SecretHandoff {
  final Map<KisKeySet, KisDraftSource> _live = <KisKeySet, KisDraftSource>{};

  /// 위젯이 설 때 붙는다(같은 세트 = 나중 것이 이긴다).
  void attach(KisKeySet set, KisDraftSource source) => _live[set] = source;

  /// 위젯이 내려갈 때 떨어진다(자기 자리일 때만).
  void detach(KisKeySet set, KisDraftSource source) {
    if (identical(_live[set], source)) _live.remove(set);
  }

  /// 그 세트의 칸이 화면에 있나 — 검증 동작이 «칸 없음» 과 «덜 참» 을 다른 문구로 말하게(조치가 다르다).
  bool isOnScreen(KisKeySet set) => _live.containsKey(set);

  /// 검증 직전 — 지금 붙어 있는 위젯의 값(없음 · 덜 참 = null) · 🔴 복사해 두지 않는다.
  KisCredentials? draftOf(KisKeySet set) => _live[set]?.current();

  /// 저장 뒤 — 위젯의 값을 비운다.
  void clearAfterSave(KisKeySet set) => _live[set]?.clear();
}

/// 🔴 클립보드 정리(원칙 1) — 붙여넣은 뒤 [after] 에 비운다 · 값 대신 지문만 쥔다.
class ClipboardJanitor {
  /// 만든다 — [read] · [write] = 플랫폼(시험 = 가짜).
  ClipboardJanitor({
    this.after = const Duration(seconds: 60),
    Future<String?> Function()? read,
    Future<void> Function(String text)? write,
  }) : _read = read ?? _readClipboard,
       _write = write ?? _writeClipboard;

  /// 비우기까지의 시간.
  final Duration after;

  final Future<String?> Function() _read;
  final Future<void> Function(String text) _write;
  Timer? _timer;
  String? _print;

  static Future<String?> _readClipboard() async =>
      (await Clipboard.getData(Clipboard.kTextPlain))?.text;

  static Future<void> _writeClipboard(String text) =>
      Clipboard.setData(ClipboardData(text: text));

  /// 방금 붙여넣은 값 — [after] 뒤에 클립보드를 비운다(다시 붙여넣으면 다시 센다).
  void pasted(String value) {
    _print = secretFingerprint(value);
    _timer?.cancel();
    _timer = Timer(after, () => unawaited(_sweep()));
  }

  Future<void> _sweep() async {
    final String? mine = _print;
    _print = null;
    _timer = null;
    if (mine == null) return;
    String? now;
    try {
      now = await _read();
    } on Object {
      now = null;
    }
    // 못 읽음 = 비운다(안전 쪽) · 그 사이 다른 것을 복사했으면 둔다.
    if (now == null || now.isEmpty || secretFingerprint(now) == mine) {
      await _write('');
    }
  }

  /// 대기 중인 정리를 지금 한다(앱이 닫힐 때 · 시험).
  Future<void> flush() async {
    _timer?.cancel();
    await _sweep();
  }

  /// 멈춘다(정리하지 않는다).
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _print = null;
  }
}

/// KIS 키 세트의 붙여넣기 칸.
enum KisPasteField {
  /// 앱키.
  appKey,

  /// 앱 시크릿.
  appSecret,

  /// 계좌번호(종합계좌 8자리 · `-` 뒤 상품코드 2자리 선택).
  account,
}

/// 붙여넣기 거부 사유.
enum KisPasteProblem {
  /// 비었다.
  empty,

  /// 빈칸 · 줄바꿈 · 따옴표가 섞였다.
  whitespace,

  /// 다른 서비스의 키 꼴(JWT · GitHub · Google · 주소 등).
  foreignKey,

  /// 앱키 꼴이 아니다(영숫자 16자 이상 · 실험 5 와 같은 판정).
  notAppKey,

  /// 계좌번호 꼴이 아니다(숫자 8자리 · `-` 뒤 2자리 선택).
  notAccount,
}

final RegExp _space = RegExp(r'''[\s"'`]''');
final RegExp _account = RegExp(r'^(\d{8})(?:-(\d{2}))?$');
const List<String> _foreign = <String>[
  'eyJ', // JWT(Supabase service_role · anon)
  'ghp_', 'gho_', 'ghu_', 'ghs_', 'github_pat_', // GitHub
  'ya29.', '1//', // Google OAuth
  'sb_secret_', 'sb_publishable_', // Supabase 새 키
  'xox', // 메신저 봇
  'http://', 'https://', 'postgres://', 'postgresql://', // 주소(ping URL 등)
];

/// 🔴 붙여넣기 판정(원칙 6) — 문제 없음 = null. [raw] 는 앞뒤 빈칸을 떼고 본다.
KisPasteProblem? kisPasteProblem(KisPasteField field, String raw) {
  final String v = raw.trim();
  if (v.isEmpty) return KisPasteProblem.empty;
  if (_space.hasMatch(v)) return KisPasteProblem.whitespace;
  for (final String p in _foreign) {
    if (v.startsWith(p)) return KisPasteProblem.foreignKey;
  }
  switch (field) {
    case KisPasteField.appKey:
    case KisPasteField.appSecret:
      final bool ascii = v.codeUnits.every((int c) => c > 32 && c < 127);
      return ascii && v.length >= 16 ? null : KisPasteProblem.notAppKey;
    case KisPasteField.account:
      return _account.hasMatch(v) ? null : KisPasteProblem.notAccount;
  }
}

/// 계좌 붙여넣기 → (종합계좌 8자리, 상품코드 2자리 · 없으면 null). 판정을 지난 값만.
(String, String?) splitKisAccount(String raw) {
  final RegExpMatch m = _account.firstMatch(raw.trim())!;
  return (m.group(1)!, m.group(2));
}
