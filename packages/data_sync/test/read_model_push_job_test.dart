// 🆕 E11l2c — 읽기 모델 push 일 · 로컬 상태 · row_version 정책 시험(설계 13 §8 R263 · 01 §8 미결 241).
//
// ① 리스 없음 = 아무것도 안 함 ② 판 = (epoch << 40) + 순번 · 단조 · 새 epoch 가 옛 판을 넘는다 ③ 상태 OK · LAG · FAILED 갈래
// ④ 나눠 보내기 · 합 ⑤ 리스 거부 = 그 자리에서 멈춤 ⑥ 행을 못 만듦 · 원천 오류 ⑦ 봉투 = 마지막 표 · 같은 목록 하나 ⑧ 계약 차례 · 원천 없는 표 0.
// 🆕 미결 242(설계 13 §8 R275 · 01 §48 K339 · K340) ⑨ 목록에서 빠진 행 = 같은 키 · 큰 판 · 차례 null 로 한 번 다시 보냄(직전 소속 = 곁 행)
// ⑩ 판정 밖(다른 모드 · 못 읽은 범위) = 다시 보내지 않고 소속에 둠 ⑪ 보냄 실패 = 직전 ∪ 이번 · 원천 · 빌더 실패 = 그대로
// ⑫ 봉투 빈 문장 2 · 차례 열 없는 표 = 소속 0 · 차례 열 = 목록 열 중 bigint 9.

import 'dart:io';

import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

final DateTime _t0 = DateTime.utc(2026, 12, 8, 9);

/// 받은 호출을 적고 차례대로 답한다.
class _Pusher implements ReadModelPusher {
  _Pusher([this.answer]);

  final List<(String table, int epoch, List<Map<String, Object?>> rows)> calls =
      <(String, int, List<Map<String, Object?>>)>[];
  ReadModelPushResult Function(String table, int i)? answer;

  @override
  Future<ReadModelPushResult> push({
    required String deviceId,
    required int epoch,
    required ReadModelTable table,
    required List<Map<String, Object?>> rows,
  }) async {
    calls.add((table.name, epoch, rows));
    return answer?.call(table.name, calls.length - 1) ??
        ReadModelPushResult.answered(
          code: null,
          epoch: epoch,
          accepted: rows.length,
          skipped: 0,
        );
  }
}

/// 워치독 표 원천(행 n 개 · 키 = mode 하나라 행마다 mode 를 바꿀 수 없으니 n ≤ 3 — 나눠 보내기는 알림 표로).
ReadModelRowInput _watchdog(RunMode mode) => ReadModelRowInput(
  mode: mode,
  rowVersion: 0,
  dtos: <String, Map<String, Object?>>{
    'WatchdogBoardVm': <String, Object?>{
      'rows': <Object?>[],
      'as_of': <String, Object?>{'label': 'x'},
      'empty_label': null,
      'holiday_notice': null,
      'limit_notice': null,
      'last_received_text': null,
    },
  },
);

ReadModelRowInput _alert(int i) => ReadModelRowInput(
  mode: RunMode.live,
  rowVersion: 0,
  dtos: <String, Map<String, Object?>>{
    'AlertItem': <String, Object?>{
      'alert_id': 'al_$i',
      'level': 'P2',
      'raised_at': '2026-12-08T09:00:00Z',
      'code': 'X',
      'title': 't',
      'body_text': 'b',
      'action_line': 'a',
      'grouped_count': 1,
    },
  },
);

/// 🆕 미결 242 — 차례가 붙은 알림 행([rank] null = 목록 밖).
ReadModelRowInput _ranked(int i, int? rank, {RunMode mode = RunMode.live}) =>
    ReadModelRowInput(
      mode: mode,
      rowVersion: 0,
      dtos: _alert(i).dtos,
      list: <String, Object?>{'inbox_rank': rank},
    );

ReadModelEnvelopeDraft _env(String code, {RunMode mode = RunMode.live}) =>
    ReadModelEnvelopeDraft(
      mode: mode,
      listCode: code,
      asOf: const <String, Object?>{'label': 'x'},
      emptyKind: EmptyKind.noData,
    );

void main() {
  late Directory dir;
  late Database db;
  late SqliteReadModelPushStatus status;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('aaq_rm_push_');
    db = openLocalLedger(dir.path, RunMode.live, clock: () => _t0);
    status = SqliteReadModelPushStatus(db);
  });
  tearDown(() {
    db.close();
    dir.deleteSync(recursive: true);
  });

  ReadModelPushJob job(
    _Pusher p,
    Map<String, ReadModelSnapshotSource> sources, {
    int chunk = 200,
    RunMode? mode,
  }) => ReadModelPushJob(
    pusher: p,
    status: status,
    sources: sources,
    nowUtc: () => _t0,
    chunkSize: chunk,
    mode: mode,
  );

  Future<ReadModelSnapshot> Function() src(ReadModelSnapshot s) =>
      () async => s;

  test('① 리스 없음(기기 id 없음 · epoch 0) = 호출 0 · 상태 0', () async {
    final _Pusher p = _Pusher();
    final ReadModelPushJob j = job(p, <String, ReadModelSnapshotSource>{
      'rm_watchdog': src(
        ReadModelSnapshot(rows: <ReadModelRowInput>[_watchdog(RunMode.live)]),
      ),
    });
    expect((await j.run(deviceId: null, epoch: 3)).noLease, isTrue);
    expect((await j.run(deviceId: 'd', epoch: 0)).noLease, isTrue);
    expect((await j.run(deviceId: '', epoch: 3)).noLease, isTrue);
    expect(p.calls, isEmpty);
    expect(status.row('rm_watchdog'), isNull);
  });

  test(
    '② 판 = (epoch << 40) + 순번 · 같은 epoch 단조 · 새 epoch 가 옛 판을 넘는다 · 행마다 같은 판',
    () async {
      final _Pusher p = _Pusher();
      final ReadModelPushJob j = job(p, <String, ReadModelSnapshotSource>{
        'rm_watchdog': src(
          ReadModelSnapshot(
            rows: <ReadModelRowInput>[
              _watchdog(RunMode.live),
              _watchdog(RunMode.simBroker),
            ],
          ),
        ),
      });
      await j.run(deviceId: 'd', epoch: 3);
      await j.run(deviceId: 'd', epoch: 3);
      final List<int> v3 = <int>[
        for (final (String, int, List<Map<String, Object?>>) c in p.calls)
          c.$3.first['row_version']! as int,
      ];
      expect(v3, <int>[(3 << 40) + 1, (3 << 40) + 2]);
      expect(
        p.calls.first.$3
            .map((Map<String, Object?> r) => r['row_version'])
            .toSet(),
        hasLength(1),
      );
      await j.run(deviceId: 'd2', epoch: 4);
      expect(p.calls.last.$3.first['row_version'], (4 << 40) + 1);
      expect((4 << 40) + 1, greaterThan(v3.last));
      expect(
        status.nextRowVersion('rm_watchdog', 3),
        (4 << 40) + 2,
        reason: '옛 epoch 로 불러도 판은 내려가지 않는다',
      );
      expect(() => readModelRowVersionFloor(0), throwsArgumentError);
      expect(() => readModelRowVersionFloor(1 << 22), throwsArgumentError);
    },
  );

  test('③ 상태 — OK(snapshot:n · 시각) · LAG(망 · 서버 · 로그인) · FAILED(시크릿 · 행 틀림 · 표 모름 · 응답 꼴)', () async {
    final Map<String, ReadModelSnapshotSource> one =
        <String, ReadModelSnapshotSource>{
          'rm_watchdog': src(
            ReadModelSnapshot(
              rows: <ReadModelRowInput>[_watchdog(RunMode.live)],
            ),
          ),
        };
    await job(_Pusher(), one).run(deviceId: 'd', epoch: 3);
    final ReadModelPushStatusRow ok = status.row('rm_watchdog')!;
    expect(
      (ok.status, ok.lastPushedKey, ok.lastOkAtUtc),
      (ReadModelPushStates.ok, 'snapshot:1', _t0),
    );
    for (final (ReadModelPushResult r, String want) c
        in <(ReadModelPushResult, String)>[
          (
            const ReadModelPushResult.failed(ReadModelPushFailure.network),
            ReadModelPushStates.lag,
          ),
          (
            const ReadModelPushResult.failed(
              ReadModelPushFailure.server,
              statusCode: 503,
            ),
            ReadModelPushStates.lag,
          ),
          (
            const ReadModelPushResult.failed(ReadModelPushFailure.notSignedIn),
            ReadModelPushStates.lag,
          ),
          (
            const ReadModelPushResult.failed(ReadModelPushFailure.config),
            ReadModelPushStates.lag,
          ),
          (
            const ReadModelPushResult.failed(
              ReadModelPushFailure.secretBlocked,
              secretFindings: 1,
            ),
            ReadModelPushStates.failed,
          ),
          (
            const ReadModelPushResult.failed(ReadModelPushFailure.badResponse),
            ReadModelPushStates.failed,
          ),
          (
            const ReadModelPushResult.answered(
              code: ReadModelPushResultCodes.rowsInvalid,
              epoch: 3,
              accepted: 0,
              skipped: 0,
            ),
            ReadModelPushStates.failed,
          ),
          (
            const ReadModelPushResult.answered(
              code: ReadModelPushResultCodes.tableUnknown,
              epoch: 3,
              accepted: 0,
              skipped: 0,
            ),
            ReadModelPushStates.failed,
          ),
        ]) {
      final ReadModelPushReport rep = await job(
        _Pusher((String t, int i) => c.$1),
        one,
      ).run(deviceId: 'd', epoch: 3);
      final ReadModelPushStatusRow row = status.row('rm_watchdog')!;
      expect(row.status, c.$2, reason: '${c.$1}');
      expect(row.lastPushedKey, 'snapshot:1', reason: '실패가 마지막 성공 글자를 지우지 않는다');
      expect(row.lastOkAtUtc, _t0);
      expect(rep.failed.isNotEmpty, c.$2 == ReadModelPushStates.failed);
    }
  });

  test('④ 나눠 보내기 — 450행 · 200씩 = 3번 · 합 · 빈 원천 = 호출 0 · OK', () async {
    final _Pusher p = _Pusher();
    final ReadModelPushReport rep = await job(
      p,
      <String, ReadModelSnapshotSource>{
        'rm_alert': src(
          ReadModelSnapshot(
            rows: <ReadModelRowInput>[for (int i = 0; i < 450; i++) _alert(i)],
          ),
        ),
        'rm_watchdog': src(const ReadModelSnapshot()),
      },
    ).run(deviceId: 'd', epoch: 3);
    expect(p.calls.map((c) => c.$3.length).toList(), <int>[200, 200, 50]);
    final ReadModelTablePush a = rep.tables.firstWhere(
      (ReadModelTablePush t) => t.table == 'rm_alert',
    );
    expect(
      (a.outcome, a.rows, a.accepted),
      (ReadModelPushOutcome.ok, 450, 450),
    );
    expect(status.row('rm_watchdog')!.status, ReadModelPushStates.ok);
    expect(status.row('rm_watchdog')!.lastPushedKey, 'snapshot:0');
    // 둘째 묶음에서 실패 → 그 표 멈춤 · 앞 묶음 수는 보고에 남는다.
    final _Pusher q = _Pusher(
      (String t, int i) => i == 1
          ? const ReadModelPushResult.failed(ReadModelPushFailure.network)
          : const ReadModelPushResult.answered(
              code: null,
              epoch: 3,
              accepted: 200,
              skipped: 0,
            ),
    );
    final ReadModelPushReport r2 = await job(
      q,
      <String, ReadModelSnapshotSource>{
        'rm_alert': src(
          ReadModelSnapshot(
            rows: <ReadModelRowInput>[for (int i = 0; i < 450; i++) _alert(i)],
          ),
        ),
      },
    ).run(deviceId: 'd', epoch: 3);
    expect(q.calls, hasLength(2));
    expect(
      (r2.tables.single.outcome, r2.tables.single.accepted),
      (ReadModelPushOutcome.lag, 200),
    );
  });

  test('⑤ 리스 거부 = 그 자리에서 멈춤 · 뒤 표 notTried · 상태 LAG', () async {
    for (final String code in <String>[
      LeaseRpcResultCodes.lost,
      LeaseRpcResultCodes.deviceNotEligible,
    ]) {
      final _Pusher p = _Pusher(
        (String t, int i) => ReadModelPushResult.answered(
          code: code,
          epoch: 5,
          accepted: 0,
          skipped: 0,
        ),
      );
      final ReadModelPushReport rep = await job(
        p,
        <String, ReadModelSnapshotSource>{
          'rm_alert': src(
            ReadModelSnapshot(
              rows: <ReadModelRowInput>[_alert(1)],
              envelopes: <ReadModelEnvelopeDraft>[
                _env(ReadModelListCodes.journalWatchTimeline),
              ],
            ),
          ),
          'rm_watchdog': src(
            ReadModelSnapshot(
              rows: <ReadModelRowInput>[_watchdog(RunMode.live)],
            ),
          ),
        },
      ).run(deviceId: 'd', epoch: 3);
      expect(p.calls, hasLength(1));
      expect(
        rep.tables.map((ReadModelTablePush t) => (t.table, t.outcome)).toList(),
        <(String, ReadModelPushOutcome)>[
          ('rm_alert', ReadModelPushOutcome.lag),
          ('rm_watchdog', ReadModelPushOutcome.notTried),
          ('rm_list_envelope', ReadModelPushOutcome.notTried),
        ],
      );
      expect(status.row('rm_alert')!.status, ReadModelPushStates.lag);
      expect(rep.failed, isEmpty);
    }
  });

  test('⑥ 행을 못 만듦 = FAILED · 그 표 호출 0 · 원천 오류 = LAG · 다른 표는 간다', () async {
    final _Pusher p = _Pusher();
    final ReadModelPushReport rep = await job(
      p,
      <String, ReadModelSnapshotSource>{
        'rm_advice': src(
          ReadModelSnapshot(
            rows: <ReadModelRowInput>[
              const ReadModelRowInput(
                mode: RunMode.live,
                rowVersion: 0,
                dtos: <String, Map<String, Object?>>{
                  'AdviceItem': <String, Object?>{
                    'advice_id': 'ad1',
                    'trade_date': '2026-12-08',
                  },
                },
              ),
            ],
          ),
        ),
        'rm_safety_state': () async => throw StateError('뷰 아직'),
        'rm_watchdog': src(
          ReadModelSnapshot(rows: <ReadModelRowInput>[_watchdog(RunMode.live)]),
        ),
      },
    ).run(deviceId: 'd', epoch: 3);
    expect(p.calls.map((c) => c.$1).toList(), <String>['rm_watchdog']);
    final Map<String, ReadModelTablePush> by = <String, ReadModelTablePush>{
      for (final ReadModelTablePush t in rep.tables) t.table: t,
    };
    expect(by['rm_advice']!.outcome, ReadModelPushOutcome.failed);
    expect(by['rm_advice']!.reason, startsWith('ROW:'));
    expect(by['rm_safety_state']!.outcome, ReadModelPushOutcome.lag);
    expect(by['rm_safety_state']!.reason, 'SOURCE:StateError');
    expect(status.row('rm_advice')!.status, ReadModelPushStates.failed);
    expect(status.row('rm_safety_state')!.status, ReadModelPushStates.lag);
    expect(rep.failed.map((ReadModelTablePush t) => t.table), <String>[
      'rm_advice',
    ]);
  });

  test('⑦ 봉투 = 마지막 표 하나 · (mode · list_code) 하나씩 · 판 = 봉투 표 판', () async {
    final _Pusher p = _Pusher();
    await job(p, <String, ReadModelSnapshotSource>{
      'rm_alert': src(
        ReadModelSnapshot(
          rows: <ReadModelRowInput>[_alert(1)],
          envelopes: <ReadModelEnvelopeDraft>[
            _env(ReadModelListCodes.journalWatchTimeline),
            _env(ReadModelListCodes.journalWatchTimeline),
            _env(
              ReadModelListCodes.journalWatchTimeline,
              mode: RunMode.simBroker,
            ),
          ],
        ),
      ),
    }).run(deviceId: 'd', epoch: 3);
    expect(p.calls.map((c) => c.$1).toList(), <String>[
      'rm_alert',
      'rm_list_envelope',
    ]);
    final List<Map<String, Object?>> env = p.calls.last.$3;
    expect(env, hasLength(2));
    expect(env.map((Map<String, Object?> r) => r['mode']).toSet(), <Object?>{
      'LIVE',
      'SIM_BROKER',
    });
    expect(env.first['row_version'], (3 << 40) + 1);
    expect(
      env.first.keys,
      containsAll(<String>['list_code', 'as_of', 'empty_kind', 'empty_label']),
    );
  });

  test('⑧ 계약 차례 · 원천 없는 표 0 · 봉투 표 · 모르는 표 원천 = 거부', () async {
    final _Pusher p = _Pusher();
    await job(p, <String, ReadModelSnapshotSource>{
      'rm_watchdog': src(
        ReadModelSnapshot(rows: <ReadModelRowInput>[_watchdog(RunMode.live)]),
      ),
      'rm_alert': src(ReadModelSnapshot(rows: <ReadModelRowInput>[_alert(1)])),
    }).run(deviceId: 'd', epoch: 3);
    expect(p.calls.map((c) => c.$1).toList(), <String>[
      'rm_alert',
      'rm_watchdog',
    ]);
    expect(
      () => job(p, <String, ReadModelSnapshotSource>{
        'rm_list_envelope': src(const ReadModelSnapshot()),
      }),
      throwsArgumentError,
    );
    expect(
      () => job(p, <String, ReadModelSnapshotSource>{
        'app_device': src(const ReadModelSnapshot()),
      }),
      throwsArgumentError,
    );
    expect(
      () => job(p, const <String, ReadModelSnapshotSource>{}, chunk: 0),
      throwsArgumentError,
    );
  });
  // ───── 🆕 미결 242(R275) ─────

  /// 알림 표에 보낸 행(그 호출들을 잇는다).
  List<Map<String, Object?>> sent(_Pusher p, {int from = 0}) =>
      <Map<String, Object?>>[
        for (final (String, int, List<Map<String, Object?>>) c in p.calls.skip(
          from,
        ))
          if (c.$1 == 'rm_alert') ...c.$3,
      ];

  List<Object?> ids(Iterable<Map<String, Object?>> rows) => <Object?>[
    for (final Map<String, Object?> r in rows) r['alert_id'],
  ];

  Map<String, ReadModelSnapshotSource> alerts(
    List<ReadModelRowInput> rows, {
    List<Map<String, Object?>> unread = const <Map<String, Object?>>[],
  }) => <String, ReadModelSnapshotSource>{
    'rm_alert': src(ReadModelSnapshot(rows: rows, unread: unread)),
  };

  test('⑨ 목록에서 빠진 행 = 같은 키 · 큰 판 · 차례 null 로 한 번 다시 보냄 · 본문 = 마지막으로 보낸 꼴 · 상태 줄 무변경', () async {
    final _Pusher p = _Pusher();
    await job(
      p,
      alerts(<ReadModelRowInput>[_ranked(1, 1), _ranked(2, 2), _ranked(3, 3)]),
    ).run(deviceId: 'd', epoch: 3);
    expect(status.members('rm_alert'), hasLength(3));
    // 둘째 깨어남 — al_2 가 7일이 지나 목록 밖(원천에 없음) · al_3 이 2위로.
    final int before = p.calls.length;
    await job(
      p,
      alerts(<ReadModelRowInput>[_ranked(1, 1), _ranked(3, 2)]),
    ).run(deviceId: 'd', epoch: 3);
    final List<Map<String, Object?>> second = sent(p, from: before);
    expect(second, hasLength(3), reason: '이번 둘 + 빠진 하나');
    final Map<String, Object?> gone = second.singleWhere(
      (Map<String, Object?> r) => r['alert_id'] == 'al_2',
    );
    expect(gone.containsKey('inbox_rank'), isTrue);
    expect(gone['inbox_rank'], isNull);
    expect(gone['row_version'], (3 << 40) + 2, reason: '이 판(큰 판)');
    expect(gone['mode'], 'LIVE');
    expect(gone['title'], 't', reason: '본문 = 마지막으로 보낸 꼴(rm_push 는 행 전체를 덮는다)');
    expect(gone.keys.toSet(), sent(p).first.keys.toSet(), reason: '같은 열');
    expect(
      second
          .singleWhere((Map<String, Object?> r) => r['alert_id'] == 'al_3')
          .cast<String, Object?>()['inbox_rank'],
      2,
    );
    expect(ids(status.members('rm_alert')).toSet(), <Object?>{'al_1', 'al_3'});
    expect(status.row('rm_alert')!.lastPushedKey, 'snapshot:3');
    expect(status.row('rm_alert')!.status, ReadModelPushStates.ok);
    // 셋째 — 다시 보내지 않는다(한 번이면 서버 행 = 목록 밖).
    final int before3 = p.calls.length;
    await job(
      p,
      alerts(<ReadModelRowInput>[_ranked(1, 1), _ranked(3, 2)]),
    ).run(deviceId: 'd', epoch: 3);
    expect(ids(sent(p, from: before3)), <Object?>['al_1', 'al_3']);
    // 목록이 통째로 비면 = 둘 다 null 로.
    final int before4 = p.calls.length;
    await job(
      p,
      alerts(const <ReadModelRowInput>[]),
    ).run(deviceId: 'd', epoch: 3);
    final List<Map<String, Object?>> fourth = sent(p, from: before4);
    expect(ids(fourth).toSet(), <Object?>{'al_1', 'al_3'});
    expect(
      fourth.every((Map<String, Object?> r) => r['inbox_rank'] == null),
      isTrue,
    );
    expect(status.members('rm_alert'), isEmpty);
    // 목록 안에 있되 차례 null 로 온 행 = 소속 아님(그 push 가 이미 null 을 보냈다).
    await job(
      p,
      alerts(<ReadModelRowInput>[_ranked(5, 1), _ranked(6, null)]),
    ).run(deviceId: 'd', epoch: 3);
    expect(ids(status.members('rm_alert')), <Object?>['al_5']);
    // 새 epoch(새 기기)도 직전 소속을 이어 빠진 행을 null 로 — 판은 새 epoch 바닥 위.
    final int before5 = p.calls.length;
    await job(
      p,
      alerts(const <ReadModelRowInput>[]),
    ).run(deviceId: 'd2', epoch: 4);
    final Map<String, Object?> carried = sent(p, from: before5).single;
    expect(carried['alert_id'], 'al_5');
    expect(carried['row_version'], greaterThan(4 << 40));
  });

  test(
    '⑩ 판정 밖 — 다른 모드 행 · 이번에 못 읽은 범위 = 다시 보내지 않고 소속에 둔다 · 풀리면 그때 null',
    () async {
      final _Pusher p = _Pusher();
      await job(
        p,
        alerts(<ReadModelRowInput>[
          _ranked(1, 1, mode: RunMode.simInternal),
          _ranked(2, 1),
          _ranked(3, 2),
        ]),
      ).run(deviceId: 'd', epoch: 3);
      // 이번 push 는 LIVE 만 읽었다 — SIM_INTERNAL al_1 은 판정 0 · al_3 은 못 읽은 범위.
      final int b = p.calls.length;
      await job(
        p,
        alerts(
          <ReadModelRowInput>[_ranked(2, 1)],
          unread: <Map<String, Object?>>[
            <String, Object?>{'alert_id': 'al_3'},
          ],
        ),
        mode: RunMode.live,
      ).run(deviceId: 'd', epoch: 3);
      expect(ids(sent(p, from: b)), <Object?>['al_2']);
      expect(ids(status.members('rm_alert')).toSet(), <Object?>{
        'al_1',
        'al_2',
        'al_3',
      }, reason: '판정 밖 = 소속에 그대로');
      // 범위가 풀림 = al_3 null · 다른 모드 al_1 은 계속 둔다.
      final int b2 = p.calls.length;
      await job(
        p,
        alerts(<ReadModelRowInput>[_ranked(2, 1)]),
        mode: RunMode.live,
      ).run(deviceId: 'd', epoch: 3);
      final List<Map<String, Object?>> got = sent(p, from: b2);
      expect(ids(got), <Object?>['al_2', 'al_3']);
      expect(got.last['inbox_rank'], isNull);
      expect(ids(status.members('rm_alert')).toSet(), <Object?>{
        'al_1',
        'al_2',
      });
      // 빈 맵 = 표 전체 못 읽음.
      final int b3 = p.calls.length;
      await job(
        p,
        alerts(
          const <ReadModelRowInput>[],
          unread: <Map<String, Object?>>[<String, Object?>{}],
        ),
      ).run(deviceId: 'd', epoch: 3);
      expect(sent(p, from: b3), isEmpty);
      expect(status.members('rm_alert'), hasLength(2));
    },
  );

  test('⑪ 보냄 실패 = 직전 ∪ 이번(빠진 행은 다음에 다시) · 원천 · 빌더 실패 = 소속 그대로', () async {
    await job(
      _Pusher(),
      alerts(<ReadModelRowInput>[_ranked(1, 1), _ranked(2, 2)]),
    ).run(deviceId: 'd', epoch: 3);
    // 망 실패 — al_2 빠짐 · al_4 새로. 소속 = al_1 · al_2 · al_4.
    final _Pusher down = _Pusher(
      (String t, int i) =>
          const ReadModelPushResult.failed(ReadModelPushFailure.network),
    );
    final ReadModelPushReport lag = await job(
      down,
      alerts(<ReadModelRowInput>[_ranked(1, 1), _ranked(4, 2)]),
    ).run(deviceId: 'd', epoch: 3);
    expect(lag.tables.single.outcome, ReadModelPushOutcome.lag);
    expect(ids(sent(down)), <Object?>['al_1', 'al_4', 'al_2']);
    expect(ids(status.members('rm_alert')).toSet(), <Object?>{
      'al_1',
      'al_2',
      'al_4',
    });
    // 다음 — al_4 도 빠짐 → al_2 · al_4 둘 다 null(앞 묶음이 들어갔을 수 있다).
    final _Pusher up = _Pusher();
    await job(
      up,
      alerts(<ReadModelRowInput>[_ranked(1, 1)]),
    ).run(deviceId: 'd', epoch: 3);
    expect(
      ids(sent(up).where((Map<String, Object?> r) => r['inbox_rank'] == null))
          .toSet(),
      <Object?>{'al_2', 'al_4'},
    );
    expect(ids(status.members('rm_alert')), <Object?>['al_1']);
    // 원천 실패 · 빌더 실패 = 소속 그대로(보낸 것 0).
    await job(_Pusher(), <String, ReadModelSnapshotSource>{
      'rm_alert': () async => throw StateError('x'),
    }).run(deviceId: 'd', epoch: 3);
    await job(
      _Pusher(),
      alerts(<ReadModelRowInput>[_ranked(9, 0)]),
    ).run(deviceId: 'd', epoch: 3);
    expect(ids(status.members('rm_alert')), <Object?>['al_1']);
    // 곁 행이 깨져 있으면 = 빈 소속(던지지 않는다).
    db.execute(
      "UPDATE read_model_push SET last_pushed_key = '{' WHERE table_name = 'rm_alert#members'",
    );
    expect(status.members('rm_alert'), isEmpty);
  });

  test(
    '⑫ 봉투 빈 문장 2(K340) · 차례 열 없는 표 = 소속 곁 행 0 · 차례 열 = 목록 열 중 bigint 9',
    () async {
      final _Pusher p = _Pusher();
      await job(p, <String, ReadModelSnapshotSource>{
        'rm_watchdog': src(
          ReadModelSnapshot(
            rows: <ReadModelRowInput>[_watchdog(RunMode.live)],
            envelopes: <ReadModelEnvelopeDraft>[
              const ReadModelEnvelopeDraft(
                mode: RunMode.live,
                listCode: ReadModelListCodes.journalWatchTimeline,
                asOf: <String, Object?>{'label': 'x'},
                emptyKind: EmptyKind.noData,
                filteredEmptyLabel: '조건에 맞는 기록이 없습니다',
                scopeEmptyLabel: '이 회차에 묶인 기록이 없습니다',
              ),
              _env(ReadModelListCodes.ledgerWatchOpenDiffs),
            ],
          ),
        ),
      }).run(deviceId: 'd', epoch: 3);
      final List<Map<String, Object?>> env = p.calls.last.$3;
      final Map<String, Object?> j = env.firstWhere(
        (Map<String, Object?> r) =>
            r['list_code'] == ReadModelListCodes.journalWatchTimeline,
      );
      expect(j['filtered_empty_label'], '조건에 맞는 기록이 없습니다');
      expect(j['scope_empty_label'], '이 회차에 묶인 기록이 없습니다');
      final Map<String, Object?> d = env.firstWhere(
        (Map<String, Object?> r) =>
            r['list_code'] == ReadModelListCodes.ledgerWatchOpenDiffs,
      );
      expect(d['filtered_empty_label'], isNull);
      expect(d['scope_empty_label'], isNull);
      expect(
        db.select(
          "SELECT table_name FROM read_model_push WHERE table_name LIKE '%#members'",
        ),
        isEmpty,
        reason: '워치독 · 봉투 = 차례 열 0',
      );
      expect(readModelRankColumns(ReadModelTables.advice), <String>[
        'inbox_rank',
        'history_rank',
      ]);
      expect(
        readModelRankColumns(ReadModelTables.configView),
        isEmpty,
        reason: 'range_presets = jsonb',
      );
      expect(readModelRankColumns(ReadModelTables.listEnvelope), isEmpty);
      expect(
        <String>{
          for (final ReadModelTable t in ReadModelTables.all)
            if (readModelRankColumns(t).isNotEmpty) t.name,
        },
        <String>{
          'rm_journal',
          'rm_holding',
          'rm_performance_point',
          'rm_rebalance_event',
          'rm_alert',
          'rm_advice',
          'rm_ledger_diff',
          'rm_blind_review',
        },
      );
      expect(
        <String>[
          for (final ReadModelTable t in ReadModelTables.all)
            ...readModelRankColumns(t),
        ],
        hasLength(9),
        reason: 'K339 차례 열 9',
      );
    },
  );
}
