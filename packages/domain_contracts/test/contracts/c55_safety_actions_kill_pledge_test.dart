// C-55 안전 동작·킬스위치 재개·서약 — 01 §30(🆕 계약 v1.21 · 엔진 예고 1/2 · 발주자 위임 2026-11-14 — 권고대로 · K1~K47).
//
// 정의: 「M5 의 안전 쓰기는 넷째 창구 `SafetyActions`(폰 전용 · `ui_safety` 만)로만 간다 — 재개 = 한 문항씩
//        (`runKillResumeItem` · 순차 · 7번 통과 = 해제 · 해제 버튼·카운트다운 0) · 서약 = `runPledge` · 결과 = `headline` +
//        `reasonCode` 만(넘김·재시도 0) — 재개 게이트 VM 은 SPEC 7문항 글자·선택지를 엔진 차례로 싣고 진행·대기·잠김을
//        미리 판정해 온다 · 서약 VM 은 0 또는 3줄 · 발동 기록은 `KillChecklistAck.activation`(추가형 · 한 명령) ·
//        결과 코드 = 엔진 글자 1:1 사전 4(공용 두 글자 한 벌)」.
//   ① 허용 키 ② 결과 id·코드 ③ 발동 기록 접수증 ④ 문항 ⑤ 선택지 ⑥ 진행 ⑦ 대기·시각 ⑧ 재생 ⑨ 잠김 ⑩ 서약 VM
//   ⑪ 제출·와이어 왕복 ⑫ 열거 와이어 ⑬ 사전 ⑭ 게이지 ⑮ 라우트 ⑯ 포트 경계 ⑰ 글자 ⑱ 받침대 ⑲ F3.
//
// 🔴 픽스처 불변식 + 경계 스캔만 본다 — `ui_safety` M5-2·M5-8 화면은 카드(E13j·E13m) 몫.
// 🔴 한국어 글자 단언 0 — 상수 리터럴 = 표본 id·키 이름·코드·라우트 상수·`FixturePaths` · 예외 = ④⑤ SPEC 문항·선택지 표
//    (출처 = SPEC v2.40 `06_시스템설계/04_안전장치.md` §3-6 «재개판» · 정규화 K38) · ⑫ 엔진 값 이름 표(출처 = core
//    `safety/kill_checklist.dart:12·21·157·169`) · ⑰ 금지 낱말 목록.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// M5-2 재개 게이트 7벌.
const List<String> _gates = <String>[
  FixturePaths.m5KillResumeGateNotConfirmed,
  FixturePaths.m5KillResumeGateWaiting,
  FixturePaths.m5KillResumeGateTimeUnknown,
  FixturePaths.m5KillResumeGateReady,
  FixturePaths.m5KillResumeGateInProgress,
  FixturePaths.m5KillResumeGateConditionUnmet,
  FixturePaths.m5KillResumeGateLocked,
];

/// 서약 3벌.
const List<String> _pledges = <String>[
  FixturePaths.m5PledgeWritten,
  FixturePaths.m5PledgeNotWritten,
  FixturePaths.m5PledgeEditWindow,
];

/// v1.21 신설 12벌.
const List<String> _all = <String>[
  ..._gates,
  ..._pledges,
  FixturePaths.m5SafetyActionResults,
  FixturePaths.m5KillChecklistReceipts,
];

/// ④ SPEC v2.40 04 §3-6 «재개판» 7문항(정규화 K38 — 굵게·🔴·백틱 제거 · 6번 괄호 설계 메모 제거 · 3·4번 선택지 분리).
const List<String> _specItems = <String>[
  '그때 적은 «규칙이 지시한 행동»을 다시 읽었다 — 지금 규칙은 무엇을 지시하는가',
  '그때의 감정 · 수면 기록을 다시 읽었다 — 지금 상태(감정 · 강도 · 수면)는',
  '그때 짚은 시나리오가 지금 어떻게 됐는가',
  '그때 적은 재개 조건이 지금 충족됐는가',
  '발동 동안 생긴 일(미체결 취소 결과 · 체결 · 남은 UNKNOWN)을 확인했다',
  '확인 시각부터 48h 가 지났음을 확인했다',
  '재개 저널을 썼다 — 사전 필드 3 · decision_id',
];

/// ⑤ 같은 표의 3·4번 대괄호 선택지(SPEC 원문).
const List<String> _specScenarioChoices = <String>['해소됨', '진행 중', '해당 없었음'];
const List<String> _specConditionChoices = <String>['충족', '미충족'];

/// ① `rows[0]` 아래 어디에도 오지 않는 키(카운트다운 원값 · 해제 버튼 칸 · 저널 id 노출 · 프리필).
const List<String> _forbiddenKeys = <String>[
  'decision_id',
  'journal_decision_id',
  'countdown',
  'remaining_seconds',
  'eta_utc',
  'release_action',
  'resume_action',
  'deactivate',
  'prefill',
  'example',
];

/// ⑰ 손익 낱말 · 금지어 · 카운트다운 · 해제 버튼.
const List<String> _forbiddenWords = <String>[
  'DRY_RUN',
  '수익률',
  '평가액',
  '손익',
  '추천',
  '권유',
  '자문',
  '시그널',
  '매매 중단',
  '카운트다운',
  '해제 버튼',
];
final RegExp _money = RegExp(r'[0-9][0-9,]*원');
final RegExp _longDigits = RegExp(r'[0-9]{8,}');

const Set<UiLevel> _allLevels = <UiLevel>{
  UiLevel.ok,
  UiLevel.info,
  UiLevel.watch,
  UiLevel.act,
  UiLevel.blocked,
};

/// ⑯ `ui_safety` 밖 화면이 이름을 들이면 안 되는 M5 포트·VM·창구.
const List<String> _portSymbols = <String>[
  'SafetyActions',
  'SafetyActionId',
  'SafetyActionResult',
  'SafetyActionCall',
  'runKillResumeItem',
  'runPledge',
  'KillSwitchGateRepository',
  'PledgeRepository',
  'KillResumeGateVm',
  'PledgeVm',
  'KillResumeItemSubmission',
  'PledgeSubmission',
];

const CommandContext _context = CommandContext(
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.autoTrade,
  leaseEpoch: 7,
  deviceId: 'dev_fake_0001',
);

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

Set<String> _keys(Map<String, Object?> m) => m.keys.toSet();

KillResumeGateVm _gate(String path) => KillResumeGateVm.fromJson(_vm(path));

PledgeVm _pledge(String path) => PledgeVm.fromJson(_vm(path));

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

/// 키 전부(깊이 우선).
Set<String> _allKeys(Object? node) {
  final Set<String> out = <String>{};
  void visit(Object? n) {
    if (n is Map) {
      for (final MapEntry<Object?, Object?> e in n.entries) {
        out.add(e.key! as String);
        visit(e.value);
      }
    } else if (n is List) {
      n.forEach(visit);
    }
  }

  visit(node);
  return out;
}

/// 원시 VM 에서 이름 붙은 칸을 지운 사본(«그 밖 바이트 같음» 비교용).
String _without(Object? node, Set<String> drop) {
  Object? strip(Object? n) {
    if (n is Map<String, Object?>) {
      return <String, Object?>{
        for (final MapEntry<String, Object?> e in n.entries)
          if (!drop.contains(e.key)) e.key: strip(e.value),
      };
    }
    if (n is List) {
      return n.map(strip).toList();
    }
    return n;
  }

  return jsonEncode(strip(node));
}

/// camelCase 값 이름 → 기계적 SCREAMING_SNAKE(K10).
String _screamingSnake(String camel) => camel
    .replaceAllMapped(
      RegExp('([a-z0-9])([A-Z])'),
      (Match m) => '${m[1]}_${m[2]}',
    )
    .toUpperCase();

/// ⑭ 게이지 객체 — 키 `release_progress` 배열 원소 · 키 `cooldown` 객체(경로 걷기 · K41).
List<Map<String, Object?>> _gauges(Object? node) {
  final List<Map<String, Object?>> out = <Map<String, Object?>>[];
  void visit(Object? n) {
    if (n is Map<String, Object?>) {
      for (final MapEntry<String, Object?> e in n.entries) {
        if (e.key == 'release_progress' && e.value is List) {
          out.addAll(_maps(e.value));
        } else if (e.key == 'cooldown' && e.value is Map) {
          out.add(e.value! as Map<String, Object?>);
        }
        visit(e.value);
      }
    } else if (n is List) {
      n.forEach(visit);
    }
  }

  visit(node);
  return out;
}

/// 행이 앞에서부터 이어 답했는가 — 답한 수.
int _answeredPrefix(KillResumeGateVm g, String where) {
  final List<bool> answered = <bool>[
    for (final KillResumeItemRow r in g.items) r.answeredText != null,
  ];
  final int n = answered.where((bool a) => a).length;
  expect(answered, <bool>[
    for (int i = 0; i < answered.length; i++) i < n,
  ], reason: '$where — 답한 행이 앞에서부터 이어지지 않는다(건너뛰기·일괄)');
  return n;
}

void main() {
  group('C-55 안전 동작·킬스위치 재개·서약 (01 §30 · 계약 v1.21)', () {
    test(
      'C-55 ① 허용 키 — VM·행·선택지 직속 키 == toJson · 결과 키 7 · 카운트다운·해제·저널 id·프리필 키 0',
      () {
        for (final String path in _gates) {
          final Map<String, Object?> raw = _vm(path);
          final KillResumeGateVm vm = KillResumeGateVm.fromJson(raw);
          final Map<String, Object?> json = vm.toJson();
          expect(_keys(raw), _keys(json), reason: '$path — VM 직속 키');
          final List<Map<String, Object?>> rawRows = _maps(raw['items']);
          for (int i = 0; i < rawRows.length; i++) {
            final Map<String, Object?> rowJson = vm.items[i].toJson();
            expect(_keys(rawRows[i]), _keys(rowJson), reason: '$path 행 $i');
            final List<Map<String, Object?>> rawChoices = _maps(
              rawRows[i]['choices'],
            );
            for (int j = 0; j < rawChoices.length; j++) {
              expect(
                _keys(rawChoices[j]),
                _keys(vm.items[i].choices[j].toJson()),
                reason: '$path 행 $i 선택지 $j',
              );
            }
          }
        }
        for (final String path in _pledges) {
          final Map<String, Object?> raw = _vm(path);
          expect(
            _keys(raw),
            _keys(PledgeVm.fromJson(raw).toJson()),
            reason: path,
          );
        }
        for (final Map<String, Object?> r in _rows(
          FixturePaths.m5SafetyActionResults,
        )) {
          expect(_keys(r), <String>{
            'action_run_id',
            'id',
            'level',
            'headline',
            'reason_code',
            'handoff_route',
            'retryable',
          });
        }
        for (final String path in _all) {
          final Set<String> keys = _allKeys(_rows(path));
          for (final String bad in _forbiddenKeys) {
            expect(keys, isNot(contains(bad)), reason: '$path — 키 $bad');
          }
        }
      },
    );

    test('C-55 ② 결과 id·코드 — id 3 전수 · 재개·서약 코드 섞기 0 · 반드시 있음 11 · 묶음마다 레벨 5값 · 넘김·재시도 0', () {
      final List<SafetyActionResult> rs = <SafetyActionResult>[
        for (final Map<String, Object?> r in _rows(
          FixturePaths.m5SafetyActionResults,
        ))
          SafetyActionResult.fromJson(r),
      ];
      // 🔵 v1.22(01 §31) — `SafetyActionId` 가 +8 로 늘었다 · 이 표본의 축 = v1.21 동작 3(새 8 = C-56 ②).
      expect(<SafetyActionId>{
        for (final SafetyActionResult r in rs) r.id,
      }, _v121SafetyIds);
      final Set<String?> resumeAllowed = <String?>{
        null,
        ...KillSwitchResultCodes.values.where(
          (String c) => c.startsWith('RESUME_'),
        ),
        KillSwitchResultCodes.notActive,
        SafetyCommonResultCodes.journalIdTaken,
        SettingsResultCodes.biometricUnavailable,
      };
      final Set<String?> pledgeAllowed = <String?>{
        null,
        ...PledgeResultCodes.values,
        SafetyCommonResultCodes.trustedTimeUnknown,
        SettingsResultCodes.biometricUnavailable,
      };
      final Set<String> seen = <String>{};
      final List<SafetyActionResult> resume = <SafetyActionResult>[];
      final List<SafetyActionResult> pledge = <SafetyActionResult>[];
      for (final SafetyActionResult r in rs) {
        final bool isResume = r.id == SafetyActionId.killSwitchResume;
        (isResume ? resume : pledge).add(r);
        expect(
          isResume ? resumeAllowed : pledgeAllowed,
          contains(r.reasonCode),
          reason: '${r.actionRunId} ${r.id.wire} — 사전 밖 코드 ${r.reasonCode}',
        );
        expect(r.handoffRoute, isNull, reason: r.actionRunId);
        expect(r.retryable, isFalse, reason: r.actionRunId);
        expect(r.headline, isNotEmpty, reason: r.actionRunId);
        if (r.reasonCode != null) {
          seen.add(r.reasonCode!);
        }
      }
      expect(seen, <String>{
        KillSwitchResultCodes.resumeTooSoon,
        KillSwitchResultCodes.resumeItemMissing,
        KillSwitchResultCodes.resumeItemOutOfOrder,
        KillSwitchResultCodes.resumeConditionUnmet,
        KillSwitchResultCodes.resumeTrustedTimeUnknown,
        KillSwitchResultCodes.resumeChecklistNotConfirmed,
        SettingsResultCodes.biometricUnavailable,
        PledgeResultCodes.sentencesMissing,
        PledgeResultCodes.outOfWindow,
        PledgeResultCodes.unchanged,
        SafetyCommonResultCodes.trustedTimeUnknown,
      });
      expect(<UiLevel>{
        for (final SafetyActionResult r in resume) r.level,
      }, _allLevels);
      expect(<UiLevel>{
        for (final SafetyActionResult r in pledge) r.level,
      }, _allLevels);
    });

    test(
      'C-55 ③ 발동 기록 접수증 — kind 하나 · 집행 ≥ 1 · 거부 사유 = 킬스위치 ∪ 공용 6 · 재개 코드 0',
      () {
        final List<CommandReceipt> rs = <CommandReceipt>[
          for (final Map<String, Object?> r in _rows(
            FixturePaths.m5KillChecklistReceipts,
          ))
            CommandReceipt.fromJson(r),
        ];
        expect(
          <CommandKind>{for (final CommandReceipt r in rs) r.kind},
          <CommandKind>{CommandKind.killChecklistConfirm},
        );
        expect(
          rs.where((CommandReceipt r) => r.state == CommandState.executed),
          isNotEmpty,
        );
        final Set<String?> rejects = <String?>{
          for (final CommandReceipt r in rs)
            if (r.state == CommandState.rejected) r.rejectReasonCode,
        };
        expect(rejects, <String>{
          KillSwitchResultCodes.checklistItemMissing,
          KillSwitchResultCodes.ackIncomplete,
          KillSwitchResultCodes.ackMismatch,
          KillSwitchResultCodes.notActive,
          SafetyCommonResultCodes.trustedTimeUnknown,
          SafetyCommonResultCodes.journalIdTaken,
        });
        for (final CommandReceipt r in rs) {
          expect(r.stateLabel, isNotEmpty, reason: r.commandId);
          expect(
            r.rejectReasonCode ?? '',
            isNot(startsWith('RESUME_')),
            reason: '${r.commandId} — 재개 코드를 발동 기록에',
          );
        }
      },
    );

    test('C-55 ④ 문항 — 7벌 모두 7행 · 번호 1..7 차례 · 글자 == SPEC 재개판', () {
      for (final String path in _gates) {
        final KillResumeGateVm g = _gate(path);
        expect(g.items, hasLength(_specItems.length), reason: path);
        expect(
          <int>[for (final KillResumeItemRow r in g.items) r.itemNo],
          <int>[for (int i = 1; i <= _specItems.length; i++) i],
          reason: '$path — 번호 차례',
        );
        expect(
          <String>[for (final KillResumeItemRow r in g.items) r.label],
          _specItems,
          reason: '$path — 문항 글자(K38)',
        );
      }
    });

    test('C-55 ⑤ 선택지 — 3번 scenario 3 · 4번 condition 2 · 그 밖 빈 · 칸 정확히 하나', () {
      for (final String path in _gates) {
        for (final KillResumeItemRow r in _gate(path).items) {
          for (final KillResumeChoice c in r.choices) {
            expect(
              (c.scenario == null) != (c.condition == null),
              isTrue,
              reason: '$path ${r.itemNo} — 선택지 칸은 정확히 하나',
            );
          }
          if (r.itemNo == 3) {
            expect(
              <String>[for (final KillResumeChoice c in r.choices) c.label],
              _specScenarioChoices,
              reason: path,
            );
            expect(
              <KillResumeScenario?>[
                for (final KillResumeChoice c in r.choices) c.scenario,
              ],
              KillResumeScenario.values,
              reason: path,
            );
          } else if (r.itemNo == 4) {
            expect(
              <String>[for (final KillResumeChoice c in r.choices) c.label],
              _specConditionChoices,
              reason: path,
            );
            expect(
              <KillResumeCondition?>[
                for (final KillResumeChoice c in r.choices) c.condition,
              ],
              KillResumeCondition.values,
              reason: path,
            );
          } else {
            expect(r.choices, isEmpty, reason: '$path ${r.itemNo}');
          }
        }
      }
    });

    test('C-55 ⑥ 진행 — 다음 번호 = 답 수 + 1 · 막힘·잠김과 배타 · ready 1 · in_progress 4 · 미충족 = 막힘', () {
      for (final String path in _gates) {
        final KillResumeGateVm g = _gate(path);
        final int n = _answeredPrefix(g, path);
        final int? next = g.nextItemNo;
        if (next != null) {
          expect(next, inInclusiveRange(1, g.items.length), reason: path);
          expect(next, n + 1, reason: '$path — 다음 번호 ≠ 답 수 + 1');
          expect(g.blockedText, isNull, reason: path);
          expect(g.lockedLabel, isNull, reason: path);
        }
      }
      final KillResumeGateVm ready = _gate(FixturePaths.m5KillResumeGateReady);
      expect(ready.nextItemNo, 1);
      expect(_answeredPrefix(ready, 'ready'), 0);
      expect(_gate(FixturePaths.m5KillResumeGateInProgress).nextItemNo, 4);
      final KillResumeGateVm unmet = _gate(
        FixturePaths.m5KillResumeGateConditionUnmet,
      );
      final KillResumeItemRow four = unmet.items.firstWhere(
        (KillResumeItemRow r) => r.itemNo == 4,
      );
      expect(four.answeredText, isNotNull);
      expect(four.level, UiLevel.blocked);
      expect(unmet.nextItemNo, isNull);
      expect(unmet.blockedText, isNotNull);
    });

    test('C-55 ⑦ 대기·시각 — 확인 전 = 게이지·ETA 0 · 대기 = 0<폭<1 · 시각 모름 = 0 · ready = 1 · 대기 중 진행 0', () {
      final KillResumeGateVm nc = _gate(
        FixturePaths.m5KillResumeGateNotConfirmed,
      );
      expect(nc.blockedText, isNotNull);
      expect(nc.etaText, isNull);
      expect(nc.cooldown, isNull);
      expect(nc.nextItemNo, isNull);
      final KillResumeGateVm w = _gate(FixturePaths.m5KillResumeGateWaiting);
      expect(w.etaText, isNotNull);
      expect(w.cooldown?.code, GaugeCodes.cooldown);
      expect(w.cooldown!.normalized, greaterThan(0));
      expect(w.cooldown!.normalized, lessThan(1));
      expect(w.nextItemNo, isNull);
      final KillResumeGateVm tu = _gate(
        FixturePaths.m5KillResumeGateTimeUnknown,
      );
      expect(tu.cooldown?.code, GaugeCodes.cooldown);
      expect(tu.cooldown!.normalized, 0);
      expect(tu.nextItemNo, isNull);
      final KillResumeGateVm r = _gate(FixturePaths.m5KillResumeGateReady);
      expect(r.cooldown?.code, GaugeCodes.cooldown);
      expect(r.cooldown!.normalized, 1);
    });

    test('C-55 ⑧ 재생 — 1..6 번만 · 확인 전 0 · 대기·ready 6', () {
      for (final String path in _gates) {
        for (final KillResumeItemRow r in _gate(path).items) {
          if (r.replayText != null) {
            expect(r.itemNo, inInclusiveRange(1, 6), reason: '$path — 7번 재생');
          }
        }
      }
      int replays(String path) =>
          _gate(path).items
              .where((KillResumeItemRow r) => r.replayText != null)
              .length;
      expect(replays(FixturePaths.m5KillResumeGateNotConfirmed), 0);
      expect(replays(FixturePaths.m5KillResumeGateWaiting), 6);
      expect(replays(FixturePaths.m5KillResumeGateReady), 6);
    });

    test('C-55 ⑨ 잠김 — locked 만 잠김 · 다음 번호 0 · 그 밖 = ready', () {
      for (final String path in _gates) {
        final KillResumeGateVm g = _gate(path);
        if (path == FixturePaths.m5KillResumeGateLocked) {
          expect(g.lockedLabel, isNotNull);
          expect(g.nextItemNo, isNull);
        } else {
          expect(g.lockedLabel, isNull, reason: path);
        }
      }
      const Set<String> drop = <String>{'next_item_no', 'locked_label'};
      expect(
        _without(_vm(FixturePaths.m5KillResumeGateLocked), drop),
        _without(_vm(FixturePaths.m5KillResumeGateReady), drop),
        reason: '잠김 = 원판(ready)에서 다음 번호만 비우고 잠김 글자를 더한 판이다',
      );
    });

    test(
      'C-55 ⑩ 서약 VM — 0 또는 3줄 · 편집 ⇒ 3 · 잠김 ⇒ 편집 0 · 엔진 글자 없는 칸 null · 합성 표지',
      () {
        for (final String path in _pledges) {
          final PledgeVm p = _pledge(path);
          expect(<int>[0, 3], contains(p.lines.length), reason: path);
          if (p.editable) {
            expect(p.lines, hasLength(3), reason: path);
          }
          if (p.lockedLabel != null) {
            expect(p.editable, isFalse, reason: path);
          }
          expect(p.statusLine, isNull, reason: '$path — 판·작성 시각 줄(K16)');
          expect(p.replayNotice, isNull, reason: '$path — 재생 까닭(K16)');
          for (int i = 0; i < p.lines.length; i++) {
            expect(
              RegExp('^합성 서약 ${i + 1} — ').hasMatch(p.lines[i]),
              isTrue,
              reason: '$path — 서약 줄은 합성 표지를 단다(실제 사용자 글 0)',
            );
          }
        }
        expect(_pledge(FixturePaths.m5PledgeNotWritten).lines, isEmpty);
        expect(_pledge(FixturePaths.m5PledgeEditWindow).editable, isTrue);
        expect(_pledge(FixturePaths.m5PledgeWritten).editable, isFalse);
      },
    );

    test('C-55 ⑪ 제출·와이어 왕복 — 재개 11키(저널 id 0 · 숫자 = 원문) · 서약 3키 · 발동 기록 10키 · 옛 JSON 열림', () {
      const KillResumeItemSubmission item = KillResumeItemSubmission(
        itemNo: 2,
        emotion: 'calm',
        intensity: '2',
        sleepHours: '7.5',
        scenario: KillResumeScenario.notApplicable,
        condition: KillResumeCondition.met,
      );
      final Map<String, dynamic> itemJson = item.toJson();
      expect(itemJson.keys.toSet(), <String>{
        'item_no',
        'text',
        'emotion',
        'intensity',
        'sleep_hours',
        'scenario',
        'condition',
        'acknowledged',
        'rationale_before',
        'expected_outcome',
        'rule_cited',
      });
      expect(itemJson['intensity'], isA<String>());
      expect(itemJson['sleep_hours'], isA<String>());
      expect(itemJson['scenario'], 'NOT_APPLICABLE');
      expect(itemJson['condition'], 'MET');
      expect(KillResumeItemSubmission.fromJson(itemJson), item);

      const PledgeSubmission pledge = PledgeSubmission(
        id: SafetyActionId.pledgeEdit,
        sentences: <String>['a', 'b', 'c'],
        decisionId: 'd_fake',
      );
      final Map<String, dynamic> pledgeJson = pledge.toJson();
      expect(pledgeJson.keys.toSet(), <String>{
        'id',
        'sentences',
        'decision_id',
      });
      expect(pledgeJson['id'], 'PLEDGE_EDIT');
      expect(PledgeSubmission.fromJson(pledgeJson), pledge);

      const KillActivationRecord record = KillActivationRecord(
        ruleAction: 'r',
        reasonKind: KillActivationReason.emotion,
        emotion: 'e',
        intensity: 7,
        sleepHours: 4.5,
        scenarioId: 'W3',
        resumeCondition: 'c',
        scope: KillActivationScope.newEntriesOnly,
        journalDecisionId: 'd_fake',
      );
      final Map<String, dynamic> recordJson = record.toJson();
      expect(recordJson.keys.toSet(), <String>{
        'rule_action',
        'reason_kind',
        'emotion',
        'intensity',
        'sleep_hours',
        'scenario_id',
        'scenario_none',
        'resume_condition',
        'scope',
        'journal_decision_id',
      });
      expect(recordJson['intensity'], isA<int>());
      expect(recordJson['sleep_hours'], isA<double>());
      expect(recordJson['reason_kind'], 'EMOTION');
      expect(recordJson['scope'], 'NEW_ENTRIES_ONLY');

      final KillChecklistAck ack = KillChecklistAck(
        safetyEventId: 'se_fake',
        openOrdersQueried: true,
        openOrdersCancelled: true,
        remainingCountZero: true,
        queriedAt: DateTime.utc(2026, 11, 16, 4, 50),
        note: 'n',
        context: _context,
        activation: record,
      );
      final Map<String, dynamic> ackJson =
          jsonDecode(jsonEncode(ack.toJson())) as Map<String, dynamic>;
      expect(KillChecklistAck.fromJson(ackJson), ack);
      final Map<String, dynamic> oldJson = Map<String, dynamic>.of(ackJson)
        ..remove('activation');
      final KillChecklistAck old = KillChecklistAck.fromJson(oldJson);
      expect(
        old.activation,
        isNull,
        reason: '추가형 — 옛 JSON(activation 없음)이 그대로 열린다',
      );
      expect(old, ack.copyWith(activation: null));
    });

    test('C-55 ⑫ 열거 와이어 — 값 이름 SCREAMING_SNAKE · 값 집합 == 엔진 값 이름 · 동작 id == 엔진 명령 kind', () {
      final Map<String, (List<Enum>, List<String>, List<String>)> table =
          <String, (List<Enum>, List<String>, List<String>)>{
            // 엔진 core `safety/kill_checklist.dart:12` KillReasonKind.
            'KillActivationReason': (
              KillActivationReason.values,
              <String>[
                for (final KillActivationReason v
                    in KillActivationReason.values)
                  v.wire,
              ],
              <String>['rule', 'emotion'],
            ),
            // `:21` KillScope.
            'KillActivationScope': (
              KillActivationScope.values,
              <String>[
                for (final KillActivationScope v in KillActivationScope.values)
                  v.wire,
              ],
              <String>['newEntriesOnly', 'liquidateAll'],
            ),
            // `:157` ScenarioStatus.
            'KillResumeScenario': (
              KillResumeScenario.values,
              <String>[
                for (final KillResumeScenario v in KillResumeScenario.values)
                  v.wire,
              ],
              <String>['resolved', 'ongoing', 'notApplicable'],
            ),
            // `:169` ResumeConditionStatus.
            'KillResumeCondition': (
              KillResumeCondition.values,
              <String>[
                for (final KillResumeCondition v in KillResumeCondition.values)
                  v.wire,
              ],
              <String>['met', 'unmet'],
            ),
          };
      for (final MapEntry<String, (List<Enum>, List<String>, List<String>)> e
          in table.entries) {
        final (List<Enum> values, List<String> wires, List<String> engine) =
            e.value;
        expect(
          <String>[for (final Enum v in values) v.name],
          engine,
          reason: '${e.key} — 값 이름 ≠ 엔진 값 이름',
        );
        expect(wires, <String>[
          for (final Enum v in values) _screamingSnake(v.name),
        ], reason: '${e.key} — 와이어 ≠ 값 이름 SCREAMING_SNAKE(K10)');
      }
      // 엔진 ds `kill_switch_store.dart:352` · `pledge_store.dart:15` 명령 kind(🔵 v1.22 새 8 = C-56 ⑨).
      expect(
        <String>[for (final SafetyActionId v in _v121SafetyIds) v.wire],
        <String>['KILL_SWITCH_RESUME', 'PLEDGE_WRITE', 'PLEDGE_EDIT'],
      );
    });

    test('C-55 ⑬ 사전 — 킬스위치 12 · 공용 2 · 서약 6(공용 0) · 게이지 4 · 등재 4 · 두 벌 0', () {
      expect(KillSwitchResultCodes.values, hasLength(12));
      expect(SafetyCommonResultCodes.values, <String>{
        'TRUSTED_TIME_UNKNOWN',
        'JOURNAL_ID_TAKEN',
      });
      expect(PledgeResultCodes.values, hasLength(6));
      expect(
        PledgeResultCodes.values,
        isNot(contains(SafetyCommonResultCodes.trustedTimeUnknown)),
      );
      expect(GaugeCodes.values, <String>{
        'DD_RECOVERY',
        'HOLD',
        'BULL_STREAK',
        'COOLDOWN',
      });
      const Map<String, Set<String>> mine = <String, Set<String>>{
        'kill_switch_result': KillSwitchResultCodes.values,
        'safety_common_result': SafetyCommonResultCodes.values,
        'pledge_result': PledgeResultCodes.values,
        'gauge': GaugeCodes.values,
      };
      for (final MapEntry<String, Set<String>> e in mine.entries) {
        expect(ContractCodes.byDomain[e.key], e.value, reason: e.key);
        for (final MapEntry<String, Set<String>> other
            in ContractCodes.byDomain.entries) {
          if (other.key == e.key) {
            continue;
          }
          expect(
            e.value.intersection(other.value),
            isEmpty,
            reason: '${e.key} ∩ ${other.key} — 같은 글자 두 사전',
          );
        }
      }
    });

    test('C-55 ⑭ 게이지 — 전 표본 release_progress·cooldown 의 code ∈ GaugeCodes', () {
      int seen = 0;
      for (final String path in FixturePaths.all) {
        for (final Map<String, Object?> g in _gauges(_env(path)['rows'])) {
          seen++;
          expect(
            GaugeCodes.values,
            contains(g['code']),
            reason: '$path — 게이지 코드 ${g['code']}',
          );
        }
      }
      expect(seen, greaterThan(0), reason: '게이지를 하나도 못 읽었다 — 걷기가 공허하다');
    });

    test(
      'C-55 ⑮ 라우트 — 상수 글자 · m5SimOpeningCash 바로 뒤 차례 3 · x1Migration 앞 · 일치 규칙',
      () {
        expect(AppRoutes.m5StoppedDecision, 'aaq://m5/stopped-decision');
        expect(AppRoutes.m5Pledge, 'aaq://m5/pledge');
        expect(AppRoutes.m5RuleChangeGate, 'aaq://m5/rule-change-gate');
        final int at = AppRoutes.all.indexOf(AppRoutes.m5SimOpeningCash);
        expect(at, isNonNegative);
        expect(AppRoutes.all.sublist(at + 1, at + 5), <String>[
          AppRoutes.m5StoppedDecision,
          AppRoutes.m5Pledge,
          AppRoutes.m5RuleChangeGate,
          AppRoutes.x1Migration,
        ]);
        for (final String r in <String>[
          AppRoutes.m5StoppedDecision,
          AppRoutes.m5Pledge,
          AppRoutes.m5RuleChangeGate,
        ]) {
          expect(AppRoutes.isRegistered(r), isTrue, reason: r);
        }
        expect(AppRoutes.isRegistered('aaq://m5/pledge/1'), isFalse);
      },
    );

    test('C-55 ⑯ 포트 경계 — ui_*(ui_safety 제외) 소스에 M5 포트·VM·창구 이름 0', () {
      final List<String> offenders = <String>[];
      for (final String name in uiPackageNames) {
        if (name == 'ui_safety') {
          continue;
        }
        final Directory lib = Directory('${repoRoot.path}/packages/$name/lib');
        if (!lib.existsSync()) {
          continue;
        }
        for (final File f in dartSourcesIn(lib)) {
          final String code = stripCommentsAndStrings(f.readAsStringSync());
          for (final String symbol in _portSymbols) {
            if (RegExp('\\b$symbol\\b').hasMatch(code)) {
              offenders.add('${shortPath(f)}: $symbol');
            }
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: '🔴 M5 쓰기·게이트는 ui_safety 만 부른다(01 §30 · K5) — 다른 화면이 부르면 M5 경계가 깨진다.',
      );
    });

    test('C-55 ⑰ 글자 — DRY_RUN·손익 낱말·금액·금지어·카운트다운·해제 버튼·8자리 숫자 0', () {
      for (final String path in _all) {
        for (final String s in _strings(_rows(path))) {
          for (final String w in _forbiddenWords) {
            expect(s.contains(w), isFalse, reason: '$path — «$w»: $s');
          }
          expect(_money.hasMatch(s), isFalse, reason: '$path — 금액: $s');
          expect(
            _longDigits.hasMatch(s),
            isFalse,
            reason: '$path — 8자리 숫자: $s',
          );
        }
      }
    });

    test('C-55 ⑱ 받침대 — 창구 2 = 동기 throw · SafetyActions = Future 에러 · 에러 스트림(동기 throw 0)', () async {
      expect(
        () => UnimplementedKillSwitchGateRepository().watchResumeGate(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => UnimplementedPledgeRepository().watchPledge(),
        throwsA(isA<UnimplementedError>()),
      );
      final UnimplementedSafetyActions actions = UnimplementedSafetyActions();
      late final Future<SafetyActionResult> run;
      late final Future<SafetyActionResult> item;
      late final Future<SafetyActionResult> pledge;
      late final Stream<SafetyActionResult> watch;
      expect(() {
        run = actions.run(SafetyActionId.pledgeWrite);
        item = actions.runKillResumeItem(
          const KillResumeItemSubmission(itemNo: 1),
        );
        pledge = actions.runPledge(
          const PledgeSubmission(
            id: SafetyActionId.pledgeWrite,
            sentences: <String>[],
          ),
        );
        watch = actions.watch('ar_fake');
      }, returnsNormally);
      await expectLater(run, throwsA(isA<UnimplementedError>()));
      await expectLater(item, throwsA(isA<UnimplementedError>()));
      await expectLater(pledge, throwsA(isA<UnimplementedError>()));
      await expectLater(watch, emitsError(isA<UnimplementedError>()));
    });

    test('C-55 ⑲ F3 — 전 표본 ramp_level ≠ L0', () {
      int seen = 0;
      for (final String path in FixturePaths.all) {
        walkJson(_env(path), (String p, String key, Object? value) {
          if (key != 'ramp_level') return;
          seen++;
          expect(
            value,
            isNot('L0'),
            reason: '$path $p — v1 엔진은 L0 을 내지 않는다(v1.19 K11)',
          );
        });
      }
      expect(seen, greaterThan(0), reason: 'ramp_level 을 하나도 못 읽었다');
    });
  });
}

/// v1.21 동작 3(🔵 v1.22 +8 은 C-56 이 본다 — 01 §31).
const Set<SafetyActionId> _v121SafetyIds = <SafetyActionId>{
  SafetyActionId.killSwitchResume,
  SafetyActionId.pledgeWrite,
  SafetyActionId.pledgeEdit,
};
