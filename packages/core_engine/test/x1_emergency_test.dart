// 🆕 E16t3c(R244) — X1-3 비상 앞쪽 복원 전 기록 재료(01 §8 미결 218 ⓒ ⓓ · 06 X1-3).
//
// 🔵 잡는 것: ① 판 이름 꼴 `rec-{한국 날}-{순번}` ② 재발급 적용 = KIS(늘) + 감시 핑 키 + Supabase 로그인(이 앱이 쥐는 것만)
//    ③ 저장 차례로 다시 세우기 = 받음 · 남음 · 끝 ④ 어긋난 기록(같은 항목 둘 · 해당 없음 · 지문 꼴) = FormatException(저널 깨짐).
import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

void main() {
  final DateTime at = DateTime.utc(2026, 11, 21, 15, 30); // 한국 11-22 00:30

  test('판 이름 = 한국 날 · 순번 1 이상', () {
    expect(x1EmergencyRunIdOf(at, 1), 'rec-2026-11-22-1');
    expect(() => x1EmergencyRunIdOf(at, 0), throwsArgumentError);
  });

  test('🔴 적용 = KIS 늘 + 감시 핑 키 + Supabase 로그인 · 나머지 = 해당 없음', () {
    final ReissueChecklist c = reissueChecklistOf(const <X1ReissueRecord>[]);
    expect(c.applicable, <ReissueItem>{
      ReissueItem.kisAppKey,
      ReissueItem.watchdogPingKey,
      ReissueItem.supabaseSession,
    });
    expect(c.notApplicable, <ReissueItem>[
      ReissueItem.messengerToken,
      ReissueItem.githubPat,
      ReissueItem.googleAccess,
    ]);
    expect(kX1ReissueUsedServices.contains(ReissueItem.kisAppKey), isFalse);
  });

  test('저장 차례로 다시 세운다 · 셋 다 받으면 끝', () {
    final ReissueChecklist one = reissueChecklistOf(<X1ReissueRecord>[
      X1ReissueRecord(
        item: ReissueItem.kisAppKey,
        fingerprint: '0123abcd',
        atUtc: at,
      ),
    ]);
    expect(one.entries.keys, <ReissueItem>[ReissueItem.kisAppKey]);
    expect(one.entries[ReissueItem.kisAppKey]!.fingerprint, '0123abcd');
    expect(one.remaining, <ReissueItem>[
      ReissueItem.watchdogPingKey,
      ReissueItem.supabaseSession,
    ]);
    final ReissueChecklist all = reissueChecklistOf(<X1ReissueRecord>[
      X1ReissueRecord(
        item: ReissueItem.supabaseSession,
        fingerprint: null,
        atUtc: at,
      ),
      X1ReissueRecord(
        item: ReissueItem.kisAppKey,
        fingerprint: '0123abcd',
        atUtc: at,
      ),
      X1ReissueRecord(
        item: ReissueItem.watchdogPingKey,
        fingerprint: '9999ffff',
        atUtc: at,
      ),
    ]);
    expect(all.complete, isTrue);
  });

  test('🔴 어긋난 기록 = FormatException', () {
    for (final List<X1ReissueRecord> bad in <List<X1ReissueRecord>>[
      <X1ReissueRecord>[
        X1ReissueRecord(
          item: ReissueItem.kisAppKey,
          fingerprint: '0123abcd',
          atUtc: at,
        ),
        X1ReissueRecord(
          item: ReissueItem.kisAppKey,
          fingerprint: '0123abce',
          atUtc: at,
        ),
      ],
      <X1ReissueRecord>[
        X1ReissueRecord(
          item: ReissueItem.githubPat,
          fingerprint: '0123abcd',
          atUtc: at,
        ),
      ],
      <X1ReissueRecord>[
        X1ReissueRecord(
          item: ReissueItem.kisAppKey,
          fingerprint: 'XYZ',
          atUtc: at,
        ),
      ],
    ]) {
      expect(() => reissueChecklistOf(bad), throwsFormatException);
    }
  });
}
