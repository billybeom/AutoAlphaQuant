// AutoAlphaQuant — operator 타깃 진입점 (Android)
//
// 🔴 지금은 «뼈대»다. 화면·엔진 조립 코드는 M2 계약 확정(G3) 이후에 들어온다.
//    여기에 계산·판정·사유 문구를 넣지 않는다 — 이 앱은 조립만 한다(00_README §5).
//
// 앞으로 이 파일이 할 일(구현 순서는 06_Claude전담_상세설계_작업목록 참조):
//   1) data_sync가 만든 리포지토리·명령 API 구현체를 Riverpod 프로바이더로 주입
//   2) trading_runtime의 Foreground Service·정확 알람 부팅
//   3) ui_shell이 노출하는 5탭 셸을 home으로 연결
//
// ⚠️ 위 3개는 각 패키지의 공개 API가 생긴 뒤에 import한다. 아직 없는 심볼을
//    미리 적어 두면 SDK 설치 직후 첫 빌드가 깨진다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // ProviderScope = Riverpod의 최상위 컨테이너. 의존 주입(overrides)이 여기로 들어온다.
  runApp(const ProviderScope(child: AutoAlphaQuantOperatorApp()));
}

/// operator 앱 루트. 전 기능(엔진·주문·키·안전 화면)을 싣는 유일한 타깃이다.
class AutoAlphaQuantOperatorApp extends StatelessWidget {
  const AutoAlphaQuantOperatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoAlphaQuant',
      theme: ThemeData(useMaterial3: true),
      // ⚠️ 다크 테마·로케일은 ui_shell이 셸을 내놓을 때 함께 정한다.
      home: const _ScaffoldStub(),
    );
  }
}

/// 화면 패키지가 붙기 전까지의 빈 화면.
/// 🔴 사용자에게 보이는 한국어 문구를 여기서 만들지 않는다(금지 2항). 자리 표시 문자열은
///    타깃 식별용 ASCII뿐이며, 실제 셸이 붙는 순간 이 위젯은 통째로 사라진다.
class _ScaffoldStub extends StatelessWidget {
  const _ScaffoldStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('AutoAlphaQuant / operator')),
    );
  }
}
