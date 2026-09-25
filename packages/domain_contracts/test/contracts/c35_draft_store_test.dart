// C-35 초안 포트 경계 — 01 §12-1 · §7 표 C-35(🆕 계약 v1.2 · §8 미결 47).
//
// 정의: 「기기 로컬 입력 초안(`DraftStore`)이 원장·명령의 모양을 흉내 내거나 화면 밖으로 새지 않는다」.
//   ① 초안 픽스처의 본문 칸은 `key.kind` 의 칸 하나다.
//   ② `DraftKind` 는 `CommandKind` 의 부분집합이고 영구 제외 6종이 없다.
//   ③ `last_command_id` 는 같은 종류의 접수증 픽스처에 있다(재구독이 답을 받는다).
//   ④ 본문 DTO 는 명령 인자 이름을 쓰고 **추가형으로만** 진화한다(`fromJson({})` 성공).
//   ⑤ 초안 픽스처 행에 모드·맥락·기기·시각 키가 없다.
//   ⑥ 초안 포트는 화면 패키지의 operator 전용 라이브러리 안에서만 쓴다(방향 제한의 기계화).
//   ⑦ `RecordingDraftStore` 받침대 자체 검증(받침대가 틀리면 화면 테스트 전부가 거짓 초록).
// 🔴 실물 암호화·영속·계열 분리는 여기서 보지 않는다 — 06 M4-9 검증 게이트의 일이다.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// 초안 픽스처 전량(F1·F2).
const List<String> _draftFixtures = <String>[
  FixturePaths.m6DraftRecordsJ3,
  FixturePaths.m6DraftRecordsX7,
];

/// 초안이 **영구히** 둘 수 없는 명령 6종(01 §12-1 · `DraftKind` 머리 주석).
const Set<String> _permanentlyExcluded = <String>{
  'BLIND_REVIEW_SCORE',
  'KILL_SWITCH_ACTIVATE',
  'DISCLOSURE_VIEW',
  'DEPOSIT_REGISTER',
  'ALERT_ACK',
  'KILL_CHECKLIST_CONFIRM',
};

/// 본문 DTO 에 영구히 없어야 하는 키 — 맥락·확인값·세션값·대상 id(키에 있다).
const Set<String> _forbiddenBodyKeys = <String>{
  'context',
  'off_hour_trade',
  'duplicate_ack',
  'declared_complete',
  'session_started_at',
  'decision_id',
  'advice_id',
  'purpose',
};

/// 초안 행에 없어야 하는 모드·맥락·기기·시각 키(구현이 저장 공간·태그로 가른다).
const Set<String> _forbiddenRowKeys = <String>{
  'context',
  'run_mode',
  'operating_mode',
  'mode',
  'device_id',
  'lease_epoch',
  'saved_at',
  'created_at',
};

/// 화면 패키지의 operator 전용 경로(패키지 루트 기준) — `DraftStore` 를 말해도 되는 곳.
const Map<String, List<String>> _operatorPaths = <String, List<String>>{
  'ui_journal': <String>['lib/journal_draft.dart', 'lib/src/journal_draft/'],
};

List<DraftRecord> _draftRows(String path) =>
    decodeEnvelope(readFixture(path)).rows
        .map(DraftRecord.fromJson)
        .toList(growable: false);

/// 본문 칸이 정확히 하나이고 그것이 `key.kind` 의 칸인가.
bool _slotMatchesKind(DraftRecord r) {
  final int filled = <Object?>[
    r.journal,
    r.manualFill,
    r.adviceSkip,
    r.selfReport,
  ].where((Object? b) => b != null).length;
  if (filled != 1) {
    return false;
  }
  return switch (r.key.kind) {
    DraftKind.journalDraft => r.journal != null,
    DraftKind.manualFillRecord => r.manualFill != null,
    DraftKind.adviceSkip => r.adviceSkip != null,
    DraftKind.selfReportBalance => r.selfReport != null,
  };
}

/// JSON 트리의 모든 객체(Map)를 넘긴다 — `walkJson` 은 리스트 원소 자체를 방문하지 않으므로
/// 봉투 `rows` 의 행(접수증)을 모으려면 이것이 필요하다.
void _eachObject(Object? node, void Function(Map<String, Object?>) visit) {
  if (node is Map<String, Object?>) {
    visit(node);
    for (final Object? v in node.values) {
      _eachObject(v, visit);
    }
  } else if (node is List<Object?>) {
    for (final Object? v in node) {
      _eachObject(v, visit);
    }
  }
}

String _relToPackage(String name, File f) {
  final String base = '${repoRoot.path}/packages/$name/'.replaceAll(r'\', '/');
  final String p = f.path.replaceAll(r'\', '/');
  return p.startsWith(base) ? p.substring(base.length) : p;
}

bool _isOperatorPath(String name, String rel) {
  final List<String> allowed = _operatorPaths[name] ?? const <String>[];
  for (final String a in allowed) {
    if (a.endsWith('/') ? rel.startsWith(a) : rel == a) {
      return true;
    }
  }
  return false;
}

void main() {
  group('C-35 초안 포트 경계 (01 §12-1 · 계약 v1.2)', () {
    test('C-35 ① 초안 픽스처의 본문 칸은 key.kind 의 칸 하나다', () {
      int rows = 0;
      final Set<DraftKind> kinds = <DraftKind>{};
      for (final String path in _draftFixtures) {
        final List<DraftRecord> records = _draftRows(path);
        for (int i = 0; i < records.length; i++) {
          final DraftRecord r = records[i];
          rows++;
          kinds.add(r.key.kind);
          expect(
            _slotMatchesKind(r),
            isTrue,
            reason:
                '$path rows[$i] — 본문 칸이 key.kind(${r.key.kind.wire}) 의 칸 1개가 아니다.',
          );
          expect(r.key.targetId, isNotEmpty, reason: '$path rows[$i]');
        }
      }
      expect(rows, greaterThan(0), reason: '초안 픽스처를 못 읽었다.');
      expect(
        kinds,
        DraftKind.values.toSet(),
        reason: '초안 픽스처가 DraftKind 전 값의 모양을 고정해야 한다(X7 포함).',
      );
    });

    test('C-35 ② DraftKind 는 CommandKind 의 부분집합이고 영구 제외 6종이 없다', () {
      final Set<String> commandWires = <String>{
        for (final CommandKind k in CommandKind.values) k.wire,
      };
      expect(
        commandWires.containsAll(_permanentlyExcluded),
        isTrue,
        reason: '영구 제외 목록이 CommandKind 표기와 어긋났다 — 목록이 공허해진다.',
      );
      for (final DraftKind d in DraftKind.values) {
        expect(
          CommandKind.values.byName(d.name).wire,
          d.wire,
          reason: 'DraftKind.${d.name} — 초안은 그 명령의 전 단계다(이름·표기 동일).',
        );
        expect(
          _permanentlyExcluded,
          isNot(contains(d.wire)),
          reason: '${d.wire} — 초안을 둘 수 없는 명령이다(01 §12-1 · J-4 수용 기준).',
        );
      }
    });

    test('C-35 ③ last_command_id 는 같은 종류의 접수증 픽스처에 있다', () {
      final Set<String> receipts = <String>{};
      for (final String path in FixturePaths.all) {
        _eachObject(jsonDecode(readFixture(path)), (Map<String, Object?> o) {
          final Object? id = o['command_id'];
          final Object? kind = o['kind'];
          if (id is String && kind is String) {
            receipts.add('$id|$kind');
          }
        });
      }
      int linked = 0;
      for (final String path in _draftFixtures) {
        final List<DraftRecord> records = _draftRows(path);
        for (int i = 0; i < records.length; i++) {
          final String? id = records[i].lastCommandId;
          if (id == null) {
            continue;
          }
          linked++;
          expect(
            receipts,
            contains('$id|${records[i].key.kind.wire}'),
            reason:
                '$path rows[$i] — 연결된 명령이 같은 종류의 접수증 픽스처에 없다. '
                '재구독(watchCommand)이 답을 받지 못해 폼이 잠긴 채 멈춘다(구현 의무 ⑦).',
          );
        }
      }
      expect(linked, greaterThan(0), reason: '«제출됨» 초안 행이 없다 — 재구독 갈래를 못 덮는다.');
    });

    test('C-35 ④ 본문 DTO 는 명령 인자 이름을 쓰고 추가형으로만 진화한다', () {
      // 🔴 `fromJson({})` 성공 = 전 필드 nullable/@Default — 앱 업데이트 전에 저장된 초안이
      //    새 모양으로도 읽힌다(필드 삭제·개명·타입 변경 금지 · C17).
      final Map<String, Set<String>> actual = <String, Set<String>>{
        'JournalDraftInput': JournalDraftInput.fromJson(<String, dynamic>{})
            .toJson()
            .keys
            .toSet(),
        'ManualFillInput': ManualFillInput.fromJson(<String, dynamic>{})
            .toJson()
            .keys
            .toSet(),
        'AdviceSkipInput': AdviceSkipInput.fromJson(<String, dynamic>{})
            .toJson()
            .keys
            .toSet(),
        'SelfReportInput': SelfReportInput.fromJson(<String, dynamic>{})
            .toJson()
            .keys
            .toSet(),
      };
      const Map<String, Set<String>> expected = <String, Set<String>>{
        'JournalDraftInput': <String>{
          'rationale_before',
          'expected_outcome',
          'rule_cited',
          'note',
        },
        'ManualFillInput': <String>{
          'trade_date',
          'symbol',
          'side',
          'quantity_text',
          'price_text',
          'commission_text',
          'tax_text',
          'account_alias',
          'prefilled_fields',
          'deviation_note',
        },
        'AdviceSkipInput': <String>{'reason', 'note'},
        'SelfReportInput': <String>{'lines', 'cash_krw_text', 'account_alias'},
      };
      expect(
        actual,
        expected,
        reason: '본문 키가 01 §12-1 기대 집합과 다르다 — 01 을 먼저 고치고 같은 커밋에서 이 목록을 고친다.',
      );
      // `J-3` 본문 = 명령 인자에서 대상 id 를 뺀 것(이름 규칙 ①).
      final Set<String> journalArgKeys = const JournalDraft(
        decisionId: 'x',
        rationaleBefore: '',
        expectedOutcome: '',
        ruleCited: '',
        note: null,
      ).toJson().keys.toSet()..remove('decision_id');
      expect(actual['JournalDraftInput'], journalArgKeys);
      for (final MapEntry<String, Set<String>> e in actual.entries) {
        expect(
          e.value.intersection(_forbiddenBodyKeys),
          isEmpty,
          reason: '${e.key} — 맥락·확인값·세션값·대상 id 는 초안에 남기지 않는다(복원 뒤 다시 확인).',
        );
      }
    });

    test('C-35 ⑤ 초안 픽스처 행에 모드·맥락·기기·시각 키가 없다', () {
      final List<String> offenders = <String>[];
      for (final String path in _draftFixtures) {
        final List<Map<String, Object?>> rows = decodeEnvelope(
          readFixture(path),
        ).rows;
        walkJson(rows, (String jsonPath, String key, Object? value) {
          if (_forbiddenRowKeys.contains(key)) {
            offenders.add('$path rows$jsonPath');
          }
        });
      }
      expect(
        offenders,
        isEmpty,
        reason:
            '모드(계열)는 키·행에 없다 — 구현이 계열별 저장 공간으로 가른다(01 §12-1-5). '
            '맥락은 제출 때 CommandApi 구현이 채운다(G-19).',
      );
    });

    test('C-35 ⑥ 초안 포트는 화면 패키지의 operator 전용 라이브러리 안에서만 쓴다', () {
      final List<String> outside = <String>[];
      final List<String> leaks = <String>[];
      final RegExp mentionsPort = RegExp(r'\bDraftStore\b');
      final RegExp importsOperator = RegExp(
        r'''(?:import|export)\s+['"][^'"]*journal_draft[/.][^'"]*['"]''',
      );
      for (final String name in uiPackageNames) {
        for (final File f in dartSourcesIn(
          Directory('${repoRoot.path}/packages/$name/lib'),
        )) {
          final String rel = _relToPackage(name, f);
          if (_isOperatorPath(name, rel)) {
            continue;
          }
          final String source = f.readAsStringSync();
          if (mentionsPort.hasMatch(stripCommentsAndStrings(source))) {
            outside.add('packages/$name/$rel');
          }
          if (_operatorPaths.containsKey(name) &&
              importsOperator.hasMatch(stripComments(source))) {
            leaks.add('packages/$name/$rel');
          }
        }
      }
      expect(
        outside,
        isEmpty,
        reason:
            '초안 포트(주입 프로바이더 포함)는 operator 전용 라이브러리 안에만 둔다 — 배럴 쪽에 두면 '
            'viewer(iOS·웹) 조립이 그것을 끌어온다(01 §12-1 주입 규약 · TARGETS T-3).',
      );
      expect(
        leaks,
        isEmpty,
        reason:
            'operator 전용 라이브러리 밖 파일이 journal_draft 를 import·export 한다 — '
            '배럴에서 초안 포트에 도달할 수 있게 된다(방향 금지 · 01 §12-1).',
      );
    });

    test('C-35 ⑦ RecordingDraftStore 받침대 자체 검증', () async {
      final List<DraftRecord> j3 = _draftRows(FixturePaths.m6DraftRecordsJ3);
      final DraftRecord seed = j3[1];
      final RecordingDraftStore store = RecordingDraftStore(
        seed: <DraftRecord>[seed],
      );

      // 시드 → load 같음(값을 지어내지 않는다).
      expect(await store.load(seed.key), seed);
      expect(store.loaded, <DraftKey>[seed.key]);
      const DraftKey other = DraftKey(
        kind: DraftKind.journalDraft,
        targetId: 'd_other',
      );
      expect(await store.load(other), isNull);

      // save → load 같음(통째 교체).
      final DraftRecord submitted = j3[2];
      await store.save(submitted);
      expect(await store.load(submitted.key), submitted);
      expect(store.saved, <DraftRecord>[submitted]);
      expect(store.current(submitted.key), submitted);

      // clear 멱등.
      await store.clear(seed.key);
      await store.clear(seed.key);
      expect(await store.load(seed.key), isNull);
      expect(store.cleared, <DraftKey>[seed.key, seed.key]);

      // 칸 불일치 save = Future 에러이고 saved 불변.
      final List<DraftRecord> bad = <DraftRecord>[
        const DraftRecord(
          key: DraftKey(kind: DraftKind.adviceSkip, targetId: 'ad_x'),
          journal: JournalDraftInput(),
        ),
        const DraftRecord(
          key: DraftKey(kind: DraftKind.journalDraft, targetId: 'd_x'),
        ),
        const DraftRecord(
          key: DraftKey(kind: DraftKind.journalDraft, targetId: 'd_x'),
          journal: JournalDraftInput(),
          adviceSkip: AdviceSkipInput(),
        ),
      ];
      for (final DraftRecord r in bad) {
        await expectLater(store.save(r), throwsA(isA<ArgumentError>()));
      }
      expect(store.saved, <DraftRecord>[
        submitted,
      ], reason: '거절된 save 는 기록되지 않는다.');
      expect(store.current(bad[0].key), isNull);

      // X7 행도 같은 규칙으로 통과한다.
      for (final DraftRecord r in _draftRows(FixturePaths.m6DraftRecordsX7)) {
        await store.save(r);
        expect(await store.load(r.key), r);
      }

      // UnimplementedDraftStore 는 전부 던진다.
      final UnimplementedDraftStore none = UnimplementedDraftStore();
      expect(() => none.load(seed.key), throwsA(isA<UnimplementedError>()));
      expect(() => none.save(seed), throwsA(isA<UnimplementedError>()));
      expect(() => none.clear(seed.key), throwsA(isA<UnimplementedError>()));
    });
  });
}
