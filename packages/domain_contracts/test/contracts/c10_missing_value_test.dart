// C-10 결측·null 렌더 — 01 §7 표 C-10 · 인벤토리 §9(🟡 화면 · 🟢 뷰모델 층).
//
// 정의: 「`PerfPoint.value == null` 구간이 보간되지 않고 공백인지」.
// 잡는 것: **결측 은폐**.
//
// 🟢 뷰모델 층에서 지금 고정할 수 있는 것: ① 결측이 `null` 로 실려 오고(0 이나 앞값이
//    아니라) ② 그 자리에 **사유 코드**가 함께 오며 ③ 같은 구간이 `PerfSegment` 의
//    `UNAVAILABLE` 로도 표시된다 — 셋이 다 있어야 화면이 「선을 잇지 않을」 근거를 갖는다.
// 🟡 「선을 잇지 않았다」 자체는 렌더 결과라 위젯 골든(C-2)의 몫이다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

void main() {
  group('C-10 결측·null (01 §7)', () {
    test('C-10 월간 성과에 결측이 null 로 실려 있고 0 으로 메워지지 않았다', () {
      final List<PerformanceSeries> series = _series(
        FixturePaths.performance24m,
      );
      expect(series, hasLength(2), reason: 'TWR·MWR 두 계열이다(인벤토리 §8-2).');

      for (final PerformanceSeries s in series) {
        final List<PerfPoint> gaps = s.points
            .where((PerfPoint p) => p.value == null)
            .toList();
        expect(
          gaps,
          hasLength(1),
          reason: '${s.metric} — 결측 구간 1 이 픽스처의 계약이다(인벤토리 §8-2).',
        );
        expect(
          gaps.single.value,
          isNull,
          reason: '🔴 결측을 0 으로 바꾸면 「손실 0%」로 읽힌다 — 은폐다.',
        );
        expect(
          gaps.single.gapReasonCode,
          isNotNull,
          reason: '결측에는 사유 코드가 함께 온다(01 §3 · GapReasonCodes).',
        );
        expect(
          ContractCodes.isRegisteredIn(
            'gap_reason_code',
            gaps.single.gapReasonCode!,
          ),
          isTrue,
        );
      }
    });

    test('C-10 결측 점의 날짜는 UNAVAILABLE 구간 안에 있다', () {
      for (final String path in <String>[
        FixturePaths.performance24m,
        FixturePaths.m7M7PerfDailyGap,
      ]) {
        for (final PerformanceSeries s in _series(path)) {
          final List<PerfSegment> unavailable = s.segments
              .where((PerfSegment seg) => seg.kind == SegmentKind.unavailable)
              .toList();
          expect(
            unavailable,
            isNotEmpty,
            reason:
                '$path — 결측이 있는데 UNAVAILABLE 구간이 없다. 화면은 구간으로 '
                '공백을 그리므로 둘이 짝이 아니면 선이 이어진다.',
          );

          for (final PerfPoint p in s.points.where(
            (PerfPoint p) => p.value == null,
          )) {
            final bool covered = unavailable.any(
              (PerfSegment seg) =>
                  seg.from.yyyyMmDd.compareTo(p.date.yyyyMmDd) <= 0 &&
                  seg.to.yyyyMmDd.compareTo(p.date.yyyyMmDd) >= 0,
            );
            expect(
              covered,
              isTrue,
              reason:
                  '$path — 결측 점 ${p.date.yyyyMmDd} 를 덮는 UNAVAILABLE 구간이 없다.',
            );
          }
        }
      }
    });

    test('C-10 측정 구간에는 결측이 없다(구간 표시와 점이 어긋나지 않는다)', () {
      for (final PerformanceSeries s in _series(
        FixturePaths.m7M7PerfDailyGap,
      )) {
        for (final PerfSegment seg in s.segments.where(
          (PerfSegment seg) => seg.kind == SegmentKind.measured,
        )) {
          final Iterable<PerfPoint> inside = s.points.where(
            (PerfPoint p) =>
                seg.from.yyyyMmDd.compareTo(p.date.yyyyMmDd) <= 0 &&
                seg.to.yyyyMmDd.compareTo(p.date.yyyyMmDd) >= 0,
          );
          expect(
            inside.where((PerfPoint p) => p.value == null),
            isEmpty,
            reason: '측정 구간 안에 결측 점이 있다 — 구간 라벨이 사실과 다르다.',
          );
        }
      }
    });

    test('C-10 결측은 왕복해도 null 로 남는다(기본값으로 채워지지 않는다)', () {
      final PerformanceSeries s = _series(FixturePaths.performance24m).first;
      final PerformanceSeries round = PerformanceSeries.fromJson(s.toJson());
      final List<PerfPoint> before = s.points
          .where((PerfPoint p) => p.value == null)
          .toList();
      final List<PerfPoint> after = round.points
          .where((PerfPoint p) => p.value == null)
          .toList();
      expect(after.length, before.length);
      expect(after.single.gapReasonCode, before.single.gapReasonCode);
    });

    test(
      'C-10 화면이 결측 구간을 보간하지 않고 공백으로 그리는지',
      () {},
      skip:
          '차트 위젯이 아직 없다. 뷰모델 층(위 4건)은 «결측이 null 로, 사유와 함께, '
          'UNAVAILABLE 구간과 짝지어 온다»까지를 고정한다 — 실제로 선을 잇지 않았는지는 '
          '위젯 골든(C-2)이 본다.',
    );
  });
}

List<PerformanceSeries> _series(String path) =>
    decodeEnvelope(readFixture(path)).rows
        .map(PerformanceSeries.fromJson)
        .toList();
