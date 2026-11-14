// operator 실행 묶음(E11p3d-1 · 설계 13 §8 R104) — 엔진과 화면이 함께 쓰는 원장 · 화면 상태 · 딥링크 중계.
//
// 🔴 원장 연결은 프로세스에 하나 — 엔진(깨어남)과 화면(읽기 모델)이 같은 `LedgerFiles` 를 쓴다(갱신 알림 = 같은 연결).
// 🔴 화면 상태 = 마지막 깨어남의 기동 판정(`operatorViewOf`) — 깨어남마다 다시 정한다(모드 전환 뒤 낡은 파일을 보지 않게).
// 🔴 딥링크(FGS 탭 등)는 화면이 설 때까지 기다렸다가 연다 — 차가운 시작에서 내비게이터가 없으면 잃지 않게 맨 마지막 하나를 쥔다.

import 'dart:async';

import 'package:core_engine/core_engine.dart'
    show Market, WatchdogRemote, frozenExchangeCalendar;
import 'package:domain_contracts/domain_contracts.dart'
    show
        AppLinkOpener,
        Clock,
        ConfigRepository,
        ContributionSetting,
        DateRange,
        FeatureFlags,
        SleeveCatalogEntry;
import 'package:flutter/foundation.dart';
import 'package:trading_runtime/trading_runtime.dart' show JobCalendars;

import '../engine/ledger_files.dart';
import '../engine/operator_engine.dart' show EngineWakeReport;
import 'operator_view.dart';
import 'secure_screen.dart';

/// operator 실행 묶음.
class OperatorRuntime {
  /// 만든다 — [files] = 엔진 원장 폴더의 원장(열린 채로 넘긴다) · [secure] · [openExternal] = 플랫폼(시험 = 기본값 · 아무것도 안 함).
  OperatorRuntime({
    required this.files,
    required this.clock,
    SecureScreen? secure,
    Future<bool> Function(String url)? openExternal,
    JobCalendars? calendars,
    this.watchdogRemote,
  }) : secure = secure ?? SecureScreen(_noSecure),
       openExternal = openExternal ?? _noExternal,
       calendars =
           calendars ??
           JobCalendars(
             kr: frozenExchangeCalendar(Market.kr),
             us: frozenExchangeCalendar(Market.us),
           );

  /// 🆕 E11p3d-2(R109) — 시장 달력(감시 보드 · 엔진과 같은 동결 달력).
  final JobCalendars calendars;

  /// 🆕 R109 — 바깥 감시 체크 목록(없음 = 보드가 «바깥을 읽지 못했습니다»).
  final WatchdogRemote? watchdogRemote;

  static Future<void> _noSecure(bool on) async {}
  static Future<bool> _noExternal(String url) async => false;

  /// 🆕 E11p3d-5(R107) — 캡처 막기 겹침 세기(FLAG_SECURE).
  final SecureScreen secure;

  /// 🆕 R107 — 바깥 링크 열기(https 만).
  final Future<bool> Function(String url) openExternal;

  /// 엔진 · 화면 공용 원장.
  final LedgerFiles files;

  /// 기기 시계.
  final Clock clock;

  /// 화면 상태(온보딩 미완 · 첫 깨어남 전 = null).
  final ValueNotifier<OperatorView?> view = ValueNotifier<OperatorView?>(null);

  /// 깨어남 보고 → 화면 상태.
  void onWake(EngineWakeReport report) {
    view.value = operatorViewOf(report.boot, files);
  }
}

/// 🔴 셸 설정 원천 — 플래그 = 화면 상태 · 그 밖(위성 목록 · 기간 프리셋 · 월 납입)은 아직 원천이 없다(R104 — 지어내지 않는다).
class OperatorConfigRepository implements ConfigRepository {
  /// 만든다.
  OperatorConfigRepository(this._view);

  final ValueListenable<OperatorView?> _view;

  @override
  Stream<FeatureFlags> watchFlags() {
    late final StreamController<FeatureFlags> c;
    void push() {
      final OperatorView? v = _view.value;
      if (v != null && !c.isClosed) c.add(v.flags);
    }

    c = StreamController<FeatureFlags>(
      onListen: () {
        push();
        _view.addListener(push);
      },
      onCancel: () {
        _view.removeListener(push);
        return c.close();
      },
    );
    return c.stream;
  }

  @override
  Stream<List<SleeveCatalogEntry>> watchSleeves() =>
      Stream<List<SleeveCatalogEntry>>.error(
        UnsupportedError('watchSleeves: 엔진 원천 없음(R104)'),
      );

  @override
  Stream<List<DateRange>> watchRangePresets() => Stream<List<DateRange>>.error(
    UnsupportedError('watchRangePresets: 엔진 원천 없음(R104)'),
  );

  @override
  Stream<ContributionSetting> watchContributionSetting() =>
      Stream<ContributionSetting>.error(
        UnsupportedError('watchContributionSetting: 조립 전(R104)'),
      );
}

/// 🔴 딥링크 중계 — 화면이 설 때까지 맨 마지막 링크 하나를 쥐었다가 연다.
class LinkRelay {
  /// 만든다 — [opener] = 셸 링크 열기(내비게이터가 없으면 아무것도 안 한다) · [ready] = 화면이 섰나.
  LinkRelay({required this.opener, required this.ready});

  /// 링크 열기.
  final AppLinkOpener Function() opener;

  /// 화면(내비게이터)이 섰나.
  final bool Function() ready;

  String? _pending;

  /// 받은 링크 — 섰으면 바로 · 아니면 쥔다.
  void receive(String link) {
    _pending = link;
    deliver();
  }

  /// 쥔 링크를 연다(화면이 섰을 때만).
  void deliver() {
    final String? l = _pending;
    if (l == null || !ready()) return;
    _pending = null;
    opener().open(l);
  }

  /// 쥐고 있는 링크(시험).
  String? get pending => _pending;
}
