// C-11 as-of 신선도 — 01 §7 표 C-11 · §1-3 · 인벤토리 §9(🟡 배너 · 🟢 계약 층).
//
// 정의: 「`staleAfter` 초과 픽스처에서 배너가 뜨는지」.
// 잡는 것: **오래된 데이터 무고지**.
//
// 🔴 화면이 현재 시각을 쓰는 자리는 전 앱에서 **하나**다 —
//    `observedAt + staleAfter < clock.nowUtc()`(01 §1-3). 그 하나를 여기서
//    주입 시계로 재현한다. `DateTime.now()` 는 테스트에서도 부르지 않는다 —
//    시계를 부르는 순간 「어제는 통과하고 오늘은 실패하는」 검사가 된다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// 01 §1-3 — 주입 시계. 구현체는 `data_sync` 이고 여기서는 고정값이다.
class _FixedClock implements Clock {
  const _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime nowUtc() => _now;
}

/// 🔴 전 앱에서 화면이 현재 시각을 쓰는 **유일한** 식(01 §1-3).
bool _isStale(AsOf asOf, Clock clock) =>
    asOf.observedAt.add(asOf.staleAfter).isBefore(clock.nowUtc());

void main() {
  group('C-11 as-of 신선도 (01 §7 · §1-3)', () {
    test('C-11 모든 픽스처의 as_of 가 신선도 판정에 필요한 값을 싣는다', () {
      for (final String path in FixturePaths.all) {
        final AsOf asOf = AsOf.fromJson(decodeEnvelope(readFixture(path)).asOf);
        expect(
          asOf.observedAt.isUtc,
          isTrue,
          reason: '$path — observedAt 은 항상 UTC 다(01 §1-3).',
        );
        expect(asOf.staleAfter.inSeconds, greaterThan(0), reason: path);
        expect(asOf.label, isNotEmpty, reason: '$path — 기준일 고지는 엔진 생성 문구다.');
        expect(
          asOf.tradeDate.yyyyMmDd,
          matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
          reason: '$path — 거래일은 현지 거래일 문자열이다(KST 환산 금지).',
        );
      }
    });

    test('C-11 stale 픽스처는 사유 코드와 배너 문구를 함께 싣는다', () {
      final AsOf stale = AsOf.fromJson(
        decodeEnvelope(readFixture(FixturePaths.m6FillFormSpecStale)).asOf,
      );
      expect(
        stale.staleReasonCode,
        isNotNull,
        reason:
            '무엇이 왜 stale 인지는 엔진 몫이다(01 §1-3) — 화면이 코드→문구 매핑을 '
            '만들지 않도록 문구까지 함께 온다.',
      );
      expect(stale.staleLabel, isNotEmpty);
      expect(
        ContractCodes.isRegisteredIn('stale_reason', stale.staleReasonCode!),
        isTrue,
        reason: '⏸ 값 목록은 엔진(M1) 확정 대기지만, 그동안에도 사전 밖 코드는 막는다.',
      );

      // 대비 — 신선한 같은 화면의 픽스처에는 사유가 없다.
      final AsOf fresh = AsOf.fromJson(
        decodeEnvelope(readFixture(FixturePaths.m6FillFormSpec)).asOf,
      );
      expect(fresh.staleReasonCode, isNull);
      expect(fresh.staleLabel, isNull);
    });

    test('C-11 신선도 판정은 observedAt + staleAfter 를 넘겼는지 하나로 갈린다', () {
      final AsOf asOf = AsOf.fromJson(
        decodeEnvelope(readFixture(FixturePaths.m6FillFormSpecStale)).asOf,
      );
      final DateTime boundary = asOf.observedAt.add(asOf.staleAfter);

      expect(
        _isStale(asOf, _FixedClock(asOf.observedAt)),
        isFalse,
        reason: '관측 시각에는 신선하다.',
      );
      expect(
        _isStale(asOf, _FixedClock(boundary)),
        isFalse,
        reason: '🔴 경계는 «초과»다 — 같은 시각은 아직 stale 이 아니다(01 §1-3 부등호).',
      );
      expect(
        _isStale(asOf, _FixedClock(boundary.add(const Duration(seconds: 1)))),
        isTrue,
      );
    });

    test('C-11 표시 시각은 TzInstant 로만 온다(기본 tzName = Asia/Seoul)', () {
      // 🔴 UTC DateTime 필드는 정렬·비교용이고, 화면이 포맷하는 자리는 TzInstant 뿐이다.
      final TzInstant instant = TzInstant.fromJson(<String, dynamic>{
        'utc': '2026-08-31T00:12:00.000Z',
      });
      expect(
        instant.tzName,
        'Asia/Seoul',
        reason: '화면은 tzName 으로만 포맷한다(01 §1-3).',
      );
      expect(instant.utc.isUtc, isTrue);
    });

    test(
      'C-11 staleAfter 초과 픽스처에서 신선도 배너가 뜨는지(렌더)',
      () {},
      skip:
          '배너 위젯이 아직 없다. 계약 층(위 4건)은 «판정에 필요한 값이 다 오고 판정식이 '
          '하나»까지를 고정한다 — 배너가 실제로 떴는지는 위젯 골든(C-2)의 몫이다.',
    );
  });
}
