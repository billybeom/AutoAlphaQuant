// 🆕 미결 220 ⓒ(계약 v1.35 · 01 §44 K294) — 원장 `decision_journal.kind` 쓰기 · 읽기 = 계약 `DecisionJournalKinds` 참조.
//
// 🔵 잡는 것: ① data_sync lib 의 SQL 글자(큰따옴표 문자열) 안에 저널 kind 글자 0 — INSERT · SELECT 가 계약 상수를 바인딩한다
//    ② 저널을 쓰는 여섯 곳(킬스위치 2 · STOPPED · RECON 해제 · 규칙 변경 요청 · 개입 3단계)이 계약 상수를 쓴다(파일마다) ·
//    `VALUES (…, NULL, NULL, ?)` 꼴(kind 비움) 0 ③ 스키마 사본 주석 = 사전 8 전량(SPEC 02D v2.45 정정 · 재생성).
// 🔴 명령 수신함 `command_inbox.kind` 지역 글자(같은 글자 · 다른 축)는 이 시험 밖 — 단일 따옴표 Dart 상수.

import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart'
    show DecisionJournalKinds;
import 'package:test/test.dart';

const String _lib = 'lib/src';

Iterable<File> _dart(String dir) =>
    Directory(dir)
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'));

void main() {
  test('① SQL 글자(큰따옴표) 안에 저널 kind 0 — 계약 상수 바인딩', () {
    final RegExp sqlLiteral = RegExp(
      '"[^"\n]*\'(${DecisionJournalKinds.values.join('|')})\'[^"\n]*"',
    );
    final List<String> hits = <String>[
      for (final File f in _dart(_lib))
        if (!f.path.endsWith('schema_v1_sql.dart'))
          for (final (int i, String line) in f.readAsLinesSync().indexed)
            if (sqlLiteral.hasMatch(line)) '${f.path}:${i + 1}',
    ];
    expect(hits, isEmpty);
  });

  test('② 저널을 쓰는 여섯 곳 = 계약 상수 · kind 비운 INSERT 0', () {
    final Map<String, List<String>> writers = <String, List<String>>{
      'local/kill_switch_store.dart': <String>[
        'DecisionJournalKinds.killSwitchChecklist',
        'DecisionJournalKinds.killSwitchResume',
      ],
      'local/stopped_decision_store.dart': <String>[
        'DecisionJournalKinds.stoppedDecision',
      ],
      'local/order_ledger.dart': <String>['DecisionJournalKinds.reconClear'],
      'local/rule_change_store.dart': <String>[
        'DecisionJournalKinds.ruleChangeRequest',
      ],
      'local/intervention_store.dart': <String>[
        'DecisionJournalKinds.interventionJournal',
      ],
    };
    int inserts = 0;
    for (final File f in _dart(_lib)) {
      final String src = f.readAsStringSync();
      final String rel = f.path
          .replaceAll(r'\', '/')
          .replaceFirst('$_lib/', '');
      final int n = 'INSERT INTO decision_journal'.allMatches(src).length;
      if (n == 0) continue;
      inserts += n;
      expect(writers.keys, contains(rel), reason: '새 저널 쓰기 = 이 표에 등재');
      for (final String k in writers[rel]!) {
        expect(src, contains(k), reason: '$rel · $k');
      }
      for (final Match m in 'INSERT INTO decision_journal'.allMatches(src)) {
        final String stmt = src.substring(
          m.start,
          src.indexOf("',", src.indexOf('VALUES', m.start)),
        );
        expect(stmt, isNot(contains('NULL, NULL, ?)')), reason: '$rel kind 비움');
      }
    }
    expect(inserts, 6);
  });

  test('③ 스키마 사본 주석 = 사전 8 전량(재생성 · 뜻 0)', () {
    final String line = File('$_lib/local/schema_v1_sql.dart')
        .readAsLinesSync()
        .firstWhere(
          (String l) => l.trimLeft().startsWith('kind             TEXT,'),
        );
    for (final String k in DecisionJournalKinds.values) {
      expect(line, contains("'$k'"));
    }
  });
}
