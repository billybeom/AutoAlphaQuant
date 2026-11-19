// E11p4l — M9 S12 연간 리뷰 목차 · 12월 창(설계 13 §8 R168 · 01 §33 K118 · K131 · K139 · 미결 202).
//
// 🔴 표본 `m9/annual_review_index_open` · `_closed` · `_first_year` 와 VM 값 그대로 · 창 = 신뢰 시각 한국 12월 ·
//    목차 = 등록된 화면만 · 서약 링크 = OPEN 때만 · S01 카드 = 표본 `m9/settings_home` 글자.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _fx = '../domain_contracts/fixtures/m9';

AnnualReviewIndexVm _fixture(String file) {
  final Map<String, Object?> d =
      jsonDecode(File('$_fx/$file').readAsStringSync()) as Map<String, Object?>;
  return AnnualReviewIndexVm.fromJson(
    (d['rows']! as List<Object?>).first! as Map<String, Object?>,
  );
}

/// 표본 기준 시각(as_of observed_at).
final DateTime _now = DateTime.utc(2026, 11, 18, 6);

bool _all(String _) => true;

void main() {
  group('창 판정 = 신뢰 시각 한국 12월', () {
    test('12월 = OPEN · 그 밖 = CLOSED · 모름 = unknown · 한국 날짜로 가른다', () {
      expect(annualReviewWindowOf(null), AnnualReviewWindow.unknown);
      expect(
        annualReviewWindowOf(DateTime.utc(2026, 12, 1)),
        AnnualReviewWindow.open,
      );
      expect(
        annualReviewWindowOf(DateTime.utc(2026, 11, 30, 15)),
        AnnualReviewWindow.open,
        reason: 'UTC 11-30 15:00 = 한국 12-01 00:00',
      );
      expect(
        annualReviewWindowOf(DateTime.utc(2026, 12, 31, 15)),
        AnnualReviewWindow.closed,
        reason: 'UTC 12-31 15:00 = 한국 1월',
      );
      expect(
        annualReviewWindowOf(DateTime.utc(2026, 11, 18)),
        AnnualReviewWindow.closed,
      );
    });
  });

  group('VM = 표본 그대로', () {
    test('OPEN(12월 · 목차 4 · 서약 링크)', () {
      expect(
        annualReviewIndexVmOf(
          AnnualReviewIndexFacts(
            trustedNowUtc: DateTime.utc(2026, 12, 3),
            firstOperatingYear: 2025,
            hasBody: _all,
            nowUtc: _now,
          ),
        ),
        _fixture('annual_review_index_open.json'),
      );
    });

    test('CLOSED(11월 = 지난해 · 목차 4 · 서약 0)', () {
      expect(
        annualReviewIndexVmOf(
          AnnualReviewIndexFacts(
            trustedNowUtc: _now,
            firstOperatingYear: 2025,
            hasBody: _all,
            nowUtc: _now,
          ),
        ),
        _fixture('annual_review_index_closed.json'),
      );
    });

    test('첫 해(지난해가 운영 전 · 올해 · 목차 2 · 서약 0)', () {
      expect(
        annualReviewIndexVmOf(
          AnnualReviewIndexFacts(
            trustedNowUtc: _now,
            firstOperatingYear: 2026,
            hasBody: _all,
            nowUtc: _now,
          ),
        ),
        _fixture('annual_review_index_first_year.json'),
      );
    });
  });

  group('등록 · 시각 · 첫 해', () {
    test('🔴 등록 안 된 화면 = 목차 행 0 · 서약 화면 없음 = 서약 링크 0(OPEN 이어도)', () {
      final AnnualReviewIndexVm vm = annualReviewIndexVmOf(
        AnnualReviewIndexFacts(
          trustedNowUtc: DateTime.utc(2026, 12, 3),
          firstOperatingYear: 2025,
          hasBody: (String r) => r == AppRoutes.ledgerExecutionGap,
          nowUtc: _now,
        ),
      );
      expect(vm.windowStateLabel, AnnualReviewTexts.open);
      expect(vm.entries.map((LinkAction e) => e.deepLink), <String>[
        AppRoutes.ledgerExecutionGap,
      ]);
      expect(vm.pledgeLink, isNull);
    });

    test('🔴 신뢰 시각 모름 = «확인하지 못했습니다» · 서약 링크 0 · 연도 = 기기 시각(12월 = 그해)', () {
      final AnnualReviewIndexVm nov = annualReviewIndexVmOf(
        AnnualReviewIndexFacts(
          trustedNowUtc: null,
          firstOperatingYear: 2025,
          hasBody: _all,
          nowUtc: _now,
        ),
      );
      expect(nov.windowStateLabel, AnnualReviewTexts.unknown);
      expect(nov.yearLabel, '2025년 연간 리뷰');
      expect(nov.entries, hasLength(4));
      expect(nov.pledgeLink, isNull);
      final AnnualReviewIndexVm dec = annualReviewIndexVmOf(
        AnnualReviewIndexFacts(
          trustedNowUtc: null,
          firstOperatingYear: 2025,
          hasBody: _all,
          nowUtc: DateTime.utc(2026, 12, 5),
        ),
      );
      expect(dec.windowStateLabel, AnnualReviewTexts.unknown);
      expect(dec.yearLabel, '2026년 연간 리뷰');
      expect(dec.pledgeLink, isNull, reason: '기기 시각은 창을 열지 않는다');
    });

    test('운영 시작 해 모름 = 첫 해 · 12월 OPEN 은 첫 해보다 앞선다', () {
      final AnnualReviewIndexVm a = annualReviewIndexVmOf(
        AnnualReviewIndexFacts(
          trustedNowUtc: _now,
          firstOperatingYear: null,
          hasBody: _all,
          nowUtc: _now,
        ),
      );
      expect(a.windowStateLabel, AnnualReviewTexts.firstYear);
      expect(a.yearLabel, '2026년 연간 리뷰');
      expect(a.entries, hasLength(2));
      final AnnualReviewIndexVm b = annualReviewIndexVmOf(
        AnnualReviewIndexFacts(
          trustedNowUtc: DateTime.utc(2026, 12, 3),
          firstOperatingYear: 2026,
          hasBody: _all,
          nowUtc: _now,
        ),
      );
      expect(b.windowStateLabel, AnnualReviewTexts.open);
      expect(b.yearLabel, '2026년 연간 리뷰');
      expect(b.entries, hasLength(4));
      expect(b.pledgeLink?.deepLink, AppRoutes.m5Pledge);
    });
  });

  group('S01 연간 카드', () {
    test('OPEN · S12 등록 = 표본 글자 · 그 밖 = 부재', () {
      final Map<String, Object?> home =
          ((jsonDecode(File('$_fx/settings_home.json').readAsStringSync())
                          as Map<String, Object?>)['rows']!
                      as List<Object?>)
                  .first!
              as Map<String, Object?>;
      expect(
        annualReviewHomeLinkOf(
          trustedNowUtc: DateTime.utc(2026, 12, 3),
          hasBody: _all,
        ),
        LinkAction.fromJson(
          home['annual_review_link']! as Map<String, Object?>,
        ),
      );
      expect(
        annualReviewHomeLinkOf(trustedNowUtc: _now, hasBody: _all),
        isNull,
      );
      expect(
        annualReviewHomeLinkOf(trustedNowUtc: null, hasBody: _all),
        isNull,
      );
      expect(
        annualReviewHomeLinkOf(
          trustedNowUtc: DateTime.utc(2026, 12, 3),
          hasBody: (String r) => r != AppRoutes.settingsAnnualReview,
        ),
        isNull,
      );
    });
  });
}
