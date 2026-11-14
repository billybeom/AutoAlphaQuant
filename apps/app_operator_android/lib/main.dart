// AutoAlphaQuant — operator 타깃 진입점 (Android)
//
// 🔴 이 앱은 조립만 한다 — 계산 · 판정 · 사유 문구를 넣지 않는다(00_README §5).
// 🔴 이 `main()` 은 화면이 없어도 돈다 — FGS 가 엔진을 소유하고(알람 · 부팅으로 뜬 프로세스) 화면은 그 엔진에 붙는다.
//
//   1) ✅ E11p2 — FGS · 정확 알람 · 부팅 기동(`startOperatorPlatform`)
//   2) ✅ E11p3a~c — 엔진 조립 · 잡 실물 · FGS 상태
//   3) 🆕 E11p3d-1(설계 13 §8 R104) — 셸 뼈대: 엔진과 같은 원장(`OperatorRuntime`) · 실물 있는 칸만 주입 ·
//      실물 있는 화면만 등록(알림 센터 · 상세) · 딥링크(FGS 탭) → 셸 링크 열기. 나머지 화면 = 셸 «자리 부재».

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_shell/ui_shell.dart';

import 'app/operator_runtime.dart';
import 'app/operator_shell.dart';
import 'platform/platform.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final OperatorRuntime? runtime = await openOperatorRuntime();
  final ProviderContainer container = ProviderContainer(
    overrides: runtime == null
        ? const <Override>[]
        : operatorShellOverrides(runtime),
  );
  final LinkRelay relay = LinkRelay(
    opener: () => container.read(shellLinkOpenerProvider),
    ready: () => container.read(shellNavigatorKeyProvider).currentState != null,
  );
  void retry() {
    WidgetsBinding.instance.addPostFrameCallback((_) => relay.deliver());
    WidgetsBinding.instance.scheduleFrame();
  }

  runtime?.view.addListener(retry);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: AutoAlphaQuantOperatorApp(shell: runtime != null),
    ),
  );
  unawaited(
    startOperatorPlatform(
      runtime: runtime,
      onLink: (String link) {
        relay.receive(link);
        retry();
      },
    ),
  );
}

/// operator 앱 루트. 전 기능(엔진·주문·키·안전 화면)을 싣는 유일한 타깃이다.
class AutoAlphaQuantOperatorApp extends StatelessWidget {
  /// 만든다 — [shell] = 실행 묶음이 섰나(아니면 빈 화면 · 시험 · 다른 타깃).
  const AutoAlphaQuantOperatorApp({super.key, this.shell = false});

  /// 셸을 띄우나.
  final bool shell;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoAlphaQuant',
      theme: ThemeData(useMaterial3: true),
      // ⚠️ 다크 테마·로케일은 ui_shell이 셸을 내놓을 때 함께 정한다.
      builder: shell ? _band : null,
      home: shell ? const ShellRoot() : const _ScaffoldStub(),
    );
  }
}

Widget _band(BuildContext context, Widget? child) =>
    ShellBandOverlay(child: child ?? const SizedBox.shrink());

/// 실행 묶음이 없을 때의 빈 화면(Android 가 아님 · 폴더를 못 얻음 — 엔진은 깨어날 때 다시 시도한다).
/// 🔴 사용자에게 보이는 한국어 문구를 여기서 만들지 않는다(금지 2항) — 타깃 식별용 ASCII 뿐.
class _ScaffoldStub extends StatelessWidget {
  const _ScaffoldStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('AutoAlphaQuant / operator')),
    );
  }
}
