// 🔴 부호 있는 체결 칸(SQL · 설계 13 §8 R128 K2 · R121 F6).
//
// 저장은 늘 양수(`executions.quantity CHECK > 0`) · `fill_kind` 가 부호를 정한다 — REVERSAL = 음수.
// 체결을 합하거나 현금으로 셈하는 곳은 이 칸을 읽는다(그냥 `quantity` 를 읽으면 정정이 수량을 늘린다).

/// [alias] 표의 [column] 을 부호 있게 읽는 SQL 식.
String signedFillSql(String alias, String column) =>
    "CASE $alias.fill_kind WHEN 'REVERSAL' THEN -$alias.$column "
    'ELSE $alias.$column END';
