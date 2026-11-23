// E11q-d2 — M8 `D-01` 장애 배너 VM(설계 13 §8 · 06 M4-12 ① · 04 §6 · 01 §26 K8 · K9 · 표본 `m8/incident_banner_*`).
//
// 🔴 갈래마다 표본과 DTO 째로 대조 — 종류 다섯 · 없음 · 열린 사건 → `other` 표본. 🔴 정렬(심각도 → 기한 → 연 시각 → id) ·
//    등급(SEV1 blocked · SEV2 act · SEV3 info · 모르는 값 = blocked) · 조치 = 본문이 있을 때만 · OK 거부.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _fx = '../domain_contracts/fixtures';

IncidentBannerVm _want(String file) => IncidentBannerVm.fromJson(
  ((jsonDecode(File('$_fx/m8/$file.json').readAsStringSync())
                  as Map<String, Object?>)['rows']!
              as List<Object?>)
          .first!
      as Map<String, Object?>,
);

bool _all(String _) => true;
bool _none(String _) => false;

OpenIncident _inc(
  String id,
  String severity, {
  String category = 'BREAKER_STOPPED',
  DateTime? due,
  DateTime? at,
}) => OpenIncident(
  incidentId: id,
  severity: severity,
  category: category,
  occurredAtUtc: at ?? DateTime.utc(2026, 11, 20),
  dueAtUtc: due,
);

void main() {
  group('🔴 표본 대조(DTO 째로)', () {
    final Map<String, (IncidentKind, UiLevel)>
    cases = <String, (IncidentKind, UiLevel)>{
      'incident_banner_token_expired': (
        IncidentKind.tokenExpired,
        UiLevel.blocked,
      ),
      'incident_banner_order_rejected': (
        IncidentKind.orderRejected,
        UiLevel.act,
      ),
      'incident_banner_network_down': (IncidentKind.networkDown, UiLevel.watch),
      'incident_banner_phone_down': (IncidentKind.phoneDown, UiLevel.blocked),
      'incident_banner_other': (IncidentKind.other, UiLevel.info),
    };
    for (final MapEntry<String, (IncidentKind, UiLevel)> c in cases.entries) {
      test('${c.key} = 번들 글자 · 조치(본문 있음)', () {
        final IncidentBannerVm got = IncidentBannerVm(
          banner: incidentBannerOf(c.value.$1, c.value.$2, hasBody: _all),
        );
        expect(got, _want(c.key));
      });
    }

    test('incident_banner_none = 열린 사건 0', () {
      expect(
        incidentBannerVmOf(const <OpenIncident>[], hasBody: _all),
        _want('incident_banner_none'),
      );
    });

    test(
      '열린 SEV3 · 모르는 분류 = incident_banner_other 그대로(종류 other · 등급 info · 조치 0)',
      () {
        expect(
          incidentBannerVmOf(<OpenIncident>[
            _inc('SEV3-X', 'SEV3', category: 'SOMETHING_NEW'),
          ], hasBody: _all),
          _want('incident_banner_other'),
        );
      },
    );

    test('번들 = 종류 다섯 전부 · 조치 목적지 = 계약 라우트', () {
      expect(
        IncidentBannerTexts.byKind.keys.toSet(),
        IncidentKind.values.toSet(),
      );
      for (final IncidentBannerCopy c in IncidentBannerTexts.byKind.values) {
        final LinkAction? a = c.action;
        if (a != null) expect(AppRoutes.all, contains(a.deepLink));
      }
    });
  });

  group('지금 엔진이 쓰는 사건', () {
    test('🔴 STOPPED SEV1 = other · blocked · 표본 other 글자 · 조치 0', () {
      final IncidentBanner b = incidentBannerVmOf(<OpenIncident>[
        _inc('SEV1-BREAKER_STOPPED-20261120', 'SEV1'),
      ], hasBody: _all).banner!;
      expect(b.kind, IncidentKind.other);
      expect(b.level, UiLevel.blocked);
      expect(b.title, '확인이 필요한 일이 있습니다');
      expect(b.bodyText, '자세한 내용은 운영 화면에서 확인하세요.');
      expect(b.actionLink, isNull);
    });

    test('🔴 대사 해제 MANUAL_ORDER SEV2 = other · act', () {
      final IncidentBanner b = incidentBannerVmOf(<OpenIncident>[
        _inc('SEV2-MANUAL_ORDER-d1', 'SEV2', category: 'MANUAL_ORDER'),
      ], hasBody: _all).banner!;
      expect(b.kind, IncidentKind.other);
      expect(b.level, UiLevel.act);
    });

    test('분류 → 종류 = 늘 other(토큰 · 네트워크 · 주문 거부는 사건 표에서 끌어오지 않는다)', () {
      for (final String c in <String>[
        'BREAKER_STOPPED',
        'MANUAL_ORDER',
        AlertCodes.brokerAuthFailed,
        AlertCodes.orderRejected,
        '',
      ]) {
        expect(incidentKindOf(c), IncidentKind.other, reason: c);
      }
    });
  });

  group('등급 · 정렬', () {
    test('심각도 → 등급(모르는 값 = 가장 무거운 쪽)', () {
      expect(incidentLevelOf('SEV1'), UiLevel.blocked);
      expect(incidentLevelOf('SEV2'), UiLevel.act);
      expect(incidentLevelOf('SEV3'), UiLevel.info);
      expect(incidentLevelOf('SEV9'), UiLevel.blocked);
    });

    UiLevel firstLevel(List<OpenIncident> xs) =>
        incidentBannerVmOf(xs, hasBody: _all).banner!.level;

    test('🔴 최대 1건 = 가장 무거운 심각도(넣은 차례와 무관)', () {
      expect(
        firstLevel(<OpenIncident>[
          _inc('a', 'SEV3'),
          _inc('b', 'SEV2'),
          _inc('c', 'SEV1'),
        ]),
        UiLevel.blocked,
      );
      expect(
        firstLevel(<OpenIncident>[_inc('a', 'SEV3'), _inc('b', 'SEV2')]),
        UiLevel.act,
      );
      expect(
        firstLevel(<OpenIncident>[_inc('z', 'SEV9'), _inc('a', 'SEV2')]),
        UiLevel.blocked,
      );
    });

    // 같은 심각도 안의 차례는 지금 글자가 같아 VM 으로는 안 보인다 — 비교 함수를 직접 본다(VM 이 이 함수로 줄 세운다).
    test('차례 = 심각도 → 기한 이른 쪽 → 기한 없음은 뒤 → 연 시각 → id', () {
      final DateTime d1 = DateTime.utc(2026, 11, 23);
      final DateTime d2 = DateTime.utc(2026, 11, 27);
      final List<OpenIncident> xs = <OpenIncident>[
        _inc('n', 'SEV2', at: DateTime.utc(2026, 11, 3)),
        _inc('s3', 'SEV3', due: DateTime.utc(2026, 11, 1)),
        _inc('late', 'SEV2', due: d2),
        _inc('early', 'SEV2', due: d1),
        _inc('b', 'SEV2', at: DateTime.utc(2026, 11, 2)),
        _inc('a', 'SEV2', at: DateTime.utc(2026, 11, 2)),
        _inc('old', 'SEV2', at: DateTime.utc(2026, 11, 1)),
        _inc('s1', 'SEV1', due: DateTime.utc(2026, 12, 31)),
      ]..sort(compareIncidentUrgency);
      expect(xs.map((OpenIncident x) => x.incidentId).toList(), <String>[
        's1',
        'early',
        'late',
        'old',
        'a',
        'b',
        'n',
        's3',
      ]);
    });
  });

  group('조치 = 본문이 있을 때만', () {
    test('본문 없음 = 조치 0(글자는 그대로)', () {
      for (final IncidentKind k in IncidentKind.values) {
        final IncidentBanner b = incidentBannerOf(
          k,
          UiLevel.act,
          hasBody: _none,
        );
        expect(b.actionLink, isNull, reason: k.wire);
        expect(b.title, IncidentBannerTexts.byKind[k]!.title);
      }
    });

    test('🔴 hasBody 는 계약 라우트 패턴으로 묻는다 · 그 목적지 하나만 본다', () {
      final List<String> asked = <String>[];
      final IncidentBanner t = incidentBannerOf(
        IncidentKind.tokenExpired,
        UiLevel.blocked,
        hasBody: (String r) {
          asked.add(r);
          return r == AppRoutes.settingsCredentials;
        },
      );
      expect(asked, <String>[AppRoutes.settingsCredentials]);
      expect(t.actionLink?.deepLink, AppRoutes.settingsCredentials);
      final IncidentBanner o = incidentBannerOf(
        IncidentKind.orderRejected,
        UiLevel.act,
        hasBody: (String r) => r == AppRoutes.settingsCredentials,
      );
      expect(o.actionLink, isNull);
    });

    test('🔴 OK 등급 = 배너에 오지 않는다', () {
      expect(
        () => incidentBannerOf(IncidentKind.other, UiLevel.ok, hasBody: _all),
        throwsArgumentError,
      );
    });
  });
}
