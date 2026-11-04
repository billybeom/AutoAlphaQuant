// E11j — 월 납입 운영값 저장 · 읽기 창구(설계 13 §8 R54 J3 · J5 · J6 · 06 M3-6 시험 ①~⑤).
//
// 🔵 잡는 것: ① append-only(UPDATE 0 · superseded_by 비움) · 변경 2회 = 이력 2행 · 현재값 1개 ② 재시도 = 같은 행 · 알림 0
//    ③ 거부 = 아무것도 안 씀 · 신뢰 시각 모름 = 거부 ④ 🔴 접수일과 적용일이 다른 달이면 현재값 = 옛 값(⑤)
//    ⑤ `CONTRIBUTION_CHANGED` 1건 · 멱등 키 = row_id ⑥ watch = 구독 즉시 + 기록마다 ⑦ 읽기 = 신뢰 시각 · 모르면 기기 시계.
import 'dart:async';
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

class _Trusted implements TrustedClock {
  _Trusted(this.at);
  DateTime? at;
  @override
  DateTime? trustedNowUtc() => at;
}

// 한국 2026-11-04 10:00.
final DateTime _t0 = DateTime.utc(2026, 11, 4, 1);

void main() {
  late Directory dir;
  late Database db;
  late _Clock clock;
  late _Trusted trusted;
  late ContributionSettingSource src;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_opl_');
    clock = _Clock(_t0);
    trusted = _Trusted(_t0);
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    src = ContributionSettingSource(
      db,
      trusted: trusted,
      clock: clock,
      kr: frozenExchangeCalendar(Market.kr),
      deviceId: 'dev-1',
    );
  });
  tearDown(() async {
    await src.close();
    db.close();
    dir.deleteSync(recursive: true);
  });

  List<Row> rows() =>
      db.select('SELECT * FROM operating_param_log ORDER BY row_id').toList();

  test('기록 = 1행 append · 칸 · 알림 1건 · 멱등 키 = row_id', () {
    final ContributionChangeResult r = src.change(
      amountInput: '150000',
      actionRunId: 'run-1',
    );
    expect(
      (r.ok, r.replayed, r.reasonCode, r.rejectedText),
      (true, false, null, null),
    );
    final Row row = rows().single;
    expect(
      (
        row['param_key'],
        row['value_text'],
        row['changed_at'],
        row['effective_from'],
        row['action_run_id'],
        row['device_id'],
        row['superseded_by'],
      ),
      (
        OperatingParamKeys.monthlyContribution,
        '150000',
        _t0.toIso8601String(),
        '2026-12-01',
        'run-1',
        'dev-1',
        null,
      ),
    );
    expect(r.row!.rowId, row['row_id']);
    expect(r.alerts, <String>{AlertCodes.contributionChanged});
    expect(r.alertDedupKey, 'CONTRIBUTION_CHANGED:${row['row_id']}');
  });

  test(
    '🔴 append-only — 변경 2회 = 이력 2행(앞 행 그대로 · superseded_by 비움) · 현재값 1개',
    () {
      src.change(amountInput: '90000', actionRunId: 'run-1');
      final List<Object?> first = rows().single.values;
      trusted.at = _t0.add(const Duration(days: 40)); // 한국 12-14
      clock.at = trusted.at!;
      src.change(amountInput: '120000', actionRunId: 'run-2');
      final List<Row> all = rows();
      expect(all, hasLength(2));
      expect(all.first.values, first);
      expect(all.map((Row r) => r['superseded_by']), <Object?>[null, null]);
      expect(src.current().amountText, '9만원');
      expect(src.current().appliesFromText, '다음 납입 주기(1월 4일)부터 12만원이 적용됩니다.');
    },
  );

  test('🔴 같은 신뢰 시각에 두 번 = 둘째는 거부(UNIQUE 충돌로 터지지 않는다)', () {
    expect(src.change(amountInput: '150000', actionRunId: 'run-1').ok, isTrue);
    final ContributionChangeResult again = src.change(
      amountInput: '170000',
      actionRunId: 'run-2',
    );
    expect(again.reasonCode, ContributionRejectCodes.clockNotAdvanced);
    expect(rows(), hasLength(1));
  });

  test('같은 회차 재시도 = 같은 행 · 알림 0 · 새 행 0', () {
    final ContributionChangeResult a = src.change(
      amountInput: '150000',
      actionRunId: 'run-1',
    );
    final ContributionChangeResult b = src.change(
      amountInput: '170000',
      actionRunId: 'run-1',
    );
    expect((b.ok, b.replayed, b.row!.rowId), (true, true, a.row!.rowId));
    expect(b.alerts, isEmpty);
    expect(b.alertDedupKey, 'CONTRIBUTION_CHANGED:${a.row!.rowId}');
    expect(rows(), hasLength(1));
  });

  test('🔴 거부 = 아무것도 안 씀 · 신뢰 시각 모름 = 거부', () {
    final ContributionChangeResult bad = src.change(
      amountInput: '10만',
      actionRunId: 'run-1',
    );
    expect(
      (bad.ok, bad.reasonCode),
      (false, ContributionRejectCodes.notNumber),
    );
    expect(bad.alerts, isEmpty);
    expect(bad.alertDedupKey, isNull);
    trusted.at = null;
    final ContributionChangeResult unknown = src.change(
      amountInput: '150000',
      actionRunId: 'run-2',
    );
    expect(unknown.reasonCode, ContributionRejectCodes.trustedTimeUnknown);
    expect(rows(), isEmpty);
  });

  test('🔴 접수일과 적용일이 다른 달 — 적용일 전 현재값 = 옛 값 · 적용일부터 새 값(06 M3-6 ⑤)', () {
    expect(src.current().amountText, '10만원');
    src.change(amountInput: '150000', actionRunId: 'run-1');
    final ContributionSetting before = src.current();
    expect(before.amountText, '10만원');
    expect(before.amountInputText, '100000');
    expect(before.appliesFromText, '다음 납입 주기(12월 1일)부터 15만원이 적용됩니다.');
    expect(before.lastChangedText, '최근 변경: 2026-11-04 · 10만원 → 15만원');
    trusted.at = DateTime.utc(2026, 11, 30, 15); // 한국 12-01 00:00
    expect(src.current().amountText, '15만원');
    // asOf.observedAt = 읽은 시각(기기 시계) — 신뢰 시각이 아니다.
    expect(src.current().asOf.observedAt, _t0);
    expect(src.current().asOf.label, '설정 기준 2026-12-01');
    expect(src.current().appliesFromText, '다음 납입 주기(1월 4일)부터 이 금액이 적용됩니다.');
  });

  test('읽기 = 신뢰 시각 · 모르면 기기 시계 · asOf = 읽은 시각', () {
    src.change(amountInput: '150000', actionRunId: 'run-1');
    trusted.at = null;
    clock.at = DateTime.utc(2026, 12, 2);
    expect(src.current().amountText, '15만원');
    expect(src.current().asOf.observedAt, DateTime.utc(2026, 12, 2));
    expect(src.current().asOf.label, '설정 기준 2026-12-02');
    clock.at = DateTime.utc(2026, 11, 20);
    expect(src.current().amountText, '10만원');
  });

  test('watch = 구독 즉시 1번 + 기록마다 1번(거부 · 재시도는 안 냄)', () async {
    final List<ContributionSetting> got = <ContributionSetting>[];
    final StreamSubscription<ContributionSetting> sub = src.watch().listen(
      got.add,
    );
    await Future<void>.delayed(Duration.zero);
    expect(got.map((ContributionSetting s) => s.lastChangedText), <String>[
      '변경 기록 없음(기본값)',
    ]);
    src.change(amountInput: '150000', actionRunId: 'run-1');
    src.change(amountInput: 'x', actionRunId: 'run-2');
    src.change(amountInput: '150000', actionRunId: 'run-1');
    await Future<void>.delayed(Duration.zero);
    expect(got, hasLength(2));
    trusted.at = _t0.add(const Duration(minutes: 1));
    expect(got.last.appliesFromText, '다음 납입 주기(12월 1일)부터 15만원이 적용됩니다.');
    await sub.cancel();
    src.change(amountInput: '170000', actionRunId: 'run-3');
    await Future<void>.delayed(Duration.zero);
    expect(got, hasLength(2));
    // 새 구독은 지금 값으로 시작한다.
    final ContributionSetting first = await src.watch().first;
    expect(first.appliesFromText, '다음 납입 주기(12월 1일)부터 17만원이 적용됩니다.');
  });

  test('다른 param_key 행은 읽지 않는다', () {
    db.execute(
      'INSERT INTO operating_param_log(param_key, value_text, changed_at, effective_from, action_run_id, device_id) '
      "VALUES ('other_key', '5', '2026-11-01T00:00:00.000Z', '2026-11-02', 'r', 'd')",
    );
    expect(contributionRowsOf(db), isEmpty);
    expect(src.current().lastChangedText, '변경 기록 없음(기본값)');
  });
}
