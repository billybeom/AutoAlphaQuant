// C-19 (01 §7 · §10-2) — 조합 게이트 강제.
//
// 01 §10-2 「허용 조합표 12칸」의 **12행 표를 그대로** 옮겨 순수 함수로 만든 것이
// 아래 [_verdictOf] 다(⚠️ 같은 절 소제목의 «허용 5 · 금지 6» 과 행별 판정이 어긋난다
// — 아래 C-19 ② 의 주석에 사유와 함께 적었다).
//
// 🔴 이 표는 «판정»이 아니라 «문서의 표»다. 거부는 화면이 아니라 엔진이 하고
//    (§10-2), 실제 기동 거부·`MODE_COMBINATION_DENIED` 발행은 엔진 런타임이
//    선행한다(인벤토리 §9 C-19 = 🟡) — 그 갈래는 아래에서 `skip` 한다.
// 🔴 그럼에도 이 표가 여기 있는 이유: **세 축 중 하나라도 값이 늘면 12칸이 아니게
//    되고, 그때 「새 칸은 허용인가 금지인가」를 아무도 묻지 않은 채 코드가
//    통과하는 것**이 이 검사가 막는 사고다. 값이 늘면 ① 이 테스트가 깨지고
//    ② 01 §10-2 를 먼저 고치게 된다 — 코드가 문서를 앞지르지 않는다.

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

/// 01 §10-2 판정 3갈래.
enum _Verdict {
  /// ✅ 허용.
  allowed,

  /// ⛔ 금지 — 기동 거부.
  denied,

  /// 🔴 조건부 — `handover_session_id` 가 있고 유효할 때만.
  conditional,
}

/// 01 §10-2 표 12칸. 🔴 순서·판정은 문서 원문 그대로다.
const Map<String, _Verdict> _table = <String, _Verdict>{
  // 1 · 2 — simInternal × autoTrade
  'SIM_INTERNAL|AUTO_TRADE|EXECUTE': _Verdict.allowed,
  'SIM_INTERNAL|AUTO_TRADE|DRY_RUN': _Verdict.denied,
  // 3 · 4 — simInternal × advisory (모의 안내 연습)
  'SIM_INTERNAL|ADVISORY|EXECUTE': _Verdict.allowed,
  'SIM_INTERNAL|ADVISORY|DRY_RUN': _Verdict.denied,
  // 5 · 6 — simBroker × autoTrade
  'SIM_BROKER|AUTO_TRADE|EXECUTE': _Verdict.allowed,
  'SIM_BROKER|AUTO_TRADE|DRY_RUN': _Verdict.denied,
  // 7 · 8 — simBroker × advisory (정의 모순)
  'SIM_BROKER|ADVISORY|EXECUTE': _Verdict.denied,
  'SIM_BROKER|ADVISORY|DRY_RUN': _Verdict.denied,
  // 9 · 10 — live × autoTrade
  'LIVE|AUTO_TRADE|DRY_RUN': _Verdict.allowed,
  'LIVE|AUTO_TRADE|EXECUTE': _Verdict.allowed,
  // 11 · 12 — live × advisory
  'LIVE|ADVISORY|EXECUTE': _Verdict.allowed,
  'LIVE|ADVISORY|DRY_RUN': _Verdict.conditional,
};

_Verdict? _verdictOf(RunMode run, OperatingMode operating, ExecPolicy exec) =>
    _table['${run.wire}|${operating.wire}|${exec.wire}'];

/// 조건부 칸의 유일한 근거 — 세션 토큰(§10-2 · B20).
bool _startupAllowed(
  RunMode run,
  OperatingMode operating,
  ExecPolicy exec, {
  String? handoverSessionId,
}) {
  final _Verdict? verdict = _verdictOf(run, operating, exec);
  if (verdict == null) {
    // 🔴 표에 없는 칸은 «모름» 이며 fail-closed 다.
    return false;
  }
  return switch (verdict) {
    _Verdict.allowed => true,
    _Verdict.denied => false,
    _Verdict.conditional =>
      handoverSessionId != null && handoverSessionId.isNotEmpty,
  };
}

void main() {
  group('C-19 X7 조합 게이트 (01 §7 · §10-2)', () {
    test('C-19 ① 표는 세 축의 곱 전수를 덮는다 — 12칸', () {
      final int cells =
          RunMode.values.length *
          OperatingMode.values.length *
          ExecPolicy.values.length;
      expect(
        cells,
        12,
        reason: '축의 값이 늘었다 — 01 §10-2 표를 먼저 고치고 이 파일을 따라 고칠 것.',
      );
      expect(_table.length, cells);

      for (final RunMode run in RunMode.values) {
        for (final OperatingMode operating in OperatingMode.values) {
          for (final ExecPolicy exec in ExecPolicy.values) {
            expect(
              _verdictOf(run, operating, exec),
              isNotNull,
              reason: '${run.wire}×${operating.wire}×${exec.wire} 칸의 판정이 없다.',
            );
          }
        }
      }
    });

    test('C-19 ② 판정 분포 — 12칸이 남김없이 갈린다 (§10-2 12행)', () {
      // ⚠️ **문서 안의 불일치를 여기 기록해 둔다(2026-09-08 · T2 발견).**
      //    01 §10-2 의 소제목은 「허용 5 · 금지 6 · 조건부 1」이라고 적었지만,
      //    같은 절의 **12행 표를 세면 허용 6 · 금지 5 · 조건부 1** 이다
      //    (✅ = #1·#3·#5·#9·#10·#11 · ⛔ = #2·#4·#6·#7·#8 · 조건부 = #12).
      //    소제목은 X7 이 #3(모의 안내 연습)을 ✅ 🆕 로 더하기 전의 수로 보인다 —
      //    §9-5 ① 의 「기존 허용 4종」(#1·#5·#9·#10)에 X7 이 #3·#11 을 더한 결과가
      //    허용 6 이기 때문이다.
      // 🔴 이 테스트는 **칸별 판정**(근거가 칸마다 적힌 쪽)을 따른다. 소제목의 수를
      //    따르려면 어느 칸을 뒤집을지부터 문서가 말해야 하고, 그것은 임의 확정이다.
      //    소제목 정정은 계약 문서 담당 몫으로 보고했다.
      int allowed = 0;
      int denied = 0;
      int conditional = 0;
      for (final _Verdict verdict in _table.values) {
        switch (verdict) {
          case _Verdict.allowed:
            allowed++;
          case _Verdict.denied:
            denied++;
          case _Verdict.conditional:
            conditional++;
        }
      }
      expect(allowed, 6);
      expect(denied, 5);
      expect(conditional, 1);
      expect(allowed + denied + conditional, _table.length);
    });

    test('C-19 ③ SIM 계열 × dryRun 은 전량 금지 (§9-5 ① — 「아무 일도 안 일어나는 모의」)', () {
      for (final RunMode run in RunMode.values.where((RunMode m) => m.isSim)) {
        for (final OperatingMode operating in OperatingMode.values) {
          expect(
            _verdictOf(run, operating, ExecPolicy.dryRun),
            _Verdict.denied,
            reason: '${run.wire}×${operating.wire}×DRY_RUN',
          );
        }
      }
    });

    test('C-19 ④ simBroker × advisory 는 두 칸 모두 금지 — 정의 모순 (§10-2 #7·#8)', () {
      // 🔴 `simBroker` 의 존재 이유는 «엔진의 주문 경로 실증»인데 사람이 손매매하면
      //    그 경로를 아무것도 증명하지 않는다.
      for (final ExecPolicy exec in ExecPolicy.values) {
        expect(
          _verdictOf(RunMode.simBroker, OperatingMode.advisory, exec),
          _Verdict.denied,
        );
        expect(
          _startupAllowed(
            RunMode.simBroker,
            OperatingMode.advisory,
            exec,
            handoverSessionId: 'hs_0001',
          ),
          isFalse,
          reason: '세션 토큰이 있어도 금지 칸은 열리지 않는다.',
        );
      }
    });

    test('C-19 ⑤ 조건부 칸은 #12 하나이며 세션 토큰이 없으면 거부다 (B20)', () {
      final List<String> conditionalKeys = _table.entries
          .where(
            (MapEntry<String, _Verdict> e) => e.value == _Verdict.conditional,
          )
          .map((MapEntry<String, _Verdict> e) => e.key)
          .toList();
      expect(conditionalKeys, <String>['LIVE|ADVISORY|DRY_RUN']);

      expect(
        _startupAllowed(
          RunMode.live,
          OperatingMode.advisory,
          ExecPolicy.dryRun,
        ),
        isFalse,
        reason: '세션 밖이면 MODE_COMBINATION_DENIED 다 — 「허용 칸」으로 통과시키지 않는다.',
      );
      expect(
        _startupAllowed(
          RunMode.live,
          OperatingMode.advisory,
          ExecPolicy.dryRun,
          handoverSessionId: 'hs_0001',
        ),
        isTrue,
      );
    });

    test('C-19 ⑥ 거부 사유 코드가 §3-8 사전에 등재되어 있다', () {
      expect(
        AdviceRejectCodes.values,
        contains(AdviceRejectCodes.modeCombinationDenied),
      );
      expect(
        AdviceRejectCodes.modeCombinationDenied,
        'MODE_COMBINATION_DENIED',
      );
    });

    test(
      'C-19 ⑦ 금지 6칸을 config·전환 명령으로 주입 → 기동 거부',
      () {},
      skip: '엔진 런타임(배치 선행 가드)이 선행한다(인벤토리 §9 C-19 = 🟡).',
    );
  });
}
