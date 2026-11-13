// 🆕 E15a — 모드 조합 가드 · 기동 판정(설계 13 §8 R81 V1~V5 · SPEC v2.44 04 §3-1 v2.44 ①② · 01 §10-2 칸별).

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const RunMode _si = RunMode.simInternal;
const RunMode _sb = RunMode.simBroker;
const RunMode _lv = RunMode.live;
const OperatingMode _auto = OperatingMode.autoTrade;
const OperatingMode _adv = OperatingMode.advisory;
const ExecPolicy _ex = ExecPolicy.execute;
const ExecPolicy _dry = ExecPolicy.dryRun;

/// 01 §10-2 표 #1~#12(문서 차례 그대로).
const List<(RunMode, OperatingMode, ExecPolicy, ModeCell)> _table =
    <(RunMode, OperatingMode, ExecPolicy, ModeCell)>[
      (_si, _auto, _ex, ModeCell.allowed),
      (_si, _auto, _dry, ModeCell.denied),
      (_si, _adv, _ex, ModeCell.allowed),
      (_si, _adv, _dry, ModeCell.denied),
      (_sb, _auto, _ex, ModeCell.allowed),
      (_sb, _auto, _dry, ModeCell.denied),
      (_sb, _adv, _ex, ModeCell.denied),
      (_sb, _adv, _dry, ModeCell.denied),
      (_lv, _auto, _dry, ModeCell.allowed),
      (_lv, _auto, _ex, ModeCell.allowed),
      (_lv, _adv, _ex, ModeCell.allowed),
      (_lv, _adv, _dry, ModeCell.conditional),
    ];

ModeStartupGate _gate({
  RunMode run = _lv,
  OperatingMode op = _auto,
  ExecPolicy exec = _ex,
  bool session = false,
  int? approved = 1,
  bool envOk = true,
  bool keys = true,
}) => modeStartupGate(
  runMode: run,
  operatingMode: op,
  execPolicy: exec,
  handoverSessionValid: session,
  approved: approved,
  credentialEnvironmentOk: envOk,
  liveKeysVerified: keys,
);

String? _reject(
  RunMode run,
  OperatingMode op,
  ExecPolicy exec, {
  bool session = false,
  bool keys = true,
}) => orderJobModeReject(
  runMode: run,
  operatingMode: op,
  execPolicy: exec,
  facts: ModeFacts(handoverSessionValid: session, liveKeysVerified: keys),
);

void main() {
  group('12칸 판정(01 §10-2 칸별 · R81 V1)', () {
    test('칸별 판정 = 문서 표 #1~#12 · 세 축의 곱 전수 · 허용 6 · 금지 5 · 조건부 1', () {
      expect(
        _table.length,
        RunMode.values.length *
            OperatingMode.values.length *
            ExecPolicy.values.length,
      );
      for (final (RunMode r, OperatingMode o, ExecPolicy e, ModeCell c)
          in _table) {
        expect(
          modeCombinationCell(r, o, e),
          c,
          reason: '${r.wire}×${o.wire}×${e.wire}',
        );
      }
      final List<ModeCell> cells = <ModeCell>[
        for (final (RunMode r, OperatingMode o, ExecPolicy e, ModeCell _)
            in _table)
          modeCombinationCell(r, o, e),
      ];
      expect(cells.where((ModeCell c) => c == ModeCell.allowed), hasLength(6));
      expect(cells.where((ModeCell c) => c == ModeCell.denied), hasLength(5));
      expect(
        cells.where((ModeCell c) => c == ModeCell.conditional),
        hasLength(1),
      );
    });

    test('허용 여부 — 조건부(#12)만 세션에 달림 · 허용 · 금지는 세션과 무관', () {
      for (final (RunMode r, OperatingMode o, ExecPolicy e, ModeCell c)
          in _table) {
        for (final bool session in <bool>[false, true]) {
          final bool want = switch (c) {
            ModeCell.allowed => true,
            ModeCell.denied => false,
            ModeCell.conditional => session,
          };
          expect(
            modeCombinationAllowed(r, o, e, handoverSessionValid: session),
            want,
            reason: '${r.wire}×${o.wire}×${e.wire} 세션 $session',
          );
        }
      }
    });

    test('실키 대기 hold = live ∧ 자동 매매 ∧ 미검증만', () {
      expect(liveAwaitingKeys(_lv, _auto, liveKeysVerified: false), isTrue);
      expect(liveAwaitingKeys(_lv, _auto, liveKeysVerified: true), isFalse);
      expect(liveAwaitingKeys(_lv, _adv, liveKeysVerified: false), isFalse);
      expect(liveAwaitingKeys(_si, _auto, liveKeysVerified: false), isFalse);
      expect(liveAwaitingKeys(_sb, _auto, liveKeysVerified: false), isFalse);
    });
  });

  group('기동 판정(R81 V3 · 04 §3-1 v2.44 ①)', () {
    test('다 맞음 = 기동 · 사유 0 · hold 0', () {
      final ModeStartupGate g = _gate();
      expect(g.start, isTrue);
      expect(g.triggered, isEmpty);
      expect(g.holds, isEmpty);
    });

    test('SAF-405 · 조합 · 자격증명 환경 = 각각 거부 · 셋 다 = 차례 고정', () {
      expect(_gate(approved: 0).triggered, <String>[kSaf405]);
      expect(_gate(approved: 0).start, isFalse);
      expect(_gate(exec: _dry, op: _adv).triggered, <String>[
        kModeCombinationDenied,
      ]);
      expect(_gate(envOk: false).triggered, <String>[kCredentialEnvMismatch]);
      expect(_gate(envOk: false).start, isFalse);
      final ModeStartupGate all = _gate(
        approved: null,
        op: _adv,
        exec: _dry,
        envOk: false,
      );
      expect(all.start, isFalse);
      expect(all.triggered, <String>[
        kSaf405,
        kModeCombinationDenied,
        kCredentialEnvMismatch,
      ]);
    });

    test('#12 = 세션 있으면 기동 · 모의 = SAF-405 무관 · 모의 금지 칸 = 거부', () {
      expect(_gate(op: _adv, exec: _dry, session: true).start, isTrue);
      expect(_gate(run: _si, approved: null).start, isTrue);
      final ModeStartupGate sim = _gate(run: _si, exec: _dry, approved: null);
      expect(sim.start, isFalse);
      expect(sim.triggered, <String>[kModeCombinationDenied]);
    });

    test('🔴 실키 대기 = hold(기동은 한다) · 안내 모드 · 모의 = hold 0', () {
      final ModeStartupGate g = _gate(keys: false);
      expect(g.start, isTrue);
      expect(g.triggered, isEmpty);
      expect(g.holds, <String>{SafetyHoldCodes.liveAwaitingKeys});
      expect(_gate(keys: false, op: _adv).holds, isEmpty);
      expect(_gate(keys: false, run: _si).holds, isEmpty);
    });
  });

  group('주문 잡 앞 판정(R81 V4)', () {
    test('금지 칸 = 조합 거부(실키 대기보다 먼저) · 허용 칸 = null', () {
      for (final (RunMode r, OperatingMode o, ExecPolicy e, ModeCell c)
          in _table) {
        expect(
          _reject(r, o, e),
          c == ModeCell.allowed ? isNull : kModeCombinationDenied,
          reason: '${r.wire}×${o.wire}×${e.wire}',
        );
      }
      expect(_reject(_sb, _adv, _ex, keys: false), kModeCombinationDenied);
      expect(_reject(_lv, _adv, _dry, keys: false), kModeCombinationDenied);
    });

    test('#12 + 세션 = 통과 · 실키 대기 = LIVE_AWAITING_KEYS(자동 매매만)', () {
      expect(_reject(_lv, _adv, _dry, session: true), isNull);
      expect(
        _reject(_lv, _auto, _ex, keys: false),
        SafetyHoldCodes.liveAwaitingKeys,
      );
      expect(
        _reject(_lv, _auto, _dry, keys: false),
        SafetyHoldCodes.liveAwaitingKeys,
      );
      expect(_reject(_lv, _adv, _ex, keys: false), isNull);
      expect(_reject(_si, _auto, _ex, keys: false), isNull);
    });

    test('거부 예외는 코드를 지닌다', () {
      const ModeGuardRejected e = ModeGuardRejected(kModeCombinationDenied);
      expect(e.code, 'MODE_COMBINATION_DENIED');
      expect(e.toString(), 'ModeGuardRejected(MODE_COMBINATION_DENIED)');
      expect(kCredentialEnvMismatch, 'CREDENTIAL_ENV_MISMATCH');
    });
  });
}
