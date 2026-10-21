// M3-2 계획 스냅샷의 «입력 원값» — `plan_snapshot.inputs` JSON v1(설계 13 §8 R22 D2 · 02 §2-9 배치 B).
//
// 🔴 계획(outputs)은 `DepositPlan.toJson()` 그대로 저장하고, 여기에는 **그 계획을 계산한 원값만** 담는다 —
//    가격 · 슬리브 값 · 연금 누계 · 계좌 별칭 · `config_hash` · as-of. «계획 대비 실제»(E7b3)가 «그때 무엇을 보고
//    계산했나»를 되짚는 앵커다(DDL 주석 «가격·환율·config_hash·계좌 매핑»).
// 🔴 환율은 `null` 이다 — P0S 는 국내상장 ETF 만 거래한다(자리만 둔다).
// 🔴 키 순서를 정렬해 같은 상태 = 같은 JSON 이 되게 한다(Decimal 은 문자열 · `toString()` 그대로).

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show AsOfSource, SleeveId, TradeDate;

import 'what_if_state.dart';

/// 계획 스냅샷의 입력 원값(JSON v1).
final class PlanInputs {
  const PlanInputs({
    required this.configHash,
    required this.asOfTradeDate,
    required this.observedAt,
    required this.source,
    required this.prices,
    required this.sleeveValues,
    required this.pensionUsedThisYear,
    required this.pensionAlias,
    required this.generalAlias,
  });

  /// [s] 에서 계획 계산에 쓴 원값만 뽑는다.
  factory PlanInputs.of(WhatIfState s) => PlanInputs(
    configHash: s.configHash,
    asOfTradeDate: s.asOfTradeDate,
    observedAt: s.observedAt.toUtc(),
    source: s.source,
    prices: Map<String, Decimal>.unmodifiable(s.prices),
    sleeveValues: Map<SleeveId, Decimal>.unmodifiable(s.sleeveValues),
    pensionUsedThisYear: s.pensionUsedThisYear,
    pensionAlias: s.accounts.pensionAlias,
    generalAlias: s.accounts.generalAlias,
  );

  /// JSON 판 번호 — 모양을 바꾸면 올린다(옛 행은 옛 판으로 읽는다).
  static const int version = 1;

  final String configHash;
  final TradeDate asOfTradeDate;
  final DateTime observedAt;
  final AsOfSource source;
  final Map<String, Decimal> prices;
  final Map<SleeveId, Decimal> sleeveValues;
  final Decimal pensionUsedThisYear;
  final String? pensionAlias;
  final String? generalAlias;

  Map<String, Object?> toJson() => <String, Object?>{
    'v': version,
    'config_hash': configHash,
    'as_of': <String, Object?>{
      'trade_date': asOfTradeDate.yyyyMmDd,
      'observed_at': observedAt.toUtc().toIso8601String(),
      'source': source.wire,
    },
    'prices': <String, String>{
      for (final String k in prices.keys.toList()..sort())
        k: prices[k]!.toString(),
    },
    'sleeve_values': <String, String>{
      for (final SleeveId k
          in sleeveValues.keys.toList()
            ..sort((SleeveId a, SleeveId b) => a.wire.compareTo(b.wire)))
        k.wire: sleeveValues[k]!.toString(),
    },
    'pension_used_this_year': pensionUsedThisYear.toString(),
    'accounts': <String, Object?>{
      'pension': pensionAlias,
      'general': generalAlias,
    },
    'fx': null,
  };

  /// [toJson] 의 역. 판 번호가 다르면 [FormatException] — 모르는 모양을 추측해 읽지 않는다.
  factory PlanInputs.fromJson(Map<String, Object?> j) {
    if (j['v'] != version) {
      throw FormatException(
        'plan_snapshot.inputs 판 ${j['v']} — $version 만 읽는다',
      );
    }
    final Map<String, Object?> asOf = (j['as_of']! as Map)
        .cast<String, Object?>();
    final Map<String, Object?> accounts = (j['accounts']! as Map)
        .cast<String, Object?>();
    return PlanInputs(
      configHash: j['config_hash']! as String,
      asOfTradeDate: TradeDate(asOf['trade_date']! as String),
      observedAt: DateTime.parse(asOf['observed_at']! as String).toUtc(),
      source: AsOfSource.values.firstWhere(
        (AsOfSource v) => v.wire == asOf['source'],
      ),
      prices: <String, Decimal>{
        for (final MapEntry<String, Object?> e
            in (j['prices']! as Map).cast<String, Object?>().entries)
          e.key: Decimal.parse(e.value! as String),
      },
      sleeveValues: <SleeveId, Decimal>{
        for (final MapEntry<String, Object?> e
            in (j['sleeve_values']! as Map).cast<String, Object?>().entries)
          SleeveId.values.firstWhere((SleeveId v) => v.wire == e.key):
              Decimal.parse(e.value! as String),
      },
      pensionUsedThisYear: Decimal.parse(
        j['pension_used_this_year']! as String,
      ),
      pensionAlias: accounts['pension'] as String?,
      generalAlias: accounts['general'] as String?,
    );
  }
}
