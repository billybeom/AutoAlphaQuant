// C-57 월 납입 설정 S13 — 투영 VM · 원문 제출 · 결과 사전 — 01 §32(🆕 계약 v1.23 · R8a 선행 · 발주자 위임 2026-11-14 —
// 권고대로 · K74~K103).
//
// 정의: 「M9 `S13` 은 엔진 `contributionSettingOf` 하나를 투영한 `MonthlyContributionVm`(잠김·버튼 칸 · `editable` = 표식)을
//        `SettingsRepository.watchContribution()` 으로 읽고, 사람이 친 금액을 **원문 그대로** `ContributionUpdateSubmission` 에 실어
//        `SettingsActions.runContributionUpdate` 로 보낸다 · 거부 코드 = 엔진 글자 1:1 사전(`ContributionResultCodes` 6 + 공용
//        `TRUSTED_TIME_UNKNOWN`) · 표본 금액 = 발주자 결정 실물 + 엔진 config 글자만」.
//   ① 허용 키 ② 잠김 ③ editable 표식 ④ 결과 id·코드 ⑤ 엔진 거부 문장 ⑥ 사전 ⑦ 금액 글자 자리 ⑧ 예정 = 지금 값 그대로
//   ⑨ 변종 동치 ⑩ 제출 DTO 왕복 ⑪ 받침대 ⑫ 포트 경계 ⑬ 글자.
//
// 🔴 픽스처 불변식 + 포트 경계 스캔만 본다 — `S13` 화면 규칙(입력칸 1 · 손질 0 · 확인 0)은 R8a 카드 정적 묶음 몫.
// 🔴 한국어 글자 단언 = 엔진 글자 표만(출처 주석 파일:줄 · origin/main 33fe351) — ⑤ 거부 문장 7 · ⑥ 사전 값 6 ·
//    ⑨ «변경 기록 없음(기본값)» · «다음 납입 주기(…)부터» 머리(core :203-204) · ⑦ 금액 글자 3(K102).

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// S13 VM 6벌.
const List<String> _vms = <String>[
  FixturePaths.m9MonthlyContribution,
  FixturePaths.m9MonthlyContributionPending,
  FixturePaths.m9MonthlyContributionNoRecord,
  FixturePaths.m9MonthlyContributionNoLimitNote,
  FixturePaths.m9MonthlyContributionLocked,
  FixturePaths.m9MonthlyContributionStale,
];

/// v1.23 신설 7벌.
const List<String> _new = <String>[
  ..._vms,
  FixturePaths.m9ContributionActionResults,
];

/// ⑦ 금액 글자가 있어도 되는 m9 표본(신설 7 + 기존 `contribution_setting_*` 2 — S7-4 입력).
const Set<String> _moneyOk = <String>{
  ..._new,
  FixturePaths.m9ContributionSettingDefault,
  FixturePaths.m9ContributionSettingNoLimitNote,
};

/// ① §4-1 JSON 키 10(선언 차례).
const List<String> _vmKeys = <String>[
  'amount_text',
  'amount_input_text',
  'equivalent_note_text',
  'applies_from_text',
  'last_changed_text',
  'editable',
  'pension_limit_note_text',
  'as_of',
  'locked_label',
  'change_label',
];

/// ① 원값·범위·쓰기·회차 id 칸 금지.
const List<String> _badKeys = <String>[
  'amount',
  'min_amount',
  'max_amount',
  'allow_zero',
  'range',
  'action_run_id',
  'device_id',
  'save_action',
  'submit_action',
  'decision_id',
];

// ── 엔진 글자 표(core · origin/main 33fe351) ───────────────────────────────

/// ⑥ 엔진 거부 코드 − 공용(core `ops/contribution_setting.dart:241-262` `ContributionRejectCodes`).
const Set<String> _engineCodes = <String>{
  'CONTRIBUTION_INPUT_BLANK',
  'CONTRIBUTION_INPUT_NEGATIVE',
  'CONTRIBUTION_INPUT_NOT_NUMBER',
  'CONTRIBUTION_INPUT_OVER_MAX',
  'CONTRIBUTION_CLOCK_NOT_ADVANCED',
  'CONTRIBUTION_UNCHANGED',
};

/// ⑤ 엔진 거부 문장(core `ops/contribution_setting.dart` `decideContributionChange` :320 · 323 · 326 · 332 · 338 · 346 · 351 —
///    :332 = `'${wonText(cfg.maxAmount)}까지 입력할 수 있습니다.'` · `maxAmount` = config 자리값 :50).
const Map<String, String> _engineReject = <String, String>{
  'CONTRIBUTION_INPUT_BLANK': '금액을 입력해 주세요.',
  'CONTRIBUTION_INPUT_NEGATIVE': '0원 이상으로 입력해 주세요.',
  'CONTRIBUTION_INPUT_NOT_NUMBER': '금액을 원 단위 숫자로 입력해 주세요.',
  'CONTRIBUTION_INPUT_OVER_MAX': '10억원까지 입력할 수 있습니다.',
  'TRUSTED_TIME_UNKNOWN': '서버 시각을 확인하지 못해 지금은 바꿀 수 없습니다. 연결을 확인한 뒤 다시 시도해 주세요.',
  'CONTRIBUTION_CLOCK_NOT_ADVANCED': '방금 바뀐 기록이 있습니다. 잠시 뒤 다시 시도해 주세요.',
  'CONTRIBUTION_UNCHANGED': '지금 금액과 같습니다.',
};

/// ⑨ 기록 없음 문장(core `ops/contribution_setting.dart:207`).
const String _noRecordText = '변경 기록 없음(기본값)';

/// ⑦ 신설 7 의 금액 글자 상한 — «10만원» = 발주자 결정 2026-09-07(core :48 `defaultAmount`) · «0원» = 05 «0 = 정상 값» ·
///    «10억원» = core :50 `maxAmount`(config 자리값 · OVER_MAX 문장 안).
const Set<String> _moneyAllowed = <String>{'10만원', '0원', '10억원'};

/// ⑦ 금액 글자.
final RegExp _money = RegExp(r'[0-9][0-9,]*(?:억|만)?[0-9,]*원');

const String _actionWire = 'SETTINGS_CONTRIBUTION_UPDATE';

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _rows(String path) => (_env(path)['rows']! as List)
    .cast<Map<String, Object?>>()
    .toList(growable: false);

Map<String, Object?> _vm(String path) => _rows(path).single;

/// 메타를 뺀 전 문자열.
List<String> _strings(Object? v) {
  final List<String> out = <String>[];
  void walk(Object? x) {
    if (x is Map) {
      x.forEach((Object? k, Object? y) {
        if (k != 'meta') walk(y);
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

void main() {
  group('C-57 월 납입 설정 S13 — 투영 VM · 원문 제출 · 결과 사전 (01 §32 · 계약 v1.23)', () {
    test('C-57 ① 허용 키 — VM 6벌 키 == toJson == 선언 10(차례 포함) · 금지 키 0 · 결과 행 키 == ActionResult', () {
      for (final String path in _vms) {
        final Map<String, Object?> row = _vm(path);
        expect(row.keys.toList(), _vmKeys, reason: '$path — VM 키');
        expect(
          MonthlyContributionVm.fromJson(row).toJson().keys.toList(),
          _vmKeys,
          reason: '$path — toJson 키',
        );
        for (final String bad in _badKeys) {
          expect(row.containsKey(bad), isFalse, reason: '$path — 금지 키 $bad');
        }
      }
      for (final Map<String, Object?> r in _rows(
        FixturePaths.m9ContributionActionResults,
      )) {
        expect(
          r.keys.toList(),
          ActionResult.fromJson(r).toJson().keys.toList(),
          reason: '결과 행 키',
        );
      }
    });

    test('C-57 ② 잠김 — locked_label ⇒ change_label null · 잠김 = _locked 한 벌', () {
      for (final String path in _vms) {
        final Map<String, Object?> row = _vm(path);
        if (row['locked_label'] != null) {
          expect(row['change_label'], isNull, reason: '$path — 잠김에 버튼');
        }
        expect(
          row['locked_label'] != null,
          path == FixturePaths.m9MonthlyContributionLocked,
          reason: '$path — 잠김 갈래',
        );
      }
    });

    test('C-57 ③ editable 표식 — 6벌 모두 editable == (change_label != null)', () {
      for (final String path in _vms) {
        final MonthlyContributionVm vm = MonthlyContributionVm.fromJson(
          _vm(path),
        );
        expect(vm.editable, vm.changeLabel != null, reason: path);
      }
    });

    test('C-57 ④ 결과 id·코드 — id 하나 · 코드 전수(6 + 공용 + 생체 + 접수) · 레벨 5값 · 넘김·재시도 0 · 회차 id 유일', () {
      final List<ActionResult> rows = _rows(
        FixturePaths.m9ContributionActionResults,
      ).map(ActionResult.fromJson).toList();
      expect(rows, hasLength(9));
      expect(rows.map((ActionResult r) => r.id).toSet(), <SettingsActionId>{
        SettingsActionId.settingsContributionUpdate,
      });
      expect(
        _rows(FixturePaths.m9ContributionActionResults)
            .map((Map<String, Object?> r) => r['id'])
            .toSet(),
        <String>{_actionWire},
      );
      expect(rows.map((ActionResult r) => r.reasonCode).toSet(), <String?>{
        ...ContributionResultCodes.values,
        SafetyCommonResultCodes.trustedTimeUnknown,
        SettingsResultCodes.biometricUnavailable,
        null,
      });
      expect(
        rows.map((ActionResult r) => r.level).toSet(),
        UiLevel.values.toSet(),
      );
      for (final ActionResult r in rows) {
        expect(r.handoffRoute, isNull, reason: r.actionRunId);
        expect(r.retryable, isFalse, reason: r.actionRunId);
      }
      expect(
        rows.map((ActionResult r) => r.actionRunId).toSet(),
        hasLength(rows.length),
      );
    });

    test('C-57 ⑤ 엔진 거부 문장 — 거부 7행 headline == 엔진 글자 · 접수 행 = «(합성)»', () {
      final List<ActionResult> rows = _rows(
        FixturePaths.m9ContributionActionResults,
      ).map(ActionResult.fromJson).toList();
      final Set<String> seen = <String>{};
      for (final ActionResult r in rows) {
        final String? code = r.reasonCode;
        if (code == null) {
          expect(r.headline, startsWith('(합성)'), reason: r.actionRunId);
        } else if (_engineReject.containsKey(code)) {
          expect(r.headline, _engineReject[code], reason: r.actionRunId);
          seen.add(code);
        }
      }
      expect(seen, _engineReject.keys.toSet());
    });

    test(
      'C-57 ⑥ 사전 — values == 엔진 6 · byDomain 등재 · 공용과 겹침 0 · 선언 상수 == values',
      () {
        expect(ContributionResultCodes.values, _engineCodes);
        expect(
          ContractCodes.byDomain['contribution_result'],
          ContributionResultCodes.values,
        );
        expect(
          ContributionResultCodes.values.intersection(
            SafetyCommonResultCodes.values,
          ),
          isEmpty,
        );
        expect(
          ContributionResultCodes.values,
          isNot(contains(SafetyCommonResultCodes.trustedTimeUnknown)),
        );
        final String src = stripComments(
          File('${libDir.path}/src/labels/settings_codes.dart')
              .readAsStringSync(),
        );
        final RegExpMatch? m = RegExp(
          r'abstract final class ContributionResultCodes\s*\{(.*?)\n\}',
          dotAll: true,
        ).firstMatch(src);
        expect(m, isNotNull);
        expect(<String>{
          for (final RegExpMatch c in RegExp(
            r"static const String \w+\s*=\s*'([^']*)';",
          ).allMatches(m![1]!))
            c[1]!,
        }, ContributionResultCodes.values);
      },
    );

    test(
      'C-57 ⑦ 금액 글자 자리 — m9 표본 중 월 납입 9벌에만 · 신설 7 금액 ⊆ {10만원, 0원, 10억원}',
      () {
        final List<String> offenders = <String>[];
        for (final String path in FixturePaths.all.where(
          (String p) => p.startsWith('m9/'),
        )) {
          final List<String> found = <String>[
            for (final String s in _strings(_env(path)))
              ..._money.allMatches(s).map((RegExpMatch m) => m[0]!),
          ];
          if (!_moneyOk.contains(path) && found.isNotEmpty) {
            offenders.add('$path: $found');
          }
          if (_new.contains(path)) {
            for (final String f in found) {
              if (!_moneyAllowed.contains(f)) offenders.add('$path: 새 금액 $f');
            }
          }
        }
        expect(offenders, isEmpty);
      },
    );

    test('C-57 ⑧ 예정 = 지금 값 그대로 — _pending amount_text == 원판 · 문장 금액 1 ≠ 지금 · 그 밖 VM 문장 금액 0', () {
      final MonthlyContributionVm base = MonthlyContributionVm.fromJson(
        _vm(FixturePaths.m9MonthlyContribution),
      );
      final MonthlyContributionVm pending = MonthlyContributionVm.fromJson(
        _vm(FixturePaths.m9MonthlyContributionPending),
      );
      expect(pending.amountText, base.amountText);
      final List<String> ap = _money
          .allMatches(pending.appliesFromText)
          .map((RegExpMatch m) => m[0]!)
          .toList();
      expect(ap, hasLength(1));
      expect(ap.single, isNot(pending.amountText));
      for (final String path in _vms) {
        if (path == FixturePaths.m9MonthlyContributionPending) continue;
        final MonthlyContributionVm vm = MonthlyContributionVm.fromJson(
          _vm(path),
        );
        expect(_money.hasMatch(vm.appliesFromText), isFalse, reason: path);
      }
    });

    test('C-57 ⑨ 변종 동치 — _locked · _stale · _no_record 는 원판에서 그 칸만 다르다', () {
      final Map<String, Object?> base = _vm(FixturePaths.m9MonthlyContribution);
      String without(Map<String, Object?> row, Set<String> keys) =>
          jsonEncode(<String, Object?>{
            for (final MapEntry<String, Object?> e in row.entries)
              if (!keys.contains(e.key)) e.key: e.value,
          });
      final Map<String, Object?> locked = _vm(
        FixturePaths.m9MonthlyContributionLocked,
      );
      const Set<String> lockKeys = <String>{
        'locked_label',
        'change_label',
        'editable',
      };
      expect(without(locked, lockKeys), without(base, lockKeys));
      final Map<String, Object?> stale = _vm(
        FixturePaths.m9MonthlyContributionStale,
      );
      expect(
        without(stale, <String>{'as_of'}),
        without(base, <String>{'as_of'}),
      );
      expect(MonthlyContributionVm.fromJson(stale).asOf.staleLabel, isNotNull);
      for (final String path in _vms) {
        if (path == FixturePaths.m9MonthlyContributionStale) continue;
        final Map<String, Object?> asOf =
            _vm(path)['as_of']! as Map<String, Object?>;
        expect(asOf.containsKey('stale_label'), isFalse, reason: path);
        expect(
          (_env(path)['as_of']! as Map<String, Object?>).containsKey(
            'stale_label',
          ),
          isFalse,
          reason: '$path 봉투',
        );
        expect(asOf, _env(path)['as_of'], reason: '$path — VM as_of == 봉투');
      }
      final Map<String, Object?> noRecord = _vm(
        FixturePaths.m9MonthlyContributionNoRecord,
      );
      expect(
        without(noRecord, <String>{'last_changed_text'}),
        without(base, <String>{'last_changed_text'}),
      );
      expect(noRecord['last_changed_text'], _noRecordText);
      // _no_limit_note = 0원이면 한도 비교 문장 null(core `ops/contribution_setting.dart:178`) · 입력칸 원값 = 숫자 그대로.
      final Map<String, Object?> noLimit = _vm(
        FixturePaths.m9MonthlyContributionNoLimitNote,
      );
      expect(noLimit.containsKey('pension_limit_note_text'), isTrue);
      expect(noLimit['pension_limit_note_text'], isNull);
      expect(noLimit['amount_input_text'], '0');
      for (final String path in _vms) {
        if (path == FixturePaths.m9MonthlyContributionNoLimitNote) continue;
        expect(_vm(path)['pension_limit_note_text'], isNotNull, reason: path);
      }
      // 적용 날짜 = 같은 today·달력의 «다음 납입 주기(…)»(core :203-204) — 6벌 모두 원판과 같은 날짜(K101).
      final RegExp nextCycle = RegExp(r'^다음 납입 주기\(([^)]+)\)부터 ');
      final String baseDate = nextCycle.firstMatch(
        base['applies_from_text']! as String,
      )![1]!;
      for (final String path in _vms) {
        final RegExpMatch? m = nextCycle.firstMatch(
          _vm(path)['applies_from_text']! as String,
        );
        expect(m, isNotNull, reason: path);
        expect(m![1], baseDate, reason: path);
      }
    });

    test('C-57 ⑩ 제출 DTO 왕복 — 키 {amount_input} · 원문 그대로(손질 0) · 왕복 같음', () {
      for (final String x in <String>['', ' 1,000 ', '-1', 'abc', '0']) {
        final ContributionUpdateSubmission s = ContributionUpdateSubmission(
          amountInput: x,
        );
        final Map<String, dynamic> json = s.toJson();
        expect(json.keys.toSet(), <String>{'amount_input'});
        expect(json['amount_input'], isA<String>());
        expect(json['amount_input'], x);
        expect(ContributionUpdateSubmission.fromJson(json), s);
      }
    });

    test('C-57 ⑪ 받침대 — watchContribution = 동기 throw · runContributionUpdate = Future 에러(동기 throw 0)', () async {
      expect(
        () => UnimplementedSettingsRepository().watchContribution(),
        throwsA(isA<UnimplementedError>()),
      );
      late Future<ActionResult> f;
      expect(() {
        f = UnimplementedSettingsActions().runContributionUpdate(
          const ContributionUpdateSubmission(amountInput: ''),
        );
      }, returnsNormally);
      await expectLater(f, throwsA(isA<UnimplementedError>()));
    });

    test('C-57 ⑫ 포트 경계 — ui_*(ui_settings 제외)에 S13 투영·제출 이름 0 · ui_settings 에 원값 창구 0', () {
      final List<String> offenders = <String>[];
      final List<RegExp> s13 = <RegExp>[
        RegExp(r'\bwatchContribution\s*\('),
        RegExp(r'\brunContributionUpdate\s*\('),
        RegExp(r'\bContributionUpdateSubmission\b'),
        RegExp(r'\bMonthlyContributionVm\b'),
      ];
      final List<RegExp> raw = <RegExp>[
        RegExp(r'\bwatchContributionSetting\b'),
        RegExp(r'\bConfigRepository\b'),
      ];
      for (final String name in uiPackageNames) {
        final Directory lib = Directory('${repoRoot.path}/packages/$name/lib');
        if (!lib.existsSync()) continue;
        for (final File f in dartSourcesIn(lib)) {
          final String code = stripCommentsAndStrings(f.readAsStringSync());
          for (final RegExp rx in name == 'ui_settings' ? raw : s13) {
            if (rx.hasMatch(code)) {
              offenders.add('${shortPath(f)}: ${rx.pattern}');
            }
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: '🔴 값의 원천 하나(K78) — S7-4·H-02 는 ConfigRepository 원값, S13 은 SettingsRepository 투영만 읽는다(두 벌 0).',
      );
    });

    test('C-57 ⑬ 글자 — 신설 7: DRY_RUN·손익 낱말·8자리 숫자·폐기 운영값·금지어 0', () {
      final List<RegExp> bad = <RegExp>[
        RegExp('DRY_RUN'),
        RegExp('평가손익|수익률|평가액|손익'),
        RegExp('[0-9]{8,}'),
        RegExp(r'(?<![0-9])90000(?![0-9])'),
        RegExp(r'9만|9\.7만'),
        RegExp('추천|권유|자문|시그널|매매 중단'),
      ];
      final List<String> offenders = <String>[];
      for (final String path in _new) {
        for (final String s in _strings(_env(path))) {
          for (final RegExp rx in bad) {
            if (rx.hasMatch(s)) offenders.add('$path: «$s» ~ ${rx.pattern}');
          }
        }
      }
      expect(offenders, isEmpty);
    });
  });
}
