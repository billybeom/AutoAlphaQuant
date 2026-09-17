// C-8 JSON 라운드트립 — 01 §7 표 C-8 · 인벤토리 §9(🟢 지금 자동화).
//
// 정의: 「전 DTO `fromJson(toJson(x)) == x`, 금액은 문자열 유지」.
// 잡는 것: **Decimal → double 유실**.
//
// 🔴 「전 DTO」를 «픽스처가 있는 DTO» 로 조용히 줄이지 않는다 — 덮이지 않은 타입은
//    [_knownUncovered] 에 사유와 함께 **전량** 적고, 목록이 어긋나면 실패시킨다.
//    (덮인 타입이 늘어도 실패한다. 그때는 목록에서 지우는 것이 옳은 조치다.)

import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_fixture_registry.dart';
import 'c00_support.dart';

void main() {
  group('C-8 JSON 라운드트립 (01 §7)', () {
    test('C-8 등록된 픽스처의 전 행이 fromJson(toJson(x)) == x 를 만족한다', () {
      int rowCount = 0;
      for (final MapEntry<String, FixtureBinding> e
          in fixtureBindings.entries) {
        final String path = e.key;
        final String raw = readFixture(path);
        final FixtureEnvelope envelope = decodeEnvelope(raw);

        for (int i = 0; i < envelope.rows.length; i++) {
          final DtoCodec<Object> codec = e.value.rows;
          final Object first = codec.decode(envelope.rows[i]);
          final Map<String, dynamic> encoded = codec.encode(first);
          final Object second = codec.decode(encoded);
          expect(
            second,
            first,
            reason: '$path rows[$i] (${codec.typeName}) — 왕복에서 값이 달라졌다.',
          );
          rowCount++;
        }

        final Map<String, Object?> decoded =
            jsonDecode(raw) as Map<String, Object?>;
        for (final MapEntry<String, DtoCodec<Object>> extra
            in e.value.extras.entries) {
          final DtoCodec<Object> codec = extra.value;
          final Object first = codec.decode(
            decoded[extra.key]! as Map<String, Object?>,
          );
          final Object second = codec.decode(codec.encode(first));
          expect(
            second,
            first,
            reason: '$path.${extra.key} (${codec.typeName}) — 왕복에서 값이 달라졌다.',
          );
          rowCount++;
        }
      }
      expect(
        rowCount,
        greaterThan(200),
        reason: '왕복한 행이 너무 적다 — 등록부가 비었거나 픽스처를 못 읽었다.',
      );
    });

    test('C-8 금액은 왕복 후에도 문자열이다(숫자로 새지 않는다)', () {
      final Set<String> moneyKeys = _moneyJsonKeys();
      expect(
        moneyKeys,
        contains('price'),
        reason: '금액 키 수집이 실패했다 — @DecimalStringConverter 스캔을 확인한다.',
      );

      void assertStrings(Object? json, String where) {
        walkJson(json, (String path, String key, Object? value) {
          if (!moneyKeys.contains(key) || value == null) {
            return;
          }
          expect(
            value,
            isA<String>(),
            reason:
                '$where $path — 금액이 숫자로 실렸다. JSON 표기는 문자열이다'
                '(01 §1-2 — 숫자로 쓰면 파서가 double 로 읽어 정밀도가 날아간다).',
          );
        });
      }

      // ① 픽스처 원문.
      for (final String path in FixturePaths.all) {
        assertStrings(jsonDecode(readFixture(path)), path);
      }

      // ② 계약 타입이 다시 쓴 JSON.
      for (final MapEntry<String, FixtureBinding> e
          in fixtureBindings.entries) {
        final FixtureEnvelope envelope = decodeEnvelope(readFixture(e.key));
        for (final Map<String, Object?> row in envelope.rows) {
          final DtoCodec<Object> codec = e.value.rows;
          assertStrings(codec.encode(codec.decode(row)), '${e.key} (toJson)');
        }
      }
    });

    test('C-8 Decimal 값 왕복은 값을 잃지 않는다(문자열 정규화는 값이 아니다)', () {
      // ⚠️ decimal 3.x 는 값을 정규화한다 — '38250.00' → '38250'.
      //    **값** 왕복은 안전하고 **문자열** 왕복은 보장되지 않는다
      //    (docs/toolchain_notes.md §4-1). 픽스처는 정규형으로 적는다.
      const DecimalStringConverter converter = DecimalStringConverter();
      for (final String raw in <String>[
        '0',
        '1',
        '38250',
        '38250.5',
        '0.0035',
        '100000000',
        '-12345.678',
      ]) {
        final Decimal parsed = converter.fromJson(raw);
        expect(converter.fromJson(converter.toJson(parsed)), parsed);
        expect(converter.toJson(parsed), raw);
      }
      // 정규화되는 표기: 값은 같고 문자열만 짧아진다.
      expect(converter.fromJson('38250.00'), converter.fromJson('38250'));

      // 🔴 double 을 거치면 값이 달라진다 — 이것이 C-8 이 막는 사고다.
      expect(Decimal.parse('0.1') + Decimal.parse('0.2'), Decimal.parse('0.3'));
      expect(0.1 + 0.2 == 0.3, isFalse);
    });

    test('C-8 픽스처의 모든 금액 문자열은 Decimal 이 그대로 읽는다', () {
      final Set<String> moneyKeys = _moneyJsonKeys();
      for (final String path in FixturePaths.all) {
        walkJson(jsonDecode(readFixture(path)), (
          String jsonPath,
          String key,
          Object? value,
        ) {
          if (!moneyKeys.contains(key) || value is! String) {
            return;
          }
          // 열거값이 같은 키 이름을 쓰는 축(`level` 등)은 숫자가 아니므로 건너뛴다.
          if (!RegExp(r'^-?[0-9]+(\.[0-9]+)?$').hasMatch(value)) {
            return;
          }
          expect(
            () => Decimal.parse(value),
            returnsNormally,
            reason: '$path $jsonPath — Decimal 이 못 읽는 금액 표기다.',
          );
        });
      }
    });

    test('C-8 계약의 모든 fromJson 타입이 덮이거나 사유와 함께 등재돼 있다', () {
      final Map<String, String> bodies = _freezedTypeBodies();
      final Set<String> withFromJson = bodies.entries
          .where((MapEntry<String, String> e) => e.value.contains('.fromJson('))
          .map((MapEntry<String, String> e) => e.key)
          .toSet();

      final Set<String> roots = <String>{
        for (final FixtureBinding b in fixtureBindings.values) ...<String>[
          b.rows.typeName,
          for (final DtoCodec<Object> c in b.extras.values) c.typeName,
        ],
      };
      expect(
        roots.difference(withFromJson),
        isEmpty,
        reason: '등록부의 타입 이름이 계약에 없다 — 이름을 잘못 적었다.',
      );

      final Set<String> covered = _closure(roots, bodies);
      final Set<String> uncovered = withFromJson.difference(covered);

      expect(
        uncovered.difference(_knownUncovered.keys.toSet()),
        isEmpty,
        reason:
            '픽스처로 덮이지 않은 계약 타입이 새로 생겼다. 픽스처를 등록하거나 '
            '_knownUncovered 에 **사유**를 적는다(01 §5 · 인벤토리 §8).',
      );
      expect(
        _knownUncovered.keys.toSet().difference(uncovered),
        isEmpty,
        reason: '이제 덮이는 타입이 _knownUncovered 에 남아 있다 — 목록에서 지운다.',
      );
      for (final MapEntry<String, String> e in _knownUncovered.entries) {
        expect(e.value, isNotEmpty, reason: '${e.key} — 미포함 사유가 비어 있다.');
      }
    });
  });
}

/// `@DecimalStringConverter()` 가 붙은 필드의 **JSON 키**(snake_case).
///
/// 🔴 목록을 손으로 적지 않는다 — 소스가 정본이라 필드가 늘면 검사도 함께 는다.
///    (`build.yaml` 의 `field_rename: snake` 를 그대로 흉내 낸다.)
Set<String> _moneyJsonKeys() {
  final Set<String> keys = <String>{};
  final RegExp re = RegExp(
    r"@DecimalStringConverter\(\)\s*(?:@JsonKey\(name:\s*'([^']+)'\)\s*)?"
    r'(?:required\s+)?Decimal\??\s+(\w+)',
  );
  for (final File f in dartSourcesIn(libDir)) {
    for (final RegExpMatch m in re.allMatches(f.readAsStringSync())) {
      final String? explicit = m.group(1);
      keys.add(explicit ?? _snake(m.group(2)!));
    }
  }
  return keys;
}

String _snake(String camel) => camel
    .replaceAllMapped(
      RegExp('([a-z0-9])([A-Z])'),
      (Match m) => '${m.group(1)}_${m.group(2)}',
    )
    .toLowerCase();

/// freezed 클래스 이름 → 생성자 본문(주석 제거).
Map<String, String> _freezedTypeBodies() {
  final Map<String, String> out = <String, String>{};
  final RegExp re = RegExp(
    r'abstract class (\w+) with _\$\w+[^{]*\{(.*?)\n\}',
    dotAll: true,
  );
  for (final File f in dartSourcesIn(libDir)) {
    final String source = stripComments(f.readAsStringSync());
    for (final RegExpMatch m in re.allMatches(source)) {
      out[m.group(1)!] = m.group(2)!;
    }
  }
  return out;
}

/// [roots] 에서 시작해 «필드에 등장하는 계약 타입» 을 따라간 폐포.
Set<String> _closure(Set<String> roots, Map<String, String> bodies) {
  final Set<String> seen = <String>{};
  final List<String> stack = roots.toList();
  while (stack.isNotEmpty) {
    final String type = stack.removeLast();
    if (!seen.add(type)) {
      continue;
    }
    final String? body = bodies[type];
    if (body == null) {
      continue;
    }
    for (final String other in bodies.keys) {
      if (other == type || seen.contains(other)) {
        continue;
      }
      if (RegExp('\\b$other\\b').hasMatch(body)) {
        stack.add(other);
      }
    }
  }
  return seen;
}

const String _reasonCommandPayload =
    '명령 인자·영수증 봉투는 화면 픽스처가 아니다 — CommandApi 구현이 채운다'
    '(01 §4-2 · C-28 G-19). 왕복은 C-16·C-28 의 몫이다.';
const String _reasonM9Fixture =
    '05(M9) 설정·운영 화면 픽스처가 인벤토리 §8 목록에 없다(m9/ 는 handover_states 1건뿐). '
    '픽스처가 생기면 등록부에 올리고 여기서 지운다.';
const String _reasonJournalDetail =
    '`J-4` blind 리뷰·보유 상세 픽스처가 아직 없다 — v1.1 은 J-2·J-3·J-5 까지 덮었다(01 §8 미결 46).';
const String _reasonCalendarUndecided =
    'X4 캘린더 채택이 미결이라 픽스처를 만들지 않았다(01 §8-5 · FeatureFlags.calendarEnabled).';
const String _reasonHandbookDraft =
    '핸드북 원고가 선행이다(C-13 🔵) — 지금 있는 것은 페이지 1건뿐이고 색인·항목 픽스처가 없다.';

/// 🔴 픽스처로 덮이지 않는 계약 타입 — **전량**이 사유와 함께 여기 있다.
const Map<String, String> _knownUncovered = <String, String>{
  // ── 명령 인자·봉투(01 §4-2) ─────────────────────────────────────────────
  'ActionResult': _reasonCommandPayload,
  'AdviceSkip': _reasonCommandPayload,
  'AlertAck': _reasonCommandPayload,
  'BlindReviewScore': _reasonCommandPayload,
  'CommandContext': _reasonCommandPayload,
  'DepositRegistration': _reasonCommandPayload,
  'DisclosureViewEvent': _reasonCommandPayload,
  'JournalDraft': _reasonCommandPayload,
  'KillChecklistAck': _reasonCommandPayload,
  'ManualFillAmendment': _reasonCommandPayload,
  'ManualFillPatchable': _reasonCommandPayload,
  'ManualFillRecord': _reasonCommandPayload,
  'ManualFillVoid': _reasonCommandPayload,
  'SelfReportBalance': _reasonCommandPayload,

  // ── M9 설정·기기·연결·백업·셸(05) ────────────────────────────────────────
  'BackupVm': _reasonM9Fixture,
  'ConnectionRow': _reasonM9Fixture,
  'ConnectionsVm': _reasonM9Fixture,
  'ContributionSetting': _reasonM9Fixture,
  'CredentialCardVm': _reasonM9Fixture,
  'CredentialListVm': _reasonM9Fixture,
  'DeviceAccessVm': _reasonM9Fixture,
  'DeviceRow': _reasonM9Fixture,
  'LiveDryRunObservationVm': _reasonM9Fixture,
  'MonthlyContributionVm': _reasonM9Fixture,
  'SettingsCard': _reasonM9Fixture,
  'SettingsHomeVm': _reasonM9Fixture,
  'ShellChip': _reasonM9Fixture,
  'ShellVm': _reasonM9Fixture,

  // ── M6 상세·기록 폼 ─────────────────────────────────────────────────────
  'BlindReviewCard': _reasonJournalDetail,
  'BlindReviewQuestion': _reasonJournalDetail,
  'StopLineNormalized': _reasonJournalDetail,

  // ── X4 캘린더 ───────────────────────────────────────────────────────────
  'CalendarEventDto': _reasonCalendarUndecided,
  'CalendarSyncStatus': _reasonCalendarUndecided,

  // ── 핸드북 ──────────────────────────────────────────────────────────────
  'HandbookEntry': _reasonHandbookDraft,
  'HandbookIndex': _reasonHandbookDraft,

  // ── 낱건 ────────────────────────────────────────────────────────────────
  'CashEstimateNotice':
      '현금 추정 고지 픽스처가 없다(01 §2-11 · C-24 가 배지 존재를 볼 때 함께 만든다).',
  'EntryRampProgress': '진입 램프 픽스처가 없다 — safety_states 는 브레이커·플래그 축만 담는다.',
  'EntryRampSleeveState': '진입 램프 픽스처가 없다(위와 같은 사유).',
  'FeatureFlags': '봉투에 실리는 값이 아니라 **셸이 주입**하는 값이다(01 §2-1 · C-17·C-18 의 입력).',
  'LedgerRepairRow':
      '정정 행 픽스처가 없다 — ledger_diffs_4 는 diff 만 담는다(C-29 가 만들 입력).',
  'Money': '⚠️ 예약 타입 — 1차 릴리스 DTO 에서 쓰지 않는다(01 §1-2). 금액은 Decimal 하나로 흐른다.',
  'PlannedWorkSummary':
      'X2 planned_work 픽스처가 없다 — resume_report_1 은 재개 항목만 담는다.',
  'RebalancePreview': '리밸런싱 미리보기 픽스처가 없다(플래너 픽스처는 납입·인출 갈래만 있다).',
  'SelfReportLine':
      'm6/self_report_1.json 이 미매핑이라 하위 행도 덮이지 않는다 — 등록부 unmappedFixtures 참조.',
  'TzInstant': '아직 어느 픽스처 필드도 TzInstant 를 싣지 않는다(01 §1-3 — 표시 시각 전용).',
};
