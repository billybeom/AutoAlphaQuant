// M2-9 · M3-5 — 세후 사다리 DTO(`AfterTaxLadder`) 조립. 01 §2-4 · §15-4-5 · C-30 · C-41 ⑦.
//
// 🔴 표시의 정본은 엔진이 만든 글자(`valueText` · `noteLine` · 갈래 라벨)다 — 화면은 수치를 포맷하지 않는다(C-30 ⓑ).
//    `cagrPct` · `endMult` 는 골든 대조 전용 값(4자리)이고 글자는 그 값의 둘째 자리 반올림이다(C-30 ⓚ).
// 🔴 §8 미결 18(외부 현금흐름 보정판) 확정 전에는 **늘 골든 참고 사다리**다 — `isReferenceOnly = true` ·
//    `referenceOnlyLabel` non-null(C-41 ⑦). 실계좌 세후를 «실측»으로 표기하지 않는다.
// 🔴 갈래는 계좌 배치가 정한다(SAF-309) — 이 함수는 받은 갈래로 조립만 한다(고르는 쪽은 계좌 매핑 읽기 경로).
// 🔵 문장은 계약 픽스처 `fixtures/m7/aftertax_ladder_1.json`(정본 갈래 · 반사실 38.5%)과 글자까지 같다.
//    픽스처에 없는 두 반사실 갈래(26.4% · 종합과세 없음)의 라벨은 같은 꼴로 지었다.

import 'package:domain_contracts/domain_contracts.dart';

import '../numeric/pandas_compat.dart';
import 'after_tax.dart';

/// 정직 기대 = 16.5% 인출 층 − 낙관 감액(%p) — F회차 «계절 게이트 ×0.5 0.26 + KOSDAQ150 프록시 0.21»
/// (tax_lib `assumption` 문장 · 06 M2-9 ⓒ ③).
const double kHonestHaircutPctPoints = 0.47;

const Map<TaxLadderBranch, String> _branchLabels = <TaxLadderBranch, String>{
  TaxLadderBranch.specPotTaxFree: '연금저축 안에서 굴리는 갈래',
  TaxLadderBranch.cfPotTaxableComp26: '반사실 — 파킹을 일반계좌에서 굴리고 종합과세 26.4% 구간이었다면',
  TaxLadderBranch.cfPotTaxableComp38: '반사실 — 파킹을 일반계좌에서 굴리고 종합과세 38.5% 구간이었다면',
  TaxLadderBranch.cfPotTaxableFlat: '반사실 — 파킹을 일반계좌에서 굴렸다면(종합과세 없이)',
};

const Map<String, String> _stepLabels = <String, String>{
  AfterTaxStepCodes.pretax: '세금 전',
  AfterTaxStepCodes.afterPot: '파킹 과세 뒤',
  AfterTaxStepCodes.afterPotC: '방어 자산 과세까지 뒤',
  AfterTaxStepCodes.wd5p5: '연금 수령 5.5% 뒤',
  AfterTaxStepCodes.wd16p5: '연금 외 수령 16.5% 뒤',
  AfterTaxStepCodes.honest: '정직 기대',
};

/// 층 코드 → 골든 층 키(«정직 기대»는 골든에 없다).
const Map<String, String> _pointKeys = <String, String>{
  AfterTaxStepCodes.pretax: 'pretax',
  AfterTaxStepCodes.afterPot: 'after_pot',
  AfterTaxStepCodes.afterPotC: 'after_pot_c',
  AfterTaxStepCodes.wd5p5: 'wd_5p5',
  AfterTaxStepCodes.wd16p5: 'wd_16p5',
};

const String _pretaxNote = '백테스트 점추정입니다. 앞으로의 약속이 아닙니다.';
const String _specAfterPotNote = '이 갈래는 파킹을 절세계좌에 두어 세금 전과 같습니다.';
const String _comprehensiveNote = '연 실현이익이 종합과세 구간에 드는 몫의 세금도 이 층에서 뺍니다.';
const String _honestNote = '지연·비용·규칙 실패를 반영한 값입니다. 점추정보다 낮습니다.';
const String _referenceOnlyLabel = '골든 참고치입니다. 실계좌로 산출한 값이 아닙니다.';

/// 세후 사다리 한 갈래를 조립한다 — 층 순서 = `AfterTaxStepCodes` 사전 순서(C-30 ⓖ).
AfterTaxLadder buildAfterTaxLadder(
  AfterTaxFull full,
  TaxLadderBranch branch, {
  required AsOf asOf,
  required String configHash,
}) {
  final AfterTaxBranch b =
      full.branches[branch] ??
      (throw ArgumentError.value(branch, 'branch', '세후 계산에 없는 갈래'));
  final bool spec = branch == TaxLadderBranch.specPotTaxFree;
  final bool comprehensive = kTaxLadderBranchRates[branch]!.$2 != null;
  double pct(String key) => pyRound(b.points[key]!.cagrPct, 4);
  double mult(String key) => pyRound(b.points[key]!.endMult, 4);
  String yearly(double pct4) => '연 ${pct4.toStringAsFixed(2)}%';

  final List<AfterTaxStep> steps = <AfterTaxStep>[];
  for (final String code in AfterTaxStepCodes.values) {
    final String? key = _pointKeys[code];
    if (key == null) {
      // 정직 기대 — 16.5% 인출 층에서 낙관 감액을 뺀 «안팎» 값(점값이 아니다 · 대조 값 없음).
      final double honest = pct('wd_16p5') - kHonestHaircutPctPoints;
      steps.add(
        AfterTaxStep(
          stepCode: code,
          label: _stepLabels[code]!,
          valueText: '연 ${honest.toStringAsFixed(1)}% 안팎',
          noteLine: _honestNote,
        ),
      );
      continue;
    }
    final String? note = switch (code) {
      AfterTaxStepCodes.pretax => _pretaxNote,
      AfterTaxStepCodes.afterPot when spec => _specAfterPotNote,
      AfterTaxStepCodes.afterPotC when comprehensive => _comprehensiveNote,
      AfterTaxStepCodes.wd5p5 || AfterTaxStepCodes.wd16p5 =>
        '세액공제 환급을 합치면 ${yearly(pct('${key}_refund_nominal'))}, '
            '환급을 다시 투자하면 ${yearly(pct('${key}_refund_reinvested'))}입니다.',
      _ => null,
    };
    steps.add(
      AfterTaxStep(
        stepCode: code,
        label: _stepLabels[code]!,
        valueText: yearly(pct(key)),
        cagrPct: pct(key),
        endMult: mult(key),
        noteLine: note,
      ),
    );
  }
  return AfterTaxLadder(
    branch: branch,
    branchLabel: _branchLabels[branch]!,
    steps: steps,
    honestExpectationLine: spec
        ? '정직 기대는 점추정보다 낮게 잡아 둔 값입니다.'
        : '반사실은 비교용이며 지금 계좌 배치의 결과가 아닙니다.',
    basisNote: spec ? '세율 가정과 계좌 배치는 엔진 설정에서 옵니다.' : '계좌 배치가 갈래를 정합니다.',
    // §8 미결 18 확정 전 — 늘 골든 참고치(C-41 ⑦ · SIM 에서도 같다 · 01 §9-4).
    isReferenceOnly: true,
    referenceOnlyLabel: _referenceOnlyLabel,
    configHash: configHash,
    asOf: asOf,
  );
}
