// E13c2 — X5 읽기 쪽 operator 판(설계 13 §8 R59 S0~S9).
//
// 🔵 잡는 것: ① 빈 원장 = 빈 문장 · 지금 기준 ② 브로커 행 → 라벨 · 정렬 · 조치 링크 · 마지막 대사 기준
//    ③ 닫힌 시각 = 탐지 뒤 첫 해제 로그(실제 `clearReconBlock`) · 다시 열리면 «열림» ④ 갱신 = 관계 표만 · 같은 값은 다시 안 냄
//    ⑤ 정정 · 시스템 밖 자산 = 빈 봉투 · 행이 생기면 스트림 오류 ⑥ 5칸 = 대사 전 · 일치 · 차단 · 연결된 파생 지연 ·
//    해당 없는 행 무시 · 안내 모드 · 기준 = 브로커 대사(해제 · 무결성 행 제외) · 구독 갱신.
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 11, 5, 9); // 한국 18:00

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late SqliteLedgerRepository repo;
  late OperatingMode mode;
  late LedgerDiagnosticsSource board;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_lr_');
    clock = _Clock(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    repo = SqliteLedgerRepository(db, clock: clock);
    mode = OperatingMode.autoTrade;
    board = LedgerDiagnosticsSource(
      db,
      clock: clock,
      operatingMode: () => mode,
    );
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  void reconLog(String id, DateTime at, String action) => db.execute(
    'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) VALUES (?, ?, 0, ?, ?)',
    <Object?>[id, at.toIso8601String(), '{}', action],
  );

  void diff(
    String id, {
    String pair = 'CANON_BROKER',
    String axis = 'QUANTITY',
    String severity = 'BLOCKING',
    String status = 'OPEN',
    String candidates = '["FILL_LAG","MANUAL_ORDER"]',
    required DateTime detected,
    int applicable = 1,
  }) => db.execute(
    'INSERT INTO ledger_diff (diff_id, pair, axis, authored_date, delta, delta_label, severity, origin_code, status, detected_at, applicable) '
    "VALUES (?, ?, ?, '2026-11-05', ?, ?, ?, NULL, ?, ?, ?)",
    <Object?>[
      id,
      pair,
      axis,
      '{"candidates":$candidates}',
      '$id 문장',
      severity,
      status,
      detected.toIso8601String(),
      applicable,
    ],
  );

  group('SqliteLedgerRepository(R59 S1 · S2 · S9)', () {
    test('빈 원장 = «최근 대조 차이가 없습니다» · 기준 = 지금', () {
      final ListResult<LedgerDiffRow> r = repo.recentDiffs();
      expect(r.rows, isEmpty);
      expect(
        (r.emptyLabel, r.hasMore, r.asOf.observedAt, r.asOf.label),
        ('최근 대조 차이가 없습니다', false, _t0, '대조 기준 2026-11-05'),
      );
    });

    test('브로커 행 → 라벨 · 정렬 · 조치 링크 · 기준 = 마지막 브로커 대사(해제 · 무결성 제외)', () {
      reconLog('rc-0#1', DateTime.utc(2026, 11, 3), 'MATCHED');
      reconLog('rc-a#1', DateTime.utc(2026, 11, 4, 0, 30), 'BLOCKED');
      reconLog('rc-clear-b#1', DateTime.utc(2026, 11, 4, 10), 'CLEARED');
      reconLog('li-c#1', DateTime.utc(2026, 11, 4, 11), 'INTEGRITY_OK');
      diff(
        'cash',
        axis: 'CASH',
        severity: 'OBSERVATIONAL',
        candidates: '["EXTERNAL_CASHFLOW"]',
        detected: DateTime.utc(2026, 11, 4, 0, 31),
      );
      diff('qty', detected: DateTime.utc(2026, 11, 4, 0, 30));
      final ListResult<LedgerDiffRow> r = repo.recentDiffs();
      expect(r.rows.map((LedgerDiffRow x) => x.diffId), <String>[
        'qty',
        'cash',
      ]);
      final LedgerDiffRow q = r.rows.first;
      expect(
        (
          q.pairLabel,
          q.axisLabel,
          q.severityLabel,
          q.statusLabel,
          q.routeLabel,
          q.detectedAtText,
          q.deltaLabel,
        ),
        (
          '브로커 대조',
          '수량',
          '주문 차단',
          '열림',
          '승인 필요',
          '탐지 2026-11-04 09:30',
          'qty 문장',
        ),
      );
      expect(q.candidateOrigins.map((ReasonChip c) => c.label), <String>[
        '체결 반영 지연',
        '수동 주문',
      ]);
      expect(
        q.actionLink,
        const LinkAction(label: '정정하기', deepLink: AppRoutes.x5RepairWizard),
      );
      expect(r.rows.last.actionLink, isNull);
      expect(r.asOf.observedAt, DateTime.utc(2026, 11, 4, 0, 30));
      expect(r.asOf.label, '대조 기준 2026-11-04');
    });

    test('🔴 닫힌 시각 = 탐지 뒤 첫 해제 로그(clearReconBlock) · 다시 열리면 «열림»', () async {
      final SqliteOrderLedger ledger = SqliteOrderLedger(
        db,
        mode: RunMode.live,
        clock: clock,
        kr: frozenExchangeCalendar(Market.kr),
      );
      reconLog('rc-clear-old#1', DateTime.utc(2026, 11, 1), 'CLEARED');
      reconLog('rc-a#1', DateTime.utc(2026, 11, 3), 'BLOCKED');
      diff('qty', detected: DateTime.utc(2026, 11, 3));
      db.execute(
        "INSERT INTO trading_block (flag_id, set_at, reason) VALUES ('RECON_MISMATCH', '2026-11-03T00:00:00Z', 'x')",
      );
      await ledger.clearReconBlock(
        ReconClearance(
          originCode: OriginCodes.fillLag,
          decisionId: 'dj',
          clearedBy: 'me',
          clearedAtUtc: DateTime.utc(2026, 11, 4, 16),
        ),
      );
      reconLog('rc-clear-later#1', DateTime.utc(2026, 11, 6, 1), 'CLEARED');
      // 파생 행은 브로커 해제 로그로 닫힌 날을 만들지 않는다(생산자 0 = 날짜 없음).
      diff(
        'gh',
        pair: 'CANON_GITHUB',
        axis: 'CHAIN_HASH',
        severity: 'OBSERVATIONAL',
        status: 'RESOLVED',
        candidates: '["ARCHIVE_LAG"]',
        detected: DateTime.utc(2026, 11, 3),
      );
      LedgerDiffRow row(String id) => repo.recentDiffs().rows.firstWhere(
        (LedgerDiffRow x) => x.diffId == id,
      );
      expect(row('qty').statusLabel, '해소됨 · 2026-11-05');
      expect(row('gh').statusLabel, '해소됨');
      // 한국 11-05 01:00 = 탐지 뒤 첫 해제 · 더 뒤 해제(한국 11-06) · 앞선 해제(11-01)는 보지 않는다.
      db.execute(
        "UPDATE ledger_diff SET status = 'OPEN', detected_at = '2026-11-05T02:00:00.000Z' WHERE diff_id = 'qty'",
      );
      final LedgerDiffRow again = row('qty');
      expect((again.statusLabel, again.actionLink?.label), ('열림', '정정하기'));
    });

    test('갱신 — 구독 즉시 · 관계 표가 바뀔 때 · 같은 값은 다시 안 냄 · 관계없는 표 = 조용', () async {
      final List<int> seen = <int>[];
      final sub = repo.watchOpenDiffs().listen(
        (ListResult<LedgerDiffRow> r) => seen.add(r.rows.length),
      );
      await pumpEventQueue();
      expect(seen, <int>[0]);
      diff('qty', detected: DateTime.utc(2026, 11, 5));
      await pumpEventQueue();
      expect(seen, <int>[0, 1]);
      db.execute(
        "UPDATE ledger_diff SET delta_label = delta_label WHERE diff_id = 'qty'",
      );
      db.execute(
        "INSERT INTO sync_state (target, last_ok_at, status, operator_epoch, updated_at) VALUES ('GITHUB', NULL, 'OK', 0, 't')",
      );
      await pumpEventQueue();
      expect(seen, <int>[0, 1]);
      db.execute('BEGIN');
      diff('a', detected: DateTime.utc(2026, 11, 5));
      diff('b', detected: DateTime.utc(2026, 11, 5));
      db.execute('COMMIT');
      await pumpEventQueue();
      expect(seen, <int>[0, 1, 3]);
      await sub.cancel();
      diff('c', detected: DateTime.utc(2026, 11, 5));
      await pumpEventQueue();
      expect(seen, <int>[0, 1, 3]);
    });

    test('watchLedgerQuery — 관계 표만 · 한 트랜잭션 = 한 번 · 해지 뒤 조용', () async {
      int n = 0;
      final List<int> seen = <int>[];
      final sub = watchLedgerQuery<int>(db, const <String>{
        'ledger_diff',
      }, () => ++n).listen(seen.add);
      await pumpEventQueue();
      expect(seen, <int>[1]);
      db.execute(
        "INSERT INTO sync_state (target, last_ok_at, status, operator_epoch, updated_at) VALUES ('GITHUB', NULL, 'OK', 0, 't')",
      );
      await pumpEventQueue();
      expect(seen, <int>[1]);
      db.execute('BEGIN');
      diff('a', detected: _t0);
      diff('b', detected: _t0);
      diff('c', detected: _t0);
      db.execute('COMMIT');
      await pumpEventQueue();
      expect(seen, <int>[1, 2]);
      await sub.cancel();
      diff('d', detected: _t0);
      await pumpEventQueue();
      expect(seen, <int>[1, 2]);
      expect(n, 2);
    });

    test('🔴 해지 직전 갱신 — 걸려 있던 타이머가 닫힌 흐름에 쓰지 않는다', () async {
      int n = 0;
      final List<int> seen = <int>[];
      final sub = watchLedgerQuery<int>(db, const <String>{
        'ledger_diff',
      }, () => ++n).listen(seen.add);
      await pumpEventQueue();
      diff('x', detected: _t0);
      // 알림이 와서 타이머가 걸릴 때까지(마이크로태스크만).
      await Future<void>.value();
      await Future<void>.value();
      await sub.cancel();
      await pumpEventQueue();
      expect(seen, <int>[1]);
      expect(n, 1);
    });

    test(
      '정정 이력 · 시스템 밖 자산 = 빈 봉투 · 🆕 E16f1 정정 이력은 실물(상세 없는 행 = 스트림 오류)',
      () async {
        final ListResult<LedgerRepairRow> r = await repo.watchRepairs().first;
        expect(r.rows, isEmpty);
        expect(
          (r.emptyLabel, r.asOf.label),
          ('정정 이력이 없습니다', '정정 이력 기준 2026-11-05'),
        );
        final ListResult<ExternalHoldingRow> h = await repo
            .watchExternalHoldings()
            .first;
        expect(h.rows, isEmpty);
        expect(h.emptyLabel, '시스템 밖 자산이 없습니다');
        db.execute(
          'INSERT INTO ledger_repair (repair_id, diff_id, direction, origin_code, decision_id, evidence_hash, supersedes, applied_at) '
          "VALUES ('rp', 'd', 'DERIVED_RESYNC', 'PUSH_LAG', NULL, 'ev', NULL, '2026-11-04T00:00:00Z')",
        );
        await expectLater(repo.watchRepairs().first, throwsStateError);
      },
    );
  });

  group('LedgerDiagnosticsSource(R59 S5 · S7)', () {
    (String, String, UiLevel) cell(DiagnosticsVm v, LedgerPair p) {
      final DiagnosticCell c = v.cells.firstWhere(
        (DiagnosticCell x) => x.pair == p,
      );
      return (c.stateCode, c.stateLabel, c.level);
    }

    test('대사 전 = 점검 0 · 첫 대사 뒤 일치 · 차단 행 = 어긋남 · 해당 없는 행은 보지 않음', () {
      DiagnosticsVm v = board.diagnostics();
      expect(v.headline, '아직 점검한 칸이 없습니다.');
      expect(cell(v, LedgerPair.canonBroker), (
        'NOT_CHECKED',
        '아직 대사 전 — 점검 안 함',
        UiLevel.info,
      ));
      expect(cell(v, LedgerPair.canonGithub), (
        'NOT_CHECKED',
        '아직 연결 전 — 점검 안 함',
        UiLevel.info,
      ));
      expect(cell(v, LedgerPair.canonSelfReport).$1, 'NOT_APPLICABLE');
      expect(v.asOf.observedAt, _t0);
      reconLog('rc-a#1', DateTime.utc(2026, 11, 5, 0, 10), 'MATCHED');
      v = board.diagnostics();
      expect(
        (cell(v, LedgerPair.canonBroker).$1, v.headline),
        ('OK', '점검한 한 칸이 모두 일치합니다.'),
      );
      expect(v.asOf.observedAt, DateTime.utc(2026, 11, 5, 0, 10));
      diff('na', detected: _t0, applicable: 0);
      expect(cell(board.diagnostics(), LedgerPair.canonBroker).$1, 'OK');
      diff(
        'cash',
        axis: 'CASH',
        severity: 'OBSERVATIONAL',
        candidates: '["EXTERNAL_CASHFLOW"]',
        detected: _t0,
      );
      expect(cell(board.diagnostics(), LedgerPair.canonBroker), (
        'CASH_OBSERVED',
        '현금이 기록과 다릅니다(관측)',
        UiLevel.watch,
      ));
      diff('qty', detected: _t0);
      diff('exe', axis: 'EXECUTION_ROW', detected: _t0);
      v = board.diagnostics();
      expect(cell(v, LedgerPair.canonBroker), (
        'MISMATCH',
        '수량 · 체결 건이 어긋납니다',
        UiLevel.blocked,
      ));
      expect(v.headline, '다섯 칸 중 한 칸이 어긋납니다.');
    });

    test('연결된 파생 · 열린 지연 행 = 뒤처짐(watch) · 해제 · 무결성 행은 기준이 아니다 · 안내 모드', () {
      reconLog('rc-a#1', DateTime.utc(2026, 11, 5, 0, 10), 'MATCHED');
      db.execute(
        "INSERT INTO sync_state (target, last_ok_at, status, operator_epoch, updated_at) VALUES ('SUPABASE', NULL, 'PUSH_LAG', 0, 't')",
      );
      diff(
        'sb',
        pair: 'CANON_SUPABASE',
        axis: 'EXECUTION_ROW',
        severity: 'OBSERVATIONAL',
        candidates: '["PUSH_LAG"]',
        detected: _t0,
      );
      diff(
        'gh',
        pair: 'CANON_GITHUB',
        axis: 'CHAIN_HASH',
        severity: 'OBSERVATIONAL',
        candidates: '["CHAIN_BROKEN"]',
        detected: _t0,
      );
      reconLog('li-x#1', DateTime.utc(2026, 11, 5, 3), 'INTEGRITY_OK');
      reconLog('rc-clear-x#1', DateTime.utc(2026, 11, 5, 4), 'CLEARED');
      DiagnosticsVm v = board.diagnostics();
      expect(cell(v, LedgerPair.canonSupabase), (
        'LAG',
        '미러가 뒤처집니다',
        UiLevel.watch,
      ));
      // GitHub 은 연결 전이라 열린 행이 있어도 점검 안 함.
      expect(cell(v, LedgerPair.canonGithub).$1, 'NOT_CHECKED');
      expect(v.headline, '다섯 칸 중 한 칸이 뒤처집니다. 파생 불일치는 주문을 막지 않습니다.');
      expect(v.asOf.observedAt, DateTime.utc(2026, 11, 5, 0, 10));
      mode = OperatingMode.advisory;
      v = board.diagnostics();
      expect(cell(v, LedgerPair.canonBroker).$1, 'NOT_APPLICABLE');
      expect(cell(v, LedgerPair.canonSelfReport), (
        'NOT_CHECKED',
        '점검하지 않음',
        UiLevel.info,
      ));
    });

    test('구독 — sync_state · 대사 로그가 바뀌면 다시 낸다', () async {
      final List<String> heads = <String>[];
      final sub = board.watchDiagnostics().listen(
        (DiagnosticsVm v) => heads.add(v.headline),
      );
      await pumpEventQueue();
      reconLog('rc-a#1', DateTime.utc(2026, 11, 5, 0, 10), 'MATCHED');
      await pumpEventQueue();
      db.execute(
        "INSERT INTO sync_state (target, last_ok_at, status, operator_epoch, updated_at) VALUES ('CALENDAR', NULL, 'OK', 0, 't')",
      );
      await pumpEventQueue();
      await sub.cancel();
      expect(heads, <String>[
        '아직 점검한 칸이 없습니다.',
        '점검한 한 칸이 모두 일치합니다.',
        '점검한 두 칸이 모두 일치합니다.',
      ]);
    });
  });
}
