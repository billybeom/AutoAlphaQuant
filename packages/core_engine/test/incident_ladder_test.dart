// E13e2 — MANUAL_ORDER SEV2 · postmortem 판정 · 사다리 원천(설계 13 §8 R63 V1~V4).
//
// 🔵 잡는 것: ① 04 §3-5 ④ — MANUAL_ORDER 해제 = 해제와 함께 SEV2(7일) 건을 원장에 넘김 · 다른 원인 = 0 · 결과 기한 = 그 건
//    ② postmortem 거부 차례 · 한 번만 · 공백만 있던 칸은 빈칸 ③ SEV1 은 postmortem 이 닫지 않는다 ④ 기한 넘김(엄격 · 빈칸만)
//    ⑤ 사다리 = P0S 문장 그대로(«사전 정의값 그대로») · 지금 단 · 새틀 있음 · 설정을 바꾸면 문장이 바뀐다 · % 글자.
import 'package:core_engine/core_engine.dart';
import 'package:core_engine/testing.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

final DateTime _t0 = DateTime.utc(2026, 11, 4, 16); // 한국 11-05 01:00

void main() {
  group('MANUAL_ORDER SEV2(R63 V1)', () {
    test('건 꼴 — id = 저널 · SEV2 · 분류 · 설명(한국 날짜 · 금액 0) · 기한 7일', () {
      final SafetyIncident i = manualOrderIncidentOf(
        decisionId: 'dj-1',
        clearedAtUtc: _t0,
      );
      expect(
        (i.incidentId, i.severity, i.category, i.occurredAtUtc, i.dueAtUtc),
        (
          'SEV2-MANUAL_ORDER-dj-1',
          'SEV2',
          'MANUAL_ORDER',
          _t0,
          _t0.add(const Duration(days: 7)),
        ),
      );
      expect(i.description, startsWith('2026-11-05 대사 해제 — 원인 MANUAL_ORDER'));
      expect(i.description, contains('저널 dj-1'));
      expect(kManualOrderPostmortemDue, const Duration(days: 7));
    });

    FakeOrderLedger ledger() => FakeOrderLedger()
      ..reconClearJournals.add('dj-1')
      ..flags.add(FlagIds.reconMismatch);

    test('🔴 clearRecon(MANUAL_ORDER) = 해제와 함께 SEV2 건 · 결과 기한 = 그 건', () async {
      final FakeOrderLedger l = ledger();
      final ReconClearOutcome o = await clearRecon(
        l,
        originCode: OriginCodes.manualOrder,
        decisionId: 'dj-1',
        clearedBy: 'app',
        nowUtc: _t0,
      );
      final SafetyIncident i = l.clearances.single.incident!;
      expect(
        (i.incidentId, i.dueAtUtc),
        ('SEV2-MANUAL_ORDER-dj-1', _t0.add(const Duration(days: 7))),
      );
      expect(o.postmortemDueUtc, i.dueAtUtc);
    });

    test('다른 원인 = 건 0 · 기한 없음', () async {
      for (final String code in <String>[
        OriginCodes.fillLag,
        OriginCodes.dbError,
        OriginCodes.advisoryFill,
      ]) {
        final FakeOrderLedger l = ledger();
        final ReconClearOutcome o = await clearRecon(
          l,
          originCode: code,
          decisionId: 'dj-1',
          clearedBy: 'app',
          nowUtc: _t0,
        );
        expect(
          (l.clearances.single.incident, o.postmortemDueUtc),
          (null, null),
          reason: code,
        );
      }
    });
  });

  group('postmortem 판정(R63 V2 · V3)', () {
    test('거부 차례 — 없음 → 빈칸 → 이미 · 공백만 있던 칸 = 빈칸으로 본다', () {
      String? code({
        bool exists = true,
        String? existing,
        String text = '원인 정리',
      }) => postmortemRejectCode(
        incidentExists: exists,
        existingPostmortem: existing,
        text: text,
      );
      expect(code(exists: false, text: ''), 'INCIDENT_NOT_FOUND');
      expect(code(text: '  ', existing: '앞 글'), 'POSTMORTEM_BLANK');
      expect(code(existing: '앞 글'), 'POSTMORTEM_ALREADY_RECORDED');
      expect(code(existing: '   '), isNull);
      expect(code(), isNull);
    });

    test('🔴 SEV1 은 postmortem 이 닫지 않는다(결정이 닫는다) · SEV2 · SEV3 는 닫는다', () {
      expect(
        <String, bool>{
          for (final String s in <String>['SEV1', 'SEV2', 'SEV3'])
            s: postmortemClosesIncident(s),
        },
        <String, bool>{'SEV1': false, 'SEV2': true, 'SEV3': true},
      );
    });

    test('기한 넘김 = 기한 < 지금 ∧ 빈칸', () {
      bool over({DateTime? due, String? pm}) =>
          postmortemOverdue(dueAtUtc: due, postmortem: pm, nowUtc: _t0);
      expect(over(due: _t0.subtract(const Duration(seconds: 1))), isTrue);
      expect(
        over(due: _t0.subtract(const Duration(seconds: 1)), pm: ' '),
        isTrue,
      );
      expect(over(due: _t0), isFalse);
      expect(over(due: _t0.add(const Duration(days: 1))), isFalse);
      expect(
        over(due: _t0.subtract(const Duration(days: 1)), pm: '글'),
        isFalse,
      );
      expect(over(), isFalse);
    });
  });

  group('사다리(R63 V4)', () {
    List<(String, String, String, String, bool)> rows(
      List<BreakerLadderStep> l,
    ) => <(String, String, String, String, bool)>[
      for (final BreakerLadderStep s in l)
        (s.label, s.triggerText, s.releaseText, s.actionText, s.current),
    ];

    test('🔵 P0S = 사전 정의값 그대로(새틀 없음) · 지금 단 하나', () {
      expect(
        rows(breakerLadderOf(current: BreakerLevel.halted)),
        <(String, String, String, String, bool)>[
          ('정상', 'dd > -15%', '—', '정상 운용', false),
          (
            '경보',
            'dd ≤ -15%',
            'dd > -13% · 20거래일 유지',
            '알림 · 새틀라이트 신규 진입 · 증액 중단(지금은 대상 없음)',
            false,
          ),
          (
            '축소 운용',
            'dd ≤ -20%',
            'dd ≥ -12% · 방향 점수 50 이상 · 20거래일 유지',
            '새틀라이트 × 0.5(지금은 대상 없음)',
            false,
          ),
          (
            '중지',
            'dd ≤ -25%',
            'dd ≥ -15% · BULL 3일 연속 · 20거래일 유지',
            '새틀라이트 0%(지금은 대상 없음) · 슬리브 A 신규 매수 정지',
            true,
          ),
          (
            '정지',
            'dd ≤ -35%',
            '자동 해제 없음 — 20거래일 · SEV1 postmortem · 가족 합의 · 결정 A/B/C',
            '신규 주문 전면 중단 · 보유 유지 · 자동 청산 없음',
            false,
          ),
        ],
      );
      expect(
        breakerLadderOf(current: BreakerLevel.normal)
            .map((BreakerLadderStep s) => s.level),
        BreakerLevel.values,
      );
    });

    test('새틀 있음 = «대상 없음» 없음 · 설정을 바꾸면 문장이 바뀐다(리터럴 0)', () {
      expect(
        breakerLadderOf(current: BreakerLevel.normal, satelliteActive: true)
            .map((BreakerLadderStep s) => s.actionText)
            .where((String t) => t.contains('대상 없음')),
        isEmpty,
      );
      final BreakerConfig b = p0sBreakerConfig();
      final BreakerConfig other = BreakerConfig(
        alertDd: -0.12,
        reduceDd: -0.18,
        haltDd: -0.225,
        stopDd: -0.30,
        alertReleaseDd: -0.10,
        reduceReleaseDd: -0.09,
        haltReleaseDd: -0.11,
        recoverHoldBars: 15,
        haltReleaseBullStreak: 4,
        stopReleaseDd: b.stopReleaseDd,
        stopReleaseBullStreak: b.stopReleaseBullStreak,
      );
      final List<(String, String, String, String, bool)> r = rows(
        breakerLadderOf(current: BreakerLevel.stopped, config: other),
      );
      expect(
        r.map(((String, String, String, String, bool) x) => x.$2),
        <String>[
          'dd > -12%',
          'dd ≤ -12%',
          'dd ≤ -18%',
          'dd ≤ -22.5%',
          'dd ≤ -30%',
        ],
      );
      expect(r[1].$3, 'dd > -10% · 15거래일 유지');
      expect(r[2].$3, 'dd ≥ -9% · 방향 점수 50 이상 · 15거래일 유지');
      expect(r[3].$3, 'dd ≥ -11% · BULL 4일 연속 · 15거래일 유지');
      expect(r[4].$3, startsWith('자동 해제 없음 — 15거래일'));
      expect(r.last.$5, isTrue);
    });

    test('% 글자 · 방향 점수 상수', () {
      expect(
        <String>[
          for (final double v in <double>[-0.15, -0.13, -0.125, -0.35, 0])
            ladderPercent(v),
        ],
        <String>['-15%', '-13%', '-12.5%', '-35%', '0%'],
      );
      expect(kReduceReleaseDirectionScore, 50.0);
    });
  });
}
