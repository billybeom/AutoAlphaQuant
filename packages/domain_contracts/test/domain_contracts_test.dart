import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

// 자리표시 테스트 — 계약 코드가 아직 없으므로 «패키지가 컴파일되고 배럴이
// 계약 버전을 노출한다»까지만 확인한다.
//
// G3에서 01 §7의 계약 회귀 테스트(C-1 뷰모델 골든 · C-8 JSON 라운드트립 ·
// C-12 열거값 전수 커버 · C-15 픽스처↔DDL 정합)가 이 파일을 대체한다.
void main() {
  test('contractVersion은 계약 확정 전까지 초안 표식을 유지한다', () {
    expect(contractVersion, '0.0.0-draft');
  });
}
