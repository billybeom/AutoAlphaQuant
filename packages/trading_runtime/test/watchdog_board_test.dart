// 워치독 보드 · 바깥 대조 · 자기 점검(설계 13 §8 R45 C7~C9 · 앱 04 §7 `W-01`).
//
// 🔵 잡는 것: ① 상태 6개의 코드 · 문구 · 레벨 · 유예 문구 · 마지막 신호 ② 🔴 지연 ≠ 실패 · 일시정지 = info
//    ③ 바깥 대조(받음 · 못 받음 60초 경계 · 없음 · 겹침 · 바깥만 멈춤 — 로컬 실패 · 멈춤 · 아직은 그대로)
//    ④ 바깥을 못 읽음 = 행 그대로 · 머리만 ⑤ 머리 · 고지 · 빈 보드 · 기준일 ⑥ 🔴 보드에 슬러그 0 ⑦ 자기 점검.

import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';
import 'package:trading_runtime/trading_runtime.dart';

/// [ymd] 의 KST 시각(UTC 값).
DateTime _kst(String ymd, int h, int m, [int s = 0]) =>
    DateTime.parse('${ymd}T00:00:00Z')
        .add(Duration(hours: h - 9, minutes: m, seconds: s));

final DateTime _now = _kst('2026-11-04', 18, 0);

WatchdogBoardInput _in(
  WatchdogState state, {
  String slug = 'live-auto-daily_data',
  String label = 'daily_data',
  Duration grace = const Duration(minutes: 30),
  Duration? lateBy,
  OccurrenceRecord? record,
}) => WatchdogBoardInput(
  label: label,
  slug: slug,
  verdict: WatchdogVerdict(state, lateBy: lateBy),
  grace: grace,
  record: record,
);

RemoteCheck _r(
  String slug, {
  RemoteCheckStatus status = RemoteCheckStatus.up,
  DateTime? last,
}) => RemoteCheck(slug: slug, status: status, lastPingUtc: last);

(String, String, UiLevel, String?, String) _cell(WatchdogCheck c) =>
    (c.stateCode, c.stateLabel, c.level, c.graceText, c.lastPingText);

WatchdogCheck _one(WatchdogBoardInput i, {List<RemoteCheck>? remote}) =>
    buildWatchdogBoard(
      rows: <WatchdogBoardInput>[i],
      nowUtc: _now,
      holiday: false,
      remote: remote,
    ).rows.single;

void main() {
  group('로컬 판정 → 행(R45 C7)', () {
    test('상태 6개 — 코드 · 문구 · 레벨 · 유예 문구 · 마지막 신호', () {
      final DateTime ok = _kst('2026-11-04', 9, 3);
      final DateTime bad = _kst('2026-11-04', 10, 2);
      expect(_cell(_one(_in(WatchdogState.pending))), (
        'WAITING',
        '기다리는 중',
        UiLevel.ok,
        '유예 30분 안입니다',
        '아직 신호가 없습니다',
      ));
      expect(
        _cell(
          _one(
            _in(
              WatchdogState.success,
              record: OccurrenceRecord(succeededUtc: ok),
            ),
          ),
        ),
        ('OK', '정상', UiLevel.ok, null, '오늘 09:03에 확인'),
      );
      expect(
        _cell(
          _one(
            _in(
              WatchdogState.late,
              grace: const Duration(hours: 2),
              lateBy: const Duration(minutes: 28),
              record: OccurrenceRecord(succeededUtc: ok),
            ),
          ),
        ),
        (
          'DELAYED',
          '지연(28분)',
          UiLevel.watch,
          '유예 2시간을 넘겨 도착했습니다',
          '오늘 09:03에 확인',
        ),
      );
      expect(
        _cell(
          _one(
            _in(WatchdogState.failed, record: OccurrenceRecord(failedUtc: bad)),
          ),
        ),
        ('FAILED', '실패', UiLevel.blocked, null, '오늘 10:02에 실패 신호'),
      );
      expect(
        _cell(
          _one(_in(WatchdogState.failed, grace: const Duration(minutes: 90))),
        ),
        ('FAILED', '실패', UiLevel.blocked, '유예 1시간 30분이 지났습니다', '아직 신호가 없습니다'),
      );
      expect(
        _cell(
          _one(
            _in(
              WatchdogState.holiday,
              record: OccurrenceRecord(
                succeededUtc: _kst('2026-11-04', 7, 12),
                holidayPing: true,
              ),
            ),
          ),
        ),
        ('OK', '휴장일 확인 — 정상', UiLevel.ok, null, '오늘 07:12에 휴장 확인'),
      );
      expect(
        _cell(
          _one(
            _in(
              WatchdogState.paused,
              record: OccurrenceRecord(succeededUtc: _kst('2026-11-03', 16, 5)),
            ),
          ),
        ),
        (
          'PAUSED',
          '유지보수로 일시정지',
          UiLevel.info,
          '유지보수 창이 끝나면 다시 봅니다',
          '어제 16:05에 확인',
        ),
      );
    });

    test('🔴 지연은 실패색이 아니다 · 일시정지는 실패 · 결측이 아니다', () {
      final WatchdogCheck late = _one(
        _in(WatchdogState.late, lateBy: const Duration(minutes: 5)),
      );
      final WatchdogCheck paused = _one(_in(WatchdogState.paused));
      expect(late.level, isNot(UiLevel.blocked));
      expect(paused.level, UiLevel.info);
    });

    test('마지막 신호 = 나중 사건 · 날 바뀜(어제 · M월 d일) · 실패 뒤 성공 = 확인', () {
      String last(OccurrenceRecord r) =>
          _one(_in(WatchdogState.success, record: r)).lastPingText;
      expect(
        last(
          OccurrenceRecord(
            succeededUtc: _kst('2026-11-04', 9, 30),
            failedUtc: _kst('2026-11-04', 9, 10),
          ),
        ),
        '오늘 09:30에 확인',
      );
      expect(
        last(
          OccurrenceRecord(
            succeededUtc: _kst('2026-11-04', 9, 10),
            failedUtc: _kst('2026-11-04', 9, 30),
          ),
        ),
        '오늘 09:30에 실패 신호',
      );
      expect(
        last(OccurrenceRecord(succeededUtc: _kst('2026-11-03', 23, 40))),
        '어제 23:40에 확인',
      );
      expect(
        last(OccurrenceRecord(succeededUtc: _kst('2026-11-02', 16, 5))),
        '11월 2일 16:05에 확인',
      );
      // KST 자정 직후 = 오늘(UTC 로는 전날).
      expect(
        last(OccurrenceRecord(succeededUtc: _kst('2026-11-04', 0, 10))),
        '오늘 00:10에 확인',
      );
    });

    test('유예 글자 — 분 · 시간 · 시간 분(받은 값을 옮길 뿐)', () {
      for (final (Duration g, String text) in <(Duration, String)>[
        (const Duration(minutes: 30), '유예 30분 안입니다'),
        (const Duration(hours: 1), '유예 1시간 안입니다'),
        (const Duration(minutes: 90), '유예 1시간 30분 안입니다'),
        (const Duration(hours: 24), '유예 24시간 안입니다'),
        (const Duration(minutes: 59), '유예 59분 안입니다'),
      ]) {
        expect(_one(_in(WatchdogState.pending, grace: g)).graceText, text);
      }
    });

    test('checkId = 차례(wd_0001…) · 이름표 그대로 · route 없음', () {
      final WatchdogBoardVm b = buildWatchdogBoard(
        rows: <WatchdogBoardInput>[
          _in(WatchdogState.success, label: '장 전 준비 배치'),
          _in(
            WatchdogState.success,
            label: '주문 배치',
            slug: 'live-auto-kr_order',
          ),
          _in(
            WatchdogState.success,
            label: '생존 신호',
            slug: 'live-auto-engine_alive',
          ),
        ],
        nowUtc: _now,
        holiday: false,
        remote: null,
      );
      expect(b.rows.map((WatchdogCheck c) => c.checkId), <String>[
        'wd_0001',
        'wd_0002',
        'wd_0003',
      ]);
      expect(b.rows.map((WatchdogCheck c) => c.label), <String>[
        '장 전 준비 배치',
        '주문 배치',
        '생존 신호',
      ]);
      expect(b.rows.every((WatchdogCheck c) => c.route == null), isTrue);
    });
  });

  group('바깥 대조(R45 C8 · D12)', () {
    final DateTime local = _kst('2026-11-04', 9, 3);
    final OccurrenceRecord rec = OccurrenceRecord(succeededUtc: local);

    test('받음 = 그대로 · 로컬 핑보다 60초 앞까지 = 받음 · 61초 앞 · 없음 = 못 받음(watch)', () {
      for (final (DateTime? seen, String code) in <(DateTime?, String)>[
        (local, 'OK'),
        (local.add(const Duration(minutes: 5)), 'OK'),
        (local.subtract(const Duration(seconds: 60)), 'OK'),
        (local.subtract(const Duration(seconds: 61)), 'OUTSIDE_NOT_RECEIVED'),
        (null, 'OUTSIDE_NOT_RECEIVED'),
      ]) {
        final WatchdogCheck c = _one(
          _in(WatchdogState.success, record: rec),
          remote: <RemoteCheck>[_r('live-auto-daily_data', last: seen)],
        );
        expect(c.stateCode, code, reason: '$seen');
        if (code != 'OK') {
          expect(
            (c.stateLabel, c.level),
            ('정상 — 바깥 감시가 못 받았습니다', UiLevel.watch),
          );
        }
      }
    });

    test('바깥에 없음 · 겹침 · 바깥만 멈춤 = watch · 지연 · 휴장도 대조한다', () {
      final List<RemoteCheck> none = <RemoteCheck>[
        _r('live-auto-other', last: local),
      ];
      final List<RemoteCheck> dup = <RemoteCheck>[
        _r('live-auto-daily_data', last: local),
        _r('live-auto-daily_data', last: local),
      ];
      final List<RemoteCheck> paused = <RemoteCheck>[
        _r(
          'live-auto-daily_data',
          status: RemoteCheckStatus.paused,
          last: local,
        ),
      ];
      expect(
        _cell(_one(_in(WatchdogState.success, record: rec), remote: none)),
        (
          'OUTSIDE_MISSING',
          '정상 — 바깥 감시에 체크가 없습니다',
          UiLevel.watch,
          null,
          '오늘 09:03에 확인',
        ),
      );
      expect(
        _one(_in(WatchdogState.success, record: rec), remote: dup).stateCode,
        'OUTSIDE_AMBIGUOUS',
      );
      expect(
        _one(
          _in(WatchdogState.success, record: rec),
          remote: paused,
        ).stateLabel,
        '정상 — 바깥 감시가 일시정지돼 있습니다',
      );
      final WatchdogCheck late = _one(
        _in(
          WatchdogState.late,
          lateBy: const Duration(minutes: 3),
          record: rec,
        ),
        remote: none,
      );
      expect(
        (late.stateLabel, late.level),
        ('지연(3분) — 바깥 감시에 체크가 없습니다', UiLevel.watch),
      );
      final WatchdogCheck hol = _one(
        _in(
          WatchdogState.holiday,
          record: OccurrenceRecord(succeededUtc: local, holidayPing: true),
        ),
        remote: <RemoteCheck>[
          _r(
            'live-auto-daily_data',
            last: local.subtract(const Duration(hours: 24)),
          ),
        ],
      );
      expect(hol.stateCode, 'OUTSIDE_NOT_RECEIVED');
    });

    test('로컬 실패 · 멈춤 · 아직 = 바깥이 어떻든 그대로(정본 = 로컬)', () {
      final List<RemoteCheck> none = <RemoteCheck>[];
      expect(
        (
          _one(_in(WatchdogState.failed), remote: none).stateCode,
          _one(_in(WatchdogState.failed), remote: none).level,
        ),
        ('FAILED', UiLevel.blocked),
      );
      expect(_one(_in(WatchdogState.paused), remote: none).stateCode, 'PAUSED');
      expect(
        _one(_in(WatchdogState.pending), remote: none).stateCode,
        'WAITING',
      );
    });

    test('바깥을 못 읽음(null) = 행은 로컬 그대로 · 머리만 «읽지 못했습니다»', () {
      final WatchdogBoardVm b = buildWatchdogBoard(
        rows: <WatchdogBoardInput>[_in(WatchdogState.success, record: rec)],
        nowUtc: _now,
        holiday: false,
        remote: null,
      );
      expect(b.rows.single.stateCode, 'OK');
      expect(b.lastReceivedText, '마지막 수신 — 바깥 감시를 읽지 못했습니다');
    });
  });

  group('머리 · 고지 · 빈 보드 · 기준일(R45 C7)', () {
    test('머리 = 바깥 last_ping 최신 · 오늘 = 시각만 · 어제 = «어제» · 받은 적 없음 = null', () {
      WatchdogBoardVm b(List<RemoteCheck> r) => buildWatchdogBoard(
        rows: const <WatchdogBoardInput>[],
        nowUtc: _now,
        holiday: false,
        remote: r,
      );
      expect(
        b(<RemoteCheck>[
          _r('a', last: _kst('2026-11-04', 9, 12)),
          _r('b', last: _kst('2026-11-04', 17, 58)),
          _r('c'),
        ]).lastReceivedText,
        '마지막 수신 17:58',
      );
      expect(
        b(<RemoteCheck>[_r('a', last: _kst('2026-11-03', 23, 40))])
            .lastReceivedText,
        '마지막 수신 어제 23:40',
      );
      expect(b(<RemoteCheck>[_r('a')]).lastReceivedText, isNull);
      expect(b(const <RemoteCheck>[]).lastReceivedText, isNull);
    });

    test('빈 보드 = 빈 문구 · 한계 고지는 늘 · 휴장 고지 = 휴장일만 · 기준일', () {
      final WatchdogBoardVm empty = buildWatchdogBoard(
        rows: const <WatchdogBoardInput>[],
        nowUtc: _now,
        holiday: true,
        remote: const <RemoteCheck>[],
      );
      expect(empty.rows, isEmpty);
      expect(empty.emptyLabel, kWatchdogEmptyLabel);
      expect(empty.emptyLabel, '등록된 워치독 체크가 아직 없습니다.');
      expect(empty.limitNotice, kWatchdogLimitNotice);
      expect(empty.holidayNotice, '휴장일의 쉼은 결측이 아닙니다.');
      final WatchdogBoardVm day = buildWatchdogBoard(
        rows: <WatchdogBoardInput>[_in(WatchdogState.success)],
        nowUtc: _kst('2026-11-05', 0, 30),
        holiday: false,
        remote: null,
      );
      expect(day.emptyLabel, isNull);
      expect(day.holidayNotice, isNull);
      expect(
        day.limitNotice,
        'healthchecks.io 자체 장애 때는 경보가 오지 않습니다 — 이메일 2차 채널로 받습니다.',
      );
      expect(day.asOf.tradeDate.yyyyMmDd, '2026-11-05');
      expect(day.asOf.label, '워치독 기준 2026-11-05');
      expect(day.asOf.source, AsOfSource.localSqlite);
      expect(day.asOf.staleAfter, const Duration(hours: 26));
      expect(day.asOf.observedAt, _kst('2026-11-05', 0, 30));
    });

    test('🔴 보드(JSON)에 슬러그 · 모드 이름이 없다 · 계약 꼴로 되읽힌다', () {
      final WatchdogBoardVm b = buildWatchdogBoard(
        rows: <WatchdogBoardInput>[
          _in(
            WatchdogState.success,
            slug: 'live-auto-daily_signal',
            label: '신호 배치',
            record: OccurrenceRecord(succeededUtc: _kst('2026-11-04', 9, 3)),
          ),
          _in(
            WatchdogState.failed,
            slug: 'live-auto-daily_reconcile',
            label: '대사 배치',
          ),
        ],
        nowUtc: _now,
        holiday: false,
        remote: <RemoteCheck>[
          _r('live-auto-daily_signal', last: _kst('2026-11-04', 9, 3)),
        ],
      );
      final String json = jsonEncode(b.toJson());
      for (final String bad in <String>[
        'live-auto',
        'daily_signal',
        'daily_reconcile',
        'hc-ping',
      ]) {
        expect(json.contains(bad), isFalse, reason: bad);
      }
      expect(
        WatchdogBoardVm.fromJson(jsonDecode(json) as Map<String, dynamic>),
        b,
      );
    });
  });

  test('E11b 판정과 잇기 — daily_data 유예 넘겨 성공 = 지연 행', () {
    final ExchangeCalendar kr = frozenExchangeCalendar(Market.kr);
    final JobCalendars cals = JobCalendars(
      kr: kr,
      us: frozenExchangeCalendar(Market.us),
    );
    final JobOccurrence occ = occurrenceOn(
      jobSpecOf('daily_data'),
      TradeDate('2026-11-04'),
      cals,
    );
    final DateTime done = occ.scheduledUtc
        .add(occ.spec.grace)
        .add(const Duration(minutes: 12));
    final OccurrenceRecord rec = OccurrenceRecord(succeededUtc: done);
    final WatchdogVerdict v = judgeOccurrence(
      occurrence: occ,
      record: rec,
      nowUtc: _now,
    );
    final WatchdogCheck c = buildWatchdogBoard(
      rows: <WatchdogBoardInput>[
        WatchdogBoardInput(
          label: 'daily_data',
          slug: 'live-auto-daily_data',
          verdict: v,
          grace: occ.spec.grace,
          record: rec,
        ),
      ],
      nowUtc: _now,
      holiday: false,
      remote: null,
    ).rows.single;
    expect(
      (c.stateCode, c.stateLabel, c.level),
      ('DELAYED', '지연(12분)', UiLevel.watch),
    );
  });

  group('자기 점검(R45 C9 · 06 M1-12 게이트)', () {
    test('없음 · 겹침 · 멈춤 · 한 번도 못 받음 · down · 기대 밖 — 이름 순', () {
      final List<RemoteAuditFinding> f = auditRemoteChecks(
        <String>{'f-down', 'a-up', 'b-missing', 'c-dup', 'd-paused', 'e-new'},
        <RemoteCheck>[
          _r('a-up'),
          _r('c-dup'),
          _r('c-dup'),
          _r('d-paused', status: RemoteCheckStatus.paused),
          _r('e-new', status: RemoteCheckStatus.fresh),
          _r('f-down', status: RemoteCheckStatus.down),
          _r('z-old-mode'),
          _r('g-grace', status: RemoteCheckStatus.grace),
        ],
      );
      expect(f.map((RemoteAuditFinding x) => '$x'), <String>[
        'missing:b-missing',
        'duplicate:c-dup',
        'paused:d-paused',
        'neverPinged:e-new',
        'down:f-down',
        'unexpected:g-grace',
        'unexpected:z-old-mode',
      ]);
      expect(
        f.first,
        const RemoteAuditFinding(RemoteAuditKind.missing, 'b-missing'),
      );
      expect(
        f.first.hashCode,
        const RemoteAuditFinding(RemoteAuditKind.missing, 'b-missing').hashCode,
      );
    });

    test('다 켜져 있고 받고 있음 = 빈 목록(grace · unknown 은 문제로 치지 않는다)', () {
      expect(
        auditRemoteChecks(
          <String>{'a', 'b', 'c'},
          <RemoteCheck>[
            _r('a'),
            _r('b', status: RemoteCheckStatus.grace),
            _r('c', status: RemoteCheckStatus.unknown),
          ],
        ),
        isEmpty,
      );
      expect(
        auditRemoteChecks(const <String>{}, const <RemoteCheck>[]),
        isEmpty,
      );
    });
  });
}
