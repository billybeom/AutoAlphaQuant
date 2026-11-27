// 🆕 미결 243 ⓐ — `M5-4` postmortem 목록 VM · 결과 · `D-01` «써야 할 postmortem» 배너(설계 13 §8 R282 · 계약 v1.39 K345).
//
// 🔴 표본과 DTO 째로 대조(«(합성) » 머리만 뗌) — 목록 3 · 배너 1 · 결과 3. 🔴 의무 건 = 기한 있음 · 차례 = 엔진 · 쓰기 칸 = 창구 있을 때만 ·
//    STOPPED 결정 링크 = 본문 있을 때만.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _fx = '../domain_contracts/fixtures';
const String _synthetic = '(합성) ';

Object? _strip(Object? v) => switch (v) {
  final String s =>
    s.startsWith(_synthetic) ? s.substring(_synthetic.length) : s,
  final List<Object?> l => <Object?>[for (final Object? x in l) _strip(x)],
  final Map<String, Object?> m => <String, Object?>{
    for (final MapEntry<String, Object?> e in m.entries) e.key: _strip(e.value),
  },
  _ => v,
};

List<Map<String, Object?>> _rows(String path) =>
    ((jsonDecode(File('$_fx/$path').readAsStringSync())
                as Map<String, Object?>)['rows']!
            as List<Object?>)
        .map((Object? r) => _strip(r)! as Map<String, Object?>)
        .toList();

PostmortemListVm _want(String name) =>
    PostmortemListVm.fromJson(_rows('m5/postmortem_list_$name.json').single);

bool _all(String _) => true;
bool _none(String _) => false;

/// 한국 시각 → UTC.
DateTime _kst(int mo, int d, int h, int mi) =>
    DateTime.utc(2026, mo, d, h, mi).subtract(const Duration(hours: 9));

OpenIncident _manual(String id, DateTime at, {String? written}) => OpenIncident(
  incidentId: id,
  severity: 'SEV2',
  category: 'MANUAL_ORDER',
  occurredAtUtc: at,
  dueAtUtc: at.add(kManualOrderPostmortemDue),
  postmortem: written,
);

OpenIncident _stopped(String id, DateTime at, {String? written}) =>
    OpenIncident(
      incidentId: id,
      severity: 'SEV1',
      category: 'BREAKER_STOPPED',
      occurredAtUtc: at,
      dueAtUtc: at.add(kStoppedPostmortemDue),
      postmortem: written,
    );

void main() {
  final DateTime now = DateTime.utc(2026, 9, 1, 9);

  group('🔴 표본 대조(DTO 째로)', () {
    test('postmortem_list_empty = 열린 의무 건 0', () {
      final PostmortemListVm want = _want('empty');
      expect(
        postmortemListVmOf(
          const <OpenIncident>[],
          nowUtc: now,
          asOf: want.asOf,
          canWrite: true,
          hasBody: _all,
        ),
        want,
      );
    });

    test('postmortem_list_due = SEV2 수동 주문 · 기한 전 · 쓰기 칸', () {
      final PostmortemListVm want = _want('due');
      expect(
        postmortemListVmOf(
          <OpenIncident>[
            _manual('SEV2-MANUAL_ORDER-20260901', _kst(9, 1, 10, 12)),
          ],
          nowUtc: now,
          asOf: want.asOf,
          canWrite: true,
          hasBody: _all,
        ),
        want,
      );
    });

    test('postmortem_list_written_overdue = SEV1 썼음(STOPPED 결정 링크) → SEV2 기한 넘김(넣은 차례와 무관)', () {
      final PostmortemListVm want = _want('written_overdue');
      final String written = want.rows.first.writtenText!;
      expect(
        postmortemListVmOf(
          <OpenIncident>[
            _manual('SEV2-MANUAL_ORDER-20260820', _kst(8, 20, 9, 41)),
            _stopped(
              'SEV1-BREAKER_STOPPED-20260828',
              _kst(8, 28, 14, 2),
              written: written,
            ),
          ],
          nowUtc: now,
          asOf: want.asOf,
          canWrite: true,
          hasBody: _all,
        ),
        want,
      );
    });

    test('incident_banner_postmortem_due = 쓸 차례 SEV2 · other · act · 조치 «postmortem 쓰기»', () {
      final IncidentBannerVm want = IncidentBannerVm.fromJson(
        _rows('m8/incident_banner_postmortem_due.json').single,
      );
      expect(
        incidentBannerVmOf(<OpenIncident>[
          _manual('SEV2-MANUAL_ORDER-20260901', _kst(9, 1, 10, 12)),
        ], hasBody: _all),
        want,
      );
    });

    test('결과 3(safety_action_results_e13) = 엔진 글자 · 등급 · 코드', () {
      final List<SafetyActionResult> want = <SafetyActionResult>[
        for (final Map<String, Object?> r in _rows(
          'm5/safety_action_results_e13.json',
        ))
          if (r['id'] == 'INCIDENT_POSTMORTEM') SafetyActionResult.fromJson(r),
      ];
      expect(want, hasLength(3));
      for (final SafetyActionResult w in want) {
        expect(
          postmortemActionResultOf(
            actionRunId: w.actionRunId,
            code: w.reasonCode,
          ),
          w,
          reason: '${w.reasonCode}',
        );
      }
    });
  });

  group('갈래', () {
    test('🔴 의무 건만(기한 있음) — SEV3 · 옛 행(기한 없음) = 빠짐', () {
      final PostmortemListVm vm = postmortemListVmOf(
        <OpenIncident>[
          OpenIncident(
            incidentId: 'SEV3-X',
            severity: 'SEV3',
            category: 'SOMETHING',
            occurredAtUtc: _kst(9, 1, 9, 0),
          ),
          _manual('SEV2-MANUAL_ORDER-a', _kst(9, 1, 10, 12)),
        ],
        nowUtc: now,
        asOf: _want('due').asOf,
        canWrite: true,
        hasBody: _all,
      );
      expect(vm.rows.map((PostmortemRow r) => r.incidentId), <String>[
        'SEV2-MANUAL_ORDER-a',
      ]);
    });

    test('🔴 쓰기 창구 없음 = 칸 0(뷰어 · 기기 id 없음) · 글자 · 차례 그대로', () {
      final PostmortemRow r = postmortemListVmOf(
        <OpenIncident>[_manual('SEV2-a', _kst(9, 1, 10, 12))],
        nowUtc: now,
        asOf: _want('due').asOf,
        canWrite: false,
        hasBody: _all,
      ).rows.single;
      expect((r.form, r.stateLabel, r.writtenText), (null, '쓸 차례', null));
    });

    test(
      '🔴 STOPPED 결정 본문 없음 = 링크 0 · 쓴 SEV1 만 남음 = 머리 «없습니다» · info · 빈 문장 0',
      () {
        final PostmortemListVm vm = postmortemListVmOf(
          <OpenIncident>[_stopped('SEV1-a', _kst(8, 28, 14, 2), written: '썼다')],
          nowUtc: now,
          asOf: _want('due').asOf,
          canWrite: true,
          hasBody: _none,
        );
        expect(
          (vm.headline, vm.level, vm.emptyLabel),
          ('써야 할 postmortem 이 없습니다', UiLevel.info, null),
        );
        final PostmortemRow r = vm.rows.single;
        expect(
          (r.nextLink, r.form, r.dueText, r.writtenText),
          (null, null, null, '썼다'),
        );
        expect(r.stateLabel, '썼습니다 — STOPPED 결정이 닫습니다');
      },
    );

    test('🔴 공백만 쓴 글 = 안 씀(쓰기 칸 · 쓸 차례) · 넘김 판정 = 기한 < 지금', () {
      final DateTime at = _kst(8, 20, 9, 41);
      final PostmortemRow r = postmortemListVmOf(
        <OpenIncident>[_manual('SEV2-a', at, written: '  ')],
        nowUtc: at.add(kManualOrderPostmortemDue),
        asOf: _want('due').asOf,
        canWrite: true,
        hasBody: _all,
      ).rows.single;
      expect((r.overdue, r.writtenText, r.form == null), (false, null, false));
      expect(r.dueText, '기한 08-27 09:41');
    });

    test('불변식 — 쓰기 칸 ⇒ 쓴 글 없음 · id 빈칸 0 · 링크 = STOPPED 결정', () {
      for (final String name in <String>['due', 'written_overdue']) {
        for (final PostmortemRow r in _want(name).rows) {
          if (r.form != null) expect(r.writtenText, isNull);
          expect(r.incidentId, isNotEmpty);
          expect(
            r.nextLink?.deepLink ?? AppRoutes.m5StoppedDecision,
            AppRoutes.m5StoppedDecision,
          );
        }
      }
    });

    test('결과 — 건 없음 = info · 모르는 코드 = ArgumentError', () {
      final SafetyActionResult r = postmortemActionResultOf(
        actionRunId: 'ar-1',
        code: PostmortemResultCodes.notFound,
      );
      expect(
        (r.id, r.level, r.reasonCode, r.retryable),
        (
          SafetyActionId.postmortemRecord,
          UiLevel.info,
          'INCIDENT_NOT_FOUND',
          false,
        ),
      );
      expect(
        () => postmortemActionResultOf(actionRunId: 'ar-1', code: 'NOPE'),
        throwsArgumentError,
      );
    });
  });

  test('관측 봉투 = 기기 시각 · 한국 날 · 로컬 원장 · 글자', () {
    final AsOf a = postmortemAsOf(DateTime.utc(2026, 9, 1, 9));
    expect(
      (a.observedAt, a.tradeDate, a.source, a.label),
      (
        DateTime.utc(2026, 9, 1, 9),
        const TradeDate('2026-09-01'),
        AsOfSource.localSqlite,
        '사건 기준 2026-09-01 18:00',
      ),
    );
  });

  group('D-01 배너', () {
    test('🔴 쓴 SEV1 · 기한 없는 건 = 기존 other 글자(조치 0) · 본문 없음 = 조치 0', () {
      final IncidentBanner written = incidentBannerVmOf(<OpenIncident>[
        _stopped('SEV1-a', _kst(8, 28, 14, 2), written: '썼다'),
      ], hasBody: _all).banner!;
      expect((written.title, written.actionLink), ('확인이 필요한 일이 있습니다', null));
      final IncidentBanner noBody = incidentBannerVmOf(<OpenIncident>[
        _stopped('SEV1-b', _kst(8, 28, 14, 2)),
      ], hasBody: _none).banner!;
      expect(
        (noBody.title, noBody.level, noBody.actionLink),
        ('써야 할 postmortem 이 있습니다', UiLevel.blocked, null),
      );
      expect(
        noBody.bodyText,
        '서킷브레이커 STOPPED 사건의 postmortem 을 기한 08-31 14:02 까지 써야 합니다.',
      );
    });

    test('🔴 첫 건 = 엔진 차례(쓴 SEV1 이 앞이면 other) — 목록은 둘 다 보인다', () {
      final List<OpenIncident> xs = <OpenIncident>[
        _manual('SEV2-a', _kst(9, 1, 10, 12)),
        _stopped('SEV1-a', _kst(8, 28, 14, 2), written: '썼다'),
      ];
      expect(
        incidentBannerVmOf(xs, hasBody: _all).banner!.title,
        '확인이 필요한 일이 있습니다',
      );
      expect(
        postmortemListVmOf(
          xs,
          nowUtc: now,
          asOf: _want('due').asOf,
          canWrite: true,
          hasBody: _all,
        ).rows.map((PostmortemRow r) => r.incidentId),
        <String>['SEV1-a', 'SEV2-a'],
      );
    });
  });
}
