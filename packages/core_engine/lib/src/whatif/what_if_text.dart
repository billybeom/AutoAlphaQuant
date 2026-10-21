// M3-1 표시 글자 — 화면이 그대로 그리는 금액·가격·수량·날짜 글자(01 §14-4 · C-38 ⑩ «화면은 원값을 포맷하지 않는다»).
//
// 🔵 꼴은 계약 픽스처(`fixtures/m7/m7_deposit_plan_*.json` · `m7_rebalance_preview_*.json`)를 따른다 — 설계 13 §8 R18 D-6:
//    금액 = 억·만 단위 + 천 단위 자투리(«10만원» · «4만 2천원» · «6천원» · «1,800만원») · 천 단위가 아니면 쉼표(«4만 2,350원»)
//    가격 = 쉼표 꼴(«19,150원») · 수량 «2주» · 날짜 «2026년 9월 1일».
// 🔴 원 미만 금액은 글자로 만들지 않는다 — 원 단위 정수만 받는다(어긋나면 엔진 버그다).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' show TradeDate;

final BigInt _eok = BigInt.from(100000000);
final BigInt _man = BigInt.from(10000);
final BigInt _thousand = BigInt.from(1000);

/// 금액 글자(만·천 꼴) — «10만원» · «4만 2천원» · «6천원» · «1,800만원» · «4만 2,350원» · «1억원» · «0원».
String wonText(Decimal amount) {
  final BigInt n = _wholeWon(amount, 'amount');
  final BigInt eok = n ~/ _eok;
  final BigInt man = (n % _eok) ~/ _man;
  final BigInt rest = n % _man;
  final List<String> parts = <String>[
    if (eok > BigInt.zero) '${_grouped(eok)}억',
    if (man > BigInt.zero) '${_grouped(man)}만',
    if (rest > BigInt.zero)
      rest % _thousand == BigInt.zero
          ? '${rest ~/ _thousand}천'
          : _grouped(rest),
  ];
  return parts.isEmpty ? '0원' : '${parts.join(' ')}원';
}

/// 가격·작은 금액 글자(쉼표 꼴) — «19,150원» · «128원».
String commaWonText(Decimal amount) =>
    '${_grouped(_wholeWon(amount, 'amount'))}원';

/// 수량 글자 — «2주».
String sharesText(int quantity) {
  if (quantity < 0) {
    throw ArgumentError.value(quantity, 'quantity', '수량은 0 이상이어야 한다');
  }
  return '$quantity주';
}

/// 날짜 글자 — «2026년 9월 1일».
String koreanDateText(TradeDate d) {
  final DateTime t = _parse(d);
  return '${t.year}년 ${t.month}월 ${t.day}일';
}

/// [d] 부터 그 해 12월 31일까지 남은 달력일(12월 31일 = 0). 연금 납입 마감 문장의 날 수.
int daysToYearEnd(TradeDate d) {
  final DateTime t = _parse(d);
  return DateTime.utc(t.year, 12, 31).difference(t).inDays;
}

BigInt _wholeWon(Decimal amount, String name) {
  if (amount < Decimal.zero) {
    throw ArgumentError.value(amount, name, '금액은 0 이상이어야 한다');
  }
  if (!amount.isInteger) {
    throw ArgumentError.value(amount, name, '원 미만 금액은 글자로 만들지 않는다');
  }
  return amount.toBigInt();
}

String _grouped(BigInt n) {
  final String s = n.toString();
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}

DateTime _parse(TradeDate d) {
  final DateTime? t = DateTime.tryParse('${d.yyyyMmDd}T00:00:00Z');
  if (t == null || d.yyyyMmDd.length != 10) {
    throw ArgumentError.value(d.yyyyMmDd, 'tradeDate', 'YYYY-MM-DD 이어야 한다');
  }
  return t;
}
