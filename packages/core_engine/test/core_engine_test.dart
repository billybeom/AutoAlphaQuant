import 'package:test/test.dart';

// 자리표시 테스트 — 엔진 코드가 아직 없어서 «패키지가 테스트 러너에 잡힌다»
// 까지만 확인한다. melos run test:dart가 빈 패키지를 조용히 건너뛰지 않게 하는
// 것이 목적이다.
//
// 실제 게이트는 test/golden/의 골든벡터 재현이며, 그것이 들어오면 이 파일은
// 지운다.
void main() {
  test('core_engine 골격이 존재한다 (자리표시)', () {
    expect(true, isTrue);
  });
}
