// C-15 픽스처 ↔ DDL 정합 — 01 §7 표 C-15 · §6 · 인벤토리 §9(🟢).
//
// 정의: 「픽스처의 열거값·필드가 §6 DDL 의 `CHECK`·컬럼과 일치하는지」.
// 잡는 것: **계약과 스키마가 갈라짐**.
// 🔴 인벤토리 §9 — 이 검사의 요점은 `SAT`·`REQUIRED`·`RECORD_MANUAL_FILL` 같은
//    **비기계적 매핑**을 잡는 것이다(이름이 기계적으로 유도되지 않는 자리).
//
// ✅ 인벤토리 §10-2 열린 물음 1·2(명령 상태 · `mode` 축)는 계약 v1.9.0 에서 닫혔다(설계 13 §8 R19 E9-2·
//    E9-6 · R20 Q1). 그 «현재 상태 고정» 검사 2개를 **결정된 모양의 등식 검사**로 바꿨다:
//    명령 state 2표 = `CommandState` − `REQUESTED` · `mode` = 두 파일(`LedgerFile`)마다 다른 CHECK
//    (`-- @sim` 태그 → `ledgerDdlFor`).

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

const List<String> _batchFiles = <String>[
  'batch_a_decision_mode.sql',
  'batch_b_plan_command.sql',
  'batch_c_x2_x5_local.sql',
  'batch_d_supabase.sql',
  'batch_e_enum_widen.sql',
  'batch_f_x7_advisory.sql',
  'batch_g_market_data.sql',
];

/// 계약 열거형 ↔ DDL CHECK 가 **정확히 같아야** 하는 축.
final List<_Axis> _axes = <_Axis>[
  _Axis(
    'batch_a_decision_mode.sql',
    'decision_log',
    'sleeve',
    _wires(SleeveId.values),
  ),
  _Axis(
    'batch_a_decision_mode.sql',
    'decision_log',
    'exit_kind',
    ExitKindCodes.values,
  ),
  _Axis(
    'batch_a_decision_mode.sql',
    'rebalance_event',
    'kind',
    _wires(RebalanceKind.values),
  ),
  _Axis(
    'batch_c_x2_x5_local.sql',
    'planned_work',
    'state',
    _wires(PlannedWorkState.values),
  ),
  _Axis(
    'batch_c_x2_x5_local.sql',
    'resume_run',
    'mode',
    _wires(ResumeMode.values),
  ),
  _Axis(
    'batch_c_x2_x5_local.sql',
    'onboarding_progress',
    'track',
    _wires(OnboardingTrack.values),
  ),
  _Axis(
    'batch_c_x2_x5_local.sql',
    'onboarding_progress',
    'state',
    _wires(StepState.values),
  ),
  _Axis(
    'batch_c_x2_x5_local.sql',
    'onboarding_choice',
    'operating_mode',
    _wires(OperatingMode.values),
  ),
  _Axis(
    'batch_c_x2_x5_local.sql',
    'calendar_event_log',
    'origin',
    _wires(CalendarOrigin.values),
  ),
  _Axis(
    'batch_c_x2_x5_local.sql',
    'ledger_diff',
    'axis',
    _wires(LedgerAxis.values),
  ),
  _Axis(
    'batch_c_x2_x5_local.sql',
    'ledger_diff',
    'severity',
    _wires(DiffSeverity.values),
  ),
  _Axis(
    'batch_c_x2_x5_local.sql',
    'ledger_diff',
    'status',
    _wires(DiffStatus.values),
  ),
  _Axis(
    'batch_d_supabase.sql',
    'command_queue',
    'kind',
    _wires(CommandKind.values),
  ),
  // 🆕 v1.41(01 §50 · K369 · H-6) — 명령 봉투 맥락 2칸 not null + check(소비 규칙 «runMode 불일치 = 거부»의 입력).
  _Axis(
    'batch_d_supabase.sql',
    'command_queue',
    'run_mode',
    _wires(RunMode.values),
  ),
  _Axis(
    'batch_d_supabase.sql',
    'command_queue',
    'operating_mode',
    _wires(OperatingMode.values),
  ),
  // 🆕 v1.22(01 §31 · K62) — 재개 미러의 재개 모드(`mode` = RunMode 와 다른 축).
  _Axis(
    'batch_d_supabase.sql',
    'resume_run_mirror',
    'resume_mode',
    _wires(ResumeMode.values),
  ),
  // 🆕 v1.9 — 인벤토리 §10-2 ① 해소: 두 표 = `CommandState` − `REQUESTED`(G-30).
  _Axis(
    'batch_b_plan_command.sql',
    'command_inbox',
    'state',
    _wires(CommandState.values).difference(<String>{'REQUESTED'}),
  ),
  _Axis(
    'batch_d_supabase.sql',
    'command_ack',
    'state',
    _wires(CommandState.values).difference(<String>{'REQUESTED'}),
  ),
  _Axis('batch_f_x7_advisory.sql', 'advice', 'kind', _wires(AdviceKind.values)),
  _Axis('batch_f_x7_advisory.sql', 'advice', 'sleeve', _wires(SleeveId.values)),
  _Axis(
    'batch_f_x7_advisory.sql',
    'advice',
    'status',
    _wires(AdviceStatus.values),
  ),
  _Axis(
    'batch_f_x7_advisory.sql',
    'advice_transition',
    'cause_code',
    AdviceTransitionCauseCodes.values,
  ),
  // 🔵 v1.22(01 §31 · K61) — `executions.fill_origin` 은 `@sim fill-origin` 축이라 아래 «두 판 합집합» 시험이 본다
  //    (태그 전 = 두 판 4값 · 태그 뒤 = LIVE 3 ∪ SIM 4 — 엔진 재생성 PR 이 계약 시험을 고치지 않게).
  _Axis(
    'batch_f_x7_advisory.sql',
    'executions',
    'fill_kind',
    _wires(FillKind.values),
  ),
  _Axis(
    'batch_f_x7_advisory.sql',
    'executions',
    'cost_source',
    _wires(CostSource.values),
  ),
  _Axis(
    'batch_f_x7_advisory.sql',
    'order_intents',
    'operating_mode',
    _wires(OperatingMode.values),
  ),
  _Axis(
    'batch_f_x7_advisory.sql',
    'credential_registry',
    'usage',
    _wires(CredentialUse.values),
  ),
  _Axis(
    'batch_f_x7_advisory.sql',
    'handover_session',
    'path',
    _wires(HandoverPath.values),
  ),
  _Axis(
    'batch_f_x7_advisory.sql',
    'ledger_diff__new',
    'pair',
    _wires(LedgerPair.values),
  ),
  // 🆕 v1.10 ㊲ — 원장 사건 · 현금 흐름 5값(설계 13 §8 R21).
  _Axis(
    'batch_f_x7_advisory.sql',
    'ledger_event',
    'kind',
    _wires(LedgerEventKind.values),
  ),
  _Axis(
    'batch_f_x7_advisory.sql',
    'ledger_event',
    'action_type',
    _wires(CorporateActionType.values),
  ),
  _Axis(
    'batch_f_x7_advisory.sql',
    'cash_flow__new',
    'kind',
    _wires(CashFlowKind.values),
  ),
  // 🆕 v1.42(01 §51 · 미결 256) — 실사 한 건의 현금 축 판정.
  _Axis(
    'batch_f_x7_advisory.sql',
    'self_report_balance',
    'cash_check',
    _wires(SelfReportCashCheck.values),
  ),
  // 🆕 v1.14(E8a · R25 G3) — 시세·지표 원천.
  _Axis(
    'batch_g_market_data.sql',
    'market_series',
    'source',
    _wires(MarketDataSource.values),
  ),
  _Axis(
    'batch_g_market_data.sql',
    'fetch_log',
    'source',
    _wires(MarketDataSource.values),
  ),
  _Axis(
    'batch_g_market_data.sql',
    'daily_prices',
    'source',
    _wires(MarketDataSource.values),
  ),
];

/// 픽스처의 열거값이 **DDL CHECK 안에** 있어야 하는 자리.
final List<_FixtureAxis> _fixtureAxes = <_FixtureAxis>[
  _FixtureAxis(
    fixture: FixturePaths.rebalance6,
    key: 'kind',
    file: 'batch_a_decision_mode.sql',
    table: 'rebalance_event',
    column: 'kind',
  ),
  _FixtureAxis(
    fixture: FixturePaths.holdings6,
    key: 'sleeve',
    file: 'batch_a_decision_mode.sql',
    table: 'decision_log',
    column: 'sleeve',
  ),
  _FixtureAxis(
    fixture: FixturePaths.journal30,
    key: 'fill_origin',
    file: 'batch_f_x7_advisory.sql',
    table: 'executions',
    column: 'fill_origin',
  ),
  _FixtureAxis(
    fixture: FixturePaths.journal30,
    key: 'fill_kind',
    file: 'batch_f_x7_advisory.sql',
    table: 'executions',
    column: 'fill_kind',
  ),
  _FixtureAxis(
    fixture: FixturePaths.journal30,
    key: 'cost_source',
    file: 'batch_f_x7_advisory.sql',
    table: 'executions',
    column: 'cost_source',
  ),
  _FixtureAxis(
    fixture: FixturePaths.m6ManualFills8,
    key: 'fill_kind',
    file: 'batch_f_x7_advisory.sql',
    table: 'executions',
    column: 'fill_kind',
  ),
  _FixtureAxis(
    fixture: FixturePaths.m6Advice12,
    key: 'status',
    file: 'batch_f_x7_advisory.sql',
    table: 'advice',
    column: 'status',
  ),
  _FixtureAxis(
    fixture: FixturePaths.m6Advice12,
    key: 'kind',
    file: 'batch_f_x7_advisory.sql',
    table: 'advice',
    column: 'kind',
  ),
  _FixtureAxis(
    fixture: FixturePaths.onboardingFresh,
    key: 'track',
    file: 'batch_c_x2_x5_local.sql',
    table: 'onboarding_progress',
    column: 'track',
  ),
  _FixtureAxis(
    fixture: FixturePaths.onboardingFresh,
    key: 'state',
    file: 'batch_c_x2_x5_local.sql',
    table: 'onboarding_progress',
    column: 'state',
  ),
  _FixtureAxis(
    fixture: FixturePaths.ledgerDiffs4,
    key: 'pair',
    file: 'batch_f_x7_advisory.sql',
    table: 'ledger_diff__new',
    column: 'pair',
  ),
  _FixtureAxis(
    fixture: FixturePaths.ledgerDiffs4,
    key: 'axis',
    file: 'batch_c_x2_x5_local.sql',
    table: 'ledger_diff',
    column: 'axis',
  ),
  _FixtureAxis(
    fixture: FixturePaths.m9HandoverStates,
    key: 'path',
    file: 'batch_f_x7_advisory.sql',
    table: 'handover_session',
    column: 'path',
  ),
];

void main() {
  group('C-15 픽스처 ↔ DDL (01 §7 · §6)', () {
    test('C-15 배치 A~F 와 README 가 있다', () {
      for (final String name in _batchFiles) {
        expect(
          File('${ddlDir.path}/$name').existsSync(),
          isTrue,
          reason: '$name 이 없다 — 마이그레이션 창의 한 배치가 통째로 빠진다(01 §6-0).',
        );
      }
      expect(File('${ddlDir.path}/README.md').existsSync(), isTrue);
    });

    test('C-15 열거형과 DDL CHECK 가 축마다 정확히 같다', () {
      for (final _Axis axis in _axes) {
        expect(
          _checkValues(axis.file, axis.table, axis.column),
          axis.expected,
          reason:
              '${axis.file}:${axis.table}.${axis.column} — 계약 열거형과 CHECK 가 '
              '갈라졌다. 신규 값은 **DDL CHECK → @JsonValue → 픽스처** 순서로 '
              '같은 커밋에서 더한다(01 §1-2).',
        );
      }
    });

    test('C-15 executions.fill_origin — LIVE·SIM 두 판 CHECK 합집합이 FillOrigin 4값이다(태그 전·후 둘 다)', () {
      // 🆕 v1.22(01 §31 · K61) — 태그 줄 = 엔진 재생성 PR. 이 시험은 그 PR 앞뒤로 같은 결과여야 한다.
      expect(
        _checkValuesBothFiles(
          'batch_f_x7_advisory.sql',
          'executions',
          'fill_origin',
        ),
        _wires(FillOrigin.values),
      );
    });

    test('C-15 픽스처의 열거값이 CHECK 안에 있다', () {
      for (final _FixtureAxis axis in _fixtureAxes) {
        final Set<String> allowed =
            _simTaggedColumns.contains('${axis.table}.${axis.column}')
            ? _checkValuesBothFiles(axis.file, axis.table, axis.column)
            : _checkValues(axis.file, axis.table, axis.column);
        expect(
          allowed,
          isNotEmpty,
          reason: '${axis.table}.${axis.column} CHECK 를 못 읽었다.',
        );
        final Set<String> used = <String>{};
        walkJson(jsonDecode(readFixture(axis.fixture)), (
          String path,
          String key,
          Object? value,
        ) {
          if (key == axis.key && value is String) {
            used.add(value);
          }
        });
        expect(
          used,
          isNotEmpty,
          reason: '${axis.fixture} 에 ${axis.key} 값이 없다.',
        );
        expect(
          used.difference(allowed),
          isEmpty,
          reason:
              '${axis.fixture} 의 ${axis.key} 가 '
              '${axis.table}.${axis.column} CHECK 밖이다 — 저장할 수 없는 값을 화면이 받는다.',
        );
      }
    });

    test('C-15 비기계적 매핑 ① SAT — 비활성이어도 양쪽에 보존된다', () {
      // 🔵 v2.31 P0S 는 새틀라이트 0% 라 판정 경로가 집행 대상에 없다. 그래도
      //    값을 지우면 과거 행을 읽지 못한다 — DDL 주석의 「🔵 SAT 보존」이 그 뜻이다.
      expect(SleeveId.values.map((SleeveId s) => s.wire), contains('SAT'));
      expect(
        _checkValues('batch_a_decision_mode.sql', 'decision_log', 'sleeve'),
        contains('SAT'),
      );
      expect(
        _checkValues('batch_f_x7_advisory.sql', 'advice', 'sleeve'),
        contains('SAT'),
      );
    });

    test('C-15 비기계적 매핑 ② RECORD_MANUAL_FILL — Dart 이름과 어순이 뒤집혀 있다', () {
      // 🔴 `manualFillRecord`(DTO) ↔ `RECORD_MANUAL_FILL`(표기) — m2-8_naming B-3.
      //    기계적으로 유도되지 않으므로 @JsonValue 와 CHECK 를 눈으로 맞춰야 한다.
      expect(CommandKind.manualFillRecord.wire, 'RECORD_MANUAL_FILL');
      expect(
        _checkValues('batch_d_supabase.sql', 'command_queue', 'kind'),
        contains('RECORD_MANUAL_FILL'),
      );
      // 뒤집힌 짝 3종이 모두 같은 규칙을 따른다.
      expect(CommandKind.manualFillAmend.wire, 'AMEND_MANUAL_FILL');
      expect(CommandKind.manualFillVoid.wire, 'VOID_MANUAL_FILL');
    });

    test('C-15 비기계적 매핑 ③ REQUIRED — StepRequirement 는 아직 DDL 축이 없다', () {
      // 🔴 픽스처는 `requirement: "REQUIRED"` 를 싣는데 `onboarding_progress` 에는
      //    그 컬럼도 CHECK 도 없다(배치 C). 「저장하지 않는 화면 전용 축」인지
      //    「DDL 누락」인지는 계약이 정할 일이라 여기서는 **현재 상태를 못 박는다**.
      expect(
        StepRequirement.values.map((StepRequirement r) => r.wire).toSet(),
        <String>{'REQUIRED', 'RECOMMENDED', 'OPTIONAL'},
      );
      final Set<String> used = <String>{};
      walkJson(jsonDecode(readFixture(FixturePaths.onboardingFresh)), (
        String path,
        String key,
        Object? value,
      ) {
        if (key == 'requirement' && value is String) {
          used.add(value);
        }
      });
      expect(used, contains('REQUIRED'));
      expect(
        _allChecks().where((CheckConstraint c) => c.column == 'requirement'),
        isEmpty,
        reason:
            'DDL 에 requirement CHECK 가 생겼다 — 축이 확정된 것이므로 이 검사를 '
            '_axes 의 1:1 대조로 옮긴다.',
      );
    });

    test('C-15 명령 state — command_inbox 와 command_ack 가 같은 집합이다(G-30)', () {
      // 인벤토리 §10-2 ① 해소(R19 E9-6 · R20). `command_queue` 에는 state 칸이 없다.
      final Set<String> inbox = _checkValues(
        'batch_b_plan_command.sql',
        'command_inbox',
        'state',
      );
      final Set<String> ack = _checkValues(
        'batch_d_supabase.sql',
        'command_ack',
        'state',
      );
      expect(inbox, ack, reason: '한쪽만 넓히면 보류된 명령이 한쪽 증언에서 사라진다(G-30).');
      expect(_wires(CommandState.values).difference(inbox), <String>{
        'REQUESTED',
      }, reason: 'REQUESTED 는 기기 쪽 내구 큐의 상태라 엔진 표에 오지 않는다 — 그 밖의 차이는 없다.');
      expect(inbox, contains('NO_OPERATOR'));
      expect(
        _checkValues('batch_d_supabase.sql', 'command_queue', 'state'),
        isEmpty,
        reason: 'command_queue 는 append-only 명령 행이다 — state 칸을 두지 않는다.',
      );
    });

    test('C-15 mode 축 — 두 파일의 CHECK 가 LedgerModeCheck 대로 갈린다', () {
      // 인벤토리 §10-2 ② 해소(R19 E9-2 · R20 Q1). 🔴 'SIM' 은 RunMode 값이 아니다.
      final Set<String> runMode = _wires(RunMode.values);
      expect(runMode, <String>{'SIM_INTERNAL', 'SIM_BROKER', 'LIVE'});

      const Map<String, LedgerModeCheck> tables = <String, LedgerModeCheck>{
        'decision_log': LedgerModeCheck.ledger,
        'order_intents': LedgerModeCheck.ledger,
        'trades': LedgerModeCheck.ledger,
        'equity_snapshot': LedgerModeCheck.ledger,
        'rebalance_event': LedgerModeCheck.ledger,
        'advice_batch': LedgerModeCheck.advice,
        'advice': LedgerModeCheck.advice,
        'calendar_link': LedgerModeCheck.calendar,
        'calendar_sync_state': LedgerModeCheck.calendar,
      };
      const Map<LedgerModeCheck, (Set<String>, Set<String>)> want =
          <LedgerModeCheck, (Set<String>, Set<String>)>{
            LedgerModeCheck.ledger: (
              <String>{'LIVE'},
              <String>{'SIM_INTERNAL', 'SIM_BROKER'},
            ),
            LedgerModeCheck.advice: (
              <String>{'LIVE'},
              <String>{'SIM_INTERNAL'},
            ),
            LedgerModeCheck.calendar: (<String>{'LIVE'}, <String>{'SIM'}),
          };
      for (final MapEntry<String, LedgerModeCheck> e in tables.entries) {
        final (Set<String> live, Set<String> sim) = want[e.value]!;
        expect(
          _localModeValues(LedgerFile.live, e.key),
          live,
          reason: '${e.key}.mode — ledger.sqlite 판',
        );
        expect(
          _localModeValues(LedgerFile.sim, e.key),
          sim,
          reason: '${e.key}.mode — ledger_sim.sqlite 판(@sim ${e.value.tag})',
        );
      }
      // 결정 사슬은 두 파일을 합치면 RunMode 3값이다 — 어느 값도 저장할 자리가 빠지지 않는다.
      expect(
        _localModeValues(
          LedgerFile.live,
          'trades',
        ).union(_localModeValues(LedgerFile.sim, 'trades')),
        runMode,
      );

      // 🔴 `mode` 칸은 이 9표(+ 이름만 같은 resume_run)에만 있다 — 나머지는 파일 식별이 덮는다(R20 Q1).
      final Set<String> withMode = <String>{
        for (final CheckConstraint c in _localChecks(LedgerFile.live))
          if (c.column == 'mode') c.table,
      };
      expect(withMode, <String>{...tables.keys, 'resume_run'});

      // Supabase 미러는 한 곳에 두 계열을 담으므로 3값 그대로다.
      expect(
        _checkValues('batch_d_supabase.sql', 'ledger_stamp', 'mode'),
        runMode,
      );

      // 🔴 픽스처의 SIM 행도 저장할 자리가 있다(je_0030 = SIM_INTERNAL → ledger_sim.sqlite).
      final Set<String> rowModes = <String>{};
      walkJson(jsonDecode(readFixture(FixturePaths.journal30)), (
        String path,
        String key,
        Object? value,
      ) {
        if (key == 'mode' && value is String && path.startsWith('rows')) {
          rowModes.add(value);
        }
      });
      expect(rowModes, containsAll(<String>['LIVE', 'SIM_INTERNAL']));
      expect(rowModes.difference(runMode), isEmpty);
    });

    test('C-15 mode 축 — 태그 없는 LIVE 고정 CHECK · DEFAULT \'SIM\' 이 남아 있지 않다', () {
      // 🔴 태그가 빠진 `CHECK (mode = 'LIVE')` 는 SIM 파일에서도 LIVE 만 받아 모의 행을 전부 거부한다.
      for (final String name in _localBatchFiles) {
        final String live = _localDdl(LedgerFile.live, name);
        final String sim = _localDdl(LedgerFile.sim, name);
        for (final CheckConstraint c in parseCheckConstraintsText(live, name)) {
          if (c.column != 'mode' || c.table == 'resume_run') continue;
          final Set<String> simValues = <String>{
            for (final CheckConstraint d in parseCheckConstraintsText(
              sim,
              name,
            ))
              if (d.table == c.table && d.column == 'mode') ...d.values,
          };
          expect(
            simValues,
            isNot(c.values.toSet()),
            reason: '$name:${c.table}.mode — @sim 태그가 없어 두 파일이 같은 값을 받는다.',
          );
        }
        final String code = live
            .split('\n')
            .map((String l) => l.replaceAll(RegExp('--.*'), ''))
            .join('\n');
        expect(
          code,
          isNot(contains("DEFAULT 'SIM'")),
          reason: "$name — 'SIM' 은 어느 파일의 CHECK 도 통과하지 못한다(명시 필수).",
        );
      }
    });

    test('C-15 수기 체결 — fill_origin CHECK 가 «MANUAL ⇔ 브로커 주문 없음» 을 묶는다', () {
      // R20 Q2 — 02 `executions.broker_order_no` 는 v1 에서 NULL 허용(02 개정 = E9b).
      final String f = File('${ddlDir.path}/batch_f_x7_advisory.sql')
          .readAsStringSync();
      expect(
        f,
        contains("AND ((fill_origin = 'MANUAL') = (broker_order_no IS NULL))"),
      );
      // 🆕 v1.22(K61) — SIM 판(태그 뒤에도)이 같은 묶음을 갖는다.
      expect(
        _localDdl(LedgerFile.sim, 'batch_f_x7_advisory.sql'),
        contains("AND ((fill_origin = 'MANUAL') = (broker_order_no IS NULL))"),
      );
    });

    test('C-15 픽스처 봉투의 meta.mode 는 전량 LIVE 다', () {
      for (final String path in FixturePaths.all) {
        expect(
          decodeEnvelope(readFixture(path)).meta.mode,
          'LIVE',
          reason:
              '$path — 봉투 모드가 섞이면 「이 픽스처가 어느 모드의 화면인가」가 '
              '흔들린다(X6 는 행 필드로 표현한다).',
        );
      }
    });
  });
}

/// 열거형의 JSON 표기 집합.
Set<String> _wires(List<Object> values) => <String>{
  for (final Object v in values) _wireOf(v),
};

String _wireOf(Object v) => switch (v) {
  final SleeveId s => s.wire,
  final RebalanceKind k => k.wire,
  final PlannedWorkState s => s.wire,
  final ResumeMode m => m.wire,
  final OnboardingTrack t => t.wire,
  final StepState s => s.wire,
  final OperatingMode m => m.wire,
  final CalendarOrigin o => o.wire,
  final LedgerAxis a => a.wire,
  final SelfReportCashCheck c => c.wire,
  final DiffSeverity s => s.wire,
  final DiffStatus s => s.wire,
  final CommandKind k => k.wire,
  final AdviceKind k => k.wire,
  final AdviceStatus s => s.wire,
  final FillOrigin o => o.wire,
  final FillKind k => k.wire,
  final CostSource c => c.wire,
  final CredentialUse u => u.wire,
  final HandoverPath p => p.wire,
  final LedgerPair p => p.wire,
  final CommandState st => st.wire,
  final LedgerEventKind k => k.wire,
  final CorporateActionType t => t.wire,
  final CashFlowKind k => k.wire,
  final RunMode m => m.wire,
  final MarketDataSource s => s.wire,
  _ => throw ArgumentError('C-15 에 등록되지 않은 열거형: ${v.runtimeType}'),
};

List<CheckConstraint>? _cache;

List<CheckConstraint> _allChecks() => _cache ??= <CheckConstraint>[
  for (final String name in _batchFiles)
    ...parseCheckConstraints(File('${ddlDir.path}/$name')),
];

/// 로컬 SQLite 배치(새 설치 v1 · batch_e 보관 · batch_d 는 Supabase).
const List<String> _localBatchFiles = <String>[
  'batch_a_decision_mode.sql',
  'batch_b_plan_command.sql',
  'batch_c_x2_x5_local.sql',
  'batch_f_x7_advisory.sql',
  'batch_g_market_data.sql',
];

/// [file] 판의 배치 SQL — `ddl/*.sql` 은 LIVE 판이고 SIM 판은 `ledgerDdlFor` 가 만든다.
String _localDdl(LedgerFile file, String name) =>
    ledgerDdlFor(file, File('${ddlDir.path}/$name').readAsStringSync());

List<CheckConstraint> _localChecks(LedgerFile file) => <CheckConstraint>[
  for (final String name in _localBatchFiles)
    ...parseCheckConstraintsText(_localDdl(file, name), name),
];

Set<String> _localModeValues(LedgerFile file, String table) => <String>{
  for (final CheckConstraint c in _localChecks(file))
    if (c.table == table && c.column == 'mode') ...c.values,
};

/// 🆕 v1.22(01 §31 · K61) — `@sim` 태그로 두 판이 갈리는 칸(픽스처 축은 두 판 합집합으로 본다).
const Set<String> _simTaggedColumns = <String>{'executions.fill_origin'};

/// 로컬 배치 [file] 의 LIVE·SIM 두 판 CHECK 값 합집합.
Set<String> _checkValuesBothFiles(String file, String table, String column) =>
    <String>{
      for (final LedgerFile f in <LedgerFile>[LedgerFile.live, LedgerFile.sim])
        for (final CheckConstraint c in parseCheckConstraintsText(
          _localDdl(f, file),
          file,
        ))
          if (c.table == table && c.column == column) ...c.values,
    };

Set<String> _checkValues(String file, String table, String column) => <String>{
  for (final CheckConstraint c in _allChecks())
    if (c.file == file && c.table == table && c.column == column) ...c.values,
};

class _Axis {
  const _Axis(this.file, this.table, this.column, this.expected);

  final String file;
  final String table;
  final String column;
  final Set<String> expected;
}

class _FixtureAxis {
  const _FixtureAxis({
    required this.fixture,
    required this.key,
    required this.file,
    required this.table,
    required this.column,
  });

  final String fixture;
  final String key;
  final String file;
  final String table;
  final String column;
}
