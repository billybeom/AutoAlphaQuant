// 모드 정본(SPEC v2.44 02 §2-6 `mode_transition` · 04 §3-1 v2.44 ① · 01 §9-5 ③ · 설계 13 §8 R82 W2~W6).
//
// 🔴 파일 하나 · 한 트랜잭션 — 두 원장 파일을 한 연결 · 한 트랜잭션에 묶지 않는다(X6-1). 반쯤 끝난 2단 커밋은
//    기동 해석(core `resolveBootMode`)이 찾고 sim 파일에만 CLOSE 를 마저 쓴다.
// 🔴 금지 조합은 **쓰지 않는다**(직전 유효 조합 유지) — 판정은 core `modeCombinationAllowed` 하나.
// 🔴 운영 방식 원천 = `operating_mode_transition` 최신 → `onboarding_choice`(커밋된 행) → null(«온보딩 미완» ≠ 자동 매매 · G-02).
// 🔴 append-only · X5-1 해시 모집단 밖(운영 상태).

import 'package:core_engine/core_engine.dart'
    show
        BootMode,
        BootModeResolved,
        ModeFacts,
        ModeFactsSource,
        ModeRowFacts,
        kModeCombinationDenied,
        modeCombinationAllowed,
        resolveBootMode;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, ExecPolicy, LedgerFile, OperatingMode, RunMode;
import 'package:sqlite3/sqlite3.dart';

import '../market/market_store.dart' show inLedgerTransaction;
import 'ledger_read_model.dart' show watchLedgerQuery;

/// `mode_transition.axis`.
enum ModeAxis {
  /// 계좌 · 서버(온보딩 커밋 · simToAuto · 모의 폐기 후 새 개시).
  runMode('RUN_MODE'),

  /// 승격 · 강등.
  execPolicy('EXEC_POLICY'),

  /// 이 파일을 닫음(sim 파일만).
  close('CLOSE');

  const ModeAxis(this.wire);

  /// 저장 글자.
  final String wire;
}

/// 한 파일의 모드 · 운영 방식(읽기).
class ModeSnapshot {
  /// 스냅숏을 만든다.
  const ModeSnapshot({
    required this.runMode,
    required this.execPolicy,
    required this.operatingMode,
  });

  /// 실행 모드.
  final RunMode runMode;

  /// 집행 정책.
  final ExecPolicy execPolicy;

  /// 운영 방식(null = 온보딩 미완).
  final OperatingMode? operatingMode;
}

/// 모드 정본(파일 하나 · R82 W2 · W3 · W6).
class SqliteModeStore {
  /// 정본을 만든다 — 🔴 [db] 의 식별(`application_id`)이 [file] 과 다르면 열지 않는다.
  SqliteModeStore(this._db, this.file, {required this._clock}) {
    final Object? appId = _db
        .select('PRAGMA application_id')
        .first
        .values
        .first;
    if (appId != file.applicationId) {
      throw StateError('모드 정본: 원장 파일 식별이 다르다($appId ≠ ${file.applicationId})');
    }
  }

  final Database _db;
  final Clock _clock;

  /// 이 정본의 파일.
  final LedgerFile file;

  /// 다시 낼 표.
  static const Set<String> watchedTables = <String>{
    'mode_transition',
    'operating_mode_transition',
    'onboarding_choice',
  };

  /// 현재 행(최신 비-CLOSE · 없으면 null).
  ModeRowFacts? current() {
    final ResultSet rs = _db.select(
      "SELECT mode, exec_policy, decision_id FROM mode_transition WHERE axis <> 'CLOSE' "
      'ORDER BY committed_at DESC, transition_id DESC LIMIT 1',
    );
    if (rs.isEmpty) return null;
    final Row r = rs.first;
    return ModeRowFacts(
      runMode: RunMode.values.firstWhere((RunMode m) => m.wire == r['mode']),
      execPolicy: ExecPolicy.values.firstWhere(
        (ExecPolicy e) => e.wire == r['exec_policy'],
      ),
      decisionId: r['decision_id'] as String,
    );
  }

  /// CLOSE 행이 있나.
  bool closed() => _db
      .select("SELECT 1 FROM mode_transition WHERE axis = 'CLOSE' LIMIT 1")
      .isNotEmpty;

  /// 운영 방식(R82 W3) — 전이 최신 → 커밋된 온보딩 선택 → null.
  OperatingMode? operatingMode() {
    final ResultSet t = _db.select(
      'SELECT to_mode FROM operating_mode_transition ORDER BY committed_at DESC, transition_id DESC LIMIT 1',
    );
    final Object? wire = t.isNotEmpty
        ? t.first['to_mode']
        : _db
              .select(
                'SELECT operating_mode FROM onboarding_choice WHERE committed_at IS NOT NULL',
              )
              .firstOrNull?['operating_mode'];
    if (wire == null) return null;
    return OperatingMode.values.firstWhere((OperatingMode m) => m.wire == wire);
  }

  /// 모드 · 운영 방식(행 없음 = null).
  ModeSnapshot? snapshot() {
    final ModeRowFacts? c = current();
    if (c == null) return null;
    return ModeSnapshot(
      runMode: c.runMode,
      execPolicy: c.execPolicy,
      operatingMode: operatingMode(),
    );
  }

  /// 구독 즉시 1번 + 표가 바뀔 때마다(R82 W6).
  Stream<ModeSnapshot?> watchCurrent() =>
      watchLedgerQuery(_db, watchedTables, snapshot);

  /// 🔴 전이를 쓴다(R82 W2) — 금지 조합 = 쓰지 않고 `MODE_COMBINATION_DENIED` · 쓰면 null.
  String? record({
    required ModeAxis axis,
    required RunMode runMode,
    required ExecPolicy execPolicy,
    required OperatingMode operatingMode,
    required bool handoverSessionValid,
    required String decisionId,
    String? handoverSessionId,
  }) {
    if (axis == ModeAxis.close) {
      throw ArgumentError.value(axis, 'axis', 'CLOSE 는 close() 로 쓴다');
    }
    if (!identical(LedgerFile.of(runMode), file)) {
      throw ArgumentError.value(
        runMode,
        'runMode',
        '${file.fileName} 계열의 모드가 아니다',
      );
    }
    if (closed()) throw StateError('닫힌 파일에는 전이를 쓰지 않는다: ${file.fileName}');
    if (!modeCombinationAllowed(
      runMode,
      operatingMode,
      execPolicy,
      handoverSessionValid: handoverSessionValid,
    )) {
      return kModeCombinationDenied;
    }
    inLedgerTransaction(_db, () {
      _insert(
        axis: axis,
        runMode: runMode,
        execPolicy: execPolicy,
        decisionId: decisionId,
        handoverSessionId: handoverSessionId,
      );
    });
    return null;
  }

  /// sim 파일을 닫는다(simToAuto 2단 커밋의 둘째 · 반쯤 끝난 커밋 복구) — 이미 닫혔으면 그대로.
  void close({required String decisionId, String? handoverSessionId}) {
    if (!identical(file, LedgerFile.sim)) {
      throw StateError('CLOSE 는 sim 파일만: ${file.fileName}');
    }
    inLedgerTransaction(_db, () {
      if (closed()) return;
      final ModeRowFacts? c = current();
      if (c == null) throw StateError('닫을 모드 행이 없다: ${file.fileName}');
      _insert(
        axis: ModeAxis.close,
        runMode: c.runMode,
        execPolicy: c.execPolicy,
        decisionId: decisionId,
        handoverSessionId: handoverSessionId,
      );
    });
  }

  void _insert({
    required ModeAxis axis,
    required RunMode runMode,
    required ExecPolicy execPolicy,
    required String decisionId,
    required String? handoverSessionId,
  }) {
    final ModeRowFacts? prev = current();
    final int n =
        (_db.select('SELECT COUNT(*) AS n FROM mode_transition').first['n']!
            as int) +
        1;
    _db.execute(
      'INSERT INTO mode_transition (transition_id, axis, mode, exec_policy, from_mode, from_exec_policy, '
      'decision_id, handover_session_id, committed_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        'MT-${n.toString().padLeft(6, '0')}',
        axis.wire,
        runMode.wire,
        execPolicy.wire,
        prev?.runMode.wire,
        prev?.execPolicy.wire,
        decisionId,
        handoverSessionId,
        _clock.nowUtc().toUtc().toIso8601String(),
      ],
    );
  }
}

/// 🔴 기동 해석(R82 W4) — 두 정본을 **따로** 읽는다(한 트랜잭션 0) · live 파일이 아직 없으면 [live] = null.
BootMode bootModeOf({
  required SqliteModeStore? live,
  required SqliteModeStore sim,
}) => resolveBootMode(
  live: live?.current(),
  sim: sim.current(),
  simClosed: sim.closed(),
);

/// 🔴 반쯤 끝난 2단 커밋 복구(R82 W4) — sim 파일에만 CLOSE 1행 · 고쳤으면 true.
bool repairHalfCommit(BootMode mode, SqliteModeStore sim) {
  if (mode is! BootModeResolved || !mode.repairSimClose) return false;
  sim.close(decisionId: mode.decisionId);
  return true;
}

/// 판정 입력 실물(R82 W5) — #12 세션 = 열린 `handover_session` ∧ 만료 전 · 실키 검증 = 주입(금고 = E11p).
class SqliteModeFacts implements ModeFactsSource {
  /// 입력을 만든다.
  SqliteModeFacts(
    this._db, {
    required this._clock,
    required this._liveKeysVerified,
  });

  final Database _db;
  final Clock _clock;
  final Future<bool> Function() _liveKeysVerified;

  @override
  Future<ModeFacts> facts() async => ModeFacts(
    handoverSessionValid: _db.select(
      'SELECT 1 FROM handover_session WHERE closed_at IS NULL AND expires_at > ? LIMIT 1',
      <Object?>[_clock.nowUtc().toUtc().toIso8601String()],
    ).isNotEmpty,
    liveKeysVerified: await _liveKeysVerified(),
  );
}
