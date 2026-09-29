// C-37 열람 게이트·기록 계약 — 01 §13-5 · §13-6 · §7 표 C-37(🆕 계약 v1.3).
//
// 정의: 「열람 게이트(`S7-2G`)와 열람 기록 명령이, 화면이 판정·조립 없이 쓸 수 있는 모양으로 온다」.
//   ① 게이트 픽스처 전부: `gate_open == (route != null)` · `headline`·`view_count_text` 비지 않음.
//   ② `route` 가 있으면 `AppRoutes.performanceExplore` 와 같다.
//   ③ 접수증 픽스처: 전 행 `DISCLOSURE_VIEW` · 같은 `command_id` · 상태 4값 · 거부 사유 없음 ·
//      `state_label` 비지 않음.
//   ④ `DisclosureViewEvent` 는 `durationSec` 를 적지 않으면 0 이고 JSON 왕복이 같다.
//   ⑤ `DisclosureSurfaceCodes.values` 가 `ContractCodes` 에 등재돼 있다.
// 🔴 «통과 전에는 `series` 를 부르지 않는다»·«접수증이 와야 열린다»는 화면 테스트의 몫이다
//    (ui_analytics). 라우터 가드 테스트는 셸(R13)이다.
// 🔴 ①②③ 은 **망가뜨린 사본**(메모리 안)으로 실패하는 것을 맨 끝 테스트가 고정한다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';
import 'support/perf_series_rows.dart' show deepCopyJson;

/// 계약 v1.3 이 아는 게이트 픽스처(4건). 검사는 **모양으로 찾은 것**을 본다.
const List<String> _knownGateFixtures = <String>[
  FixturePaths.m7M7DisclosureGate,
  FixturePaths.m7M7DisclosureGateClosed,
  FixturePaths.m7M7DisclosureGateFirst,
  FixturePaths.m7M7DisclosureGateFrequent,
];

/// 열람 기록 접수증의 상태 — 픽스처의 **행 순서가 뜻**이다(01 §13-10 · N5).
/// 거부(`REJECTED`) 표본은 v1.3 에 없다(거부 코드 사전 = 미결).
const List<CommandState> _receiptStates = <CommandState>[
  CommandState.requested,
  CommandState.executed,
  CommandState.expired,
  CommandState.heldForIntegrity,
];

void main() {
  group('C-37 열람 게이트·기록 계약 (01 §13 · 계약 v1.3)', () {
    test('C-37 ① 게이트는 열려 있을 때만 목적지를 싣고, 글자 2줄은 늘 온다', () {
      final Map<String, Map<String, Object?>> gates = _gateRows();
      expect(gates.keys, containsAll(_knownGateFixtures));
      final List<String> bad = <String>[
        for (final MapEntry<String, Map<String, Object?>> e in gates.entries)
          ..._gateViolations(e.key, e.value),
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));

      // 입력 확인 — 열린 것·닫힌 것 · 마찰 줄 있는 것·없는 것이 모두 있다.
      final List<DisclosureGateVm> vms = gates.values
          .map(DisclosureGateVm.fromJson)
          .toList();
      expect(vms.where((DisclosureGateVm g) => g.gateOpen), isNotEmpty);
      expect(vms.where((DisclosureGateVm g) => !g.gateOpen), isNotEmpty);
      expect(
        vms.where((DisclosureGateVm g) => g.frictionLine == null),
        isNotEmpty,
      );
      expect(
        vms.where((DisclosureGateVm g) => g.frictionLine != null),
        isNotEmpty,
      );
    });

    test('C-37 ② 게이트의 목적지는 수익률 탐색 하나다', () {
      final List<String> bad = <String>[
        for (final MapEntry<String, Map<String, Object?>> e
            in _gateRows().entries)
          ..._gateRouteViolations(e.key, e.value),
      ];
      expect(bad, isEmpty, reason: bad.join('\n'));
      expect(AppRoutes.all, contains(AppRoutes.performanceExplore));
    });

    test('C-37 ③ 열람 기록 접수증은 한 명령의 네 상태다', () {
      final List<Map<String, Object?>> rows = _receiptRows();
      expect(_receiptViolations(rows), isEmpty);
    });

    test('C-37 ④ DisclosureViewEvent 는 durationSec 를 적지 않으면 0 이다', () {
      final DisclosureViewEvent event = DisclosureViewEvent(
        surfaceCode: DisclosureSurfaceCodes.performanceExplore,
        viewedAt: DateTime.utc(2026, 8, 31, 10),
      );
      expect(event.durationSec, 0, reason: '진입 시점 기록은 0 이다 — 화면은 이 값을 적지 않는다.');

      final Map<String, dynamic> json = event.toJson();
      expect(json.keys.toSet(), <String>{
        'surface_code',
        'viewed_at',
        'duration_sec',
      });
      expect(json['surface_code'], 'PERFORMANCE_EXPLORE');
      expect(json['duration_sec'], 0);
      expect(DisclosureViewEvent.fromJson(json), event);

      // 옛 엔진·옛 기록처럼 키가 없어도 0 으로 읽는다(추가형 진화).
      final DisclosureViewEvent withoutKey = DisclosureViewEvent.fromJson(
        <String, dynamic>{
          'surface_code': 'PERFORMANCE_EXPLORE',
          'viewed_at': '2026-08-31T10:00:00.000Z',
        },
      );
      expect(withoutKey.durationSec, 0);
      expect(withoutKey, event);

      // 기본값이 값을 덮어쓰지 않는다(늘 0 을 돌려주는 구현이면 여기서 깨진다).
      expect(
        DisclosureViewEvent.fromJson(<String, dynamic>{
          ...json,
          'duration_sec': 42,
        }).durationSec,
        42,
      );
    });

    test('C-37 ⑤ 열람 화면 코드는 코드 사전에 등재돼 있다', () {
      expect(DisclosureSurfaceCodes.values, isNotEmpty);
      expect(
        DisclosureSurfaceCodes.values,
        contains(DisclosureSurfaceCodes.performanceExplore),
      );
      expect(ContractCodes.hasDomain('disclosure_surface'), isTrue);
      expect(
        ContractCodes.byDomain['disclosure_surface'],
        DisclosureSurfaceCodes.values,
      );
      for (final String code in DisclosureSurfaceCodes.values) {
        expect(
          ContractCodes.isRegisteredIn('disclosure_surface', code),
          isTrue,
          reason: code,
        );
        expect(
          RegExp(r'^[A-Z][A-Z0-9_]*$').hasMatch(code),
          isTrue,
          reason: '$code — 코드는 대문자·밑줄이다.',
        );
      }
      expect(
        ContractCodes.isRegisteredIn('disclosure_surface', 'MONTHLY_REPORT'),
        isFalse,
        reason: '등재하지 않은 값까지 통과시키면 사전이 아니다.',
      );
    });

    test('C-37 자체 검증 — 망가뜨린 사본은 검사에 걸린다', () {
      final Map<String, Map<String, Object?>> gates = _gateRows();
      final Map<String, Object?> open =
          gates[FixturePaths.m7M7DisclosureGateFirst]!;
      final Map<String, Object?> closed =
          gates[FixturePaths.m7M7DisclosureGateClosed]!;

      // 원본은 통과한다(아래 변이가 뜻을 갖는 전제).
      expect(_gateViolations('open', open), isEmpty);
      expect(_gateViolations('closed', closed), isEmpty);
      expect(_gateRouteViolations('open', open), isEmpty);

      // ①
      expect(
        _gateViolations('m', deepCopyJson(open)..remove('route')),
        isNotEmpty,
        reason: '열렸는데 목적지가 없다.',
      );
      expect(
        _gateViolations(
          'm',
          deepCopyJson(closed)..['route'] = AppRoutes.performanceExplore,
        ),
        isNotEmpty,
        reason: '닫혔는데 목적지가 있다.',
      );
      expect(
        _gateViolations('m', deepCopyJson(open)..['gate_open'] = false),
        isNotEmpty,
      );
      expect(
        _gateViolations('m', deepCopyJson(open)..['headline'] = ''),
        isNotEmpty,
      );
      expect(
        _gateViolations('m', deepCopyJson(closed)..['view_count_text'] = ' '),
        isNotEmpty,
      );
      // ②
      expect(
        _gateRouteViolations(
          'm',
          deepCopyJson(open)..['route'] = AppRoutes.reportArchive,
        ),
        isNotEmpty,
        reason: '등록된 다른 목적지도 게이트의 목적지는 아니다.',
      );
      expect(
        _gateRouteViolations(
          'm',
          deepCopyJson(open)..['route'] = AppNavActions.back,
        ),
        isNotEmpty,
      );

      // ③
      final List<Map<String, Object?>> receipts = _receiptRows();
      expect(_receiptViolations(receipts), isEmpty);
      List<Map<String, Object?>> broken(
        void Function(List<Map<String, Object?>> rows) edit,
      ) {
        final List<Map<String, Object?>> copy = receipts
            .map(deepCopyJson)
            .toList();
        edit(copy);
        return copy;
      }

      expect(
        _receiptViolations(
          broken((List<Map<String, Object?>> r) => r[1]['kind'] = 'ALERT_ACK'),
        ),
        isNotEmpty,
        reason: '다른 명령의 접수증이 섞였다.',
      );
      expect(
        _receiptViolations(
          broken(
            (List<Map<String, Object?>> r) =>
                r[2]['command_id'] = 'cmd_20260831_0043',
          ),
        ),
        isNotEmpty,
        reason: '다른 명령 id.',
      );
      expect(
        _receiptViolations(
          broken((List<Map<String, Object?>> r) => r[1]['state'] = 'REJECTED'),
        ),
        isNotEmpty,
        reason: '거부 표본은 v1.3 에 없다.',
      );
      expect(
        _receiptViolations(
          broken(
            (List<Map<String, Object?>> r) =>
                r[3]['reject_reason_code'] = 'SAF-309',
          ),
        ),
        isNotEmpty,
        reason: '거부 사유 코드가 실렸다.',
      );
      expect(
        _receiptViolations(
          broken((List<Map<String, Object?>> r) => r[0]['state_label'] = ''),
        ),
        isNotEmpty,
      );
      expect(
        _receiptViolations(
          broken((List<Map<String, Object?>> r) => r.removeLast()),
        ),
        isNotEmpty,
        reason: '행이 하나 빠졌다.',
      );
      expect(
        _receiptViolations(
          broken((List<Map<String, Object?>> r) {
            final Map<String, Object?> first = r.removeAt(0);
            r.add(first);
          }),
        ),
        isNotEmpty,
        reason: '행 순서가 바뀌었다(순서가 뜻이다).',
      );
    });
  });
}

/// 전 픽스처에서 게이트 행을 **모양으로** 찾는다(`gate_open` · `headline` 키) — 경로 → 행.
Map<String, Map<String, Object?>> _gateRows() {
  final Map<String, Map<String, Object?>> out =
      <String, Map<String, Object?>>{};
  for (final String path in FixturePaths.all) {
    final List<Map<String, Object?>> rows = decodeEnvelope(readFixture(path))
        .rows;
    for (final Map<String, Object?> row in rows) {
      if (row.containsKey('gate_open') && row.containsKey('headline')) {
        expect(
          out.containsKey(path),
          isFalse,
          reason: '$path — 게이트 픽스처는 1행이다.',
        );
        out[path] = row;
      }
    }
  }
  return out;
}

List<Map<String, Object?>> _receiptRows() =>
    decodeEnvelope(readFixture(FixturePaths.m7M7DisclosureViewReceipts4)).rows;

List<String> _gateViolations(String where, Map<String, Object?> row) {
  final DisclosureGateVm vm = DisclosureGateVm.fromJson(row);
  return <String>[
    if (vm.gateOpen != (vm.route != null))
      '$where — gate_open ${vm.gateOpen} 인데 route ${vm.route == null ? '없음' : '있음'}',
    if (vm.headline.trim().isEmpty) '$where — headline 이 비었다',
    if (vm.viewCountText.trim().isEmpty) '$where — view_count_text 가 비었다',
    if (vm.frictionLine != null && vm.frictionLine!.trim().isEmpty)
      '$where — friction_line 이 빈 글자다(없으면 키를 뺀다)',
  ];
}

List<String> _gateRouteViolations(String where, Map<String, Object?> row) {
  final String? route = DisclosureGateVm.fromJson(row).route;
  return <String>[
    if (route != null && route != AppRoutes.performanceExplore)
      '$where — route $route ≠ ${AppRoutes.performanceExplore}',
  ];
}

List<String> _receiptViolations(List<Map<String, Object?>> rows) {
  final List<String> bad = <String>[];
  final List<CommandReceipt> receipts = rows
      .map(CommandReceipt.fromJson)
      .toList();
  final List<CommandState> states = <CommandState>[
    for (final CommandReceipt r in receipts) r.state,
  ];
  if (states.join(',') != _receiptStates.join(',')) {
    bad.add('상태 순서 $states ≠ $_receiptStates');
  }
  if (receipts.map((CommandReceipt r) => r.commandId).toSet().length != 1) {
    bad.add('command_id 가 한 가지가 아니다');
  }
  for (int i = 0; i < receipts.length; i++) {
    final CommandReceipt r = receipts[i];
    if (r.kind != CommandKind.disclosureView) {
      bad.add('rows[$i] kind ${r.kind.name} — DISCLOSURE_VIEW 가 아니다');
    }
    if (r.stateLabel.trim().isEmpty) {
      bad.add('rows[$i] state_label 이 비었다');
    }
    if (r.rejectReasonCode != null ||
        rows[i].containsKey('reject_reason_code')) {
      bad.add('rows[$i] reject_reason_code 가 실렸다');
    }
  }
  return bad;
}
