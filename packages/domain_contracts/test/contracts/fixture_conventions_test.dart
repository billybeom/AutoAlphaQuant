// 픽스처 규약 검사 (01 §5 · 인벤토리 §8) — T2 담당분.
//
// 01 §7 의 번호로는 C-14(시크릿 스캔)·C-15(픽스처↔DDL 정합)의 **봉투·버전 축**에
// 해당한다. 🔴 DDL `CHECK` 대조는 C-15 본체(다른 조 담당)이며 여기서는 하지 않는다 —
// 여기 있는 것은 「봉투가 계약대로 생겼는가 · 실키가 없는가 · 계약 판본이 한 축인가 ·
// 폐기된 운영값이 남아 있지 않은가」다.
//
// 🔴 픽스처는 **합성 데이터**이고 실계좌·실키가 0건이어야 한다(01 §5 대원칙).
// 🔴 봉투 필수 4값(as_of·empty_kind·empty_label·has_more)이 없으면 「없음」(NO_DATA)과
//    「모름」(NOT_LOADED)이 화면에서 갈리지 않는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'support/fixture_io_t2.dart';

/// 🔴 폐기된 월 납입 운영값(01 §7 C-32 · G-89). 픽스처의 운영값 예시는 **100,000**
///    하나이며, 이 목록의 값이 남아 있으면 「네 곳에 상수를 각각 적지 않는다」가
///    픽스처 쪽에서 먼저 무너진 것이다.
/// 🔴 숫자는 **자릿수 경계**로 찾는다 — 그러지 않으면 `"9000000"`(연 한도 소진액)이
///    `90000` 으로 걸린다.
final List<RegExp> _retiredContributionValues = <RegExp>[
  RegExp(r'(?<![0-9])90000(?![0-9])'),
  RegExp(r'(?<![0-9])97000(?![0-9])'),
  RegExp(r'(?<![0-9])124000(?![0-9])'),
  RegExp(r'90_000|97_000|124_000'),
  RegExp('9만|9\\.7만|12\\.4만'),
];

void main() {
  group('픽스처 규약 (01 §5 · 인벤토리 §8)', () {
    test('C-14/C-15 ① FixturePaths.all 이 디스크의 픽스처 전량과 일치한다', () {
      // 🔴 목록에 없는 파일이 생기면 시크릿 스캔·열거값 대조가 그 파일을 **건너뛴 채**
      //    통과한다 — 「검사하지 않는 검사」의 가장 흔한 입구다.
      final List<String> declared = List<String>.of(FixturePaths.all)..sort();
      expect(declared, fixtureFilesOnDisk());
      expect(
        declared.toSet().length,
        declared.length,
        reason: 'FixturePaths.all 에 같은 경로가 두 번 있다.',
      );
    });

    test('C-15 ② 봉투가 계약대로 생겼다 — meta 7필드 + as_of + 빈 상태 3값', () {
      for (final String path in FixturePaths.all) {
        final FixtureEnvelope envelope = decodeEnvelope(fixtureText(path));

        expect(envelope.meta.fixtureVersion, isNotEmpty, reason: path);
        expect(envelope.meta.generatedAt, isNotEmpty, reason: path);
        expect(envelope.meta.notice, isNotEmpty, reason: path);
        expect(
          RunMode.values.map((RunMode m) => m.wire),
          contains(envelope.meta.mode),
          reason: '$path — meta.mode 가 RunMode 표기가 아니다: ${envelope.meta.mode}',
        );
        // 🔴 합성 config 해시. 실전 해시가 픽스처에 들어오면 C-13(핸드북 정합)이
        //    실계좌 설정을 인용하기 시작한다.
        expect(envelope.meta.configHash, startsWith('cfg_fake_'), reason: path);

        // 빈 상태 3분 — 「없는 것」·「못 받은 것」·「해당 없음」은 다르다.
        expect(
          EmptyKind.values.map((EmptyKind k) => k.wire),
          contains(envelope.emptyKind),
          reason: '$path — empty_kind: ${envelope.emptyKind}',
        );
        if (envelope.rows.isEmpty &&
            emptyKindFromJson(envelope.emptyKind) == EmptyKind.noData) {
          expect(
            envelope.emptyLabel,
            isNotNull,
            reason: '$path — 빈 목록인데 화면이 그릴 문구가 없다(계약 3조 ③).',
          );
        }
      }
    });

    test('C-15 ③ as_of 는 전 픽스처에 실리고 디코드된다 (계약 3조 ③)', () {
      for (final String path in FixturePaths.all) {
        final FixtureEnvelope envelope = decodeEnvelope(fixtureText(path));
        final AsOf asOf = AsOf.fromJson(envelope.asOf);

        expect(asOf.label, isNotEmpty, reason: '$path — 기준일 고지 문구가 비었다.');
        expect(asOf.tradeDate.yyyyMmDd, isNotEmpty, reason: path);
        expect(
          asOf.staleAfter.inSeconds,
          greaterThan(0),
          reason: '$path — staleAfter 가 0 이면 신선도 배너가 영원히 뜨거나 안 뜬다.',
        );
        if (asOf.staleReasonCode != null) {
          expect(
            StaleReasonCodes.values,
            contains(asOf.staleReasonCode),
            reason: '$path — 등재되지 않은 stale 사유 코드: ${asOf.staleReasonCode}',
          );
        }
      }
    });

    test('C-15 ④ meta.contract_version 이 패키지 상수와 같은 축이다', () {
      // 🔴 한쪽만 올리면 C-1(뷰모델 골든)·C-15 가 **갈라진 채로 통과**한다.
      for (final String path in FixturePaths.all) {
        expect(
          decodeEnvelope(fixtureText(path)).meta.contractVersion,
          contractVersion,
          reason: path,
        );
      }
    });

    test('C-14 ⑤ 픽스처에 실키·계좌 전체번호가 0건이다', () {
      for (final String path in FixturePaths.all) {
        final List<SecretFinding> findings = scanForSecrets(fixtureText(path));
        expect(
          findings,
          isEmpty,
          // 🔴 실패 메시지에 원문을 그대로 싣지 않는다 — 코드와 자리만 말한다.
          reason:
              '$path 에서 시크릿 패턴이 걸렸다: '
              '${findings.map((SecretFinding f) => '${f.code}@${f.offset}').join(', ')}',
        );
      }
    });

    test('C-32 ⑥ 폐기된 월 납입 운영값이 픽스처에 남아 있지 않다 (G-89)', () {
      for (final String path in FixturePaths.all) {
        final String text = fixtureText(path);
        for (final RegExp pattern in _retiredContributionValues) {
          expect(
            pattern.hasMatch(text),
            isFalse,
            reason:
                '$path 에 폐기된 운영값이 남아 있다(${pattern.pattern}). '
                '운영값 예시는 100,000 하나다.',
          );
        }
      }
    });

    test('C-32 ⑦ 픽스처 파일 이름에 금액이 들어가지 않는다', () {
      // 🔴 이름이 금액을 말하면 값이 바뀔 때 파일명까지 계약이 된다
      //    (`_default`·`_limit`·`_expired` 로 «갈래»를 말한다).
      final RegExp amountLike = RegExp(r'[0-9]{5,}');
      for (final String path in FixturePaths.all) {
        final String basename = path.split('/').last;
        expect(
          amountLike.hasMatch(basename),
          isFalse,
          reason: '픽스처 이름에 금액으로 읽힐 숫자가 있다: $path',
        );
      }
    });
  });
}
