// C-26 (01 §7 · §2-11 · §10-4) — 안내 상태기계 + 전환 원자성.
//
// 전환 위저드 갈래(「냉각 중 신규 기록 → 커밋 거부 → 단계 5 복귀」 · 「커밋 직전
// 미체결 발견 → 단계 4 복귀」)와 이행 갭 분모 계상은 엔진·`ui_*` 가 선행한다
// (인벤토리 §9 C-26 = 🟡).
//
// 🔴 여기서 검사하는 것은 **파생 판정 두 개와 억제된 날의 소식**이다:
//    ① `effectiveStatus` — 만료는 UPDATE 가 아니라 **파생**이다(A4)
//    ② `openCount` — 정의가 §2-11 조문 하나뿐이고 화면이 목록 길이로 세지 않는다(G-08)
//    ③ `NO_ACTION` — 「오늘은 아무것도 하지 마십시오」는 무소식이 아니라 소식이다(G-08)
//    ④ 회수된 안내는 `REVOKED` + 등재된 사유 코드다(G-20)

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_io_t2.dart';

/// 01 §2-1 — 되살아나지 않는 상태. 🔴 X2 원칙 ①과 동형이다.
const Set<AdviceStatus> _terminal = <AdviceStatus>{
  AdviceStatus.filled,
  AdviceStatus.skipped,
  AdviceStatus.expired,
  AdviceStatus.superseded,
  AdviceStatus.revoked,
};

/// 01 §2-11 A4 — 만료의 **파생** 규칙. 저장값을 고치지 않는다.
AdviceStatus _derivedStatus(AdviceItem item) {
  if (_terminal.contains(item.status)) {
    return item.status;
  }
  final bool lapsed =
      item.validUntilDate.yyyyMmDd.compareTo(item.asOf.tradeDate.yyyyMmDd) < 0;
  return lapsed ? AdviceStatus.expired : item.status;
}

/// 01 §2-11 G-08 — `openCount` 의 정의. 🔴 여기 말고 다른 곳에 두 번째 정의를 만들지 않는다.
int _openCountOf(Iterable<AdviceItem> items) => items
    .where(
      (AdviceItem i) =>
          !i.suppressed &&
          (i.effectiveStatus == AdviceStatus.open ||
              i.effectiveStatus == AdviceStatus.partial),
    )
    .length;

/// 안내 행 + 요약을 함께 싣는 픽스처(01 §5).
const List<String> _summaryFixtures = <String>[
  FixturePaths.m6Advice12,
  FixturePaths.m6AdviceBlocked,
  FixturePaths.m6AdviceDetailOnhold,
  FixturePaths.m6AdviceDetailPartial,
  FixturePaths.m6AdviceEmpty,
  FixturePaths.m6AdviceExpiredConfirm,
  FixturePaths.m6AdviceHandoverCooling,
  FixturePaths.m6AdviceNoAction,
  FixturePaths.m6AdviceViewer4,
];

void main() {
  group('C-26 X7 안내 상태기계 (01 §7 · §2-11)', () {
    test('C-26 ① AdviceStatus 는 7값이고 종단 5값은 되살아나지 않는다', () {
      expect(AdviceStatus.values.length, 7);
      expect(
        _terminal.union(<AdviceStatus>{
          AdviceStatus.open,
          AdviceStatus.partial,
        }),
        AdviceStatus.values.toSet(),
        reason: '값이 늘었다 — 종단 여부를 01 §2-1 에서 먼저 정할 것.',
      );
    });

    test('C-26 ② effectiveStatus 는 저장값에서 파생된다 (A4)', () {
      for (final String path in _summaryFixtures) {
        for (final Map<String, Object?> row in fixtureRows(path)) {
          final AdviceItem item = AdviceItem.fromJson(row);
          expect(
            item.effectiveStatus,
            _derivedStatus(item),
            reason:
                '$path · ${item.adviceId} — 저장값 ${item.status.wire} · '
                '기한 ${item.validUntilDate.yyyyMmDd} · 기준일 ${item.asOf.tradeDate.yyyyMmDd}',
          );
        }
      }
    });

    test('C-26 ③ openCount 는 §2-11 정의 그대로다 (G-08)', () {
      for (final String path in _summaryFixtures) {
        final Map<String, Object?> envelope = fixtureJson(path);
        final Object? summaryJson = envelope['summary'];
        if (summaryJson is! Map<String, Object?>) {
          continue;
        }
        expect(
          envelope['has_more'],
          isFalse,
          reason: '$path — 행이 잘린 봉투면 요약과 대조할 수 없다.',
        );

        final AdviceInboxSummary summary = AdviceInboxSummary.fromJson(
          summaryJson,
        );
        final List<AdviceItem> items = fixtureRows(path)
            .map(AdviceItem.fromJson)
            .toList();

        expect(
          summary.openCount,
          _openCountOf(items),
          reason:
              '$path — 요약의 openCount 가 행과 어긋난다. '
              '정의 = effectiveStatus ∈ {open, partial} 이고 suppressed == false '
              '(onHold 는 센다 · suppressed 는 세지 않는다).',
        );
      }
    });

    test('C-26 ④ onHold 는 세고 suppressed 는 세지 않는다 (G-08)', () {
      final AdviceInboxSummary onHold = AdviceInboxSummary.fromJson(
        fixtureJson(FixturePaths.m6AdviceDetailOnhold)['summary']!
            as Map<String, Object?>,
      );
      final List<AdviceItem> onHoldItems = fixtureRows(
        FixturePaths.m6AdviceDetailOnhold,
      ).map(AdviceItem.fromJson).toList();

      expect(onHoldItems.any((AdviceItem i) => i.onHold), isTrue);
      expect(onHold.openCount, greaterThan(0), reason: '보류는 「없는 일」이 아니다.');
    });

    test('C-26 ⑤ NO_ACTION 은 무소식이 아니라 소식이다 (G-08)', () {
      final Map<String, Object?> envelope = fixtureJson(
        FixturePaths.m6AdviceNoAction,
      );
      final AdviceInboxSummary summary = AdviceInboxSummary.fromJson(
        envelope['summary']! as Map<String, Object?>,
      );
      final AdviceItem item = AdviceItem.fromJson(
        fixtureRows(FixturePaths.m6AdviceNoAction).single,
      );

      expect(item.kind, AdviceKind.noAction);
      expect(item.suppressed, isTrue);
      expect(item.suppressedLabel, isNotNull);
      expect(item.suppressedLabel, isNotEmpty);
      expect(item.actions, isEmpty, reason: '억제된 날에는 누를 것이 없다.');
      expect(item.symbol, isNull);
      expect(item.quantity, isNull);
      expect(item.side, isNull);
      expect(item.priceBand, isNull);

      // 🔴 C14(「openCount == 0 이면 렌더하지 않는다」)의 유일한 예외.
      expect(summary.openCount, 0);
      expect(summary.hasSuppressedNotice, isTrue);
    });

    test('C-26 ⑥ 전환 냉각 배너도 openCount == 0 에서 렌더된다 (N-1)', () {
      final AdviceInboxSummary summary = AdviceInboxSummary.fromJson(
        fixtureJson(FixturePaths.m6AdviceHandoverCooling)['summary']!
            as Map<String, Object?>,
      );
      expect(summary.openCount, 0);
      expect(summary.handoverCoolingActive, isTrue);
      expect(
        summary.handoverCoolingLabel,
        isNotNull,
        reason: '화면이 위저드 상태를 직접 읽어 배너를 만들지 않게 하는 필드다.',
      );
    });

    test('C-26 ⑦ 회수된 안내는 REVOKED + 등재된 사유 코드다 (G-20)', () {
      final List<AdviceItem> revoked = fixtureRows(FixturePaths.m6Advice12)
          .map(AdviceItem.fromJson)
          .where((AdviceItem i) => i.effectiveStatus == AdviceStatus.revoked)
          .toList();

      expect(
        revoked,
        isNotEmpty,
        reason: '회수 갈래가 없으면 「규칙대로 전환한 사람이 예산을 잃는다」 검사가 입력을 잃는다.',
      );
      for (final AdviceItem item in revoked) {
        expect(item.closeReasonCode, isNotNull, reason: item.adviceId);
        expect(
          DecisionReasonCodes.values,
          contains(item.closeReasonCode),
          reason:
              '${item.adviceId} 의 사유 코드가 §3 사전에 없다: ${item.closeReasonCode}',
        );
        // 🔴 회수는 사람의 미이행이 아니다 — 버튼은 열람뿐이다.
        expect(
          item.actions.map((AdviceAction a) => a.actionId),
          isNot(contains(AdviceActionId.skip)),
        );
      }
      expect(
        revoked.map((AdviceItem i) => i.closeReasonCode),
        contains(DecisionReasonCodes.handoverClosed),
      );
    });

    test(
      'C-26 ⑧ 전환 원자성 — 냉각 중 신규 기록 → 커밋 거부 → 단계 5 복귀',
      () {},
      skip: '위저드 런타임(M5-11)이 선행한다(인벤토리 §9 C-26 = 🟡).',
    );

    test(
      'C-26 ⑨ NO_ACTION·REVOKED 가 이행 갭 분모(issued)에 계상되지 않는다',
      () {},
      skip: '엔진의 이행 갭 집계가 선행한다 — 픽스처는 분모의 원천을 싣지 않는다.',
    );
  });
}
