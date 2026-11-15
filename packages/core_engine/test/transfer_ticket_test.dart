// E16b — X1-2 이전 티켓(설계 13 §8 R117 B6 · SPEC v2.45 04 §3-1 ②).
//
// 🔵 잡는 것: ① 영수증 = RETIRED 끝난 저널에서만(그 앞 · 중단 = 없음) ② 발급 = 6키 · 만료 = 지금 + TTL · 칸 꼴 검사
//    ③ 페이로드 왕복 · 다른 키 · 빠진 키 · 글자 아님 · 시간대 없는 만료 = 거부 ④ 유효 = 신뢰 시각 < 만료 · 모름 = 무효.
import 'dart:convert';

import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

const String _run = 'mig-2026-12-01-1';
final DateTime _t = DateTime.utc(2026, 12, 1, 3);
final String _sha = 'a' * 64;
final String _chain = 'b' * 64;
const String _nonce = 'n0nce_ABCDEFGHIJKLMNOPQRS';

MigrationStepRow _r(PlanStep s, MigrationStepState st) =>
    MigrationStepRow(runId: _run, step: s.wire, state: st.wire, atUtc: _t);

List<MigrationStepRow> _doneThrough(PlanStep upTo) => <MigrationStepRow>[
  for (final PlanStep s in PlanStep.values.take(
    upTo.index + 1,
  )) ...<MigrationStepRow>[
    _r(s, MigrationStepState.entered),
    _r(s, MigrationStepState.done),
  ],
];

DemotionReceipt _receipt() =>
    demotionReceiptOf(planProgressOf(_run, _doneThrough(PlanStep.retired)))!;

TransferTicket _issue({
  String? sha,
  String? chain,
  String date = '2026-11-30',
  String nonce = _nonce,
  Duration ttl = const Duration(minutes: 15),
}) => TransferTicket.issue(
  _receipt(),
  backupSha256: sha ?? _sha,
  chainHash: chain ?? _chain,
  authoredDate: date,
  nonce: nonce,
  trustedNowUtc: _t,
  ttl: ttl,
);

void main() {
  test('🔴 영수증 = RETIRED 끝난 저널에서만 — 그 앞 · 들어가기만 · 중단 = 없음', () {
    expect(
      demotionReceiptOf(
        planProgressOf(_run, _doneThrough(PlanStep.keysDeleted)),
      ),
      isNull,
    );
    expect(
      demotionReceiptOf(
        planProgressOf(_run, <MigrationStepRow>[
          ..._doneThrough(PlanStep.keysDeleted),
          _r(PlanStep.retired, MigrationStepState.entered),
        ]),
      ),
      isNull,
    );
    expect(
      demotionReceiptOf(
        planProgressOf(_run, <MigrationStepRow>[
          _r(PlanStep.freeze, MigrationStepState.entered),
          _r(PlanStep.freeze, MigrationStepState.failed),
        ]),
      ),
      isNull,
    );
    expect(_receipt().runId, _run);
    expect(
      demotionReceiptOf(
        planProgressOf(_run, _doneThrough(PlanStep.ticketIssued)),
      )!.runId,
      _run,
    );
  });

  test('🔴 발급 — 페이로드 = 정확히 6키 · id = xt-{이전} · 만료 = 신뢰 시각 + TTL', () {
    final TransferTicket t = _issue();
    final Map<String, Object?> j =
        jsonDecode(t.toPayload()) as Map<String, Object?>;
    expect(j.keys.toList(), kTransferTicketKeys);
    expect(j, <String, Object?>{
      'id': 'xt-$_run',
      'sha256': _sha,
      'chain': _chain,
      'date': '2026-11-30',
      'nonce': _nonce,
      'exp': '2026-12-01T03:15:00.000Z',
    });
    expect(t.expiresAtUtc, DateTime.utc(2026, 12, 1, 3, 15));
  });

  test('발급 칸 꼴 — TTL 0 · sha · chain · 날 · 논스', () {
    expect(() => _issue(ttl: Duration.zero), throwsArgumentError);
    expect(() => _issue(sha: 'A' * 64), throwsArgumentError);
    expect(() => _issue(chain: 'b' * 63), throwsArgumentError);
    expect(() => _issue(date: '2026-11-3'), throwsArgumentError);
    expect(() => _issue(nonce: 'short'), throwsArgumentError);
    expect(() => _issue(nonce: '${'x' * 22}!'), throwsArgumentError);
  });

  test('페이로드 왕복', () {
    final TransferTicket t = _issue();
    final TransferTicket back = TransferTicket.parse(t.toPayload());
    expect(
      (
        back.ticketId,
        back.backupSha256,
        back.chainHash,
        back.authoredDate,
        back.nonce,
        back.expiresAtUtc,
      ),
      (t.ticketId, _sha, _chain, '2026-11-30', _nonce, t.expiresAtUtc),
    );
  });

  test('🔴 페이로드 거부 — 다른 키(시크릿) · 빠진 키 · 글자 아님 · 시간대 없는 만료 · 객체 아님', () {
    Map<String, Object?> base() =>
        jsonDecode(_issue().toPayload()) as Map<String, Object?>;
    String enc(Map<String, Object?> m) => jsonEncode(m);
    expect(
      () => TransferTicket.parse(enc(base()..['appKey'] = 'x')),
      throwsFormatException,
    );
    expect(
      () => TransferTicket.parse(enc(base()..remove('nonce'))),
      throwsFormatException,
    );
    expect(
      () => TransferTicket.parse(enc(base()..['date'] = 20261130)),
      throwsFormatException,
    );
    expect(
      () => TransferTicket.parse(enc(base()..['exp'] = '2026-12-01T03:15:00')),
      throwsFormatException,
    );
    expect(
      () => TransferTicket.parse(enc(base()..['id'] = 'mig-1')),
      throwsFormatException,
    );
    expect(() => TransferTicket.parse('[]'), throwsFormatException);
  });

  test('🔴 유효 = 신뢰 시각 < 만료 · 모름 · 만료 시각 · 뒤 = 무효', () {
    final TransferTicket t = _issue();
    expect(transferTicketValid(t, null), isFalse);
    expect(
      transferTicketValid(t, DateTime.utc(2026, 12, 1, 3, 14, 59)),
      isTrue,
    );
    expect(transferTicketValid(t, DateTime.utc(2026, 12, 1, 3, 15)), isFalse);
    expect(transferTicketValid(t, DateTime.utc(2026, 12, 1, 4)), isFalse);
  });
}
