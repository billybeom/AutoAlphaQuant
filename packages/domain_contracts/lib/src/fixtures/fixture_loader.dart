// 01 §5 «모의 데이터 픽스처» — 봉투(meta + as_of + empty_kind + empty_label +
// has_more + rows) 디코더와 검증 헬퍼.
//
// 🔴 순수 Dart 여야 한다(인벤토리 §8-5) — `dart:io` 를 쓰면 web viewer 빌드가
//    깨진다. 파일을 읽는 것은 호출자(테스트·화면 하네스)의 일이고 이 파일은
//    «문자열 → DTO» 만 한다.
// 🔴 봉투 필수 4값(as_of·empty_kind·empty_label·has_more)이 하나라도 없으면
//    빈 값으로 넘기지 않고 예외를 던진다(같은 §8-5). 「없음」(NO_DATA + 문구)과
//    「모름」(NOT_LOADED + stale_reason_code)이 화면에서 갈리는 근거가 이 넷이다.
// 🔴 이 파일은 판정하지 않는다(01 §1-4) — 계산 getter·부작용 함수 0건.

import 'dart:convert';

import '../enums/ui.dart'; // EmptyKind — 영역 A
import '../primitives/as_of.dart'; // AsOf — 영역 A
import '../primitives/list_result.dart'; // ListResult<T> — 영역 A

/// 픽스처 봉투가 계약대로 생기지 않았을 때 던진다.
///
/// 🔴 「필드가 없으면 기본값」은 이 계약의 반대다 — 빠진 값은 실패로 드러낸다.
class FixtureFormatException implements Exception {
  const FixtureFormatException(this.message, {this.path});

  /// 사람이 읽을 사유 한 줄.
  final String message;

  /// 문제가 난 자리(`meta.seed`·`rows[3].price` 처럼 점 표기).
  final String? path;

  @override
  String toString() => path == null
      ? 'FixtureFormatException: $message'
      : 'FixtureFormatException: $message (at $path)';
}

/// 봉투 머리의 `meta` 블록(01 §5 봉투 형식).
///
/// 🔴 `contractVersion` 은 `lib/src/contract_version.dart` 상수와 **같은 축**이다
///    — 한쪽만 올리면 C-1(뷰모델 골든)·C-15(픽스처↔DDL)가 갈라진 채 통과한다.
class FixtureMeta {
  const FixtureMeta({
    required this.fixtureVersion,
    required this.contractVersion,
    required this.generatedAt,
    required this.mode,
    required this.configHash,
    required this.seed,
    required this.notice,
  });

  /// 픽스처 묶음 자체의 판본.
  final String fixtureVersion;

  /// 이 픽스처가 표현하는 M2 계약의 판본.
  final String contractVersion;

  /// 픽스처를 생성한 시각(UTC 문자열 원문 — 표시용이 아니다).
  final String generatedAt;

  /// `RunMode` 의 JSON 표기(`SIM_INTERNAL`·`SIM_BROKER`·`LIVE`).
  final String mode;

  /// 합성 config 해시(`cfg_fake_…`).
  final String configHash;

  /// 합성 데이터 생성 시드.
  final int seed;

  /// 「합성 데이터. 실계좌·실키 없음.」 고지 문구.
  final String notice;
}

/// 디코드된 봉투. `rows` 는 아직 DTO 가 아니라 원시 Map 이다.
class FixtureEnvelope {
  const FixtureEnvelope({
    required this.meta,
    required this.asOf,
    required this.emptyKind,
    required this.emptyLabel,
    required this.hasMore,
    required this.rows,
  });

  final FixtureMeta meta;

  /// 봉투의 `as_of` 원문 Map. `AsOf.fromJson` 의 입력이다.
  final Map<String, Object?> asOf;

  /// `EmptyKind` 의 JSON 표기(`NO_DATA`·`NOT_LOADED`·`NOT_APPLICABLE`).
  final String emptyKind;

  /// 빈 목록일 때 화면이 그대로 그릴 문구. 엔진 생성 — 화면이 짓지 않는다.
  final String? emptyLabel;

  final bool hasMore;

  /// 엔진이 **이미 정렬한** 행. 🔴 화면·테스트가 재정렬하지 않는다.
  final List<Map<String, Object?>> rows;
}

/// 봉투 JSON 문자열을 검증하며 디코드한다.
///
/// 필수 키가 없거나 타입이 다르면 [FixtureFormatException].
FixtureEnvelope decodeEnvelope(String json) {
  final Object? decoded = jsonDecode(json);
  if (decoded is! Map<String, Object?>) {
    throw const FixtureFormatException('봉투 최상위가 객체가 아니다.');
  }

  final Map<String, Object?> metaJson = _requireMap(decoded, 'meta');
  final Map<String, Object?> asOfJson = _requireMap(decoded, 'as_of');

  // 🔴 empty_label 은 값이 null 이어도 «키가 있어야» 한다 — 「없음」과
  //    「고지를 아직 못 받았다」를 구별하는 것이 이 계약의 목적이다.
  if (!decoded.containsKey('empty_label')) {
    throw const FixtureFormatException(
      '봉투에 empty_label 키가 없다.',
      path: 'empty_label',
    );
  }
  final Object? emptyLabel = decoded['empty_label'];
  if (emptyLabel != null && emptyLabel is! String) {
    throw const FixtureFormatException(
      'empty_label 은 문자열이거나 null 이다.',
      path: 'empty_label',
    );
  }

  final List<Map<String, Object?>> rows = <Map<String, Object?>>[];
  final Object? rawRows = decoded['rows'];
  if (rawRows is! List) {
    throw const FixtureFormatException('봉투에 rows 배열이 없다.', path: 'rows');
  }
  for (int i = 0; i < rawRows.length; i++) {
    final Object? row = rawRows[i];
    if (row is! Map<String, Object?>) {
      throw FixtureFormatException('행이 객체가 아니다.', path: 'rows[$i]');
    }
    rows.add(row);
  }

  return FixtureEnvelope(
    meta: FixtureMeta(
      fixtureVersion: _requireString(
        metaJson,
        'fixture_version',
        prefix: 'meta',
      ),
      contractVersion: _requireString(
        metaJson,
        'contract_version',
        prefix: 'meta',
      ),
      generatedAt: _requireString(metaJson, 'generated_at', prefix: 'meta'),
      mode: _requireString(metaJson, 'mode', prefix: 'meta'),
      configHash: _requireString(metaJson, 'config_hash', prefix: 'meta'),
      seed: _requireInt(metaJson, 'seed', prefix: 'meta'),
      notice: _requireString(metaJson, 'notice', prefix: 'meta'),
    ),
    asOf: asOfJson,
    emptyKind: _requireString(decoded, 'empty_kind'),
    emptyLabel: emptyLabel as String?,
    hasMore: _requireBool(decoded, 'has_more'),
    rows: rows,
  );
}

/// 봉투 JSON 을 `ListResult<T>` 로 디코드한다(인벤토리 §8-5 시그니처 축).
///
/// [rowFrom] 은 각 DTO 의 `fromJson` 을 그대로 넘긴다.
ListResult<T> decodeList<T>(
  String json,
  T Function(Map<String, Object?>) rowFrom,
) {
  final FixtureEnvelope envelope = decodeEnvelope(json);
  return ListResult<T>(
    rows: envelope.rows.map(rowFrom).toList(growable: false),
    asOf: AsOf.fromJson(envelope.asOf),
    emptyKind: emptyKindFromJson(envelope.emptyKind),
    emptyLabel: envelope.emptyLabel,
    hasMore: envelope.hasMore,
  );
}

/// 단일 객체 픽스처(`resume_report_1.json` 처럼 `rows` 가 1행인 것)의 편의 창구.
///
/// 🔴 행이 정확히 1개가 아니면 예외다 — 「첫 행을 쓴다」는 조용한 판정이 된다.
T decodeSingle<T>(String json, T Function(Map<String, Object?>) rowFrom) {
  final FixtureEnvelope envelope = decodeEnvelope(json);
  if (envelope.rows.length != 1) {
    throw FixtureFormatException(
      '단일 객체 픽스처인데 행이 ${envelope.rows.length}개다.',
      path: 'rows',
    );
  }
  return rowFrom(envelope.rows.single);
}

/// `EmptyKind` 의 JSON 표기 → 열거값(01 §2-1).
///
/// 🔴 표기 문자열의 정본은 영역 A 의 `EmptyKind.wire` 하나다 — 여기에 두 번째
///    목록을 만들지 않는다. 🔴 알 수 없는 값을 기본값으로 흘려보내지 않는다.
EmptyKind emptyKindFromJson(String raw) {
  for (final EmptyKind kind in EmptyKind.values) {
    if (kind.wire == raw) {
      return kind;
    }
  }
  throw FixtureFormatException('알 수 없는 empty_kind: $raw', path: 'empty_kind');
}

// ─────────────────────────────────────────────────────────────────────────────
// 시크릿 스캔 — C-14 의 판정부(인벤토리 §9)
// ─────────────────────────────────────────────────────────────────────────────

/// C-14 가 찾는 패턴 하나.
class SecretPattern {
  const SecretPattern(this.code, this.description, this.pattern);

  /// 사유 코드(테스트 실패 메시지에 그대로 실린다).
  final String code;

  /// 무엇을 찾는가.
  final String description;

  final RegExp pattern;
}

/// C-14 스캔 결과 1건.
class SecretFinding {
  const SecretFinding({
    required this.code,
    required this.description,
    required this.matchedText,
    required this.offset,
  });

  final String code;
  final String description;

  /// 걸린 문자열 원문. 🔴 실키를 로그에 남기지 않기 위해 호출자가 마스킹한다.
  final String matchedText;

  /// 원문에서의 위치(0-기반).
  final int offset;

  @override
  String toString() => '$code($description) @$offset: $matchedText';
}

/// 픽스처 원문에서 시크릿으로 보이는 것을 찾는다(C-14).
///
/// 🔴 판정은 «찾았다/못 찾았다» 뿐이다 — 이 함수는 파일을 고치지 않는다.
List<SecretFinding> scanForSecrets(String text) {
  final List<SecretFinding> findings = <SecretFinding>[];
  for (final SecretPattern rule in secretPatterns) {
    for (final RegExpMatch m in rule.pattern.allMatches(text)) {
      findings.add(
        SecretFinding(
          code: rule.code,
          description: rule.description,
          matchedText: m[0]!,
          offset: m.start,
        ),
      );
    }
  }
  findings.sort(
    (SecretFinding a, SecretFinding b) => a.offset.compareTo(b.offset),
  );
  return findings;
}

/// C-14 패턴 목록(01 §5 대원칙 · 인벤토리 §9 C-14).
///
/// 🔴 「KIS 앱키 · `ya29.` · `1//` · 8자리 계좌」 네 축이 문서가 지목한 것이고,
///    나머지 둘은 같은 사고(자격증명이 픽스처에 새는 것)의 이웃 패턴이다.
/// 🔴 «8자리 이상 연속 숫자» 를 그대로 잡으면 **금액 문자열이 걸린다**
///    (`"30000000"` = 3천만원 인출 · 1억은 9자리다). 그래서 계좌번호는
///    ① 계좌번호꼴(`123456-78`) ② 계좌를 가리키는 키의 값 ③ 「계좌」 뒤의 숫자
///    세 갈래로만 찾는다. 🔴 계좌는 픽스처에 **별칭만** 실리므로 이 셋이면 충분하다.
final List<SecretPattern> secretPatterns = <SecretPattern>[
  SecretPattern(
    'KIS_APP_KEY',
    'KIS 앱키·앱시크릿으로 보이는 긴 영숫자 토큰',
    // KIS 앱키는 36자, 앱시크릿은 180자 안팎의 연속 영숫자다.
    // 픽스처의 정상 값(티커·별칭·`cfg_fake_…`·sha256 앞 12자)은 밑줄·하이픈이
    // 섞이거나 32자 미만이다.
    RegExp('"[A-Za-z0-9]{32,}"'),
  ),
  SecretPattern(
    'GOOGLE_OAUTH_ACCESS_TOKEN',
    'Google OAuth 액세스 토큰 접두 ya29.',
    RegExp(r'ya29\.[A-Za-z0-9_\-]+'),
  ),
  SecretPattern(
    'GOOGLE_OAUTH_REFRESH_TOKEN',
    'Google OAuth 리프레시 토큰 접두 1//',
    RegExp(r'"1//[A-Za-z0-9_\-]+'),
  ),
  SecretPattern(
    'ACCOUNT_NUMBER_FORM',
    '계좌번호꼴 숫자(6자리 이상 - 2자리 이상)',
    RegExp('[0-9]{6,}-[0-9]{2,}'),
  ),
  SecretPattern(
    'ACCOUNT_NUMBER_FIELD',
    '계좌를 가리키는 키에 실린 8자리 이상 연속 숫자',
    RegExp(
      '"[A-Za-z_]*account[A-Za-z_]*"\\s*:\\s*"[0-9]{8,}"',
      caseSensitive: false,
    ),
  ),
  SecretPattern(
    'ACCOUNT_NUMBER_IN_TEXT',
    '문구 안에 적힌 계좌 전체번호',
    RegExp('계좌[^0-9]{0,4}[0-9]{8,}'),
  ),
  SecretPattern(
    'BEARER_TOKEN',
    'Authorization 헤더 형태의 Bearer 토큰',
    RegExp(r'[Bb]earer\s+[A-Za-z0-9._\-]{16,}'),
  ),
  SecretPattern(
    'PRIVATE_KEY_BLOCK',
    'PEM 개인키 블록',
    RegExp('BEGIN [A-Z ]*PRIVATE KEY'),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// 원시 접근 헬퍼 — 「없으면 기본값」을 금지하기 위한 것이다.
// ─────────────────────────────────────────────────────────────────────────────

Map<String, Object?> _requireMap(
  Map<String, Object?> json,
  String key, {
  String? prefix,
}) {
  final Object? v = json[key];
  if (v is! Map<String, Object?>) {
    throw FixtureFormatException(
      '$key 블록이 없거나 객체가 아니다.',
      path: _path(prefix, key),
    );
  }
  return v;
}

String _requireString(Map<String, Object?> json, String key, {String? prefix}) {
  final Object? v = json[key];
  if (v is! String) {
    throw FixtureFormatException(
      '$key 가 없거나 문자열이 아니다.',
      path: _path(prefix, key),
    );
  }
  return v;
}

int _requireInt(Map<String, Object?> json, String key, {String? prefix}) {
  final Object? v = json[key];
  if (v is! int) {
    throw FixtureFormatException(
      '$key 가 없거나 정수가 아니다.',
      path: _path(prefix, key),
    );
  }
  return v;
}

bool _requireBool(Map<String, Object?> json, String key, {String? prefix}) {
  final Object? v = json[key];
  if (v is! bool) {
    throw FixtureFormatException(
      '$key 가 없거나 참·거짓이 아니다.',
      path: _path(prefix, key),
    );
  }
  return v;
}

String _path(String? prefix, String key) =>
    prefix == null ? key : '$prefix.$key';
