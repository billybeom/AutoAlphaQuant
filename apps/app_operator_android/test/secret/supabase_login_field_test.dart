// E11k-d2 — o_07 ③ Supabase 로그인 칸(설계 13 §8 R216 · 계약 v1.31 01 §40 · 05 §4 6원칙). 값 = 이어 붙인 연습 값만.
//
// 🔵 잡는 것: ① 붙여넣기 → 이메일 가림 · 🔴 비밀번호 = «붙여 넣음»만(글자 수 0) · 넘김 = 지금 값 ② 이메일 꼴 아님 = 쥐지 않음 + 엔진 글자
//    ③ 비밀번호 = 그대로(끝 줄바꿈만 뗌 · 앞뒤 빈칸 그대로) ④ 클립보드 비었음 ⑤ 비움 · 내려가면 떨어짐 · 캡처 막기 ⑥ 60초 정리
//    ⑦ 🔴 화면 어디에도 이메일 전체 · 비밀번호 0 ⑧ 슬롯 빌더 = 이 칸.

import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_shell.dart'
    show operatorSlotBuilder;
import 'package:app_operator_android/app/secure_screen.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:app_operator_android/secret/secret_handoff.dart';
import 'package:app_operator_android/secret/supabase_login_field.dart';
import 'package:domain_contracts/domain_contracts.dart' show OnboardingSlotIds;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../engine/support.dart';

const String _email = 'owner@example.com';
final String _password = ' pw-${'Z' * 16} ';

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
                SupabaseLoginPanel(
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
    SupabaseLoginField f,
    String? value,
  ) async {
    board = value;
    await tester.tap(find.byKey(Key('m4-supabase-login-${f.name}-paste')));
    await tester.pump();
  }

  /// 붙여넣은 뒤 60초 정리 타이머를 흘려보낸다.
  Future<void> drain(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 61));

  String shown(WidgetTester tester, SupabaseLoginField f) => tester
      .widget<Text>(find.byKey(Key('m4-supabase-login-${f.name}-shown')))
      .data!;

  String? note(WidgetTester tester, SupabaseLoginField f) {
    final Finder n = find.byKey(Key('m4-supabase-login-${f.name}-note'));
    return n.evaluate().isEmpty ? null : tester.widget<Text>(n).data;
  }

  String allText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((Text t) => t.data ?? '')
      .join('\n');

  testWidgets('🔴 붙여넣기 → 이메일 가림 · 비밀번호 «붙여 넣음»만 · 넘김 = 지금 값 · 전체 값은 화면 0', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    expect(shown(tester, SupabaseLoginField.email), SupabaseLoginLabels.empty);
    expect(handoff.supabaseLoginDraft(), (email: null, password: null));
    await paste(tester, SupabaseLoginField.email, '  $_email ');
    await paste(tester, SupabaseLoginField.password, '$_password\r\n');
    expect(shown(tester, SupabaseLoginField.email), 'o***@example.com');
    expect(
      shown(tester, SupabaseLoginField.password),
      SupabaseLoginLabels.passwordSet,
    );
    // 비밀번호 = 붙여 넣은 그대로(끝 줄바꿈만 뗌 · 앞뒤 빈칸 그대로).
    expect(handoff.supabaseLoginDraft(), (email: _email, password: _password));
    final String all = allText(tester);
    expect(all, contains(SupabaseLoginLabels.guide));
    expect(all, isNot(contains(_email)));
    expect(all, isNot(contains(_password.trim())));
    await drain(tester);
  });

  testWidgets('🔴 이메일 꼴 아님 = 쥐지 않음 · 엔진 글자 · 앞 값 그대로', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    await paste(tester, SupabaseLoginField.email, _email);
    await paste(tester, SupabaseLoginField.email, 'owner at example');
    expect(note(tester, SupabaseLoginField.email), '이메일과 비밀번호를 모두 붙여 넣으십시오.');
    expect(handoff.supabaseLoginDraft()!.email, _email);
    await paste(tester, SupabaseLoginField.email, 'second@example.com');
    expect(note(tester, SupabaseLoginField.email), isNull);
    expect(handoff.supabaseLoginDraft()!.email, 'second@example.com');
    await drain(tester);
  });

  testWidgets('클립보드 비었음 · 줄바꿈뿐인 비밀번호 = 알림 · 값 0', (WidgetTester tester) async {
    await pump(tester);
    await paste(tester, SupabaseLoginField.email, null);
    expect(
      note(tester, SupabaseLoginField.email),
      SupabaseLoginLabels.clipboardEmpty,
    );
    await paste(tester, SupabaseLoginField.password, '\n');
    expect(
      note(tester, SupabaseLoginField.password),
      SupabaseLoginLabels.clipboardEmpty,
    );
    expect(handoff.supabaseLoginDraft(), (email: null, password: null));
    await drain(tester);
  });

  testWidgets('🔴 비움 · 내려가면 넘김에서 떨어진다 · 캡처 막기 켬/끔', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    expect(secureCalls, <bool>[true]);
    await paste(tester, SupabaseLoginField.email, _email);
    await paste(tester, SupabaseLoginField.password, _password);
    handoff.clearSupabaseLogin();
    await tester.pump();
    expect(handoff.supabaseLoginDraft(), (email: null, password: null));
    expect(
      shown(tester, SupabaseLoginField.password),
      SupabaseLoginLabels.empty,
    );
    await pump(tester, other: const SizedBox.shrink());
    expect(handoff.supabaseLoginDraft(), isNull);
    expect(secureCalls, <bool>[true, false]);
    await drain(tester);
  });

  testWidgets('🔴 붙여넣은 값 = 60초 뒤 클립보드 비움', (WidgetTester tester) async {
    await pump(tester);
    await paste(tester, SupabaseLoginField.password, _password);
    await drain(tester);
    await tester.pump();
    expect(writes, <String>['']);
  });

  test('maskEmail — 앞 1자 + *** + @도메인 · 꼴 아님 = ***', () {
    expect(maskEmail('owner@example.com'), 'o***@example.com');
    expect(maskEmail('@example.com'), '***');
    expect(maskEmail('owner'), '***');
  });

  testWidgets('슬롯 빌더 — SECRET_SUPABASE_LOGIN = 이 칸(실행 묶음의 넘김)', (
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
    final Widget w = operatorSlotBuilder(rt)(OnboardingSlotIds.supabaseLogin);
    expect(w, isA<SupabaseLoginPanel>());
    expect(identical((w as SupabaseLoginPanel).handoff, rt.secrets), isTrue);
    expect(identical(w.secure, rt.secure), isTrue);
  });
}
