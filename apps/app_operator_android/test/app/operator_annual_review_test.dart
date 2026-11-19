// E11p4l — M9 S12 12월 연간 리뷰 목차 조립(설계 13 §8 R168 · 01 §33 K118 · K131 · 미결 202) — 실 SQLite(sim 원장).
//
// 🔴 창 = 신뢰 시각(실행 묶음 `trusted`) · 목차 = 조립 앱 레지스트리에 본문이 있는 화면만 · 운영 시작 해 = 온보딩 확정 시각 ·
//    S01 연간 카드 = OPEN · S12 등록 때만.

import 'package:app_operator_android/app/operator_ops_status.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_settings_repository.dart';
import 'package:app_operator_android/app/operator_shell.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show AnnualReviewTexts, TrustedClock, kAnnualReviewEntries;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database;
import 'package:ui_settings/ui_settings.dart' show AnnualReviewEntry;
import 'package:ui_shell/ui_shell.dart' show ShellRouteBodies;

import '../engine/support.dart';

class _Trusted implements TrustedClock {
  const _Trusted(this.at);
  final DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

bool _all(String _) => true;

OperatorView _viewOf(Database db) => OperatorView(
  db: db,
  flags: const FeatureFlags(
    satelliteEnabled: false,
    webViewerEnabled: false,
    calendarEnabled: false,
    runMode: RunMode.simInternal,
    operatingMode: OperatingMode.autoTrade,
    configHash: 'cfg_test',
  ),
);

void main() {
  tearDownAll(deleteTempDirs);

  late FakeClock clock;
  late LedgerFiles files;

  setUp(() {
    clock = FakeClock(kst(2026, 11, 19, 9, 30));
    files = openFiles(tempLedgerDir(), clock);
  });
  tearDown(() => files.close());

  OperatorRuntime rt({DateTime? trusted}) => OperatorRuntime(
    files: files,
    clock: clock,
    trusted: _Trusted(trusted),
    vault: MemorySecretVault(),
  );

  void commitOnboarding(DateTime at) => files.sim.execute(
    'INSERT INTO onboarding_choice (id, operating_mode, chosen_at, committed_at) VALUES (1, ?, ?, ?)',
    <Object?>[
      OperatingMode.autoTrade.wire,
      at.toIso8601String(),
      at.toIso8601String(),
    ],
  );

  Future<AnnualReviewIndexVm> index(
    OperatorRuntime r, {
    bool Function(String) hasBody = _all,
  }) => OperatorOpsStatusRepository(
    r,
    hasBody: hasBody,
  ).watchAnnualReview().first;

  test('🔴 신뢰 시각 모름(E11k 전) = «확인하지 못했습니다» · 서약 링크 0', () async {
    commitOnboarding(DateTime.utc(2025, 3, 1));
    final AnnualReviewIndexVm vm = await index(rt());
    expect(vm.windowStateLabel, AnnualReviewTexts.unknown);
    expect(vm.yearLabel, '2025년 연간 리뷰');
    expect(vm.entries, kAnnualReviewEntries);
    expect(vm.pledgeLink, isNull);
    expect(vm.asOf.label, '연간 점검 기준 2026-11-19');
  });

  test('🔴 신뢰 시각 12월 = OPEN · 목차 4 · 서약 링크 · 11월 = 지난해 CLOSED', () async {
    commitOnboarding(DateTime.utc(2025, 3, 1));
    final AnnualReviewIndexVm open = await index(
      rt(trusted: DateTime.utc(2026, 12, 2)),
    );
    expect(open.windowStateLabel, AnnualReviewTexts.open);
    expect(open.yearLabel, '2026년 연간 리뷰');
    expect(open.entries, hasLength(4));
    expect(open.pledgeLink?.deepLink, AppRoutes.m5Pledge);
    final AnnualReviewIndexVm closed = await index(
      rt(trusted: DateTime.utc(2026, 11, 19)),
    );
    expect(closed.windowStateLabel, AnnualReviewTexts.closed);
    expect(closed.yearLabel, '2025년 연간 리뷰');
    expect(closed.pledgeLink, isNull);
  });

  test('운영 시작 해 = 온보딩 확정 시각(한국) · 올해 시작 = 첫 해 · 확정 전 = 첫 해', () async {
    final AnnualReviewIndexVm none = await index(
      rt(trusted: DateTime.utc(2026, 11, 19)),
    );
    expect(none.windowStateLabel, AnnualReviewTexts.firstYear);
    commitOnboarding(DateTime.utc(2026, 1, 5));
    final AnnualReviewIndexVm first = await index(
      rt(trusted: DateTime.utc(2026, 11, 19)),
    );
    expect(first.windowStateLabel, AnnualReviewTexts.firstYear);
    expect(first.yearLabel, '2026년 연간 리뷰');
    expect(first.entries, hasLength(2));
  });

  test('🔴 지금 레지스트리 = 🆕 R173 M7 리밸런싱 회차만 등록 → 목차 행 1 · 서약 화면 미등록 → 서약 링크 0(12월이어도) · S12 는 등록', () async {
    const ShellRouteBodies bodies = kOperatorRouteBodies;
    expect(
      bodies.byPattern.containsKey(AppRoutes.settingsAnnualReview),
      isTrue,
    );
    expect(
      bodies.byPattern[AppRoutes.settingsAnnualReview]!(
        const <String, String>{},
      ),
      isA<AnnualReviewEntry>(),
    );
    commitOnboarding(DateTime.utc(2025, 3, 1));
    final AnnualReviewIndexVm vm = await index(
      rt(trusted: DateTime.utc(2026, 12, 2)),
      hasBody: bodies.byPattern.containsKey,
    );
    expect(vm.windowStateLabel, AnnualReviewTexts.open);
    expect(vm.entries.map((LinkAction e) => e.deepLink), <String>[
      AppRoutes.rebalanceHistory,
    ], reason: '등록된 화면만(S01 원칙) — R173 회차 목록이 서서 그 행이 열린다');
    expect(vm.pledgeLink, isNull);
  });

  test('🔴 S01 연간 카드 = 신뢰 시각 12월 · S12 등록 때만 · 모름 = 부재', () async {
    final OperatorRuntime dec = rt(trusted: DateTime.utc(2026, 12, 2))
      ..view.value = _viewOf(files.sim);
    final SettingsHomeVm open = await OperatorSettingsRepository(
      dec,
      hasBody: _all,
    ).home();
    expect(open.annualReviewLink?.deepLink, AppRoutes.settingsAnnualReview);
    expect(open.annualReviewLink?.label, AnnualReviewTexts.homeCard);
    final OperatorRuntime unknown = rt()..view.value = _viewOf(files.sim);
    expect(
      (await OperatorSettingsRepository(
        unknown,
        hasBody: _all,
      ).home()).annualReviewLink,
      isNull,
    );
    expect(
      (await OperatorSettingsRepository(
        dec,
        hasBody: (String r) => r != AppRoutes.settingsAnnualReview,
      ).home()).annualReviewLink,
      isNull,
    );
  });
}
