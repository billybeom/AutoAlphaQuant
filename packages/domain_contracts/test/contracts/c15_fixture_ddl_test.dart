// C-15 픽스처 ↔ DDL 정합 — 01 §7 표 C-15 · §6 · 인벤토리 §9(🟢).
//
// 정의: 「픽스처의 열거값·필드가 §6 DDL 의 `CHECK`·컬럼과 일치하는지」.
// 잡는 것: **계약과 스키마가 갈라짐**.
// 🔴 인벤토리 §9 — 이 검사의 요점은 `SAT`·`REQUIRED`·`RECORD_MANUAL_FILL` 같은
//    **비기계적 매핑**을 잡는 것이다(이름이 기계적으로 유도되지 않는 자리).
//
// 🔴 **아직 닫히지 않은 물음은 «통과»로 덮지 않는다.** 인벤토리 §10-2 의 열린 물음
//    1·2(명령 상태 4/7/9 · `mode` 축 2값 vs 3값)는 확정 전까지 DDL 을 고칠 수 없으므로
//    (§9-1 «확정 전 DDL 불변») 여기서는 **현재 상태를 못 박는다** — 어느 쪽으로든
//    결정이 오면 이 검사가 실패해서 「DDL·열거형·픽스처를 한 커밋에서」 움직이게 만든다.

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
  _Axis(
    'batch_f_x7_advisory.sql',
    'executions',
    'fill_origin',
    _wires(FillOrigin.values),
  ),
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

    test('C-15 픽스처의 열거값이 CHECK 안에 있다', () {
      for (final _FixtureAxis axis in _fixtureAxes) {
        final Set<String> allowed = _checkValues(
          axis.file,
          axis.table,
          axis.column,
        );
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

    test('C-15 🔴 열린 물음 1 — 명령 상태 집합이 세 곳에서 다르다(현재 상태 고정)', () {
      // 인벤토리 §10-2 ①. G-30 은 「command_inbox 의 state 집합 = command_queue 의
      // state 집합」을 요구하는데 지금은 셋이 다르다. 확정 전에는 DDL 을 고치지 않는다.
      final Set<String> contract = CommandState.values
          .map((CommandState s) => s.wire)
          .toSet();
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

      expect(
        contract.difference(inbox),
        <String>{'REQUESTED', 'NO_OPERATOR'},
        reason:
            '🔴 열린 물음 1 — command_inbox 에 없는 계약 상태가 바뀌었다. '
            '결정이 왔다면 DDL·열거형·픽스처를 한 커밋에서 움직이고 이 기대값을 고친다.',
      );
      expect(contract.difference(ack), <String>{
        'REQUESTED',
        'STALE_CONTEXT',
        'HELD_FOR_INTEGRITY',
        'PENDING_LEASE_CONFIRM',
        'NO_OPERATOR',
      }, reason: '🔴 command_ack 는 여전히 4값이다 — 보류 상태를 ack 이 표현하지 못한다.');
    });

    test('C-15 🔴 열린 물음 2 — mode 축이 로컬 2값·미러 3값으로 갈려 있다(현재 상태 고정)', () {
      // 인벤토리 §10-2 ②-ⓑ — 🔴 'SIM' 은 RunMode 의 @JsonValue 가 **아니다**.
      // 로컬 2값 CHECK 는 「SIM 계열을 좁게 받는다」가 아니라 **SIM 계열 행을 하나도
      // 표현하지 못한다**.
      final Set<String> runMode = RunMode.values
          .map((RunMode m) => m.wire)
          .toSet();
      expect(runMode, <String>{'SIM_INTERNAL', 'SIM_BROKER', 'LIVE'});

      final Set<String> local = _checkValues(
        'batch_a_decision_mode.sql',
        'trades',
        'mode',
      );
      expect(
        local,
        <String>{'SIM', 'LIVE'},
        reason:
            '🔴 로컬 SQLite 의 mode CHECK 가 바뀌었다 — 결정이 왔다면 batch_a·b·f 와 '
            'journal_30.json 과 이 검사를 한 커밋에서 움직인다.',
      );
      expect(runMode.intersection(local), <String>{
        'LIVE',
      }, reason: '겹치는 값은 LIVE 하나뿐이다 — 2값 유지는 «보수적 선택»이 아니다.');

      final Set<String> mirror = _checkValues(
        'batch_d_supabase.sql',
        'ledger_stamp',
        'mode',
      );
      expect(
        mirror,
        runMode,
        reason:
            'Supabase 미러는 이미 RunMode 3값이다 — 로컬과 미러가 같은 축을 다르게 '
            '적고 있다(열린 물음 2 의 실측 근거).',
      );

      // 🔴 픽스처는 이미 SIM 계열 행을 싣는다 — 봉투만 보고 «정합» 이라 하면 안 된다.
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
      expect(
        rowModes,
        contains('SIM_INTERNAL'),
        reason:
            'journal_30.json 의 je_0030 이 SIM_INTERNAL 을 싣는다(인벤토리 §10-2 ②-ⓐ).',
      );
      expect(
        rowModes.difference(local),
        isNotEmpty,
        reason:
            '🔴 이 차집합이 비면 충돌이 해소된 것이다 — 그때 이 검사를 지우고 '
            'mode 축을 _axes 의 1:1 대조로 옮긴다.',
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
  _ => throw ArgumentError('C-15 에 등록되지 않은 열거형: ${v.runtimeType}'),
};

List<CheckConstraint>? _cache;

List<CheckConstraint> _allChecks() => _cache ??= <CheckConstraint>[
  for (final String name in _batchFiles)
    ...parseCheckConstraints(File('${ddlDir.path}/$name')),
];

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
