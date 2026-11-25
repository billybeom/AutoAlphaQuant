// E11m-a — 운영 폰 명령 소비기 순수 몫(설계 13 §8 R274 · R272 Y4~Y6 · 01 §10-8 · 계약 v1.41 §50).
//
// 지키는 것: command_open 행 꼴(계약 `CommandOpenColumns`) · 갈래(뷰어 4종만 · 실행 모드 불일치 = 거부 · 만료 = 신뢰 시각 · 킬스위치 예외 ·
// 와이어 꼴 아님 = INPUT_INVALID) · 지문 = 폰이 직접 낸 명령과 같은 식 · ack id = (명령 · 상태)에서 정해짐 · ack 행 = 서버가 덮는 칸 0.

import 'dart:convert';
import 'dart:math';

import 'package:core_engine/core_engine.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

final DateTime _t0 = DateTime.utc(2026, 12, 10, 1);

Map<String, Object?> _row({
  String id = '11111111-2222-4333-8444-555555555555',
  String kind = 'KILL_SWITCH_ACTIVATE',
  Object? payload = const <String, Object?>{},
  String runMode = 'LIVE',
  String operatingMode = 'AUTO_TRADE',
  Object? epoch = 3,
  String requested = '2026-12-10T00:59:00.123456+00:00',
  String expires = '2026-12-24T00:59:00+00:00',
}) => <String, Object?>{
  'command_id': id,
  'kind': kind,
  'payload': payload,
  'issued_by_device': 'viewer-ios-1',
  'nonce': 'n' * 32,
  'requested_at': requested,
  'expires_at': expires,
  'owner_uid': 'uid-owner',
  'run_mode': runMode,
  'operating_mode': operatingMode,
  'lease_epoch': epoch,
};

RemoteCommand _cmd(Map<String, Object?> row) => remoteCommandOf(row)!;

RemoteCommandRoute _route(
  Map<String, Object?> row, {
  RunMode mode = RunMode.live,
  DateTime? now,
}) => routeRemoteCommand(_cmd(row), runMode: mode, trustedNowUtc: now ?? _t0);

const JournalDraft _draft = JournalDraft(
  decisionId: 'J-1',
  rationaleBefore: '근거',
  expectedOutcome: '기대',
  ruleCited: JournalRuleCitedCodes.reconCause,
);

void main() {
  group('행 꼴(command_open = command_queue 행)', () {
    test('계약 CommandOpenColumns 열 그대로 읽는다 · 시각 = UTC', () {
      final Map<String, Object?> row = _row();
      expect(row.keys.toList(), CommandOpenColumns.all);
      final RemoteCommand c = _cmd(row);
      expect(
        (
          c.commandId,
          c.kind,
          c.issuedByDevice,
          c.runMode,
          c.operatingMode,
          c.leaseEpoch,
          c.requestedAt,
          c.expiresAt.isUtc,
        ),
        (
          '11111111-2222-4333-8444-555555555555',
          CommandKind.killSwitchActivate,
          'viewer-ios-1',
          RunMode.live,
          OperatingMode.autoTrade,
          3,
          DateTime.utc(2026, 12, 10, 0, 59, 0, 123, 456),
          true,
        ),
      );
      expect(c.toString(), isNot(contains('viewer-ios-1')));
    });

    test(
      '꼴 아님 = null(빈 id · 종류 · 기기 · nonce · 시차 없는 시각 · 본문 객체 아님 · epoch 정수 아님)',
      () {
        for (final MapEntry<String, Object?> bad in <MapEntry<String, Object?>>[
          const MapEntry<String, Object?>('command_id', ''),
          const MapEntry<String, Object?>('command_id', null),
          const MapEntry<String, Object?>('kind', null),
          const MapEntry<String, Object?>('issued_by_device', ''),
          const MapEntry<String, Object?>('nonce', null),
          const MapEntry<String, Object?>(
            'requested_at',
            '2026-12-10T00:59:00',
          ),
          const MapEntry<String, Object?>('expires_at', 'nope'),
          const MapEntry<String, Object?>('payload', '{}'),
          const MapEntry<String, Object?>('payload', <Object?>[]),
          const MapEntry<String, Object?>('lease_epoch', '3'),
        ]) {
          final Map<String, Object?> row = _row()..[bad.key] = bad.value;
          expect(
            remoteCommandOf(row),
            isNull,
            reason: '${bad.key}=${bad.value}',
          );
        }
        // epoch 없음 = 읽는다(감사용 · 기록 셋은 null 로 남긴다).
        expect(remoteCommandOf(_row(epoch: null))?.leaseEpoch, isNull);
      },
    );
  });

  group('갈래', () {
    test('뷰어 4종 밖(운영 폰 종류 · 모르는 종류) = 소비 0 — 🔴 실행 모드가 달라도 거부 ack 를 쓰지 않는다(소비 0 이 먼저)', () {
      for (final CommandKind k in CommandKind.values) {
        final RemoteCommandRoute r = _route(_row(kind: k.wire));
        expect(
          r is RemoteCommandSkip,
          !ViewerCommandTtl.kinds.contains(k),
          reason: k.wire,
        );
        if (!ViewerCommandTtl.kinds.contains(k)) {
          expect(
            _route(_row(kind: k.wire, runMode: 'SIM_INTERNAL')),
            isA<RemoteCommandSkip>(),
            reason: '${k.wire} 다른 모드',
          );
        }
      }
      expect(_route(_row(kind: 'SOMETHING_NEW')), isA<RemoteCommandSkip>());
      expect(
        _route(_row(kind: 'SOMETHING_NEW', runMode: 'SIM_BROKER')),
        isA<RemoteCommandSkip>(),
      );
    });

    test('🔴 실행 모드 불일치 = 예외 없이 거부(킬스위치 포함 · 모르는 글자도 다름)', () {
      for (final (String kind, String mode, RunMode now)
          in <(String, String, RunMode)>[
            ('KILL_SWITCH_ACTIVATE', 'SIM_INTERNAL', RunMode.live),
            ('DISCLOSURE_VIEW', 'LIVE', RunMode.simBroker),
            ('JOURNAL_DRAFT', 'PAPER', RunMode.live),
          ]) {
        final RemoteCommandRoute r = _route(
          _row(kind: kind, runMode: mode),
          mode: now,
        );
        expect(r, isA<RemoteCommandRefuse>(), reason: '$kind $mode');
        r as RemoteCommandRefuse;
        expect(
          (r.state, r.reasonCode, r.stateLabel),
          (
            CommandState.rejected,
            CommandContextRejectCodes.runModeMismatch,
            RemoteCommandTexts.runModeMismatch,
          ),
        );
      }
    });

    test('만료 = 신뢰 시각으로만 · 같은 시각 = 만료 · 모르면 만료 아님 · 🔴 킬스위치는 만료로 버리지 않는다', () {
      final Map<String, Object?> view = _row(
        kind: 'DISCLOSURE_VIEW',
        payload: DisclosureViewEvent(
          surfaceCode: DisclosureSurfaceCodes.values.first,
          viewedAt: DateTime.utc(2026, 12, 10, 0, 58),
        ).toJson(),
        expires: '2026-12-10T01:00:00Z',
      );
      final RemoteCommandRoute at = _route(view, now: _t0);
      expect(at, isA<RemoteCommandRefuse>());
      at as RemoteCommandRefuse;
      expect(
        (at.state, at.reasonCode, at.stateLabel),
        (CommandState.expired, null, RemoteCommandTexts.expired),
      );
      expect(
        _route(view, now: _t0.subtract(const Duration(seconds: 1))),
        isA<RemoteDisclosureView>(),
      );
      expect(
        routeRemoteCommand(
          _cmd(view),
          runMode: RunMode.live,
          trustedNowUtc: null,
        ),
        isA<RemoteDisclosureView>(),
      );
      expect(
        _route(_row(expires: '2026-11-01T00:00:00Z'), now: _t0),
        isA<RemoteKillSwitch>(),
      );
    });

    test('기록 셋 = 운영 방식 모름 → INPUT_INVALID · 킬스위치 = 운영 방식 없이 집행', () {
      final RemoteCommandRoute j = _route(
        _row(
          kind: 'JOURNAL_DRAFT',
          payload: _draft.toJson(),
          operatingMode: 'PAPER',
        ),
      );
      expect(j, isA<RemoteCommandRefuse>());
      expect(
        (j as RemoteCommandRefuse).reasonCode,
        AdviceRejectCodes.inputInvalid,
      );
      expect(_route(_row(operatingMode: 'PAPER')), isA<RemoteKillSwitch>());
    });

    test('와이어 → 처리기 인자 · 꼴 아님 = INPUT_INVALID(저널 칸 빠짐 · 점수 꼴 · 모르는 열람 화면)', () {
      final RemoteCommandRoute j = _route(
        _row(kind: 'JOURNAL_DRAFT', payload: _draft.toJson()),
      );
      expect((j as RemoteJournalDraft).draft, _draft);
      final RemoteCommandRoute b = _route(
        _row(
          kind: 'BLIND_REVIEW_SCORE',
          payload: const BlindReviewScore(
            decisionId: 'D1',
            answers: <String, int>{'PIT_INPUT': 1},
          ).toJson(),
        ),
      );
      expect((b as RemoteBlindReviewScore).score.answers, <String, int>{
        'PIT_INPUT': 1,
      });
      for (final (String kind, Map<String, Object?> payload)
          in <(String, Map<String, Object?>)>[
            ('JOURNAL_DRAFT', <String, Object?>{'decision_id': 'J-1'}),
            (
              'BLIND_REVIEW_SCORE',
              <String, Object?>{'decision_id': 'D1', 'answers': 'x'},
            ),
            (
              'DISCLOSURE_VIEW',
              DisclosureViewEvent(
                surfaceCode: 'NOT_A_SURFACE',
                viewedAt: DateTime.utc(2026, 12, 10, 0, 58),
              ).toJson(),
            ),
            (
              'DISCLOSURE_VIEW',
              <String, Object?>{
                'surface_code': DisclosureSurfaceCodes.values.first,
              },
            ),
          ]) {
        final RemoteCommandRoute r = _route(_row(kind: kind, payload: payload));
        expect(r, isA<RemoteCommandRefuse>(), reason: '$kind $payload');
        r as RemoteCommandRefuse;
        expect(
          (r.state, r.reasonCode, r.stateLabel),
          (
            CommandState.rejected,
            AdviceRejectCodes.inputInvalid,
            RemoteCommandTexts.inputInvalid,
          ),
        );
      }
    });

    test('지문 = 폰이 직접 낸 명령과 같은 식(수신함 payload_digest 가 길에 따라 갈리지 않는다)', () {
      final JournalDraftCommand phone = issueJournalDraft(
        draft: _draft,
        nowUtc: _t0,
        deviceId: 'op',
        random: Random(1),
      );
      final RemoteCommandRoute j = _route(
        _row(kind: 'JOURNAL_DRAFT', payload: _draft.toJson()),
      );
      expect((j as RemoteJournalDraft).payloadDigest, phone.payloadDigest);
      const BlindReviewScore score = BlindReviewScore(
        decisionId: 'D1',
        answers: <String, int>{'A': 1, 'B': 0},
      );
      final BlindReviewScoreCommand phoneScore = issueBlindReviewScore(
        score: score,
        nowUtc: _t0,
        deviceId: 'op',
        random: Random(1),
      );
      final RemoteCommandRoute b = _route(
        _row(kind: 'BLIND_REVIEW_SCORE', payload: score.toJson()),
      );
      expect(
        (b as RemoteBlindReviewScore).payloadDigest,
        phoneScore.payloadDigest,
      );
      final RemoteCommandRoute k = _route(_row());
      expect(
        (k as RemoteKillSwitch).payloadDigest,
        issueKillCommand(
          payload: const <String, Object?>{},
          random: Random(1),
        ).payloadDigest,
      );
      expect(
        remotePayloadDigest(const <String, Object?>{'a': 1}),
        sha256.convert(utf8.encode('{"a":1}')).toString(),
      );
    });
  });

  group('ack', () {
    final RegExp uuid = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-8[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    test('ack id = (명령 · 상태)에서 정해지는 uuid 꼴 — 같은 것끼리 같고 하나라도 다르면 다르다', () {
      const String a = '11111111-2222-4333-8444-555555555555';
      const String b = '11111111-2222-4333-8444-555555555556';
      final Set<String> ids = <String>{};
      for (final CommandState s in CommandState.values) {
        final String id = commandAckId(a, s);
        expect(id, matches(uuid), reason: s.wire);
        expect(commandAckId(a, s), id);
        ids.add(id);
        ids.add(commandAckId(b, s));
      }
      expect(ids, hasLength(CommandState.values.length * 2));
    });

    test('ack 행 = 서버가 덮는 칸(lease_epoch · acked_at) 0 · 🔴 서버 판정 · 리스 없는 상태 = 만들지 않는다', () {
      final Map<String, Object?> r = commandAckRow(
        commandId: 'c1',
        state: CommandState.rejected,
        stateLabel: '거부됨',
        rejectReasonCode: 'X',
        decisionId: 'D',
      );
      expect(r.keys.toSet(), <String>{
        'ack_id',
        'command_id',
        'state',
        'state_label',
        'reject_reason_code',
        'decision_id',
      });
      expect(
        (r['ack_id'], r['state']),
        (commandAckId('c1', CommandState.rejected), 'REJECTED'),
      );
      for (final CommandState s in <CommandState>[
        CommandState.requested,
        CommandState.noOperator,
        CommandState.pendingLeaseConfirm,
      ]) {
        expect(
          () => commandAckRow(commandId: 'c1', state: s, stateLabel: 'x'),
          throwsArgumentError,
          reason: s.wire,
        );
      }
    });
  });
}
