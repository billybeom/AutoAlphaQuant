// C-1 뷰모델 골든 스냅샷 — 01 §7 표 C-1 · 인벤토리 §9.
//
// 정의: 「픽스처 → 뷰모델 변환 결과를 `*.golden.json` 과 비교」.
// 🔵 골든 파일(`*.golden.json`)은 아직 없다 — 이 회차는 그 **앞 단계**인
//    «픽스처가 계약 봉투대로 생겼고 계약 타입으로 역직렬화된다»를 고정한다.
//    필드 의미가 조용히 바뀌면 여기서 먼저 깨진다(required 필드가 사라지거나
//    열거값이 바뀌면 `fromJson` 이 던진다).
// 🔴 골든은 M2 소유다 — 화면 담당은 읽기만 한다(01 §7 「최초 생성과 재생성」 표).

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_fixture_registry.dart';
import 'c00_support.dart';

void main() {
  group('C-1 뷰모델 골든 (01 §7)', () {
    test('C-1 픽스처 목록(FixturePaths.all)과 디스크의 파일이 정확히 일치한다', () {
      final Set<String> declared = FixturePaths.all.toSet();
      final Set<String> onDisk = allFixtureFilesOnDisk().toSet();

      expect(
        declared.difference(onDisk),
        isEmpty,
        reason: 'FixturePaths 에 있는데 파일이 없다(01 §5 — 파일명은 계약이다).',
      );
      expect(
        onDisk.difference(declared),
        isEmpty,
        reason:
            '파일은 있는데 FixturePaths 에 없다. 등재하지 않은 픽스처는 '
            'C-14 시크릿 스캔·C-15 대조를 통째로 건너뛴다.',
      );
      expect(
        FixturePaths.all.length,
        declared.length,
        reason: 'FixturePaths.all 에 중복 항목이 있다.',
      );
    });

    test('C-1 모든 픽스처가 등록부(뷰모델 매핑 또는 사유)에 있다', () {
      final Set<String> registered = <String>{
        ...fixtureBindings.keys,
        ...unmappedFixtures.keys,
      };
      final Set<String> missing = FixturePaths.all.toSet().difference(
        registered,
      );
      expect(
        missing,
        isEmpty,
        reason:
            '등록부에 없는 픽스처다. c00_fixture_registry.dart 의 fixtureBindings 에 '
            '타입을 적거나, 계약에 타입이 없으면 unmappedFixtures 에 **사유와 함께** 적는다.',
      );

      final Set<String> both = fixtureBindings.keys.toSet().intersection(
        unmappedFixtures.keys.toSet(),
      );
      expect(both, isEmpty, reason: '한 픽스처가 매핑과 미매핑 양쪽에 있다.');
    });

    test('C-1 봉투 필수값 — as_of·empty_kind·empty_label·has_more·meta 7값', () {
      for (final String path in FixturePaths.all) {
        expect(fixtureExists(path), isTrue, reason: '픽스처 파일이 없다: $path');
        final FixtureEnvelope envelope = decodeEnvelope(readFixture(path));

        expect(
          envelope.meta.contractVersion,
          contractVersion,
          reason:
              '$path — meta.contract_version 과 lib/src/contract_version.dart 가 '
              '갈라졌다(01 §5 · 인벤토리 §8-1). 한쪽만 올리지 않는다.',
        );
        expect(envelope.meta.fixtureVersion, isNotEmpty, reason: path);
        expect(
          envelope.meta.configHash,
          startsWith('cfg_fake_'),
          reason: '$path — 픽스처의 config_hash 는 합성값이다(01 §5).',
        );
        expect(
          envelope.meta.notice,
          '합성 데이터. 실계좌·실키 없음.',
          reason: '$path — 봉투 고지 문구는 01 §5 의 문장 하나다.',
        );
        expect(envelope.meta.seed, greaterThan(0), reason: path);
        expect(envelope.meta.generatedAt, isNotEmpty, reason: path);
        expect(envelope.meta.mode, isNotEmpty, reason: path);

        // `emptyKindFromJson` 은 미등록 값을 던진다 — 조용한 기본값이 없다.
        expect(emptyKindFromJson(envelope.emptyKind), isNotNull, reason: path);

        final AsOf asOf = AsOf.fromJson(envelope.asOf);
        expect(
          asOf.label,
          isNotEmpty,
          reason: '$path — as_of.label 은 엔진 생성 문구다.',
        );
        expect(
          asOf.staleAfter.inSeconds,
          greaterThan(0),
          reason: '$path — stale_after_seconds 가 0 이면 신선도 배너가 영원히 뜬다.',
        );

        if (envelope.rows.isEmpty) {
          expect(
            envelope.emptyLabel,
            isNotNull,
            reason:
                '$path — 빈 목록에는 empty_label 이 실려 온다(계약 3조 ③). '
                '없으면 화면이 빈 상태 문구를 지어내야 한다.',
          );
          expect(envelope.emptyLabel, isNotEmpty, reason: path);
        }
      }
    });

    test('C-1 등록된 픽스처가 계약 뷰모델로 역직렬화된다', () {
      for (final MapEntry<String, FixtureBinding> e
          in fixtureBindings.entries) {
        final String path = e.key;
        final FixtureBinding binding = e.value;
        final String raw = readFixture(path);
        final FixtureEnvelope envelope = decodeEnvelope(raw);

        for (int i = 0; i < envelope.rows.length; i++) {
          expect(
            () => binding.rows.decode(envelope.rows[i]),
            returnsNormally,
            reason:
                '$path rows[$i] → ${binding.rows.typeName} 역직렬화 실패. '
                '필드 이름·열거값이 계약과 갈라졌다.',
          );
        }

        // 봉투에 얹힌 추가 블록(안내함의 `summary` 등).
        final Map<String, Object?> decoded =
            jsonDecode(raw) as Map<String, Object?>;
        for (final MapEntry<String, DtoCodec<Object>> extra
            in binding.extras.entries) {
          final Object? block = decoded[extra.key];
          expect(
            block,
            isA<Map<String, Object?>>(),
            reason: '$path — 봉투에 ${extra.key} 블록이 없다.',
          );
          expect(
            () => extra.value.decode(block! as Map<String, Object?>),
            returnsNormally,
            reason: '$path.${extra.key} → ${extra.value.typeName} 역직렬화 실패.',
          );
        }
      }
    });

    test('C-1 ListResult 로 조립하면 봉투 4값이 그대로 실린다', () {
      // 대표 1건으로 `decodeList` 경로(인벤토리 §8-5 시그니처)를 확인한다.
      final ListResult<Object> result = decodeList<Object>(
        readFixture(FixturePaths.journal30),
        TradeJournalEntry.fromJson,
      );
      expect(result.rows, hasLength(30));
      expect(result.hasMore, isFalse);
      expect(result.emptyKind, EmptyKind.noData);
      expect(result.asOf.label, isNotEmpty);
    });

    test('C-1 미매핑 픽스처도 봉투까지는 계약을 지킨다(사유는 등록부에 남긴다)', () {
      for (final MapEntry<String, String> e in unmappedFixtures.entries) {
        expect(e.value, isNotEmpty, reason: '${e.key} — 미매핑 사유가 비어 있다.');
        expect(
          () => decodeEnvelope(readFixture(e.key)),
          returnsNormally,
          reason: '${e.key} — 뷰모델이 없어도 봉투는 계약대로여야 한다.',
        );
      }
    });

    test(
      'C-1 골든 JSON(*.golden.json) 대조',
      () {},
      skip:
          '골든 파일이 아직 없다. 01 §7 「최초 생성과 재생성」 표에 따라 골든은 M2 소유이며 '
          '뷰모델 변환기(ui_* 프리젠터)와 함께 만든다 — 지금 만들면 «픽스처를 다시 적은 것»이 된다.',
    );
  });
}
