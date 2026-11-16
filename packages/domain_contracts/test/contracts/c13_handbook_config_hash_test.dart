// C-13 핸드북 ↔ 규칙 정합 — 01 §7 표 C-13 · 인벤토리 §9(🔵 핸드북 원고 선행).
//
// 정의: 「픽스처 `config_hash` vs 핸드북 메타 불일치 시 실패」.
// 잡는 것: **설명이 규칙보다 뒤처짐**.
//
// 🔵 핸드북 «원고»는 아직 없다(페이지 픽스처 1건뿐). 그래서 여기서 고정하는 것은
//    **대조의 기계 부분**이다 — 같은 봉투 안에서 `config_hash` 가 갈라지면 실패한다.
//    원고가 들어오면 이 자리에 「핸드북 메타 ↔ 엔진 config」 대조가 더해진다.
// 🆕 v1.17(01 §26 K14 · C-13 ⓐ) — 뒤처짐 판정·글자 = 엔진(`outdatedNotice`) · 화면 비교 0 · 뒤처짐 표본도 해시 = meta ·
//    핸드북 표본 6벌(페이지 4 + 목차 2)을 전부 본다 · 페이지는 본문 XOR 모르는 앵커 문장(`missingLabel`).

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

void main() {
  group('C-13 핸드북 정합 (01 §7)', () {
    test('C-13 핸드북 표본(페이지 4 · 목차 2)의 config_hash 가 봉투 메타와 같다', () {
      const List<String> pages = <String>[
        FixturePaths.m8HandbookPageSleeveB,
        FixturePaths.m8HandbookPageOutdated,
        FixturePaths.m8HandbookPageMissing,
        FixturePaths.m8HandbookPageArchived,
      ];
      const List<String> indexes = <String>[
        FixturePaths.m8HandbookIndex,
        FixturePaths.m8HandbookIndexOutdated,
      ];
      for (final String path in pages) {
        final FixtureEnvelope envelope = decodeEnvelope(readFixture(path));
        final HandbookPage page = HandbookPage.fromJson(envelope.rows.single);
        expect(
          page.configHash,
          envelope.meta.configHash,
          reason:
              '$path — 핸드북이 설명하는 규칙과 픽스처가 만들어진 규칙이 다르다 — '
              '이 상태로 화면에 띄우면 «설명이 규칙보다 뒤처진» 것을 아무도 모른다 '
              '(🆕 v1.17 — 뒤처짐은 엔진이 `outdatedNotice` 글자로 말한다 · 해시는 그대로 meta).',
        );
        expect(page.anchor, isNotEmpty, reason: path);
        expect(
          page.blocks.isNotEmpty != (page.missingLabel != null),
          isTrue,
          reason:
              '$path — 빈 페이지는 「설명이 있다」가 아니다 · 본문이 없으면 모르는 앵커 문장(missingLabel)이 '
              '있어야 하고, 본문이 있으면 그 문장은 없다.',
        );
      }
      for (final String path in indexes) {
        final FixtureEnvelope envelope = decodeEnvelope(readFixture(path));
        final HandbookIndex index = HandbookIndex.fromJson(
          envelope.rows.single,
        );
        expect(index.configHash, envelope.meta.configHash, reason: path);
        expect(index.entries, isNotEmpty, reason: path);
      }
    });

    test('C-13 한 봉투 안의 config_hash 는 전부 같은 값이다', () {
      final List<String> mismatches = <String>[];
      for (final String path in FixturePaths.all) {
        final String raw = readFixture(path);
        final FixtureEnvelope envelope = decodeEnvelope(raw);
        walkJson(jsonDecode(raw), (String jsonPath, String key, Object? value) {
          if (key != 'config_hash' || value is! String) {
            return;
          }
          if (jsonPath == 'meta.config_hash') {
            return;
          }
          if (value != envelope.meta.configHash) {
            mismatches.add(
              '$path $jsonPath = $value ≠ ${envelope.meta.configHash}',
            );
          }
        });
      }
      expect(
        mismatches,
        isEmpty,
        reason:
            '봉투 메타와 행의 config_hash 가 갈라지면 「어느 규칙으로 만든 값인가」가 '
            '행마다 달라진다 — 대조가 통과한 것이 아니라 볼 것이 없어진다.',
      );
    });

    test('C-13 config_hash 를 싣는 DTO 는 전부 그 값을 필드로 받는다', () {
      // 🔴 화면이 「지금 보고 있는 값」과 「컴파일된 값」을 비교하기 시작하면 그 비교가
      //    엔진의 판정을 화면이 재구현하는 것이다(contract_version.dart 주석).
      final Map<String, String> bodies = _freezedBodies();
      for (final String type in <String>[
        'DecisionRef',
        'FeatureFlags',
        'TriggerSnapshot',
        'AfterTaxLadder',
        'DepositPlan',
        'HandbookIndex',
        'HandbookPage',
        'CalendarEventDto',
      ]) {
        expect(
          bodies[type],
          contains('configHash'),
          reason: '$type 에 configHash 가 없다 — C-13 대조의 입력이 하나 사라진다.',
        );
      }
    });

    test('C-13 계약에 빌드 시점 config_hash 상수가 없다', () {
      final String source = stripComments(
        File('${libDir.path}/src/contract_version.dart').readAsStringSync(),
      );
      expect(
        RegExp(r'const\s+String\s+configHash').hasMatch(source),
        isFalse,
        reason:
            'config_hash 는 엔진이 런타임에 만드는 값이고 계약에서는 DTO 필드로만 '
            '흐른다(contract_version.dart 주석).',
      );
      // 🔴 같은 이유로 schemaVersion·hashFormatVersion 도 아직 상수가 아니다.
      expect(
        RegExp(r'const\s+String\s+schemaVersion').hasMatch(source),
        isFalse,
      );
      expect(
        RegExp(r'const\s+String\s+hashFormatVersion').hasMatch(source),
        isFalse,
      );
    });

    test(
      'C-13 핸드북 메타 ↔ 엔진 config 대조',
      () {},
      skip:
          '핸드북 원고(06 §3-11 HB-1~HB-3)가 아직 없다 — 목차·페이지 표본은 v1.17 에 있으나 '
          '«인용한 임계값·문장이 지금 규칙과 같은가» 의 대조 상대(원고 메타)가 없다(대조 = 엔진 내부 · '
          '`outdatedNotice`). '
          '원고가 들어오면 「인용한 임계값·문장이 지금 규칙과 같은가」를 여기서 본다 — '
          '지금 넣으면 대조 상대가 없어 «통과»가 «볼 것이 없었다»와 같아진다.',
    );
  });
}

Map<String, String> _freezedBodies() {
  final Map<String, String> out = <String, String>{};
  final RegExp re = RegExp(
    r'abstract class (\w+)\s+with _\$\w+[^{]*\{(.*?)\n\}',
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
