// 시크릿 스캔 게이트(설계 13 §8 R44 E7 · 06 M4-6 · 지도 D16 · 04_안전장치 SAF-904).
//
// 세 갈래로 찾는다:
//  ① **정확 값** — 금고에 든 값 전부(8자 이상). 계좌번호 8자리는 여기서 잡는다.
//  ② **접두 패턴** — `ya29.` · `1//` · `ghp_`(gho · ghu · ghs · ghr) · `github_pat_` · `Bearer ` + 20자 이상.
//  ③ **시크릿 필드 이름**(SAF-904) — `appkey` · `appsecret` · `authorization` · `access_token` · `hashkey` ·
//     `refresh_token` · `approval_key` 에 가림 아닌 값. KIS 키 꼴을 몰라도 응답 · 기록에 섞인 키를 잡는다.
// 🔴 맨 «8자리 숫자» 패턴은 쓰지 않는다 — 체결조회 `ord_dt` · 주문번호가 매일 P1 을 낸다(경보 피로 규칙).
// 🔴 결과에 값 · 발췌가 없다 — 종류 · 줄 · 칸 · (정확 값이면) 지문만.
// 🔴 막히면 다시 시도하지 않는다 — 부르는 쪽(아카이브 E11n · push E11l2)이 P1 을 낸다(알림 코드 = 계약 1.17.0 창).
// 🟡 KIS 앱키 꼴 패턴은 발주자 확인 뒤(Claude 는 키를 못 본다).

import 'package:core_engine/core_engine.dart'
    show kMinRedactLength, kRedacted, secretFingerprint;

/// 찾은 것의 종류.
enum SecretFindingKind {
  /// 금고에 든 값과 같다.
  exactValue,

  /// Google 접근 토큰(`ya29.`).
  googleAccessToken,

  /// Google 갱신 토큰(`1//`).
  googleRefreshToken,

  /// GitHub 토큰(`ghp_` · `github_pat_` 등).
  githubToken,

  /// `Bearer` 뒤 토큰.
  bearerToken,

  /// 시크릿 필드 이름에 가림 아닌 값.
  secretField,
}

/// 찾은 것 하나 — 🔴 값 · 발췌 없음.
class SecretFinding {
  /// 찾은 것을 만든다.
  const SecretFinding({
    required this.kind,
    required this.line,
    required this.column,
    this.fingerprint,
    this.field,
  });

  /// 종류.
  final SecretFindingKind kind;

  /// 줄(1부터).
  final int line;

  /// 칸(1부터 · UTF-16 단위).
  final int column;

  /// 정확 값이면 그 값의 지문(앞 8).
  final String? fingerprint;

  /// 시크릿 필드면 필드 이름(소문자).
  final String? field;

  @override
  bool operator ==(Object other) =>
      other is SecretFinding &&
      other.kind == kind &&
      other.line == line &&
      other.column == column &&
      other.fingerprint == fingerprint &&
      other.field == field;

  @override
  int get hashCode => Object.hash(kind, line, column, fingerprint, field);

  @override
  String toString() =>
      '${kind.name}@$line:$column'
      '${fingerprint == null ? '' : ' 지문 $fingerprint'}'
      '${field == null ? '' : ' 필드 $field'}';
}

/// 스캔 결과.
class SecretScanResult {
  /// 결과를 만든다.
  const SecretScanResult(this.source, this.findings);

  /// 무엇을 봤나(파일 경로 등 — 값이 아니다).
  final String source;

  /// 찾은 것(위치 순).
  final List<SecretFinding> findings;

  /// 막는가 — 하나라도 찾으면. 🔴 다시 시도하지 않는다(P1).
  bool get blocked => findings.isNotEmpty;

  @override
  String toString() => blocked
      ? 'SecretScan($source): 막음 ${findings.length}건 — ${findings.join(' · ')}'
      : 'SecretScan($source): 통과';
}

final List<(SecretFindingKind, RegExp)>
_prefixPatterns = <(SecretFindingKind, RegExp)>[
  (SecretFindingKind.googleAccessToken, RegExp(r'ya29\.[0-9A-Za-z_\-]{20,}')),
  (SecretFindingKind.googleRefreshToken, RegExp(r'1//[0-9A-Za-z_\-]{20,}')),
  (
    SecretFindingKind.githubToken,
    RegExp(
      r'(?:ghp|gho|ghu|ghs|ghr)_[0-9A-Za-z]{30,}|github_pat_[0-9A-Za-z_]{40,}',
    ),
  ),
  (
    SecretFindingKind.bearerToken,
    RegExp(r'[Bb][Ee][Aa][Rr][Ee][Rr]\s+[0-9A-Za-z._~+/\-]{20,}=*'),
  ),
];

/// 시크릿 필드 이름(소문자 · SAF-904 + 갱신 토큰 · 웹소켓 승인키).
const Set<String> kSecretFieldNames = <String>{
  'appkey',
  'appsecret',
  'authorization',
  'access_token',
  'hashkey',
  'refresh_token',
  'approval_key',
};

// JSON `"이름": "값"`.
final RegExp _jsonField = RegExp(r'"([A-Za-z_]+)"\s*:\s*"([^"\\]*)"');

// `이름=값` · `이름: 값`(환경 변수 · 쿼리 · 설정) — `KIS_APP_KEY=` 는 `APP_KEY=` 로 잡힌다.
// 🔴 이름 앞 접두 묶음(`(?:\w+_)*`)은 두지 않는다 — 긴 영숫자 덩어리(base64)에서 되짚기가 제곱으로 는다.
final RegExp _kvField = RegExp(
  '(app_?key|app_?secret|access_?token|refresh_?token|hash_?key|approval_?key)'
  '\\s*[=:]\\s*([^\\s,&"\'}\\]]+)',
  caseSensitive: false,
);

String _norm(String name) => name.toLowerCase().replaceAll('_', '');

final Set<String> _normFieldNames = kSecretFieldNames.map(_norm).toSet();

/// 가림 값인가 — 빈 값 · `<가림>` · `…` 마스킹 · 별표 · `redacted`.
bool _looksMasked(String v) {
  final String t = v.trim();
  if (t.isEmpty) return true;
  if (t.contains(kRedacted) || t.contains('…')) return true;
  if (RegExp(r'^[*•xX#\-]+$').hasMatch(t)) return true;
  if (t.toLowerCase().contains('redacted')) return true;
  return false;
}

class _Hit {
  _Hit(this.start, this.end, this.kind, {this.fingerprint, this.field});
  final int start, end;
  final SecretFindingKind kind;
  final String? fingerprint, field;
}

/// [text] 를 스캔한다(R44 E7). [exactValues] = 금고의 값 전부(`readAllSecretValues`) — 8자 미만은 무시한다.
SecretScanResult scanForSecrets(
  String text, {
  required Iterable<String> exactValues,
  String source = '',
}) {
  final List<_Hit> hits = <_Hit>[];
  for (final String v in exactValues.toSet()) {
    if (v.length < kMinRedactLength) continue;
    final String fp = secretFingerprint(v);
    int from = 0;
    while (true) {
      final int at = text.indexOf(v, from);
      if (at < 0) break;
      hits.add(
        _Hit(at, at + v.length, SecretFindingKind.exactValue, fingerprint: fp),
      );
      from = at + v.length;
    }
  }
  for (final (SecretFindingKind kind, RegExp re) in _prefixPatterns) {
    for (final RegExpMatch m in re.allMatches(text)) {
      hits.add(_Hit(m.start, m.end, kind));
    }
  }
  for (final RegExpMatch m in _jsonField.allMatches(text)) {
    final String name = m.group(1)!;
    final String value = m.group(2)!;
    if (!_normFieldNames.contains(_norm(name))) continue;
    if (_looksMasked(value) || value.length < kMinRedactLength) continue;
    final int vs = m.end - 1 - value.length;
    hits.add(
      _Hit(
        vs,
        vs + value.length,
        SecretFindingKind.secretField,
        field: name.toLowerCase(),
      ),
    );
  }
  for (final RegExpMatch m in _kvField.allMatches(text)) {
    final String value = m.group(2)!;
    if (_looksMasked(value) || value.length < kMinRedactLength) continue;
    final int vs = m.end - value.length;
    hits.add(
      _Hit(
        vs,
        m.end,
        SecretFindingKind.secretField,
        field: m.group(1)!.toLowerCase(),
      ),
    );
  }
  // 위치 순 · 같은 자리면 긴 것 → 정확 값 먼저 · 앞의 것 안에 든 것은 뺀다(같은 값을 두 번 세지 않는다).
  hits.sort((_Hit a, _Hit b) {
    final int c = a.start.compareTo(b.start);
    if (c != 0) return c;
    final int l = (b.end - b.start).compareTo(a.end - a.start);
    if (l != 0) return l;
    return a.kind.index.compareTo(b.kind.index);
  });
  final List<_Hit> kept = <_Hit>[];
  for (final _Hit h in hits) {
    if (kept.isNotEmpty &&
        h.start >= kept.last.start &&
        h.end <= kept.last.end) {
      continue;
    }
    kept.add(h);
  }
  final List<int> lineStarts = <int>[0];
  for (int i = 0; i < text.length; i++) {
    if (text.codeUnitAt(i) == 0x0a) lineStarts.add(i + 1);
  }
  SecretFinding at(_Hit h) {
    int lo = 0, hi = lineStarts.length - 1;
    while (lo < hi) {
      final int mid = (lo + hi + 1) >> 1;
      if (lineStarts[mid] <= h.start) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return SecretFinding(
      kind: h.kind,
      line: lo + 1,
      column: h.start - lineStarts[lo] + 1,
      fingerprint: h.fingerprint,
      field: h.field,
    );
  }

  return SecretScanResult(source, kept.map(at).toList());
}
