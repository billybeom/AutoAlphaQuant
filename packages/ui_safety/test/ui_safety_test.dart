import 'package:flutter_test/flutter_test.dart';

// 자리표시 테스트 — 화면이 아직 없어서 «패키지가 테스트 러너에 잡힌다»까지만
// 확인한다.
//
// 실제 테스트는 test/golden/의 위젯 골든(C-2)이며, 특히 해제 게이트가 순차인지·
// 킬스위치 발동에 확인 대화가 붙지 않았는지를 프레임으로 고정한다.
void main() {
  test('ui_safety 골격이 존재한다 (자리표시)', () {
    expect(true, isTrue);
  });
}
