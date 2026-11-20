// C-52 설정 홈·연결 관리·M9 동작·엔진 등재형 — 01 §27(🆕 계약 v1.18 · R6 선행 + 엔진 등재형 7 ·
// 발주자 결정 2026-11-13 Q1~Q4 · K-a~K-z).
//
// 정의: 「M9 `S01` 설정 홈·`S07` 연결 관리는 엔진이 완성한 VM 으로 온다 — 묶음 차례·뷰어 판 행 빼기·연간 링크(OPEN)·
//        승격 줄 = 엔진 · 카드 아이콘 = `level` 뿐(코드 사전 0) · 연결 행 색 = `level`(짝 규칙 · `statusCode` 는 ui 미참조) ·
//        동작 = 엔진이 완성한 `SettingsActionCall`(args 화이트리스트 · 그 행의 target · 그 옵션의 channel) ·
//        채널 선택 = 알림 채널 행에 붙은 카드 하나 · 잠김 = `lockedLabel` + 엔진이 동작 칸을 비움 · 결과 = 버튼 근거 0 —
//        그리고 엔진 등재형 7 코드가 사전·표본과 글자로 맞는다」.
//   ① 허용 키 ② 홈 묶음 ③ 칩·연간 링크 ④ 뷰어 판 ⑤ 연결 행 ⑥ 동작 호출 ⑦ 채널 선택 ⑧ 잠김 ⑨ 동작 결과
//   ⑩ 엔진 등재형 ⑪ 받침대 ⑫ 라우트 ⑬ 손익·금액.
//
// 🔴 픽스처 불변식만 본다 — `ui_settings` 화면 스캔은 R6a·R6b 카드 정적 묶음 몫.
// 🔴 한국어 글자 단언 0 — 상수 리터럴 = 표본 id·키 이름·코드·라우트 상수·`FixturePaths` · ⑬ 의 금지 낱말 목록 하나 뿐.
// 🆕 v1.19(01 §28 · K16) — ⑨ «코드 3 전수» 를 S07 3 코드로 좁혔다(`SettingsResultCodes` += 엔진 제어 2 · 그 전수 = C-53 ⑫).

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

const List<String> _homes = <String>[
  FixturePaths.m9SettingsHome,
  FixturePaths.m9SettingsHomeNoReview,
  FixturePaths.m9SettingsHomeViewer,
];

const List<String> _m9Connections = <String>[
  FixturePaths.m9Connections,
  FixturePaths.m9ConnectionsTelegram,
  FixturePaths.m9ConnectionsLocked,
];

/// 연결 4벌 — m9 3 + 개정 1(`incident_token_expired` · 미결 165 해소).
const List<String> _connections = <String>[
  ..._m9Connections,
  FixturePaths.m8IncidentTokenExpired,
];

/// m9 신설 7벌(⑬ · DRY_RUN 0 — ③).
const List<String> _m9New = <String>[
  ..._homes,
  ..._m9Connections,
  FixturePaths.m9SettingsActionResults,
];

/// S07 동작 3과 그 args 화이트리스트(`settings_actions.dart` 머리 · K-r · K-s).
final Map<SettingsActionId, Set<String>> _argsWhitelist =
    <SettingsActionId, Set<String>>{
      SettingsActionId.connectionTest: <String>{'target'},
      SettingsActionId.connectionSyncNow: <String>{'target'},
      SettingsActionId.notifyChannelSelect: <String>{'channel'},
    };

/// 폰 전용 목적지(K-w · 뷰어 판 VM 에 오면 안 된다).
const List<String> _phoneOnly = <String>[
  AppRoutes.settingsCredentials,
  AppRoutes.settingsAccounts,
  AppRoutes.settingsOperations,
  AppRoutes.settingsDevices,
  AppRoutes.settingsCalendar,
  AppRoutes.settingsBackup,
  AppRoutes.settingsDiagnostics,
  AppRoutes.settingsContribution,
];

/// ⑫ — M9 라우트 11(`settingsCredentials` 바로 뒤 · 이 차례).
const List<String> _m9Routes = <String>[
  AppRoutes.settingsHome,
  AppRoutes.settingsAccounts,
  AppRoutes.settingsAllocation,
  AppRoutes.settingsOperations,
  AppRoutes.settingsDevices,
  AppRoutes.settingsConnections,
  AppRoutes.settingsCalendar,
  AppRoutes.settingsBackup,
  AppRoutes.settingsDiagnostics,
  AppRoutes.settingsGeneral,
  AppRoutes.settingsAnnualReview,
];

/// ⑬ 손익 성격 낱말(C-6 의 화면 글자 판 · 이 목록만 한국어 상수).
const List<String> _pnlWords = <String>['수익률', '평가액', '손익'];

/// ⑬ 금액 글자 꼴.
final RegExp _money = RegExp(r'[0-9][0-9,]*원');

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _maps(Object? list) =>
    (list! as List<Object?>).cast<Map<String, Object?>>();

List<Map<String, Object?>> _rows(String path) => _maps(_env(path)['rows']);

/// VM 1행 봉투의 VM.
Map<String, Object?> _vm(String path) {
  final List<Map<String, Object?>> rows = _rows(path);
  expect(rows, hasLength(1), reason: '$path — VM 1행 봉투가 아니다');
  return rows.single;
}

Map<String, Object?>? _map(Object? v) => v as Map<String, Object?>?;

Set<String> _keys(Map<String, Object?> m) => m.keys.toSet();

SettingsHomeVm _home(String path) => SettingsHomeVm.fromJson(_vm(path));

ConnectionsVm _conn(String path) => ConnectionsVm.fromJson(_vm(path));

/// 문자열 값 전부.
List<String> _strings(Object? node) {
  final List<String> out = <String>[];
  void visit(Object? n) {
    if (n is String) {
      out.add(n);
    } else if (n is Map) {
      n.values.forEach(visit);
    } else if (n is List) {
      n.forEach(visit);
    }
  }

  visit(node);
  return out;
}

void _expectSameKeys(
  Map<String, Object?> raw,
  Map<String, Object?> json,
  String where,
) {
  expect(_keys(raw), _keys(json), reason: '$where — 직속 키 ≠ toJson 키');
}

void main() {
  group('C-52 설정 홈·연결 관리·M9 동작·엔진 등재형 (01 §27 · 계약 v1.18)', () {
    test(
      'C-52 ① 허용 키 — 새·개정 DTO 8 의 직속 키 = toJson · action_available·is_viewer 0',
      () {
        for (final String path in _homes) {
          final Map<String, Object?> raw = _vm(path);
          final SettingsHomeVm vm = SettingsHomeVm.fromJson(raw);
          _expectSameKeys(raw, vm.toJson(), '$path SettingsHomeVm');
          _expectSameKeys(
            _map(raw['status_chip'])!,
            vm.statusChip.toJson(),
            '$path EngineStatusChip',
          );
          final List<Map<String, Object?>> groups = _maps(raw['groups']);
          for (int g = 0; g < groups.length; g++) {
            _expectSameKeys(
              groups[g],
              vm.groups[g].toJson(),
              '$path groups[$g] SettingsGroup',
            );
            final List<Map<String, Object?>> cards = _maps(groups[g]['cards']);
            for (int c = 0; c < cards.length; c++) {
              _expectSameKeys(
                cards[c],
                vm.groups[g].cards[c].toJson(),
                '$path groups[$g].cards[$c] SettingsCard',
              );
            }
          }
        }
        for (final String path in _connections) {
          final Map<String, Object?> raw = _vm(path);
          final ConnectionsVm vm = ConnectionsVm.fromJson(raw);
          _expectSameKeys(raw, vm.toJson(), '$path ConnectionsVm');
          final List<Map<String, Object?>> rows = _maps(raw['rows']);
          for (int r = 0; r < rows.length; r++) {
            final ConnectionRow row = vm.rows[r];
            _expectSameKeys(
              rows[r],
              row.toJson(),
              '$path rows[$r] ConnectionRow',
            );
            final Map<String, Object?>? picker = _map(
              rows[r]['channel_picker'],
            );
            if (picker != null) {
              _expectSameKeys(
                picker,
                row.channelPicker!.toJson(),
                '$path rows[$r] NotifyChannelCard',
              );
              final List<Map<String, Object?>> options = _maps(
                picker['options'],
              );
              for (int o = 0; o < options.length; o++) {
                _expectSameKeys(
                  options[o],
                  row.channelPicker!.options[o].toJson(),
                  '$path rows[$r].options[$o] NotifyChannelOption',
                );
              }
            }
          }
        }
        final List<String> revived = <String>[];
        for (final String path in <String>[..._m9New, ..._connections]) {
          walkJson(_env(path), (String jsonPath, String key, Object? value) {
            if (key == 'action_available' || key == 'is_viewer') {
              revived.add('$path $jsonPath');
            }
          });
        }
        expect(revived, isEmpty, reason: '삭제 칸(K-q)·뷰어 칸(K-o)이 되살아났다');
      },
    );

    test('C-52 ② 홈 묶음 — 차례 GENERAL < OPERATIONAL < RULE · 빈 묶음 0 · code 유일 · route 등록 · 레벨 5값', () {
      for (final String path in _homes) {
        final SettingsHomeVm vm = _home(path);
        final List<int> tiers = <int>[
          for (final SettingsGroup g in vm.groups) g.tier.index,
        ];
        for (int i = 1; i < tiers.length; i++) {
          expect(
            tiers[i],
            greaterThan(tiers[i - 1]),
            reason: '$path — 묶음 차례가 엄격 오름이 아니다(차례 = 엔진 의무)',
          );
        }
        final List<SettingsCard> cards = <SettingsCard>[
          for (final SettingsGroup g in vm.groups) ...g.cards,
        ];
        for (final SettingsGroup g in vm.groups) {
          expect(g.cards, isNotEmpty, reason: '$path ${g.tier} — 빈 묶음');
        }
        expect(
          cards.map((SettingsCard c) => c.code).toSet(),
          hasLength(cards.length),
          reason: '$path — 카드 code 중복',
        );
        for (final SettingsCard c in cards) {
          expect(c.route, isNotNull, reason: '$path ${c.code} — route 없음');
          expect(
            AppRoutes.isRegistered(c.route!),
            isTrue,
            reason: '$path ${c.code} ${c.route}',
          );
        }
      }
      final List<SettingsCard> main = <SettingsCard>[
        for (final SettingsGroup g in _home(FixturePaths.m9SettingsHome).groups)
          ...g.cards,
      ];
      expect(main, hasLength(11));
      expect(
        main.map((SettingsCard c) => c.level).toSet(),
        UiLevel.values.toSet(),
        reason: 'settings_home — 레벨 5값 전수(표본 동치 방지)',
      );
      expect(
        main.where((SettingsCard c) => c.attentionText != null),
        isNotEmpty,
      );
      expect(
        main.where((SettingsCard c) => c.attentionText == null),
        isNotEmpty,
      );
    });

    test('C-52 ③ 칩·연간 링크 — label 비지 않음 · 승격 줄 갈래 · 링크 = settingsAnnualReview · DRY_RUN 0', () {
      final List<SettingsHomeVm> vms = <SettingsHomeVm>[
        for (final String p in _homes) _home(p),
      ];
      for (int i = 0; i < vms.length; i++) {
        expect(vms[i].statusChip.label, isNotEmpty, reason: _homes[i]);
        final LinkAction? link = vms[i].annualReviewLink;
        if (link != null) {
          expect(
            link.deepLink,
            AppRoutes.settingsAnnualReview,
            reason: _homes[i],
          );
        }
      }
      expect(
        vms.where((SettingsHomeVm v) => v.statusChip.promotionLabel != null),
        isNotEmpty,
      );
      expect(
        vms.where((SettingsHomeVm v) => v.statusChip.promotionLabel == null),
        isNotEmpty,
      );
      expect(_home(FixturePaths.m9SettingsHome).annualReviewLink, isNotNull);
      expect(
        _home(FixturePaths.m9SettingsHomeNoReview).annualReviewLink,
        isNull,
      );
      final List<String> dryRun = <String>[
        for (final String path in _m9New)
          for (final String s in _strings(_env(path)))
            if (s.contains('DRY_RUN')) '$path: $s',
      ];
      expect(dryRun, isEmpty, reason: 'm9 표본에 DRY_RUN 글자(G-63 확장)');
    });

    test('C-52 ④ 뷰어 판 — 카드 ⊂ 원판 · 폰 전용 목적지 0 · 묶음 차례 · 칩·링크 같음', () {
      final SettingsHomeVm full = _home(FixturePaths.m9SettingsHome);
      final SettingsHomeVm viewer = _home(FixturePaths.m9SettingsHomeViewer);
      final Map<String, String> fullCards = <String, String>{
        for (final SettingsGroup g in full.groups)
          for (final SettingsCard c in g.cards) c.code: jsonEncode(c.toJson()),
      };
      for (final SettingsGroup g in viewer.groups) {
        for (final SettingsCard c in g.cards) {
          expect(
            fullCards[c.code],
            jsonEncode(c.toJson()),
            reason: '뷰어 ${c.code} — 원판에 없거나 값이 다르다',
          );
          expect(_phoneOnly, isNot(contains(c.route)), reason: c.code);
        }
      }
      expect(
        viewer.groups.map((SettingsGroup g) => g.tier).toList(),
        full.groups.map((SettingsGroup g) => g.tier).toList(),
      );
      expect(viewer.statusChip, full.statusChip);
      expect(viewer.annualReviewLink, full.annualReviewLink);
    });

    test('C-52 ⑤ 연결 행 — 짝 규칙 · target 사전·유일 · route 등록 · healthchecks = 워치독 링크 · 행 수', () {
      for (final String path in _connections) {
        final ConnectionsVm vm = _conn(path);
        final Set<String> targets = <String>{};
        for (final ConnectionRow r in vm.rows) {
          final String where = '$path ${r.target}';
          expect(
            r.statusCode == 'OK',
            r.level == UiLevel.ok,
            reason: '$where — OK ⇔ ok 짝이 깨졌다',
          );
          if (r.statusCode == 'NOT_SET') {
            expect(r.level, UiLevel.info, reason: where);
          }
          if (r.statusCode == 'FAILED') {
            expect(
              <UiLevel>{UiLevel.act, UiLevel.blocked},
              contains(r.level),
              reason: where,
            );
          }
          if (r.statusCode == 'LAGGED') {
            expect(
              <UiLevel>{UiLevel.watch, UiLevel.act},
              contains(r.level),
              reason: where,
            );
          }
          expect(
            ConnectionTargetCodes.values,
            contains(r.target),
            reason: where,
          );
          expect(targets.add(r.target), isTrue, reason: '$where — target 중복');
          if (r.route != null) {
            expect(AppRoutes.isRegistered(r.route!), isTrue, reason: where);
          }
          if (r.target == ConnectionTargetCodes.healthchecks) {
            expect(r.actions, isEmpty, reason: '$where — 워치독은 링크만');
            expect(r.route, AppRoutes.opsWatchdog, reason: where);
          }
        }
      }
      final ConnectionsVm main = _conn(FixturePaths.m9Connections);
      expect(main.rows, hasLength(5));
      expect(
        main.rows.map((ConnectionRow r) => r.level).toSet(),
        UiLevel.values.toSet(),
        reason: 'connections — 레벨 5값 전수',
      );
      expect(
        main.rows.where((ConnectionRow r) => r.detailLine != null),
        isNotEmpty,
      );
      final ConnectionsVm tg = _conn(FixturePaths.m9ConnectionsTelegram);
      expect(tg.rows, hasLength(4));
      expect(
        tg.rows.where(
          (ConnectionRow r) => r.target == ConnectionTargetCodes.calendar,
        ),
        isEmpty,
        reason: 'connections_telegram — 캘린더 행 0(행 수 = 받은 수)',
      );
    });

    test('C-52 ⑥ 동작 호출 — 전 픽스처 actions·select_action: id 3 · args 화이트리스트 · 그 행 target · 그 옵션 channel', () {
      final List<String> bad = <String>[];
      void check(
        String where,
        Map<String, Object?> raw, {
        String? target,
        String? channel,
      }) {
        final SettingsActionCall call = SettingsActionCall.fromJson(raw);
        final Set<String>? allowed = _argsWhitelist[call.id];
        if (allowed == null) {
          bad.add('$where — id ${call.id.wire} 는 S07 동작이 아니다');
          return;
        }
        if (!allowed.containsAll(call.args.keys)) {
          bad.add('$where — args ${call.args.keys} ⊄ $allowed');
        }
        if (call.label.isEmpty) {
          bad.add('$where — label 빔');
        }
        if (call.args.containsKey('target') && call.args['target'] != target) {
          bad.add('$where — target ${call.args['target']} ≠ 행 $target');
        }
        if (call.args.containsKey('channel')) {
          if (call.args['channel'] != channel) {
            bad.add('$where — channel ${call.args['channel']} ≠ 옵션 $channel');
          }
          if (!NotifyChannelCodes.values.contains(call.args['channel'])) {
            bad.add('$where — channel 사전 밖');
          }
        }
      }

      for (final String path in FixturePaths.all) {
        walkJson(_env(path), (String jsonPath, String key, Object? value) {
          if (key != 'rows' || value is! List) {
            return;
          }
          for (final Object? row in value) {
            if (row is! Map<String, Object?>) {
              continue;
            }
            final Object? actions = row['actions'];
            final Object? target = row['target'];
            if (actions is List && target is String) {
              for (int i = 0; i < actions.length; i++) {
                check(
                  '$path $jsonPath ${row['target']} actions[$i]',
                  actions[i]! as Map<String, Object?>,
                  target: target,
                );
              }
            }
            final Map<String, Object?>? picker = _map(row['channel_picker']);
            if (picker != null) {
              for (final Map<String, Object?> o in _maps(picker['options'])) {
                final Map<String, Object?>? sel = _map(o['select_action']);
                if (sel != null) {
                  check(
                    '$path $jsonPath option ${o['code']}',
                    sel,
                    channel: o['code'] as String?,
                  );
                }
              }
            }
          }
        });
      }
      expect(bad, isEmpty);
      for (final String path in _connections) {
        expect(
          _conn(path).rows.where((ConnectionRow r) => r.actions.isNotEmpty),
          path == FixturePaths.m9ConnectionsLocked ? isEmpty : isNotEmpty,
          reason: path,
        );
      }
    });

    test(
      'C-52 ⑦ 채널 선택 — 알림 채널 행에 하나 · selected 1 · 고지 2칸 · 배지 갈래 · 두 벌 고지 다름',
      () {
        final Map<String, NotifyChannelCard> pickers =
            <String, NotifyChannelCard>{};
        for (final String path in _connections) {
          final List<ConnectionRow> withPicker = _conn(path).rows
              .where((ConnectionRow r) => r.channelPicker != null)
              .toList();
          if (path == FixturePaths.m8IncidentTokenExpired) {
            expect(withPicker, isEmpty, reason: path);
            continue;
          }
          expect(withPicker, hasLength(1), reason: '$path — 채널 선택 행 ≠ 1');
          expect(
            withPicker.single.target,
            ConnectionTargetCodes.notifyChannel,
            reason: path,
          );
          final NotifyChannelCard card = withPicker.single.channelPicker!;
          pickers[path] = card;
          expect(
            card.options.where((NotifyChannelOption o) => o.selected),
            hasLength(1),
            reason: '$path — 선택된 채널 ≠ 1(기본 선택 = 엔진)',
          );
          for (final NotifyChannelOption o in card.options) {
            expect(NotifyChannelCodes.values, contains(o.code), reason: path);
            if (o.selected) {
              expect(o.selectAction, isNull, reason: '$path ${o.code}');
            } else if (path != FixturePaths.m9ConnectionsLocked) {
              expect(o.selectAction, isNotNull, reason: '$path ${o.code}');
            }
          }
          expect(card.capabilityNotice, isNotEmpty, reason: path);
          expect(card.watchdogChannelLine, isNotEmpty, reason: path);
        }
        expect(pickers[FixturePaths.m9Connections]!.tokenBadgeText, isNotNull);
        expect(
          pickers[FixturePaths.m9ConnectionsTelegram]!.tokenBadgeText,
          isNull,
        );
        expect(
          pickers[FixturePaths.m9Connections]!.capabilityNotice,
          isNot(pickers[FixturePaths.m9ConnectionsTelegram]!.capabilityNotice),
        );
      },
    );

    test('C-52 ⑧ 잠김 — locked_label · 동작 칸 0 · 그 밖은 원판과 같음 · 다른 표본 locked_label null', () {
      final ConnectionsVm locked = _conn(FixturePaths.m9ConnectionsLocked);
      expect(locked.lockedLabel, isNotNull);
      for (final ConnectionRow r in locked.rows) {
        expect(r.actions, isEmpty, reason: r.target);
        for (final NotifyChannelOption o
            in r.channelPicker?.options ?? const <NotifyChannelOption>[]) {
          expect(o.selectAction, isNull, reason: '${r.target} ${o.code}');
        }
      }
      ConnectionsVm strip(ConnectionsVm vm) => vm.copyWith(
        lockedLabel: null,
        rows: <ConnectionRow>[
          for (final ConnectionRow r in vm.rows)
            r.copyWith(
              actions: const <SettingsActionCall>[],
              channelPicker: r.channelPicker?.copyWith(
                options: <NotifyChannelOption>[
                  for (final NotifyChannelOption o in r.channelPicker!.options)
                    o.copyWith(selectAction: null),
                ],
              ),
            ),
        ],
      );
      expect(strip(locked), strip(_conn(FixturePaths.m9Connections)));
      for (final String path in _connections) {
        if (path != FixturePaths.m9ConnectionsLocked) {
          expect(_conn(path).lockedLabel, isNull, reason: path);
        }
      }
    });

    test('C-52 ⑨ 동작 결과 — 5행 · 레벨 5값 · 코드 3 전수 · 넘김 0 · 재시도 0 · id = S07 3', () {
      final List<ActionResult> results = <ActionResult>[
        for (final Map<String, Object?> r in _rows(
          FixturePaths.m9SettingsActionResults,
        ))
          ActionResult.fromJson(r),
      ];
      expect(results, hasLength(5));
      expect(
        results.map((ActionResult r) => r.level).toSet(),
        UiLevel.values.toSet(),
      );
      final Set<String?> codes = results
          .map((ActionResult r) => r.reasonCode)
          .toSet();
      expect(
        <String?>{...SettingsResultCodes.values, null}.containsAll(codes),
        isTrue,
      );
      expect(
        codes.containsAll(<String>{
          SettingsResultCodes.biometricUnavailable,
          SettingsResultCodes.connectionTestFailed,
          SettingsResultCodes.syncAlreadyRunning,
        }),
        isTrue,
        reason: 'S07 코드 3 전수(v1.18) · 🆕 v1.19 엔진 제어 2 = C-53 ⑫',
      );
      for (final ActionResult r in results) {
        expect(r.handoffRoute, isNull, reason: r.actionRunId);
        expect(
          r.retryable,
          isFalse,
          reason: '${r.actionRunId} — 버튼 = 행 actions 뿐(K-u)',
        );
        expect(_argsWhitelist.keys, contains(r.id), reason: r.actionRunId);
      }
    });

    test('C-52 ⑩ 엔진 등재형 — safety 3 · resume 3 · values 36(🆕 v1.27 +5 = C-61) · 알림 표본 6 · LEASE_INVALID', () {
      expect(AlertCodes.safety, <String>{
        'BREAKER_STOPPED',
        'LEDGER_INTEGRITY_BROKEN',
        'STOPPED_RELEASE_ELIGIBLE',
      });
      expect(AlertCodes.resume, <String>{
        'RESUME_TRADING_HALTED',
        'RESUME_COMPLETED',
        'RESUME_DATA_GAP',
      });
      expect(
        AlertCodes.values,
        hasLength(36),
      ); // 🆕 v1.27(01 §36) — safetyWarn 4 · derivedSync 1(C-61).
      expect(AlertCodes.values.containsAll(AlertCodes.safety), isTrue);
      expect(AlertCodes.values.containsAll(AlertCodes.resume), isTrue);
      final List<String> codes = <String>[
        for (final Map<String, Object?> r in _rows(
          FixturePaths.m8AlertsSafetyResume,
        ))
          AlertItem.fromJson(r).code,
      ];
      expect(codes, hasLength(6));
      expect(codes.toSet(), <String>{
        ...AlertCodes.safety,
        ...AlertCodes.resume,
      });
      expect(JournalReasonCodes.leaseInvalid, 'LEASE_INVALID');
      expect(
        JournalReasonCodes.values,
        contains(JournalReasonCodes.leaseInvalid),
      );
      expect(
        JournalReasonCodes.leaseInvalid,
        isNot(AdviceRejectCodes.leaseExpired),
      );
    });

    test(
      'C-52 ⑪ 받침대 — UnimplementedSettingsRepository.watchHome 은 동기로 던진다',
      () {
        expect(
          () => UnimplementedSettingsRepository().watchHome(),
          throwsA(isA<UnimplementedError>()),
        );
      },
    );

    test(
      'C-52 ⑫ 라우트 — M9 11 글자 · settingsCredentials 바로 뒤 차례 · 설정 홈 일치 경계',
      () {
        expect(_m9Routes, <String>[
          'aaq://settings',
          'aaq://settings/accounts',
          'aaq://settings/allocation',
          'aaq://settings/operations',
          'aaq://settings/devices',
          'aaq://settings/connections',
          'aaq://settings/calendar',
          'aaq://settings/backup',
          'aaq://settings/diagnostics',
          'aaq://settings/general',
          'aaq://settings/annual-review',
        ]);
        final int at = AppRoutes.all.indexOf(AppRoutes.settingsCredentials);
        expect(at, greaterThanOrEqualTo(0));
        expect(AppRoutes.all.sublist(at + 1, at + 12), _m9Routes);
        expect(AppRoutes.isRegistered('aaq://settings'), isTrue);
        expect(AppRoutes.isRegistered('aaq://settings/'), isFalse);
        expect(
          AppRoutes.isRegistered('aaq://settings/operations?x=1'),
          isFalse,
        );
        expect(AppRoutes.isRegistered('aaq://settings/unknown'), isFalse);
      },
    );

    test('C-52 ⑬ 손익·금액 — m9 신설 7벌 전 문자열에 손익 낱말·금액 글자 0', () {
      final List<String> bad = <String>[
        for (final String path in _m9New)
          for (final String s in _strings(_env(path)['rows']))
            if (_pnlWords.any(s.contains) || _money.hasMatch(s)) '$path: $s',
      ];
      expect(bad, isEmpty);
    });
  });
}
