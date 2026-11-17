// operator 실행 묶음(E11p3d-1 · 설계 13 §8 R104) — 엔진과 화면이 함께 쓰는 원장 · 화면 상태 · 딥링크 중계.
//
// 🔴 원장 연결은 프로세스에 하나 — 엔진(깨어남)과 화면(읽기 모델)이 같은 `LedgerFiles` 를 쓴다(갱신 알림 = 같은 연결).
// 🔴 화면 상태 = 마지막 깨어남의 기동 판정(`operatorViewOf`) — 깨어남마다 다시 정한다(모드 전환 뒤 낡은 파일을 보지 않게).
// 🔴 딥링크(FGS 탭 등)는 화면이 설 때까지 기다렸다가 연다 — 차가운 시작에서 내비게이터가 없으면 잃지 않게 맨 마지막 하나를 쥔다.

import 'dart:async';

import 'package:core_engine/core_engine.dart'
    show
        DeviceRiskFacts,
        ExchangeCalendar,
        Market,
        SecretVault,
        WatchdogRemote,
        contributionKstDay,
        contributionSettingOf,
        frozenExchangeCalendar;
import 'package:data_sync/data_sync.dart'
    show contributionRowsOf, watchLedgerQuery;
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
import 'package:http/http.dart' as http;
import 'package:trading_runtime/trading_runtime.dart' show JobCalendars;

import '../engine/ledger_files.dart';
import '../engine/operator_engine.dart' show EngineWakeReport;
import '../secret/secret_handoff.dart' show ClipboardJanitor, SecretHandoff;
import 'operator_onboarding.dart' show OnboardingProbe;
import 'operator_view.dart';
import 'secure_screen.dart';
import 'view_stream.dart';

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
    SecretHandoff? secrets,
    ClipboardJanitor? clipboard,
    this.vault,
    this.kisHttp,
    this.onboardingProbe,
    this.deviceProbe,
    this.deviceId,
  }) : secure = secure ?? SecureScreen(_noSecure),
       secrets = secrets ?? SecretHandoff(),
       clipboard = clipboard ?? ClipboardJanitor(),
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

  /// 🆕 E11p3d-5b(R115) — 시크릿 칸 ↔ 검증 동작 넘김(값은 위젯 상태에만).
  final SecretHandoff secrets;

  /// 🆕 R115 — 붙여넣은 뒤 60초 클립보드 정리.
  final ClipboardJanitor clipboard;

  /// 🆕 E11p3d-5c(R118) — 키 금고(검증 통과 뒤 저장 · 없음 = 설정 동작 부재).
  final SecretVault? vault;

  /// 🆕 R118 — 키 검증용 HTTP(모의 서버만 · 없음 = 설정 동작 부재).
  final http.Client? kisHttp;

  /// 🆕 E11p4b(R125) — 온보딩 실측(알림 권한 · 배터리 예외 · 없음 = 진척 행만).
  final Future<OnboardingProbe?> Function()? onboardingProbe;

  /// 🆕 E11p3d-5g(R142) — 이 기기 id(백업 제외 자리 · `AndroidOps.deviceId` · 없음 = 못 얻음 · 플랫폼 밖).
  /// 🔴 X1 «이 기기» 판정 재료 — 엔진 기동 입력(`BootInputs.deviceId`)은 엔진 E16t2b 가 넣는다.
  final String? deviceId;

  /// 🆕 E11p3d-2c(R136) — H-03 기기 측정(저장공간 · 배터리 · 보안 패치 · 온도 — 값만 · 없음 = 기기 리스크 원천 없음).
  final Future<DeviceRiskFacts> Function()? deviceProbe;

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

/// 🔴 셸 설정 원천 — 플래그 = 화면 상태 · 🆕 월 납입 = 엔진 운영값(R120) · 위성 목록 · 기간 프리셋 = 아직 원천 없음(R104 — 지어내지 않는다).
class OperatorConfigRepository implements ConfigRepository {
  /// 만든다 — [clock] · [kr] = 월 납입 읽기(오늘 · 적용 회차) · [tick] = 시간만 흐를 때 다시 계산하는 주기.
  OperatorConfigRepository(
    this._view, {
    required this.clock,
    required this.kr,
    this.tick = const Duration(minutes: 1),
  });

  final ValueListenable<OperatorView?> _view;

  /// 기기 시계(🔴 읽기는 신뢰 시각을 모르면 기기 시계 — 엔진 R54 J6 · 읽기는 상태를 바꾸지 않는다).
  final Clock clock;

  /// 국내 달력(적용 회차).
  final ExchangeCalendar kr;

  /// 다시 계산하는 주기(달이 바뀌어 예정 값이 지금 값이 되는 몫).
  final Duration tick;

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

  /// 🆕 R120 — 화면 상태 원장의 월 납입(엔진 `contributionSettingOf` · 기록 없음 = P0S 기본값).
  ContributionSetting _contributionOf(OperatorView v) {
    final DateTime now = clock.nowUtc();
    return contributionSettingOf(
      rows: contributionRowsOf(v.db),
      todayKst: contributionKstDay(now),
      observedAtUtc: now,
      kr: kr,
    );
  }

  /// 🆕 R120 — 월 납입 = 엔진 운영값(`operating_param_log`) · 기록마다 · 주기마다 · 화면 상태마다 · 바뀐 값만 ·
  /// 화면 상태 없음 = 오류.
  @override
  Stream<ContributionSetting> watchContributionSetting() =>
      followView<ContributionSetting>(
        view: _view,
        changes: (OperatorView v) => watchLedgerQuery<ContributionSetting>(
          v.db,
          const <String>{'operating_param_log'},
          () => _contributionOf(v),
        ),
        now: _contributionOf,
        tick: tick,
        noView: () => StateError('월 납입: 화면 상태 없음(온보딩 전)'),
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
