// advice_skip_fakes.dart — A-4 미이행 사유 위젯 테스트·골든 공용 가짜와 도우미.
//
// 🔴 가짜는 전부 testing.dart 받침대를 extends 한다 — 화면이 부르면 안 되는 창구는
//    받침대가 던져서 테스트가 실패한다. 한국어 리터럴 0.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_journal/journal_draft.dart';
import 'package:ui_journal/ui_journal.dart';

import 'golden/golden_support.dart';
import 'holdings_overview_fakes.dart';

/// A-4 읽기 창구 가짜 — 받은 인자를 호출마다 기록한다.
class FakeAdviceFormRepository extends UnimplementedAdviceRepository {
  FakeAdviceFormRepository({required this.item, required this.spec});

  final Future<AdviceItem?> Function(int call) item;
  final Stream<ManualFillFormSpec> Function(int call) spec;

  /// findById 의 id — 호출마다.
  final List<String> findArgs = <String>[];
  int specCalls = 0;

  @override
  Future<AdviceItem?> findById(String adviceId) {
    final int call = findArgs.length;
    findArgs.add(adviceId);
    return item(call);
  }

  @override
  Stream<ManualFillFormSpec> watchManualFillFormSpec() {
    final int call = specCalls;
    specCalls = specCalls + 1;
    return spec(call);
  }
}

/// A-4 명령 가짜 — 받은 제출·구독 id 를 호출마다 기록한다.
class FakeAdviceSkipCommandApi extends UnimplementedCommandApi {
  FakeAdviceSkipCommandApi({required this.skip, required this.watch});

  final Future<CommandReceipt> Function(int call) skip;
  final Stream<CommandReceipt> Function(int call) watch;

  final List<AdviceSkipSubmission> skipped = <AdviceSkipSubmission>[];
  final List<String> watched = <String>[];

  @override
  Future<CommandReceipt> skipAdvice(AdviceSkipSubmission submission) {
    final int call = skipped.length;
    skipped.add(submission);
    return skip(call);
  }

  @override
  Stream<CommandReceipt> watchCommand(String commandId) {
    final int call = watched.length;
    watched.add(commandId);
    return watch(call);
  }
}

/// A-4 주입 6개.
List<Override> adviceSkipOverrides({
  required FakeAdviceFormRepository repo,
  required CommandApi cmd,
  required DraftStore store,
  SafetyState? safety,
  Clock? clock,
  RecordingLinkOpener? opener,
}) => <Override>[
  journalAdviceRepositoryProvider.overrideWithValue(repo),
  journalCommandApiProvider.overrideWithValue(cmd),
  journalDraftStoreProvider.overrideWithValue(store),
  journalSafetyRepositoryProvider.overrideWithValue(
    FakeHoldingsSafetyRepository(safety ?? safetyFixtureRow(0)),
  ),
  journalClockProvider.overrideWithValue(clock ?? FixedClock(kGoldenNowUtc)),
  journalLinkOpenerProvider.overrideWithValue(opener ?? RecordingLinkOpener()),
];

/// 390×3000 · DPR 1.0 으로 A-4 를 띄운다(값 도착까지 pump 두 번).
Future<void> pumpAdviceSkip(
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
        home: Scaffold(body: AdviceSkipForm(adviceId: adviceId)),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

/// 복원 id 시드 — 입력 준비(화면 판정 아님).
DraftRecord adviceSkipSeedWithCommand(DraftRecord r, String commandId) =>
    r.copyWith(lastCommandId: commandId);

/// 참조 카드 안 Text 순서 — 화면의 build 순서 그대로.
List<String> adviceFormRefTexts(AdviceItem v) => <String>[
  ?v.symbolLabel,
  ?v.sideLabel,
  v.sizingLabel,
  ?v.priceBand?.label,
  v.validityLabel,
  v.progressLabel,
];

/// A-4 화면에 나올 수 있는 Text 글자 전부.
Set<String> adviceSkipAllowed(ManualFillFormSpec s, AdviceItem v) => <String>{
  s.asOf.label,
  ?s.bannerText,
  ...adviceFormRefTexts(v),
  s.skipNoticeText,
  for (final ReasonOption o in s.skipReasons) o.label,
  ?s.blockedText,
};
