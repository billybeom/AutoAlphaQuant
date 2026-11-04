// KIS 접근토큰 보관(설계 13 §8 R29 L3 · M1-8 «토큰 24h 수명주기 · 만료 5분 전 선갱신» · R44 E8 · 지도 D18 · X11).
//
// 🔴 발급은 1분에 1회(EGW00133)이고 발급할 때마다 휴대폰 알림톡이 온다 — 그래서 24시간 안에는 다시 쓴다.
// 🔴 키 = (환경 · 앱키 지문) — 앱키는 종합계좌 단위라 같은 환경에 두 벌(실전 · ISA)이 있을 수 있다. 환경 하나만 키로
//    쓰면 두 계좌 토큰이 서로 덮고, 덮일 때마다 재발급(알림톡)이 난다(X11).
// 🔵 보관처 셋: [MemoryKisTokenStore](시험 · 한 번 실행) · [FileKisTokenStore](개발 · 저장소 밖 경로) ·
//    [VaultKisTokenStore](키 금고 — 기동 때 금고 → 메모리 · 쓰기 = 비동기 저장 · D18).
// 🔴 토큰 값은 `toString`·오류에 나오지 않는다.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show SecretId, SecretVault, secretFingerprint;

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

/// 토큰 보관 키 — 환경 · 앱키 지문(R44 E8 · 값 없이 «어느 키인가»).
class KisTokenKey {
  /// 키를 만든다.
  const KisTokenKey(this.environment, this.appKeyFingerprint);

  /// [credentials] 의 키.
  factory KisTokenKey.of(KisCredentials credentials) => KisTokenKey(
    credentials.environment,
    secretFingerprint(credentials.appKey),
  );

  /// 환경.
  final KisEnvironment environment;

  /// 앱키 지문(sha256 앞 8).
  final String appKeyFingerprint;

  /// 보관 칸 이름 — `환경:지문`.
  String get slot => '${environment.name}:$appKeyFingerprint';

  @override
  bool operator ==(Object other) =>
      other is KisTokenKey &&
      other.environment == environment &&
      other.appKeyFingerprint == appKeyFingerprint;

  @override
  int get hashCode => Object.hash(environment, appKeyFingerprint);

  @override
  String toString() => 'KisTokenKey($slot)';
}

/// 토큰 보관 포트 — 🔴 동기(주문 경로 코드를 바꾸지 않는다 · D18) · 키 = (환경 · 앱키 지문).
abstract interface class KisTokenStore {
  /// [key] 의 토큰(없으면 null).
  KisToken? read(KisTokenKey key);

  /// [key] 의 토큰을 둔다.
  void write(KisTokenKey key, KisToken token);

  /// [key] 의 토큰을 버린다(서버가 무효라고 할 때).
  void clear(KisTokenKey key);
}

/// 메모리 보관 — 프로세스가 끝나면 사라진다.
class MemoryKisTokenStore implements KisTokenStore {
  final Map<KisTokenKey, KisToken> _m = <KisTokenKey, KisToken>{};

  @override
  KisToken? read(KisTokenKey key) => _m[key];

  @override
  void write(KisTokenKey key, KisToken token) => _m[key] = token;

  @override
  void clear(KisTokenKey key) => _m.remove(key);
}

Map<String, Object?> _encodeToken(KisToken t) => <String, Object?>{
  'access_token': t.accessToken,
  'expires_at': t.expiresAt.toUtc().toIso8601String(),
};

KisToken? _decodeToken(Object? e) {
  if (e is! Map<String, Object?>) return null;
  final Object? t = e['access_token'], x = e['expires_at'];
  if (t is! String || x is! String) return null;
  final DateTime? at = DateTime.tryParse(x);
  return at == null ? null : KisToken(t, at.toUtc());
}

Map<String, Object?> _decodeMap(String? raw) {
  if (raw == null || raw.isEmpty) return <String, Object?>{};
  try {
    final Object? v = jsonDecode(raw);
    return v is Map<String, Object?> ? v : <String, Object?>{};
  } on FormatException {
    return <String, Object?>{};
  }
}

/// 파일 보관(개발용) — 🔴 [file] 은 저장소 밖(예 `%USERPROFILE%\aaq-secrets\kis_tokens.json` · 13 §5-2).
///
/// 칸 이름 = `환경:지문`(R44 E8). 옛 꼴(`mock` · `live`) 칸은 읽지 않는다 — 첫 실행에 1회 재발급된다.
class FileKisTokenStore implements KisTokenStore {
  FileKisTokenStore(this.file);

  final File file;

  Map<String, Object?> _load() => file.existsSync()
      ? _decodeMap(file.readAsStringSync())
      : <String, Object?>{};

  void _save(Map<String, Object?> m) {
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(m));
  }

  @override
  KisToken? read(KisTokenKey key) => _decodeToken(_load()[key.slot]);

  @override
  void write(KisTokenKey key, KisToken token) {
    _save(<String, Object?>{..._load(), key.slot: _encodeToken(token)});
  }

  @override
  void clear(KisTokenKey key) => _save(_load()..remove(key.slot));
}

/// 금고 보관(R44 E8 · D18) — 기동 때 금고 한 칸([vaultId])을 메모리로 올리고, 쓰기 · 지우기는 메모리에 바로 ·
/// 금고에는 비동기로(부른 순서대로) 남긴다.
///
/// 🔴 금고 쓰기 실패는 던지지 않는다 — 센다([writeFailures]). 메모리 토큰은 그대로 쓰고, 다음 기동에 1회 재발급된다.
/// 🔴 기동 때 금고를 못 읽거나 칸이 깨졌으면 빈 것으로 시작한다([loadFailed]) — 토큰은 캐시라 매매를 막지 않는다.
class VaultKisTokenStore implements KisTokenStore {
  VaultKisTokenStore._(this._vault, this._mem, {required this.loadFailed});

  /// 금고 칸 이름.
  static final SecretId vaultId = SecretId('kis.tokens');

  /// 금고에서 올린다.
  static Future<VaultKisTokenStore> load(SecretVault vault) async {
    String? raw;
    bool failed = false;
    try {
      raw = await vault.read(vaultId);
    } on Object {
      failed = true;
    }
    final Map<String, KisToken> mem = <String, KisToken>{};
    _decodeMap(raw).forEach((String slot, Object? e) {
      final KisToken? t = _decodeToken(e);
      if (t != null) mem[slot] = t;
    });
    return VaultKisTokenStore._(vault, mem, loadFailed: failed);
  }

  final SecretVault _vault;
  final Map<String, KisToken> _mem;
  Future<void> _chain = Future<void>.value();

  /// 기동 때 금고를 못 읽었나.
  final bool loadFailed;

  /// 금고 쓰기가 실패한 횟수.
  int writeFailures = 0;

  @override
  KisToken? read(KisTokenKey key) => _mem[key.slot];

  @override
  void write(KisTokenKey key, KisToken token) {
    _mem[key.slot] = token;
    _persist();
  }

  @override
  void clear(KisTokenKey key) {
    _mem.remove(key.slot);
    _persist();
  }

  void _persist() {
    // 부른 그 순간의 내용을 찍어 둔다 — 늦게 끝난 쓰기가 나중 내용을 덮지 않게(순서 보존 사슬).
    final String snapshot = jsonEncode(<String, Object?>{
      for (final MapEntry<String, KisToken> e in _mem.entries)
        e.key: _encodeToken(e.value),
    });
    _chain = _chain.then((_) async {
      try {
        await _vault.write(vaultId, snapshot);
      } on Object {
        writeFailures++;
      }
    });
  }

  /// 밀린 금고 쓰기가 끝날 때까지 기다린다(종료 · 시험).
  Future<void> flush() => _chain;

  @override
  String toString() =>
      'VaultKisTokenStore(${_mem.length}칸 · 쓰기 실패 $writeFailures)';
}
