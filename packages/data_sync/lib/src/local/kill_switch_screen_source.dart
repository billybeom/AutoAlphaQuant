// 🆕 E11q-b1a — M5-1 킬스위치 화면 원천(operator · 설계 13 §8 R178 · 01 §34 K146).
//
// 🔴 셈 · 문장 = 엔진(`killSwitchScreenVmOf`) · 여기는 원장 원문만 모은다: 킬스위치 상태 행(`kill_switch_state`) ·
//    지금 발동 뒤의 마지막 취소 보고(`kill_switch_event` CANCEL_REPORT 요약 — 금액 0).
// 🔴 시각 = 신뢰 시각(해제 시각 줄 · 모르면 엔진이 «셀 수 없습니다»라 말한다) · 관측 시각 = 기기 시계.

import 'dart:convert';

import 'package:core_engine/core_engine.dart'
    show
        KillCancelItem,
        KillCancelOutcome,
        KillCancelReport,
        KillSwitchRecord,
        TrustedClock,
        killSwitchActive,
        killSwitchScreenVmOf;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, KillSwitchScreenVm;
import 'package:sqlite3/sqlite3.dart';

import 'kill_switch_store.dart' show readKillSwitchRecord;

/// M5-1 한 화면 읽기(동기 — 화면 흐름이 원장 변경 · 주기마다 다시 부른다).
class SqliteKillSwitchScreenSource {
  /// 만든다 — [canRecord] = 발동 뒤 기록 쓰기 창구가 있나(폰 · 이 기기 id) · [hasBody] = 조립 앱 등록 화면.
  SqliteKillSwitchScreenSource(
    this._db, {
    required this._clock,
    required this._trusted,
    required this._canRecord,
    required this._hasBody,
  });

  final Database _db;
  final Clock _clock;
  final TrustedClock _trusted;
  final bool _canRecord;
  final bool Function(String route) _hasBody;

  /// 다시 낼 표.
  static const Set<String> watchedTables = <String>{
    'kill_switch_state',
    'kill_switch_event',
  };

  /// M5-1 VM.
  KillSwitchScreenVm screen() {
    final KillSwitchRecord r = readKillSwitchRecord(_db);
    return killSwitchScreenVmOf(
      record: r,
      trustedNowUtc: _trusted.trustedNowUtc(),
      nowUtc: _clock.nowUtc(),
      cancel: lastKillCancelReport(_db, r),
      canRecord: _canRecord,
      hasBody: _hasBody,
    );
  }
}

/// 지금 발동 뒤의 마지막 취소 보고(꺼짐 · 보고 없음 = null) — 🔴 시각 비교는 글자가 아니라 시각으로(ISO 소수 자리가 다를 수 있다).
KillCancelReport? lastKillCancelReport(Database db, KillSwitchRecord r) {
  final DateTime? at = r.activatedAtUtc;
  if (at == null || !killSwitchActive(r)) return null;
  DateTime? best;
  String? summary;
  for (final Row row in db.select(
    "SELECT occurred_at, summary FROM kill_switch_event WHERE kind = 'CANCEL_REPORT'",
  )) {
    final DateTime t = DateTime.parse(row['occurred_at'] as String).toUtc();
    if (t.isBefore(at)) continue;
    if (best == null || !t.isBefore(best)) {
      best = t;
      summary = row['summary'] as String;
    }
  }
  if (summary == null) return null;
  final Map<String, Object?> j = jsonDecode(summary) as Map<String, Object?>;
  return KillCancelReport(<KillCancelItem>[
    for (final Object? o in (j['items'] as List<Object?>? ?? const <Object?>[]))
      if (o case {
        'intent_id': final String intent,
        'symbol': final String symbol,
        'outcome': final String outcome,
      })
        KillCancelItem(
          intent,
          symbol,
          KillCancelOutcome.values.firstWhere(
            (KillCancelOutcome x) => x.wire == outcome,
            orElse: () => throw StateError('모르는 취소 결과: $outcome'),
          ),
          code: (o as Map<String, Object?>)['code'] as String?,
        ),
  ], candidatesError: j['candidates_error'] as String?);
}
