// X1-3 비상 앞쪽 복원 전 기록 · 재발급 기록(E16t3c · 설계 13 §8 R244 · 01 §8 미결 218 ⓓ · 06 X1-3 · 08 그림 9-2).
//
// 🔴 새 폰은 복원 전에 live 원장이 없다 → 행 = 늘 열린 sim 원장의 `command_inbox`(O-04 ⑤ 첫 클레임 기록 R229 F5 선례 · 스키마 0 ·
//    덧붙이기만 · 고치지 않는다):
//    · kind `X1_EMERGENCY_REVOKE` · state `EXECUTED` = 회수 한 판 — command_id = 판(`rec-…`) · 🔴 ingested_at = 서버 REVOKED 시각
//      (`lease_revoke` 의 즉시 만료 시각 · 기기 시계 0) · lease_epoch = 회수 epoch · decision_id = 비상 선언 결정 · run_mode `LIVE`
//      (X1 = live 만) · payload_digest = 새 복구 코드 해시(평문 0).
//    · 같은 kind · state `REJECTED` = 서버 거부(감사만 · 상태에 쓰지 않는다) — command_id = 명령 id · reject_reason_code = 서버 글자.
//    · kind `X1_REISSUE_RECORD` · state `EXECUTED` = 재발급 항목 하나 — command_id = `{판}:{항목}`(같은 항목 둘 = PK 거부) ·
//      ingested_at = 신뢰 시각 · decision_id = 판 · payload_digest = 새 값 지문(sha256 앞 8 · 확인만 항목 = 빈 글자) · 🔴 값 0.
// 🔴 판정(재발급 차례 · 해당 없음 · 키 재사용 · 신뢰 시각) = core `ReissueChecklist` · 펜싱 = core `fencingVerdictOf`.

import 'package:core_engine/core_engine.dart'
    show
        ReissueChecklist,
        ReissueItem,
        X1EmergencyFacts,
        X1ReissueRecord,
        kX1EmergencyRevokeKind,
        kX1ReissueRecordKind,
        kstDateText,
        reissueChecklistOf;
import 'package:domain_contracts/domain_contracts.dart'
    show RunMode, X1FencingResultCodes;
import 'package:sqlite3/sqlite3.dart';

/// 회수 한 판(🔴 평문 0).
class X1EmergencyRecord {
  /// 만든다.
  const X1EmergencyRecord({
    required this.runId,
    required this.operatorEpoch,
    required this.revokedAtUtc,
    required this.newCodeHash,
    required this.decisionId,
  });

  /// 판(`rec-…`).
  final String runId;

  /// 회수 epoch.
  final int operatorEpoch;

  /// 서버 REVOKED 시각.
  final DateTime revokedAtUtc;

  /// 새 복구 코드 해시.
  final String newCodeHash;

  /// 비상 선언 결정.
  final String decisionId;

  @override
  String toString() => 'X1EmergencyRecord($runId · epoch $operatorEpoch)';
}

/// 비상 앞쪽 기록 저장소(sim 원장 `command_inbox`).
class SqliteX1EmergencyStore {
  /// 만든다 — [_db] = sim 원장(늘 열림).
  SqliteX1EmergencyStore(this._db);

  final Database _db;

  /// 마지막 회수 판(없음 = null) · 꼴 아님 = [FormatException].
  X1EmergencyRecord? latest() {
    final ResultSet rs = _db.select(
      'SELECT command_id, ingested_at, lease_epoch, payload_digest, decision_id FROM command_inbox '
      "WHERE kind = ? AND state = 'EXECUTED' ORDER BY rowid DESC LIMIT 1",
      <Object?>[kX1EmergencyRevokeKind],
    );
    if (rs.isEmpty) return null;
    final Row r = rs.single;
    final Object? epoch = r['lease_epoch'];
    final Object? decision = r['decision_id'];
    if (epoch is! int || epoch < 1 || decision is! String) {
      throw FormatException('비상 회수 기록 꼴이 아니다', r['command_id']);
    }
    return X1EmergencyRecord(
      runId: r['command_id'] as String,
      operatorEpoch: epoch,
      revokedAtUtc: DateTime.parse(r['ingested_at'] as String).toUtc(),
      newCodeHash: r['payload_digest'] as String,
      decisionId: decision,
    );
  }

  /// 그 한국 날의 다음 순번(회수 판 · 거부 행은 세지 않는다).
  int nextSeq(DateTime atUtc) =>
      (_db.select(
            'SELECT COUNT(*) AS n FROM command_inbox WHERE kind = ? AND command_id LIKE ?',
            <Object?>[kX1EmergencyRevokeKind, 'rec-${kstDateText(atUtc)}-%'],
          ).single['n']
          as int) +
      1;

  /// 🔴 회수 한 판을 적는다.
  void recordRevoked({
    required String runId,
    required String decisionId,
    required int operatorEpoch,
    required DateTime revokedAtUtc,
    required String newCodeHash,
  }) {
    _db.execute(
      'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
      'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
      "VALUES (?, ?, ?, 'EXECUTED', '실행됨', NULL, ?, ?, NULL, ?, ?)",
      <Object?>[
        runId,
        kX1EmergencyRevokeKind,
        revokedAtUtc.toUtc().toIso8601String(),
        decisionId,
        RunMode.live.wire,
        operatorEpoch,
        newCodeHash,
      ],
    );
  }

  /// 서버 거부 한 행(감사만).
  void recordRejected({
    required String commandId,
    required String code,
    required String newCodeHash,
    required DateTime atUtc,
  }) {
    _db.execute(
      'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
      'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
      "VALUES (?, ?, ?, 'REJECTED', '거부됨', ?, NULL, ?, NULL, NULL, ?)",
      <Object?>[
        commandId,
        kX1EmergencyRevokeKind,
        atUtc.toUtc().toIso8601String(),
        code,
        RunMode.live.wire,
        newCodeHash,
      ],
    );
  }

  /// [runId] 의 재발급 기록(적은 차례).
  List<X1ReissueRecord> reissues(String runId) => <X1ReissueRecord>[
    for (final Row r in _db.select(
      'SELECT command_id, ingested_at, payload_digest FROM command_inbox '
      "WHERE kind = ? AND state = 'EXECUTED' AND decision_id = ? ORDER BY rowid",
      <Object?>[kX1ReissueRecordKind, runId],
    ))
      _reissueOf(runId, r),
  ];

  static X1ReissueRecord _reissueOf(String runId, Row r) {
    final String id = r['command_id'] as String;
    final String wire = id.startsWith('$runId:')
        ? id.substring(runId.length + 1)
        : throw FormatException('재발급 기록 이름이 아니다', id);
    final ReissueItem item = ReissueItem.values.firstWhere(
      (ReissueItem i) => i.wire == wire,
      orElse: () => throw FormatException('재발급 항목이 아니다', wire),
    );
    final String digest = r['payload_digest'] as String;
    return X1ReissueRecord(
      item: item,
      fingerprint: digest.isEmpty ? null : digest,
      atUtc: DateTime.parse(r['ingested_at'] as String).toUtc(),
    );
  }

  /// 🔴 화면 재료 — 마지막 회수 판 + 재발급 진행(없음 = null) · 어긋난 기록 = [FormatException].
  X1EmergencyFacts? facts() {
    final X1EmergencyRecord? e = latest();
    if (e == null) return null;
    return X1EmergencyFacts(
      runId: e.runId,
      operatorEpoch: e.operatorEpoch,
      revokedAtUtc: e.revokedAtUtc,
      checklist: reissueChecklistOf(reissues(e.runId)),
    );
  }

  /// 🔴 재발급 항목 하나 — 거부 = 코드(회수 판 아님 = `FENCING_NOT_STARTED` · 그 밖 = core 체크리스트 글자) · 받음 = null(한 행).
  ///
  /// [fingerprint] = 새 값 지문(확인만 항목 = null) · [priorFingerprints] = 옛 값 지문(이 폰 금고 · 🔴 옛 폰 금고는 새 폰에 없다).
  String? recordReissue({
    required String runId,
    required ReissueItem item,
    required String? fingerprint,
    required Set<String> priorFingerprints,
    required DateTime? trustedNowUtc,
  }) {
    final X1EmergencyRecord? e = latest();
    if (e == null || e.runId != runId) return X1FencingResultCodes.notStarted;
    final ReissueChecklist c = reissueChecklistOf(reissues(runId));
    final (ReissueChecklist? next, String? code) = c.accept(
      item,
      fingerprint: fingerprint,
      priorFingerprints: priorFingerprints,
      trustedNowUtc: trustedNowUtc,
    );
    if (next == null) return code;
    _db.execute(
      'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
      'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
      "VALUES (?, ?, ?, 'EXECUTED', '실행됨', NULL, ?, ?, NULL, ?, ?)",
      <Object?>[
        '$runId:${item.wire}',
        kX1ReissueRecordKind,
        trustedNowUtc!.toUtc().toIso8601String(),
        runId,
        RunMode.live.wire,
        e.operatorEpoch,
        fingerprint ?? '',
      ],
    );
    return null;
  }
}
