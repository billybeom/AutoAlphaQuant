// 화면 캡처 막기 · 바깥 링크(E11p3d-5 · 설계 13 §8 R107 · 05 §4-2 «스크린샷 방지» · 06 M4-11 ③ ⑤).
//
// 🔴 FLAG_SECURE = 시크릿 · QR · 복구 카드를 보이는 라우트에서만 — 들어갈 때 켜고 **나갈 때 끈다**(켠 채로 두면 다른 화면까지
//    캡처 불가가 된다 · 05 §4-2). 화면이 겹치면(라우트 위에 라우트) 센다 — 마지막 하나가 나갈 때 끈다.
// 🔴 라우트 단위 = 본문 레지스트리에서 감싼다(`secureRouteBodies` · 그 라우트의 본문이 서 있는 동안). 슬롯 단위(온보딩 `SECRET_*` ·
//    `RECOVERY_CHECKSUM`) = 슬롯 위젯이 `SecureScope` 로 감싼다(슬롯 빌더 = 뒤 조각).
// 🔴 바깥 링크 = `https://` 만 브라우저로 — 앱 링크(`aaq://`)는 셸 그대로(`OperatorLinkOpener`).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart'
    show AppLinkOpener, AppRoutes;
import 'package:flutter/widgets.dart';
import 'package:ui_shell/ui_shell.dart' show ShellBodyBuilder, ShellRouteBodies;

import '../platform/android_ops.dart' show isExternalHttps;

/// 🔴 FLAG_SECURE 라우트(R107) — S02 자격증명 · S06 기기 · 접근(QR) · V-01 페어링(QR) · X1 새 폰 받기(QR) · X1 비상(복구 코드) ·
/// 🆕 E16j-b X1 옛 폰 마법사(티켓 QR — 01 §42 K265 «x1Migration = 옛 폰» · 논스 = 리스 클레임 재료).
const Set<String> kSecureRoutePatterns = <String>{
  AppRoutes.settingsCredentials,
  AppRoutes.settingsDevices,
  AppRoutes.onboardingPairing,
  AppRoutes.x1Migration,
  AppRoutes.x1MigrationPlan,
  AppRoutes.x1MigrationEmergency,
};

/// 캡처 막기 겹침 세기.
class SecureScreen {
  /// 만든다 — [set] = 플랫폼 켜기 · 끄기(조립 = `AndroidOps.setSecure`).
  SecureScreen(this._set);

  final Future<void> Function(bool on) _set;
  int _depth = 0;

  /// 지금 겹침 수(시험).
  int get depth => _depth;

  /// 들어간다 — 0 → 1 이면 켠다.
  Future<void> enter() async {
    _depth++;
    if (_depth == 1) await _set(true);
  }

  /// 나간다 — 1 → 0 이면 끈다(0 에서 더 나가지 않는다).
  Future<void> exit() async {
    if (_depth == 0) return;
    _depth--;
    if (_depth == 0) await _set(false);
  }
}

/// 🔴 이 위젯이 서 있는 동안 캡처를 막는다.
class SecureScope extends StatefulWidget {
  /// 만든다.
  const SecureScope({super.key, required this.screen, required this.child});

  /// 겹침 세기.
  final SecureScreen screen;

  /// 감쌀 화면.
  final Widget child;

  @override
  State<SecureScope> createState() => _SecureScopeState();
}

class _SecureScopeState extends State<SecureScope> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.screen.enter());
  }

  @override
  void dispose() {
    unawaited(widget.screen.exit());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// 🔴 본문 레지스트리 — `kSecureRoutePatterns` 의 본문을 `SecureScope` 로 감싼다(나머지 그대로 · 홈 그대로).
ShellRouteBodies secureRouteBodies(
  ShellRouteBodies bodies,
  SecureScreen screen,
) => ShellRouteBodies(<String, ShellBodyBuilder>{
  for (final MapEntry<String, ShellBodyBuilder> e in bodies.byPattern.entries)
    e.key: kSecureRoutePatterns.contains(e.key)
        ? (Map<String, String> p) =>
              SecureScope(screen: screen, child: e.value(p))
        : e.value,
}, home: bodies.home);

/// 🔴 링크 열기 — `https://` = 바깥(브라우저) · 그 밖 = 셸.
class OperatorLinkOpener implements AppLinkOpener {
  /// 만든다.
  const OperatorLinkOpener({required this.inner, required this.external});

  /// 셸 링크 열기.
  final AppLinkOpener inner;

  /// 바깥 링크 열기(조립 = `AndroidOps.openExternalUrl`).
  final Future<bool> Function(String url) external;

  @override
  void open(String link) {
    if (isExternalHttps(link)) {
      unawaited(external(link));
      return;
    }
    inner.open(link);
  }
}
