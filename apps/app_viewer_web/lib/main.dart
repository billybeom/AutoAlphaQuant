// AutoAlphaQuant — viewer 타깃 진입점 (웹·데스크탑 공유) — ⚠️ 스텁
//
// 🔴 이 타깃이 v1에 들어가는지는 **발주자 결정 Q-D 대기 중**이다(00_README §8-2).
//    결정 전까지 여기에 화면을 붙이지 않는다 — 빼기로 나면 지울 코드이기 때문이다.
//
// 계약 쪽 스위치는 이미 있다: `FeatureFlags.webViewerEnabled`(01 §2-1).
// Q-D가 「포함」으로 나면 ① pubspec의 «Q-D 확정 시 살릴 목록» 주석 해제
//                        ② app_viewer_ios/lib/main.dart와 같은 조립 코드 적용
//                        ③ docs/TARGETS.md의 ⚠️ 열 갱신 — 순서로 진행한다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: AutoAlphaQuantWebViewerApp()));
}

/// 웹 viewer 앱 루트 — 스텁.
class AutoAlphaQuantWebViewerApp extends StatelessWidget {
  const AutoAlphaQuantWebViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoAlphaQuant',
      theme: ThemeData(useMaterial3: true),
      home: const _ScaffoldStub(),
    );
  }
}

/// 🔴 사용자에게 보이는 한국어 문구를 여기서 만들지 않는다(금지 2항).
class _ScaffoldStub extends StatelessWidget {
  const _ScaffoldStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('AutoAlphaQuant / viewer (web) — stub')),
    );
  }
}
