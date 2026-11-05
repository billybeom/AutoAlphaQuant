// 운영 기기 알림 읽기 — `AlertRepository` 구현(인박스 · 센터 · 상세 · 앱 01 §4-1 · §24 · 설계 13 §8 R69).
//
// 🔴 VM 조립은 core `safety/alert_text.dart`(순수) — 여기는 행 읽기 · 구독만.
// 🔴 시각 = 기기 시계(알림은 기기 시각 축 · R68 H3) · 시간만 흐를 때의 다시 냄 = 조립의 주기 신호(R69 I9).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AlertCenterVm,
        AlertDetailVm,
        AlertItem,
        AlertLevel,
        AlertRepository,
        Clock;
import 'package:sqlite3/sqlite3.dart';

import 'ledger_read_model.dart' show watchLedgerQuery;

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

DateTime _instant(String v) {
  if (!_offset.hasMatch(v)) throw FormatException('시각에 오프셋 없음', v);
  return DateTime.parse(v).toUtc();
}

AlertLevel _level(String wire) {
  for (final AlertLevel l in AlertLevel.values) {
    if (l.wire == wire) return l;
  }
  throw FormatException('모르는 알림 등급', wire);
}

/// 알림 저장 행 전부(+ 확인 시각 · 적힌 사다리 단계 수).
List<StoredAlert> storedAlerts(Database db) => <StoredAlert>[
  for (final Row r in db.select(
    'SELECT e.alert_id, e.code, e.level, e.raised_at, a.acked_at, '
    '(SELECT COUNT(*) FROM alert_escalation x WHERE x.alert_id = e.alert_id) AS steps '
    'FROM alert_event e LEFT JOIN alert_ack a ON a.alert_id = e.alert_id',
  ))
    StoredAlert(
      alertId: r['alert_id'] as String,
      code: r['code'] as String,
      level: _level(r['level'] as String),
      raisedAtUtc: _instant(r['raised_at'] as String),
      ackedAtUtc: r['acked_at'] == null
          ? null
          : _instant(r['acked_at'] as String),
      escalationSteps: r['steps'] as int,
    ),
];

/// 운영 기기 알림 읽기(R69).
class SqliteAlertRepository implements AlertRepository {
  /// 저장소를 만든다.
  SqliteAlertRepository(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  /// 다시 낼 표(R69 I9).
  static const Set<String> watchedTables = <String>{
    'alert_event',
    'alert_ack',
    'alert_escalation',
  };

  @override
  Stream<List<AlertItem>> watchInbox({AlertLevel? min}) => watchLedgerQuery(
    _db,
    watchedTables,
    () => alertInboxOf(
      rows: storedAlerts(_db),
      nowUtc: _clock.nowUtc().toUtc(),
      min: min,
    ),
  );

  @override
  Stream<AlertCenterVm> watchCenter({required bool p0Only}) => watchLedgerQuery(
    _db,
    watchedTables,
    () => alertCenterOf(
      rows: storedAlerts(_db),
      nowUtc: _clock.nowUtc().toUtc(),
      p0Only: p0Only,
    ),
  );

  @override
  Stream<AlertDetailVm> watchAlert(String alertId) => watchLedgerQuery(
    _db,
    watchedTables,
    () => alertDetailOf(
      rows: storedAlerts(_db),
      nowUtc: _clock.nowUtc().toUtc(),
      alertId: alertId,
    ),
  );
}
