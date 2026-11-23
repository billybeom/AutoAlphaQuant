// 안전 사건 postmortem 쓰기 · 기한 넘김 읽기(03_운영 카드 ⑤ · SPEC 04 §3-5 ④ · §2 v2.40 · 설계 13 §8 R63 V2 · V3).
//
// 🔴 postmortem = 한 번만(덮지 않는다) · SEV2 · SEV3 = 같은 트랜잭션에서 건을 닫는다 · SEV1(STOPPED) = 결정이 닫는다(E13d2).
// 🔴 같은 command_id 재전달 = 처음 결과 그대로(command_inbox 멱등).
// 🆕 E11q-d2 — 열린 사건 읽기(`D-01` 장애 배너 원천 · 06 M4-12 ①) · 지켜보는 표.

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;

/// `command_inbox.kind`.
const String kPostmortemCommandKind = 'INCIDENT_POSTMORTEM';

/// postmortem 결과.
class PostmortemResult {
  /// 결과를 만든다.
  const PostmortemResult({
    required this.executed,
    this.replayed = false,
    this.reasonCode,
    this.closed = false,
  });

  /// 실행됐나(재전달이면 처음 결과).
  final bool executed;

  /// 같은 command_id 재전달이었나.
  final bool replayed;

  /// 거부 코드.
  final String? reasonCode;

  /// 이번에 건을 닫았나(SEV2 · SEV3).
  final bool closed;
}

/// 기한을 넘긴 건 한 줄.
class OverduePostmortem {
  /// 줄을 만든다.
  const OverduePostmortem({
    required this.incidentId,
    required this.severity,
    required this.category,
    required this.dueAtUtc,
  });

  /// id · 심각도 · 분류.
  final String incidentId, severity, category;

  /// 기한.
  final DateTime dueAtUtc;
}

/// 🆕 E11q-d2 — `D-01` 장애 배너가 지켜보는 표(같은 연결의 `db.updates` · 건이 열리고 닫히는 곳 하나).
const Set<String> kIncidentWatchedTables = <String>{'incidents'};

/// 🆕 E11q-d2 — 열린 사건(`resolved_at` 빈칸 · 배너 원천 · 차례 = 엔진 `incidentBannerVmOf` 몫 — 여기선 id 차례).
List<OpenIncident> openIncidentsOf(Database db) => <OpenIncident>[
  for (final Row r in db.select(
    'SELECT incident_id, occurred_at, severity, category, due_at FROM incidents '
    'WHERE resolved_at IS NULL ORDER BY incident_id',
  ))
    OpenIncident(
      incidentId: r['incident_id'] as String,
      severity: r['severity'] as String,
      category: r['category'] as String,
      occurredAtUtc: DateTime.parse(r['occurred_at'] as String).toUtc(),
      dueAtUtc: switch (r['due_at']) {
        final String due => DateTime.parse(due).toUtc(),
        _ => null,
      },
    ),
];

/// 안전 사건 저장(R63).
class SqliteIncidentStore {
  /// 저장을 만든다.
  SqliteIncidentStore(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  void _command(
    String commandId,
    String digest, {
    String? rejectCode,
    String? incidentId,
  }) => _db.execute(
    'INSERT INTO command_inbox(command_id, kind, ingested_at, state, state_label, reject_reason_code, '
    'decision_id, run_mode, operating_mode, lease_epoch, payload_digest) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, NULL, NULL, NULL, ?)',
    <Object?>[
      commandId,
      kPostmortemCommandKind,
      _clock.nowUtc().toUtc().toIso8601String(),
      rejectCode == null ? 'EXECUTED' : 'REJECTED',
      rejectCode == null ? '실행됨' : '거부됨 — $rejectCode',
      rejectCode,
      incidentId,
      digest,
    ],
  );

  /// postmortem 을 쓴다(R63 V2).
  PostmortemResult recordPostmortem({
    required String commandId,
    required String payloadDigest,
    required String incidentId,
    required String text,
  }) {
    final ResultSet again = _db.select(
      'SELECT state, reject_reason_code FROM command_inbox WHERE command_id = ?',
      <Object?>[commandId],
    );
    if (again.isNotEmpty) {
      final bool ok = again.first['state'] == 'EXECUTED';
      return PostmortemResult(
        executed: ok,
        replayed: true,
        reasonCode: again.first['reject_reason_code'] as String?,
        closed:
            ok &&
            _db.select(
              'SELECT 1 FROM incidents WHERE incident_id = ? AND resolved_at IS NOT NULL',
              <Object?>[incidentId],
            ).isNotEmpty,
      );
    }
    final ResultSet rs = _db.select(
      'SELECT severity, postmortem FROM incidents WHERE incident_id = ?',
      <Object?>[incidentId],
    );
    final String? code = postmortemRejectCode(
      incidentExists: rs.isNotEmpty,
      existingPostmortem: rs.isEmpty ? null : rs.first['postmortem'] as String?,
      text: text,
    );
    if (code != null) {
      _command(
        commandId,
        payloadDigest,
        rejectCode: code,
        incidentId: incidentId,
      );
      return PostmortemResult(executed: false, reasonCode: code);
    }
    final bool close = postmortemClosesIncident(rs.first['severity'] as String);
    final String at = _clock.nowUtc().toUtc().toIso8601String();
    inLedgerTransaction(_db, () {
      // SEV2 · SEV3 = postmortem 이 건을 닫는다(이미 닫혔으면 그 시각 그대로) · SEV1 = 열린 채.
      _db.execute(
        'UPDATE incidents SET postmortem = ?, '
        'resolved_at = CASE WHEN ? = 1 THEN COALESCE(resolved_at, ?) ELSE resolved_at END '
        'WHERE incident_id = ?',
        <Object?>[text.trim(), close ? 1 : 0, at, incidentId],
      );
      _command(commandId, payloadDigest, incidentId: incidentId);
    });
    return PostmortemResult(executed: true, closed: close);
  }

  /// 기한을 넘긴 postmortem(R63 V3 · 기한 오름차순).
  List<OverduePostmortem> overduePostmortems() {
    final DateTime now = _clock.nowUtc().toUtc();
    final List<OverduePostmortem> out =
        <OverduePostmortem>[
          for (final Row r in _db.select(
            'SELECT incident_id, severity, category, postmortem, due_at FROM incidents WHERE due_at IS NOT NULL',
          ))
            if (postmortemOverdue(
              dueAtUtc: DateTime.parse(r['due_at'] as String).toUtc(),
              postmortem: r['postmortem'] as String?,
              nowUtc: now,
            ))
              OverduePostmortem(
                incidentId: r['incident_id'] as String,
                severity: r['severity'] as String,
                category: r['category'] as String,
                dueAtUtc: DateTime.parse(r['due_at'] as String).toUtc(),
              ),
        ]..sort((OverduePostmortem a, OverduePostmortem b) {
          final int t = a.dueAtUtc.compareTo(b.dueAtUtc);
          return t != 0 ? t : a.incidentId.compareTo(b.incidentId);
        });
    return out;
  }
}
