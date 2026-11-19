// GV-12 거래일 판정 · GV-12c 월 마지막 세션 음성 케이스(05 §GV-12 · AC-B12 중 12·12c) · 03 §4-3.
//
// 정답지 = 05 v1.22 본문 블록 원문 · 세션 데이터 = exchange_calendars 4.13.2 동결 표(vectors/SOURCES.md).
// 🔴 MIC(XKRX·XNYS) → market(KR·US) 변환은 01 §1 `MIC` 상수 그대로(05 §GV-12 v1.5).
// 🔵 GV-12b(미국 주문의 ET 거래일)는 P0S 에 미국 주문이 없어 보류(설계 13 §7 P-2).
// 🔴 한 정본(E11o-b · 설계 13 §8 R163) — 판정은 엔진 lib `Gv12Calendar` 에 있고 폰도 같은 케이스를 돈다.

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

import 'golden_vectors.dart';

void main() {
  runFamily(const Gv12Calendar());

  // 원천 세션 표(vectors/sessions_x*.json)의 출처 확인 — 폰은 lib 동결 달력을 쓰므로 시험에만 남는다.
  test('세션 표의 머리말이 생성기·버전·건수를 밝힌다', () {
    for (final Market m in Market.values) {
      final Map<String, Object?> meta = asObject(
        loadVector('sessions_${m.mic.toLowerCase()}.json')['meta'],
      );
      expect(meta['calendar'], m.mic);
      expect(asString(meta['source']), startsWith('exchange_calendars '));
      expect(
        asInt(meta['count']),
        asStringList(
          loadVector('sessions_${m.mic.toLowerCase()}.json')['sessions'],
        ).length,
      );
    }
  });
}
