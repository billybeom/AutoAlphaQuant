// 🆕 E11q-d1 — M8 문서 창구(D-02 런북 · D-03 긴급 카드 · B-01·B-02 핸드북) 조립 — 실 SQLite(sim 원장).
//
// 🔴 원천 = 엔진 원고 번들 그대로(원장 · 키 0) · 긴급 카드 = 이 폰 빌드 인쇄 자리 없음(슬롯 이름 null) ·
//    핸드북 설정 지문 = 화면이 읽는 원장의 모의 개시 판(전 · 못 읽음 = 빈 글자) · 화면 상태가 바뀌면 다시 낸다 ·
//    S02 유출 런북 링크 = 그 런북 원고 전 → 없음.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:app_operator_android/app/operator_command_api.dart';
import 'package:app_operator_android/app/operator_documents.dart';
import 'package:app_operator_android/app/operator_runtime.dart';
import 'package:app_operator_android/app/operator_settings_repository.dart';
import 'package:app_operator_android/app/operator_view.dart';
import 'package:app_operator_android/engine/ledger_files.dart';
import 'package:core_engine/core_engine.dart'
    show
        HandbookTexts,
        P0sHumanInputs,
        RunbookTexts,
        handbookIndexOf,
        p0sRuleFingerprint,
        runbookIndexVmOf;
import 'package:core_engine/testing.dart' show MemorySecretVault;
import 'package:data_sync/data_sync.dart'
    show
        OpsConfigReady,
        P0sHumanDecision,
        SqliteOnboardingStore,
        currentP0sOpsConfig;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show Database, sqlite3;

import '../engine/support.dart';

const String _dev = '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e';

Map<String, Object?> _row(String file) =>
    ((jsonDecode(
                  File('../../packages/domain_contracts/fixtures/$file')
                      .readAsStringSync(),
                ) as Map<String, Object?>)['rows']!
                as List<Object?>)
            .first!
        as Map<String, Object?>;

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
    clock = FakeClock(kst(2026, 11, 21, 9, 30));
    files = openFiles(tempLedgerDir(), clock);
  });
  tearDown(() => files.close());

  OperatorRuntime rt({P0sHumanDecision? human}) => OperatorRuntime(
    files: files,
    clock: clock,
    vault: MemorySecretVault(),
    deviceId: _dev,
    humanDecision: human,
  );

  Future<void> openSim(OperatorRuntime r) async {
    expect(
      SqliteOnboardingStore(
        files.sim,
        clock: clock,
      ).selectOperatingMode(OperatingMode.autoTrade).ok,
      isTrue,
    );
    final CommandReceipt receipt =
        await OperatorCommandApi(r, random: Random(7)).submitSelfReportBalance(
          SelfReportSubmission(
            purpose: SelfReportPurpose.simOpening,
            input: const SelfReportInput(cashKrwText: '10,000,000'),
            declaredComplete: true,
          ),
        );
    expect(receipt.state, CommandState.executed, reason: receipt.stateLabel);
  }

  P0sHumanDecision human() => P0sHumanDecision(
    inputs: P0sHumanInputs(
      aSymbol: '229200',
      accountByStrategy: const <String, String>{
        'P0S_A': 'isa',
        'P0S_B': 'pension',
        'P0S_C': 'general',
        'P0S_POT': 'isa',
      },
    ),
    accountLabels: const <String, String>{
      'isa': 'ISA',
      'pension': '연금저축',
      'general': '일반 위탁',
    },
    decisionRef: 'R153',
  );

  group('D-02 · D-03', () {
    test(
      '🔴 목록 · 상세 = 엔진 원고 번들(표본 글자) · 원고 없는 런북 = 준비 중 · 모르는 id = 값',
      () async {
        const OperatorRunbookRepository repo = OperatorRunbookRepository();
        expect(await repo.watchRunbookIndex().first, runbookIndexVmOf());
        expect(
          await repo.watchRunbookIndex().first,
          RunbookIndexVm.fromJson(_row('m8/runbook_index.json')),
        );
        expect(
          await repo.watchRunbook('host-lost').first,
          RunbookVm.fromJson(_row('m8/runbook_host_lost.json')),
        );
        expect(
          (await repo.watchRunbook('broker-outage').first).missingLabel,
          RunbookTexts.preparingLabel,
        );
        expect(
          await repo.watchRunbook('nope').first,
          RunbookVm.fromJson(_row('m8/runbook_missing.json')),
        );
      },
    );

    test('🔴 긴급 카드 = 이 폰 빌드 인쇄 자리 없음 → 표본 `emergency_card_no_print`(버튼 부재) · 인쇄 빌드 = 슬롯 이름', () async {
      expect(kOperatorEmergencyCardPrintable, isFalse);
      expect(
        await const OperatorRunbookRepository().watchEmergencyCard().first,
        EmergencyCardVm.fromJson(_row('m8/emergency_card_no_print.json')),
      );
      expect(
        await const OperatorRunbookRepository(printable: true)
            .watchEmergencyCard()
            .first,
        EmergencyCardVm.fromJson(_row('m8/emergency_card.json')),
      );
    });
  });

  group('B-01 · B-02', () {
    test(
      '🔴 온보딩 전(화면 상태 없음) = sim 파일 · 개시 판 없음 → 지문 빈 글자 · 뒤처짐 0 · 원고 번들 목차',
      () async {
        final OperatorHandbookRepository repo = OperatorHandbookRepository(
          rt(),
        );
        final HandbookIndex idx = await repo.watchIndex().first;
        expect(
          idx,
          handbookIndexOf(
            configHash: '',
            ruleFingerprint: p0sRuleFingerprint(),
          ),
        );
        expect(idx.outdatedNotice, isNull);
        expect(idx.entries, hasLength(8));
      },
    );

    test('🔴 모의 개시 뒤 = 설정 지문 = 개시 판 · 화면 상태가 바뀌면 다시 낸다(바뀐 값만)', () async {
      final OperatorRuntime r = rt(human: human());
      final OperatorHandbookRepository repo = OperatorHandbookRepository(r);
      final List<HandbookIndex> got = <HandbookIndex>[];
      final sub = repo.watchIndex().listen(got.add);
      await pumpEventQueue();
      expect(got.single.configHash, '');
      await openSim(r);
      final String hash =
          (currentP0sOpsConfig(files.sim) as OpsConfigReady).configHash;
      r.view.value = _viewOf(files.sim);
      await pumpEventQueue();
      expect(got, hasLength(2));
      expect(got.last.configHash, hash);
      expect(hash, isNot(''));
      // 같은 값이면 다시 내지 않는다.
      r.view.value = _viewOf(files.sim);
      await pumpEventQueue();
      expect(got, hasLength(2));
      await sub.cancel();
    });

    test('🔴 원장을 못 읽어도 핸드북은 연다(지문 칸만 빈 글자)', () async {
      final Database broken = sqlite3.openInMemory();
      addTearDown(broken.close);
      final OperatorRuntime r = rt();
      r.view.value = _viewOf(broken);
      final OperatorHandbookRepository repo = OperatorHandbookRepository(r);
      expect((await repo.watchIndex().first).configHash, '');
      expect((await repo.watchPage('sleeve-b').first).blocks, isNotEmpty);
    });

    test(
      '🔴 쪽 = 별칭 풀이 · live 값 원천 0 → 블록째 뺌(asOf null) · 없는 쪽 = 표본 문장',
      () async {
        final OperatorHandbookRepository repo = OperatorHandbookRepository(
          rt(),
        );
        final HandbookPage b = await repo.watchPage('sleeves/sleeve-b').first;
        final HandbookPage fx = HandbookPage.fromJson(
          _row('m8/handbook_page_sleeve_b.json'),
        );
        expect(b.anchor, 'sleeve-b');
        expect(b.asOf, isNull);
        expect(b.blocks, <HandbookBlock>[
          for (final HandbookBlock x in fx.blocks)
            if (x.live == null) x,
        ]);
        final HandbookPage missing = await repo
            .watchPage('rebalance/monthly')
            .first;
        expect(missing.missingLabel, HandbookTexts.missingLabel);
        expect(missing.configHash, '');
      },
    );
  });

  test('🔴 S02 유출 런북 링크 = 그 런북 원고 전 → 없음(본문이 있어도)', () async {
    final CredentialListVm vm = await OperatorSettingsRepository(
      rt(),
      hasBody: (_) => true,
    ).credentials();
    expect(vm.leakRunbookLink, isNull);
  });
}
