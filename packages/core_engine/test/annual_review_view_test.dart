// E11q-q5a — M7 S7-7 연간 리뷰 VM · S7-10 이행 갭 결과(설계 13 §8 R220 · 01 §15-4 · K24 · K25).
//
// 🔴 표본 `m7/m7_annual_2026` · `_offwindow` · `_first_year` · `execution_gap_not_applicable` · `_empty` 와 DTO 째로 같다 ·
//    연도 · 창 = S12 목차와 같은 함수(목차가 말한 해 = 본문의 해) · 세후 골든 사본 = `golden_p0s.json` 과 같다.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _fx = '../domain_contracts/fixtures/m7';

Map<String, Object?> _row(String file) =>
    ((jsonDecode(File('$_fx/$file').readAsStringSync())
                    as Map<String, Object?>)['rows']!
                as List<Object?>)
            .first!
        as Map<String, Object?>;

AnnualReviewVm _annual(String file) => AnnualReviewVm.fromJson(_row(file));

/// 표본 기준 시각(as_of observed_at · 한국 2026-08-31 18:00).
final DateTime _asOfNow = DateTime.utc(2026, 8, 31, 9);

const String _cfg = 'cfg_fake_0000000000000000';

bool _all(String _) => true;
bool _none(String _) => false;

AnnualReviewVm _vm({
  required DateTime? trusted,
  int? first,
  DateTime? now,
  bool Function(String)? hasBody,
  String? year,
}) => annualReviewVmOf(
  trustedNowUtc: trusted,
  nowUtc: now ?? _asOfNow,
  firstOperatingYear: first,
  configHash: _cfg,
  hasBody: hasBody ?? _all,
  year: year,
);

void main() {
  group('VM = 표본 그대로(섹션 · 글자 · 세후 두 갈래 · 기준)', () {
    test('OPEN — 신뢰 시각 12월 = 그해 · A 행 = 탐색 링크', () {
      expect(
        _vm(trusted: DateTime.utc(2026, 12, 3), first: 2025),
        _annual('m7_annual_2026.json'),
      );
    });

    test('CLOSED — 12월 밖 = 지난해(끝난 해 · 운영 첫 해와 같아도 닫힘)', () {
      expect(
        _vm(trusted: _asOfNow, first: 2025),
        _annual('m7_annual_offwindow.json'),
      );
    });

    test('FIRST_YEAR — 지난해가 운영 첫 해 앞 = 그해 · 첫 해 문장 · 링크 0', () {
      expect(
        _vm(trusted: _asOfNow, first: 2026),
        _annual('m7_annual_first_year.json'),
      );
      expect(
        _vm(trusted: _asOfNow),
        _annual('m7_annual_first_year.json'),
        reason: '운영 첫 해 모름 = 운영 전 = 첫 해(S12 와 같다)',
      );
    });
  });

  group('A 행 링크 = 탐색 본문이 등록됐을 때만', () {
    test('등록 안 됨 = 링크 0(나머지는 표본 그대로)', () {
      final AnnualReviewVm got = _vm(
        trusted: DateTime.utc(2026, 12, 3),
        first: 2025,
        hasBody: _none,
      );
      final AnnualReviewVm want = _annual('m7_annual_2026.json');
      expect(got.sections.map((AnnualReviewSection s) => s.route), <String?>[
        null,
        null,
        null,
        null,
      ]);
      expect(got.copyWith(sections: want.sections), want, reason: '링크만 빠진다');
    });

    test('물은 라우트 = 탐색 하나', () {
      final List<String> asked = <String>[];
      _vm(
        trusted: DateTime.utc(2026, 12, 3),
        first: 2025,
        hasBody: (String r) {
          asked.add(r);
          return true;
        },
      );
      expect(asked.toSet(), <String>{AppRoutes.performanceExplore});
    });
  });

  group('연도 · 창 = S12 목차와 같은 함수', () {
    final List<(DateTime?, int?)> cases = <(DateTime?, int?)>[
      (DateTime.utc(2026, 12, 3), 2025),
      (DateTime.utc(2026, 12, 3), 2026),
      (DateTime.utc(2026, 12, 3), null),
      (DateTime.utc(2026, 11, 30, 15), 2026), // 한국 12-01 00:00
      (DateTime.utc(2026, 12, 31, 15), 2026), // 한국 2027-01-01
      (DateTime.utc(2027, 3, 2), 2026),
      (DateTime.utc(2027, 3, 2), 2027),
      (DateTime.utc(2028, 6, 1), 2026),
      (null, 2025),
      (null, 2026),
      (null, null),
    ];
    for (final (DateTime? trusted, int? first) in cases) {
      test('신뢰 $trusted · 첫 해 $first — 연도 줄 · 창 글자가 목차와 같다', () {
        final AnnualReviewVm vm = _vm(trusted: trusted, first: first);
        final AnnualReviewIndexVm idx = annualReviewIndexVmOf(
          AnnualReviewIndexFacts(
            trustedNowUtc: trusted,
            firstOperatingYear: first,
            hasBody: _all,
            nowUtc: _asOfNow,
          ),
        );
        expect(vm.yearLabel, idx.yearLabel);
        expect(vm.windowStateLabel, idx.windowStateLabel);
        expect(vm.yearLabel, contains(vm.year), reason: 'C-41 ⑥');
      });
    }

    test(
      '창이 열린 12월 = 운영 첫 해 · 운영 전(모름)이어도 그해 OPEN · 열림 섹션(K24 · S12 와 같다)',
      () {
        for (final int? first in <int?>[2026, null]) {
          final AnnualReviewVm vm = _vm(
            trusted: DateTime.utc(2026, 12, 3),
            first: first,
          );
          expect(
            (vm.year, vm.windowStateCode),
            ('2026', AnnualReviewCodes.open),
            reason: '$first',
          );
          expect(
            vm.sections,
            _annual('m7_annual_2026.json').sections,
            reason: '$first',
          );
        }
      },
    );

    test('신뢰 시각 모름 = UNKNOWN · S12 글자 · 연도 = 기기 시각 · OPEN 을 지어내지 않는다', () {
      final AnnualReviewVm vm = _vm(
        trusted: null,
        first: 2025,
        now: DateTime.utc(2026, 12, 3),
      );
      expect(vm.windowStateCode, AnnualReviewCodes.unknown);
      expect(vm.windowStateLabel, AnnualReviewTexts.unknown);
      expect(vm.year, '2026');
      expect(
        vm.sections.first.lines,
        _annual('m7_annual_2026.json').sections.first.lines,
      );
    });

    test('모름 + 첫 해 = 글자 «모름» · 섹션 = 첫 해 문장', () {
      final AnnualReviewVm vm = _vm(trusted: null, first: 2026);
      expect(vm.windowStateCode, AnnualReviewCodes.unknown);
      expect(vm.sections, _annual('m7_annual_first_year.json').sections);
    });
  });

  group('명시 연도 = 끝난 해만', () {
    test('운영 첫 해 ~ 기본 연도 앞 = 닫힘(지난 해의 리뷰)', () {
      final AnnualReviewVm vm = _vm(
        trusted: DateTime.utc(2026, 12, 3),
        first: 2024,
        year: '2025',
      );
      expect(vm.year, '2025');
      expect(vm.windowStateCode, AnnualReviewCodes.closed);
      expect(vm.windowStateLabel, AnnualReviewTexts.closed);
      expect(vm.sections, _annual('m7_annual_offwindow.json').sections);
    });

    test('기본 연도 = 인자 없음과 같다', () {
      expect(
        _vm(trusted: _asOfNow, first: 2025, year: '2025'),
        _vm(trusted: _asOfNow, first: 2025),
      );
    });

    test('범위 밖 = 실패(운영 첫 해 앞 · 기본 연도 뒤 · 첫 해 · 운영 전)', () {
      for (final (DateTime trusted, int? first, String year)
          in <(DateTime, int?, String)>[
            (DateTime.utc(2026, 12, 3), 2025, '2024'),
            (DateTime.utc(2026, 12, 3), 2025, '2027'),
            (_asOfNow, 2025, '2026'), // 8월 = 2026 은 아직 안 끝났다
            (_asOfNow, 2026, '2025'),
            (_asOfNow, null, '2025'),
          ]) {
        expect(
          () => _vm(trusted: trusted, first: first, year: year),
          throwsStateError,
          reason: '$trusted · $first · $year',
        );
      }
    });

    test('꼴이 틀리면 = 인자 오류', () {
      for (final String bad in <String>['26', '2026-12', ' 2025', 'abcd']) {
        expect(
          () => _vm(trusted: _asOfNow, first: 2024, year: bad),
          throwsArgumentError,
          reason: bad,
        );
      }
    });
  });

  group('세후 = 골든 참고치', () {
    test('엔진 사본 = golden_p0s.json aftertax_full_S7 과 값 하나 다르지 않다', () {
      final Map<String, Object?> file = jsonDecode(
        File('test/golden/vectors/golden_p0s.json').readAsStringSync(),
      ) as Map<String, Object?>;
      expect(kP0sAfterTaxFullS7Golden, equals(file['aftertax_full_S7']));
    });

    test('본문 = POT 비과세 · 반사실 = 종합과세 38.5% · 참고치 표지 · 지문 = 받은 판', () {
      final AnnualReviewVm vm = _vm(trusted: _asOfNow, first: 2025);
      expect(vm.afterTax!.branch, TaxLadderBranch.specPotTaxFree);
      expect(
        vm.afterTaxCounterfactual!.branch,
        TaxLadderBranch.cfPotTaxableComp38,
      );
      expect(vm.afterTax!.isReferenceOnly, isTrue);
      final AnnualReviewVm other = annualReviewVmOf(
        trustedNowUtc: _asOfNow,
        nowUtc: _asOfNow,
        firstOperatingYear: 2025,
        configHash: 'cfg_other',
        hasBody: _all,
      );
      expect(other.afterTax!.configHash, 'cfg_other');
      expect(other.afterTaxCounterfactual!.configHash, 'cfg_other');
    });

    test('세후 계산을 받으면 그것으로 짓는다(골든 고정 아님)', () {
      final Map<String, Object?> changed = jsonDecode(
        jsonEncode(kP0sAfterTaxFullS7Golden),
      ) as Map<String, Object?>;
      ((changed['spec_pot_taxfree']! as Map<String, Object?>)['pretax']!
              as Map<String, Object?>)['cagr_pct'] =
          12.0;
      final AnnualReviewVm vm = annualReviewVmOf(
        trustedNowUtc: _asOfNow,
        nowUtc: _asOfNow,
        firstOperatingYear: 2025,
        configHash: _cfg,
        hasBody: _all,
        afterTax: AfterTaxFull.fromGoldenJson(changed),
      );
      expect(vm.afterTax, isNot(_annual('m7_annual_offwindow.json').afterTax));
    });
  });

  group('S7-10 이행 갭', () {
    ExecutionGapResult gap(String file) =>
        ExecutionGapResult.fromJson(_row(file));

    test('자동 매매 = 해당 없음(표본 그대로 · 달과 무관)', () {
      for (final String? m in <String?>[null, '2026-08', '2025-12']) {
        expect(
          executionGapResultOf(
            mode: OperatingMode.autoTrade,
            nowUtc: _asOfNow,
            yyyyMm: m,
          ),
          gap('execution_gap_not_applicable.json'),
        );
      }
    });

    test('운용 전(모드 모름) = 발행된 안내 0(표본 그대로)', () {
      expect(
        executionGapResultOf(mode: null, nowUtc: _asOfNow),
        gap('execution_gap_empty.json'),
      );
    });

    test('안내 모드 = 산출 원천 없음 실패(지어내지 않는다)', () {
      expect(
        () => executionGapResultOf(
          mode: OperatingMode.advisory,
          nowUtc: _asOfNow,
        ),
        throwsStateError,
      );
    });

    test('달 꼴이 틀리면 = 인자 오류', () {
      for (final String bad in <String>[
        '2026-13',
        '2026-8',
        '202608',
        '2026-00',
      ]) {
        expect(
          () => executionGapResultOf(
            mode: OperatingMode.autoTrade,
            nowUtc: _asOfNow,
            yyyyMm: bad,
          ),
          throwsArgumentError,
          reason: bad,
        );
      }
    });
  });
}
