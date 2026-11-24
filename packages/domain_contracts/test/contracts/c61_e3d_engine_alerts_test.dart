// C-61 E3d 계약 창 — 엔진 등재 대기 알림 5 등재(SAF 경고 4 · 파생 FORK 1) — 01 §36
// (🆕 계약 v1.27 · 발주자 위임 2026-11-14 — 권고대로 · K187~K195).
//
// 정의: 「엔진이 이미 내던 «등재 대기 제안» 알림 다섯이 `AlertCodes` 에 있다 — `safetyWarn` 4(SAF-302 · 308 · 306 · 307 부속) ·
//        `derivedSync` 1(`DERIVED_FORK`) · `values` 36 · 기존 7 묶음과 서로소 · 표본 5행의 코드 = 두 묶음 합 · 등급 = 엔진 등급표
//        (C-47 ⑥ 와 같은 값) · 링크 = 라우트 상수 · `alert_code` 도메인 등재」.
//   ① 묶음 글자 ② values 36 · 서로소 ③ 표본 코드 집합 ④ 표본 등급 ⑤ 링크 ⑥ 사전 도메인
//
// 🔴 등급을 계약에 사전으로 만들지 않는다(`alert_codes.dart` 머리 조문) — ④ 의 표는 이 시험 한 곳(엔진 `kAlertLevels` 그대로 ·
//    04 §5-3 v2.45 · v2.46 제안).
// 🔴 SAF-307 달러 노출 기준선 초과는 코드가 없다(월간 리포트 `D2_ALLOCATION` 메모 · 01 §36 K192) — ① 이 다섯 글자만 못박는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// ④ 엔진 등급(core `safety/alert_rules.dart` `kAlertLevels` · 04 §5-3 v2.45 · v2.46).
const Map<String, String> _engineLevel = <String, String>{
  'DERIVED_FORK': 'P0',
  'DEFENSIVE_FLOOR_BREACHED': 'P1',
  'GOLD_SHARE_HIGH': 'P1',
  'FINANCIAL_INCOME_CAP_EXCEEDED': 'P1',
  'KRW_LIQUIDITY_LOW': 'P2',
};

List<Map<String, Object?>> _rows() =>
    decodeEnvelope(readFixture(FixturePaths.m8AlertsEngineProposalsV127)).rows;

void main() {
  group('C-61 E3d 계약 창 — 엔진 등재 대기 알림 5(01 §36)', () {
    test('① 묶음 글자 — safetyWarn 4 · derivedSync 1', () {
      expect(AlertCodes.safetyWarn, <String>{
        'DEFENSIVE_FLOOR_BREACHED',
        'GOLD_SHARE_HIGH',
        'FINANCIAL_INCOME_CAP_EXCEEDED',
        'KRW_LIQUIDITY_LOW',
      });
      expect(AlertCodes.derivedSync, <String>{'DERIVED_FORK'});
      expect(AlertCodes.defensiveFloorBreached, 'DEFENSIVE_FLOOR_BREACHED');
      expect(AlertCodes.goldShareHigh, 'GOLD_SHARE_HIGH');
      expect(
        AlertCodes.financialIncomeCapExceeded,
        'FINANCIAL_INCOME_CAP_EXCEEDED',
      );
      expect(AlertCodes.krwLiquidityLow, 'KRW_LIQUIDITY_LOW');
      expect(AlertCodes.derivedFork, 'DERIVED_FORK');
    });

    test('② values 36 · 두 묶음 ⊂ values · 기존 7 묶음과 서로소', () {
      // 🔵 v1.39(01 §48) — +3(킬스위치 확인 1 · push 2) → 39(전량 고정 = C-72 ⑦).
      expect(AlertCodes.values, hasLength(greaterThanOrEqualTo(36)));
      final Set<String> added = <String>{
        ...AlertCodes.safetyWarn,
        ...AlertCodes.derivedSync,
      };
      expect(added, hasLength(5));
      expect(AlertCodes.values.containsAll(added), isTrue);
      final Set<String> before = <String>{
        ...AlertCodes.x7Advice,
        ...AlertCodes.handover,
        ...AlertCodes.autoTrade,
        ...AlertCodes.maintenance,
        ...AlertCodes.operatingParam,
        ...AlertCodes.safety,
        ...AlertCodes.resume,
      };
      expect(before, hasLength(31));
      expect(before.intersection(added), isEmpty);
      // 🔵 v1.39(01 §48) — 뒤 판 묶음(킬스위치 확인 · push)은 C-72 ⑦ 이 고정한다.
      expect(<String>{
        ...before,
        ...added,
        ...AlertCodes.killSwitch,
        ...AlertCodes.readModelPush,
      }, AlertCodes.values);
    });

    test('③ 표본 5행 — 코드 집합 = 두 묶음 합 · 각 1행 · 봉투 = 목록', () {
      final List<Map<String, Object?>> rows = _rows();
      expect(rows, hasLength(5));
      final List<String> codes = <String>[
        for (final Map<String, Object?> r in rows) AlertItem.fromJson(r).code,
      ];
      expect(codes.toSet(), <String>{
        ...AlertCodes.safetyWarn,
        ...AlertCodes.derivedSync,
      });
      expect(codes.toSet(), hasLength(5));
    });

    test('④ 표본 등급 = 엔진 등급표 · 등급 순(P0 → P2) · 미확인', () {
      final List<AlertItem> items = <AlertItem>[
        for (final Map<String, Object?> r in _rows()) AlertItem.fromJson(r),
      ];
      for (final AlertItem a in items) {
        expect(
          a.level.name.toUpperCase(),
          _engineLevel[a.code],
          reason: a.code,
        );
        expect(a.ack, isNull, reason: a.alertId);
        expect(a.groupedCount, 1, reason: a.alertId);
      }
      final List<int> order = <int>[
        for (final AlertItem a in items) AlertLevel.values.indexOf(a.level),
      ];
      expect(order, List<int>.of(order)..sort());
    });

    test('⑤ 링크 = 라우트 상수(근거 링크만 · 상세 링크 0)', () {
      for (final Map<String, Object?> r in _rows()) {
        final AlertItem a = AlertItem.fromJson(r);
        expect(AppRoutes.all, contains(a.deepLink), reason: a.code);
        expect(a.detailDeepLink, isNull, reason: a.code);
      }
    });

    test('⑥ alert_code 사전 도메인에 다섯 다 있다(C-5)', () {
      for (final String c in _engineLevel.keys) {
        expect(
          ContractCodes.isRegisteredIn('alert_code', c),
          isTrue,
          reason: c,
        );
      }
    });
  });
}
