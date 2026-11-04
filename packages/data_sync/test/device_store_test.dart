// 기기 로컬 암호화 저장소 — 초안 · 큐 ⓐ · watchCommand(설계 13 §8 R46 · 01 §12-1-6 의무 10조 · `watchCommand` 의무 ①~④).
//
// 🔵 잡는 것: ① 닫고 다시 열어도 남는다(재시작 생존) ② 계열 교차 `load` 0 · 계열 전환은 옮기지도 지우지도 않는다
//    ③ 한 사슬 순서(`clear` 뒤 부활 0 · 마지막 `save` 가 이긴다) ④ 🔴 동기 throw 0 · 꼴 검사 = Future 에러(값 0)
//    ⑤ 해독 실패(키 소실 · 계열 태그 · JSON · 키 불일치) = null + 값 없는 보고 ⑥ 연결 id 답변 보장(모르는 id = null)
//    ⑦ 큐 ⓐ «전송 대기» · 만료 없음 · 첫 값 즉시 · 종단 전 완료 0 · 모르는 id = 에러 · 로컬 거부 재생 · executed = 연결 초안 삭제.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core_engine/testing.dart';
import 'package:data_sync/data_sync.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

const String _secretText = '속마음-원문-7f3a';

class _Rig {
  _Rig() : dir = Directory.systemTemp.createTempSync('aaq_device_');

  final Directory dir;
  final FakeSealedBox box = FakeSealedBox();
  final List<DeviceStoreFault> faults = <DeviceStoreFault>[];
  bool sim = false;
  late DeviceLocal local;
  late DeviceDraftStore drafts;
  late LocalCommandQueue queue;

  void open() {
    local = DeviceLocal.open(
      directory: dir.path,
      box: box,
      isSim: () => sim,
      onFault: faults.add,
    );
    drafts = DeviceDraftStore(local);
    queue = LocalCommandQueue(local);
  }

  Future<void> reopen() async {
    await local.close();
    open();
  }

  String path({required bool isSim}) =>
      '${dir.path}${Platform.pathSeparator}${deviceLocalFileName(isSim: isSim)}';
}

DraftKey _jk([String id = 'd-1']) =>
    DraftKey(kind: DraftKind.journalDraft, targetId: id);

DraftRecord _journal({
  String id = 'd-1',
  String text = _secretText,
  String? link,
}) => DraftRecord(
  key: _jk(id),
  journal: JournalDraftInput(rationaleBefore: text, note: '메모'),
  lastCommandId: link,
);

CommandReceipt _receipt(
  String id,
  CommandState state, {
  String label = '엔진 문구',
}) => CommandReceipt(
  commandId: id,
  kind: CommandKind.journalDraft,
  state: state,
  stateLabel: label,
  requestedAt: DateTime.utc(2026, 11, 4, 9),
  expiresAt: DateTime.utc(2026, 11, 5, 9),
  nonce: 'n-$id',
  issuedByDeviceId: 'dev-1',
);

Future<CommandReceipt> _enqueue(
  LocalCommandQueue q,
  String id, {
  DateTime? expiresAt,
}) => q.enqueue(
  commandId: id,
  kind: CommandKind.journalDraft,
  nonce: 'n-$id',
  requestedAt: DateTime.utc(2026, 11, 4, 9),
  expiresAt: expiresAt ?? DateTime.utc(2026, 11, 5, 9),
  issuedByDeviceId: 'dev-1',
  wire: <String, Object?>{
    'decision_id': 'd-1',
    'rationale_before': _secretText,
  },
);

/// 흐름의 값 · 에러 · 끝을 모은다.
class _Watch {
  _Watch(Stream<CommandReceipt> s) {
    sub = s.listen(values.add, onError: errors.add, onDone: done.complete);
  }

  // 흐름이 종단으로 끝나거나 시험이 취소한다.
  // ignore: cancel_subscriptions
  late final StreamSubscription<CommandReceipt> sub;
  final List<CommandReceipt> values = <CommandReceipt>[];
  final List<Object> errors = <Object>[];
  final Completer<void> done = Completer<void>();

  List<CommandState> get states =>
      values.map((CommandReceipt r) => r.state).toList();
}

Future<void> _settle() async {
  for (int i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late _Rig rig;
  setUp(() {
    rig = _Rig()..open();
  });
  tearDown(() async {
    try {
      await rig.local.close();
    } on Object {
      // 이미 닫힘.
    }
    rig.dir.deleteSync(recursive: true);
  });

  group('초안(의무 ① ④ ⑤ ⑨)', () {
    test(
      '네 종류 save → load · 🔴 닫고 다시 열어도 남는다 · 파일 = 계열 둘 · ledger 아님',
      () async {
        final List<DraftRecord> rs = <DraftRecord>[
          _journal(),
          DraftRecord(
            key: const DraftKey(
              kind: DraftKind.manualFillRecord,
              targetId: 'adv-1',
            ),
            manualFill: const ManualFillInput(quantityText: '3', priceText: ''),
          ),
          DraftRecord(
            key: const DraftKey(kind: DraftKind.adviceSkip, targetId: 'adv-2'),
            adviceSkip: const AdviceSkipInput(
              reason: AdviceSkipReason.priceUnacceptable,
              note: '비쌈',
            ),
          ),
          DraftRecord(
            key: const DraftKey(
              kind: DraftKind.selfReportBalance,
              targetId: '2026-08/연금저축',
            ),
            selfReport: const SelfReportInput(
              lines: <SelfReportLineInput>[
                SelfReportLineInput(symbol: '133690', quantityText: '4'),
              ],
              cashKrwText: '120000',
            ),
          ),
        ];
        for (final DraftRecord r in rs) {
          await rig.drafts.save(r);
        }
        await rig.reopen();
        for (final DraftRecord r in rs) {
          expect(await rig.drafts.load(r.key), r);
        }
        for (final bool s in <bool>[true, false]) {
          expect(File(rig.path(isSim: s)).existsSync(), isTrue);
          expect(deviceLocalFileName(isSim: s).startsWith('ledger'), isFalse);
        }
        expect(deviceLocalFileName(isSim: true), 'device_local_sim.sqlite');
        expect(deviceLocalFileName(isSim: false), 'device_local_live.sqlite');
        expect(rig.faults, isEmpty);
      },
    );

    test('같은 키 = 통째 교체 · 없는 키 = null · clear 멱등', () async {
      expect(await rig.drafts.load(_jk()), isNull);
      await rig.drafts.save(_journal(text: '첫'));
      await rig.drafts.save(_journal(text: '둘'));
      expect((await rig.drafts.load(_jk()))!.journal!.rationaleBefore, '둘');
      await rig.drafts.clear(_jk());
      await rig.drafts.clear(_jk());
      expect(await rig.drafts.load(_jk()), isNull);
    });

    test(
      '🔴 순서 — 기다리지 않고 save · clear · save … = 부른 순서 · clear 뒤 앞 save 부활 0',
      () async {
        final List<Future<void>> fs = <Future<void>>[
          for (int i = 0; i < 10; i++) rig.drafts.save(_journal(text: 'v$i')),
          rig.drafts.clear(_jk()),
        ];
        final Future<DraftRecord?> afterClear = rig.drafts.load(_jk());
        fs.add(rig.drafts.save(_journal(text: '마지막', id: 'd-2')));
        await Future.wait(fs);
        expect(await afterClear, isNull);
        expect(await rig.drafts.load(_jk()), isNull);
        expect(
          (await rig.drafts.load(_jk('d-2')))!.journal!.rationaleBefore,
          '마지막',
        );
        await rig.reopen();
        expect(await rig.drafts.load(_jk()), isNull);
      },
    );

    test(
      '🔴 동기 throw 0 · 꼴 검사 = ArgumentError Future 에러 · 메시지에 본문 값 0',
      () async {
        final List<DraftRecord> bad = <DraftRecord>[
          const DraftRecord(
            key: DraftKey(kind: DraftKind.journalDraft, targetId: 'd'),
          ),
          DraftRecord(
            key: _jk(),
            journal: const JournalDraftInput(rationaleBefore: _secretText),
            adviceSkip: const AdviceSkipInput(note: _secretText),
          ),
          DraftRecord(
            key: _jk(),
            adviceSkip: const AdviceSkipInput(note: _secretText),
          ),
          _journal(id: ''),
        ];
        for (final DraftRecord r in bad) {
          late Future<void> f;
          expect(() => f = rig.drafts.save(r), returnsNormally);
          await expectLater(
            f,
            throwsA(
              isA<ArgumentError>().having(
                (ArgumentError e) => '$e'.contains(_secretText),
                '값 0',
                isFalse,
              ),
            ),
          );
        }
        late Future<DraftRecord?> l;
        late Future<void> c;
        expect(() => l = rig.drafts.load(_jk('')), returnsNormally);
        expect(() => c = rig.drafts.clear(_jk('')), returnsNormally);
        await expectLater(l, throwsArgumentError);
        await expectLater(c, throwsArgumentError);
        // 실패가 사슬을 막지 않는다.
        await rig.drafts.save(_journal());
        expect(await rig.drafts.load(_jk()), isNotNull);
      },
    );

    test(
      '🔴 닫힌 뒤 = DeviceStoreError(closed) Future 에러 · 동기 throw 0 · 경로 · 값 0',
      () async {
        await rig.local.close();
        late Future<void> f;
        expect(() => f = rig.drafts.save(_journal()), returnsNormally);
        await expectLater(
          f,
          throwsA(
            isA<DeviceStoreError>()
                .having(
                  (DeviceStoreError e) => e.kind,
                  'kind',
                  DeviceStoreErrorKind.closed,
                )
                .having(
                  (DeviceStoreError e) => '$e'.contains(rig.dir.path),
                  '경로 0',
                  isFalse,
                ),
          ),
        );
        await expectLater(
          rig.drafts.load(_jk()),
          throwsA(isA<DeviceStoreError>()),
        );
        rig.open();
      },
    );

    test('날짜 만료 없음 — 오래된 초안도 그대로(시계를 묻지 않는다)', () async {
      await rig.drafts.save(_journal());
      await rig.reopen();
      await rig.reopen();
      expect(await rig.drafts.load(_jk()), isNotNull);
    });
  });

  group('계열(의무 ④ · R46 G3)', () {
    test('🔴 LIVE 초안은 SIM 에서 안 보인다 · 같은 키 따로 · 돌아오면 다시 보인다', () async {
      await rig.drafts.save(_journal(text: '실전'));
      rig.sim = true;
      expect(await rig.drafts.load(_jk()), isNull);
      await rig.drafts.save(_journal(text: '모의'));
      expect((await rig.drafts.load(_jk()))!.journal!.rationaleBefore, '모의');
      rig.sim = false;
      expect((await rig.drafts.load(_jk()))!.journal!.rationaleBefore, '실전');
      expect(rig.faults, isEmpty);
    });

    test('discardSimDrafts = SIM 초안만 · LIVE 그대로', () async {
      await rig.drafts.save(_journal(text: '실전'));
      rig.sim = true;
      await rig.drafts.save(_journal(text: '모의'));
      await rig.drafts.discardSimDrafts();
      expect(await rig.drafts.load(_jk()), isNull);
      rig.sim = false;
      expect((await rig.drafts.load(_jk()))!.journal!.rationaleBefore, '실전');
      // LIVE 계열에 있을 때 불러도 SIM 만 지운다.
      rig.sim = true;
      await rig.drafts.save(_journal(text: '모의 2'));
      rig.sim = false;
      await rig.drafts.discardSimDrafts();
      expect((await rig.drafts.load(_jk()))!.journal!.rationaleBefore, '실전');
      rig.sim = true;
      expect(await rig.drafts.load(_jk()), isNull);
    });

    test('같은 계열 · 같은 이름공간이라도 다른 키의 봉함은 열리지 않는다(aad 에 키)', () async {
      await rig.drafts.save(_journal(id: 'd-1'));
      final SealedRow a = rig.local.current.get(
        DeviceNamespace.draft,
        draftItemKey(_jk('d-1')),
      )!;
      rig.local.current.put(
        DeviceNamespace.draft,
        draftItemKey(_jk('d-2')),
        a.body,
      );
      expect(await rig.drafts.load(_jk('d-2')), isNull);
      expect(rig.faults.single.kind, DeviceStoreFaultKind.sealOpenFailed);
      await _enqueue(rig.queue, 'c1');
      final SealedRow q = rig.local.current.get(DeviceNamespace.queue, 'c1')!;
      rig.local.current.put(DeviceNamespace.queue, 'c2', q.body);
      expect(await rig.queue.receiptOf('c2'), isNull);
    });

    test('행 계열 태그가 파일과 다르면 null + familyMismatch 보고', () async {
      await rig.drafts.save(_journal());
      await rig.local.close();
      final Database db = sqlite3.open(rig.path(isSim: false));
      db.execute("UPDATE sealed_item SET family = 'sim'");
      db.close();
      rig.open();
      expect(await rig.drafts.load(_jk()), isNull);
      expect(rig.faults, <DeviceStoreFault>[
        const DeviceStoreFault(
          DeviceStoreFaultKind.familyMismatch,
          DeviceNamespace.draft,
        ),
      ]);
    });

    test('다른 계열 파일의 봉함을 옮겨 붙여도 열리지 않는다(aad 에 계열)', () async {
      await rig.drafts.save(_journal());
      final SealedRow live = rig.local.current.get(
        DeviceNamespace.draft,
        draftItemKey(_jk()),
      )!;
      rig.sim = true;
      rig.local.simFile.put(
        DeviceNamespace.draft,
        draftItemKey(_jk()),
        live.body,
      );
      expect(await rig.drafts.load(_jk()), isNull);
      expect(rig.faults.single.kind, DeviceStoreFaultKind.sealOpenFailed);
    });
  });

  group('해독 실패(의무 ⑥)', () {
    test(
      '키 소실 = null + sealOpenFailed · 다음 save 가 덮으면 다시 읽힌다 · 깨진 행은 지우지 않는다',
      () async {
        await rig.drafts.save(_journal());
        rig.box.loseKey();
        expect(await rig.drafts.load(_jk()), isNull);
        expect(
          rig.faults.single,
          const DeviceStoreFault(
            DeviceStoreFaultKind.sealOpenFailed,
            DeviceNamespace.draft,
          ),
        );
        expect(
          rig.local.current.get(DeviceNamespace.draft, draftItemKey(_jk())),
          isNotNull,
        );
        await rig.drafts.save(_journal(text: '새로'));
        expect((await rig.drafts.load(_jk()))!.journal!.rationaleBefore, '새로');
      },
    );

    test('JSON 아님 · 모양 다름 · 키 불일치 = null + 보고 · 🔴 보고 문자열에 값 · 키 0', () async {
      final String k = draftItemKey(_jk());
      Future<void> raw(Object json) async {
        final Uint8List b = await rig.local.seal(
          rig.local.current,
          DeviceNamespace.draft,
          k,
          json,
        );
        rig.local.current.put(DeviceNamespace.draft, k, b);
      }

      final Uint8List notJson = await rig.box.seal(
        Uint8List.fromList(utf8.encode('{깨짐 $_secretText')),
        aad: deviceLocalAad('live', DeviceNamespace.draft, k),
      );
      rig.local.current.put(DeviceNamespace.draft, k, notJson);
      expect(await rig.drafts.load(_jk()), isNull);
      await raw(<String, Object?>{'key': 3, 'journal': _secretText});
      expect(await rig.drafts.load(_jk()), isNull);
      await raw(_journal(id: 'other').toJson());
      expect(await rig.drafts.load(_jk()), isNull);
      // JSON 이지만 지도가 아니다(목록) — 던지지 않고 null.
      final Uint8List list = await rig.box.seal(
        Uint8List.fromList(utf8.encode('[1, 2]')),
        aad: deviceLocalAad('live', DeviceNamespace.draft, k),
      );
      rig.local.current.put(DeviceNamespace.draft, k, list);
      expect(await rig.drafts.load(_jk()), isNull);
      expect(
        rig.faults.map((DeviceStoreFault f) => f.kind),
        <DeviceStoreFaultKind>[
          DeviceStoreFaultKind.decodeFailed,
          DeviceStoreFaultKind.decodeFailed,
          DeviceStoreFaultKind.keyMismatch,
          DeviceStoreFaultKind.decodeFailed,
        ],
      );
      for (final DeviceStoreFault f in rig.faults) {
        expect('$f'.contains(_secretText), isFalse);
        expect('$f'.contains('d-1'), isFalse);
      }
    });

    test('보고기가 던져도 load 는 null 로 끝난다', () async {
      await rig.local.close();
      rig.local = DeviceLocal.open(
        directory: rig.dir.path,
        box: rig.box,
        isSim: () => false,
        onFault: (DeviceStoreFault f) => throw StateError('보고 실패'),
      );
      rig.drafts = DeviceDraftStore(rig.local);
      await rig.drafts.save(_journal());
      rig.box.loseKey();
      expect(await rig.drafts.load(_jk()), isNull);
    });
  });

  group('연결 id 답변(의무 ⑦ · R46 G7)', () {
    test('큐 · 종단 기록에 없는 lastCommandId = null 로 · 있으면 그대로 · 행은 그대로', () async {
      await rig.drafts.save(_journal(link: 'cmd-x'));
      expect((await rig.drafts.load(_jk()))!.lastCommandId, isNull);
      await _enqueue(rig.queue, 'cmd-x');
      expect((await rig.drafts.load(_jk()))!.lastCommandId, 'cmd-x');
      await rig.queue.applyReceipt(_receipt('cmd-x', CommandState.rejected));
      expect((await rig.drafts.load(_jk()))!.lastCommandId, 'cmd-x');
    });

    test('로컬 거부 접수증의 id 도 답한다', () async {
      await rig.queue.recordLocalRejection(
        _receipt('cmd-r', CommandState.rejected),
      );
      await rig.drafts.save(_journal(link: 'cmd-r'));
      expect((await rig.drafts.load(_jk()))!.lastCommandId, 'cmd-r');
    });
  });

  group('큐 ⓐ · watchCommand(G8 · G9 · 의무 ①~④ ⑧)', () {
    test(
      'enqueue = requested «전송 대기» · ① 첫 값 곧바로 · 바뀔 때마다 · ② 종단 뒤에만 완료',
      () async {
        final CommandReceipt r = await _enqueue(rig.queue, 'c1');
        expect(
          (r.state, r.stateLabel, r.commandId, r.nonce),
          (CommandState.requested, '전송 대기', 'c1', 'n-c1'),
        );
        final _Watch w = _Watch(rig.queue.watchCommand('c1'));
        await _settle();
        expect(w.states, <CommandState>[CommandState.requested]);
        expect(w.done.isCompleted, isFalse);
        await rig.queue.applyReceipt(_receipt('c1', CommandState.received));
        await rig.queue.applyReceipt(
          _receipt('c1', CommandState.heldForIntegrity),
        );
        await _settle();
        expect(w.done.isCompleted, isFalse);
        await rig.queue.applyReceipt(
          _receipt('c1', CommandState.executed, label: '완료'),
        );
        await w.done.future;
        expect(w.states, <CommandState>[
          CommandState.requested,
          CommandState.received,
          CommandState.heldForIntegrity,
          CommandState.executed,
        ]);
        expect(w.values.last.stateLabel, '완료');
        expect(w.errors, isEmpty);
      },
    );

    test('구독 직후 같은 사슬에 올라온 반영도 첫 값 뒤에 온다', () async {
      await _enqueue(rig.queue, 'c1');
      final _Watch w = _Watch(rig.queue.watchCommand('c1'));
      final Future<void> a = rig.queue.applyReceipt(
        _receipt('c1', CommandState.executed),
      );
      await a;
      await w.done.future;
      expect(w.states, <CommandState>[
        CommandState.requested,
        CommandState.executed,
      ]);
    });

    test(
      '🔴 재시작 생존 · 만료 없음(지난 expiresAt 도 requested) · unsent = 적재 순 · markSent',
      () async {
        await _enqueue(rig.queue, 'c1', expiresAt: DateTime.utc(2020));
        await _enqueue(rig.queue, 'c2');
        await rig.reopen();
        expect(
          (await rig.queue.receiptOf('c1'))!.state,
          CommandState.requested,
        );
        final List<QueuedCommand> u = await rig.queue.unsent();
        expect(u.map((QueuedCommand q) => q.receipt.commandId), <String>[
          'c1',
          'c2',
        ]);
        expect(u.first.wire['rationale_before'], _secretText);
        expect('${u.first}'.contains(_secretText), isFalse);
        await rig.queue.markSent('c1');
        expect(
          (await rig.queue.unsent()).map(
            (QueuedCommand q) => q.receipt.commandId,
          ),
          <String>['c2'],
        );
        expect(
          (await rig.queue.receiptOf('c1'))!.state,
          CommandState.requested,
        );
        final _Watch w = _Watch(rig.queue.watchCommand('c1'));
        await _settle();
        expect(w.states, <CommandState>[CommandState.requested]);
        await w.sub.cancel();
      },
    );

    test(
      '③ 모르는 id = 스트림 에러 뒤 끝 · applyReceipt · markSent = Future 에러 · 🔴 값 0',
      () async {
        final _Watch w = _Watch(rig.queue.watchCommand('nope'));
        await w.done.future;
        expect(w.values, isEmpty);
        expect(w.errors.single, isA<UnknownCommandError>());
        expect('${w.errors.single}'.contains('nope'), isFalse);
        await expectLater(
          rig.queue.applyReceipt(_receipt('nope', CommandState.executed)),
          throwsA(isA<UnknownCommandError>()),
        );
        await expectLater(
          rig.queue.markSent('nope'),
          throwsA(isA<UnknownCommandError>()),
        );
      },
    );

    test('④ 로컬 거부 = 종단 rejected 1값 곧바로 · rejected 아니면 ArgumentError · 같은 id = StateError', () async {
      await rig.queue.recordLocalRejection(
        _receipt('lr', CommandState.rejected, label: '입력 오류'),
      );
      await rig.reopen();
      final _Watch w = _Watch(rig.queue.watchCommand('lr'));
      await w.done.future;
      expect(w.states, <CommandState>[CommandState.rejected]);
      await expectLater(
        rig.queue.recordLocalRejection(_receipt('x', CommandState.executed)),
        throwsArgumentError,
      );
      await expectLater(
        rig.queue.recordLocalRejection(_receipt('lr', CommandState.rejected)),
        throwsStateError,
      );
      await expectLater(_enqueue(rig.queue, 'lr'), throwsStateError);
      await _enqueue(rig.queue, 'q1');
      await expectLater(_enqueue(rig.queue, 'q1'), throwsStateError);
    });

    test(
      '🔴 ⑧ executed = 연결 초안 자동 삭제(화면 없이) · 다른 연결 · rejected · expired 는 그대로',
      () async {
        await _enqueue(rig.queue, 'c1');
        await _enqueue(rig.queue, 'c2');
        await _enqueue(rig.queue, 'c3');
        await rig.drafts.save(_journal(id: 'd-1', link: 'c1'));
        await rig.drafts.save(_journal(id: 'd-2', link: 'c2'));
        await rig.drafts.save(_journal(id: 'd-3', link: 'c3'));
        await rig.drafts.save(_journal(id: 'd-4'));
        await rig.queue.applyReceipt(_receipt('c1', CommandState.executed));
        await rig.queue.applyReceipt(_receipt('c2', CommandState.rejected));
        await rig.queue.applyReceipt(_receipt('c3', CommandState.expired));
        expect(await rig.drafts.load(_jk('d-1')), isNull);
        expect((await rig.drafts.load(_jk('d-2')))!.lastCommandId, 'c2');
        expect((await rig.drafts.load(_jk('d-3')))!.lastCommandId, 'c3');
        expect(await rig.drafts.load(_jk('d-4')), isNotNull);
        // 화면 clear 와 멱등.
        await rig.drafts.clear(_jk('d-1'));
        // 셋 다 종단 — 큐에서 빠지고 새 구독은 1값 뒤 끝.
        expect(await rig.queue.unsent(), isEmpty);
        for (final (String id, CommandState s) in <(String, CommandState)>[
          ('c1', CommandState.executed),
          ('c2', CommandState.rejected),
          ('c3', CommandState.expired),
        ]) {
          final _Watch w = _Watch(rig.queue.watchCommand(id));
          await w.done.future;
          expect(w.states, <CommandState>[s]);
        }
      },
    );

    test('종단은 바뀌지 않는다 — 뒤늦은 접수증 무시 · 새 구독 = 종단 1값 뒤 끝 · 큐에서 빠진다', () async {
      await _enqueue(rig.queue, 'c1');
      await rig.queue.applyReceipt(_receipt('c1', CommandState.executed));
      await rig.queue.applyReceipt(_receipt('c1', CommandState.rejected));
      expect((await rig.queue.receiptOf('c1'))!.state, CommandState.executed);
      expect(await rig.queue.unsent(), isEmpty);
      final _Watch w = _Watch(rig.queue.watchCommand('c1'));
      await w.done.future;
      expect(w.states, <CommandState>[CommandState.executed]);
    });

    test('계열 = 현재만 — LIVE 명령은 SIM 에서 모르는 id', () async {
      await _enqueue(rig.queue, 'c1');
      rig.sim = true;
      final _Watch w = _Watch(rig.queue.watchCommand('c1'));
      await w.done.future;
      expect(w.errors.single, isA<UnknownCommandError>());
      expect(await rig.queue.unsent(), isEmpty);
    });

    test('키 소실 = 큐 행은 보고하고 뺀다 · 구독 = 에러(잠금 탈출은 화면 «다시 시도»)', () async {
      await _enqueue(rig.queue, 'c1');
      rig.box.loseKey();
      expect(await rig.queue.unsent(), isEmpty);
      expect(
        rig.faults.first,
        const DeviceStoreFault(
          DeviceStoreFaultKind.sealOpenFailed,
          DeviceNamespace.queue,
        ),
      );
      final _Watch w = _Watch(rig.queue.watchCommand('c1'));
      await w.done.future;
      expect(w.errors, hasLength(1));
    });

    test('구독 취소 뒤 반영은 그 흐름에 가지 않는다 · 구독 자리도 비운다', () async {
      await _enqueue(rig.queue, 'c1');
      final _Watch w = _Watch(rig.queue.watchCommand('c1'));
      final _Watch w2 = _Watch(rig.queue.watchCommand('c1'));
      await _settle();
      expect(rig.queue.activeWatchCount, 2);
      await w.sub.cancel();
      expect(rig.queue.activeWatchCount, 1);
      await rig.queue.applyReceipt(_receipt('c1', CommandState.received));
      await _settle();
      expect(w.states, <CommandState>[CommandState.requested]);
      expect(w2.states, <CommandState>[
        CommandState.requested,
        CommandState.received,
      ]);
      await w2.sub.cancel();
      expect(rig.queue.activeWatchCount, 0);
    });

    test('비종단 접수증도 저장된다 — 다시 열어도 · 새 구독 첫 값 = 마지막 접수증', () async {
      await _enqueue(rig.queue, 'c1');
      await rig.queue.applyReceipt(
        _receipt('c1', CommandState.received, label: '엔진 수신'),
      );
      await rig.reopen();
      expect((await rig.queue.receiptOf('c1'))!.stateLabel, '엔진 수신');
      final _Watch w = _Watch(rig.queue.watchCommand('c1'));
      await _settle();
      expect(w.states, <CommandState>[CommandState.received]);
      expect(
        (await rig.queue.unsent()).single.wire['rationale_before'],
        _secretText,
      );
      await w.sub.cancel();
    });
  });
}
