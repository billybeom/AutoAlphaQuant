// M5-14 가상 초기금 화면(설계 13 §8 R156) — 접수증 = 계약 픽스처 `m6/self_report_receipts_5` 의 행(지어내지 않는다).

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_safety/sim_opening.dart';
import 'package:ui_safety/ui_safety.dart' show SafetyLabels;

List<CommandReceipt> _receipts() {
  final Map<String, dynamic> j = jsonDecode(
    File('../domain_contracts/fixtures/${FixturePaths.m6SelfReportReceipts5}')
        .readAsStringSync(),
  ) as Map<String, dynamic>;
  return <CommandReceipt>[
    for (final Object? r in j['rows'] as List<Object?>)
      CommandReceipt.fromJson(r! as Map<String, dynamic>),
  ];
}

final List<CommandReceipt> _rows = _receipts();

CommandReceipt _of(CommandState s) =>
    _rows.firstWhere((CommandReceipt r) => r.state == s);

class _Api extends UnimplementedCommandApi {
  _Api(this.reply, {this.follow});

  final Future<CommandReceipt> Function() reply;
  final Stream<CommandReceipt>? follow;
  final List<SelfReportSubmission> sent = <SelfReportSubmission>[];
  final List<String> watched = <String>[];

  @override
  Future<CommandReceipt> submitSelfReportBalance(
    SelfReportSubmission submission,
  ) {
    sent.add(submission);
    return reply();
  }

  @override
  Stream<CommandReceipt> watchCommand(String commandId) {
    watched.add(commandId);
    return follow ?? const Stream<CommandReceipt>.empty();
  }
}

Future<void> _pump(WidgetTester tester, CommandApi? api) => tester.pumpWidget(
  ProviderScope(
    overrides: <Override>[
      safetySimOpeningCommandApiProvider.overrideWithValue(api),
    ],
    child: const MaterialApp(home: Scaffold(body: SimOpeningCash())),
  ),
);

TextField _field(WidgetTester tester) =>
    tester.widget<TextField>(find.byKey(const Key('m5-14-cash')));

FilledButton _button(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byKey(const Key('m5-14-submit')));

String _receiptText(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('m5-14-receipt'))).data!;

void main() {
  test('픽스처 = 요청됨 · 실행 · 거부 행이 있다(시험 전제)', () {
    for (final CommandState s in <CommandState>[
      CommandState.requested,
      CommandState.executed,
      CommandState.rejected,
    ]) {
      expect(_of(s).kind, CommandKind.selfReportBalance, reason: s.name);
    }
  });

  testWidgets('🔴 처음 = 빈칸(기본값 없음) · 숫자 자판 · 정적 글자 · 버튼 열림 · 접수증 없음', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _Api(() async => _of(CommandState.executed)));
    expect(find.text(SafetyLabels.simOpeningCashTitle), findsOneWidget);
    expect(find.text(SafetyLabels.simOpeningCashNote), findsOneWidget);
    expect(find.text(SafetyLabels.simOpeningCashField), findsOneWidget);
    expect(find.text(SafetyLabels.simOpeningCashSubmit), findsOneWidget);
    expect(_field(tester).controller!.text, '');
    expect(_field(tester).enabled, isTrue);
    expect(_field(tester).keyboardType, TextInputType.number);
    expect(_button(tester).onPressed, isNotNull);
    expect(find.byKey(const Key('m5-14-receipt')), findsNothing);
    expect(find.byKey(const Key('m5-14-not-accepted')), findsNothing);
  });

  testWidgets(
    '🔴 화면 검증 0 — 빈칸도 그대로 낸다(모의 개시 · 확인값 참) · 거부 = 엔진 글자 · 다시 낼 수 있다',
    (WidgetTester tester) async {
      final CommandReceipt no = _of(CommandState.rejected);
      final _Api api = _Api(() async => no);
      await _pump(tester, api);
      await tester.tap(find.byKey(const Key('m5-14-submit')));
      await tester.pumpAndSettle();
      expect(api.sent, hasLength(1));
      expect(api.sent.single.purpose, SelfReportPurpose.simOpening);
      expect(api.sent.single.yyyyMm, isNull);
      expect(api.sent.single.input, const SelfReportInput());
      expect(api.sent.single.declaredComplete, isTrue);
      expect(_receiptText(tester), no.stateLabel);
      final Text t = tester.widget<Text>(
        find.byKey(const Key('m5-14-receipt')),
      );
      expect(
        t.style?.color,
        Theme.of(tester.element(find.byType(SimOpeningCash))).colorScheme.error,
      );
      expect(_field(tester).enabled, isTrue);
      expect(_button(tester).onPressed, isNotNull);
      expect(api.watched, isEmpty);
    },
  );

  testWidgets('🔴 적은 글자 그대로 · 실행 = 엔진 글자 · 칸 · 버튼 잠금(두 번 선언 0)', (
    WidgetTester tester,
  ) async {
    final CommandReceipt ok = _of(CommandState.executed);
    final _Api api = _Api(() async => ok);
    await _pump(tester, api);
    await tester.enterText(find.byKey(const Key('m5-14-cash')), ' 10,000,000');
    await tester.tap(find.byKey(const Key('m5-14-submit')));
    await tester.pumpAndSettle();
    expect(api.sent.single.input.cashKrwText, ' 10,000,000');
    expect(api.sent.single.input.lines, isEmpty);
    expect(api.sent.single.input.accountAlias, isNull);
    expect(_receiptText(tester), ok.stateLabel);
    expect(
      tester.widget<Text>(find.byKey(const Key('m5-14-receipt'))).style,
      isNull,
    );
    expect(_field(tester).enabled, isFalse);
    expect(_button(tester).onPressed, isNull);
  });

  testWidgets('🔴 끝나지 않은 접수증 = watchCommand 를 따라간다(기다리는 동안 잠금) · 실행 글자로 바뀐다', (
    WidgetTester tester,
  ) async {
    final CommandReceipt req = _of(CommandState.requested);
    final CommandReceipt ok = _of(CommandState.executed);
    final StreamController<CommandReceipt> c =
        StreamController<CommandReceipt>();
    final _Api api = _Api(() async => req, follow: c.stream);
    await _pump(tester, api);
    await tester.enterText(find.byKey(const Key('m5-14-cash')), '5000000');
    await tester.tap(find.byKey(const Key('m5-14-submit')));
    await tester.pump();
    expect(api.watched, <String>[req.commandId]);
    expect(_receiptText(tester), req.stateLabel);
    expect(_field(tester).enabled, isFalse);
    expect(_button(tester).onPressed, isNull);
    c.add(ok);
    await tester.pump();
    expect(_receiptText(tester), ok.stateLabel);
    expect(_button(tester).onPressed, isNull);
    await c.close();
  });

  testWidgets('🔴 제출 자체 실패 = 정적 글자(접수증 아님) · 다시 낼 수 있다', (
    WidgetTester tester,
  ) async {
    final _Api api = _Api(
      () async => throw UnsupportedError('submitSelfReportBalance'),
    );
    await _pump(tester, api);
    await tester.tap(find.byKey(const Key('m5-14-submit')));
    await tester.pumpAndSettle();
    expect(find.text(SafetyLabels.submitNotAccepted), findsOneWidget);
    expect(find.byKey(const Key('m5-14-receipt')), findsNothing);
    expect(_button(tester).onPressed, isNotNull);
    expect(_field(tester).enabled, isTrue);
  });

  testWidgets('🔴 주입 null(기기 id 없음) = 제출 버튼 부재 · 칸은 보인다', (
    WidgetTester tester,
  ) async {
    await _pump(tester, null);
    expect(find.byKey(const Key('m5-14-submit')), findsNothing);
    expect(find.byKey(const Key('m5-14-cash')), findsOneWidget);
  });
}
