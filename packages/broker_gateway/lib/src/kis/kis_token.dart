// KIS 접근토큰 보관(설계 13 §8 R29 L3 · M1-8 «토큰 24h 수명주기 · 만료 5분 전 선갱신»).
//
// 🔴 발급은 1분에 1회(EGW00133)이고 발급할 때마다 휴대폰 알림톡이 온다 — 그래서 24시간 안에는 다시 쓴다.
// 🔵 키 금고(M4-4)가 생기기 전의 보관처다: [MemoryKisTokenStore](시험·한 번 실행) · [FileKisTokenStore](개발 · 저장소 밖 경로).
// 🔴 토큰 값은 `toString`·오류에 나오지 않는다.

import 'dart:convert';
import 'dart:io';

import 'kis_environment.dart';

/// 받은 접근토큰 하나.
class KisToken {
  const KisToken(this.accessToken, this.expiresAt);

  /// 토큰 값(Bearer).
  final String accessToken;

  /// 만료 시각(UTC).
  final DateTime expiresAt;

  /// [now] 기준 [margin] 넘게 남았나.
  bool usableAt(DateTime now, {Duration margin = kKisTokenRenewMargin}) =>
      expiresAt.difference(now) > margin;

  @override
  String toString() => 'KisToken(<가림> · 만료 ${expiresAt.toIso8601String()})';
}

/// 만료 이만큼 전이면 새로 받는다(M1-8).
const Duration kKisTokenRenewMargin = Duration(minutes: 5);

/// 토큰 보관 포트 — 환경마다 한 벌(R29 L3).
abstract interface class KisTokenStore {
  /// [env] 의 토큰(없으면 null).
  KisToken? read(KisEnvironment env);

  /// [env] 의 토큰을 둔다.
  void write(KisEnvironment env, KisToken token);

  /// [env] 의 토큰을 버린다(서버가 무효라고 할 때).
  void clear(KisEnvironment env);
}

/// 메모리 보관 — 프로세스가 끝나면 사라진다.
class MemoryKisTokenStore implements KisTokenStore {
  final Map<KisEnvironment, KisToken> _m = <KisEnvironment, KisToken>{};

  @override
  KisToken? read(KisEnvironment env) => _m[env];

  @override
  void write(KisEnvironment env, KisToken token) => _m[env] = token;

  @override
  void clear(KisEnvironment env) => _m.remove(env);
}

/// 파일 보관(개발용) — 🔴 [file] 은 저장소 밖(예 `%USERPROFILE%\aaq-secrets\kis_tokens.json` · 13 §5-2).
class FileKisTokenStore implements KisTokenStore {
  FileKisTokenStore(this.file);

  final File file;

  Map<String, Object?> _load() {
    if (!file.existsSync()) return <String, Object?>{};
    try {
      final Object? v = jsonDecode(file.readAsStringSync());
      return v is Map<String, Object?> ? v : <String, Object?>{};
    } on FormatException {
      return <String, Object?>{};
    }
  }

  void _save(Map<String, Object?> m) {
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(m));
  }

  @override
  KisToken? read(KisEnvironment env) {
    final Object? e = _load()[env.name];
    if (e is! Map<String, Object?>) return null;
    final Object? t = e['access_token'], x = e['expires_at'];
    if (t is! String || x is! String) return null;
    final DateTime? at = DateTime.tryParse(x);
    return at == null ? null : KisToken(t, at.toUtc());
  }

  @override
  void write(KisEnvironment env, KisToken token) {
    _save(<String, Object?>{
      ..._load(),
      env.name: <String, Object?>{
        'access_token': token.accessToken,
        'expires_at': token.expiresAt.toUtc().toIso8601String(),
      },
    });
  }

  @override
  void clear(KisEnvironment env) => _save(_load()..remove(env.name));
}
