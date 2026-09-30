// 픽스처 계좌 별칭 — 🆕 계약 v1.4(R11 선행 · 설계 D9 ⑧ · C-38 ⑦ 의 입력).
//
// 🔴 정본은 `fixtures/README.md` «픽스처 계좌 별칭 표»다. 이 파일은 그 표를 코드로 옮긴 사본이며
//    **두 곳은 같은 커밋에서 바꾼다**(한쪽만 바꾸면 C-38 ⑦ 이 옛 집합으로 통과한다).
// 🔴 이 파일에는 테스트가 없고 판정도 하지 않는다 — 판정은 C-38 에 있다.
// 🔵 `sleeve_catalog_4.json` 은 계좌 축이 없어(sleeve·label·order 뿐) 정본이 될 수 없다(실측).
// 🔴 별칭만 싣는다 — 계좌 전체번호는 픽스처 어디에도 없다(01 §5 대원칙 · C-14).

/// 연금 계좌 별칭(슬리브 B 가 설 수 있는 계좌 · SPEC v2.23 가드).
const Set<String> kFixturePensionAccountAliases = <String>{'연금저축', 'IRP'};

/// 픽스처에 쓸 수 있는 계좌 별칭 전부(연금 계좌 + 과세 계좌 `일반`). 표 밖 별칭 = 실패(C-38 ⑦).
const Set<String> kFixtureAccountAliases = <String>{
  ...kFixturePensionAccountAliases,
  '일반',
};
