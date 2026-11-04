// 정본 자가 무결성 — 체인 자가 대조(SPEC v2.40 04 §3-1 «`LEDGER_INTEGRITY` 를 세우는 조건» ① · 설계 13 §8 R58 C2 · C3).
//
// 🔴 대상 = 스탬프된 **모든 날**(체크포인트 뒤만이 아니다 — 지난날 소급 수정을 잡는 것이 목적).
// 🔴 마지막 스탬프 뒤에 귀속되는 행 = 아직 스탬프 전 → 대상 밖. 첫 스탬프 **앞** 날의 행 = 소급 삽입 → 불일치.
// 🔴 이 판정은 **세우기만** 한다 — 해제는 X5-3 원장 정정(E16) 뿐이다.

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart' show hashFormatVersion;

import 'ledger_hash.dart';

/// 제안 알림 코드(P0 · 계약 = E13i1 — 그때까지 문자열로 싣는다).
const String kLedgerIntegrityAlertCode = 'LEDGER_INTEGRITY_BROKEN';

/// 불일치 사유(R58 C2 · C3).
enum LedgerIntegrityReason {
  /// 스탬프의 직렬화 형식 판이 현행과 다르다.
  formatVersion('FORMAT_VERSION'),

  /// 스탬프 날이 달력일로 이어지지 않는다(스탬프 행이 빠졌다).
  dateGap('DATE_GAP'),

  /// 체인 칸이 앞 체인 ‖ day_hash 와 다르다.
  chainBroken('CHAIN_BROKEN'),

  /// 지금 원장으로 다시 센 day_hash 가 스탬프와 다르다.
  dayHashMismatch('DAY_HASH_MISMATCH'),

  /// 첫 스탬프 앞 날에 귀속되는 행이 있다(소급 삽입).
  rowsBeforeFirstStamp('ROWS_BEFORE_FIRST_STAMP'),

  /// 🔴 행을 날에 귀속하지 못했다 — 다시 셀 수 없으면 일치를 말할 수 없다(fail-closed).
  attribution('ATTRIBUTION'),

  /// `PRAGMA integrity_check` 가 `ok` 가 아니다.
  sqliteIntegrity('SQLITE_INTEGRITY');

  const LedgerIntegrityReason(this.code);

  /// 기록 표기.
  final String code;
}

/// `ledger_daily_hash` 한 행.
class StoredDayStamp {
  /// 행을 만든다.
  const StoredDayStamp({
    required this.authoredDate,
    required this.dayHash,
    required this.chainHash,
    required this.hashFormatVersion,
  });

  /// 귀속 날(한국 날짜 `YYYY-MM-DD`).
  final String authoredDate;

  /// 저장된 day_hash · chain_hash.
  final String dayHash, chainHash;

  /// 저장된 형식 판.
  final int hashFormatVersion;
}

/// 자가 대조 결과.
class LedgerIntegrityVerdict {
  /// 통과.
  const LedgerIntegrityVerdict.ok({
    required this.daysChecked,
    required this.checkedThrough,
  }) : reason = null,
       firstBadDate = null;

  /// 불일치.
  const LedgerIntegrityVerdict.failed(
    LedgerIntegrityReason this.reason, {
    this.firstBadDate,
    required this.daysChecked,
    this.checkedThrough,
  });

  /// 불일치 사유(통과 = null).
  final LedgerIntegrityReason? reason;

  /// 처음 어긋난 날(모름 = null).
  final String? firstBadDate;

  /// 대조한 스탬프 날 수.
  final int daysChecked;

  /// 대조한 마지막 스탬프 날(스탬프 0 = null).
  final String? checkedThrough;

  /// 통과했나.
  bool get ok => reason == null;

  /// `reconciliation_log.discrepancies` JSON — 🔴 날 · 사유 · 날 수만(금액 0).
  String summaryJson() => jsonEncode(<String, Object?>{
    'kind': 'LEDGER_INTEGRITY',
    'ok': ok,
    'reason': reason?.code,
    'first_bad_date': firstBadDate,
    'days_checked': daysChecked,
    'checked_through': checkedThrough,
  });
}

String _nextDay(String yyyyMmDd) {
  final DateTime d = DateTime.parse('${yyyyMmDd}T00:00:00Z');
  return DateTime.utc(
    d.year,
    d.month,
    d.day + 1,
  ).toIso8601String().substring(0, 10);
}

/// 체인 자가 대조(R58 C2) — [stamps] = 날 오름차순 · [linesByDay] = 지금 원장의 날 → 표 → 정규 줄.
LedgerIntegrityVerdict verifyLedgerChain(
  List<StoredDayStamp> stamps,
  Map<String, Map<String, List<String>>> linesByDay, {
  int formatVersion = hashFormatVersion,
}) {
  if (stamps.isEmpty) {
    return const LedgerIntegrityVerdict.ok(
      daysChecked: 0,
      checkedThrough: null,
    );
  }
  final String first = stamps.first.authoredDate;
  final List<String> before = <String>[
    for (final String d in linesByDay.keys)
      if (d.compareTo(first) < 0) d,
  ]..sort();
  if (before.isNotEmpty) {
    return LedgerIntegrityVerdict.failed(
      LedgerIntegrityReason.rowsBeforeFirstStamp,
      firstBadDate: before.first,
      daysChecked: 0,
    );
  }
  String previousChain = kChainGenesis;
  for (int i = 0; i < stamps.length; i++) {
    final StoredDayStamp s = stamps[i];
    LedgerIntegrityVerdict fail(LedgerIntegrityReason r, [String? day]) =>
        LedgerIntegrityVerdict.failed(
          r,
          firstBadDate: day ?? s.authoredDate,
          daysChecked: i,
          checkedThrough: i == 0 ? null : stamps[i - 1].authoredDate,
        );
    if (s.hashFormatVersion != formatVersion) {
      return fail(LedgerIntegrityReason.formatVersion);
    }
    if (i > 0) {
      final String expected = _nextDay(stamps[i - 1].authoredDate);
      if (s.authoredDate != expected) {
        return fail(LedgerIntegrityReason.dateGap, expected);
      }
    }
    final String recount = dayHashOf(
      linesByDay[s.authoredDate] ?? const <String, List<String>>{},
    );
    if (recount != s.dayHash) {
      return fail(LedgerIntegrityReason.dayHashMismatch);
    }
    // dayHash = 방금 다시 센 값 · previousChain = 창세값 또는 앞 날에서 검증된 값 — 둘 다 16진 64자다.
    if (chainHashOf(previousChain, s.dayHash) != s.chainHash) {
      return fail(LedgerIntegrityReason.chainBroken);
    }
    previousChain = s.chainHash;
  }
  return LedgerIntegrityVerdict.ok(
    daysChecked: stamps.length,
    checkedThrough: stamps.last.authoredDate,
  );
}
