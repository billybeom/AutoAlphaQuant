// 명령 내구 큐 ⓐ · 접수증 흐름(설계 13 §8 R46 G8 · G9 · 01 §10-8 · §4-2 · `CommandApi.watchCommand` 의무 ①~④).
//
// 🔴 명령은 사실을 잃지 않는다 — 먼저 기기 로컬 큐 ⓐ 에 쌓이고(봉함 · 재시작 생존) 네트워크가 되면 ⓑ `command_queue` 로 간다(E11m).
//    🔴 로컬 큐의 항목은 **만료되지 않는다** — 만료는 서버 `expires_at` 에서만(그 접수증을 [applyReceipt] 가 받는다).
// 🔴 `watchCommand` — ① 큐에만 있어도 첫 값(«전송 대기»)을 곧바로 ② 종단(executed · rejected · expired) 전에는 완료하지 않는다
//    ③ 모르는 id = 스트림 에러 ④ 큐 적재 없는 로컬 거부 접수증의 id 도 종단 `rejected` 1값을 곧바로 다시 낸다.
// 🔴 executed 를 관찰하면 그 명령에 연결된 초안을 지운다(의무 ⑧ · 화면이 닫혀 있어도 · 화면 `clear` 와 멱등).

import 'dart:async';

import 'package:domain_contracts/domain_contracts.dart';

import 'device_local.dart';

/// «전송 대기» — 큐 ⓐ 에만 있는 명령의 라벨(01 §10-8 · `A-3`).
const String kQueuedStateLabel = '전송 대기';

/// 종단 상태(의무 ②).
const Set<CommandState> kTerminalCommandStates = <CommandState>{
  CommandState.executed,
  CommandState.rejected,
  CommandState.expired,
};

/// 모르는 명령 id — 🔴 id · 값 없음.
class UnknownCommandError implements Exception {
  /// 실패를 만든다.
  const UnknownCommandError();

  @override
  String toString() => 'UnknownCommandError(모르는 명령)';
}

/// 보낼 차례의 명령 하나(ⓑ 전송용).
class QueuedCommand {
  /// 명령을 만든다.
  const QueuedCommand(this.receipt, this.wire);

  /// 지금 접수증.
  final CommandReceipt receipt;

  /// 와이어 본문(봉함 안에 있던 것 · 🔴 기록 금지).
  final Map<String, Object?> wire;

  @override
  String toString() =>
      'QueuedCommand(${receipt.kind.wire} · ${receipt.state.wire})';
}

/// 큐 ⓐ — [DeviceLocal] 의 한 사슬 위에서 돈다(초안과 같은 저장소 · 다른 이름공간).
class LocalCommandQueue {
  /// 큐를 만든다.
  LocalCommandQueue(this._local);

  final DeviceLocal _local;
  final Map<String, Set<StreamController<CommandReceipt>>> _watchers =
      <String, Set<StreamController<CommandReceipt>>>{};

  Future<Map<String, Object?>?> _entry(
    DeviceFamilyFile f,
    String ns,
    String id,
  ) async {
    final SealedRow? row = f.get(ns, id);
    if (row == null) return null;
    return _local.unseal(f, ns, row);
  }

  CommandReceipt? _receiptOf(Map<String, Object?>? e, String ns) {
    if (e == null) return null;
    final Object? r = e['receipt'];
    try {
      if (r is Map<String, Object?>) return CommandReceipt.fromJson(r);
    } on Object {
      // 아래에서 보고.
    }
    _local.report(DeviceStoreFault(DeviceStoreFaultKind.decodeFailed, ns));
    return null;
  }

  Future<CommandReceipt?> _current(DeviceFamilyFile f, String id) async {
    final CommandReceipt? t = _receiptOf(
      await _entry(f, DeviceNamespace.terminal, id),
      DeviceNamespace.terminal,
    );
    if (t != null) return t;
    return _receiptOf(
      await _entry(f, DeviceNamespace.queue, id),
      DeviceNamespace.queue,
    );
  }

  bool _known(DeviceFamilyFile f, String id) =>
      f.get(DeviceNamespace.queue, id) != null ||
      f.get(DeviceNamespace.terminal, id) != null;

  void _emit(CommandReceipt r) {
    final Set<StreamController<CommandReceipt>>? ws = _watchers[r.commandId];
    if (ws == null) return;
    final bool done = kTerminalCommandStates.contains(r.state);
    for (final StreamController<CommandReceipt> c in ws.toList()) {
      c.add(r);
      if (done) unawaited(c.close());
    }
    if (done) _watchers.remove(r.commandId);
  }

  /// 큐 ⓐ 에 쌓는다 → `requested` · «전송 대기» 접수증(R46 G8). 🔴 같은 id 가 이미 있으면 거부(StateError).
  Future<CommandReceipt> enqueue({
    required String commandId,
    required CommandKind kind,
    required String nonce,
    required DateTime requestedAt,
    required DateTime expiresAt,
    required String issuedByDeviceId,
    required Map<String, Object?> wire,
  }) => _local.run(() async {
    if (commandId.isEmpty) throw ArgumentError('commandId 가 비었다');
    final DeviceFamilyFile f = _local.current;
    if (_known(f, commandId)) throw StateError('이미 있는 명령 id 다');
    final CommandReceipt r = CommandReceipt(
      commandId: commandId,
      kind: kind,
      state: CommandState.requested,
      stateLabel: kQueuedStateLabel,
      requestedAt: requestedAt.toUtc(),
      expiresAt: expiresAt.toUtc(),
      nonce: nonce,
      issuedByDeviceId: issuedByDeviceId,
    );
    final body = await _local.seal(
      f,
      DeviceNamespace.queue,
      commandId,
      <String, Object?>{'receipt': r.toJson(), 'wire': wire, 'sent': false},
    );
    f.put(DeviceNamespace.queue, commandId, body);
    _emit(r);
    return r;
  });

  /// 큐 적재 없는 로컬 거부 접수증을 남긴다(의무 ④) — `rejected` 만 · 같은 id 가 있으면 거부.
  Future<void> recordLocalRejection(CommandReceipt receipt) =>
      _local.run(() async {
        if (receipt.state != CommandState.rejected) {
          throw ArgumentError('로컬 거부 접수증은 rejected 여야 한다');
        }
        final DeviceFamilyFile f = _local.current;
        if (_known(f, receipt.commandId)) throw StateError('이미 있는 명령 id 다');
        final body = await _local.seal(
          f,
          DeviceNamespace.terminal,
          receipt.commandId,
          <String, Object?>{'receipt': receipt.toJson()},
        );
        f.put(DeviceNamespace.terminal, receipt.commandId, body);
        _emit(receipt);
      });

  /// 전송 ⓑ · 소비 쪽 접수증을 반영한다(E11m 이 부른다) — 종단이면 큐에서 빼 종단 기록으로 ·
  /// 🔴 executed 면 연결 초안을 지운다(의무 ⑧). 이미 종단인 명령의 뒤늦은 접수증은 무시(종단은 바뀌지 않는다).
  /// 모르는 id = [UnknownCommandError].
  Future<void> applyReceipt(CommandReceipt receipt) => _local.run(() async {
    final DeviceFamilyFile f = _local.current;
    final String id = receipt.commandId;
    if (f.get(DeviceNamespace.terminal, id) != null) return;
    final Map<String, Object?>? e = await _entry(f, DeviceNamespace.queue, id);
    if (e == null) {
      if (f.get(DeviceNamespace.queue, id) == null) {
        throw const UnknownCommandError();
      }
      throw const DeviceStoreError(DeviceStoreErrorKind.readFailed);
    }
    if (kTerminalCommandStates.contains(receipt.state)) {
      final body = await _local.seal(
        f,
        DeviceNamespace.terminal,
        id,
        <String, Object?>{'receipt': receipt.toJson()},
      );
      f.move(DeviceNamespace.queue, DeviceNamespace.terminal, id, body);
      if (receipt.state == CommandState.executed) {
        for (final String k in f.keysLinkedTo(DeviceNamespace.draft, id)) {
          f.delete(DeviceNamespace.draft, k);
        }
      }
    } else {
      final body = await _local.seal(
        f,
        DeviceNamespace.queue,
        id,
        <String, Object?>{...e, 'receipt': receipt.toJson()},
      );
      f.put(DeviceNamespace.queue, id, body);
    }
    _emit(receipt);
  });

  /// ⓑ 로 보냈다고 표시한다(접수증은 그대로 · 다시 보내지 않게).
  Future<void> markSent(String commandId) => _local.run(() async {
    final DeviceFamilyFile f = _local.current;
    final Map<String, Object?>? e = await _entry(
      f,
      DeviceNamespace.queue,
      commandId,
    );
    if (e == null) throw const UnknownCommandError();
    final body = await _local.seal(
      f,
      DeviceNamespace.queue,
      commandId,
      <String, Object?>{...e, 'sent': true},
    );
    f.put(DeviceNamespace.queue, commandId, body);
  });

  /// 보낼 차례(아직 안 보낸 것 · 적재 순 · 깨진 행은 보고하고 뺀다).
  Future<List<QueuedCommand>> unsent() => _local.run(() async {
    final DeviceFamilyFile f = _local.current;
    final List<QueuedCommand> out = <QueuedCommand>[];
    for (final SealedRow row in f.all(DeviceNamespace.queue)) {
      final Map<String, Object?>? e = await _local.unseal(
        f,
        DeviceNamespace.queue,
        row,
      );
      final CommandReceipt? r = _receiptOf(e, DeviceNamespace.queue);
      final Object? wire = e?['wire'];
      if (r == null || wire is! Map<String, Object?>) continue;
      if (e!['sent'] == true) continue;
      out.add(QueuedCommand(r, wire));
    }
    return out;
  });

  /// 지금 접수증(없으면 null).
  Future<CommandReceipt?> receiptOf(String commandId) =>
      _local.run(() => _current(_local.current, commandId));

  /// 접수증 흐름(G9 · 의무 ①~④) — 구독마다 새 흐름.
  Stream<CommandReceipt> watchCommand(String commandId) {
    late final StreamController<CommandReceipt> c;
    c = StreamController<CommandReceipt>(
      onListen: () {
        // 첫 값 · 구독 등록을 사슬 **안**에서 한다 — 뒤에 올라온 접수증 반영이 첫 값보다 먼저 닿지 않게.
        unawaited(
          _local
              .run(() async {
                final CommandReceipt? r = await _current(
                  _local.current,
                  commandId,
                );
                if (c.isClosed) return;
                if (r == null) {
                  c.addError(const UnknownCommandError());
                  unawaited(c.close());
                  return;
                }
                c.add(r);
                if (kTerminalCommandStates.contains(r.state)) {
                  unawaited(c.close());
                  return;
                }
                _watchers
                    .putIfAbsent(
                      commandId,
                      () => <StreamController<CommandReceipt>>{},
                    )
                    .add(c);
              })
              .catchError((Object e) {
                if (c.isClosed) return;
                c.addError(e);
                unawaited(c.close());
              }),
        );
      },
      onCancel: () {
        final Set<StreamController<CommandReceipt>>? ws = _watchers[commandId];
        ws?.remove(c);
        if (ws != null && ws.isEmpty) _watchers.remove(commandId);
      },
    );
    return c.stream;
  }

  /// 살아 있는 구독 수(진단 · 시험용 — 취소 · 종단이면 줄어든다).
  int get activeWatchCount => _watchers.values.fold<int>(
    0,
    (int n, Set<StreamController<CommandReceipt>> s) => n + s.length,
  );

  @override
  String toString() => 'LocalCommandQueue';
}
