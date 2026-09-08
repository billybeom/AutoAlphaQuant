// C-23 (01 §7 · §10-3 · §2-8) — 원장은 한 스트림이다.
//
// 「파생 계산 경로가 `advice`·`external_holding` 을 참조하지 않는다」의 실측은
// 엔진·`data_sync` 소스 스캔이 선행한다(인벤토리 §9 C-23 = 🟡). 여기서 지키는 것은
// **계약 면의 두 가지**다:
//   ① 캘린더 타입에 안내를 실을 자리가 아예 없는가(§2-8 화이트리스트 직렬화)
//   ② 시스템 밖 자산이 «별도 표»가 아니라 `scope` 축으로 표현되는가(§2-1 `HoldingScope`)
//
// 🔴 계획(안내)이 사실(체결)로 섞이면 캘린더에서 「내가 3번 샀나」로 읽히고,
//    그 오인이 이중 매수를 부른다 — `canonCalendar` 대사는 1:1 이라 감사로도 잡히지 않는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_io_t2.dart';

void main() {
  group('C-23 X7 원장 단일 스트림 (01 §7 · §10-3)', () {
    test('C-23 ① CalendarEventDto 에 안내를 실을 필드가 없다 (§2-8 화이트리스트)', () {
      final CalendarEventDto event = CalendarEventDto(
        aaqKey: 'exec.ex_0001',
        kind: CalendarEventKind.execution,
        startUtc: DateTime.utc(2026, 8, 31, 5),
        allDay: false,
        title: '체결 · 매수 069500',
        body: '수량 12주 · 계좌 연금저축',
        origin: CalendarOrigin.live,
        configHash: 'cfg_fake_0000000000000000',
      );

      final Iterable<String> keys = event.toJson().keys;
      for (final String key in keys) {
        expect(
          key.contains('advice'),
          isFalse,
          reason: '캘린더 타입에 안내 필드가 생겼다: $key',
        );
        // 🔴 타입에 없음: 손익·수익률·평가액·잔고·계좌 전체번호·시크릿.
        for (final String forbidden in <String>[
          'pnl',
          'return',
          'balance',
          'equity',
          'account_no',
          'secret',
          'token',
        ]) {
          expect(
            key.contains(forbidden),
            isFalse,
            reason: '캘린더 타입에 금지 필드가 생겼다: $key',
          );
        }
      }
    });

    test('C-23 ② 캘린더 갈래에 «안내» 가 없다 (§2-8 kind 표)', () {
      for (final CalendarEventKind kind in CalendarEventKind.values) {
        expect(
          kind.wire.contains('ADVICE'),
          isFalse,
          reason: '안내가 캘린더 이벤트 갈래로 올라왔다: ${kind.wire}',
        );
      }
      // 🔴 정정 2행을 «체결» 3건으로 그리지 않기 위한 갈래는 남아 있어야 한다(C11).
      expect(
        CalendarEventKind.values.map((CalendarEventKind k) => k.wire),
        contains('EXECUTION_CORRECTION'),
      );
    });

    test('C-23 ③ 시스템 밖 자산은 별도 표가 아니라 scope 축이다 (D7)', () {
      expect(
        HoldingScope.values.map((HoldingScope s) => s.wire).toList(),
        <String>['MANAGED', 'EXTERNAL'],
      );

      // `external_holdings_2` 는 «등록 목록»(위저드 입력)이지 보유 파생이 아니다 —
      // 🔴 표시 UNION 은 `HoldingsRepository` 한 곳에서만 만든다.
      final List<Map<String, Object?>> external = fixtureRows(
        FixturePaths.m6ExternalHoldings2,
      );
      expect(external, isNotEmpty);
      for (final Map<String, Object?> row in external) {
        expect(
          row.containsKey('scope_label'),
          isTrue,
          reason: '시스템 밖 자산 행이 «시스템 밖» 이라고 말하지 못하면 관리 대상과 섞인다.',
        );
        expect(row.containsKey('quantity'), isTrue);
        // 🔴 손익·평가액은 오지 않는다(결정 8).
        expect(row.containsKey('unrealized_pnl'), isFalse);
        expect(row.containsKey('market_value'), isFalse);
      }
    });

    test(
      'C-23 ④ 파생 계산 경로가 advice·external_holding 을 참조하지 않는다',
      () {},
      skip: 'core_engine·data_sync 소스 스캔이 선행한다(인벤토리 §9 C-23 = 🟡).',
    );

    test(
      'C-23 ⑤ 캘린더 매퍼에 AdviceItem 타입 차단',
      () {},
      skip: '캘린더 매퍼 구현(X4 채택 미결 · 01 §8-5)이 선행한다.',
    );
  });
}
