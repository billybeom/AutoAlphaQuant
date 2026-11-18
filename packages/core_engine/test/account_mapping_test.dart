// E11p3d-5i — M9 S03 계좌 · 슬리브 매핑 VM(설계 13 §8 R151) · 표본 = domain_contracts `m9/account_mapping*`.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

// 2026-12-01 09:00 KST.
final DateTime _now = DateTime.utc(2026, 12, 1);
final DateTime _verified = DateTime.utc(2026, 11, 30, 23, 46);

const Map<String, String> _map = <String, String>{
  'P0S_A': '연금저축',
  'P0S_B': 'ISA',
  'P0S_C': '일반',
  'P0S_POT': '연금저축',
};

AccountMappingVm _vm({PaperAccountFacts? paper, Map<String, String>? map}) =>
    accountMappingVmOf(
      AccountMappingFacts(
        paper:
            paper ??
            PaperAccountFacts(
              accountNo: '50125096',
              productCode: '01',
              verifiedAtUtc: _verified,
            ),
        accountByStrategy: map,
      ),
      nowUtc: _now,
    );

Map<String, Object?> _fx(String name) {
  final Map<String, Object?> env = jsonDecode(
    File('../domain_contracts/fixtures/m9/$name.json').readAsStringSync(),
  ) as Map<String, Object?>;
  return (env['rows']! as List<Object?>).first! as Map<String, Object?>;
}

void main() {
  test(
    '🔴 운영 설정 없음(사람 값 P0-① 전) = 계좌 = 모의 한 행 · 슬리브 A·B·C 미지정 ACT(표본 문장) · 선택지 0',
    () {
      final AccountMappingVm vm = _vm();
      expect(vm.accounts, hasLength(1));
      final AccountRow mock = vm.accounts.single;
      expect(
        (mock.label, mock.kindLabel, mock.maskedNumberText, mock.badgeText),
        ('모의투자', '모의 01', '****5096', '실전 매핑 대상 아님'),
      );
      expect(mock.checkText, '모의 서버 잔고 확인 12-01 08:46');
      expect(mock.level, UiLevel.info);
      expect(
        vm.mappings.map((SleeveMappingRow m) => m.sleeveLabel).toList(),
        <String>['슬리브 A', '슬리브 B', '슬리브 C'],
      );
      for (final SleeveMappingRow m in vm.mappings) {
        expect(m.accountLabel, isNull);
        expect(m.statusLine, '미지정 — 이 슬리브의 주문은 내지 않습니다.');
        expect(m.level, UiLevel.act);
        expect(m.options, isEmpty);
        expect(m.subbookLine, isNull);
      }
      // 표본(미지정 행)과 같은 글자.
      final Map<String, Object?> unmapped =
          (_fx('account_mapping_unmapped')['mappings']! as List<Object?>)[2]!
              as Map<String, Object?>;
      expect(vm.mappings.first.statusLine, unmapped['status_line']);
    },
  );

  test('🔴 모의 계좌 — 번호 = 엔진 마스킹(뒤 4) · 검증 기록 없음 = WATCH · 키 없음 = «등록 전» ACT(1행 이상 · 원번호 0)', () {
    final AccountRow noCheck = _vm(
      paper: const PaperAccountFacts(accountNo: '50125096', productCode: '22'),
    ).accounts.single;
    expect(noCheck.kindLabel, '모의 22');
    expect(noCheck.checkText, '모의 서버 잔고 확인 기록 없음');
    expect(noCheck.level, UiLevel.watch);
    final AccountRow none = _vm(paper: const PaperAccountFacts())
        .accounts
        .single;
    expect(
      (none.maskedNumberText, none.checkText, none.level),
      ('등록 전', '모의 키를 먼저 등록하세요(증권사 키)', UiLevel.act),
    );
    // 원번호는 어디에도 싣지 않는다.
    expect(jsonEncode(_vm().toJson()).contains('50125096'), isFalse);
  });

  test('🔴 운영 설정 있음 = 슬리브 = 별칭(OK · 선택지 = 지금 계좌 하나 · 바꾸기 0) · POT 가 A 와 같으면 A 행 한 줄 · 실전 별칭 = «등록 전» 행', () {
    final AccountMappingVm vm = _vm(map: _map);
    expect(
      vm.mappings
          .map((SleeveMappingRow m) => (m.sleeveLabel, m.accountLabel, m.level))
          .toList(),
      <(String, String?, UiLevel)>[
        ('슬리브 A', '연금저축', UiLevel.ok),
        ('슬리브 B', 'ISA', UiLevel.ok),
        ('슬리브 C', '일반', UiLevel.ok),
      ],
    );
    expect(vm.mappings[0].subbookLine, 'POT 서브북도 이 계좌에서 운용합니다.');
    expect(vm.mappings[1].subbookLine, isNull);
    expect(vm.mappings[0].statusLine, isNull);
    expect(vm.mappings[1].options, const <AccountMappingOption>[
      AccountMappingOption(label: 'ISA', selected: true),
    ]);
    expect(
      vm.mappings
          .expand((SleeveMappingRow m) => m.options)
          .map((AccountMappingOption o) => o.selectAction),
      everyElement(isNull),
    );
    // 실전 별칭 = 중복 없이 차례대로 + 모의 한 행(맨 뒤).
    expect(vm.accounts.map((AccountRow a) => a.label).toList(), <String>[
      '연금저축',
      'ISA',
      '일반',
      '모의투자',
    ]);
    final AccountRow isa = vm.accounts[1];
    expect(
      (isa.maskedNumberText, isa.checkText, isa.level),
      ('등록 전', '실전 키 등록 전 — 잔고를 확인할 수 없습니다', UiLevel.watch),
    );
    // POT 가 다른 계좌면 A 행 줄 없음.
    expect(
      _vm(map: <String, String>{..._map, 'P0S_POT': 'ISA'})
          .mappings[0]
          .subbookLine,
      isNull,
    );
  });

  test('🔴 R154 — 정한 대응표만 있고 모의 개시 판 없음 = 그 별칭(표시 글자) · «모의 개시 전» INFO · 개시 판이 있으면 그 판이 이긴다', () {
    const Map<String, String> decided = <String, String>{
      'P0S_A': 'isa',
      'P0S_B': 'pension',
      'P0S_C': 'general',
      'P0S_POT': 'isa',
    };
    const Map<String, String> labels = <String, String>{
      'isa': 'ISA',
      'pension': '연금저축',
      'general': '일반 위탁',
    };
    AccountMappingVm of({Map<String, String>? active}) => accountMappingVmOf(
      AccountMappingFacts(
        paper: const PaperAccountFacts(),
        accountByStrategy: active,
        decidedByStrategy: decided,
        accountLabels: labels,
      ),
      nowUtc: _now,
    );
    final AccountMappingVm pending = of();
    expect(
      pending.mappings
          .map((SleeveMappingRow m) => (m.accountLabel, m.statusLine, m.level))
          .toList(),
      <(String?, String?, UiLevel)>[
        ('ISA', '모의 개시 전 — 시작하면 이 계좌로 운영합니다.', UiLevel.info),
        ('연금저축', '모의 개시 전 — 시작하면 이 계좌로 운영합니다.', UiLevel.info),
        ('일반 위탁', '모의 개시 전 — 시작하면 이 계좌로 운영합니다.', UiLevel.info),
      ],
    );
    expect(pending.mappings.first.subbookLine, 'POT 서브북도 이 계좌에서 운용합니다.');
    expect(pending.mappings.first.options, const <AccountMappingOption>[
      AccountMappingOption(label: 'ISA', selected: true),
    ]);
    expect(pending.accounts.map((AccountRow a) => a.label).toList(), <String>[
      'ISA',
      '연금저축',
      '일반 위탁',
      '모의투자',
    ]);
    // 개시 판(지금 설정)이 있으면 그것 · 상태 줄 없음 · OK.
    final AccountMappingVm active = of(
      active: const <String, String>{
        'P0S_A': 'pension',
        'P0S_B': 'pension',
        'P0S_C': 'general',
        'P0S_POT': 'pension',
      },
    );
    expect(active.mappings.first.accountLabel, '연금저축');
    expect(active.mappings.first.statusLine, isNull);
    expect(active.mappings.first.level, UiLevel.ok);
    // 둘 다 없으면 미지정(R151 그대로).
    expect(
      accountMappingVmOf(
        const AccountMappingFacts(paper: PaperAccountFacts()),
        nowUtc: _now,
      ).mappings.first.statusLine,
      kSleeveUnmappedLine,
    );
    expect(kSleevePendingLine, '모의 개시 전 — 시작하면 이 계좌로 운영합니다.');
  });

  test('🔴 버튼 · 잠김 = 없음(동작 · 실전 키 · 생체 전) · 기준 = 지금 · 26시간 · KST', () {
    final AccountMappingVm vm = _vm(map: _map);
    expect(vm.verifyAction, isNull);
    expect(vm.lockedLabel, isNull);
    final AsOf a = vm.asOf;
    expect(a.observedAt, _now);
    expect(a.tradeDate, const TradeDate('2026-12-01'));
    expect(a.staleAfter, const Duration(seconds: 93600));
    expect(a.label, '계좌 기준 2026-12-01 09:00');
  });

  test('표본과 같은 꼴 — VM · 계좌 · 슬리브 JSON 키가 `account_mapping` 과 같다', () {
    final Map<String, Object?> fx = _fx('account_mapping');
    final Map<String, Object?> ours =
        jsonDecode(jsonEncode(_vm(map: _map).toJson())) as Map<String, Object?>;
    expect(ours.keys.toSet(), fx.keys.toSet());
    Map<String, Object?> first(Map<String, Object?> m, String k) =>
        (m[k]! as List<Object?>).first! as Map<String, Object?>;
    expect(
      first(ours, 'accounts').keys.toSet(),
      first(fx, 'accounts').keys.toSet(),
    );
    expect(
      first(ours, 'mappings').keys.toSet(),
      first(fx, 'mappings').keys.toSet(),
    );
    expect(
      first(first(ours, 'mappings'), 'options').keys.toSet(),
      first(first(fx, 'mappings'), 'options').keys.toSet(),
    );
  });
}
