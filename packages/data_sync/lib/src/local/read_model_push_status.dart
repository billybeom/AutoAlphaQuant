// 🆕 E11l2c — 읽기 모델 push 로컬 상태 · `row_version` 정책(설계 13 §8 R263 · 01 §8 미결 241 ⓑ ⓓ · 01 §6-4 규칙 5조 ②③ ·
// 로컬 표 `read_model_push`(배치 A 말미 · `table_name` PK · `last_pushed_key` · `last_ok_at` · `row_version` · `status`)).
//
// 🔴 `row_version` = (리스 epoch << 40) + 이 기기 표별 순번 — 기기가 바뀌면(X1 · 비상 회수) epoch 가 오르므로 새 기기의 판이
//    옛 기기의 어떤 판보다 크다(시계 0 · 서버 `row_version` 큰 쪽만 반영 — 규칙 5조 ②). 같은 epoch 안에서는 순번이 오른다.
//    실패한 시도도 판을 쓴다(다음 시도 = +1 · 단조 증가만 지킨다).
// 🔴 status = OK(받아들여짐) · PUSH_LAG(망 · 서버 · 로그인 · 리스 — 다음 깨우기에 다시) · PUSH_FAILED(시크릿 차단 · 행 틀림 ·
//    표 모름 · 응답 꼴 — 사람이 볼 일 · 알림 = 부르는 쪽).
// 🔴 `last_pushed_key` = 통째 판(`snapshot:<행 수>`) — 증분 키 대신 그 표의 지금 모습 전부를 보낸다(백필 = 같은 길).

import 'package:sqlite3/sqlite3.dart';

/// 판 순번이 들어갈 아래 비트 수(epoch 는 그 위 · epoch < 2^22 → bigint 안).
const int kReadModelRowVersionShift = 40;

/// 이 epoch 의 판 바닥(그 epoch 의 첫 판 = 바닥 + 1).
int readModelRowVersionFloor(int epoch) {
  if (epoch <= 0 || epoch >= (1 << 22)) {
    throw ArgumentError.value(epoch, 'epoch', '1 이상 2^22 미만');
  }
  return epoch << kReadModelRowVersionShift;
}

/// push 상태 값(로컬 CHECK 3값).
abstract final class ReadModelPushStates {
  /// 받아들여짐.
  static const String ok = 'OK';

  /// 다음 깨우기에 다시.
  static const String lag = 'PUSH_LAG';

  /// 사람이 볼 일.
  static const String failed = 'PUSH_FAILED';
}

/// 표 하나의 로컬 상태.
class ReadModelPushStatusRow {
  /// 만든다.
  const ReadModelPushStatusRow({
    required this.table,
    required this.status,
    required this.rowVersion,
    required this.lastPushedKey,
    this.lastOkAtUtc,
  });

  /// 표 이름.
  final String table;

  /// 상태.
  final String status;

  /// 마지막으로 쓴 판.
  final int rowVersion;

  /// 마지막 성공의 판 글자(`snapshot:<행 수>` · 성공 전 = 빈 글자).
  final String lastPushedKey;

  /// 마지막 성공 시각.
  final DateTime? lastOkAtUtc;
}

/// 🆕 `read_model_push` 저장소.
class SqliteReadModelPushStatus {
  /// [db] = 지금 모드의 원장 DB.
  SqliteReadModelPushStatus(this._db);

  final Database _db;

  /// [table] 의 다음 판(이 epoch 바닥보다 크고 지금까지 쓴 판보다 크다).
  int nextRowVersion(String table, int epoch) {
    final int floor = readModelRowVersionFloor(epoch);
    final ResultSet rs = _db.select(
      'SELECT row_version FROM read_model_push WHERE table_name = ?',
      <Object?>[table],
    );
    final int used = rs.isEmpty ? 0 : rs.first['row_version'] as int;
    return used >= floor ? used + 1 : floor + 1;
  }

  /// 받아들여짐.
  void recordOk(String table, int rowVersion, int rows, DateTime atUtc) => _put(
    table,
    rowVersion,
    ReadModelPushStates.ok,
    key: 'snapshot:$rows',
    okAt: atUtc.toUtc().toIso8601String(),
  );

  /// 다음에 다시.
  void recordLag(String table, int rowVersion) =>
      _put(table, rowVersion, ReadModelPushStates.lag);

  /// 사람이 볼 일.
  void recordFailed(String table, int rowVersion) =>
      _put(table, rowVersion, ReadModelPushStates.failed);

  /// 표 하나(없으면 null).
  ReadModelPushStatusRow? row(String table) {
    final ResultSet rs = _db.select(
      'SELECT table_name, status, row_version, last_pushed_key, last_ok_at '
      'FROM read_model_push WHERE table_name = ?',
      <Object?>[table],
    );
    if (rs.isEmpty) return null;
    final Row r = rs.first;
    final String? ok = r['last_ok_at'] as String?;
    return ReadModelPushStatusRow(
      table: r['table_name'] as String,
      status: r['status'] as String,
      rowVersion: r['row_version'] as int,
      lastPushedKey: r['last_pushed_key'] as String,
      lastOkAtUtc: ok == null ? null : DateTime.parse(ok).toUtc(),
    );
  }

  void _put(
    String table,
    int rowVersion,
    String status, {
    String? key,
    String? okAt,
  }) {
    _db.execute(
      'INSERT INTO read_model_push(table_name, last_pushed_key, last_ok_at, row_version, status) '
      "VALUES (?, COALESCE(?, ''), ?, ?, ?) "
      'ON CONFLICT(table_name) DO UPDATE SET '
      'last_pushed_key = COALESCE(?, last_pushed_key), '
      'last_ok_at = COALESCE(?, last_ok_at), '
      'row_version = MAX(row_version, excluded.row_version), '
      'status = excluded.status',
      <Object?>[table, key, okAt, rowVersion, status, key, okAt],
    );
  }
}
