// 🆕 E11-viewer-223(01 §8 미결 223 ⓑ · 계약 v1.36 §45 K310) — 목록 봉투 · `ListResult` 조립.
//
// 🔴 빈 목록에도 봉투 · hasMore = limit+1 · 받은 차례 그대로 · 필터 빈 문장 = 봉투 글자 또는 null(뷰어가 짓지 않는다).

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:read_model_client/read_model_client.dart';
import 'package:test/test.dart';

const String _code = ReadModelListCodes.journalWatchTimeline;

Map<String, Object?> _envRow({
  String code = _code,
  Object? emptyKind = 'NO_DATA',
  Object? emptyLabel = '아직 기록된 거래가 없습니다',
}) => <String, Object?>{
  'row_version': 1,
  'lease_epoch': 1,
  'pushed_at': '2026-11-24T00:00:00Z',
  'mode': 'LIVE',
  'list_code': code,
  'as_of': _asOf,
  'empty_kind': emptyKind,
  'empty_label': emptyLabel,
};

ReadModelListEnvelope _env({String? label = '아직 기록된 거래가 없습니다'}) =>
    listEnvelopeOfRow(_envRow(emptyLabel: label), listCode: _code);

/// 봉투 `as_of`(와이어 — 엔진 `AsOf.toJson()` 꼴).
final Map<String, Object?> _asOf = jsonDecode(
  jsonEncode(
    AsOf(
      observedAt: DateTime.utc(2026, 11, 24),
      tradeDate: const TradeDate('2026-11-21'),
      source: AsOfSource.localSqlite,
      staleAfter: const Duration(hours: 26),
      label: '기준 2026-11-21',
    ).toJson(),
  ),
) as Map<String, Object?>;

Matcher get _fmt => throwsA(isA<FormatException>());

void main() {
  test('봉투 행 → 봉투(열 4 · 와이어 그대로)', () {
    for (final EmptyKind k in EmptyKind.values) {
      final ReadModelListEnvelope e = listEnvelopeOfRow(
        _envRow(emptyKind: k.wire, emptyLabel: null),
        listCode: _code,
      );
      expect(e.listCode, _code);
      expect(e.emptyKind, k);
      expect(e.emptyLabel, isNull);
      expect(e.asOf.tradeDate.yyyyMmDd, '2026-11-21');
    }
    expect(_env().emptyLabel, '아직 기록된 거래가 없습니다');
  });

  test('봉투 행을 못 읽으면 던진다 — 열 없음 · 다른 창구 · 모르는 갈래 · 꼴', () {
    for (final String col in <String>[
      'list_code',
      'as_of',
      'empty_kind',
      'empty_label',
    ]) {
      expect(
        () => listEnvelopeOfRow(_envRow()..remove(col), listCode: _code),
        _fmt,
        reason: col,
      );
    }
    expect(
      () => listEnvelopeOfRow(
        _envRow(code: ReadModelListCodes.adviceWatchInbox),
        listCode: _code,
      ),
      _fmt,
    );
    expect(
      () => listEnvelopeOfRow(_envRow(emptyKind: 'EMPTY'), listCode: _code),
      _fmt,
    );
    expect(
      () => listEnvelopeOfRow(_envRow(emptyKind: null), listCode: _code),
      _fmt,
    );
    expect(
      () => listEnvelopeOfRow(_envRow(emptyLabel: 3), listCode: _code),
      _fmt,
    );
    expect(
      () => listEnvelopeOfRow(_envRow()..['as_of'] = 'x', listCode: _code),
      _fmt,
    );
    expect(
      () => listEnvelopeOfRow(
        _envRow()..['as_of'] = <String, Object?>{'trade_date': 1},
        listCode: _code,
      ),
      _fmt,
    );
    expect(
      () => listEnvelopeOfRow(_envRow(), listCode: 'Nope.watch'),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('hasMore = limit+1 조회 · 행 = 앞 limit 개(받은 차례 그대로)', () {
    final ListResult<int> more = listResultOf<int>(
      fetched: <int>[5, 3, 9, 1],
      envelope: _env(label: null),
      listCode: _code,
      limit: 3,
    );
    expect(more.rows, <int>[5, 3, 9]);
    expect(more.hasMore, isTrue);
    final ListResult<int> exact = listResultOf<int>(
      fetched: <int>[5, 3, 9],
      envelope: _env(label: null),
      listCode: _code,
      limit: 3,
    );
    expect(exact.rows, <int>[5, 3, 9]);
    expect(exact.hasMore, isFalse);
    final ListResult<int> all = listResultOf<int>(
      fetched: <int>[2, 1],
      envelope: _env(label: null),
      listCode: _code,
    );
    expect(all.rows, <int>[2, 1]);
    expect(all.hasMore, isFalse);
    final ListResult<int> zero = listResultOf<int>(
      fetched: <int>[7],
      envelope: _env(label: null),
      listCode: _code,
      limit: 0,
    );
    expect(zero.rows, isEmpty);
    expect(zero.hasMore, isTrue);
    expect(
      () => listResultOf<int>(
        fetched: <int>[],
        envelope: _env(),
        listCode: _code,
        limit: -1,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('봉투 = asOf · emptyKind · emptyLabel 그대로(무필터)', () {
    final ReadModelListEnvelope e = _env();
    final ListResult<int> r = listResultOf<int>(
      fetched: <int>[],
      envelope: e,
      listCode: _code,
      limit: 100,
    );
    expect(r.rows, isEmpty);
    expect(r.asOf, e.asOf);
    expect(r.emptyKind, e.emptyKind);
    expect(r.emptyLabel, '아직 기록된 거래가 없습니다');
  });

  test('빈 목록에도 봉투 — 봉투 없음 · 다른 창구 봉투 = FormatException', () {
    expect(
      () =>
          listResultOf<int>(fetched: <int>[], envelope: null, listCode: _code),
      _fmt,
    );
    expect(
      () => listResultOf<int>(
        fetched: <int>[],
        envelope: _env(),
        listCode: ReadModelListCodes.adviceWatchHistory,
      ),
      _fmt,
    );
  });

  test('필터 빈 문장 갈래 — 봉투 글자(전체가 빔) 또는 null · 행 있으면 null', () {
    // 전체가 비었다(봉투 글자 있음) → 필터 결과도 비었고 그 글자가 참이다.
    expect(
      listResultOf<int>(
        fetched: <int>[],
        envelope: _env(),
        listCode: _code,
        limit: 100,
        filtered: true,
      ).emptyLabel,
      '아직 기록된 거래가 없습니다',
    );
    // 전체는 비지 않았는데(봉투 글자 null) 필터가 비웠다 → 필터 빈 문장 = 엔진 글자 · 열 없음 → null.
    expect(
      listResultOf<int>(
        fetched: <int>[],
        envelope: _env(label: null),
        listCode: _code,
        limit: 100,
        filtered: true,
      ).emptyLabel,
      isNull,
    );
    // 행이 있으면 빈 문장 0(낡은 봉투 글자를 싣지 않는다).
    expect(
      listResultOf<int>(
        fetched: <int>[1],
        envelope: _env(),
        listCode: _code,
        limit: 100,
        filtered: true,
      ).emptyLabel,
      isNull,
    );
  });
}
