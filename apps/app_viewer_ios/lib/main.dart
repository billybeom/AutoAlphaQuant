// AutoAlphaQuant — viewer 타깃 진입점 (iOS)
//
// 🔴 읽기 전용 타깃이다. 엔진도, 주문도, 브로커 키도 이 앱에 없다(pubspec 주석 참조).
//    여기서 할 수 있는 쓰기는 두 갈래뿐이다 — ① 저널 작성 ② 킬스위치 «발동».
//    둘 다 append-only 명령으로 나가고, 서버 RLS가 한 번 더 막는다(01 §6-4).
//
// ⚠️ 지금은 뼈대다. 화면 조립은 M2 계약 확정(G3) 이후.
//    "엔진이 멈췄다" 판정은 push된 상태값이 아니라 `AsOf.observedAt` 신선도에서
//    파생한다(01 §1-3) — 죽은 엔진은 자기가 죽었다고 알려 주지 않기 때문이다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: AutoAlphaQuantViewerApp()));
}

/// viewer 앱 루트(iOS). 조회 + 저널 작성 + 킬스위치 발동까지.
class AutoAlphaQuantViewerApp extends StatelessWidget {
  const AutoAlphaQuantViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoAlphaQuant',
      theme: ThemeData(useMaterial3: true),
      home: const _ScaffoldStub(),
    );
  }
}

/// 화면 패키지가 붙기 전까지의 빈 화면.
/// 🔴 사용자에게 보이는 한국어 문구를 여기서 만들지 않는다(금지 2항).
class _ScaffoldStub extends StatelessWidget {
  const _ScaffoldStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('AutoAlphaQuant / viewer (iOS)')),
    );
  }
}
