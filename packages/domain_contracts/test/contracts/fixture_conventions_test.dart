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
// 🆕 v1.4(01 §14-12 · 설계 Δ4 «봉투 키 화이트리스트») — C-15 ⑥ 봉투 최상위 키는 필수 6키 +
//    `fixtures/README.md` «봉투 형제 키 표»의 키뿐이다(`lag_notice` 류 고아 키 재발 방지 · 미결 40 과 같은 뿌리).

import 'dart:io';

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

/// 🆕 v1.4 C-15 ⑥ — 봉투 필수 6키(로더가 읽는 키 · 01 §5).
const Set<String> _envelopeKeys = <String>{
  'meta',
  'as_of',
  'empty_kind',
  'empty_label',
  'has_more',
  'rows',
};

/// README «봉투 형제 키 표»의 머리(이 줄부터 다음 `---`·`#` 까지가 표 구역이다).
const String _siblingTableHeading = '### 봉투 확장 — 부속 블록 (봉투 형제 키 표)';

/// 표 한 행의 첫 열 백틱 키 — `| \`summary\` | … |`.
final RegExp _siblingRow = RegExp(r'^\|\s*`([a-z][a-z0-9_]*)`\s*\|');

/// README 원문에서 형제 키 표의 키를 읽는다(표 = 기계가 읽는 목록 · 한 행에 키 하나).
Set<String> _siblingKeysFrom(String readme) {
  final List<String> lines = readme.split('\n');
  final int start = lines.indexWhere(
    (String l) => l.trim() == _siblingTableHeading,
  );
  if (start < 0) {
    return const <String>{};
  }
  final Set<String> keys = <String>{};
  for (int i = start + 1; i < lines.length; i++) {
    final String l = lines[i].trim();
    if (l == '---' || l.startsWith('#')) {
      break;
    }
    final RegExpMatch? m = _siblingRow.firstMatch(l);
    if (m != null) {
      keys.add(m.group(1)!);
    }
  }
  return keys;
}

/// 봉투 1건의 최상위 키 가운데 화이트리스트 밖의 것.
List<String> _strayEnvelopeKeys(
  String path,
  Map<String, Object?> envelope,
  Set<String> siblings,
) => <String>[
  for (final String key in envelope.keys)
    if (!_envelopeKeys.contains(key) && !siblings.contains(key))
      '$path — 봉투 최상위 키 `$key` 가 README 형제 키 표에 없다',
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

    test('C-15 ⑥ 봉투 최상위 키는 필수 6키 + README 형제 키 표뿐이다 (🆕 v1.4 · 01 §14-12)', () {
      final String readme = File('${fixturesDir().path}/README.md')
          .readAsStringSync();
      final Set<String> siblings = _siblingKeysFrom(readme);
      // 자체 검증 — 표를 실제로 읽었다(못 읽으면 «전부 표 밖»이 아니라 «표가 비었다»로 먼저 걸린다).
      expect(
        siblings,
        containsAll(<String>['summary', 'advice_summary', 'active_flags']),
        reason: 'README «봉투 형제 키 표»를 못 읽었다 — 머리 글자나 표 모양이 바뀌었다.',
      );
      expect(siblings.intersection(_envelopeKeys), isEmpty);
      expect(
        _siblingKeysFrom(
          '$_siblingTableHeading\n\n| 키 | 타입 | 쓰는 파일 |\n|---|---|---|\n'
          '| `summary` | T | f |\n| `lag_notice` | 문장 | g |\n\n---\n| `after` | x | y |\n',
        ),
        <String>{'summary', 'lag_notice'},
      );
      // 자체 검증 — 표 밖 키는 걸린다(v1.4 에서 지운 `lag_notice` 가 대표).
      expect(
        _strayEnvelopeKeys('fake', <String, Object?>{
          'meta': 1,
          'rows': <Object?>[],
          'lag_notice': '문장',
        }, siblings),
        hasLength(1),
      );

      final List<String> stray = <String>[];
      final Set<String> used = <String>{};
      for (final String path in FixturePaths.all) {
        final Map<String, Object?> envelope = fixtureJson(path);
        stray.addAll(_strayEnvelopeKeys(path, envelope, siblings));
        used.addAll(envelope.keys.where(siblings.contains));
      }
      expect(
        stray,
        isEmpty,
        reason:
            '봉투에 표 밖 최상위 키가 있다 — 행 필드로 옮기거나(DTO 가 읽는 자리) README «봉투 형제 키 표»에 '
            '**먼저** 등재한다(01 §14-12).\n${stray.join('\n')}',
      );
      // 역방향 — 표의 키는 실제로 쓰인다(쓰이지 않는 키가 남으면 표가 낡아 화이트리스트가 넓어진다).
      expect(
        siblings.difference(used),
        isEmpty,
        reason: 'README 형제 키 표에 아무 픽스처도 쓰지 않는 키가 있다 — 표에서 지운다.',
      );
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
