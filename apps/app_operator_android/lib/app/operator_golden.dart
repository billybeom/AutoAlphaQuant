// 골든 기기 실행기 operator 판(E11o-d · 설계 13 §8 R167 · R161 O4 · O6 · O7 · O8).
//
// 🔴 자산 = 엔진 패키지가 싣는 실행기 선언 파일만(`packages/core_engine/test/golden/vectors/<파일>` · 엔진 pubspec · 시험이 대조).
// 🔴 실행 = 백그라운드 isolate(`Isolate.run` · 화면이 멈추지 않게) · 판정 = 엔진 `kDeviceGoldenSuite`(시험과 같은 코드 · 두 벌 0).
// 🔴 기록 = 대상 원장의 `reconciliation_log` 1행(`gv-` · `GOLDEN_OK` / `GOLDEN_FAILED` · 결과 JSON) — S10 = 지금 화면 원장 ·
//    O-04 ④ = 온보딩 sim 파일.
// 🔴 실행기가 «전량»이 아니면 돌리지 않는다(부분 실행으로 «통과»를 지어내지 않는다 · R161 O5).
// 🔴 같은 실행이 진행 중이면 같은 결과를 기다린다(두 번 누름 = 한 번 실행).
// 🆕 리뷰 3차 G-2 · G-6(01 §8 미결 237) —
//    ① «지금 지문» = 벡터 묶음 지문 + 이 앱 설치 판(엔진 `goldenRunDigestOf`). 앱 판 = Android 패키지 정보
//       (`versionName+versionCode@lastUpdateTime` — 버전을 올리지 않은 다시 설치도 설치 시각이 바뀐다 = R161 O7 «앱 업데이트 = 다시 실행»).
//       판을 못 읽으면 준비 실패(= 판정 보류 · 다음에 다시) — 옛 통과를 지금 통과로 말하지 않는다(R167 F4).
//    ② 마지막 기록 = 넣은 차례(`rowid`) — 기기 시계 `run_at` 글자 순이면 시계가 뒤로 간 뒤 옛 OK 가 새 FAILED 를 이긴다.

import 'dart:async';
import 'dart:isolate';

import 'package:core_engine/core_engine.dart'
    show
        GoldenBundle,
        GoldenRecordView,
        GoldenRunResult,
        goldenDiscrepanciesJson,
        goldenRecordOf,
        goldenRunDigestOf,
        selftestGoldenResultOf,
        kDeviceGoldenSuite,
        kGoldenFailed,
        kGoldenOk,
        kGoldenReconPrefix;
import 'package:domain_contracts/domain_contracts.dart' show Clock;
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:sqlite3/sqlite3.dart' show Database, Row;

/// 자산 열쇠(엔진 패키지 자산).
String goldenAssetKey(String file) =>
    'packages/core_engine/test/golden/vectors/$file';

/// 읽은 묶음 · 지문 · 전체 수.
class GoldenPrepared {
  /// 만든다 — [digest] = 엔진 `goldenRunDigestOf`(벡터 묶음 + 앱 판).
  GoldenPrepared({
    required this.files,
    required this.vectorsDigest,
    required this.appBuild,
    required this.total,
  }) : digest = goldenRunDigestOf(
         vectorsDigest: vectorsDigest,
         appBuild: appBuild,
       );

  /// 파일 이름 → 원문.
  final Map<String, String> files;

  /// 벡터 묶음 지문(엔진 `GoldenBundle.digest`).
  final String vectorsDigest;

  /// 🆕 미결 237 — 이 앱 설치 판.
  final String appBuild;

  /// 🔴 지금 앱 판 지문(벡터 묶음 + 앱 판) — 기록 · S10 · O-04 ④ · 위저드가 비교하는 것은 이것뿐.
  final String digest;

  /// 돌리기 전 센 전체 수.
  final int total;
}

/// 골든 기기 실행기(operator).
class OperatorGolden {
  /// 만든다 — [load] = 자산 읽기(앱 = `rootBundle.loadString`) · [appBuild] = 이 앱 설치 판(앱 = `AndroidOps.appBuild` ·
  /// null · 빈 글자 = 못 읽음) · [isolate] = 백그라운드 실행(시험 = false).
  OperatorGolden(
    this._load, {
    required this.clock,
    required this.appBuild,
    this.isolate = true,
  });

  final Future<String> Function(String key) _load;

  /// 🆕 미결 237 — 이 앱 설치 판 읽기(null · 빈 글자 = 못 읽음 = 판정 보류).
  final Future<String?> Function() appBuild;

  /// 기록 시각.
  final Clock clock;

  /// 백그라운드 isolate 로 도나.
  final bool isolate;

  /// 지금 돌고 있나(S10 «실행 중»).
  final ValueNotifier<bool> running = ValueNotifier<bool>(false);

  Future<GoldenPrepared>? _prep;
  GoldenPrepared? _ready;
  Future<GoldenRunResult>? _inFlight;

  /// 읽어 둔 묶음(아직 · 못 읽음 = null).
  GoldenPrepared? get prepared => _ready;

  Future<T> _off<T>(FutureOr<T> Function() f) =>
      isolate ? Isolate.run(f) : Future<T>.sync(f);

  /// 🔴 자산을 읽고 지문 · 전체 수를 센다(한 번 · 실패하면 다음에 다시).
  Future<GoldenPrepared> prepare() => _prep ??= _doPrepare().then(
    (GoldenPrepared p) => _ready = p,
    onError: (Object e, StackTrace st) {
      _prep = null;
      return Future<GoldenPrepared>.error(e, st);
    },
  );

  Future<GoldenPrepared> _doPrepare() async {
    // 🔴 미결 237 — 앱 판을 못 읽으면 준비 실패(판정 보류 · 다음에 다시) — 판을 지어내지 않는다.
    final String? build = await appBuild();
    if (build == null || build.isEmpty) {
      throw StateError('골든: 앱 판을 읽지 못했습니다 — 판정 보류');
    }
    final Map<String, String> files = <String, String>{
      for (final String n in kDeviceGoldenSuite.files)
        n: await _load(goldenAssetKey(n)),
    };
    final (String, int) dt = await _off<(String, int)>(() {
      final GoldenBundle b = GoldenBundle(files);
      return (b.digest, kDeviceGoldenSuite.caseCount(b));
    });
    return GoldenPrepared(
      files: files,
      vectorsDigest: dt.$1,
      appBuild: build,
      total: dt.$2,
    );
  }

  /// 🔴 돌리고 [db] 에 기록한다 — «전량» 아님 = [StateError] · 진행 중 = 같은 결과.
  Future<GoldenRunResult> run(Database db) {
    if (!kDeviceGoldenSuite.complete) {
      return Future<GoldenRunResult>.error(StateError('골든 실행기 미완성 — 판정 보류'));
    }
    return _inFlight ??= _run(db).whenComplete(() => _inFlight = null);
  }

  Future<GoldenRunResult> _run(Database db) async {
    running.value = true;
    try {
      final GoldenPrepared p = await prepare();
      final GoldenRunResult r = await _off<GoldenRunResult>(
        () => kDeviceGoldenSuite.run(GoldenBundle(p.files)),
      );
      _record(db, r, p);
      return r;
    } finally {
      running.value = false;
    }
  }

  void _record(Database db, GoldenRunResult r, GoldenPrepared p) {
    final String at = clock.nowUtc().toUtc().toIso8601String();
    final int n =
        db.select(
              'SELECT COUNT(*) AS n FROM reconciliation_log WHERE run_at = ?',
              <Object?>[at],
            ).single['n']
            as int;
    db.execute(
      'INSERT INTO reconciliation_log (recon_id, run_at, matched, discrepancies, action_taken) '
      'VALUES (?, ?, ?, ?, ?)',
      <Object?>[
        '$kGoldenReconPrefix$at#${n + 1}',
        at,
        r.allPassed ? 1 : 0,
        goldenDiscrepanciesJson(r, appBuild: p.appBuild),
        r.allPassed ? kGoldenOk : kGoldenFailed,
      ],
    );
  }

  /// O-04 ④ 칸 — 돌리고 결과 문장(엔진)을 돌려준다.
  Future<String> runHeadline(Database db) async => selftestGoldenResultOf(
    actionRunId: 'o04-golden',
    result: await run(db),
  ).headline;

  /// [db] 의 마지막 골든 기록(없음 · 읽지 못함 = null) — 🔴 미결 237 G-6: 마지막 = 넣은 차례(`rowid` · 추가만 하는 표) ·
  /// 기기 시계 글자 순이 아니다.
  static GoldenRecordView? lastRecord(Database db) {
    final Row? row = db
        .select(
          'SELECT run_at, action_taken, discrepancies FROM reconciliation_log '
          "WHERE recon_id GLOB '$kGoldenReconPrefix*' "
          'ORDER BY rowid DESC LIMIT 1',
        )
        .firstOrNull;
    if (row == null) return null;
    return goldenRecordOf(
      runAt: row['run_at'] as String,
      actionTaken: row['action_taken'] as String?,
      discrepancies: row['discrepancies'] as String?,
    );
  }
}
