// 🆕 E11q-c1b — 키 세트 검증 기록(`credential_registry` · 설계 13 §8 R196 · 미결 207 ⓑ · 02 DDL «값은 저장하지 않는다»).
//
// 🔴 값 0 — 별칭 · 세트 · 금고 칸 접두(`kis.live` 꼴) · 건강 · 마지막 검증 시각만. 별칭 · 접두 꼴이 아니면 [ArgumentError]
//    (키 · 계좌번호가 이 표에 들어올 길을 막는다 — 소문자 · 숫자 · `_` · `.` · 40자 이하).
// 🔴 쓰는 곳 = 조회 검증 결과(통과 = OK · 거절 = INVALID) · 시각 = 기기 시계(판정 축 아님 — 신선도 수치 0).
// 🔴 파일 = 지금 운영 파일(모의 기간 = 모의 파일) · simToAuto 커밋이 실전 세트 행을 실전 파일로 옮긴다(`sim_to_auto_carry`).

import 'package:core_engine/core_engine.dart'
    show CredentialHealthCodes, CredentialHealthRecord;
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:sqlite3/sqlite3.dart';

final RegExp _token = RegExp(r'^[a-z0-9_.]{1,40}$');
final RegExp _kind = RegExp(r'^[A-Z_]{1,40}$');
final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

/// 키 세트 검증 기록 저장.
class SqliteCredentialRegistry {
  /// 저장을 만든다.
  SqliteCredentialRegistry(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  /// 다시 낼 표.
  static const Set<String> watchedTables = <String>{'credential_registry'};

  /// 🔴 조회 검증 결과를 적는다 — [passed] = OK · 아니면 INVALID · 마지막 검증 시각 = 지금(기기).
  void recordVerification({
    required String alias,
    required String kind,
    required String keystoreRef,
    required bool passed,
  }) {
    if (!_token.hasMatch(alias)) {
      throw ArgumentError.value('<가림>', 'alias', '별칭 꼴이 아니다');
    }
    if (!_token.hasMatch(keystoreRef)) {
      throw ArgumentError.value('<가림>', 'keystoreRef', '금고 칸 접두 꼴이 아니다');
    }
    if (!_kind.hasMatch(kind)) {
      throw ArgumentError.value('<가림>', 'kind', '세트 표기 꼴이 아니다');
    }
    _db.execute(
      'INSERT INTO credential_registry (alias, kind, keystore_ref, expires_at, last_verified_at, health) '
      'VALUES (?, ?, ?, NULL, ?, ?) '
      'ON CONFLICT(alias) DO UPDATE SET kind = excluded.kind, keystore_ref = excluded.keystore_ref, '
      'last_verified_at = excluded.last_verified_at, health = excluded.health',
      <Object?>[
        alias,
        kind,
        keystoreRef,
        _clock.nowUtc().toUtc().toIso8601String(),
        passed ? CredentialHealthCodes.ok : CredentialHealthCodes.invalid,
      ],
    );
  }

  /// 기록 전부(별칭 차례) — 시각에 시차가 없으면 [FormatException].
  List<CredentialHealthRecord> records() => credentialRecordsOf(_db);
}

/// [db] 의 키 세트 검증 기록 전부(읽기만 · 별칭 차례) — 시각에 시차가 없으면 [FormatException].
List<CredentialHealthRecord> credentialRecordsOf(Database db) =>
    <CredentialHealthRecord>[
      for (final Row r in db.select(
        'SELECT kind, health, last_verified_at FROM credential_registry ORDER BY alias',
      ))
        CredentialHealthRecord(
          kind: r['kind'] as String,
          health: r['health'] as String,
          lastVerifiedAtUtc: _instant(r['last_verified_at']),
        ),
    ];

DateTime? _instant(Object? v) {
  if (v == null) return null;
  if (v is! String || !_offset.hasMatch(v)) {
    throw FormatException('credential_registry 시각에 시차가 없다', v);
  }
  return DateTime.parse(v).toUtc();
}
