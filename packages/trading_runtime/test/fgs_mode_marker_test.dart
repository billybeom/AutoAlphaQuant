// 🆕 E15g — FGS 모드 표지(설계 13 §8 R110 AO2~AO6 · 01 :3406 «모의투자 실행 중» · 04 :379 «투자 안내 실행 중»).

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';
import 'package:trading_runtime/trading_runtime.dart';

final DateTime _recon = DateTime.utc(2026, 12, 21, 22, 5); // 07:05 KST

FgsStatus _s(
  RunMode run,
  OperatingMode op, {
  UiLevel level = UiLevel.ok,
  String? headline,
  String? p0,
}) => FgsStatus(
  level: level,
  runMode: run,
  operatingMode: op,
  headline: headline,
  lastReconAtUtc: _recon,
  nextRebalanceInSessions: 3,
  p0AlertId: p0,
);

void main() {
  test('정상 줄 — 모의 · 안내 · 모의 × 안내 · 실전 × 자동 매매(표지 0 · 바이트 그대로)', () {
    const String tail = '정상 · 마지막 대사 07:05 · 다음 리밸런싱 D-3';
    expect(
      buildFgsNotice(_s(RunMode.simInternal, OperatingMode.autoTrade)).text,
      '모의투자 실행 중 · $tail',
    );
    expect(
      buildFgsNotice(_s(RunMode.simBroker, OperatingMode.autoTrade)).text,
      '모의투자 실행 중 · $tail',
    );
    expect(
      buildFgsNotice(_s(RunMode.live, OperatingMode.advisory)).text,
      '투자 안내 실행 중 · $tail',
    );
    expect(
      buildFgsNotice(_s(RunMode.simInternal, OperatingMode.advisory)).text,
      '모의투자 · 투자 안내 실행 중 · $tail',
    );
    expect(
      buildFgsNotice(_s(RunMode.live, OperatingMode.autoTrade)).text,
      tail,
    );
  });

  test('이상 · P0 줄도 표지가 맨 앞 · P0 에 `[모의]` 를 또 붙이지 않는다 · 채널 · 링크 그대로', () {
    final FgsNotice act = buildFgsNotice(
      _s(
        RunMode.simInternal,
        OperatingMode.autoTrade,
        level: UiLevel.act,
        headline: '대사 차이 1건',
      ),
    );
    expect(act.text, '모의투자 실행 중 · 대사 차이 1건 · 마지막 대사 07:05');
    expect(act.channel, FgsChannel.opsStatus);
    final FgsNotice p0 = buildFgsNotice(
      _s(
        RunMode.simInternal,
        OperatingMode.autoTrade,
        level: UiLevel.act,
        headline: '주문 결과 불명',
        p0: 'A-1',
      ),
    );
    expect(p0.channel, FgsChannel.opsP0);
    expect(p0.text, startsWith('모의투자 실행 중 · 주문 결과 불명'));
    expect(p0.text.contains('[모의]'), isFalse);
    expect(
      buildFgsNotice(
        _s(
          RunMode.live,
          OperatingMode.autoTrade,
          level: UiLevel.act,
          headline: '주문 결과 불명',
          p0: 'A-1',
        ),
      ).text,
      '주문 결과 불명 · 마지막 대사 07:05',
    );
  });

  test('모드가 바뀌면 다시 띄운다 · «DRY_RUN» · 돈 글자 0', () {
    final FgsNotice sim = buildFgsNotice(
      _s(RunMode.simInternal, OperatingMode.autoTrade),
    );
    final FgsNotice live = buildFgsNotice(
      _s(RunMode.live, OperatingMode.autoTrade),
    );
    expect(shouldRepostFgs(sim, live), isTrue);
    expect(shouldRepostFgs(live, live), isFalse);
    for (final FgsNotice n in <FgsNotice>[sim, live]) {
      expect(n.text.contains('DRY_RUN'), isFalse);
      expect(n.text.contains('원'), isFalse);
    }
  });

  test('재료 → 상태 = 모드 · 운영 방식 그대로(정상 · 이상 둘 다)', () {
    final List<SafetyState> safety = <SafetyState>[
      for (final Map<String, dynamic> r
          in ((jsonDecode(
                    File('../domain_contracts/fixtures/safety_states.json')
                        .readAsStringSync(),
                  ) as Map<String, dynamic>)['rows']
                  as List<dynamic>)
              .cast<Map<String, dynamic>>())
        SafetyState.fromJson(r),
    ];
    for (final SafetyState st in <SafetyState>[safety.first, safety.last]) {
      final FgsStatus s = fgsStatusOf(
        FgsFacts(
          safety: st,
          runMode: RunMode.simBroker,
          operatingMode: OperatingMode.advisory,
        ),
      );
      expect(
        (s.runMode, s.operatingMode),
        (RunMode.simBroker, OperatingMode.advisory),
      );
      expect(buildFgsNotice(s).text, startsWith('모의투자 · 투자 안내 실행 중 · '));
    }
  });
}
