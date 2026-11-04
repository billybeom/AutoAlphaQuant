// 🧪 시험 전용 — 키 금고 · 봉함 가짜(설계 13 §8 R44 E2 · E6). 🔴 암호가 아니다.

import 'dart:convert';
import 'dart:typed_data';

import '../security/sealed_box.dart';
import '../security/secret_vault.dart';

/// 메모리 금고 — 호출 기록 · 실패 주입.
class MemorySecretVault implements SecretVault {
  /// 처음 값으로 만든다.
  MemorySecretVault([Map<String, String>? initial]) {
    initial?.forEach((String k, String v) => _m[SecretId(k)] = v);
  }

  final Map<SecretId, String> _m = <SecretId, String>{};

  /// 호출 기록(`read:이름` · `write:이름` · `delete:이름` · `ids`) — 🔴 값은 남기지 않는다.
  final List<String> calls = <String>[];

  /// 이 이름에 쓰기 · 지우기가 실패한다.
  final Set<String> failWritesTo = <String>{};

  /// 이 이름 읽기가 실패한다.
  final Set<String> failReadsOf = <String>{};

  /// 지금 값(시험 확인용).
  String? peek(String id) => _m[SecretId(id)];

  @override
  Future<String?> read(SecretId id) async {
    calls.add('read:${id.value}');
    if (failReadsOf.contains(id.value)) {
      throw SecretVaultError('${id.value}: 읽기 실패(주입)');
    }
    return _m[id];
  }

  @override
  Future<void> write(SecretId id, String value) async {
    calls.add('write:${id.value}');
    if (failWritesTo.contains(id.value)) {
      throw SecretVaultError('${id.value}: 쓰기 실패(주입)');
    }
    _m[id] = value;
  }

  @override
  Future<void> delete(SecretId id) async {
    calls.add('delete:${id.value}');
    if (failWritesTo.contains(id.value)) {
      throw SecretVaultError('${id.value}: 지우기 실패(주입)');
    }
    _m.remove(id);
  }

  @override
  Future<Set<SecretId>> ids() async {
    calls.add('ids');
    return _m.keys.toSet();
  }
}

/// 봉함 가짜 — 머리(키 세대 · aad 길이) + aad + 본문 + 꼬리표(합). [loseKey] = 키 소실(이전 봉함은 못 연다).
class FakeSealedBox implements SealedBox {
  int _generation = 1;

  /// 키를 잃는다(백업 복원 · 재설치 흉내).
  void loseKey() => _generation++;

  static int _tag(List<int> bytes) {
    int h = 0x811c9dc5;
    for (final int b in bytes) {
      h = ((h ^ b) * 0x01000193) & 0xffffffff;
    }
    return h;
  }

  @override
  Future<Uint8List> seal(Uint8List plain, {required String aad}) async {
    final List<int> a = utf8.encode(aad);
    if (a.length > 255) throw ArgumentError('aad 가 길다(가짜 한계 255바이트)');
    final List<int> body = <int>[_generation, a.length, ...a, ...plain];
    final int t = _tag(body);
    return Uint8List.fromList(<int>[
      ...body,
      t >> 24 & 0xff,
      t >> 16 & 0xff,
      t >> 8 & 0xff,
      t & 0xff,
    ]);
  }

  @override
  Future<Uint8List?> open(Uint8List sealed, {required String aad}) async {
    if (sealed.length < 6) return null;
    final List<int> body = sealed.sublist(0, sealed.length - 4);
    final int t =
        sealed[sealed.length - 4] << 24 |
        sealed[sealed.length - 3] << 16 |
        sealed[sealed.length - 2] << 8 |
        sealed[sealed.length - 1];
    if (_tag(body) != t) return null;
    if (body[0] != _generation) return null;
    final int n = body[1];
    if (body.length < 2 + n) return null;
    if (utf8.decode(body.sublist(2, 2 + n), allowMalformed: true) != aad) {
      return null;
    }
    return Uint8List.fromList(body.sublist(2 + n));
  }
}
