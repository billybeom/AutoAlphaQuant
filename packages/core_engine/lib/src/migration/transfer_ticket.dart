// X1-2 이전 티켓(QR 페이로드 · 순수 · 설계 13 §8 R117 B6 · SPEC v2.45 04 §3-1 ② · 02 §4 `ticket_ttl_minutes`).
//
// 🔴 강등 전에는 티켓을 만들 수 없다 — [DemotionReceipt] 는 RETIRED 가 끝난 저널에서만 생긴다(생성자 비공개).
// 🔴 페이로드 = 정확히 6키(티켓 id · 백업 sha256 · chain · authored 날 · 논스 · 만료) — 다른 키 = 거부(시크릿 0).
// 🔴 유효 = 신뢰 시각 < 만료 · 모르면 무효 · TTL = 인자(값 = 설정 · lib 리터럴 0).

import 'dart:convert';

import 'migration_plan.dart' show PlanProgress, PlanStep;

final RegExp _hex64 = RegExp(r'^[0-9a-f]{64}$');
final RegExp _day = RegExp(r'^\d{4}-\d{2}-\d{2}$');
final RegExp _nonce = RegExp(r'^[A-Za-z0-9_-]{22,128}$');

/// 강등 영수증 — 🔴 [demotionReceiptOf] 로만 생긴다.
final class DemotionReceipt {
  const DemotionReceipt._(this.runId);

  /// 강등이 끝난 이전.
  final String runId;
}

/// 🔴 RETIRED 가 끝났을 때만 영수증 · 아니면 null.
DemotionReceipt? demotionReceiptOf(PlanProgress p) =>
    p.failed == null && p.isDone(PlanStep.retired)
    ? DemotionReceipt._(p.runId)
    : null;

/// 이전 티켓 페이로드 키(정확히 이 여섯).
const List<String> kTransferTicketKeys = <String>[
  'id',
  'sha256',
  'chain',
  'date',
  'nonce',
  'exp',
];

/// 이전 티켓.
final class TransferTicket {
  TransferTicket._({
    required this.ticketId,
    required this.backupSha256,
    required this.chainHash,
    required this.authoredDate,
    required this.nonce,
    required this.expiresAtUtc,
  }) {
    if (!ticketId.startsWith('xt-') || ticketId.length < 4) {
      throw ArgumentError.value(ticketId, 'id', '티켓 id 꼴');
    }
    if (!_hex64.hasMatch(backupSha256)) {
      throw ArgumentError.value(backupSha256.length, 'sha256', '16진 64');
    }
    if (!_hex64.hasMatch(chainHash)) {
      throw ArgumentError.value(chainHash.length, 'chain', '16진 64');
    }
    if (!_day.hasMatch(authoredDate)) {
      throw ArgumentError.value(authoredDate, 'date', '날 꼴');
    }
    if (!_nonce.hasMatch(nonce)) {
      throw ArgumentError.value(nonce.length, 'nonce', 'base64url 22~128');
    }
    if (!expiresAtUtc.isUtc) {
      throw ArgumentError.value(expiresAtUtc, 'exp', 'UTC');
    }
  }

  /// 🔴 강등 영수증이 있어야 만든다 — 만료 = [trustedNowUtc] + [ttl].
  factory TransferTicket.issue(
    DemotionReceipt receipt, {
    required String backupSha256,
    required String chainHash,
    required String authoredDate,
    required String nonce,
    required DateTime trustedNowUtc,
    required Duration ttl,
  }) {
    if (ttl <= Duration.zero) {
      throw ArgumentError.value(ttl, 'ttl', '0 보다 커야');
    }
    return TransferTicket._(
      ticketId: 'xt-${receipt.runId}',
      backupSha256: backupSha256,
      chainHash: chainHash,
      authoredDate: authoredDate,
      nonce: nonce,
      expiresAtUtc: trustedNowUtc.toUtc().add(ttl),
    );
  }

  /// 페이로드 → 티켓 — 🔴 키가 정확히 여섯이 아니면 [FormatException].
  factory TransferTicket.parse(String payload) {
    final Object? j = jsonDecode(payload);
    if (j is! Map<String, Object?>) {
      throw const FormatException('이전 티켓이 객체가 아니다');
    }
    final Set<String> keys = j.keys.toSet();
    if (keys.length != kTransferTicketKeys.length ||
        !keys.containsAll(kTransferTicketKeys)) {
      throw FormatException('이전 티켓 키가 다르다', keys.toList()..sort());
    }
    String str(String k) {
      final Object? v = j[k];
      if (v is! String) throw FormatException('이전 티켓 $k 가 글자가 아니다');
      return v;
    }

    final DateTime exp = DateTime.parse(str('exp'));
    try {
      return TransferTicket._(
        ticketId: str('id'),
        backupSha256: str('sha256'),
        chainHash: str('chain'),
        authoredDate: str('date'),
        nonce: str('nonce'),
        expiresAtUtc: exp,
      );
    } on ArgumentError catch (e) {
      throw FormatException('이전 티켓 칸이 틀렸다: ${e.name}');
    }
  }

  /// 티켓 id(`xt-{이전 id}`).
  final String ticketId;

  /// 백업 스냅숏 sha256.
  final String backupSha256;

  /// 백업 매니페스트 체인.
  final String chainHash;

  /// 백업의 마지막 authored 날.
  final String authoredDate;

  /// 리스 클레임 논스.
  final String nonce;

  /// 만료(UTC).
  final DateTime expiresAtUtc;

  /// QR 페이로드 — 키 차례 고정 · 6키.
  String toPayload() => jsonEncode(<String, String>{
    'id': ticketId,
    'sha256': backupSha256,
    'chain': chainHash,
    'date': authoredDate,
    'nonce': nonce,
    'exp': expiresAtUtc.toIso8601String(),
  });
}

/// 🔴 티켓이 지금 유효한가 — 신뢰 시각 모름 = 무효 · 만료 시각 이상 = 무효.
bool transferTicketValid(TransferTicket t, DateTime? trustedNowUtc) =>
    trustedNowUtc != null && trustedNowUtc.toUtc().isBefore(t.expiresAtUtc);
