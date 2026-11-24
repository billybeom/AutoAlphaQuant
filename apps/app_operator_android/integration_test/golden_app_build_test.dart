// 🆕 리뷰 3차 G-2(01 §8 미결 237) 에뮬레이터 확인 — 실제 Kotlin `appBuild`(패키지 정보) · 골든 «지금 지문» = 벡터 묶음 + 이 설치 판.
//
// 🔴 로컬 실측용(CI 밖 — 기기가 있어야 돈다) · 키 · 계좌 0 · 바깥 망 0 · 원장 쓰기 0(준비만 · 실행 0).
// 실행: `flutter test integration_test/golden_app_build_test.dart -d emulator-5554` · 표지 `IT_237_BUILD` 줄에 판이 찍힌다.

import 'package:app_operator_android/app/operator_golden.dart';
import 'package:app_operator_android/engine/system_clock.dart';
import 'package:app_operator_android/platform/platform.dart';
import 'package:core_engine/core_engine.dart'
    show GoldenBundle, goldenRunDigestOf;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('🔴 앱 판 = «이름+코드@설치 시각»(두 번 불러도 같다) · 골든 준비 지문 = 벡터 묶음 + 앱 판 · 묶음 지문 그대로가 아니다', () async {
    final AndroidOps ops = AndroidOps();
    final String? a = await ops.appBuild();
    final String? b = await ops.appBuild();
    // ignore: avoid_print
    print('IT_237_BUILD $a');
    expect(a, matches(RegExp(r'^.+\+[1-9][0-9]*@[1-9][0-9]{9,}$')));
    expect(b, a);
    final OperatorGolden g = OperatorGolden(
      rootBundle.loadString,
      clock: const SystemClock(),
      appBuild: ops.appBuild,
    );
    final GoldenPrepared p = await g.prepare();
    expect(p.appBuild, a);
    expect(GoldenBundle(p.files).digest, p.vectorsDigest);
    expect(
      p.digest,
      goldenRunDigestOf(vectorsDigest: p.vectorsDigest, appBuild: a!),
    );
    expect(p.digest, isNot(p.vectorsDigest));
  });
}
