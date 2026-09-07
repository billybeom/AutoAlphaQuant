import 'package:test/test.dart';

// 자리표시 테스트 — 구현체가 아직 없어서 «패키지가 테스트 러너에 잡힌다»
// 까지만 확인한다.
//
// 실제 테스트는 두 리포지토리 구현체가 같은 픽스처에서 **같은 필드값**을
// 내는지(계약 3조 ①)와 명령 append-only(C-16)이며, 그것이 들어오면 지운다.
void main() {
  test('data_sync 골격이 존재한다 (자리표시)', () {
    expect(true, isTrue);
  });
}
