// 운영 설정 읽기 모델(순수 · 설계 13 §8 R148 Z1~Z5 · SPEC 02 §4 `operations` 블록 — 🔴 전략 config_hash 밖).
//
// 🔴 값은 코드에 없다 — 원천 = 앱 자산(SPEC 02 §4 블록 그대로 · 잠정 · ⬜ 발주자 확정) · 여기는 읽기만.
// 🔴 키 없음 · 값 null(⬜ 미정) = null(기능 꺼짐 · 지어내지 않음) · 꼴 틀림 = [FormatException](조용히 넘어가지 않음).
// 🔴 변환은 core 의 설정 생성자 검사(1 미만 거부 등)를 그대로 거친다.

import '../migration/fencing.dart' show FencingConfig;
import '../migration/migration_gate.dart' show MigrationObservationConfig;
import '../mode/live_observation.dart' show LiveObservationConfig;
import '../resume/resume_gap.dart' show ResumeLadder;

/// `operations` 블록 읽기(원문 = JSON 객체).
final class OperationsConfig {
  OperationsConfig._(this._root);

  /// [json] = `operations` 블록(객체) — 객체가 아니면 [FormatException].
  factory OperationsConfig.fromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const FormatException('operations 블록이 객체가 아니다');
    }
    return OperationsConfig._(json);
  }

  final Map<String, Object?> _root;

  /// 원문(쓰는 조각이 읽기를 더할 때까지 그대로 보관).
  Map<String, Object?> get raw => Map<String, Object?>.unmodifiable(_root);

  Object? _at(List<String> path) {
    Object? node = _root;
    for (int i = 0; i < path.length; i++) {
      if (node is! Map<String, Object?>) {
        throw FormatException('operations.${path.take(i).join('.')} 가 객체가 아니다');
      }
      if (!node.containsKey(path[i])) return null;
      node = node[path[i]];
    }
    return node;
  }

  int? _int(List<String> path) {
    final Object? v = _at(path);
    if (v == null) return null;
    if (v is! int) {
      throw FormatException('operations.${path.join('.')} 는 정수여야 한다', '$v');
    }
    return v;
  }

  List<int>? _intList(List<String> path) {
    final Object? v = _at(path);
    if (v == null) return null;
    if (v is! List<Object?> || v.any((Object? x) => x is! int)) {
      throw FormatException('operations.${path.join('.')} 는 정수 목록이어야 한다', '$v');
    }
    return <int>[for (final Object? x in v) x! as int];
  }

  bool? _bool(List<String> path) {
    final Object? v = _at(path);
    if (v == null) return null;
    if (v is! bool) {
      throw FormatException(
        'operations.${path.join('.')} 는 참 · 거짓이어야 한다',
        '$v',
      );
    }
    return v;
  }

  /// M1-22 live × dryRun 관찰 거래일.
  int? get liveDryRunObservationTradingDays =>
      _int(const <String>['live_dry_run_observation_trading_days']);

  /// 감시 유지보수 창 넘김 시간(시).
  int? get maintenanceOverdueHours =>
      _int(const <String>['migration', 'maintenance_overdue_hours']);

  /// 비상 펜싱 마진(분).
  int? get fencingMarginMinutes =>
      _int(const <String>['migration', 'fencing_margin_minutes']);

  /// 브로커 토큰 잔존(시 · null = 모름 → core 가정값).
  int? get brokerTokenResidualHours =>
      _int(const <String>['migration', 'broker_token_residual_hours']);

  /// X1-5 관찰 거래일(계획).
  int? get planObservationTradingDays =>
      _int(const <String>['migration', 'observation_trading_days', 'plan']);

  /// X1-5 관찰 거래일(비상).
  int? get emergencyObservationTradingDays => _int(const <String>[
    'migration',
    'observation_trading_days',
    'emergency',
  ]);

  /// 이전 티켓 유효(분).
  int? get ticketTtlMinutes =>
      _int(const <String>['migration', 'ticket_ttl_minutes']);

  /// 파생 재생성 하루 상한.
  int? get derivedResyncDailyCap =>
      _int(const <String>['migration', 'derived_resync_daily_cap']);

  /// 원장 스냅숏을 올리나(⬜ 발주자).
  bool? get backupUpload => _bool(const <String>['migration', 'backup_upload']);

  /// 🔴 창 넘김(없음 = null · 0 이하 = [ArgumentError] — core 판정이 0 보다 커야 한다).
  Duration? get maintenanceOverdue {
    final int? h = maintenanceOverdueHours;
    if (h == null) return null;
    if (h <= 0) {
      throw ArgumentError.value(h, 'maintenance_overdue_hours', '0 보다 커야');
    }
    return Duration(hours: h);
  }

  /// 🔴 X1-5 관찰 설정(둘 중 하나라도 없음 = null).
  MigrationObservationConfig? get migrationObservation {
    final int? plan = planObservationTradingDays;
    final int? emergency = emergencyObservationTradingDays;
    if (plan == null || emergency == null) return null;
    return MigrationObservationConfig(
      planTradingDays: plan,
      emergencyTradingDays: emergency,
    );
  }

  /// 🔴 M1-22 관찰 설정(없음 = null).
  LiveObservationConfig? get liveObservation {
    final int? d = liveDryRunObservationTradingDays;
    return d == null ? null : LiveObservationConfig(requiredTradingDays: d);
  }

  /// 🆕 R150 — 재개 갭 사다리(거래일 · NORMAL · CONSERVATIVE · RECOVERY_DRY 상한).
  List<int>? get gapLadderTradingDays =>
      _intList(const <String>['resume', 'gap_ladder_trading_days']);

  /// 🆕 R150 — 백업 갭(달력일 · 이상 = RECOVERY_FULL).
  int? get backupGapDays => _int(const <String>['resume', 'backup_gap_days']);

  /// 🔴 R150 — 재개 사다리(둘 중 하나라도 없음 = null · `ResumeLadder` 생성자 검사 그대로).
  ResumeLadder? get resumeLadder {
    final List<int>? gaps = gapLadderTradingDays;
    final int? backup = backupGapDays;
    if (gaps == null || backup == null) return null;
    return ResumeLadder(gapLadderTradingDays: gaps, backupGapDays: backup);
  }

  /// 🔴 펜싱 설정(마진 없음 = null · 잔존 없음 = core 가정값).
  FencingConfig? get fencing {
    final int? m = fencingMarginMinutes;
    if (m == null) return null;
    final int? residual = brokerTokenResidualHours;
    return FencingConfig(
      margin: Duration(minutes: m),
      brokerTokenResidual: residual == null ? null : Duration(hours: residual),
    );
  }
}
