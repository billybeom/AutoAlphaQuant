// flutter_test_config.dart — ui_journal 위젯 테스트 공통 설정 (C-2 위젯 골든 하네스 · M2 소유)
//
// 무엇을 하나: `flutter test` 가 이 패키지의 모든 테스트 파일 앞에서 이 파일의
//   `testExecutable` 을 먼저 부른다(Flutter 규약 — test/ 아래 같은 이름 파일 자동 탐지).
//   여기서 골든 비교기를 **허용 오차 비교기**로 바꾼다.
//
// 왜 있나(01 §7 골든 규칙 · test/golden/README.md):
//   · 위젯 골든 PNG 는 화면 담당이 자기 PC(Windows)에서 찍고, CI 는 리눅스에서 비교한다.
//     같은 픽스처·같은 폰트(테스트 기본 폰트)라도 플랫폼 래스터라이저의 안티에일리어싱이
//     픽셀 몇 개 차이를 낸다. 그 차이로 게이트가 빨개지면 「스냅샷을 다시 찍자」가 되고,
//     그것이 01 §7 이 막으려는 위조의 입구다.
//   · 그래서 **임계는 M2 가 한 곳에서** 정한다 — 화면 담당은 이 파일을 고치지 않는다
//     (01 §7 「C-2 가 플랫폼·폰트 차이로 흔들리면 임계 조정은 M2 가 한다」).
//
// 임계의 뜻: 전체 픽셀 중 달라진 픽셀의 비율. 0.5% = 390×844 화면에서 약 1,600 픽셀.
//   배지·칩·행 하나가 빠지면 이보다 훨씬 크게 벌어지므로 검사의 목적(사유 칩·배지 누락 탐지)은
//   그대로 살고, 글자 가장자리 AA 차이만 흡수된다.
//
// 🔴 이 파일에 한국어 «문자열 리터럴»을 두지 않는다 — 테스트라 C-5 대상은 아니지만
//    실패 메시지에 문구를 짓는 습관이 lib/ 로 옮아간다. 메시지는 ASCII 로만 쓴다.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// 허용 오차(달라진 픽셀 비율). 🔴 M2 만 바꾼다.
const double kGoldenDiffTolerance = 0.005;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final GoldenFileComparator current = goldenFileComparator;
  if (current is LocalFileComparator) {
    // `flutter test` 는 테스트 파일마다 LocalFileComparator 를 미리 세워 둔다.
    // 그 basedir(테스트 파일이 있는 폴더)을 그대로 물려받는다 — 골든 경로는
    // 테스트 파일 기준 상대 경로(`goldens/<name>.png`)로 풀린다.
    goldenFileComparator = TolerantGoldenFileComparator(
      current.basedir.resolve('_placeholder_test.dart'),
      tolerance: kGoldenDiffTolerance,
    );
  }
  await testMain();
}

/// 픽셀 차이가 [tolerance] 이하면 통과로 보는 로컬 파일 비교기.
///
/// 실패하면 기본 비교기와 똑같이 `failures/` 폴더에 masked/isolated diff 이미지를 남긴다
/// (그 폴더는 .gitignore 에 있다).
class TolerantGoldenFileComparator extends LocalFileComparator {
  TolerantGoldenFileComparator(super.testFile, {required this.tolerance});

  /// 0.0 ~ 1.0 — 달라진 픽셀 비율의 상한.
  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed) {
      return true;
    }
    if (result.diffPercent <= tolerance) {
      debugPrint(
        'golden "$golden": diff ${(result.diffPercent * 100).toStringAsFixed(3)}% '
        '<= tolerance ${(tolerance * 100).toStringAsFixed(2)}% -> accepted',
      );
      return true;
    }
    final String error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}
