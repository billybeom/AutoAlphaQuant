// simToAuto 전환 세션 저장 — 열기(6단계 생체) · 하나만 · 취소 · 만료 · 닫기 자리 · 읽기 · 냉각 알림
// (01 :2967 · 02 §2 `handover_session` · 앱 05 :510 · :585 · SPEC v2.44 · 설계 13 §8 R93 AE1 f2 · R96 AF1~AF12).
//
// 🔴 실전 파일만(모의 파일 = [StateError] — `SqliteModeStore` 의 식별 검사 · AF1).
// 🔴 열기 = 신뢰 시각으로 다시 판정(core `judgeSimToAuto` + `simToAutoOpenReject`) 뒤 한 트랜잭션 · 거부 = 쓰기 0.
// 🔴 `expires_at` = 해시 모집단(연장 0) · `closed_at` · `close_code` = 밖(UPDATE 로 닫는다).
// 🔴 모드는 건드리지 않는다 — 실전 개시 커밋 · 모의 CLOSE = f3 · 리스 · 감시 = f4 · 알림을 내는 잡 = f4.

import 'package:core_engine/core_engine.dart'
    show
        ExchangeCalendar,
        HandoverCloseCode,
        HandoverSessionCodes,
        HandoverSessionKind,
        HandoverSessionRecord,
        LiveObservationConfig,
        SimToAutoFacts,
        SimToAutoReport,
        TrustedClock,
        handoverCoolingAlertCodes,
        handoverSessionHeadline,
        handoverSessionIdOf,
        judgeSimToAuto,
        kHandoverCancelledHeadline,
        kHandoverSessionTtl,
        simToAutoOpenReject;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, HandoverPath, LedgerFile;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;
import 'mode_store.dart' show SqliteModeStore;

final RegExp _offset = RegExp(r'(Z|[+-]\d\d:?\d\d)$');

DateTime _instant(String v) {
  if (!_offset.hasMatch(v)) {
    throw FormatException('handover_session 시각에 시차가 없다', v);
  }
  return DateTime.parse(v).toUtc();
}

HandoverSessionRecord _record(Row r) {
  final Object? closed = r['closed_at'];
  final Object? code = r['close_code'];
  final Object? path = r['path'];
  return HandoverSessionRecord(
    sessionId: r['handover_session_id'] as String,
    kind: HandoverSessionKind.fromWire(r['kind'] as String),
    path: path == null
        ? null
        : HandoverPath.values.firstWhere(
            (HandoverPath p) => p.wire == path,
            orElse: () => throw FormatException('handover_session.path', path),
          ),
    deviceId: r['device_id'] as String,
    leaseEpoch: r['lease_epoch'] as int,
    openedAtUtc: _instant(r['opened_at'] as String),
    expiresAtUtc: _instant(r['expires_at'] as String),
    closedAtUtc: closed == null ? null : _instant(closed as String),
    closeCode: code == null ? null : HandoverCloseCode.fromWire(code as String),
  );
}

SimToAutoFacts _at(SimToAutoFacts f, DateTime? now) => SimToAutoFacts(
  trustedNowUtc: now,
  simRunMode: f.simRunMode,
  simClosed: f.simClosed,
  operatingMode: f.operatingMode,
  trial: f.trial,
  goldenVectorPassed: f.goldenVectorPassed,
  liveKeysVerified: f.liveKeysVerified,
  accountByStrategy: f.accountByStrategy,
  fate: f.fate,
  sessionOpenedAtUtc: null,
  killSwitchActive: f.killSwitchActive,
  blockingFlags: f.blockingFlags,
);

/// 세션 쓰기 결과.
class HandoverSessionOutcome {
  /// 성공.
  const HandoverSessionOutcome.ok(String this.sessionId, this.headline)
    : reasonCode = null;

  /// 거부 · 되돌림(아무것도 쓰지 않았다).
  const HandoverSessionOutcome.no(String this.reasonCode, this.headline)
    : sessionId = null;

  /// 거부 코드(성공 = null).
  final String? reasonCode;

  /// 세션 id(거부 = null).
  final String? sessionId;

  /// 엔진 문구(화면은 그대로 그린다).
  final String headline;

  /// 성공했나.
  bool get ok => reasonCode == null;
}

/// simToAuto 전환 세션 저장(R96).
class SqliteHandoverSessionStore {
  /// 저장을 만든다 — 🔴 [db] 가 실전 파일이 아니면 [StateError].
  ///
  /// `clock` = 취소 시각(기기 · `closed_at` 은 해시 밖) · `trusted` = 열기 · 냉각 · 만료 판정.
  SqliteHandoverSessionStore(
    this._db, {
    required this._clock,
    required this._trusted,
  }) {
    SqliteModeStore(_db, LedgerFile.live, clock: _clock);
  }

  final Database _db;
  final Clock _clock;
  final TrustedClock _trusted;

  List<HandoverSessionRecord> _unclosed() => <HandoverSessionRecord>[
    for (final Row r in _db.select(
      'SELECT * FROM handover_session WHERE closed_at IS NULL',
    ))
      _record(r),
  ];

  /// 세션 한 행(없음 = null).
  HandoverSessionRecord? session(String sessionId) {
    final ResultSet rs = _db.select(
      'SELECT * FROM handover_session WHERE handover_session_id = ?',
      <Object?>[sessionId],
    );
    return rs.isEmpty ? null : _record(rs.first);
  }

  /// 가장 늦게 연 «안 닫힌 simToAuto» 세션(만료 포함 — 판정이 «기한 지남»을 말한다 · AF9) — 없음 = null.
  ///
  /// = core `SimToAutoFacts.sessionOpenedAtUtc` 의 원천.
  HandoverSessionRecord? simToAutoSession() {
    HandoverSessionRecord? best;
    for (final HandoverSessionRecord s in _unclosed()) {
      if (s.kind != HandoverSessionKind.wizard ||
          s.path != HandoverPath.simToAuto) {
        continue;
      }
      if (best == null ||
          s.openedAtUtc.isAfter(best.openedAtUtc) ||
          (s.openedAtUtc == best.openedAtUtc &&
              s.sessionId.compareTo(best.sessionId) > 0)) {
        best = s;
      }
    }
    return best;
  }

  /// 🔴 6단계 — 생체 확인 1회로 simToAuto 세션을 연다(AF2 · AF3 · AF5).
  ///
  /// [biometricConfirmed] = 호출자(M5 위저드)의 생체 증명 · [facts] 의 시각 · 세션 칸은 버리고 신뢰 시각으로 다시 판정한다.
  HandoverSessionOutcome openSimToAuto({
    required bool biometricConfirmed,
    required SimToAutoFacts facts,
    required ExchangeCalendar kr,
    required LiveObservationConfig observation,
    required String deviceId,
    required int leaseEpoch,
  }) {
    if (deviceId.trim().isEmpty) {
      throw ArgumentError.value(deviceId, 'deviceId', '빈 기기 id');
    }
    if (leaseEpoch < 0) {
      throw ArgumentError.value(leaseEpoch, 'leaseEpoch', '음수 리스 세대');
    }
    final DateTime? now = _trusted.trustedNowUtc()?.toUtc();
    final SimToAutoReport report = judgeSimToAuto(
      _at(facts, now),
      kr: kr,
      observation: observation,
    );
    final String? reject = simToAutoOpenReject(
      biometricConfirmed: biometricConfirmed,
      trustedNowUtc: now,
      report: report,
    );
    if (reject != null) {
      return HandoverSessionOutcome.no(reject, handoverSessionHeadline(reject));
    }
    final DateTime at = now!;
    final String id = handoverSessionIdOf(at);
    bool busy = false;
    try {
      inLedgerTransaction(_db, () {
        final List<HandoverSessionRecord> open = _unclosed();
        if (open.any((HandoverSessionRecord s) => s.liveAt(at))) {
          busy = true;
          return;
        }
        // 만료됐는데 안 닫힌 행 = 막지 않고 여기서 닫는다(AF3).
        for (final HandoverSessionRecord s in open) {
          _db.execute(
            'UPDATE handover_session SET closed_at = ?, close_code = ? '
            'WHERE handover_session_id = ? AND closed_at IS NULL',
            <Object?>[
              at.toIso8601String(),
              HandoverCloseCode.expired.wire,
              s.sessionId,
            ],
          );
        }
        _db.execute(
          'INSERT INTO handover_session (handover_session_id, kind, path, device_id, lease_epoch, '
          'opened_at, expires_at, closed_at, close_code) VALUES (?, ?, ?, ?, ?, ?, ?, NULL, NULL)',
          <Object?>[
            id,
            HandoverSessionKind.wizard.wire,
            HandoverPath.simToAuto.wire,
            deviceId,
            leaseEpoch,
            at.toIso8601String(),
            at.add(kHandoverSessionTtl).toIso8601String(),
          ],
        );
      });
    } on SqliteException {
      return HandoverSessionOutcome.no(
        HandoverSessionCodes.rolledBack,
        handoverSessionHeadline(HandoverSessionCodes.rolledBack),
      );
    }
    if (busy) {
      return HandoverSessionOutcome.no(
        HandoverSessionCodes.sessionOpen,
        handoverSessionHeadline(HandoverSessionCodes.sessionOpen),
      );
    }
    return HandoverSessionOutcome.ok(
      id,
      handoverSessionHeadline(null, openedAtUtc: at),
    );
  }

  /// 취소(AF6) — 안 닫힌 세션 → `CANCELLED`(시각 = 기기) · 닫힌 · 없는 세션 = `HANDOVER_SESSION_INVALID`.
  HandoverSessionOutcome cancel(String sessionId) {
    final HandoverSessionRecord? s = session(sessionId);
    if (s == null || s.closed) {
      return HandoverSessionOutcome.no(
        HandoverSessionCodes.sessionInvalid,
        handoverSessionHeadline(HandoverSessionCodes.sessionInvalid),
      );
    }
    _db.execute(
      'UPDATE handover_session SET closed_at = ?, close_code = ? '
      'WHERE handover_session_id = ? AND closed_at IS NULL',
      <Object?>[
        _clock.nowUtc().toUtc().toIso8601String(),
        HandoverCloseCode.cancelled.wire,
        sessionId,
      ],
    );
    return HandoverSessionOutcome.ok(sessionId, kHandoverCancelledHeadline);
  }

  /// 만료 정리(AF7) — 신뢰 시각으로 «안 닫힘 ∧ 만료»를 `EXPIRED` · 신뢰 시각 없음 = 0건 · 반환 = 닫은 수.
  int expireDue() {
    final DateTime? now = _trusted.trustedNowUtc()?.toUtc();
    if (now == null) return 0;
    int n = 0;
    inLedgerTransaction(_db, () {
      for (final HandoverSessionRecord s in _unclosed()) {
        if (now.isBefore(s.expiresAtUtc)) continue;
        _db.execute(
          'UPDATE handover_session SET closed_at = ?, close_code = ? '
          'WHERE handover_session_id = ? AND closed_at IS NULL',
          <Object?>[
            now.toIso8601String(),
            HandoverCloseCode.expired.wire,
            s.sessionId,
          ],
        );
        n++;
      }
    });
    return n;
  }

  /// 🔴 커밋 · 되돌림으로 닫기(AF8 · f3 가 쓸 자리) — 바깥 트랜잭션 안에서만 · 안 닫힌 행만.
  void closeInTransaction(
    String sessionId,
    HandoverCloseCode code, {
    required DateTime atUtc,
  }) {
    if (_db.autocommit) {
      throw StateError('전환 세션 닫기는 바깥 트랜잭션 안에서만');
    }
    if (code != HandoverCloseCode.committed &&
        code != HandoverCloseCode.rolledBack) {
      throw ArgumentError.value(code, 'code', '커밋 · 되돌림만');
    }
    final HandoverSessionRecord? s = session(sessionId);
    if (s == null || s.closed) {
      throw StateError('닫을 수 없는 전환 세션: $sessionId');
    }
    _db.execute(
      'UPDATE handover_session SET closed_at = ?, close_code = ? '
      'WHERE handover_session_id = ? AND closed_at IS NULL',
      <Object?>[atUtc.toUtc().toIso8601String(), code.wire, sessionId],
    );
  }

  /// 냉각 알림 코드(AF11) — 내는 잡(f4)이 기동 파일의 `SqliteAlertSink.emit(kHandoverCoolingCheck, …)` 로 넘긴다.
  Set<String> coolingAlertCodes() => handoverCoolingAlertCodes(
    simToAutoSession(),
    trustedNowUtc: _trusted.trustedNowUtc()?.toUtc(),
  );
}
