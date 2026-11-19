// 골든벡터 GV-40d 기동 통제(SAF-405) · GV-40e 재량 예산 원장(SAF-409) — AC-S18 의 d · e 몫 판정
// (E11o-c1 · 설계 13 §8 R164 · R66 Y6 · Y9 · R64 W8).
//
// 🔴 옛 시험(`test/golden/gv40d_startup_test.dart` · `gv40e_discretion_test.dart`)의 판정을 한 글자도 바꾸지 않고 옮겼다.
// 정답지 = gv40_saf_warn.json(파일럿5 원본 통째). 🔵 40d 정답지는 live 기동의 판정이다(04 §1 «미승인 config로 live 실행»)
// — 모의 모드는 discretion 밖이라 rule_change_test 가 본다. 🔵 40e `decision_id` «미연결» = null → `journalLinked: false`.

import 'package:domain_contracts/domain_contracts.dart' show RunMode;

import '../safety/discretion.dart' show DiscretionJudgement, judgeDiscretion;
import '../safety/rule_change.dart' show StartupGate, startupConfigGate;
import 'golden_runner.dart';

List<String> _ids(List<Map<String, Object?>> cases) => <String>[
  for (final Map<String, Object?> c in cases)
    gvString(c['id']).split(' ').first,
];

/// GV-40d 기동 통제 d1~d3.
class Gv40dStartup implements GoldenFamily {
  /// 만든다.
  const Gv40dStartup();

  @override
  String get id => 'GV-40d';

  @override
  Set<String> get files => const <String>{'gv40_saf_warn.json'};

  @override
  List<GvCase> cases(GoldenBundle b) {
    final List<Map<String, Object?>> cases = gvObjectList(
      b.json('gv40_saf_warn.json')['GV-40d'],
    );
    return <GvCase>[
      GvCase(
        'GV-40d = 3건(d1~d3)',
        () => (GvProbe()..same(_ids(cases), <String>['d1', 'd2', 'd3'], 'ids'))
            .failure,
      ),
      for (final Map<String, Object?> c in cases)
        GvCase('GV-40d ${gvString(c['id'])}', () {
          final Object? approved = gvObject(c['input'])['approved'];
          final Map<String, Object?> exp = gvObject(c['expected']);
          final StartupGate g = startupConfigGate(
            runMode: RunMode.live,
            approved: approved == null ? null : gvInt(approved),
          );
          return (GvProbe()
                ..same(
                  g.start ? '기동' : '기동 거부',
                  gvString(exp['action']),
                  'action',
                )
                ..same(
                  g.triggered,
                  gvStringList(exp['triggered']),
                  'triggered',
                ))
              .failure;
        }),
    ];
  }
}

/// GV-40e 재량 예산 원장 e1~e9 — `triggered` · `action` 은 사유가 있느냐로 정해진다(참조 `gv40e_discretion`).
class Gv40eDiscretion implements GoldenFamily {
  /// 만든다.
  const Gv40eDiscretion();

  @override
  String get id => 'GV-40e';

  @override
  Set<String> get files => const <String>{'gv40_saf_warn.json'};

  @override
  List<GvCase> cases(GoldenBundle b) {
    final List<Map<String, Object?>> cases = gvObjectList(
      b.json('gv40_saf_warn.json')['GV-40e'],
    );
    return <GvCase>[
      GvCase(
        'GV-40e = 9건(e1~e9)',
        () =>
            (GvProbe()..same(_ids(cases), <String>[
                  'e1',
                  'e2',
                  'e3',
                  'e4',
                  'e5',
                  'e6',
                  'e7',
                  'e8',
                  'e9',
                ], 'ids'))
                .failure,
      ),
      for (final Map<String, Object?> c in cases)
        GvCase('GV-40e ${gvString(c['id'])}', () {
          final Map<String, Object?> input = gvObject(c['input']);
          final Map<String, Object?> exp = gvObject(c['expected']);
          final DiscretionJudgement j = judgeDiscretion(
            deltaPct: gvDouble(input['delta_pct']),
            journalLinked: input['decision_id'] != null,
            priorUseDates: gvStringList(input['history']),
            today: gvString(input['now']),
          );
          final Map<String, Object?> m = gvObject(exp['metrics']);
          return (GvProbe()
                ..same(
                  j.rejectReasons,
                  gvStringList(exp['reject_reasons']),
                  'reject_reasons',
                )
                ..same(
                  j.applies ? '반영' : '요청 거부',
                  gvString(exp['action']),
                  'action',
                )
                ..same(
                  j.applies ? <String>[] : <String>['SAF-409'],
                  gvStringList(exp['triggered']),
                  'triggered',
                )
                ..same(
                  j.rolling12mCount,
                  gvInt(m['rolling_12m_count']),
                  'rolling_12m_count',
                )
                ..same(j.deltaPct, gvDouble(m['delta_pct']), 'delta_pct'))
              .failure;
        }),
    ];
  }
}
