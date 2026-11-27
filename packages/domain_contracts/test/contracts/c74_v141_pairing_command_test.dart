// C-74 뷰어 페어링 RPC · 명령 표 읽는 함수 · 배치 D 명령 표 정정 — 01 §50
// (🆕 계약 v1.41 · 발주자 위임 2026-11-14 — 권고대로 · K360~ · 01 §8 미결 246 · 178 · 156 · 182 · 01 §10-8 G-26 · 13 §8 R272 Y1~Y4).
//
// 정의: 「페어링 쓰는 RPC 3(security definer · 리스 반환 글자) · 읽는 함수 2(invoker) · 인자 = 리스 · 넘김 티켓 글자 재사용 ·
//        거부 = 리스 공용 2 ∪ 고유 3 · runMode 불일치 거부 1 · 서버 판정 상태 글자 카탈로그 2 · 뷰어 명령 TTL 4 ·
//        배치 D: 표 `pairing_ticket`(해시만 · 정책 0) · `command_queue` 맥락 3칸 not null + check · 두 INSERT 정책 `requested_at = now()` ·
//        `command_ack(command_id)` 색인」.
//   ① 판 · 표본 ② 이름 ③ 인자 ④ 반환 칸 ⑤ 거부 사전 · 도메인 ⑥ 배치 D 티켓 표 ⑦ 배치 D 명령 표 ⑧ 카탈로그 · TTL · 상한 ⑨ 글자 꼴.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

String _batchD() =>
    File('${ddlDir.path}/batch_d_supabase.sql').readAsStringSync();

/// 주석(`-- …` 줄 끝까지)을 뺀 배치 D.
String _batchDCode() => _batchD().replaceAll(RegExp(r'--[^\n]*'), '');

/// 표 하나의 `create table` 본문(주석 뺌 · 괄호 안).
String _tableBody(String table) {
  final RegExpMatch? m = RegExp(
    'create table if not exists $table \\(([\\s\\S]*?)\\n\\);',
  ).firstMatch(_batchDCode());
  expect(m, isNotNull, reason: table);
  return m!.group(1)!;
}

/// 표 본문의 열 이름(차례 그대로 · 제약 줄 뺌).
List<String> _columnsOf(String table) => <String>[
  for (final String line in _tableBody(table).split('\n'))
    if (RegExp(
      r'^\s+([a-z_]+)\s+(text|uuid|jsonb|bigint|int|integer|timestamptz|date)\b',
    ).hasMatch(line))
      RegExp(r'^\s+([a-z_]+)').firstMatch(line)!.group(1)!,
];

/// 표 하나에 걸린 정책 문장(`create policy … on <표> …;`) 전부.
List<String> _policiesOn(String table) =>
    RegExp('create policy (\\w+) on $table\\b[^;]*;')
        .allMatches(_batchDCode())
        .map((RegExpMatch m) => m.group(0)!.replaceAll(RegExp(r'\s+'), ' '))
        .toList();

void main() {
  group('C-74 뷰어 페어링 · 명령 표 읽기 (01 §50)', () {
    // 🔵 v1.42(01 §51) — 판 글자 · 수 고정 = 최신 창 시험(C-75 ①)만 · 여기는 «1.41.0 이상 · 402 이상 · 봉투 판 = 계약 판».
    test('C-74 ① 판 · 표본 — 1.41.0 이상 · 402 이상(버전 줄만) · 봉투 판 = 계약 판', () {
      expect(contractVersion, isNot(anyOf('1.39.0', '1.40.0')));
      expect(FixturePaths.all.length, greaterThanOrEqualTo(402));
      expect(allFixtureFilesOnDisk().length, FixturePaths.all.length);
      for (final String path in FixturePaths.all) {
        final Map<String, Object?> meta =
            (jsonDecode(readFixture(path)) as Map<String, Object?>)['meta']!
                as Map<String, Object?>;
        expect(meta['contract_version'], contractVersion, reason: path);
      }
    });

    test(
      'C-74 ② 이름 — 페어링 3 · 읽기 2 · 서로 · 리스 · 넘김 · rm_push · op_push 와 겹침 0',
      () {
        expect(PairingRpcNames.values, <String>{
          'pairing_ticket_issue',
          'pairing_claim',
          'pairing_revoke',
        });
        expect(CommandReadRpcNames.values, <String>{
          'command_open',
          'command_status',
        });
        final List<Set<String>> families = <Set<String>>[
          LeaseRpcNames.values,
          LeaseHandoverRpcNames.values,
          ReadModelPushRpcNames.values,
          OpsPushRpcNames.values,
          PairingRpcNames.values,
          CommandReadRpcNames.values,
        ];
        final List<String> all = <String>[
          for (final Set<String> f in families) ...f,
        ];
        expect(all.toSet(), hasLength(all.length), reason: 'RPC 이름 겹침 0');
        // 🔵 R272 초안 `device_revoke` → `pairing_revoke`(K362 — `device_retire` 와 헷갈림 0 · 대상 = 뷰어만).
        expect(all, isNot(contains('device_revoke')));
      },
    );

    test('C-74 ③ 인자 — 리스 · 넘김 티켓 글자 재사용 · 새 글자 3 · 읽기 2 · 전부 p_', () {
      expect(PairingRpcParams.values, <String>{
        'p_device_id',
        'p_epoch',
        'p_ticket_nonce_hash',
        'p_ticket_ttl_minutes',
        'p_ticket_nonce',
        'p_label',
        'p_platform',
        'p_target_device_id',
      });
      expect(PairingRpcParams.deviceId, LeaseRpcParams.deviceId);
      expect(PairingRpcParams.epoch, LeaseRpcParams.epoch);
      expect(
        PairingRpcParams.ticketNonceHash,
        LeaseHandoverRpcParams.ticketNonceHash,
      );
      expect(
        PairingRpcParams.ticketTtlMinutes,
        LeaseHandoverRpcParams.ticketTtlMinutes,
      );
      expect(PairingRpcParams.ticketNonce, LeaseHandoverRpcParams.ticketNonce);
      expect(CommandReadRpcParams.values, <String>{'p_limit', 'p_command_ids'});
      for (final String p in <String>{
        ...PairingRpcParams.values,
        ...CommandReadRpcParams.values,
      }) {
        expect(p, matches(RegExp(r'^p_[a-z_]+$')));
        // 서버가 정하는 칸(소유자 · 상태 · 역할 · 시각)은 인자가 아니다.
        for (final String server in <String>[
          'owner',
          'status',
          'role',
          'auth_uid',
          'expires_at',
          'requested_at',
        ]) {
          expect(p, isNot(contains(server)), reason: '$p · $server');
        }
      }
    });

    test('C-74 ④ 반환 칸 — 쓰는 셋 = 리스 반환 글자 · command_open = command_queue 열 차례 · command_status 6', () {
      expect(PairingRpcColumns.values, LeaseRpcColumns.values);
      expect(PairingRpcColumns.code, LeaseRpcColumns.code);
      expect(PairingRpcColumns.expiresAt, LeaseRpcColumns.expiresAt);
      expect(CommandOpenColumns.all, _columnsOf('command_queue'));
      expect(CommandStatusColumns.all, <String>[
        'command_id',
        'state',
        'state_label',
        'reject_reason_code',
        'decision_id',
        'acked_at',
      ]);
      // ack 칸 이름 = 배치 D command_ack 열 이름 그대로(command_id · ack 넷).
      final List<String> ack = _columnsOf('command_ack');
      for (final String c in CommandStatusColumns.all) {
        expect(ack, contains(c), reason: c);
      }
    });

    test(
      'C-74 ⑤ 거부 — 페어링 고유 3 · runMode 1 · 도메인 등재 · 다른 사전과 서로소 · 리스 공용 2 재사용',
      () {
        expect(PairingRpcResultCodes.values, <String>{
          'PAIRING_TICKET_INVALID',
          'PAIRING_TICKET_EXPIRED',
          'PAIRING_DEVICE_NOT_ELIGIBLE',
        });
        expect(
          ContractCodes.byDomain['pairing_rpc_result'],
          PairingRpcResultCodes.values,
        );
        expect(CommandContextRejectCodes.values, <String>{'RUN_MODE_MISMATCH'});
        expect(
          ContractCodes.byDomain['command_context_reject'],
          CommandContextRejectCodes.values,
        );
        for (final String c in <String>{
          ...PairingRpcResultCodes.values,
          ...CommandContextRejectCodes.values,
        }) {
          expect(ContractCodes.domainsOf(c), hasLength(1), reason: c);
        }
        expect(
          PairingRpcResultCodes.values.intersection(<String>{
            ...LeaseRpcResultCodes.values,
            ...LeaseHandoverResultCodes.values,
            ...ReadModelPushResultCodes.values,
            ...OpsPushResultCodes.values,
          }),
          isEmpty,
        );
        // 폐기된 뒤 뷰어 거부 = 온보딩 사전(V-01) — 이 사전 밖.
        expect(
          PairingRpcResultCodes.values,
          isNot(contains(OnboardingResultCodes.pairingTokenRevoked)),
        );
        // runMode 불일치(거부) ≠ X7 운영 방식 불일치 · 닫힌 원장.
        expect(
          CommandContextRejectCodes.runModeMismatch,
          isNot(
            anyOf(
              AdviceRejectCodes.operatingModeMismatch,
              LedgerWriteGateCodes.ledgerClosed,
            ),
          ),
        );
        expect(
          LeaseRpcResultCodes.values,
          containsAll(<String>[
            LeaseRpcResultCodes.lost,
            LeaseRpcResultCodes.deviceNotEligible,
          ]),
        );
      },
    );

    test('C-74 ⑥ 배치 D 티켓 표 — 소유자당 1행 · 해시만(16진 64 check) · 낸 기기 참조 · RLS 켬 · 정책 0 · 서명 주석', () {
      expect(_columnsOf('pairing_ticket'), <String>[
        'owner_uid',
        'ticket_hash',
        'issued_by_device',
        'issued_at',
        'expires_at',
      ]);
      final String body = _tableBody('pairing_ticket');
      expect(
        body,
        contains(
          'owner_uid         uuid primary key references auth.users(id),',
        ),
      );
      expect(
        body,
        contains(
          r"ticket_hash       text not null check (ticket_hash ~ '^[0-9a-f]{64}$'),",
        ),
      );
      expect(
        body,
        contains(
          'issued_by_device  text not null references app_device(device_id),',
        ),
      );
      expect(body, contains('expires_at        timestamptz not null'));
      // 평문 칸 0.
      expect(body, isNot(contains('nonce')));
      expect(body, isNot(contains('secret')));
      expect(
        _batchDCode(),
        contains('alter table pairing_ticket enable row level security;'),
      );
      expect(
        _policiesOn('pairing_ticket'),
        isEmpty,
        reason: '클라이언트 정책 0(select 포함)',
      );
      // 표는 app_device 뒤(참조) · 리스 · 복구 표 뒤 · 명령 표 앞.
      final String d = _batchD();
      expect(
        d.indexOf('create table if not exists pairing_ticket ('),
        greaterThan(d.indexOf('create table if not exists recovery_secret (')),
      );
      expect(
        d.indexOf('create table if not exists pairing_ticket ('),
        lessThan(d.indexOf('create table if not exists command_queue (')),
      );
      // RPC 서명 주석 — 이름 · 인자 글자가 계약 그대로.
      expect(
        d,
        contains(
          '${PairingRpcNames.ticketIssue} (${PairingRpcParams.deviceId} text, ${PairingRpcParams.epoch} bigint, '
          '${PairingRpcParams.ticketNonceHash} text, ${PairingRpcParams.ticketTtlMinutes} int)',
        ),
      );
      expect(
        d,
        contains(
          '${PairingRpcNames.claim} (${PairingRpcParams.ticketNonce} text, ${PairingRpcParams.deviceId} text, '
          '${PairingRpcParams.label} text, ${PairingRpcParams.platform} text)',
        ),
      );
      expect(
        d,
        contains(
          '${PairingRpcNames.revoke} (${PairingRpcParams.deviceId} text, ${PairingRpcParams.epoch} bigint, '
          '${PairingRpcParams.targetDeviceId} text)',
        ),
      );
    });

    test('C-74 ⑦ 배치 D 명령 표 — 맥락 3칸 not null + check · 두 INSERT 정책 requested_at = now() · 뷰어 4종 = TTL 종류 · ack 색인 · 읽는 함수 주석', () {
      final String q = _tableBody('command_queue');
      expect(
        q,
        contains(
          "run_mode          text not null check (run_mode in ('LIVE','SIM_INTERNAL','SIM_BROKER')),",
        ),
      );
      expect(
        q,
        contains(
          "operating_mode    text not null check (operating_mode in ('AUTO_TRADE','ADVISORY')),",
        ),
      );
      expect(q, contains('lease_epoch       bigint not null,'));
      expect(
        RegExp(r'run_mode in \(([^)]*)\)')
            .firstMatch(q)!
            .group(1)!
            .replaceAll("'", '')
            .split(',')
            .toSet(),
        RunMode.values.map((RunMode m) => m.wire).toSet(),
      );
      expect(
        RegExp(r'operating_mode in \(([^)]*)\)')
            .firstMatch(q)!
            .group(1)!
            .replaceAll("'", '')
            .split(',')
            .toSet(),
        OperatingMode.values.map((OperatingMode m) => m.wire).toSet(),
      );
      // 두 INSERT 정책 = 분리 그대로 · 둘 다 접수 시각 = 서버.
      final List<String> ins = <String>[
        for (final String p in _policiesOn('command_queue'))
          if (p.contains(' for insert ')) p,
      ];
      expect(ins, hasLength(2));
      for (final String p in ins) {
        expect(
          p,
          contains('expires_at > now() and requested_at = now()'),
          reason: p,
        );
      }
      // 뷰어 화이트리스트 4종 = ViewerCommandTtl.kinds(차례 그대로).
      final String viewer = ins.singleWhere(
        (String p) => p.contains('command_insert_viewer'),
      );
      final List<String> kinds = RegExp(r'kind in \(([^)]*)\)')
          .firstMatch(viewer)!
          .group(1)!
          .split(',')
          .map((String k) => k.trim().replaceAll("'", ''))
          .toList();
      expect(
        kinds,
        ViewerCommandTtl.kinds.map((CommandKind k) => k.wire).toList(),
      );
      // ack 색인.
      expect(
        _batchDCode(),
        contains(
          'create index if not exists ix_command_ack_command_id on command_ack(command_id);',
        ),
      );
      // 읽는 함수 서명 주석 · ack 리스 없는 상태 거부 주석.
      final String d = _batchD();
      expect(
        d,
        contains(
          '${CommandReadRpcNames.open} (${CommandReadRpcParams.limit} int) returns setof command_queue',
        ),
      );
      expect(
        d,
        contains(
          '${CommandReadRpcNames.status} (${CommandReadRpcParams.commandIds} uuid[]) returns table (command_id uuid, state text, state_label text, reject_reason_code text,',
        ),
      );
      expect(
        d,
        contains('PENDING_LEASE_CONFIRM` · `NO_OPERATOR` ack 를 받지 않는다'),
      );
      // 명령 표 쓰기 정책 = INSERT 둘뿐(UPDATE · DELETE 0 = append-only).
      expect(
        RegExp(
          r'create policy \w+ on command_(queue|ack) for (update|delete|all)',
        ).hasMatch(_batchDCode()),
        isFalse,
      );
    });

    test(
      'C-74 ⑧ 카탈로그 · TTL · 상한 — 서버 판정 2상태만 글자 · 수치 0 · 뷰어 4종 TTL · 티켓 수명 범위',
      () {
        expect(
          CommandStatusText.of(CommandState.requested),
          CommandStatusText.requested,
        );
        expect(
          CommandStatusText.of(CommandState.noOperator),
          CommandStatusText.noOperator,
        );
        for (final CommandState s in CommandState.values) {
          if (s == CommandState.requested || s == CommandState.noOperator) {
            continue;
          }
          expect(
            CommandStatusText.of(s),
            isNull,
            reason: '${s.wire} — 최신 ack 의 엔진 글자',
          );
        }
        for (final String t in <String>[
          CommandStatusText.requested,
          CommandStatusText.noOperator,
        ]) {
          expect(t.trim(), isNotEmpty);
          expect(RegExp(r'[0-9]').hasMatch(t), isFalse, reason: '수치 0 — $t');
        }
        // G-26 — «요청됨»이 «껐다»로 읽히지 않게 · 받을 기기 없음 = 지금 할 수 있는 길.
        expect(CommandStatusText.requested, contains('처리 전'));
        expect(CommandStatusText.noOperator, contains('증권사 앱'));
        expect(
          CommandStatusText.requested,
          isNot(CommandStatusText.noOperator),
        );

        expect(ViewerCommandTtl.kinds, <CommandKind>[
          CommandKind.killSwitchActivate,
          CommandKind.journalDraft,
          CommandKind.blindReviewScore,
          CommandKind.disclosureView,
        ]);
        for (final CommandKind k in CommandKind.values) {
          final Duration? ttl = ViewerCommandTtl.of(k);
          if (ViewerCommandTtl.kinds.contains(k)) {
            expect(ttl, isNotNull, reason: k.wire);
            expect(
              ttl!,
              greaterThanOrEqualTo(const Duration(days: 1)),
              reason: k.wire,
            );
          } else {
            expect(ttl, isNull, reason: '${k.wire} — 운영 폰 명령 TTL = 엔진 · 운영 설정');
          }
        }
        // 킬스위치 = 가장 길다(늦게 닿아도 멈춤 · 만료 = 침묵).
        for (final CommandKind k in ViewerCommandTtl.kinds) {
          expect(
            ViewerCommandTtl.killSwitchActivate,
            greaterThanOrEqualTo(ViewerCommandTtl.of(k)!),
          );
        }
        expect(ViewerCommandTtl.journalDraft, const Duration(days: 14));

        expect(PairingTicketLimits.ttlMinutesMin, 1);
        expect(
          PairingTicketLimits.ttlMinutesMax,
          greaterThanOrEqualTo(15),
          reason: '182 잠정 15분이 범위 안',
        );
        expect(PairingTicketLimits.ttlMinutesMax, lessThanOrEqualTo(60));
        expect(CommandReadLimits.openMax, greaterThan(0));
      },
    );

    test('C-74 ⑨ 글자 꼴 — 코드 = PAIRING_ · 대문자 snake · 함수 = 소문자 snake', () {
      for (final String c in PairingRpcResultCodes.values) {
        expect(c, matches(RegExp(r'^PAIRING_[A-Z0-9_]+$')));
      }
      for (final String c in CommandContextRejectCodes.values) {
        expect(c, matches(RegExp(r'^[A-Z][A-Z0-9_]+$')));
      }
      for (final String n in <String>{
        ...PairingRpcNames.values,
        ...CommandReadRpcNames.values,
      }) {
        expect(n, matches(RegExp(r'^[a-z][a-z0-9_]+$')));
      }
    });
  });
}
