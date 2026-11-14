// 🆕 E15g — 모드 표지(OS 알림 제목 접두 · 표지 글자 · 설계 13 §8 R110 AO7).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

void main() {
  test('OS 제목 접두 — 모의 왼쪽 · 안내 · 둘 다 · 실전 × 자동 매매 = 빈 글자', () {
    expect(
      alertOsTitlePrefix(RunMode.simInternal, OperatingMode.autoTrade),
      '[모의]',
    );
    expect(
      alertOsTitlePrefix(RunMode.simBroker, OperatingMode.autoTrade),
      '[모의]',
    );
    expect(alertOsTitlePrefix(RunMode.live, OperatingMode.advisory), '[안내]');
    expect(
      alertOsTitlePrefix(RunMode.simInternal, OperatingMode.advisory),
      '[모의][안내]',
    );
    expect(alertOsTitlePrefix(RunMode.live, OperatingMode.autoTrade), '');
    expect(kSimMarker, '모의투자');
    expect(kAdvisoryMarker, '투자 안내');
  });

  test('🔴 앱 안 알림 항목에는 걸지 않는다 — 사전 문구에 접두 0', () {
    for (final String code in kAlertTexts.keys) {
      expect(alertTextOf(code).title.startsWith('['), isFalse, reason: code);
    }
  });
}
