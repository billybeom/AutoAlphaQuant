// golden_support.dart — C-2 위젯 골든 공용 도우미 (ui_analytics · M2 소유)
//
// 무엇을 하나: 픽스처 JSON 을 읽어 계약 DTO 로 만들고, 위젯을 고정 크기 폰 화면에
//   light/dark 로 올린 뒤 `goldens/<이름>_<light|dark>.png` 와 비교한다.
//   ui_journal 의 같은 파일과 규약이 같고, 로더만 **제네릭**이다(M7 은 봉투 안에 1행짜리
//   리포트·4행짜리 신뢰 등급·5행짜리 회계 기준값이 섞여 있어 타입을 호출자가 넘긴다).
//
// 🔴 픽스처는 M2 소유다 — 여기서 **값을 고치지 않는다**. 슬라이스(행 고르기)는 허용된다.
// 🔴 `DateTime.now()` 를 부르지 않는다 — 신선도 판정에 쓰는 시계는 [FixedClock] 으로 주입한다.
// 🔴 한국어 문자열 리터럴을 두지 않는다 — 화면에 보이는 글자는 전부 픽스처에서 온다.
//
// 쓰는 법은 test/golden/README.md 「하네스」 절의 s71_golden_test.dart 예시를 따른다.

import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// `flutter test` 는 패키지 루트(`packages/ui_analytics`)에서 돈다. 픽스처는 형제 패키지에 있다.
///
/// 🔴 절대 경로를 적지 않는다(01 §5) — 실행 위치에서 상대로 찾는다.
Directory fixturesDir() =>
    Directory('${Directory.current.path}/../domain_contracts/fixtures');

/// 픽스처 원문(UTF-8). [relPath] 는 `FixturePaths` 상수를 그대로 넘긴다.
String fixtureText(String relPath) =>
    File('${fixturesDir().path}/$relPath').readAsStringSync();

/// 봉투 원형(meta·as_of·empty_kind·empty_label·has_more·rows 원시 Map).
/// 봉투 값(`empty_kind`·`empty_label` 등)을 직접 볼 때 쓴다.
/// 🔵 v1.1 — `m7_monthly_pending.json` 의 봉투 형제 키 `pending_d_day_text` 는 **폐기**됐다
///    (D-day 문장은 행의 `MonthlyReport.pendingNoticeText` 로 온다 — 01 §8 미결 40).
FixtureEnvelope fixtureEnvelope(String relPath) =>
    decodeEnvelope(fixtureText(relPath));

/// 목록 픽스처 → `ListResult<T>`. 예: `listFixture(FixturePaths.m7LedgerTrust4, LedgerTrustBadge.fromJson)`.
ListResult<T> listFixture<T>(
  String relPath,
  T Function(Map<String, dynamic>) fromJson,
) => decodeList<T>(fixtureText(relPath), fromJson);

/// 1행 픽스처 → 그 DTO. 예: `singleFixture(FixturePaths.m7M7Monthly202608, MonthlyReport.fromJson)`.
/// 🔴 행이 정확히 1개가 아니면 던진다 — 「첫 행을 쓴다」는 조용한 판정이다.
T singleFixture<T>(String relPath, T Function(Map<String, dynamic>) fromJson) =>
    decodeSingle<T>(fixtureText(relPath), fromJson);

/// 01 §1-3 — 주입 시계. 골든은 고정값으로 찍는다.
class FixedClock implements Clock {
  const FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime nowUtc() => _now;
}

/// 픽스처 `as_of.observed_at`(2026-08-31T09:00Z) + 1시간. `stale_after_seconds` 안이라
/// «신선»으로 판정된다. stale 골든이 필요하면 이 값에 2일을 더해 새 상수를 만든다.
final DateTime kGoldenNowUtc = DateTime.utc(2026, 8, 31, 10);

/// 골든이 찍는 화면 크기(논리 픽셀 · 폰 세로). 🔴 M2 만 바꾼다 — 바꾸면 전 골든이 깨진다.
const Size kGoldenPhoneSize = Size(390, 844);

/// 골든 대상 서브트리를 가리키는 키.
const Key goldenBoundaryKey = Key('golden-boundary');

/// [child] 를 고정 크기 폰 화면·[brightness] 테마로 올린다.
///
/// 스트림 프로바이더가 첫 값을 내보내도록 한 프레임 더 pump 한다.
///
/// 🆕 [wrapApp] — `MaterialApp` **바깥**을 감싼다(2026-09-21 · C4 R1b-Bob-J1 Q5).
///    바텀시트·다이얼로그 같은 **모달**은 `MaterialApp` 의 Navigator 위에 뜨므로, 주입
///    (`ProviderScope(overrides: …)`)이 `child` 안쪽에 있으면 모달이 그 주입을 보지 못한다
///    (실제 앱은 `ProviderScope` 가 앱 루트에 있어 문제가 없다 — 하네스만의 제약이었다).
///    모달을 여는 골든·테스트는 주입을 여기로 올린다:
///
///        await pumpForGolden(
///          tester,
///          const JournalTimeline(),
///          brightness: b,
///          wrapApp: (Widget app) => ProviderScope(overrides: <Override>[…], child: app),
///        );
///        await tester.tap(find.text(JournalLabels.filter));
///        await tester.pumpAndSettle();
///        await expectGolden('j1_filter_open', b);
///
///    모달이 없는 화면은 지금까지처럼 `child` 에 `ProviderScope` 를 넣어도 된다(기존 골든 무변경).
Future<void> pumpForGolden(
  WidgetTester tester,
  Widget child, {
  required Brightness brightness,
  Size logicalSize = kGoldenPhoneSize,
  Widget Function(Widget app)? wrapApp,
}) async {
  tester.view.physicalSize = logicalSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final Widget app = MaterialApp(
    // DEBUG 리본이 골든 오른쪽 위를 덮는다 — 2026-09-23 infra
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, brightness: brightness),
    home: Scaffold(body: child),
  );
  await tester.pumpWidget(
    RepaintBoundary(
      key: goldenBoundaryKey,
      child: wrapApp == null ? app : wrapApp(app),
    ),
  );
  await tester.pump();
}

/// `goldens/<name>_<light|dark>.png` 와 비교한다(경로는 테스트 파일 기준).
///
/// 최초 베이스라인은 **새 테스트 파일을 지정해**
/// `flutter test --update-goldens test/golden/<화면id>_golden_test.dart` **한 번**으로 만든다.
/// 🔴 폴더 지정(`test/golden`) 금지 — 이미 있는 다른 화면의 PNG 까지 다시 찍힌다(README 만드는 순서 2).
/// 그 뒤 픽스처가 그대로인데 다시 찍는 것은 위조다(01 §7).
Future<void> expectGolden(String name, Brightness brightness) => expectLater(
  find.byKey(goldenBoundaryKey),
  matchesGoldenFile('goldens/${name}_${brightnessSuffix(brightness)}.png'),
);

/// 파일명 접미 — `light` / `dark`.
String brightnessSuffix(Brightness brightness) => switch (brightness) {
  Brightness.light => 'light',
  Brightness.dark => 'dark',
};
