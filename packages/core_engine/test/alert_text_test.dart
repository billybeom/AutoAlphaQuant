// E13h2 — 알림 문구 사전 · AckState 글자 · 인박스 · 센터 · 상세 VM(설계 13 §8 R69).
//
// 🔵 잡는 것: ① 사전 = 등급 표의 코드 28 그대로 · 빈 글자 0 · 링크 = AppRoutes 상수 · 픽스처 글자(그대로 쓴 9코드)
//    ② 모르는 코드 = 오류 ③ AckState 갈래(사다리 없는 알림 = null · 확인 · 0 · 1 · 2단) · 픽스처 글자
//    ④ 고정 = 미확인 P0(나이 무관) + 기간 안 확인 P0 · 차례 ⑤ 섹션 = 한국 날 · 오늘 머리 · P1 펼침 · P2 접힘 · 접힘 머리 ·
//    7일 경계 ⑥ 빈 문장 · P0만 ⑦ 인박스 차례 · min ⑧ 상세 있음 · 모르는 id · 기간 밖 ⑨ 행 글자.
import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:test/test.dart';

// 한국 2026-11-05 10:00.
final DateTime _now = DateTime.utc(2026, 11, 5, 1);

StoredAlert _a(
  String id,
  String code,
  AlertLevel level,
  DateTime at, {
  DateTime? acked,
  int steps = 0,
}) => StoredAlert(
  alertId: id,
  code: code,
  level: level,
  raisedAtUtc: at,
  ackedAtUtc: acked,
  escalationSteps: steps,
);

List<Map<String, Object?>> _fixtureItems(String name) {
  final List<Map<String, Object?>> out = <Map<String, Object?>>[];
  void walk(Object? o) {
    if (o is Map<String, Object?>) {
      if (o.containsKey('alert_id') && o.containsKey('code')) out.add(o);
      o.values.forEach(walk);
    } else if (o is List<Object?>) {
      o.forEach(walk);
    }
  }

  walk(
    jsonDecode(
      File('../domain_contracts/fixtures/m8/$name').readAsStringSync(),
    ),
  );
  return out;
}

void main() {
  test('사전 = 등급 표 코드 28 그대로 · 빈 글자 0 · 링크 = AppRoutes 상수', () {
    expect(kAlertTexts.keys.toSet(), kAlertLevels.keys.toSet());
    expect(kAlertTexts, hasLength(28));
    for (final MapEntry<String, AlertText> e in kAlertTexts.entries) {
      expect(
        <String>[
          e.value.title,
          e.value.body,
          e.value.action,
        ].every((String s) => s.trim().isNotEmpty),
        isTrue,
        reason: e.key,
      );
      if (e.value.deepLink != null) {
        expect(AppRoutes.all, contains(e.value.deepLink), reason: e.key);
      }
    }
    // 조치가 다르면 다르게 말한다 — D-7 은 할 일 없음 · D-1 은 미리보기.
    expect(
      kAlertTexts['REBALANCE_D7']!.action,
      isNot(kAlertTexts['REBALANCE_D1']!.action),
    );
  });

  test('픽스처 글자 — 그대로 쓴 9코드 · 빈 문장 · 상세 없음 문장', () {
    // 🟡 픽스처끼리 글자가 다른 5코드(ADVICE_DUE_SOON · ADVICE_EXPIRED · ADVICE_ISSUED · CONTRIBUTION_CHANGED ·
    //    SELF_AUDIT_DUE) — 엔진 사전 = 센터 픽스처(`alert_center_*`) 쪽 · 뒤 파일이 이긴다(R69 · 정정 제안).
    final Map<String, Map<String, Object?>> fx = <String, Map<String, Object?>>{
      for (final String f in <String>[
        'alerts_advice_9codes.json',
        'alerts_stale_orders_held.json',
        'alert_center_p0_ack.json',
        'alert_center_digest.json',
      ])
        for (final Map<String, Object?> it in _fixtureItems(f))
          it['code']! as String: it,
    };
    for (final String code in <String>[
      'ADVICE_DUE_SOON',
      'ADVICE_EXIT_URGENT',
      'ADVICE_EXPIRED',
      'ADVICE_REVOKED',
      'ADVICE_SUPPRESSED',
      'LEDGER_TRUST_DOWNGRADE',
      'MAINTENANCE_WINDOW_OVERDUE',
      'MANUAL_FILL_REJECTED',
      'STALE_ORDERS_HELD',
    ]) {
      final AlertText t = alertTextOf(code);
      expect(fx[code], isNotNull, reason: code);
      expect(
        <String>[t.title, t.body, t.action],
        <Object?>[
          fx[code]!['title'],
          fx[code]!['body_text'],
          fx[code]!['action_line'],
        ],
        reason: code,
      );
    }
    final Map<String, Object?> empty = _fixtureRow('alert_center_empty.json');
    final Map<String, Object?> missing = _fixtureRow(
      'alert_detail_missing.json',
    );
    expect(kAlertEmptyLabel, empty['empty_label']);
    expect(kAlertMissingLabel, missing['missing_label']);
  });

  test('🔴 모르는 코드 = 오류', () {
    expect(() => alertTextOf('SOMETHING_NEW'), throwsArgumentError);
    expect(
      () => alertItemOf(_a('x', 'SOMETHING_NEW', AlertLevel.p1, _now)),
      throwsArgumentError,
    );
  });

  test('AckState — 사다리 없는 알림 = null · 확인 · 0 · 1 · 2단(픽스처 글자)', () {
    expect(ackStateOf(_a('x', 'ORDER_REJECTED', AlertLevel.p1, _now)), isNull);
    expect(
      ackStateOf(_a('x', 'ADVICE_EXIT_URGENT', AlertLevel.p0, _now)),
      isNull,
    );
    final DateTime ackAt = _now.add(const Duration(minutes: 3));
    final AckState acked = ackStateOf(
      _a('x', 'RECON_MISMATCH', AlertLevel.p0, _now, acked: ackAt, steps: 1),
    )!;
    expect(
      (acked.acked, acked.ackedAt, acked.stateLabel, acked.escalationStep),
      (true, ackAt, '수신 확인함', 1),
    );
    String label(int steps) => ackStateOf(
      _a('x', 'RECON_MISMATCH', AlertLevel.p0, _now, steps: steps),
    )!.stateLabel;
    expect(label(0), '수신 확인 전');
    expect(label(1), '수신 확인 전 · 백업 채널로 보냈습니다');
    expect(label(2), '수신 확인 전 · 반복 알람을 울렸습니다');
    final AckState s2 = ackStateOf(
      _a('x', 'RECON_MISMATCH', AlertLevel.p0, _now, steps: 2),
    )!;
    expect((s2.acked, s2.ackedAt, s2.escalationStep), (false, null, 2));
  });

  test('행 글자 — 한국 HH:mm · 묶음 1 · 상세 링크 · 근거 링크', () {
    final AlertItem it = alertItemOf(
      _a(
        'AL-1',
        'ORDER_OUTCOME_UNKNOWN',
        AlertLevel.p0,
        DateTime.utc(2026, 11, 4, 15, 5),
      ),
    );
    expect(
      (
        it.raisedAtText,
        it.groupedCount,
        it.groupedText,
        it.detailDeepLink,
        it.deepLink,
      ),
      (
        '00:05',
        1,
        null,
        'aaq://alerts/detail/AL-1',
        'aaq://journal/unknown-board',
      ),
    );
    expect(
      (it.title, it.level, it.code),
      ('주문 결과를 확인하지 못했습니다', AlertLevel.p0, 'ORDER_OUTCOME_UNKNOWN'),
    );
    expect(it.ack!.stateLabel, '수신 확인 전');
  });

  group('센터 · 인박스 · 상세', () {
    // 한국 날: 오늘 11-05 · 기간 첫날 10-30.
    final List<StoredAlert> rows = <StoredAlert>[
      _a(
        'p0-old-open',
        'BROKER_AUTH_FAILED',
        AlertLevel.p0,
        DateTime.utc(2026, 10, 1),
      ),
      _a(
        'p0-new-open',
        'RECON_MISMATCH',
        AlertLevel.p0,
        DateTime.utc(2026, 11, 5, 0, 30),
      ),
      _a(
        'p0-acked',
        'ORDER_OUTCOME_UNKNOWN',
        AlertLevel.p0,
        DateTime.utc(2026, 11, 4, 3),
        acked: DateTime.utc(2026, 11, 4, 3, 5),
      ),
      _a(
        'p0-acked-old',
        'ORDER_OUTCOME_UNKNOWN',
        AlertLevel.p0,
        DateTime.utc(2026, 10, 29, 3),
        acked: DateTime.utc(2026, 10, 29, 4),
      ),
      _a(
        'p1-today',
        'WATCHDOG_LATE',
        AlertLevel.p1,
        DateTime.utc(2026, 11, 5, 0, 10),
      ),
      _a(
        'p1-today-2',
        'BACKUP_STALE',
        AlertLevel.p1,
        DateTime.utc(2026, 11, 4, 16),
      ),
      _a(
        'p2-today',
        'ADVICE_EXPIRED',
        AlertLevel.p2,
        DateTime.utc(2026, 11, 5, 0, 5),
      ),
      _a(
        'p2-1030',
        'DEPOSIT_REMINDER',
        AlertLevel.p2,
        DateTime.utc(2026, 10, 29, 15),
      ),
      // 같은 시각 둘 = id 차례.
      _a(
        'p1-1031-b',
        'DATA_SOURCE_DOWN',
        AlertLevel.p1,
        DateTime.utc(2026, 10, 31, 3),
      ),
      _a(
        'p1-1031',
        'ORDER_REJECTED',
        AlertLevel.p1,
        DateTime.utc(2026, 10, 31, 3),
      ),
      _a(
        'p1-1029',
        'ORDER_REJECTED',
        AlertLevel.p1,
        DateTime.utc(2026, 10, 29, 14, 59),
      ),
    ];

    test('🔴 고정 = 미확인 P0(나이 무관) 먼저 · 기간 안 확인 P0 · 기간 밖 확인 P0 = 빠짐', () {
      final AlertCenterVm c = alertCenterOf(
        rows: rows,
        nowUtc: _now,
        p0Only: false,
      );
      expect(c.pinned.map((AlertItem i) => i.alertId), <String>[
        'p0-new-open',
        'p0-old-open',
        'p0-acked',
      ]);
      expect(c.emptyLabel, isNull);
      expect(c.asOf.label, '알림 기준 2026-11-05');
      expect(c.asOf.staleAfter, const Duration(hours: 26));
    });

    test('🔴 섹션 = 한국 날 · 최근 날 먼저 · 오늘 머리 · P1 펼침 · P2 접힘 · 7일 경계', () {
      final AlertCenterVm c = alertCenterOf(
        rows: rows,
        nowUtc: _now,
        p0Only: false,
      );
      expect(c.sections.map((AlertSection s) => s.headerText), <String>[
        '오늘',
        '2026-10-31',
        '2026-10-30',
      ]);
      final AlertSection d1031 = c.sections[1];
      expect(d1031.rows.map((AlertItem i) => i.alertId), <String>[
        'p1-1031',
        'p1-1031-b',
      ]);
      expect(d1031.digestLabel, isNull);
      final AlertSection today = c.sections.first;
      // 11-04 16:00Z = 한국 11-05 01:00 → 오늘.
      expect(today.rows.map((AlertItem i) => i.alertId), <String>[
        'p1-today',
        'p1-today-2',
      ]);
      expect(today.digestRows.map((AlertItem i) => i.alertId), <String>[
        'p2-today',
      ]);
      expect(today.digestLabel, 'P2 1건');
      final AlertSection d1030 = c.sections.last;
      // 10-29 15:00Z = 한국 10-30(기간 첫날 · 든다) · 10-29 14:59Z = 한국 10-29(기간 밖).
      expect(d1030.rows, isEmpty);
      expect(d1030.digestRows.map((AlertItem i) => i.alertId), <String>[
        'p2-1030',
      ]);
      final AlertSection p1Only = alertCenterOf(
        rows: <StoredAlert>[rows[4]],
        nowUtc: _now,
        p0Only: false,
      ).sections.single;
      expect(p1Only.digestLabel, isNull);
      expect(p1Only.digestRows, isEmpty);
    });

    test('P0만 보기 = 섹션 0 · 고정 그대로', () {
      final AlertCenterVm c = alertCenterOf(
        rows: rows,
        nowUtc: _now,
        p0Only: true,
      );
      expect(c.sections, isEmpty);
      expect(c.pinned, hasLength(3));
      expect(c.emptyLabel, isNull);
    });

    test('빈 문장 = 고정 0 ∧ 섹션 0 일 때만', () {
      expect(
        alertCenterOf(
          rows: const <StoredAlert>[],
          nowUtc: _now,
          p0Only: false,
        ).emptyLabel,
        kAlertEmptyLabel,
      );
      // P0만 보기에 P1 만 있으면 = 빈 문장.
      expect(
        alertCenterOf(
          rows: <StoredAlert>[rows[4]],
          nowUtc: _now,
          p0Only: true,
        ).emptyLabel,
        kAlertEmptyLabel,
      );
      expect(
        alertCenterOf(
          rows: <StoredAlert>[rows[4]],
          nowUtc: _now,
          p0Only: false,
        ).emptyLabel,
        isNull,
      );
    });

    test('인박스 차례 = 고정 P0 → P1 → P2 · min', () {
      List<String> ids(AlertLevel? min) => alertInboxOf(
        rows: rows,
        nowUtc: _now,
        min: min,
      ).map((AlertItem i) => i.alertId).toList();
      expect(ids(null), <String>[
        'p0-new-open',
        'p0-old-open',
        'p0-acked',
        'p1-today',
        'p1-today-2',
        'p1-1031',
        'p1-1031-b',
        'p2-today',
        'p2-1030',
      ]);
      expect(ids(AlertLevel.p0), <String>[
        'p0-new-open',
        'p0-old-open',
        'p0-acked',
      ]);
      expect(ids(AlertLevel.p1), hasLength(7));
    });

    test('상세 = 보이는 알림 · 모르는 id · 기간 밖 = 없음 문장', () {
      final AlertDetailVm d = alertDetailOf(
        rows: rows,
        nowUtc: _now,
        alertId: 'p1-today',
      );
      expect((d.item!.alertId, d.missingLabel), ('p1-today', null));
      expect(d.item, alertItemOf(rows[4]));
      for (final String id in <String>['NONE', 'p1-1029', 'p0-acked-old']) {
        final AlertDetailVm m = alertDetailOf(
          rows: rows,
          nowUtc: _now,
          alertId: id,
        );
        expect(
          (m.item, m.missingLabel),
          (null, kAlertMissingLabel),
          reason: id,
        );
      }
      // 기간 밖이라도 미확인 P0 = 보인다.
      expect(
        alertDetailOf(rows: rows, nowUtc: _now, alertId: 'p0-old-open').item,
        isNotNull,
      );
    });
  });

  test('상수', () {
    expect(kAlertWindowDays, 7);
  });
}

Map<String, Object?> _fixtureRow(String name) =>
    ((jsonDecode(
                  File('../domain_contracts/fixtures/m8/$name')
                      .readAsStringSync(),
                ) as Map<String, Object?>)['rows']!
                as List<Object?>)
            .first!
        as Map<String, Object?>;
