// 키 금고 포트(설계 13 §8 R44 E1 · E2 · 06 M4-4 · 04_안전장치 SAF-901 · SAF-905).
//
// 🔴 여기에 두는 까닭 — 금고를 쓰는 곳이 broker_gateway(KIS 키 · 토큰)와 data_sync(healthchecks · Supabase ·
//    GitHub)인데 01 §1-1 이 둘 사이 의존을 막는다. 둘 다 core_engine 을 의존하고, ui_* 는 core_engine 이 금지라
//    화면은 이 포트에 닿지 못한다.
// 🔴 이름(`SecretId`)은 기록에 나와도 된다 — **값**은 어떤 문자열(`toString` · 오류 · 기록)에도 나오지 않는다.
// 🔵 실물(Android Keystore 로 감싼 저장소) = `app_operator_android` 얇은 어댑터(E11p · D20).

/// 금고 칸 이름 — 소문자 · 숫자 · `.` · `_` · `-` 만(1~64자).
class SecretId {
  /// 이름을 만든다 — 꼴이 아니면 ArgumentError(값이 이름에 섞이는 실수를 막는다).
  SecretId(this.value) {
    if (!_shape.hasMatch(value)) {
      throw ArgumentError.value(value.length, 'SecretId', '이름 꼴이 아니다(길이)');
    }
  }

  static final RegExp _shape = RegExp(r'^[a-z0-9][a-z0-9._-]{0,63}$');

  /// 이름.
  final String value;

  @override
  bool operator ==(Object other) => other is SecretId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'SecretId($value)';
}

/// 키 금고 포트 — 🔴 비동기(Keystore 는 플랫폼 호출이다).
abstract interface class SecretVault {
  /// [id] 의 값(없으면 null).
  Future<String?> read(SecretId id);

  /// [id] 에 [value] 를 둔다(덮어쓴다).
  Future<void> write(SecretId id, String value);

  /// [id] 를 지운다(없어도 성공).
  Future<void> delete(SecretId id);

  /// 저장된 이름 전부 — 시크릿 스캔이 정확 값 목록을 손으로 들고 다니지 않게(R44 E2).
  Future<Set<SecretId>> ids();
}

/// 금고 실패 — 🔴 메시지에 값이 없다(이름 · 사유만).
class SecretVaultError implements Exception {
  /// 실패를 만든다.
  const SecretVaultError(this.message);

  /// 사유(값 0).
  final String message;

  @override
  String toString() => 'SecretVaultError: $message';
}

/// 금고에 든 값 전부(스캔 · 가림용 · 이름 순).
///
/// 🔴 한 칸이라도 못 읽으면 실패를 그대로 던진다 — 건너뛰면 그 값이 스캔에서 빠진 채 «통과»가 된다.
Future<List<String>> readAllSecretValues(SecretVault vault) async {
  final List<SecretId> names = (await vault.ids()).toList()
    ..sort((SecretId a, SecretId b) => a.value.compareTo(b.value));
  final List<String> out = <String>[];
  for (final SecretId id in names) {
    final String? v = await vault.read(id);
    if (v != null && v.isNotEmpty) out.add(v);
  }
  return out;
}
