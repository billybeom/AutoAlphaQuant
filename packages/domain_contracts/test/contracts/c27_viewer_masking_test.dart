// C-27 (01 §7 · §10-7) — viewer 집행 정보 마스킹.
//
// 2라우트 렌더(`A-1`·`A-2`)는 `ui_*` 가 선행한다(인벤토리 §9 C-27 = 🟡).
// 🔴 그 앞에서 **픽스처 자체가 이미 마스킹돼 있어야** 한다 — 뷰모델에 값이 실려
//    오면 화면이 그리지 않아도 «집행 가능 정보»가 웹으로 나간 것이다(계약 3조 ① 의
//    유일한 예외 §10-7). 웹에서 읽고 바로 매매하면 그 체결은 **기록되지 않는다**(A6).
//
// 🔴 G-21 — 검사는 「숫자 리터럴 전량 금지」가 **아니다**. 「종목 코드 · 주(株) 단위
//    수량 · 원(₩) 단위 가격」 **세 패턴 0건**이며 비율 %·건수는 허용이다.
//    허용 목록을 넓히지 말고 이 세 패턴만 정규식으로 고정한다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_io_t2.dart';

/// ① 종목 코드 — 6자리 숫자 티커와 KRX 파생 코드꼴(`0085P0`).
final RegExp _symbolPattern = RegExp(
  r'(?<![0-9])[0-9]{6}(?![0-9])|[0-9]{4}[A-Z][0-9]',
);

/// ② 주(株) 단위 수량.
final RegExp _sharesPattern = RegExp(r'[0-9][0-9,]*\s*주(?![가-힣])');

/// ③ 원(₩) 단위 가격.
final RegExp _pricePattern = RegExp(r'[0-9][0-9,.]*\s*(억원|만원|원)|₩');

void main() {
  group('C-27 X7 viewer 마스킹 (01 §7 · §10-7)', () {
    late List<AdviceItem> items;

    setUp(() {
      items = fixtureRows(FixturePaths.m6AdviceViewer4)
          .map(AdviceItem.fromJson)
          .toList();
    });

    test('C-27 ① viewer 판에는 종목·방향·수량·가격이 오지 않는다 (A6)', () {
      expect(items, isNotEmpty);
      for (final AdviceItem item in items) {
        expect(item.symbol, isNull, reason: item.adviceId);
        expect(item.symbolLabel, isNull, reason: item.adviceId);
        expect(item.side, isNull, reason: item.adviceId);
        expect(item.quantity, isNull, reason: item.adviceId);
        expect(item.priceBand, isNull, reason: item.adviceId);
        // 🔴 G-22 — 0 을 채우면 「0주 기록됨」이라는 거짓이 된다.
        expect(item.recordedQuantity, isNull, reason: item.adviceId);
      }
    });

    test('C-27 ② 대신 phoneOnlyLabel 이 그 자리를 말한다', () {
      for (final AdviceItem item in items) {
        expect(
          item.phoneOnlyLabel,
          isNotNull,
          reason: '${item.adviceId} — 빈 칸만 남으면 사람은 「고장」으로 읽는다.',
        );
        expect(item.phoneOnlyLabel, isNotEmpty);
      }
    });

    test('C-27 ③ 세 패턴(종목 코드·주 수량·원 가격)이 0건이다 (G-21)', () {
      final List<({String path, String value})> strings = collectStrings(
        withoutMeta(fixtureJson(FixturePaths.m6AdviceViewer4)),
      );
      expect(strings, isNotEmpty);

      for (final ({String path, String value}) entry in strings) {
        expect(
          _symbolPattern.hasMatch(entry.value),
          isFalse,
          reason: '종목 코드 누출 — ${entry.path}: ${entry.value}',
        );
        expect(
          _sharesPattern.hasMatch(entry.value),
          isFalse,
          reason: '수량 누출 — ${entry.path}: ${entry.value}',
        );
        expect(
          _pricePattern.hasMatch(entry.value),
          isFalse,
          reason: '가격 누출 — ${entry.path}: ${entry.value}',
        );
      }
    });

    test('C-27 ④ 비율 %·건수는 허용이다 — 허용 목록을 넓히지 않는다 (G-21)', () {
      // 🔴 이 세 문자열이 걸리면 정규식이 지나치게 넓어진 것이다.
      for (final String allowed in <String>[
        '오늘 처리할 안내가 2건입니다.',
        '이행률 88%',
        '목표 대비 +1.8%p',
      ]) {
        expect(_symbolPattern.hasMatch(allowed), isFalse, reason: allowed);
        expect(_sharesPattern.hasMatch(allowed), isFalse, reason: allowed);
        expect(_pricePattern.hasMatch(allowed), isFalse, reason: allowed);
      }

      // 반대로 세 패턴은 실제 누출을 잡아야 한다 — 정규식이 죽어 있으면 ③ 은
      // 「검사하지 않는 검사」가 된다.
      expect(_symbolPattern.hasMatch('069500 KODEX 200'), isTrue);
      expect(_symbolPattern.hasMatch('0085P0'), isTrue);
      expect(_sharesPattern.hasMatch('12주 매수'), isTrue);
      expect(_pricePattern.hasMatch('38,250원'), isTrue);
      expect(_pricePattern.hasMatch('₩38,250'), isTrue);
    });

    test(
      'C-27 ⑤ advice_viewer_4 로 A-1·A-2 2라우트만 렌더',
      () {},
      skip: 'ui_m6 위젯 골든이 선행한다(인벤토리 §9 C-27 = 🟡).',
    );
  });
}
