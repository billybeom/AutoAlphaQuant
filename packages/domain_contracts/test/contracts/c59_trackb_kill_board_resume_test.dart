// C-59 트랙 B — M5-1 킬스위치 화면 · 발동 뒤 기록 폼 · M5-5 차단 보드 · X2 재개 리포트 감싸개 · 발동 인자 0 — 01 §34
// (🆕 계약 v1.25 · 트랙 B 선행 · 발주자 위임 2026-11-14 — 권고대로 · K144~K165).
//
// 정의: 「M5-1 은 `KillSwitchScreenVm`(발동 버튼 = 꺼짐만 · 확인 대화 0 · 취소 보고 · 발동 뒤 기록 폼 = SPEC 카드 ④ (가) 원문 ·
//        게이트 링크 = 기록 뒤만 · 🔴 잠김에도 발동 버튼)을 `KillSwitchGateRepository.watchKillSwitch()` 로, M5-5 는
//        `BlockBoardVm`(킬스위치 진입 늘 · 사다리 = 엔진 글자 · 행 = 플래그 사전 글자)을 `BlockBoardRepository.watchBoard()` 로,
//        X2 리포트는 감싸개 `ResumeReportVm`(원판 그대로 + 시각·단계·빈 문장)을 `ResumeGateRepository.watchReport()` 로 읽는다 ·
//        `CommandApi.activateKillSwitch()` 는 인자 0(화면이 기기 id·사유를 짓지 않는다) · 표본에 금액·수량·주문번호·intent id 0」.
//   ① 허용 키 ② 꺼짐 ⇔ 버튼 ③ 머리 글자 ④ 폼 자리 ⑤ 폼 문항 ⑥ 잠김 비대칭 ⑦ 취소 보고 ⑧ 발동 접수증 ⑨ 발동 서명
//   ⑩ 보드 링크 ⑪ 보드 사다리 ⑫ 보드 행 ⑬ 게이트 꺼짐 ⑭ 리포트 감싸개 ⑮ X2 게이트 막힌 것 0 ⑯ 사전·슬롯·받침대 ⑰ 포트 경계·글자.
//
// 🔴 픽스처 불변식 + 포트 경계 스캔만 본다 — M5·X2 화면 규칙(확인 대화 0 · 해제 버튼 0 · 순차)은 `ui_safety` 카드(E11q-b1~b3) 몫.
// 🔴 리터럴 = 표본 id·키·코드·`FixturePaths` + 엔진·SPEC 글자 표(출처 주석 파일:줄 · origin/main 85456ab2 · K159).

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// M5-1 VM 7벌.
const List<String> _ksVms = <String>[
  FixturePaths.m5KillSwitchOff,
  FixturePaths.m5KillSwitchActiveUnrecorded,
  FixturePaths.m5KillSwitchCancelReadFailed,
  FixturePaths.m5KillSwitchRecordedWaiting,
  FixturePaths.m5KillSwitchRecordedReady,
  FixturePaths.m5KillSwitchLocked,
  FixturePaths.m5KillSwitchActiveLocked,
];

/// M5-5 VM 4벌.
const List<String> _bbVms = <String>[
  FixturePaths.m5BlockBoardClear,
  FixturePaths.m5BlockBoardKillActive,
  FixturePaths.m5BlockBoardResumeIncomplete,
  FixturePaths.m5BlockBoardStopped,
];

/// X2 리포트 감싸개 3벌.
const List<String> _rrVms = <String>[
  FixturePaths.x2ResumeReportScreenNormal,
  FixturePaths.x2ResumeReportScreenRecoveryFull,
  FixturePaths.x2ResumeReportScreenEmpty,
];

/// v1.25 신설 17벌.
const List<String> _new = <String>[
  ..._ksVms,
  FixturePaths.m5KillSwitchActivateReceipts,
  FixturePaths.m5KillResumeGateOff,
  ..._bbVms,
  ..._rrVms,
  FixturePaths.x2ResumeGateClear,
];

/// ① §4-1 JSON 키(선언 차례).
const List<String> _ksKeys = <String>[
  'state_label',
  'level',
  'activated_text',
  'activate_label',
  'path_lines',
  'cancel_headline',
  'cancel_rows',
  'checklist_state_label',
  'form',
  'eta_text',
  'gate_link',
  'locked_label',
  'as_of',
];
const List<String> _cancelKeys = <String>[
  'symbol_text',
  'outcome_code',
  'outcome_label',
  'level',
];
const List<String> _formKeys = <String>[
  'items',
  'ack_queried_label',
  'ack_cancelled_label',
  'ack_remaining_zero_label',
  'note_label',
  'notice_text',
];
const List<String> _itemKeys = <String>[
  'item_no',
  'label',
  'hint_text',
  'fixed_text',
  'choices',
];
const List<String> _choiceKeys = <String>['label', 'reason_kind', 'scope'];
const List<String> _bbKeys = <String>[
  'headline',
  'level',
  'breaker_label',
  'rows',
  'gauges',
  'ladder',
  'stopped_decision_link',
  'kill_switch_link',
  'empty_label',
  'as_of',
];
const List<String> _bbRowKeys = <String>[
  'row_id',
  'label',
  'set_at_text',
  'clear_kind_label',
  'clear_instruction',
  'level',
  'link',
];
const List<String> _rrKeys = <String>[
  'report',
  'period_text',
  'phase_label',
  'empty_label',
  'as_of',
];

/// ① 금지 키 — 금액·수량·주문번호·intent id·기기 id · 카운트다운 원값 · 해제 칸 · 프리필(K151 · K159).
const Set<String> _badKeys = <String>{
  'intent_id',
  'order_no',
  'broker_order_no',
  'quantity',
  'remaining_qty',
  'device_id',
  'countdown',
  'remaining_seconds',
  'release_action',
  'deactivate',
  'prefill',
  'example',
  'journal_decision_id',
};

// ── 엔진·SPEC 글자 표(origin/main 85456ab2) ─────────────────────────────

/// ③ core `safety/kill_switch.dart:149` · :154 · :158 · :165 `killSwitchViewOf` 글자.
const String _off = '킬스위치 꺼짐';
const String _on = '킬스위치 작동 중 — 신규 주문을 막고 있습니다';
const String _checklistFirst = '체크리스트를 먼저 마치십시오 — 마친 때부터 48시간을 셉니다';
const String _etaReady = '해제 가능 — 재개 체크리스트를 진행하십시오';

/// ③ 시각 꼴 — `kill_switch.dart:159` «체크리스트 확인 ${_kstMdHm(…)}» · :164 «해제 가능 예정 ${_kstMdHm(…)}».
final RegExp _checklistDone = RegExp(r'^체크리스트 확인 \d\d-\d\d \d\d:\d\d$');
final RegExp _etaWait = RegExp(r'^해제 가능 예정 \d\d-\d\d \d\d:\d\d$');

/// ⑤ SPEC v2.40 04 §3-6 표 «카드 ④(발동 뒤 기록)» 열 원문 7(01 §30 K38 정규화 — 굵게·🔴 제거 · 5번 선택지 분리).
const List<String> _specItems = <String>[
  '규칙이 지시한 행동은 무엇인가',
  '지금 끄는 것이 규칙인가 감정인가(감정 · 강도 · 수면)',
  '사전에 문서화한 시나리오인가(W번호 · 트리거 ID)',
  '재개 조건을 지금 적을 수 있는가',
  '끄는 범위',
  '재개 최소 대기 시작 시각(48h)',
  '저널 작성 완료(decision_id)',
];

/// ⑤ 03 §7-4 종이 카드 원문 보탬 줄(3·5번만 — K148).
const Map<int, String> _hints = <int, String>{
  3: '해당 없으면, 이것은 새로운 상황이 아니라 대개 새로운 감정이다.',
  5: '전량 청산은 2단계 확인 + 대기 필요. 기본은 신규 진입 차단.',
};

/// ⑤ core `safety/kill_checklist.dart:86` · :89 · :92 · :95 `KillAckAnswers` 주석 원문.
const List<String> _ackLabels = <String>[
  '미체결 주문을 조회했다',
  '전량 취소했다',
  '잔여 0 을 확인했다',
  '1줄',
];

/// ⑦ core `safety/kill_activation.dart:53-65` `KillCancelOutcome.wire`.
const Set<String> _engineCancelWires = <String>{
  'CANCELLED',
  'FAILED',
  'UNKNOWN',
  'NOT_CANCELLED_UNKNOWN_INTENT',
  'IN_FLIGHT',
};

/// ⑫ core `safety/safety_text.dart:49-51` · :73-75 `kFlagDictionary`(라벨 · 해제 문장 — 표본이 쓰는 두 플래그).
const Map<String, List<String>> _flagText = <String, List<String>>{
  'RESUME_INCOMPLETE': <String>['재개 점검이 끝나지 않았습니다', '재개 점검이 끝나면 자동으로 풀립니다.'],
  'JOURNAL_MISSING': <String>['일지가 비어 있습니다', '일지를 채우면 자동으로 풀립니다.'],
};

/// ⑫ 보드 행 id — 킬스위치(플래그가 아니다 · K155).
const String _killRowId = 'KILL_SWITCH';

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _rows(String path) => (_env(path)['rows']! as List)
    .cast<Map<String, Object?>>()
    .toList(growable: false);

Map<String, Object?> _vm(String path) => _rows(path).single;

List<Map<String, Object?>> _maps(Object? v) =>
    (v! as List).cast<Map<String, Object?>>().toList(growable: false);

/// 키 몇 개를 뺀 행의 JSON(변종 동치).
String _without(Map<String, Object?> row, Set<String> keys) =>
    jsonEncode(<String, Object?>{
      for (final MapEntry<String, Object?> e in row.entries)
        if (!keys.contains(e.key)) e.key: e.value,
    });

/// 전 키(재귀).
Set<String> _allKeys(Object? v) {
  final Set<String> out = <String>{};
  void walk(Object? x) {
    if (x is Map) {
      x.forEach((Object? k, Object? y) {
        out.add(k! as String);
        walk(y);
      });
    } else if (x is List) {
      x.forEach(walk);
    }
  }

  walk(v);
  return out;
}

/// 메타·`deep_link`·`report`(엔진 원판 복사 — ⑭ 가 바이트로 본다)를 뺀 전 문자열.
List<String> _strings(Object? v) {
  final List<String> out = <String>[];
  void walk(Object? x) {
    if (x is Map) {
      x.forEach((Object? k, Object? y) {
        if (k != 'meta' && k != 'deep_link' && k != 'report') walk(y);
      });
    } else if (x is List) {
      x.forEach(walk);
    } else if (x is String) {
      out.add(x);
    }
  }

  walk(v);
  return out;
}

/// 링크 목적지가 실재 라우트(파라미터 패턴 포함)인가.
bool _isRoute(String link) => AppRoutes.all.any((String r) {
  final String rx = RegExp.escape(r).replaceAll(RegExp(r':[A-Za-z]+'), '[^/]+');
  return RegExp('^$rx\$').hasMatch(link);
});

List<String> _deepLinks(Object? v) {
  final List<String> out = <String>[];
  void walk(Object? x) {
    if (x is Map) {
      x.forEach((Object? k, Object? y) {
        if (k == 'deep_link' && y is String) {
          out.add(y);
        } else {
          walk(y);
        }
      });
    } else if (x is List) {
      x.forEach(walk);
    }
  }

  walk(v);
  return out;
}

bool _isOff(Map<String, Object?> vm) => vm['state_label'] == _off;

void main() {
  group('C-59 트랙 B — M5-1 킬스위치 화면 · 폼 · M5-5 보드 · X2 리포트 감싸개 · 발동 인자 0 (01 §34 · 계약 v1.25)', () {
    test(
      'C-59 ① 허용 키 — 새 VM 키 == toJson == 선언(차례 포함) · 행·폼·선택지 키 · 금지 키 0',
      () {
        for (final String path in _ksVms) {
          final Map<String, Object?> row = _vm(path);
          expect(row.keys.toList(), _ksKeys, reason: '$path — VM 키');
          expect(
            KillSwitchScreenVm.fromJson(row).toJson().keys.toList(),
            _ksKeys,
            reason: '$path — toJson 키',
          );
          for (final Map<String, Object?> c in _maps(row['cancel_rows'])) {
            expect(c.keys.toList(), _cancelKeys, reason: '$path — 취소 행 키');
            expect(
              KillCancelRow.fromJson(c).toJson().keys.toList(),
              _cancelKeys,
            );
          }
          final Map<String, Object?>? form =
              row['form'] as Map<String, Object?>?;
          if (form != null) {
            expect(form.keys.toList(), _formKeys, reason: '$path — 폼 키');
            expect(
              KillActivationFormVm.fromJson(form).toJson().keys.toList(),
              _formKeys,
            );
            for (final Map<String, Object?> it in _maps(form['items'])) {
              expect(it.keys.toList(), _itemKeys, reason: '$path — 문항 키');
              for (final Map<String, Object?> c in _maps(it['choices'])) {
                expect(c.keys.toList(), _choiceKeys, reason: '$path — 선택지 키');
              }
            }
          }
        }
        for (final String path in _bbVms) {
          final Map<String, Object?> row = _vm(path);
          expect(row.keys.toList(), _bbKeys, reason: '$path — VM 키');
          expect(
            BlockBoardVm.fromJson(row).toJson().keys.toList(),
            _bbKeys,
            reason: '$path — toJson 키',
          );
          for (final Map<String, Object?> r in _maps(row['rows'])) {
            expect(r.keys.toList(), _bbRowKeys, reason: '$path — 행 키');
            expect(
              BlockBoardRow.fromJson(r).toJson().keys.toList(),
              _bbRowKeys,
            );
          }
        }
        for (final String path in _rrVms) {
          final Map<String, Object?> row = _vm(path);
          expect(row.keys.toList(), _rrKeys, reason: '$path — VM 키');
          expect(
            ResumeReportVm.fromJson(row).toJson().keys.toList(),
            _rrKeys,
            reason: '$path — toJson 키',
          );
        }
        for (final String path in _new) {
          expect(
            _allKeys(_env(path)['rows']).intersection(_badKeys),
            isEmpty,
            reason: '$path — 금지 키',
          );
        }
      },
    );

    test('C-59 ② 꺼짐 ⇔ 버튼 — 발동 버튼 = 꺼짐만 · 꺼짐 ⇒ 발동 줄·보고·기록·폼·ETA·게이트 0 · 경로 안내 = 꺼짐만', () {
      int offs = 0;
      for (final String path in _ksVms) {
        final Map<String, Object?> vm = _vm(path);
        final bool off = _isOff(vm);
        expect(vm['activate_label'] != null, off, reason: '$path — 버튼 ⇔ 꺼짐');
        if ((vm['path_lines']! as List).isNotEmpty) {
          expect(off, isTrue, reason: '$path — 경로 안내는 꺼짐만');
        }
        if (off) {
          offs++;
          for (final String k in <String>[
            'activated_text',
            'cancel_headline',
            'checklist_state_label',
            'form',
            'eta_text',
            'gate_link',
          ]) {
            expect(vm[k], isNull, reason: '$path — 꺼짐인데 $k');
          }
          expect(vm['cancel_rows'], isEmpty, reason: path);
        } else {
          expect(vm['activated_text'], isNotNull, reason: path);
        }
      }
      expect(offs, 2, reason: '꺼짐 표본 = off · locked');
    });

    test('C-59 ③ 머리 글자 — 머리 == 엔진 두 문장 · 기록 상태·ETA == 엔진 문장 또는 엔진 시각 꼴', () {
      for (final String path in _ksVms) {
        final Map<String, Object?> vm = _vm(path);
        expect(<String>[_off, _on], contains(vm['state_label']), reason: path);
        final String? cl = vm['checklist_state_label'] as String?;
        if (cl != null) {
          expect(
            cl == _checklistFirst || _checklistDone.hasMatch(cl),
            isTrue,
            reason: '$path — 기록 상태 «$cl»',
          );
        }
        final String? eta = vm['eta_text'] as String?;
        if (eta != null) {
          expect(
            eta == _etaReady || _etaWait.hasMatch(eta),
            isTrue,
            reason: '$path — ETA «$eta»',
          );
        }
      }
    });

    test('C-59 ④ 폼 자리 — 폼 ⇒ 켜짐 ∧ 기록 전 ∧ 잠김 0 ∧ 게이트·ETA 0 · 기록 뒤 ⇒ 폼 0 ∧ 게이트 = m5ReleaseGate', () {
      int forms = 0;
      int gates = 0;
      for (final String path in _ksVms) {
        final Map<String, Object?> vm = _vm(path);
        if (vm['form'] != null) {
          forms++;
          expect(_isOff(vm), isFalse, reason: path);
          expect(vm['checklist_state_label'], _checklistFirst, reason: path);
          expect(vm['locked_label'], isNull, reason: path);
          expect(vm['gate_link'], isNull, reason: path);
          expect(vm['eta_text'], isNull, reason: path);
        }
        final String? cl = vm['checklist_state_label'] as String?;
        if (cl != null && _checklistDone.hasMatch(cl)) {
          gates++;
          expect(vm['form'], isNull, reason: '$path — 기록 뒤 폼');
          expect(
            (vm['gate_link']! as Map<String, Object?>)['deep_link'],
            AppRoutes.m5ReleaseGate,
            reason: '$path — 게이트 링크',
          );
          expect(vm['eta_text'], isNotNull, reason: path);
        } else {
          expect(vm['gate_link'], isNull, reason: '$path — 기록 전 게이트 링크');
        }
      }
      expect(forms, 2, reason: '폼 표본 = active_unrecorded · cancel_read_failed');
      expect(gates, 2, reason: '기록 뒤 표본 = recorded_waiting · recorded_ready');
    });

    test('C-59 ⑤ 폼 문항 — 7행 == SPEC 원문 · 2·5 선택지(칸 정확히 하나) · 6·7 고정 글자 · 힌트 3·5 = 종이 카드 · 확인 라벨 == 엔진', () {
      for (final String path in <String>[
        FixturePaths.m5KillSwitchActiveUnrecorded,
        FixturePaths.m5KillSwitchCancelReadFailed,
      ]) {
        final KillActivationFormVm f = KillSwitchScreenVm.fromJson(_vm(path))
            .form!;
        expect(
          <int>[for (final KillActivationItemRow r in f.items) r.itemNo],
          <int>[1, 2, 3, 4, 5, 6, 7],
          reason: '$path — 번호 차례',
        );
        expect(
          <String>[for (final KillActivationItemRow r in f.items) r.label],
          _specItems,
          reason: '$path — 문항 글자(K38)',
        );
        for (final KillActivationItemRow r in f.items) {
          final int n = r.itemNo;
          expect(
            r.choices.isNotEmpty,
            n == 2 || n == 5,
            reason: '$path $n번 선택지',
          );
          expect(
            r.fixedText != null,
            n == 6 || n == 7,
            reason: '$path $n번 고정 글자',
          );
          expect(r.hintText, _hints[n], reason: '$path $n번 힌트');
          expect(
            r.hintText ?? '',
            isNot(contains('끄지 않는다')),
            reason: '$path $n번 — K148',
          );
          for (final KillActivationChoice c in r.choices) {
            expect(
              (c.reasonKind == null) != (c.scope == null),
              isTrue,
              reason: '$path $n번 «${c.label}» — 칸 정확히 하나',
            );
            if (n == 2) expect(c.reasonKind, isNotNull, reason: '$path 2번');
            if (n == 5) expect(c.scope, isNotNull, reason: '$path 5번');
          }
        }
        expect(
          <KillActivationReason?>{
            for (final KillActivationChoice c in f.items[1].choices)
              c.reasonKind,
          },
          KillActivationReason.values.toSet(),
          reason: '$path — 2번 = 규칙·감정 전수',
        );
        expect(
          <KillActivationScope?>{
            for (final KillActivationChoice c in f.items[4].choices) c.scope,
          },
          KillActivationScope.values.toSet(),
          reason: '$path — 5번 = 범위 전수',
        );
        expect(
          <String>[
            f.ackQueriedLabel,
            f.ackCancelledLabel,
            f.ackRemainingZeroLabel,
            f.noteLabel,
          ],
          _ackLabels,
          reason: '$path — 확인 라벨(엔진 주석 원문)',
        );
        expect(f.noticeText, isNotNull, reason: '$path — 고지(기록 = 주문 0)');
      }
    });

    test('C-59 ⑥ 잠김 비대칭 — 잠김 ⇒ 폼 0 · 꺼짐+잠김 = 꺼짐 + 잠김 글자(🔴 발동 버튼 남음) · 켜짐+잠김 = 켜짐 − 폼 + 잠김', () {
      for (final String path in _ksVms) {
        final Map<String, Object?> vm = _vm(path);
        if (vm['locked_label'] != null) {
          expect(vm['form'], isNull, reason: '$path — 잠김에 폼');
        }
      }
      final Map<String, Object?> locked = _vm(FixturePaths.m5KillSwitchLocked);
      expect(
        locked['activate_label'],
        isNotNull,
        reason: '🔴 잠김이 발동 버튼을 지웠다(K150)',
      );
      expect(
        _without(locked, <String>{'locked_label'}),
        _without(_vm(FixturePaths.m5KillSwitchOff), <String>{'locked_label'}),
        reason: '꺼짐+잠김 = 꺼짐 + 잠김 글자',
      );
      expect(
        _without(_vm(FixturePaths.m5KillSwitchActiveLocked), <String>{
          'locked_label',
          'form',
        }),
        _without(_vm(FixturePaths.m5KillSwitchActiveUnrecorded), <String>{
          'locked_label',
          'form',
        }),
        reason: '켜짐+잠김 = 켜짐 − 폼 + 잠김 글자',
      );
      expect(
        <String>[
          for (final String path in _ksVms)
            if (_vm(path)['locked_label'] != null) path,
        ],
        <String>[
          FixturePaths.m5KillSwitchLocked,
          FixturePaths.m5KillSwitchActiveLocked,
        ],
      );
    });

    test('C-59 ⑦ 취소 보고 — 사전 == 엔진 wire 5 · 코드 ∈ 사전 · 켜짐만 · 읽기 실패 = 행 0 ∧ 머리 · 종목 = 합성 6자리', () {
      expect(KillCancelOutcomeCodes.values, _engineCancelWires);
      int rows = 0;
      for (final String path in _ksVms) {
        final Map<String, Object?> vm = _vm(path);
        for (final Map<String, Object?> c in _maps(vm['cancel_rows'])) {
          rows++;
          expect(_isOff(vm), isFalse, reason: path);
          expect(
            KillCancelOutcomeCodes.values,
            contains(c['outcome_code']),
            reason: path,
          );
          expect(
            c['symbol_text'] as String,
            matches(RegExp(r'^\(합성\) [0-9]{6}$')),
            reason: path,
          );
        }
        if (vm['cancel_headline'] != null) {
          expect(_isOff(vm), isFalse, reason: path);
        }
      }
      expect(rows, greaterThan(0));
      final Map<String, Object?> fail = _vm(
        FixturePaths.m5KillSwitchCancelReadFailed,
      );
      expect(fail['cancel_rows'], isEmpty);
      expect(fail['cancel_headline'], isNotNull);
    });

    test('C-59 ⑧ 발동 접수증 — KILL_SWITCH_ACTIVATE 2행 · 거부 코드 0 · 상태 = EXECUTED(폰) · REQUESTED(뷰어)', () {
      final List<CommandReceipt> rs = <CommandReceipt>[
        for (final Map<String, Object?> r in _rows(
          FixturePaths.m5KillSwitchActivateReceipts,
        ))
          CommandReceipt.fromJson(r),
      ];
      expect(rs, hasLength(2));
      expect(rs.map((CommandReceipt r) => r.kind).toSet(), <CommandKind>{
        CommandKind.killSwitchActivate,
      });
      expect(
        rs.map((CommandReceipt r) => r.rejectReasonCode).toSet(),
        <String?>{null},
        reason: '발동 거부 코드를 지어내지 않는다(K149)',
      );
      expect(rs.map((CommandReceipt r) => r.state).toSet(), <CommandState>{
        CommandState.executed,
        CommandState.requested,
      });
    });

    test('C-59 ⑨ 발동 서명 — CommandApi.activateKillSwitch() 인자 0 · reasonFreeText·deviceId 0 · 받침대 throw', () {
      final File api = File('${libDir.path}/src/commands/command_api.dart');
      final String code = stripComments(api.readAsStringSync());
      expect(
        RegExp(r'Future<CommandReceipt>\s+activateKillSwitch\(\)\s*;')
            .hasMatch(code),
        isTrue,
        reason: '🔴 발동은 인자 0(K149)',
      );
      expect(code, isNot(contains('reasonFreeText')));
      expect(code, isNot(contains('deviceId')));
      expect(
        () => UnimplementedCommandApi().activateKillSwitch(),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('C-59 ⑩ 보드 링크 — 킬스위치 진입 늘(m5KillSwitch) · 재개 결정 ⇒ m5StoppedDecision ∧ 정지 · 링크 목적지 = 실재 라우트', () {
      for (final String path in _bbVms) {
        final Map<String, Object?> vm = _vm(path);
        expect(
          (vm['kill_switch_link']! as Map<String, Object?>)['deep_link'],
          AppRoutes.m5KillSwitch,
          reason: '$path — 끄기는 언제나(K154)',
        );
        final Map<String, Object?>? sd =
            vm['stopped_decision_link'] as Map<String, Object?>?;
        if (sd != null) {
          expect(sd['deep_link'], AppRoutes.m5StoppedDecision, reason: path);
          expect(vm['breaker_label'], '정지', reason: path);
        }
      }
      for (final String path in _new) {
        for (final String link in _deepLinks(_env(path)['rows'])) {
          expect(_isRoute(link), isTrue, reason: '$path — 없는 라우트 $link');
        }
      }
      expect(
        _vm(FixturePaths.m5BlockBoardStopped)['stopped_decision_link'],
        isNotNull,
      );
    });

    test('C-59 ⑪ 보드 사다리 — 사다리 행 == m5/breaker_ladder_* 원판 · 지금 단 하나 · 그 라벨 == breaker_label', () {
      final Object? normal = _vm(FixturePaths.m5BreakerLadderNormal)['rows'];
      final Object? stopped = _vm(FixturePaths.m5BreakerLadderStopped)['rows'];
      for (final String path in _bbVms) {
        final Map<String, Object?> vm = _vm(path);
        final Map<String, Object?> ladder =
            vm['ladder']! as Map<String, Object?>;
        final List<Map<String, Object?>> rows = _maps(ladder['rows']);
        final List<Map<String, Object?>> cur = <Map<String, Object?>>[
          for (final Map<String, Object?> r in rows)
            if (r['current'] == true) r,
        ];
        expect(cur, hasLength(1), reason: path);
        expect(cur.single['label'], vm['breaker_label'], reason: path);
        expect(
          jsonEncode(ladder['rows']),
          jsonEncode(
            path == FixturePaths.m5BlockBoardStopped ? stopped : normal,
          ),
          reason: '$path — 사다리 글자 = 엔진 원판',
        );
      }
    });

    test('C-59 ⑫ 보드 행 — 행 id ∈ FlagIds ∪ KILL_SWITCH · 플래그 글자 == 엔진 사전 · 빈 문장 ⇒ 행 0 · 게이지 ∈ GaugeCodes', () {
      for (final String path in _bbVms) {
        final Map<String, Object?> vm = _vm(path);
        final List<Map<String, Object?>> rows = _maps(vm['rows']);
        if (vm['empty_label'] != null) {
          expect(rows, isEmpty, reason: path);
        }
        for (final Map<String, Object?> r in rows) {
          final String id = r['row_id']! as String;
          expect(
            <String>{...FlagIds.values, _killRowId},
            contains(id),
            reason: path,
          );
          final List<String>? want = _flagText[id];
          if (want != null) {
            expect(
              <Object?>[r['label'], r['clear_instruction']],
              want,
              reason: '$path $id — 플래그마다 다른 문장(엔진 사전)',
            );
          }
          if (id == _killRowId) {
            expect(r['label'], _on, reason: path);
          }
        }
        for (final Map<String, Object?> g in _maps(vm['gauges'])) {
          expect(GaugeCodes.values, contains(g['code']), reason: path);
        }
      }
      expect(_vm(FixturePaths.m5BlockBoardClear)['empty_label'], isNotNull);
      expect(_vm(FixturePaths.m5BlockBoardKillActive)['empty_label'], isNull);
    });

    test('C-59 ⑬ 게이트 꺼짐 — 7행 글자·선택지 == ready · 머리 «킬스위치 꺼짐» · 다음·막힘·잠김·ETA·게이지 0 · 재생·답 0', () {
      final KillResumeGateVm off = KillResumeGateVm.fromJson(
        _vm(FixturePaths.m5KillResumeGateOff),
      );
      final KillResumeGateVm ready = KillResumeGateVm.fromJson(
        _vm(FixturePaths.m5KillResumeGateReady),
      );
      expect(off.readinessLabel, _off);
      expect(off.nextItemNo, isNull);
      expect(off.blockedText, isNull);
      expect(off.lockedLabel, isNull);
      expect(off.etaText, isNull);
      expect(off.cooldown, isNull);
      expect(
        <String>[for (final KillResumeItemRow r in off.items) r.label],
        <String>[for (final KillResumeItemRow r in ready.items) r.label],
      );
      expect(
        jsonEncode(<Object?>[
          for (final KillResumeItemRow r in off.items)
            <Object?>[for (final KillResumeChoice c in r.choices) c.toJson()],
        ]),
        jsonEncode(<Object?>[
          for (final KillResumeItemRow r in ready.items)
            <Object?>[for (final KillResumeChoice c in r.choices) c.toJson()],
        ]),
      );
      for (final KillResumeItemRow r in off.items) {
        expect(r.replayText, isNull, reason: '${r.itemNo}번 재생');
        expect(r.answeredText, isNull, reason: '${r.itemNo}번 답');
      }
    });

    test('C-59 ⑭ 리포트 감싸개 — report 0 ⇔ 빈 문장 · report ⇒ 시각·단계 · report == x2/resume_report_* 원판', () {
      for (final String path in _rrVms) {
        final ResumeReportVm vm = ResumeReportVm.fromJson(_vm(path));
        expect(vm.report == null, vm.emptyLabel != null, reason: path);
        if (vm.report != null) {
          expect(vm.periodText, isNotNull, reason: path);
          expect(vm.phaseLabel, isNotNull, reason: path);
        }
      }
      for (final (String wrap, String src) in <(String, String)>[
        (
          FixturePaths.x2ResumeReportScreenNormal,
          FixturePaths.x2ResumeReportNormal,
        ),
        (
          FixturePaths.x2ResumeReportScreenRecoveryFull,
          FixturePaths.x2ResumeReportRecoveryFull,
        ),
      ]) {
        expect(
          jsonEncode(_vm(wrap)['report']),
          jsonEncode(_vm(src)),
          reason: '$wrap — 원판과 다른 리포트',
        );
      }
    });

    test(
      'C-59 ⑮ X2 게이트 막힌 것 0 — 행 0 · OK · 리포트 링크 = x2ResumeReport · 잠김 0',
      () {
        final ResumeGateVm g = ResumeGateVm.fromJson(
          _vm(FixturePaths.x2ResumeGateClear),
        );
        expect(g.rows, isEmpty);
        expect(g.level, UiLevel.ok);
        expect(g.reportLink?.deepLink, AppRoutes.x2ResumeReport);
        expect(g.lockedLabel, isNull);
      },
    );

    test(
      'C-59 ⑯ 사전·슬롯·받침대 — byDomain 등재 · OpsSlotIds 2 · 창구 3 = 동기 throw · 반환 타입',
      () {
        expect(
          ContractCodes.byDomain['kill_cancel_outcome'],
          KillCancelOutcomeCodes.values,
        );
        expect(OpsSlotIds.values, <String>{
          'EMERGENCY_CARD_PRINT',
          'KILL_SWITCH',
        });
        expect(OpsSlotIds.killSwitch, 'KILL_SWITCH');
        expect(
          () => UnimplementedKillSwitchGateRepository().watchKillSwitch(),
          throwsA(isA<UnimplementedError>()),
        );
        expect(
          () => UnimplementedBlockBoardRepository().watchBoard(),
          throwsA(isA<UnimplementedError>()),
        );
        expect(
          () => UnimplementedResumeGateRepository().watchReport(),
          throwsA(isA<UnimplementedError>()),
        );
        final Stream<KillSwitchScreenVm> Function() ks =
            UnimplementedKillSwitchGateRepository().watchKillSwitch;
        final Stream<BlockBoardVm> Function() bb =
            UnimplementedBlockBoardRepository().watchBoard;
        final Stream<ResumeReportVm> Function() rr =
            UnimplementedResumeGateRepository().watchReport;
        expect(<Object>[ks, bb, rr], hasLength(3));
      },
    );

    test('C-59 ⑰ 포트 경계·글자 — ui_*(ui_safety 제외)에 새 이름 0 · 새 표본 17 에 DRY_RUN·손익·금액·카운트다운·8자리 숫자 0', () {
      final List<RegExp> names = <RegExp>[
        RegExp(r'\bKillSwitchScreenVm\b'),
        RegExp(r'\bKillActivationFormVm\b'),
        RegExp(r'\bKillCancelRow\b'),
        RegExp(r'\bBlockBoardVm\b'),
        RegExp(r'\bBlockBoardRepository\b'),
        RegExp(r'\bResumeReportVm\b'),
        RegExp(r'\bwatchKillSwitch\s*\('),
        RegExp(r'\bwatchBoard\s*\('),
        RegExp(r'\bwatchReport\s*\('),
        RegExp(r'\bKillCancelOutcomeCodes\b'),
      ];
      final List<String> offenders = <String>[];
      int scanned = 0;
      for (final String name in uiPackageNames) {
        if (name == 'ui_safety') continue;
        final Directory lib = Directory('${repoRoot.path}/packages/$name/lib');
        if (!lib.existsSync()) continue;
        for (final File f in dartSourcesIn(lib)) {
          scanned++;
          final String code = stripCommentsAndStrings(f.readAsStringSync());
          for (final RegExp rx in names) {
            if (rx.hasMatch(code)) {
              offenders.add('${shortPath(f)}: ${rx.pattern}');
            }
          }
        }
      }
      expect(scanned, greaterThan(0), reason: 'ui_*/lib 를 못 읽었다');
      expect(
        offenders,
        isEmpty,
        reason: '🔴 M5·X2 화면은 ui_safety 만 그린다(00_README §4 · K145)',
      );
      final RegExp bad = RegExp(
        r'DRY_RUN|평가손익|수익률|평가액|손익|세후|카운트다운|해제 버튼|[0-9]{8,}|[0-9][0-9,]*원|[0-9]만',
      );
      for (final String path in _new) {
        for (final String s in _strings(_env(path))) {
          expect(bad.hasMatch(s), isFalse, reason: '$path — «$s»');
        }
      }
    });
  });
}
