// E11q-q5c — M7 S7-3 드로다운 · TUW 맥락 VM(설계 13 §8 R226 · 03 §7 · 표본 `m7/m7_dd_context_*`).
//
// 🔴 `deep` 표본 = 원장 값을 맞춰 넣으면 참조 구간 두 줄(엔진 원천 0 → null)만 빼고 DTO 째로 같다 · `normal` 표본 = 글자 셋 ·
//    기간 · 기준이 같다(게이지 = 현재 ÷ 최대 — 표본 0.21 은 다른 눈금) · 셈 = 월간 리포트 C1 · C2 와 같은 규칙.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _fx = '../domain_contracts/fixtures/m7';

DrawdownContextVm _fixture(String file) => DrawdownContextVm.fromJson(
  ((jsonDecode(File('$_fx/$file').readAsStringSync())
                  as Map<String, Object?>)['rows']!
              as List<Object?>)
          .first!
      as Map<String, Object?>,
);

final DateTime _now = DateTime.utc(2026, 8, 31, 9);

bool _weekday(String ymd) =>
    DateTime.parse('${ymd}T00:00:00Z').weekday <= DateTime.friday;

DrawdownContextVm _vm(
  List<EquityPoint> eq, {
  bool Function(String)? isSession,
  bool integrity = false,
}) => drawdownContextVmOf(
  equity: eq,
  isSession:
      isSession ?? (String d) => eq.any((EquityPoint p) => p.date == d), // 결측 0
  nowUtc: _now,
  integrityHidden: integrity,
);

void main() {
  group('표본', () {
    test('깊은 낙폭(deep) — 고점 뒤 11개월째 물속 · 참조 구간만 null(엔진 원천 0)', () {
      final DrawdownContextVm want = _fixture('m7_dd_context_deep.json');
      expect(
        _vm(const <EquityPoint>[
          EquityPoint('2024-09-30', 0.90),
          EquityPoint('2025-03-31', 0.95),
          EquityPoint('2025-09-30', 1.00),
          EquityPoint('2026-03-31', 0.842),
          EquityPoint('2026-08-31', 0.869),
        ]),
        want.copyWith(referenceBandText: null, referenceBandCaveatText: null),
      );
    });

    test('보통(normal) — 글자 셋 · 기간 · 기준 = 표본 · 게이지 = 현재 ÷ 최대(0.33)', () {
      final DrawdownContextVm want = _fixture('m7_dd_context_normal.json');
      final DrawdownContextVm got = _vm(const <EquityPoint>[
        EquityPoint('2024-09-30', 1.00),
        EquityPoint('2025-01-31', 1.00),
        EquityPoint('2025-02-28', 0.936),
        EquityPoint('2025-05-05', 1.01),
        EquityPoint('2026-07-31', 1.10),
        EquityPoint('2026-08-31', 1.0769),
      ]);
      expect(
        got.copyWith(ddNormalized: want.ddNormalized),
        want.copyWith(referenceBandText: null, referenceBandCaveatText: null),
      );
      expect(got.ddNormalized, 0.33);
    });
  });

  group('셈', () {
    test('입출금은 낙폭이 아니다 — 출금 날 평가액이 줄어도 0', () {
      final DrawdownContextVm v = _vm(const <EquityPoint>[
        EquityPoint('2026-08-03', 100),
        EquityPoint('2026-08-04', 50, flow: -50),
        EquityPoint('2026-08-05', 50),
      ]);
      expect(v.currentDdText, '현재 낙폭 0.0%');
      expect(v.maxDdText, '최대 낙폭 0.0%');
      expect(v.tuwText, DrawdownContextTexts.tuw(0));
      expect(v.ddNormalized, 0);
    });

    test('회복하면 현재 0 · 최장 = 고점 → 회복 날 · 1개월 미만', () {
      final DrawdownContextVm v = _vm(const <EquityPoint>[
        EquityPoint('2026-08-03', 100),
        EquityPoint('2026-08-04', 95),
        EquityPoint('2026-08-10', 101),
      ]);
      expect(v.currentDdText, '현재 낙폭 0.0%');
      expect(v.maxDdText, '최대 낙폭 −5.0%');
      expect(v.tuwText, '회복까지 걸린 최장 기간 1개월 미만');
      expect(v.ddNormalized, 0);
      expect(v.periodLabel, '최근 1개월');
    });

    test('두 번 빠지면 더 긴 쪽 · 진행 중 = 마지막 점까지', () {
      final DrawdownContextVm v = _vm(const <EquityPoint>[
        EquityPoint('2026-01-02', 100),
        EquityPoint('2026-01-20', 90),
        EquityPoint('2026-03-10', 100.5), // 67일
        EquityPoint('2026-04-01', 99),
        EquityPoint('2026-08-31', 99.5), // 174일 진행 중
      ]);
      expect(v.tuwText, '회복까지 걸린 최장 기간 5개월');
      expect(v.currentDdText, '현재 낙폭 −1.0%');
      expect(v.maxDdText, '최대 낙폭 −10.0%');
      expect(v.ddNormalized, 0.1);
      expect(v.periodLabel, '최근 8개월');
    });

    test('🆕 결측 세션 = 있는 스냅숏으로 잇고 최대 낙폭 문장에 고지 · 기준 = 마지막 스냅숏 날', () {
      final DrawdownContextVm v = _vm(const <EquityPoint>[
        EquityPoint('2026-08-03', 100),
        EquityPoint('2026-08-04', 97),
        EquityPoint('2026-08-07', 99), // 05 · 06 결측
      ], isSession: _weekday);
      expect(v.maxDdText, '최대 낙폭 −3.0% (결측 2거래일 제외)');
      expect(v.asOf.label, '드로다운 기준 2026-08-07');
      expect(v.asOf.tradeDate, TradeDate('2026-08-07'));
      expect(v.asOf.observedAt, _now);
    });
  });

  group('실패(빈 상태 칸 없음 — 미결 44)', () {
    test('무결성 점검 중 · 스냅숏 0 = 상태 오류 · 날짜 순 아님 = 인자 오류', () {
      expect(
        () => _vm(const <EquityPoint>[
          EquityPoint('2026-08-03', 1),
        ], integrity: true),
        throwsStateError,
      );
      expect(() => _vm(const <EquityPoint>[]), throwsStateError);
      expect(
        () => _vm(const <EquityPoint>[
          EquityPoint('2026-08-04', 1),
          EquityPoint('2026-08-03', 1),
        ]),
        throwsArgumentError,
      );
    });
  });
}
