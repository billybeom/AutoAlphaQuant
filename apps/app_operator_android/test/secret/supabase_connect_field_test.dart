// E11k-c — o_07 ② Supabase 연결 칸(설계 13 §8 R206 · 계약 v1.29 01 §39 · 05 §4 6원칙). 값 = 이어 붙인 연습 값만.
//
// 🔵 잡는 것: ① 붙여넣기 → 엔진 마스킹 표시(주소 = ref 만 가림 · 키 «앞4…뒤4») · 전체 값은 화면 0 ② 넘김 = 지금 값
//    ③ 🔴 꼴 틀림 · 비밀 키 · service_role = 쥐지 않는다 + 엔진 글자 알림(앞에 쥔 값은 그대로) ④ 클립보드 비었음 알림
//    ⑤ 저장 뒤 비움 · 내려가면 넘김에서 떨어진다 ⑥ 서 있는 동안 캡처 막기 ⑦ 붙여넣은 값 = 60초 정리 대상 ⑧ 슬롯 빌더 = 이 칸.

import 'dart:convert';

import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart'
    show operatorSlotBuilder;
import 'package:app_operator_android/app/secure_screen.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/secret/secret_handoff.dart';
import 'package:app_operator_android/secret/supabase_connect_field.dart';
import 'package:data_sync/data_sync.dart'
    show SupabaseConnectText, SupabaseInputProblem;
import 'package:domain_contracts/domain_contracts.dart' show OnboardingSlotIds;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../engine/support.dart';

final String _ref = 'q' * 12 + '7' * 8;
final String _url = 'https://$_ref.supabase.co';
final String _pub = 'sb_${'publishable'}_${'K' * 12}${'4' * 10}';
final String _secret = 'sb_${'secret'}_${'K' * 12}${'4' * 10}';

String _jwt(String role) {
  String seg(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${seg(<String, String>{'alg': 'HS256'})}.'
      '${seg(<String, String>{'role': role})}.${'s' * 20}';
}

void main() {
  tearDownAll(deleteTempDirs);

  late String? board;
  late List<String> writes;
  late List<bool> secureCalls;
  late SecretHandoff handoff;
  late ClipboardJanitor janitor;

  setUp(() {
    board = null;
    writes = <String>[];
    secureCalls = <bool>[];
    handoff = SecretHandoff();
    janitor = ClipboardJanitor(
      after: const Duration(seconds: 60),
      read: () async => board,
      write: (String t) async {
        writes.add(t);
        board = t;
      },
    );
  });

  Future<void> pump(WidgetTester tester, {Widget? other}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child:
                other ??
                SupabaseConnectField(
                  handoff: handoff,
                  janitor: janitor,
                  secure: SecureScreen((bool on) async => secureCalls.add(on)),
                  readClipboard: () async => board,
                ),
          ),
        ),
      ),
    );
  }

  Future<void> paste(
    WidgetTester tester,
    SupabasePasteField f,
    String? value,
  ) async {
    board = value;
    await tester.tap(find.byKey(Key('m4-supabase-${f.name}-paste')));
    await tester.pump();
  }

  String shown(WidgetTester tester, SupabasePasteField f) =>
      tester.widget<Text>(find.byKey(Key('m4-supabase-${f.name}-shown'))).data!;

  String? note(WidgetTester tester, SupabasePasteField f) {
    final Finder n = find.byKey(Key('m4-supabase-${f.name}-note'));
    return n.evaluate().isEmpty ? null : tester.widget<Text>(n).data;
  }

  /// 붙여넣은 뒤 60초 정리 타이머를 흘려보낸다(시험 끝에 타이머가 남지 않게).
  Future<void> drain(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 61));

  String allText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((Text t) => t.data ?? '')
      .join('\n');

  testWidgets('🔴 붙여넣기 → 마스킹 표시 · 넘김 = 지금 값 · 전체 값은 화면 0', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    expect(shown(tester, SupabasePasteField.url), SupabaseFieldLabels.empty);
    expect(handoff.supabaseDraft(), (url: null, key: null));
    await paste(tester, SupabasePasteField.url, '  $_url/ ');
    await paste(tester, SupabasePasteField.key, ' $_pub ');
    expect(
      shown(tester, SupabasePasteField.url),
      'https://qqqq…7777.supabase.co',
    );
    expect(shown(tester, SupabasePasteField.key), 'sb_p…4444');
    expect(handoff.supabaseDraft(), (url: _url, key: _pub));
    final String all = allText(tester);
    expect(all, contains(SupabaseFieldLabels.guide));
    expect(all, isNot(contains(_ref)));
    expect(all, isNot(contains(_pub)));
    await drain(tester);
  });

  testWidgets('🔴 비밀 키 · service_role · 꼴 틀림 = 쥐지 않는다 · 엔진 글자 알림 · 앞 값 그대로', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    await paste(tester, SupabasePasteField.key, _pub);
    await paste(tester, SupabasePasteField.key, _secret);
    expect(
      note(tester, SupabasePasteField.key),
      SupabaseConnectText.input(SupabaseInputProblem.secretKey),
    );
    expect(handoff.supabaseDraft()!.key, _pub);
    await paste(tester, SupabasePasteField.key, _jwt('service_role'));
    expect(
      note(tester, SupabasePasteField.key),
      SupabaseConnectText.input(SupabaseInputProblem.serviceRoleKey),
    );
    expect(handoff.supabaseDraft()!.key, _pub);
    await paste(tester, SupabasePasteField.url, 'https://$_ref.example.com');
    expect(
      note(tester, SupabasePasteField.url),
      SupabaseConnectText.input(SupabaseInputProblem.notProjectUrl),
    );
    expect(handoff.supabaseDraft()!.url, isNull);
    expect(allText(tester), isNot(contains(_secret)));
    // 맞는 값을 다시 붙이면 알림이 사라진다.
    await paste(tester, SupabasePasteField.url, _url);
    expect(note(tester, SupabasePasteField.url), isNull);
    expect(handoff.supabaseDraft()!.url, _url);
    await drain(tester);
  });

  testWidgets('옛 anon JWT = 받는다(키 칸)', (WidgetTester tester) async {
    await pump(tester);
    final String anon = _jwt('anon');
    await paste(tester, SupabasePasteField.key, anon);
    expect(note(tester, SupabasePasteField.key), isNull);
    expect(handoff.supabaseDraft()!.key, anon);
    await drain(tester);
  });

  testWidgets('클립보드 비었음 = 알림 · 값 0', (WidgetTester tester) async {
    await pump(tester);
    await paste(tester, SupabasePasteField.url, null);
    expect(
      note(tester, SupabasePasteField.url),
      SupabaseFieldLabels.clipboardEmpty,
    );
    expect(handoff.supabaseDraft(), (url: null, key: null));
  });

  testWidgets('🔴 저장 뒤 비움 · 내려가면 넘김에서 떨어진다 · 캡처 막기 켬/끔', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    expect(secureCalls, <bool>[true]);
    await paste(tester, SupabasePasteField.url, _url);
    await paste(tester, SupabasePasteField.key, _pub);
    handoff.clearSupabaseAfterSave();
    await tester.pump();
    expect(handoff.supabaseDraft(), (url: null, key: null));
    expect(shown(tester, SupabasePasteField.key), SupabaseFieldLabels.empty);
    await pump(tester, other: const SizedBox.shrink());
    expect(handoff.supabaseDraft(), isNull);
    expect(secureCalls, <bool>[true, false]);
    await drain(tester);
  });

  testWidgets('🔴 붙여넣은 값 = 60초 뒤 클립보드 비움', (WidgetTester tester) async {
    await pump(tester);
    await paste(tester, SupabasePasteField.key, _pub);
    await tester.pump(const Duration(seconds: 61));
    await tester.pump();
    expect(writes, <String>['']);
  });

  testWidgets('슬롯 빌더 — SECRET_SUPABASE_CONNECT = 이 칸(실행 묶음의 넘김)', (
    WidgetTester tester,
  ) async {
    final LedgerFiles f = openFiles(
      tempLedgerDir(),
      FakeClock(DateTime.utc(2026, 12, 8)),
    );
    addTearDown(f.close);
    final OperatorRuntime rt = OperatorRuntime(
      files: f,
      clock: FakeClock(DateTime.utc(2026, 12, 8)),
    );
    final Widget w = operatorSlotBuilder(rt)(OnboardingSlotIds.supabaseConnect);
    expect(w, isA<SupabaseConnectField>());
    expect(identical((w as SupabaseConnectField).handoff, rt.secrets), isTrue);
    expect(identical(w.janitor, rt.clipboard), isTrue);
  });
}
