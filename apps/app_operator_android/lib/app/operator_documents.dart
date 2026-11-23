// 🆕 E11q-d1 — M8 문서 창구: `D-02` 런북 · `D-03` 긴급 카드 · `B-01`·`B-02` 핸드북(설계 13 §8 · 06 M4-12 ①② · 04 §6 · §8).
//
// 🔴 원천 = 엔진 원고 번들(`kRunbookCatalog` · `kHandbookManuscript`) — 원장 · 키 · 네트워크 0 → 온보딩 전 · 원장이
//    망가져도 열린다(런북이 필요한 때가 바로 그때다).
// 🔴 긴급 카드 인쇄 = 이 폰 빌드에 인쇄 · PDF 위젯이 없다([kOperatorEmergencyCardPrintable] = false) → 엔진이 슬롯 이름을
//    비운다(버튼 부재 · 운영 슬롯 빌더의 `EMERGENCY_CARD_PRINT` = 자리 부재 그대로).
// 🔴 핸드북 설정 지문 = 화면이 읽는 원장(깨어남 전 = sim 파일)의 모의 개시 판(없음 · 못 읽음 = 빈 글자 — 화면은 이 칸을 쓰지
//    않는다) · 뒤처짐 = 엔진(원고 규칙 지문 ↔ 지금 규칙 지문).
// 🆕 E11q-d1b(R236) — live «현재 상태»(금 상한) = 화면 상태의 원장에서 읽을 때 짓는다(data_sync `ledgerHandbookLiveOf` —
//    가장 최근 평가 행의 날 · 일간 잡 경고 단계와 같은 셈) · 원천 없음(온보딩 전 · 평가 행 없음 · 셈 불가 · 설정 못 읽음) =
//    엔진이 그 블록을 뺀다(지어내지 않는다) · 쪽 = 원장 표가 바뀌면 다시 낸다.

import 'dart:async';

import 'package:core_engine/core_engine.dart'
    show
        HandbookLiveReading,
        P0sWarnSetup,
        emergencyCardVmOf,
        handbookIndexOf,
        handbookPageOf,
        p0sExposureMap,
        p0sRuleFingerprint,
        runbookIndexVmOf,
        runbookVmOf;
import 'package:data_sync/data_sync.dart'
    show
        OpsConfigRead,
        OpsConfigReady,
        currentP0sOpsConfig,
        kHandbookLiveWatchedTables,
        ledgerHandbookLiveOf,
        watchLedgerQuery;
import 'package:domain_contracts/domain_contracts.dart'
    show
        EmergencyCardVm,
        HandbookIndex,
        HandbookPage,
        HandbookRepository,
        RunbookIndexVm,
        RunbookRepository,
        RunbookVm;
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:sqlite3/sqlite3.dart' show Database;

import 'operator_runtime.dart' show OperatorRuntime;
import 'operator_view.dart' show OperatorView;

/// 이 폰 빌드가 긴급 카드를 인쇄 · PDF 로 낼 수 있나 — 플랫폼 위젯(`printing` 류) 전 = 아니다.
const bool kOperatorEmergencyCardPrintable = false;

/// `D-02` · `D-03` — 엔진 원고 번들(읽기 전용 · 쓰기 0).
class OperatorRunbookRepository implements RunbookRepository {
  /// 만든다.
  const OperatorRunbookRepository({
    this.printable = kOperatorEmergencyCardPrintable,
  });

  /// 인쇄 · PDF 자리가 있나.
  final bool printable;

  @override
  Stream<RunbookIndexVm> watchRunbookIndex() =>
      Stream<RunbookIndexVm>.value(runbookIndexVmOf());

  @override
  Stream<RunbookVm> watchRunbook(String runbookId) =>
      Stream<RunbookVm>.value(runbookVmOf(runbookId));

  @override
  Stream<EmergencyCardVm> watchEmergencyCard() =>
      Stream<EmergencyCardVm>.value(emergencyCardVmOf(printable: printable));
}

/// `B-01` · `B-02` — 엔진 원고 번들 + 지금 설정 지문 · 규칙 지문(화면 상태가 바뀌면 다시 낸다).
class OperatorHandbookRepository implements HandbookRepository {
  /// 만든다.
  OperatorHandbookRepository(this._rt);

  final OperatorRuntime _rt;

  /// 지금 설정 지문 — 화면이 읽는 원장의 모의 개시 판(없음 · 못 읽음 = 빈 글자).
  String _configHash() {
    final Database db = _rt.view.value?.db ?? _rt.files.sim;
    try {
      final OpsConfigRead cfg = currentP0sOpsConfig(db);
      return cfg is OpsConfigReady ? cfg.configHash : '';
    } on Object {
      // 문서는 원장이 망가져도 연다 — 지문 칸만 비운다(화면은 이 칸을 쓰지 않는다).
      return '';
    }
  }

  @override
  Stream<HandbookIndex> watchIndex() => _follow(
    () => handbookIndexOf(
      configHash: _configHash(),
      ruleFingerprint: p0sRuleFingerprint(),
    ),
  );

  /// 🆕 E11q-d1b — «현재 상태» 값(화면 상태의 원장 · 없음 · 못 읽음 = 빈 맵 → 엔진이 블록을 뺀다).
  Map<String, HandbookLiveReading> _live() {
    final OperatorView? v = _rt.view.value;
    if (v == null) return const <String, HandbookLiveReading>{};
    try {
      final OpsConfigRead cfg = currentP0sOpsConfig(v.db);
      return ledgerHandbookLiveOf(
        v.db,
        mode: v.flags.runMode,
        setup: cfg is OpsConfigReady
            ? P0sWarnSetup(map: p0sExposureMap(cfg.config.monthEnd))
            : null,
        nowUtc: _rt.clock.nowUtc(),
      );
    } on Object {
      // 문서는 원장이 망가져도 연다 — «현재 상태» 블록만 뺀다(지어내지 않는다).
      return const <String, HandbookLiveReading>{};
    }
  }

  @override
  Stream<HandbookPage> watchPage(String anchor) => _followLedger(
    () => handbookPageOf(
      anchor,
      configHash: _configHash(),
      ruleFingerprint: p0sRuleFingerprint(),
      live: _live(),
    ),
  );

  /// 들을 때 한 번 · 화면 상태가 바뀔 때마다(바뀐 값만).
  Stream<T> _follow<T>(T Function() now) =>
      _followListenable<OperatorView?, T>(_rt.view, now);

  /// 🆕 E11q-d1b — [_follow] + 화면 상태의 원장 표([kHandbookLiveWatchedTables])가 바뀔 때마다(바뀐 값만).
  Stream<T> _followLedger<T>(T Function() now) {
    late final StreamController<T> c;
    StreamSubscription<T>? sub;
    T? last;
    bool has = false;

    void put(T v) {
      if (c.isClosed || (has && v == last)) return;
      has = true;
      last = v;
      c.add(v);
    }

    void fail(Object e, StackTrace st) {
      if (!c.isClosed) c.addError(e, st);
    }

    void follow() {
      unawaited(sub?.cancel());
      sub = null;
      final OperatorView? v = _rt.view.value;
      if (v == null) {
        // 온보딩 전 = 원장 없음 — 번들 글자만(한 번).
        try {
          put(now());
        } on Object catch (e, st) {
          fail(e, st);
        }
        return;
      }
      sub = watchLedgerQuery<T>(
        v.db,
        kHandbookLiveWatchedTables,
        now,
      ).listen(put, onError: fail);
    }

    c = StreamController<T>(
      onListen: () {
        _rt.view.addListener(follow);
        follow();
      },
      onCancel: () async {
        _rt.view.removeListener(follow);
        await sub?.cancel();
        await c.close();
      },
    );
    return c.stream;
  }
}

Stream<T> _followListenable<L, T>(ValueListenable<L> on, T Function() now) {
  late final StreamController<T> c;
  T? last;
  bool has = false;

  void put() {
    if (c.isClosed) return;
    final T v;
    try {
      v = now();
    } on Object catch (e, st) {
      c.addError(e, st);
      return;
    }
    if (has && v == last) return;
    has = true;
    last = v;
    c.add(v);
  }

  c = StreamController<T>(
    onListen: () {
      on.addListener(put);
      put();
    },
    onCancel: () async {
      on.removeListener(put);
      await c.close();
    },
  );
  return c.stream;
}
