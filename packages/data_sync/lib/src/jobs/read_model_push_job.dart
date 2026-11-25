// 🆕 E11l2c — 읽기 모델 push 일(설계 13 §8 R263 · 01 §8 미결 241 ⓐⓑⓒⓓ · 01 §6-4 규칙 5조 ②③⑥ · 06 M4-1).
//
// 🔵 한 번 = 원천이 있는 표마다(계약 `ReadModelTables` 차례) 지금 모습 전부 → `readModelRow`(판 = 이 일이 붙인다) →
//    [chunkSize] 행씩 나눠 `rm_push` → 로컬 상태. 목록 봉투(`rm_list_envelope`)는 원천들이 낸 봉투를 모아 마지막에.
// 🔴 리스가 없으면(기기 id 없음 · epoch 0) 아무것도 하지 않는다(상태도 안 바꾼다).
// 🔴 리스 거부(`LEASE_LOST` · `LEASE_DEVICE_NOT_ELIGIBLE`)를 받으면 그 자리에서 멈춘다 — 다른 표도 같은 답이다(PUSH_LAG).
// 🔴 표 하나의 실패는 그 표만 멈춘다(앞 묶음은 이미 들어갔을 수 있다 — 행마다 독립 upsert · 다음 판이 덮는다).
// 🔴 PUSH_FAILED(시크릿 차단 · 행 틀림 · 표 모름 · 응답 꼴 · 행을 못 만듦) = 보고서에 실어 돌려준다 — P1 알림 코드는 계약 창 몫(1.39.0).
// 🔴 버전 스탬프(규칙 5조 ⑥) = 빌더가 `rm_config_view` 행마다 싣는다 — 그 표에 원천이 있으면 push 마다 함께 간다.
// 🆕 미결 242(설계 13 §8 R275 · 01 §48 K339) — 차례 열이 있는 표: 직전 소속(로컬 곁 행)에 있었는데 이번 행에 키가 없는 행 =
//    같은 키 · 이 판 · 차례 null 로 다시 보낸다(삭제 0 · K335 — 시간이 지나 빠지는 원장 차이 30일 · 알림 7일 · 안내 만료 ·
//    시리즈 기본 구간 밖 옛 점 포함). 판정 밖 = 다른 모드 행([mode]) · 이번에 원천을 못 읽은 범위([ReadModelSnapshot.unread]) —
//    그대로 소속에 둔다(다음 깨어남에 다시). 소속 = 보냄 성공 = 이번 차례 행(+판정 밖) · 보냄 실패 = 직전 ∪ 이번(앞 묶음이
//    들어갔을 수 있다 — 빠진 행은 다음에 다시) · 원천 · 빌더 실패 = 그대로.

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart'
    show
        EmptyKind,
        LeaseRpcResultCodes,
        ReadModelPushColumns,
        ReadModelPushResultCodes,
        ReadModelTable,
        ReadModelTables,
        RunMode;

import '../local/read_model_push_status.dart';
import '../supabase/read_model_rows.dart';
import '../supabase/supabase_read_model_push.dart';

/// 목록 봉투 한 칸(원천이 낸다 — `ListResult` 의 봉투).
class ReadModelEnvelopeDraft {
  /// 만든다.
  const ReadModelEnvelopeDraft({
    required this.mode,
    required this.listCode,
    required this.asOf,
    required this.emptyKind,
    this.emptyLabel,
    this.filteredEmptyLabel,
    this.scopeEmptyLabel,
  });

  /// 모드.
  final RunMode mode;

  /// `ReadModelListCodes` 값.
  final String listCode;

  /// `AsOf.toJson()`.
  final Map<String, Object?> asOf;

  /// 빈 갈래.
  final EmptyKind emptyKind;

  /// 빈 문장.
  final String? emptyLabel;

  /// 🆕 미결 242(K340) — 필터를 건 조회가 빈 때 엔진 문장(없으면 null).
  final String? filteredEmptyLabel;

  /// 🆕 미결 242(K340) — 일지 회차 필터가 빈 때 엔진 문장(없으면 null).
  final String? scopeEmptyLabel;
}

/// 표 하나의 지금 모습(판 없음 — 이 일이 붙인다).
class ReadModelSnapshot {
  /// 만든다.
  const ReadModelSnapshot({
    this.rows = const <ReadModelRowInput>[],
    this.envelopes = const <ReadModelEnvelopeDraft>[],
    this.unread = const <Map<String, Object?>>[],
  });

  /// 행 입력(판은 무시된다).
  final List<ReadModelRowInput> rows;

  /// 이 표가 행 원천인 목록의 봉투.
  final List<ReadModelEnvelopeDraft> envelopes;

  /// 🆕 미결 242(R275) — 이번에 원천을 못 읽은 범위(열 → 값 · 다 같으면 그 범위 · 빈 맵 = 표 전체) — 직전 소속 중
  /// 이 범위 행은 «빠짐» 판정을 하지 않는다(매개 값 하나 실패 = 그 값만 뺀다 · R268 D4 — 그 값의 옛 행 차례를 지우지 않는다).
  final List<Map<String, Object?>> unread;
}

/// 표 하나의 원천.
typedef ReadModelSnapshotSource = Future<ReadModelSnapshot> Function();

/// 표 하나의 결과 갈래.
enum ReadModelPushOutcome {
  /// 받아들여짐.
  ok,

  /// 다음에 다시(망 · 서버 · 로그인 · 리스 · 원천 아직).
  lag,

  /// 사람이 볼 일.
  failed,

  /// 리스 거부 뒤라 시도하지 않음.
  notTried,
}

/// 표 하나의 결과.
class ReadModelTablePush {
  /// 만든다.
  const ReadModelTablePush(
    this.table,
    this.outcome, {
    this.rowVersion = 0,
    this.rows = 0,
    this.accepted = 0,
    this.skipped = 0,
    this.reason,
  });

  /// 표 이름.
  final String table;

  /// 갈래.
  final ReadModelPushOutcome outcome;

  /// 쓴 판.
  final int rowVersion;

  /// 보낸 행 수.
  final int rows;

  /// 넣거나 바꾼 행 수(합).
  final int accepted;

  /// 건너뛴 행 수(합).
  final int skipped;

  /// 사유(서버 코드 · 실패 이름 · 빌더 사유 — 🔴 값 0).
  final String? reason;

  @override
  String toString() =>
      '$table ${outcome.name}${reason == null ? '' : ' $reason'} $accepted/$skipped';
}

/// 한 번의 보고서.
class ReadModelPushReport {
  /// 만든다.
  const ReadModelPushReport(this.tables, {this.noLease = false});

  /// 리스가 없어 하지 않았다.
  final bool noLease;

  /// 표마다(차례 = 계약 차례 · 원천 없는 표 = 없음).
  final List<ReadModelTablePush> tables;

  /// 사람이 볼 실패.
  List<ReadModelTablePush> get failed => <ReadModelTablePush>[
    for (final ReadModelTablePush t in tables)
      if (t.outcome == ReadModelPushOutcome.failed) t,
  ];
}

/// 🆕 읽기 모델 push 일.
class ReadModelPushJob {
  /// 만든다 — [sources] = 표 이름 → 원천(없는 표 = 보내지 않는다 · `rm_list_envelope` 는 원천을 받지 않는다).
  ReadModelPushJob({
    required this.pusher,
    required this.status,
    required this.sources,
    required this.nowUtc,
    this.chunkSize = 200,
    this.mode,
  }) {
    if (chunkSize < 1) throw ArgumentError.value(chunkSize, 'chunkSize');
    for (final String name in sources.keys) {
      final ReadModelTable? t = readModelTableNamed(name);
      if (t == null || t == ReadModelTables.listEnvelope) {
        throw ArgumentError.value(name, 'sources', '계약 22표(봉투 표 밖)만');
      }
    }
  }

  /// push 포트.
  final ReadModelPusher pusher;

  /// 로컬 상태.
  final SqliteReadModelPushStatus status;

  /// 표 이름 → 원천.
  final Map<String, ReadModelSnapshotSource> sources;

  /// 지금(UTC).
  final DateTime Function() nowUtc;

  /// 한 번에 보내는 행 수 상한.
  final int chunkSize;

  /// 🆕 미결 242(R275) — 이 push 가 읽은 원장 모드(직전 소속 중 다른 모드 행 = 빠짐 판정 0 · null = 모드를 가리지 않는다).
  final RunMode? mode;

  /// 한 번 돈다 — 이 기기 [deviceId] · 쥔 리스 [epoch].
  Future<ReadModelPushReport> run({
    required String? deviceId,
    required int epoch,
  }) async {
    if (deviceId == null || deviceId.isEmpty || epoch <= 0) {
      return const ReadModelPushReport(<ReadModelTablePush>[], noLease: true);
    }
    final List<ReadModelTablePush> out = <ReadModelTablePush>[];
    final Map<String, ReadModelEnvelopeDraft> envelopes =
        <String, ReadModelEnvelopeDraft>{};
    bool leaseGone = false;
    for (final ReadModelTable t in ReadModelTables.all) {
      final ReadModelSnapshotSource? src = sources[t.name];
      if (src == null) continue;
      if (leaseGone) {
        out.add(ReadModelTablePush(t.name, ReadModelPushOutcome.notTried));
        continue;
      }
      final int rv = status.nextRowVersion(t.name, epoch);
      final ReadModelSnapshot snap;
      try {
        snap = await src();
      } on Object catch (e) {
        status.recordLag(t.name, rv);
        out.add(
          ReadModelTablePush(
            t.name,
            ReadModelPushOutcome.lag,
            rowVersion: rv,
            reason: 'SOURCE:${e.runtimeType}',
          ),
        );
        continue;
      }
      for (final ReadModelEnvelopeDraft e in snap.envelopes) {
        envelopes['${e.mode.wire}|${e.listCode}'] = e;
      }
      final List<Map<String, Object?>> rows;
      try {
        rows = <Map<String, Object?>>[
          for (final ReadModelRowInput r in snap.rows)
            readModelRow(t, r.withRowVersion(rv)),
        ];
      } on ReadModelRowError catch (e) {
        status.recordFailed(t.name, rv);
        out.add(
          ReadModelTablePush(
            t.name,
            ReadModelPushOutcome.failed,
            rowVersion: rv,
            reason: 'ROW:${e.reason}',
          ),
        );
        continue;
      }
      final _Membership? m = _membership(t, rv, rows, snap.unread);
      final ReadModelTablePush r = await _send(
        t,
        rv,
        m == null ? rows : <Map<String, Object?>>[...rows, ...m.dropped],
        deviceId,
        epoch,
      );
      if (m != null) {
        status.recordMembers(
          t.name,
          rv,
          r.outcome == ReadModelPushOutcome.ok ? m.afterOk : m.afterFail,
          nowUtc(),
        );
      }
      out.add(r);
      if (_isLeaseCode(r.reason)) leaseGone = true;
    }
    if (envelopes.isNotEmpty) {
      const ReadModelTable t = ReadModelTables.listEnvelope;
      if (leaseGone) {
        out.add(
          const ReadModelTablePush(
            'rm_list_envelope',
            ReadModelPushOutcome.notTried,
          ),
        );
      } else {
        final int rv = status.nextRowVersion(t.name, epoch);
        final List<Map<String, Object?>> rows;
        try {
          rows = <Map<String, Object?>>[
            for (final ReadModelEnvelopeDraft e in envelopes.values)
              listEnvelopeRow(
                mode: e.mode,
                rowVersion: rv,
                listCode: e.listCode,
                asOf: e.asOf,
                emptyKind: e.emptyKind,
                emptyLabel: e.emptyLabel,
                filteredEmptyLabel: e.filteredEmptyLabel,
                scopeEmptyLabel: e.scopeEmptyLabel,
              ),
          ];
        } on ReadModelRowError catch (e) {
          status.recordFailed(t.name, rv);
          out.add(
            ReadModelTablePush(
              t.name,
              ReadModelPushOutcome.failed,
              rowVersion: rv,
              reason: 'ROW:${e.reason}',
            ),
          );
          return ReadModelPushReport(out);
        }
        out.add(await _send(t, rv, rows, deviceId, epoch));
      }
    }
    return ReadModelPushReport(out);
  }

  Future<ReadModelTablePush> _send(
    ReadModelTable t,
    int rv,
    List<Map<String, Object?>> rows,
    String deviceId,
    int epoch,
  ) async {
    int accepted = 0;
    int skipped = 0;
    for (int i = 0; i < rows.length; i += chunkSize) {
      final List<Map<String, Object?>> chunk = rows.sublist(
        i,
        i + chunkSize > rows.length ? rows.length : i + chunkSize,
      );
      final ReadModelPushResult r = await pusher.push(
        deviceId: deviceId,
        epoch: epoch,
        table: t,
        rows: chunk,
      );
      if (r.ok) {
        accepted += r.accepted;
        skipped += r.skipped;
        continue;
      }
      final String reason = r.code ?? r.failure!.name;
      final bool fail = _isFailure(r);
      if (fail) {
        status.recordFailed(t.name, rv);
      } else {
        status.recordLag(t.name, rv);
      }
      return ReadModelTablePush(
        t.name,
        fail ? ReadModelPushOutcome.failed : ReadModelPushOutcome.lag,
        rowVersion: rv,
        rows: rows.length,
        accepted: accepted,
        skipped: skipped,
        reason: reason,
      );
    }
    status.recordOk(t.name, rv, rows.length, nowUtc());
    return ReadModelTablePush(
      t.name,
      ReadModelPushOutcome.ok,
      rowVersion: rv,
      rows: rows.length,
      accepted: accepted,
      skipped: skipped,
    );
  }

  /// 🆕 미결 242(R275) — 차례 열이 있는 표의 빠진 행 · 다음 소속(차례 열 없는 표 = null).
  _Membership? _membership(
    ReadModelTable t,
    int rv,
    List<Map<String, Object?>> rows,
    List<Map<String, Object?>> unread,
  ) {
    final List<String> ranks = readModelRankColumns(t);
    if (ranks.isEmpty) return null;
    String keyOf(Map<String, Object?> r) =>
        jsonEncode(<Object?>[for (final String k in t.keyColumns) r[k]]);
    bool isMember(Map<String, Object?> r) =>
        ranks.any((String c) => r[c] != null);
    bool judged(Map<String, Object?> r) =>
        (mode == null || r[ReadModelPushColumns.mode.name] == mode!.wire) &&
        !unread.any(
          (Map<String, Object?> s) => s.entries.every(
            (MapEntry<String, Object?> e) => r[e.key] == e.value,
          ),
        );
    final Set<String> now = <String>{
      for (final Map<String, Object?> r in rows) keyOf(r),
    };
    final Map<String, Map<String, Object?>> current =
        <String, Map<String, Object?>>{
          for (final Map<String, Object?> r in rows)
            if (isMember(r)) keyOf(r): r,
        };
    final Map<String, Map<String, Object?>> prev =
        <String, Map<String, Object?>>{
          for (final Map<String, Object?> r in status.members(t.name))
            keyOf(r): r,
        };
    final List<Map<String, Object?>> dropped = <Map<String, Object?>>[];
    final Map<String, Map<String, Object?>> carried =
        <String, Map<String, Object?>>{};
    prev.forEach((String k, Map<String, Object?> r) {
      if (now.contains(k)) return;
      if (judged(r)) {
        dropped.add(<String, Object?>{
          ...r,
          ReadModelPushColumns.rowVersion.name: rv,
          for (final String c in ranks) c: null,
        });
      } else {
        carried[k] = r;
      }
    });
    return _Membership(
      dropped: dropped,
      afterOk: <Map<String, Object?>>[
        ...<String, Map<String, Object?>>{...carried, ...current}.values,
      ],
      afterFail: <Map<String, Object?>>[
        ...<String, Map<String, Object?>>{...prev, ...current}.values,
      ],
    );
  }

  static bool _isLeaseCode(String? reason) =>
      reason == LeaseRpcResultCodes.lost ||
      reason == LeaseRpcResultCodes.deviceNotEligible;

  /// 사람이 볼 실패(나머지 = 다음 깨우기에 다시).
  static bool _isFailure(ReadModelPushResult r) {
    if (r.code != null) return ReadModelPushResultCodes.values.contains(r.code);
    return r.failure == ReadModelPushFailure.secretBlocked ||
        r.failure == ReadModelPushFailure.badResponse;
  }
}

/// 🆕 미결 242(R275) — 한 표의 빠진 행 · 보냄 결과별 다음 소속.
class _Membership {
  const _Membership({
    required this.dropped,
    required this.afterOk,
    required this.afterFail,
  });

  /// 다시 보낼 빠진 행(같은 키 · 이 판 · 차례 null).
  final List<Map<String, Object?>> dropped;

  /// 보냄 성공 뒤 소속(이번 차례 행 + 판정 밖 직전 행).
  final List<Map<String, Object?>> afterOk;

  /// 보냄 실패 뒤 소속(직전 ∪ 이번 차례 행).
  final List<Map<String, Object?>> afterFail;
}
