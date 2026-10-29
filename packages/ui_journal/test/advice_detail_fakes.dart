// advice_detail_fakes.dart — A-2 안내 상세 위젯 테스트·골든 공용 가짜와 도우미.
//
// 🔴 가짜는 전부 testing.dart 받침대를 extends 한다 — 화면이 부르면 안 되는 창구는
//    받침대가 던져서 테스트가 실패한다. 한국어 리터럴 0.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/ui_journal.dart';

import 'advice_fakes.dart';
import 'golden/golden_support.dart';
import 'holdings_overview_fakes.dart';

/// A-2 읽기 창구 가짜 — 받은 id 를 호출마다 기록한다.
class FakeAdviceDetailRepository extends UnimplementedAdviceRepository {
  FakeAdviceDetailRepository({required this.item, required this.fills});

  final Future<AdviceItem?> Function(int call) item;
  final Future<List<TradeJournalEntry>> Function(int call) fills;

  /// findById 의 id — 호출마다.
  final List<String> findArgs = <String>[];

  /// fillsOfAdvice 의 id — 호출마다.
  final List<String> fillsArgs = <String>[];

  @override
  Future<AdviceItem?> findById(String adviceId) {
    final int call = findArgs.length;
    findArgs.add(adviceId);
    return item(call);
  }

  @override
  Future<List<TradeJournalEntry>> fillsOfAdvice(String adviceId) {
    final int call = fillsArgs.length;
    fillsArgs.add(adviceId);
    return fills(call);
  }
}

/// A-2 주입 4개.
List<Override> adviceDetailOverrides({
  required FakeAdviceDetailRepository repo,
  SafetyState? safety,
  Clock? clock,
  RecordingLinkOpener? opener,
}) => <Override>[
  journalAdviceRepositoryProvider.overrideWithValue(repo),
  journalSafetyRepositoryProvider.overrideWithValue(
    FakeHoldingsSafetyRepository(safety ?? safetyFixtureRow(0)),
  ),
  journalClockProvider.overrideWithValue(clock ?? FixedClock(kGoldenNowUtc)),
  journalLinkOpenerProvider.overrideWithValue(opener ?? RecordingLinkOpener()),
];

/// 390×3000 · DPR 1.0 으로 A-2 를 띄운다(값 도착까지 pump 두 번).
Future<void> pumpAdviceDetail(
  WidgetTester tester, {
  required List<Override> overrides,
  required String adviceId,
}) async {
  tester.view.physicalSize = const Size(390, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(body: AdviceDetail(adviceId: adviceId)),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

/// A-2 화면에 나올 수 있는 Text 글자 전부(체결 행 글자는 넣지 않는다).
Set<String> adviceDetailAllowed(AdviceItem v) => <String>{
  v.asOf.label,
  ...adviceCardTexts(v),
  ?v.closeReasonLabel,
  for (final ReasonChip c in v.recordedDeviationChips) c.label,
  ?v.decisionLink?.label,
};
