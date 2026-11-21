// X5-4 파생(원격 사본 · 아카이브 · 캘린더) ↔ 정본 체인 관계 · 동기 조치 · 체인 diff(순수 · 설계 13 §8 R112 E16a ·
// 06 :289 FORK · :290 RESTORE_ROLLBACK · 지도 e16-map D4 · D16).
//
// 🔴 한 분류기 — 파생 epoch > 정본 = EPOCH_AHEAD · 파생 날 > 정본 마지막 날 = AHEAD · 같은 날 체인 다름(기준점 밖)
//    · 정본 첫 날보다 앞 = DIVERGED → 셋 다 FORK(끈적 · 재생성 0 · 사람만 해제).
// 🔴 epoch 를 날짜보다 먼저 본다(더 새 기기의 기록은 날이 같아도 FORK).
// 🔴 FORK 판정은 리스와 무관(판정 · 로컬 기록은 파생 쓰기가 아니다) · 재생성만 리스 유효 · 일 상한 안에서.
// 🔴 파생 diff 는 어떤 관계에서도 관측 등급(주문을 막지 않는다 · `diffSeverityFor`).
// 🔵 일 재생성 상한은 기본값 없이 인자로(값 = E16-0 `operations.migration.derived_resync_daily_cap`).

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AlertCodes,
        DerivedRelationCodes,
        DiffSeverity,
        LedgerAxis,
        LedgerPair,
        OriginCodes;

import '../orders/ledger_pairs.dart' show diffSeverityFor;
import 'lease_gate.dart' show LeaseVerdict;
import 'ledger_archive.dart' show ArchiveCheckpoint;
import 'ledger_integrity.dart' show StoredDayStamp;

/// 파생 FORK 알림 코드(P0 · 글자 = 계약 `AlertCodes.derivedFork` 참조 · 미결 212).
const String kDerivedForkAlertCode = AlertCodes.derivedFork;

final RegExp _day = RegExp(r'^\d{4}-\d{2}-\d{2}$');
final RegExp _hex64 = RegExp(r'^[0-9a-f]{64}$');

/// 파생 대상(02 `sync_state.target`).
enum DerivedTarget {
  /// 원격 사본(Supabase).
  supabase(
    'SUPABASE',
    LedgerPair.canonSupabase,
    OriginCodes.pushLag,
    '원격 사본',
    '원격 사본이',
  ),

  /// 아카이브(GitHub).
  github(
    'GITHUB',
    LedgerPair.canonGithub,
    OriginCodes.archiveLag,
    '아카이브',
    '아카이브가',
  ),

  /// 캘린더.
  calendar(
    'CALENDAR',
    LedgerPair.canonCalendar,
    OriginCodes.calWriteFailed,
    '캘린더',
    '캘린더가',
  );

  const DerivedTarget(
    this.syncTarget,
    this.pair,
    this.lagOriginCode,
    this.label,
    this.subject,
  );

  /// `sync_state.target` 글자.
  final String syncTarget;

  /// 대조 쌍.
  final LedgerPair pair;

  /// 뒤처짐 원인 코드.
  final String lagOriginCode;

  /// 문구 이름.
  final String label;

  /// 문구 주어(이 · 가).
  final String subject;
}

/// `sync_state.status`(02 CHECK).
enum DerivedSyncStatus {
  /// 맞음.
  ok('OK'),

  /// 밀림.
  pushLag('PUSH_LAG'),

  /// 밀어 넣기 실패.
  pushFailed('PUSH_FAILED'),

  /// 갈라짐(끈적 · 사람만 해제).
  fork('FORK'),

  /// 봉인.
  sealed('SEALED');

  const DerivedSyncStatus(this.wire);

  /// 저장 글자.
  final String wire;

  /// 저장 글자 → 값(모르면 [FormatException]).
  static DerivedSyncStatus parse(String w) => values.firstWhere(
    (DerivedSyncStatus s) => s.wire == w,
    orElse: () => throw FormatException('sync_state.status', w),
  );
}

/// 파생 쪽 마지막 스탬프.
class DerivedStamp {
  /// 스탬프를 만든다 — 날 `YYYY-MM-DD` · 체인 16진 64 · epoch ≥ 0(아니면 [ArgumentError]).
  DerivedStamp({
    required this.authoredDate,
    required this.chainHash,
    required this.operatorEpoch,
  }) {
    if (!_day.hasMatch(authoredDate)) {
      throw ArgumentError.value(authoredDate, 'authoredDate', '날 꼴이 아니다');
    }
    if (!_hex64.hasMatch(chainHash)) {
      throw ArgumentError.value(chainHash.length, 'chainHash', '체인 꼴이 아니다');
    }
    if (operatorEpoch < 0) {
      throw ArgumentError.value(operatorEpoch, 'operatorEpoch', '음수');
    }
  }

  /// 아카이브 체크포인트에서.
  factory DerivedStamp.fromCheckpoint(ArchiveCheckpoint c) => DerivedStamp(
    authoredDate: c.authoredDate,
    chainHash: c.chainHash,
    operatorEpoch: c.operatorEpoch,
  );

  /// 마지막으로 쓴 날.
  final String authoredDate;

  /// 그 날 체인.
  final String chainHash;

  /// 쓴 기기의 epoch.
  final int operatorEpoch;
}

/// 새 기준점(R112 D2 — 생산자 = E16f · 여기는 입력만).
class ChainBaseline {
  /// 기준점을 만든다.
  const ChainBaseline({required this.fromDate, required this.decisionId});

  /// 이 날부터 스탬프를 다시 썼다.
  final String fromDate;

  /// 선언 결정.
  final String decisionId;
}

/// 정본 체인(스탬프는 날 오름차순 · 겹침 0).
class CanonChain {
  /// 체인을 만든다 — 오름차순이 아니거나 같은 날이 둘이면 [ArgumentError](연속성 검사 = `verifyLedgerChain`).
  CanonChain({
    required List<StoredDayStamp> stamps,
    required this.operatorEpoch,
    List<ChainBaseline> baselines = const <ChainBaseline>[],
  }) : stamps = List<StoredDayStamp>.unmodifiable(stamps),
       baselines = List<ChainBaseline>.unmodifiable(baselines) {
    for (int i = 1; i < stamps.length; i++) {
      if (stamps[i].authoredDate.compareTo(stamps[i - 1].authoredDate) <= 0) {
        throw ArgumentError('정본 스탬프가 오름차순이 아니다: ${stamps[i].authoredDate}');
      }
    }
    if (operatorEpoch < 0) {
      throw ArgumentError.value(operatorEpoch, 'operatorEpoch', '음수');
    }
  }

  /// 스탬프.
  final List<StoredDayStamp> stamps;

  /// 지금 epoch.
  final int operatorEpoch;

  /// 새 기준점.
  final List<ChainBaseline> baselines;

  /// 첫 날(없음 = null).
  String? get firstDate => stamps.isEmpty ? null : stamps.first.authoredDate;

  /// 마지막 날(없음 = null).
  String? get lastDate => stamps.isEmpty ? null : stamps.last.authoredDate;

  /// 그 날 체인(없음 = null).
  String? chainAt(String date) {
    for (final StoredDayStamp s in stamps) {
      if (s.authoredDate == date) return s.chainHash;
    }
    return null;
  }

  /// [date] 뒤 첫 스탬프 날(없음 = null).
  String? dateAfter(String date) {
    for (final StoredDayStamp s in stamps) {
      if (s.authoredDate.compareTo(date) > 0) return s.authoredDate;
    }
    return null;
  }
}

/// 파생 ↔ 정본 관계.
enum DerivedRelation {
  /// 같다.
  inSync(DerivedRelationCodes.inSync),

  /// 파생이 비었다.
  empty(DerivedRelationCodes.empty),

  /// 파생이 뒤처졌다(같은 사슬).
  behind(DerivedRelationCodes.behind),

  /// 새 기준점 전 기록(재생성).
  rebased(DerivedRelationCodes.rebased),

  /// 파생이 정본보다 앞섰다(FORK · RESTORE_ROLLBACK).
  ahead(DerivedRelationCodes.ahead),

  /// 갈라졌다(FORK).
  diverged(DerivedRelationCodes.diverged),

  /// 더 새 기기의 기록(FORK).
  epochAhead(DerivedRelationCodes.epochAhead);

  const DerivedRelation(this.wire);

  /// 글자.
  final String wire;

  /// FORK 인가.
  bool get forks =>
      this == DerivedRelation.ahead ||
      this == DerivedRelation.diverged ||
      this == DerivedRelation.epochAhead;
}

/// 🔴 관계 분류(R112 D4) — epoch 먼저.
DerivedRelation derivedRelationOf(CanonChain canon, DerivedStamp? derived) {
  if (derived == null) {
    return canon.stamps.isEmpty
        ? DerivedRelation.inSync
        : DerivedRelation.empty;
  }
  if (derived.operatorEpoch > canon.operatorEpoch) {
    return DerivedRelation.epochAhead;
  }
  final String? last = canon.lastDate;
  if (last == null || derived.authoredDate.compareTo(last) > 0) {
    return DerivedRelation.ahead;
  }
  if (derived.authoredDate.compareTo(canon.firstDate!) < 0) {
    return DerivedRelation.diverged;
  }
  final String? c = canon.chainAt(derived.authoredDate);
  if (c == derived.chainHash) {
    return derived.authoredDate == last
        ? DerivedRelation.inSync
        : DerivedRelation.behind;
  }
  if (canon.baselines.any(
    (ChainBaseline b) => b.fromDate.compareTo(derived.authoredDate) <= 0,
  )) {
    return DerivedRelation.rebased;
  }
  return DerivedRelation.diverged;
}

/// 재생성을 미루는 까닭.
enum DerivedHoldReason {
  /// 리스가 유효하지 않다.
  leaseNotValid('LEASE_NOT_VALID'),

  /// 오늘 재생성 상한.
  dailyCap('DAILY_CAP'),

  /// 봉인.
  sealed('SEALED');

  const DerivedHoldReason(this.wire);

  /// 글자.
  final String wire;
}

/// 동기 조치.
sealed class DerivedSyncAction {
  const DerivedSyncAction();
}

/// 할 일 없음.
final class DerivedNoop extends DerivedSyncAction {
  /// 만든다.
  const DerivedNoop();
}

/// [fromDate] 부터 다시 만든다.
final class DerivedResync extends DerivedSyncAction {
  /// 만든다.
  const DerivedResync(this.fromDate);

  /// 시작 날.
  final String fromDate;
}

/// 미룬다.
final class DerivedHold extends DerivedSyncAction {
  /// 만든다.
  const DerivedHold(this.reason);

  /// 까닭.
  final DerivedHoldReason reason;
}

/// 쓰기를 멈춘다(FORK · 끈적).
final class DerivedForkStop extends DerivedSyncAction {
  /// 만든다.
  const DerivedForkStop(this.relation);

  /// 판정된 관계.
  final DerivedRelation relation;
}

/// 🔴 동기 조치(R112 D4) — FORK 끈적 · FORK 판정은 리스 무관 · 재생성 = 리스 유효 ∧ 일 상한 안.
///
/// [dailyCap] = 하루 재생성 상한(기본값 없음 · 1 미만 = [ArgumentError]).
DerivedSyncAction derivedSyncActionOf({
  required DerivedRelation relation,
  required DerivedSyncStatus current,
  required LeaseVerdict lease,
  required int resyncsToday,
  required int dailyCap,
  required CanonChain canon,
  DerivedStamp? derived,
}) {
  if (dailyCap < 1) {
    throw ArgumentError.value(dailyCap, 'dailyCap', '1 이상');
  }
  if (current == DerivedSyncStatus.fork) return DerivedForkStop(relation);
  if (relation.forks) return DerivedForkStop(relation);
  if (current == DerivedSyncStatus.sealed) {
    return const DerivedHold(DerivedHoldReason.sealed);
  }
  if (relation == DerivedRelation.inSync) return const DerivedNoop();
  if (lease != LeaseVerdict.valid) {
    return const DerivedHold(DerivedHoldReason.leaseNotValid);
  }
  if (resyncsToday >= dailyCap) {
    return const DerivedHold(DerivedHoldReason.dailyCap);
  }
  return DerivedResync(switch (relation) {
    DerivedRelation.empty => canon.firstDate!,
    DerivedRelation.behind => canon.dateAfter(derived!.authoredDate)!,
    DerivedRelation.rebased =>
      (canon.baselines
              .where(
                (ChainBaseline b) =>
                    b.fromDate.compareTo(derived!.authoredDate) <= 0,
              )
              .map((ChainBaseline b) => b.fromDate)
              .toList()
            ..sort())
          .first,
    _ => throw StateError('재생성할 관계가 아니다: ${relation.wire}'),
  });
}

/// 파생 체인 diff 한 건(`ledger_diff` 꼴 재료 · 🔴 늘 관측).
class DerivedChainDiff {
  /// 만든다.
  const DerivedChainDiff({
    required this.diffId,
    required this.pair,
    required this.axis,
    required this.severity,
    required this.authoredDate,
    required this.deltaJson,
    required this.label,
    required this.candidates,
  });

  /// `ld-` + 내용 해시 24.
  final String diffId;

  /// 대조 쌍.
  final LedgerPair pair;

  /// 축 = CHAIN_HASH.
  final LedgerAxis axis;

  /// 심각도(파생 = 관측).
  final DiffSeverity severity;

  /// 귀속 날.
  final String authoredDate;

  /// 전후 JSON(금액 0).
  final String deltaJson;

  /// 엔진 문장.
  final String label;

  /// 원인 후보.
  final List<String> candidates;
}

String? _c8(String? chain) => chain?.substring(0, 8);

/// 관계 → 체인 diff(IN_SYNC = null).
DerivedChainDiff? derivedChainDiffOf(
  DerivedTarget target,
  DerivedRelation relation,
  CanonChain canon,
  DerivedStamp? derived,
) {
  if (relation == DerivedRelation.inSync) return null;
  final String date = derived?.authoredDate ?? canon.firstDate!;
  final String? canonChain = canon.chainAt(date);
  final List<String> candidates = switch (relation) {
    DerivedRelation.empty ||
    DerivedRelation.behind => <String>[target.lagOriginCode],
    DerivedRelation.rebased => const <String>[OriginCodes.chainBroken],
    DerivedRelation.ahead => const <String>[OriginCodes.restoreRollback],
    DerivedRelation.diverged || DerivedRelation.epochAhead => const <String>[
      OriginCodes.chainBroken,
      OriginCodes.restoreRollback,
    ],
    DerivedRelation.inSync => const <String>[],
  };
  final String n = target.label;
  final String s = target.subject;
  final String label = switch (relation) {
    DerivedRelation.empty => '$s 비어 있습니다 — 정본 ${canon.firstDate} 부터 채웁니다',
    DerivedRelation.behind =>
      '$s ${derived!.authoredDate} 에 멈춰 있습니다 — 정본 ${canon.lastDate}',
    DerivedRelation.rebased => '$s 새 기준점 전 기록입니다 — 다시 만듭니다',
    DerivedRelation.ahead => '$s 정본보다 앞서 있습니다 — 쓰기를 멈췄습니다',
    DerivedRelation.diverged => '$n 기록이 정본과 다릅니다 — 쓰기를 멈췄습니다',
    DerivedRelation.epochAhead => '$n에 더 새 기기의 기록이 있습니다 — 쓰기를 멈췄습니다',
    DerivedRelation.inSync => '',
  };
  final String deltaJson = jsonEncode(<String, Object?>{
    'target': target.syncTarget,
    'relation': relation.wire,
    'canon_date': canon.lastDate,
    'canon_chain8': _c8(canonChain),
    'derived_date': derived?.authoredDate,
    'derived_chain8': _c8(derived?.chainHash),
    'canon_epoch': canon.operatorEpoch,
    'derived_epoch': derived?.operatorEpoch,
    'candidates': candidates,
  });
  final String key =
      '${target.pair.wire}|$date|${relation.wire}|${_c8(derived?.chainHash) ?? '-'}|${_c8(canonChain) ?? '-'}';
  return DerivedChainDiff(
    diffId:
        'ld-${sha256.convert(utf8.encode(key)).toString().substring(0, 24)}',
    pair: target.pair,
    axis: LedgerAxis.chainHash,
    severity: diffSeverityFor(target.pair, LedgerAxis.chainHash),
    authoredDate: date,
    deltaJson: deltaJson,
    label: label,
    candidates: candidates,
  );
}
