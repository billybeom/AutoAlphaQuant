// E13g2 — 서약 판정 · 에피소드 · 재생 대상(설계 13 §8 R67).
//
// 🔵 잡는 것: ① 문장 = 셋 · 앞뒤 공백 뺌 · 빈칸 ② 첫 판 차례(신뢰 시각 → 이미 → 문장 → id) ③ 편집 차례(신뢰 시각 →
//    없음 → 12월(한국 달 경계) → 문장 → 같음(공백만 다름도 같음) → 저널) ④ 에피소드 = 마지막 고점(DD ≥ 0)부터 · 고점 없음 = 첫 날 ·
//    섞인 차례 ⑤ 임계 경계(−0.10 = 닿음) · 건너뛰기 = 대상 여럿 · 가장 깊은 것 · 재생한 것 빼기 · 서약 없음 = 없음.
import 'package:core_engine/core_engine.dart';
import 'package:test/test.dart';

final DateTime _dec = DateTime.utc(2026, 12, 10);
const List<String> _three = <String>['하나', '둘', '셋'];

Pledge _p(List<String> lines) =>
    Pledge(version: 1, lines: lines, writtenAtUtc: DateTime.utc(2026, 1, 1));

String? _edit({
  DateTime? now,
  bool unknown = false,
  Pledge? current,
  bool none = false,
  List<String> sentences = const <String>['하나', '둘', '넷'],
  bool journal = true,
}) => pledgeEditRejectCode(
  nowUtc: unknown ? null : (now ?? _dec),
  current: none ? null : (current ?? _p(_three)),
  sentences: sentences,
  journalLinked: journal,
);

DrawdownPoint _d(String date, double dd) => DrawdownPoint(date, dd);

void main() {
  test('문장 = 셋 · 앞뒤 공백 뺌 · 빈칸 · 수가 다르면 null', () {
    expect(pledgeSentencesOf(const <String>[' 하나 ', '둘', '셋\n']), _three);
    expect(pledgeSentencesOf(const <String>['하나', '  ', '셋']), isNull);
    expect(pledgeSentencesOf(const <String>['하나', '둘']), isNull);
    expect(pledgeSentencesOf(const <String>['하나', '둘', '셋', '넷']), isNull);
  });

  test('첫 판 차례 — 신뢰 시각 → 이미 → 문장 → id · 12월 밖에도 된다', () {
    String? w({
      bool unknown = false,
      Pledge? current,
      List<String> s = _three,
      String id = 'ON-1',
    }) => pledgeWriteRejectCode(
      nowUtc: unknown ? null : DateTime.utc(2026, 3, 1),
      current: current,
      sentences: s,
      decisionId: id,
    );
    expect(w(), isNull);
    expect(w(unknown: true, current: _p(_three)), 'TRUSTED_TIME_UNKNOWN');
    expect(
      w(current: _p(_three), s: const <String>['']),
      'PLEDGE_ALREADY_WRITTEN',
    );
    expect(
      w(s: const <String>['하나', '둘', ' '], id: ''),
      'PLEDGE_SENTENCES_MISSING',
    );
    expect(w(id: '  '), 'PLEDGE_JOURNAL_MISSING');
  });

  test('🔴 편집 차례 — 신뢰 시각 → 없음 → 12월 → 문장 → 같음 → 저널', () {
    expect(_edit(), isNull);
    expect(_edit(unknown: true, none: true), 'TRUSTED_TIME_UNKNOWN');
    expect(
      _edit(none: true, now: DateTime.utc(2026, 3, 1)),
      'PLEDGE_NOT_WRITTEN',
    );
    expect(
      _edit(now: DateTime.utc(2026, 3, 1), sentences: const <String>['']),
      'PLEDGE_OUT_OF_WINDOW',
    );
    expect(
      _edit(sentences: const <String>['하나', ''], journal: false),
      'PLEDGE_SENTENCES_MISSING',
    );
    expect(_edit(sentences: _three, journal: false), 'PLEDGE_UNCHANGED');
    // 공백만 다르면 같은 문장.
    expect(
      _edit(sentences: const <String>[' 하나', '둘 ', '셋']),
      'PLEDGE_UNCHANGED',
    );
    // 어느 한 문장만 달라도 다르다.
    for (final List<String> s in <List<String>>[
      const <String>['다른', '둘', '셋'],
      const <String>['하나', '다른', '셋'],
    ]) {
      expect(_edit(sentences: s), isNull, reason: '$s');
    }
    expect(_edit(journal: false), 'PLEDGE_JOURNAL_MISSING');
  });

  test('12월 = 한국 달 — 11-30 14:59Z 밖 · 15:00Z 안 · 12-31 15:00Z 밖', () {
    expect(
      _edit(now: DateTime.utc(2026, 11, 30, 14, 59)),
      'PLEDGE_OUT_OF_WINDOW',
    );
    expect(_edit(now: DateTime.utc(2026, 11, 30, 15)), isNull);
    expect(_edit(now: DateTime.utc(2026, 12, 31, 14, 59)), isNull);
    expect(_edit(now: DateTime.utc(2026, 12, 31, 15)), 'PLEDGE_OUT_OF_WINDOW');
  });

  test('에피소드 = 마지막 고점(DD ≥ 0)부터 · 고점 없음 = 첫 날 · 섞인 차례 · 없음 = null', () {
    expect(currentEpisodeOf(const <DrawdownPoint>[]), isNull);
    final DrawdownEpisode e = currentEpisodeOf(<DrawdownPoint>[
      _d('2026-01-05', -0.04),
      _d('2026-01-01', 0),
      _d('2026-01-02', -0.30),
      _d('2026-01-03', 0),
      _d('2026-01-04', -0.12),
    ])!;
    expect((e.peakDate, e.minDrawdown), ('2026-01-03', -0.12));
    final DrawdownEpisode noPeak = currentEpisodeOf(<DrawdownPoint>[
      _d('2026-01-02', -0.08),
      _d('2026-01-01', -0.02),
    ])!;
    expect((noPeak.peakDate, noPeak.minDrawdown), ('2026-01-01', -0.08));
    final DrawdownEpisode atPeak = currentEpisodeOf(<DrawdownPoint>[
      _d('2026-01-01', -0.2),
      _d('2026-01-02', 0),
    ])!;
    expect((atPeak.peakDate, atPeak.minDrawdown), ('2026-01-02', 0.0));
  });

  test('🔴 재생 대상 — 경계 포함 · 건너뛰기 = 여럿 · 가장 깊은 것 · 재생한 것 빼기 · 서약 없음', () {
    PledgeReplayDue? due(
      double minDd, {
      Set<double> shown = const <double>{},
      bool has = true,
    }) => pledgeReplayDueOf(
      hasPledge: has,
      episode: DrawdownEpisode(peakDate: '2026-01-03', minDrawdown: minDd),
      shownThresholds: shown,
    );
    expect(due(-0.0999), isNull);
    expect(due(-0.10)!.thresholds, <double>[-0.10]);
    final PledgeReplayDue jump = due(-0.16)!;
    expect(jump.thresholds, <double>[-0.10, -0.15]);
    expect((jump.deepest, jump.peakDate), (-0.15, '2026-01-03'));
    expect(due(-0.25)!.thresholds, <double>[-0.10, -0.15, -0.20]);
    expect(due(-0.16, shown: <double>{-0.10})!.thresholds, <double>[-0.15]);
    expect(due(-0.16, shown: <double>{-0.10, -0.15}), isNull);
    expect(due(-0.30, has: false), isNull);
    expect(
      pledgeReplayDueOf(
        hasPledge: true,
        episode: null,
        shownThresholds: const <double>{},
      ),
      isNull,
    );
    expect(() => jump.thresholds.add(0), throwsUnsupportedError);
  });

  test('상수 = 02 §4 키 값', () {
    expect(kPledgeReplayDd, <double>[-0.10, -0.15, -0.20]);
    expect(kPledgeSentences, 3);
  });
}
