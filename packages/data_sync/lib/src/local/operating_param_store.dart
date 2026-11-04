// 월 납입 운영값 저장 · 읽기 창구(M3-6 엔진 몫 · 설계 13 §8 R54 J3 · J5 · J6 · 02 §2 `operating_param_log`).
//
// 🔴 append-only — UPDATE 0건(`superseded_by` 는 비워 둔다 · 대체 = 조회 규약 «changed_at 최대»).
// 🔴 쓰기 = 신뢰 시각만(모르면 거부) · 읽기 = 신뢰 시각 · 모르면 기기 시계(읽기는 상태를 바꾸지 않는다).
// 🔴 쓰기 창구 바인딩(`settingsContributionUpdate`) = 다음 계약 창 — 여기는 엔진 함수.

import 'dart:async';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show AlertCodes, Clock, ContributionSetting, OperatingParamKeys;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;

/// 변경 결과.
class ContributionChangeResult {
  const ContributionChangeResult._({
    this.row,
    this.replayed = false,
    this.reasonCode,
    this.rejectedText,
  });

  /// 쓴 행(재시도면 이미 있던 행).
  final ContributionParamRow? row;

  /// 같은 회차 재시도였나.
  final bool replayed;

  /// 거부 사유 코드.
  final String? reasonCode;

  /// 거부 문장(엔진).
  final String? rejectedText;

  /// 받아들였나(새 행 · 재시도 둘 다).
  bool get ok => row != null;

  /// 알림 — 새 행에만 `CONTRIBUTION_CHANGED`(P2) 1건(재시도 · 거부 = 0).
  Set<String> get alerts => row != null && !replayed
      ? const <String>{AlertCodes.contributionChanged}
      : const <String>{};

  /// 알림 멱등 키(`CONTRIBUTION_CHANGED:{row_id}`) — 받는 쪽이 같은 키를 두 번 보내지 않는다.
  String? get alertDedupKey =>
      row == null ? null : '${AlertCodes.contributionChanged}:${row!.rowId}';
}

/// `operating_param_log` 의 월 납입 행.
List<ContributionParamRow> contributionRowsOf(Database db) =>
    <ContributionParamRow>[
      for (final Row r in db.select(
        'SELECT row_id, value_text, changed_at, effective_from, action_run_id FROM operating_param_log '
        'WHERE param_key = ? ORDER BY row_id',
        <Object?>[OperatingParamKeys.monthlyContribution],
      ))
        contributionParamRowFromColumns(
          rowId: r['row_id'] as int,
          valueText: r['value_text'] as String,
          changedAtText: r['changed_at'] as String,
          effectiveFrom: r['effective_from'] as String,
          actionRunId: r['action_run_id'] as String,
        ),
    ];

/// 월 납입 운영값 창구(R54 J5 · J6).
class ContributionSettingSource {
  /// 창구를 만든다.
  ContributionSettingSource(
    this._db, {
    required this._trusted,
    required this._clock,
    required this._kr,
    required this._deviceId,
    ContributionConfig? config,
  }) : _config = config ?? p0sContributionConfig();

  final Database _db;
  final TrustedClock _trusted;
  final Clock _clock;
  final ExchangeCalendar _kr;
  final String _deviceId;
  final ContributionConfig _config;
  final StreamController<void> _changed = StreamController<void>.broadcast(
    sync: true,
  );

  /// 지금 값(동기).
  ContributionSetting current() {
    final DateTime now = _trusted.trustedNowUtc() ?? _clock.nowUtc();
    return contributionSettingOf(
      rows: contributionRowsOf(_db),
      todayKst: contributionKstDay(now),
      observedAtUtc: _clock.nowUtc(),
      kr: _kr,
      config: _config,
    );
  }

  /// 구독 즉시 1번 + 기록마다 1번(`ConfigRepository.watchContributionSetting` 의 엔진 쪽).
  Stream<ContributionSetting> watch() {
    late final StreamController<ContributionSetting> out;
    StreamSubscription<void>? sub;
    out = StreamController<ContributionSetting>(
      onListen: () {
        sub = _changed.stream.listen((_) => out.add(current()));
        out.add(current());
      },
      onCancel: () async {
        await sub?.cancel();
        await out.close();
      },
    );
    return out.stream;
  }

  /// 바꾼다 — [amountInput] = 입력칸 글자 그대로 · [actionRunId] = 회차(재시도 = 같은 행).
  ContributionChangeResult change({
    required String amountInput,
    required String actionRunId,
  }) {
    final ContributionDecision d = decideContributionChange(
      amountInput: amountInput,
      actionRunId: actionRunId,
      rows: contributionRowsOf(_db),
      trustedNowUtc: _trusted.trustedNowUtc(),
      kr: _kr,
      config: _config,
    );
    if (d.replay != null) {
      return ContributionChangeResult._(row: d.replay, replayed: true);
    }
    if (d.rejected) {
      return ContributionChangeResult._(
        reasonCode: d.reasonCode,
        rejectedText: d.rejectedText,
      );
    }
    final int id = inLedgerTransaction(_db, () {
      _db.execute(
        'INSERT INTO operating_param_log(param_key, value_text, changed_at, effective_from, action_run_id, device_id) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        <Object?>[
          OperatingParamKeys.monthlyContribution,
          d.amount!.toString(),
          d.changedAtUtc!.toIso8601String(),
          d.effectiveFrom,
          actionRunId,
          _deviceId,
        ],
      );
      return _db.lastInsertRowId;
    });
    final ContributionParamRow row = ContributionParamRow(
      rowId: id,
      amount: d.amount!,
      changedAtUtc: d.changedAtUtc!,
      effectiveFrom: d.effectiveFrom!,
      actionRunId: actionRunId,
    );
    _changed.add(null);
    return ContributionChangeResult._(row: row);
  }

  /// 닫는다(구독이 더 오지 않는다).
  Future<void> close() => _changed.close();
}
