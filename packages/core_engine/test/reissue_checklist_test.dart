// E16c — X1-3 비상 재발급 6종 체크리스트 · 키 재사용 거부(설계 13 §8 R119 C4~C6).
//
// 🔵 잡는 것: ① 6 항목 차례 · 값 항목 넷 · 확인 항목 둘 ② KIS 늘 필수 · 안 쓰는 서비스 = 해당 없음
//    ③ 🔴 새 지문 ∈ 옛 지문 = KEY_REUSED ④ 지문 꼴 · 확인 항목에 지문 · 두 번 · 신뢰 시각 모름 = 거부
//    ⑤ 받을수록 남은 항목 줄고 다 받으면 완료 · 불변(옛 판 그대로).
import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

final DateTime _t = DateTime.utc(2026, 12, 2, 1);
const Set<String> _prior = <String>{'aaaa1111', 'bbbb2222'};

void main() {
  test('6 항목 차례 · 글자 · 값 항목 넷 · 확인 항목 둘', () {
    expect(ReissueItem.values.map((ReissueItem i) => i.wire), <String>[
      'KIS_APP_KEY',
      'MESSENGER_TOKEN',
      'WATCHDOG_PING_KEY',
      'GITHUB_PAT',
      'SUPABASE_SESSION',
      'GOOGLE_ACCESS',
    ]);
    expect(
      ReissueItem.values.where((ReissueItem i) => !i.hasSecret),
      <ReissueItem>[ReissueItem.supabaseSession, ReissueItem.googleAccess],
    );
  });

  test('🔴 KIS 앱키 = 늘 필수 · 안 쓰는 서비스 = 해당 없음', () {
    final ReissueChecklist c = ReissueChecklist.start(<ReissueItem>{
      ReissueItem.watchdogPingKey,
      ReissueItem.supabaseSession,
    });
    expect(c.remaining, <ReissueItem>[
      ReissueItem.kisAppKey,
      ReissueItem.watchdogPingKey,
      ReissueItem.supabaseSession,
    ]);
    expect(c.notApplicable, <ReissueItem>[
      ReissueItem.messengerToken,
      ReissueItem.githubPat,
      ReissueItem.googleAccess,
    ]);
    expect(
      ReissueChecklist.start(const <ReissueItem>{}).remaining,
      <ReissueItem>[ReissueItem.kisAppKey],
    );
    final (ReissueChecklist? x, String? code) = c.accept(
      ReissueItem.googleAccess,
      fingerprint: null,
      priorFingerprints: _prior,
      trustedNowUtc: _t,
    );
    expect(x, isNull);
    expect(code, ReissueCodes.notApplicable);
  });

  test('🔴 옛 값과 같은 지문 = KEY_REUSED · 다른 지문 = 받음', () {
    final ReissueChecklist c = ReissueChecklist.start(const <ReissueItem>{});
    final (ReissueChecklist? r, String? reused) = c.accept(
      ReissueItem.kisAppKey,
      fingerprint: 'bbbb2222',
      priorFingerprints: _prior,
      trustedNowUtc: _t,
    );
    expect(r, isNull);
    expect(reused, ReissueCodes.keyReused);
    final (ReissueChecklist? ok, String? none) = c.accept(
      ReissueItem.kisAppKey,
      fingerprint: 'cccc3333',
      priorFingerprints: _prior,
      trustedNowUtc: _t,
    );
    expect(none, isNull);
    expect(ok!.complete, isTrue);
    expect(ok.entries[ReissueItem.kisAppKey]!.fingerprint, 'cccc3333');
    expect(ok.entries[ReissueItem.kisAppKey]!.atUtc, _t);
    expect(c.complete, isFalse, reason: '옛 판은 그대로');
  });

  test('지문 꼴 · 확인 항목에 지문 · 두 번 · 신뢰 시각 모름 = 거부', () {
    final ReissueChecklist c = ReissueChecklist.start(<ReissueItem>{
      ReissueItem.googleAccess,
    });
    String? code(
      ReissueChecklist on,
      ReissueItem i,
      String? fp, {
      bool unknown = false,
    }) => on
        .accept(
          i,
          fingerprint: fp,
          priorFingerprints: _prior,
          trustedNowUtc: unknown ? null : _t,
        )
        .$2;
    expect(
      code(c, ReissueItem.kisAppKey, null),
      ReissueCodes.fingerprintRequired,
    );
    expect(
      code(c, ReissueItem.kisAppKey, 'CCCC3333'),
      ReissueCodes.fingerprintRequired,
    );
    expect(
      code(c, ReissueItem.kisAppKey, 'cccc333'),
      ReissueCodes.fingerprintRequired,
    );
    expect(
      code(c, ReissueItem.googleAccess, 'cccc3333'),
      ReissueCodes.fingerprintUnexpected,
    );
    expect(
      code(c, ReissueItem.kisAppKey, 'cccc3333', unknown: true),
      ReissueCodes.trustedTimeUnknown,
    );
    final ReissueChecklist once = c
        .accept(
          ReissueItem.googleAccess,
          fingerprint: null,
          priorFingerprints: _prior,
          trustedNowUtc: _t,
        )
        .$1!;
    expect(code(once, ReissueItem.googleAccess, null), ReissueCodes.duplicate);
    expect(once.entries[ReissueItem.googleAccess]!.fingerprint, isNull);
  });

  test('받을수록 남은 항목이 줄고 다 받으면 완료', () {
    ReissueChecklist c = ReissueChecklist.start(ReissueItem.values.toSet());
    expect(c.remaining, ReissueItem.values);
    var n = 0;
    for (final ReissueItem i in ReissueItem.values) {
      expect(c.complete, isFalse);
      c = c
          .accept(
            i,
            fingerprint: i.hasSecret ? '0000000${n++}' : null,
            priorFingerprints: _prior,
            trustedNowUtc: _t,
          )
          .$1!;
    }
    expect(c.complete, isTrue);
    expect(c.remaining, isEmpty);
    expect(c.notApplicable, isEmpty);
  });
}
