// E11q-c2 — M9 S09 백업·복원 VM · «지금 백업» 결과(설계 13 §8 R201) — 기대값 = 계약 표본(`m9/backup*` · `m9/backup_action_results`).
//
// 🔵 잡는 것: ① 표본 6벌 = 엔진 VM 그대로(기본 · 나이 경고 · 빈 · 모의 · 잠김 · 오래됨(as_of 만 다름)) ② 버튼 부재 갈래(K133 —
//    스탬프 0 · 아카이브 IN_SYNC 아님 · 창구 없음 · 잠김) + 까닭 고지 ③ 지점 행(새것부터 · 해시 앞 8 · 상태 줄 = 체크포인트 같음)
//    ④ 결과 10행 = 표본 글자에서 «(합성) » 만 뺀 것 · 엔진 코드 == 계약 사전 ⑤ 사전 밖 코드 = 거부 ⑥ 스냅숏 이름 ↔ 시각.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

Map<String, dynamic> _env(String name) =>
    jsonDecode(File('../domain_contracts/fixtures/m9/$name').readAsStringSync())
        as Map<String, dynamic>;

BackupVm _want(String name) => BackupVm.fromJson(
  (_env(name)['rows'] as List<Object?>).first! as Map<String, dynamic>,
);

// 표본 기준 = 2026-11-18T06:00Z(한국 15:00).
final DateTime _now = DateTime.utc(2026, 11, 18, 6);

// 지점 1 = 한국 11-17 21:40 만듦 · 11-17 장부까지 · 지점 2 = 한국 11-10 20:05 만듦 · 11-10 장부까지.
final DateTime _at1 = DateTime.utc(2026, 11, 17, 12, 40);
final DateTime _at2 = DateTime.utc(2026, 11, 10, 11, 5);

String _hex(String head) => head.padRight(64, '0');

BackupManifest _manifest(String day, String chain, {int epoch = 0}) =>
    BackupManifest(
      sha256: _hex('ab'),
      chainHash: chain,
      authoredDate: day,
      schemaVersion: 1,
      hashFormatVersion: 1,
      operatorEpoch: epoch,
      writerDeviceId: 'dev-c2',
    );

final String _chain1 = _hex('5e0c9a4f');
final String _chain2 = _hex('b71d03e8');

BackupPointFacts _p1({int epoch = 0}) => BackupPointFacts(
  code: 'rp_s09_01',
  createdAtUtc: _at1,
  manifest: _manifest('2026-11-17', _chain1, epoch: epoch),
);

BackupPointFacts _p2() => BackupPointFacts(
  code: 'rp_s09_02',
  createdAtUtc: _at2,
  manifest: _manifest('2026-11-10', _chain2),
);

ArchiveCheckpoint _cp({
  String day = '2026-11-17',
  String? chain,
  int epoch = 0,
}) => ArchiveCheckpoint(
  schemaVersion: 1,
  hashFormatVersion: 1,
  authoredDate: day,
  chainHash: chain ?? _chain1,
  operatorEpoch: epoch,
  writerDeviceId: 'dev-c2',
  committedAt: '2026-11-17T15:00:00Z',
);

BackupScreenFacts _facts({
  bool live = true,
  bool stamped = true,
  bool inSync = true,
  ArchiveCheckpoint? archive,
  bool noArchive = false,
  List<BackupPointFacts>? points,
  bool canRun = true,
  bool linkable = true,
  DateTime? now,
  String? locked,
}) => BackupScreenFacts(
  liveLedger: live,
  stamped: stamped,
  archiveInSync: inSync,
  archive: noArchive ? null : (archive ?? _cp()),
  points: points ?? <BackupPointFacts>[_p2(), _p1()],
  canRun: canRun,
  migrationLinkable: linkable,
  nowUtc: now ?? _now,
  lockedLabel: locked,
);

void main() {
  group('backupVmOf — 표본 6벌 = 엔진 VM 그대로', () {
    test(
      '🔴 기본 — 지점 2(받은 차례 무관 · 새것부터) · 새것만 «복원 검증 통과» · 버튼 · X1 링크 · OK',
      () {
        expect(backupVmOf(_facts()), _want('backup.json'));
      },
    );

    test('🔴 나이 경고 — 마지막 백업 26h 넘음 = WATCH + 배지 · 지점 머리 ≠ 체크포인트 = 상태 줄 부재', () {
      expect(
        backupVmOf(_facts(points: <BackupPointFacts>[_p2()])),
        _want('backup_age_warn.json'),
      );
    });

    test('🔴 빈 — live · 지점 0 = INFO «아직 백업한 적이 없습니다» · 빈 줄 · 버튼 · 링크', () {
      expect(
        backupVmOf(_facts(points: const <BackupPointFacts>[])),
        _want('backup_empty.json'),
      );
    });

    test(
      '🔴 모의 원장 = 버튼 · 링크 부재 + 모의 고지 · 지점 0(X1_LIVE_ONLY — 받은 지점이 있어도 그리지 않는다)',
      () {
        expect(backupVmOf(_facts(live: false)), _want('backup_sim.json'));
        expect(
          backupVmOf(_facts(live: false, stamped: false, inSync: false)),
          _want('backup_sim.json'),
        );
      },
    );

    test('🔴 잠김 = 버튼 · 링크 부재 · 나머지 기본과 같다(C-58 ⑬)', () {
      expect(
        backupVmOf(_facts(locked: BackupScreenTexts.locked)),
        _want('backup_locked.json'),
      );
    });

    test('🔵 오래됨 표본 = 기본과 as_of.stale_label 만 다르다(낡음 줄 = 조립 · 엔진은 새로 낸다)', () {
      final BackupVm stale = _want('backup_stale.json');
      expect(
        backupVmOf(_facts()),
        stale.copyWith(asOf: stale.asOf.copyWith(staleLabel: null)),
      );
    });
  });

  group('backupVmOf — 버튼 부재 갈래(K133 · 미결 199 ⓑⓒ) · 까닭 한 줄', () {
    test('🔴 스탬프 0 = 버튼 부재 + «마감된 장부가 없어» 고지 · 링크는 남는다', () {
      final BackupVm vm = backupVmOf(
        _facts(
          stamped: false,
          inSync: false,
          points: const <BackupPointFacts>[],
        ),
      );
      expect(vm.runAction, isNull);
      expect(vm.noticeText, BackupScreenTexts.noStampNotice);
      expect(vm.lastBackupText, BackupScreenTexts.never);
      expect(vm.migrationLink, isNotNull);
    });

    test('🔴 아카이브 IN_SYNC 아님(체크포인트 없음 · 뒤처짐) = 버튼 부재 + 아카이브 대기 고지 · 오래돼도 «눌러 주세요» 배지 0', () {
      for (final BackupScreenFacts f in <BackupScreenFacts>[
        _facts(inSync: false, noArchive: true),
        _facts(inSync: false),
      ]) {
        final BackupVm vm = backupVmOf(f);
        expect(vm.runAction, isNull);
        expect(vm.noticeText, BackupScreenTexts.archiveWaitNotice);
      }
      final BackupVm old = backupVmOf(
        _facts(inSync: false, points: <BackupPointFacts>[_p2()]),
      );
      expect(old.level, UiLevel.watch, reason: '나이는 사실 그대로');
      expect(old.ageBadgeText, isNull, reason: '누를 버튼이 없다');
    });

    test('🔴 창구 없음(설정 동작 · 기기 id) = 버튼만 부재 · 고지 · 링크 그대로', () {
      final BackupVm vm = backupVmOf(_facts(canRun: false));
      expect(vm.runAction, isNull);
      expect(vm.noticeText, BackupScreenTexts.notice);
      expect(vm.migrationLink, isNotNull);
    });

    test('🔴 X1 화면 본문 없음 = 링크 부재(막다른 길 0)', () {
      expect(backupVmOf(_facts(linkable: false)).migrationLink, isNull);
    });

    test('🔴 runAction = backupRunNow · args {} · 글자 엔진', () {
      final SettingsActionCall run = backupVmOf(_facts()).runAction!;
      expect(run.id, SettingsActionId.backupRunNow);
      expect(run.args, isEmpty);
      expect(run.label, BackupScreenTexts.run);
    });
  });

  group('backupVmOf — 지점 행', () {
    test('🔴 해시 앞 8 = 엔진이 자른다 · 상태 줄 = 날 · 체인 · epoch 모두 같을 때만', () {
      final BackupVm vm = backupVmOf(_facts());
      expect(vm.points.map((RestorePointRow p) => p.chainHashText), <String>[
        '5e0c9a4f',
        'b71d03e8',
      ]);
      expect(
        backupVmOf(_facts(archive: _cp(epoch: 1))).points.first.stateLabel,
        isNull,
        reason: 'epoch 다름',
      );
      expect(
        backupVmOf(_facts(archive: _cp(chain: _hex('ff'))))
            .points
            .first
            .stateLabel,
        isNull,
        reason: '체인 다름',
      );
      expect(
        backupVmOf(_facts(noArchive: true)).points.first.stateLabel,
        isNull,
        reason: '체크포인트 없음',
      );
    });

    test('🔵 26h 경계 — 딱 26h = 아직 OK · 1분 넘음 = WATCH', () {
      final DateTime edge = _at1.add(kBackupStaleAfter);
      expect(backupVmOf(_facts(now: edge)).level, UiLevel.ok);
      expect(
        backupVmOf(_facts(now: edge.add(const Duration(minutes: 1)))).level,
        UiLevel.watch,
      );
    });
  });

  group('backupRunResultOf — 결과 사전', () {
    test('🔴 표본 10행 = 글자에서 «(합성) » 만 뺀 것 · 레벨 · 코드 그대로', () {
      final List<ActionResult> rows =
          (_env('backup_action_results.json')['rows'] as List<Object?>)
              .cast<Map<String, dynamic>>()
              .map(ActionResult.fromJson)
              .toList();
      expect(rows, hasLength(10));
      for (final ActionResult want in rows) {
        final ActionResult got = backupRunResultOf(
          actionRunId: want.actionRunId,
          rejectCode: want.reasonCode,
        );
        expect(
          got,
          want.copyWith(headline: want.headline.replaceFirst('(합성) ', '')),
          reason: '${want.reasonCode}',
        );
      }
    });

    test('🔴 엔진 take 코드 8 == 계약 BackupResultCodes(글자 같음) · 나올 수 없는 2 = 거부', () {
      final Set<String> engine = <String>{
        MigrationStartCodes.liveOnly,
        SnapshotCodes.noStamp,
        SnapshotCodes.exists,
        RestoreReason.unreadable.wire,
        RestoreReason.schemaSkew.wire,
        RestoreReason.sqliteIntegrity.wire,
        RestoreReason.chainInvalid.wire,
        RestoreReason.rollback.wire,
      };
      expect(engine, BackupResultCodes.values);
      for (final String code in BackupResultCodes.values) {
        expect(
          backupRunResultOf(actionRunId: 'x', rejectCode: code).reasonCode,
          code,
        );
      }
      for (final String bad in <String>[
        RestoreReason.shaMismatch.wire,
        RestoreReason.manifestMismatch.wire,
        'NOPE',
      ]) {
        expect(
          () => backupRunResultOf(actionRunId: 'x', rejectCode: bad),
          throwsArgumentError,
          reason: bad,
        );
      }
    });
  });

  group('스냅숏 이름 = 만든 시각(UTC 분)', () {
    test('🔴 이름 ↔ 시각 왕복 · 초 버림 · 꼴 밖 = null', () {
      final DateTime t = DateTime.utc(2026, 11, 17, 12, 40, 59);
      final String n = backupSnapshotNameOf(t);
      expect(n, 'bk_20261117T1240Z');
      expect(backupSnapshotTimeOf(n), DateTime.utc(2026, 11, 17, 12, 40));
      expect(
        backupSnapshotNameOf(DateTime.parse('2026-11-17T21:40:00+09:00')),
        n,
        reason: '시간대 무관',
      );
      for (final String bad in <String>[
        'mig-20261105-1',
        'bk_20261117T1240',
        'bk_20260230T1240Z',
        'bk_20261117T2460Z',
        'rp_s09_01',
      ]) {
        expect(backupSnapshotTimeOf(bad), isNull, reason: bad);
      }
    });
  });
}
