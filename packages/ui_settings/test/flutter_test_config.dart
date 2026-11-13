// flutter_test_config.dart — ui_settings 위젯 테스트 공통 설정 (C-2 위젯 골든 하네스 · M2 소유)
//
// 무엇을 하나: `flutter test` 가 이 패키지의 모든 테스트 파일 앞에서 이 파일의
//   `testExecutable` 을 먼저 부른다(Flutter 규약 — test/ 아래 같은 이름 파일 자동 탐지).
//   여기서 골든 비교기를 **이동·안티에일리어싱 허용 비교기**로 바꾼다.
//
// 왜 있나(01 §7 골든 규칙 · test/golden/README.md):
//   · 위젯 골든 PNG 는 화면 담당이 자기 PC(Windows)에서 찍고, CI 는 리눅스에서 비교한다.
//     같은 픽스처·같은 폰트라도 글자 상자 가장자리가 1px 어긋나고 그림자 AA 가 다르다.
//     2026-09-17 실측(J-1 8장): 0.74~1.44% 픽셀이 어긋났고 light/dark 가 같은 값 —
//     테마가 아니라 글자 위치 차이다. 그 차이로 게이트가 빨개지면 「스냅샷을 다시 찍자」가
//     되고, 그것이 01 §7 이 막으려는 위조의 입구다.
//   · 단순 «달라진 픽셀 비율» 허용치를 1.5% 로 올리면 칩 하나 누락(약 0.6%)을 놓친다.
//     그래서 `shift_tolerant_compare.dart` 의 «유의 픽셀»(3×3 흐림 뒤 양방향으로 이웃 어디에도
//     비슷한 색이 없는 픽셀)만 센다 — 그리고 그 «양»과 «뭉침» 둘 다로 판정한다(3판).
//   · 실측(2026-09-17 · 리눅스 CI vs Windows 골든 14장 = J-1 8 + S7-1 6):
//       플랫폼 소음  = 전체 0.004~0.177% · 가장 빽빽한 24×24 창 1.0~5.6%(6~32px) — 얇게 흩어진다
//       구조 변화    = 18px 아이콘 1개 누락: 전체 0.06% · 창 27%(153px) / 칩 1개: 1.4% · 47% /
//                      글자 줄 1개: 3.4% · 83% / 배너 1개: 15.8% · 96% — 한 곳에 뭉친다
//     전체 비율만으로는 아이콘 누락(0.06%)이 소음(0.18%)보다 작아 못 가른다. 뭉침(창 밀도)은
//     소음 최대 5.6% vs 신호 최소 27% 로 5배 벌어진다 → **창 12%** 를 주 판정으로, **전체 0.5%**
//     를 넓게 퍼진 변화(색 전체 이동 등)의 보조 판정으로 둔다.
//   · 🔵 2026-10-01 보조 기준 0.5% → **1.0%**(PR #19 R11a 리눅스 CI 실측 112장 = ui_analytics 56 +
//     ui_journal 56): 글자가 빽빽한 S7-4 화면의 흩어진 소음이 전체 0.592%(s74_pension_limit_hit
//     light · 창 5.2%)로 옛 보조 기준만 넘었다. 112장의 창 밀도는 모두 ≤5.2% — 주 기준(12%)은
//     그대로 둔다. 새 값은 소음 최대 0.592% 의 1.69배이고, 위 구조 변화 가운데 전체 비율로도
//     잡히던 것(칩 1.4% · 글자 줄 3.4% · 배너 15.8%)은 여전히 1.0% 위다(아이콘 누락은 처음부터
//     창 기준 몫). 선례 = 비교기 3판 infra PR #3(d0f6035).
//   · 🔵 2026-10-01 **P2**(같은 infra PR · 적대 검토 infra_review): 보조 기준만 1.0% 로 올리면
//     «1px 선 → 3px»(테두리·차트 격자 전부 굵어짐 — S7-2 6장 전체 0.606~0.607% · 창 51/576 8.9%)를
//     옛 판정은 잡고 새 판정은 놓친다. 전체 비율로는 소음(0.592%)과 겹쳐 못 가르고, 창이 가른다
//     (소음 ≤5.2% vs 회귀 8.9%). 그래서 **전체 0.5% 를 넘으면 창 7% 이하일 때만** 통과로 본다.
//     PR #19 CI 112장(창 ≤5.2%)은 모두 통과 · 검토가 찾은 «옛 판정만 잡던» 7건은 모두 실패.
//   · **임계는 M2 가 한 곳에서** 정한다 — 화면 담당은 이 파일을 고치지 않는다
//     (01 §7 「C-2 가 플랫폼·폰트 차이로 흔들리면 임계 조정은 M2 가 한다」).
//
// 🔴 이 파일에 한국어 «문자열 리터럴»을 두지 않는다 — 테스트라 C-5 대상은 아니지만
//    실패 메시지에 문구를 짓는 습관이 lib/ 로 옮아간다. 메시지는 ASCII 로만 쓴다.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'golden/shift_tolerant_compare.dart';

/// 유의 픽셀 **전체 비율** 상한(보조 판정). 390×844 화면(329,160px)에서 1.0% ≈ 3,292px.
/// 실측 소음 최대 0.592%(2026-10-01 · PR #19 리눅스 CI · s74_pension_limit_hit light 1,950px ·
/// 그다음 0.461%) — 2026-09-17 의 0.177% 에서 글자 빽빽한 화면이 늘며 올라왔다.
/// 옛 값 0.005(PR #3) → 0.010. 🔴 M2 만 바꾼다.
const double kGoldenSignificantDiffTolerance = 0.010;

/// 가장 빽빽한 24×24 창의 유의 픽셀 **밀도** 상한(주 판정). 12% = 69px.
/// 실측 소음 최대 5.6%(32px) · 가장 작은 구조 변화(18px 아이콘 누락) 26.6%(153px). 🔴 M2 만 바꾼다.
const double kGoldenMaxWindowDensity = 0.12;

/// P2 «엄격 구간» 시작(전체 비율). 이 값을 넘는 «양»은 창 밀도가 [kGoldenThinWindowDensity]
/// 이하일 때만 통과한다 — 옛 보조 기준 0.5%(PR #3) 를 그대로 쓴다.
/// 근거(2026-10-01 · infra_review): «1px 선 → 3px» 회귀가 전체 0.606~0.607% 로 소음 최대
/// 0.592% 와 겹친다 — 전체 비율만으로는 못 가르니 이 구간에서는 창을 본다. 🔴 M2 만 바꾼다.
const double kGoldenStrictDiffTolerance = 0.005;

/// P2 «얇게 흩어짐» 상한(창 밀도). 7% ≈ 40/576px.
/// 근거(2026-10-01 · infra_review): PR #19 리눅스 CI 112장의 창 최대 5.2%(30px · 2026-09-17 은
/// 5.6%) 와 검토가 찾은 가장 얇은 회귀(선 1→3px 창 8.9% · 51px) 사이 — 기하평균 ≈6.8% → 7%.
/// 전체가 [kGoldenStrictDiffTolerance] 를 넘는 장에만 걸린다(112장 가운데 1장). 🔴 M2 만 바꾼다.
const double kGoldenThinWindowDensity = 0.07;

/// 같은 색으로 볼 채널 차(0~255). AA 회색 단계 차이는 이 안에 든다.
const int kGoldenChannelDelta = 48;

/// 이동 허용 반경(px). 1 = 3×3 이웃.
const int kGoldenShiftRadius = 1;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final GoldenFileComparator current = goldenFileComparator;
  if (current is LocalFileComparator) {
    // `flutter test` 는 테스트 파일마다 LocalFileComparator 를 미리 세워 둔다.
    // 그 basedir(테스트 파일이 있는 폴더)을 그대로 물려받는다 — 골든 경로는
    // 테스트 파일 기준 상대 경로(`goldens/<name>.png`)로 풀린다.
    goldenFileComparator = ShiftTolerantGoldenFileComparator(
      current.basedir.resolve('_placeholder_test.dart'),
      tolerance: kGoldenSignificantDiffTolerance,
      maxWindowDensity: kGoldenMaxWindowDensity,
      strictTolerance: kGoldenStrictDiffTolerance,
      thinWindowDensity: kGoldenThinWindowDensity,
      channelDelta: kGoldenChannelDelta,
      radius: kGoldenShiftRadius,
    );
  }
  await testMain();
}

/// 1px 이동·AA 차이는 무시하고 «유의 픽셀»의 전체 비율이 [tolerance] 이하 **그리고** 가장
/// 빽빽한 창의 밀도가 [maxWindowDensity] 이하 **그리고** 전체가 [strictTolerance] 를 넘으면 창이
/// [thinWindowDensity] 이하일 때(P2) 통과로 보는 비교기 — 판정은 `acceptsSignificantDiff` 하나.
///
/// 바이트가 완전히 같으면 디코드 없이 바로 통과한다(같은 PC 에서 찍은 경우).
/// 실패하면 기본 비교기와 똑같이 `failures/` 폴더에 masked/isolated diff 이미지를 남긴다
/// (그 폴더는 .gitignore 에 있다).
class ShiftTolerantGoldenFileComparator extends LocalFileComparator {
  ShiftTolerantGoldenFileComparator(
    super.testFile, {
    required this.tolerance,
    required this.maxWindowDensity,
    required this.strictTolerance,
    required this.thinWindowDensity,
    required this.channelDelta,
    required this.radius,
  });

  /// 0.0 ~ 1.0 — 유의 픽셀 전체 비율의 상한(보조 판정).
  final double tolerance;

  /// 0.0 ~ 1.0 — 가장 빽빽한 창의 유의 픽셀 밀도 상한(주 판정).
  final double maxWindowDensity;

  /// 0.0 ~ 1.0 — 이 전체 비율을 넘으면 창이 [thinWindowDensity] 이하여야 한다(P2).
  final double strictTolerance;

  /// 0.0 ~ 1.0 — P2 의 «얇게 흩어짐» 창 밀도 상한.
  final double thinWindowDensity;

  /// 같은 색으로 볼 채널 차.
  final int channelDelta;

  /// 이동 허용 반경.
  final int radius;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final Uint8List goldenBytes = Uint8List.fromList(
      await getGoldenBytes(golden),
    );
    final ComparisonResult exact = await GoldenFileComparator.compareLists(
      imageBytes,
      goldenBytes,
    );
    if (exact.passed) {
      return true;
    }

    final ui.Image candidate = await _decode(imageBytes);
    final ui.Image reference = await _decode(goldenBytes);
    try {
      if (candidate.width != reference.width ||
          candidate.height != reference.height) {
        final String error = await generateFailureOutput(
          exact,
          golden,
          basedir,
        );
        throw FlutterError(
          '$error\nsize mismatch: candidate ${candidate.width}x${candidate.height} '
          'vs golden ${reference.width}x${reference.height}',
        );
      }
      final Uint8List a = await _rgba(candidate);
      final Uint8List b = await _rgba(reference);
      final SignificantDiffStats stats = analyzeSignificantDiffs(
        a,
        b,
        width: candidate.width,
        height: candidate.height,
        radius: radius,
        channelDelta: channelDelta,
      );
      final int significant = stats.total;
      final double ratio = significant / (candidate.width * candidate.height);
      final String summary =
          'golden "$golden": raw diff ${(exact.diffPercent * 100).toStringAsFixed(2)}% '
          '(${exact.diffPercent > 0 ? 'nonzero' : 'zero'}), significant $significant px = '
          '${(ratio * 100).toStringAsFixed(3)}% (tolerance ${(tolerance * 100).toStringAsFixed(2)}%, '
          'radius $radius, channelDelta $channelDelta) '
          'maxWindow ${stats.maxWindowCount}/${stats.windowSize * stats.windowSize} = '
          '${(stats.maxWindowDensity * 100).toStringAsFixed(1)}% '
          '(limit ${(maxWindowDensity * 100).toStringAsFixed(0)}%; '
          'above ${(strictTolerance * 100).toStringAsFixed(2)}% total only if '
          '<= ${(thinWindowDensity * 100).toStringAsFixed(0)}%)';
      if (acceptsSignificantDiff(
        stats,
        width: candidate.width,
        height: candidate.height,
        tolerance: tolerance,
        maxWindowDensity: maxWindowDensity,
        strictTolerance: strictTolerance,
        thinWindowDensity: thinWindowDensity,
      )) {
        debugPrint('$summary -> accepted');
        return true;
      }
      final String error = await generateFailureOutput(exact, golden, basedir);
      throw FlutterError('$error\n$summary -> rejected');
    } finally {
      candidate.dispose();
      reference.dispose();
    }
  }

  static Future<ui.Image> _decode(Uint8List png) {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromList(png, completer.complete);
    return completer.future;
  }

  static Future<Uint8List> _rgba(ui.Image image) async {
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (data == null) {
      throw StateError('toByteData returned null');
    }
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
