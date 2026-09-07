import 'package:test/test.dart';

// 자리표시 테스트 — 게이트웨이 코드가 아직 없어서 «패키지가 테스트 러너에
// 잡힌다»까지만 확인한다.
//
// 실제 테스트는 lib/src/fake_broker/의 시나리오로 주문 경로를 돌리는 것이며,
// 그것이 들어오면 이 파일은 지운다.
void main() {
  test('broker_gateway 골격이 존재한다 (자리표시)', () {
    expect(true, isTrue);
  });
}
