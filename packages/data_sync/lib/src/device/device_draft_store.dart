// 입력 초안 저장소 — `DraftStore` 구현(설계 13 §8 R46 G3~G7 · 01 §12-1-6 의무 10조).
//
// 🔴 사람이 적던 입력의 원문을 이 기기 안에만 둔다 — 원장 사실도, 명령도 아니다(§12-1-1).
// 🔴 `load` = 현재 계열만 · 다른 계열 · 봉함 열기 실패 · 해독 실패 = null(의무 ④ ⑥).
// 🔴 `load` 가 돌려주는 `lastCommandId` 는 `watchCommand` 가 답할 수 있는 id 다 — 큐 ⓐ · 종단 기록에 없으면 null 로 바꿔
//    준다(의무 ⑦ · 화면이 영구 잠금에 갇히지 않게 · 행은 그대로).
// 🔴 날짜 만료 없음(의무 ⑨) · 계열 전환은 옮기지도 지우지도 않는다 · LIVE 초안을 지우는 메서드는 없다.

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';

import 'device_local.dart';

/// 초안 키 → 저장 키(종류 표기 · 대상 id).
String draftItemKey(DraftKey k) =>
    jsonEncode(<String>[k.kind.wire, k.targetId]);

/// [r] 의 본문 칸 중 non-null 인 것의 종류(꼴 검사용).
List<DraftKind> _filled(DraftRecord r) => <DraftKind>[
  if (r.journal != null) DraftKind.journalDraft,
  if (r.manualFill != null) DraftKind.manualFillRecord,
  if (r.adviceSkip != null) DraftKind.adviceSkip,
  if (r.selfReport != null) DraftKind.selfReportBalance,
];

void _checkKey(DraftKey k) {
  if (k.targetId.isEmpty) {
    throw ArgumentError('DraftKey.targetId 가 비었다');
  }
}

/// 꼴 검사(의무 ⑩) — 본문 칸이 정확히 1개이고 그것이 `key.kind` 의 칸 · 🔴 메시지에 값 0(칸 이름만).
void checkDraftShape(DraftRecord r) {
  _checkKey(r.key);
  final List<DraftKind> f = _filled(r);
  if (f.length != 1 || f.single != r.key.kind) {
    throw ArgumentError(
      'DraftRecord 본문 칸이 ${r.key.kind.wire} 하나가 아니다(채운 칸 ${f.map((DraftKind k) => k.wire).join(',')})',
    );
  }
}

/// `DraftStore` 구현 — [DeviceLocal] 의 한 사슬 위에서 돈다.
class DeviceDraftStore implements DraftStore {
  /// 저장소를 만든다.
  DeviceDraftStore(this._local);

  final DeviceLocal _local;

  @override
  Future<DraftRecord?> load(DraftKey key) => _local.run(() async {
    _checkKey(key);
    final DeviceFamilyFile f = _local.current;
    final String k = draftItemKey(key);
    final SealedRow? row = f.get(DeviceNamespace.draft, k);
    if (row == null) return null;
    final Map<String, Object?>? json = await _local.unseal(
      f,
      DeviceNamespace.draft,
      row,
    );
    if (json == null) return null;
    final DraftRecord r;
    try {
      r = DraftRecord.fromJson(json);
    } on Object {
      _local.report(
        const DeviceStoreFault(
          DeviceStoreFaultKind.decodeFailed,
          DeviceNamespace.draft,
        ),
      );
      return null;
    }
    if (r.key != key) {
      _local.report(
        const DeviceStoreFault(
          DeviceStoreFaultKind.keyMismatch,
          DeviceNamespace.draft,
        ),
      );
      return null;
    }
    final String? link = r.lastCommandId;
    if (link != null &&
        f.get(DeviceNamespace.queue, link) == null &&
        f.get(DeviceNamespace.terminal, link) == null) {
      return r.copyWith(lastCommandId: null);
    }
    return r;
  });

  @override
  Future<void> save(DraftRecord record) => _local.run(() async {
    checkDraftShape(record);
    final DeviceFamilyFile f = _local.current;
    final String k = draftItemKey(record.key);
    final body = await _local.seal(
      f,
      DeviceNamespace.draft,
      k,
      record.toJson(),
    );
    f.put(
      DeviceNamespace.draft,
      k,
      body,
      linkedCommandId: record.lastCommandId,
    );
  });

  @override
  Future<void> clear(DraftKey key) => _local.run(() {
    _checkKey(key);
    _local.current.delete(DeviceNamespace.draft, draftItemKey(key));
  });

  /// SIM 원장 «폐기»를 고른 경우 — SIM 초안만 지운다(R46 G3 · §12-1-5 «계열 전환»).
  /// 🔴 LIVE 초안을 지우는 메서드는 두지 않는다(실제 매매의 수기 기록일 수 있다).
  Future<void> discardSimDrafts() =>
      _local.run(() => _local.simFile.deleteNamespace(DeviceNamespace.draft));

  @override
  String toString() => 'DeviceDraftStore';
}
