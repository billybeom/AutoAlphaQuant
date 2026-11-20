// 원장 파일 묶음(E11p3a · 설계 e11p-map Q1 · Q3 · Q4).
//
// 🔴 sim 파일은 늘 연다(온보딩 · 모의 개시가 여기서 시작한다).
// 🔴 live 파일은 **이미 있을 때만** 연다 — `openLocalLedger` 는 없으면 만들기 때문에 먼저 존재를 본다
//    (live 파일이 생기는 것은 simToAuto 뿐이다 · E15f — 🆕 E11q-c1(R191 · 미결 207 ⓒ) 세션 시작(6단계 · 엔진 사전 판정 통과 뒤 ·
//    [LedgerFiles.openLive]) · 커밋. 빈 live 파일 = 모드 행 0 → 기동 판정은 그대로 sim(`resolveBootMode`)).
// 🔵 연결은 프로세스 수명 동안 열어 둔다 — 깨어날 때마다 모드는 다시 판정하지만(Q4) 파일은 다시 열지 않는다.

import 'dart:io' show Directory, File;

import 'package:data_sync/data_sync.dart' show openLocalLedger;
import 'package:domain_contracts/domain_contracts.dart'
    show Clock, LedgerFile, RunMode;
import 'package:sqlite3/sqlite3.dart' show Database;

/// 원장 파일을 연다(시험이 가짜 폴더를 넣는다).
typedef LedgerOpener = Database Function(String directory, RunMode mode);

/// 한 폴더 안의 sim · live 원장.
class LedgerFiles {
  LedgerFiles._(this.directory, this.sim, this._opener);

  /// [directory] 를 만들고(없으면) sim 파일을 연다.
  factory LedgerFiles.open(
    String directory, {
    required Clock clock,
    LedgerOpener? opener,
  }) {
    Directory(directory).createSync(recursive: true);
    final LedgerOpener o =
        opener ??
        (String d, RunMode m) =>
            openLocalLedger(d, m, clock: () => clock.nowUtc());
    return LedgerFiles._(directory, o(directory, RunMode.simInternal), o);
  }

  /// 원장 폴더.
  final String directory;

  /// sim 원장(늘 열림).
  final Database sim;

  final LedgerOpener _opener;
  Database? _live;

  /// live 원장 — 파일이 아직 없으면 null(만들지 않는다).
  Database? liveIfExists() {
    final Database? open = _live;
    if (open != null) return open;
    if (!File('$directory/${LedgerFile.live.fileName}').existsSync()) {
      return null;
    }
    return _live = _opener(directory, RunMode.live);
  }

  /// 🆕 E11q-c1(R191 · 미결 207 ⓒ) — live 원장을 연다(없으면 만든다) — 🔴 simToAuto 세션 시작(엔진 사전 판정 통과 뒤)만 부른다.
  Database openLive() => _live ??= _opener(directory, RunMode.live);

  /// 닫는다(시험).
  void close() {
    sim.close();
    _live?.close();
    _live = null;
  }
}
