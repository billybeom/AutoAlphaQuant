// 온보딩 단계 진척 저장 · 읽기(E11p4a · 설계 13 §8 R122 · 02 §2 `onboarding_progress` · 앱 01 §25 K15).
//
// 🔴 표 = 단계 · 트랙마다 지금 상태 한 행(PRIMARY KEY (step_id, track)) — 이력 표가 아니다(덮어쓴다).
// 🔴 쓰는 쪽 = 검증 동작(키 검증 통과 → o_02 VERIFIED 등 · 조립 앱 E11p4b) · 읽는 쪽 = 단계 목록 VM 의 사실.
// 🔴 카탈로그에 없는 단계 id = 오류(한 행도 쓰지 않는다) · 트랙 = FRESH(재연결 · 페어링 트랙은 단계 목록에 없다).

import 'package:core_engine/core_engine.dart'
    show OnboardingStepFact, onboardingStepIds;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, OnboardingTrack, StepState;
import 'package:sqlite3/sqlite3.dart';

/// 🆕 R129 — 단계 하나의 마지막 기록.
class OnboardingProgressRecord {
  /// 만든다.
  const OnboardingProgressRecord({
    required this.state,
    required this.updatedAtUtc,
    this.failureReasonCode,
  });

  /// 상태.
  final StepState state;

  /// 기록 시각.
  final DateTime updatedAtUtc;

  /// 실패 코드.
  final String? failureReasonCode;
}

/// 온보딩 진척 저장.
class SqliteOnboardingProgressStore {
  /// 저장을 만든다 — 시각 = 기기 시계(갱신 시각 · 검증 시각).
  SqliteOnboardingProgressStore(this._db, {required this._clock});

  final Database _db;
  final Clock _clock;

  /// 단계 목록이 다시 읽어야 하는 표.
  static const Set<String> watchedTables = <String>{
    'onboarding_progress',
    'onboarding_choice',
  };

  /// 🔴 FRESH 트랙의 단계 → 사실(행 없음 = 사실 없음 — 호출자가 원천 없음/실측으로 채운다).
  Map<String, OnboardingStepFact> facts() => <String, OnboardingStepFact>{
    for (final Row r in _db.select(
      'SELECT step_id, state, verified_until, failure_reason_code FROM onboarding_progress '
      'WHERE track = ? ORDER BY step_id',
      <Object?>[OnboardingTrack.fresh.wire],
    ))
      r['step_id'] as String: OnboardingStepFact(
        state: StepState.values.singleWhere(
          (StepState s) => s.wire == r['state'],
        ),
        verifiedUntil: r['verified_until'] == null
            ? null
            : DateTime.parse(r['verified_until'] as String).toUtc(),
        failureReasonCode: r['failure_reason_code'] as String?,
      ),
  };

  /// 🆕 E11p3d-5d(R129) — 단계 하나의 마지막 기록(상태 · 기록 시각 · 실패 코드 · 없음 = null) — S02 «마지막 검증» 줄.
  OnboardingProgressRecord? lastRecord(String stepId) {
    final Row? r = _db.select(
      'SELECT state, updated_at, failure_reason_code FROM onboarding_progress '
      'WHERE step_id = ? AND track = ?',
      <Object?>[stepId, OnboardingTrack.fresh.wire],
    ).firstOrNull;
    if (r == null) return null;
    return OnboardingProgressRecord(
      state: StepState.values.singleWhere(
        (StepState s) => s.wire == r['state'],
      ),
      updatedAtUtc: DateTime.parse(r['updated_at'] as String).toUtc(),
      failureReasonCode: r['failure_reason_code'] as String?,
    );
  }

  /// 🔴 단계 하나의 지금 상태를 쓴다(덮어쓴다) — VERIFIED = 검증 시각 · 실패 코드 비움 · 그 밖 = 검증 시각 비움.
  void record(
    String stepId,
    StepState state, {
    DateTime? verifiedUntil,
    String? failureReasonCode,
  }) {
    if (!onboardingStepIds.contains(stepId)) {
      throw ArgumentError.value(stepId, 'stepId', '카탈로그에 없는 단계');
    }
    if (state == StepState.verified && failureReasonCode != null) {
      throw ArgumentError('VERIFIED 에 실패 코드를 붙이지 않는다');
    }
    final String now = _clock.nowUtc().toUtc().toIso8601String();
    _db.execute(
      'INSERT INTO onboarding_progress(step_id, track, state, verified_at, verified_until, '
      'failure_reason_code, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?) '
      'ON CONFLICT(step_id, track) DO UPDATE SET state = excluded.state, '
      'verified_at = excluded.verified_at, verified_until = excluded.verified_until, '
      'failure_reason_code = excluded.failure_reason_code, updated_at = excluded.updated_at',
      <Object?>[
        stepId,
        OnboardingTrack.fresh.wire,
        state.wire,
        state == StepState.verified ? now : null,
        verifiedUntil?.toUtc().toIso8601String(),
        failureReasonCode,
        now,
      ],
    );
  }
}
