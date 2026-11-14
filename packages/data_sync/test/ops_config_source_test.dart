// 🆕 E11p3c-2 — 지금 운영 설정 원천(설계 13 §8 R99): 모의 개시 판 → 사람 값 → 다시 지은 지문 대조.

import 'dart:io';

import 'package:core_engine/core_engine.dart'
    show P0sHumanInputs, P0sOpsConfig, P0sStrategyIds;
import 'package:data_sync/data_sync.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart' hide BreakerLevel;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _Clock implements Clock {
  _Clock(this.at);
  DateTime at;
  @override
  DateTime nowUtc() => at;
}

final DateTime _t0 = DateTime.utc(2026, 12, 21, 1);

const Map<String, String> _accounts = <String, String>{
  P0sStrategyIds.sleeveA: 'general',
  P0sStrategyIds.sleeveB: 'pension',
  P0sStrategyIds.sleeveC: 'general',
  P0sStrategyIds.pot: 'general',
};

const CommandContext _ctx = CommandContext(
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.autoTrade,
  leaseEpoch: 0,
  deviceId: 'dev-1',
);

SelfReportBalance _report() => SelfReportBalance(
  asOfTradeDate: const TradeDate('2026-12-21'),
  purpose: SelfReportPurpose.simOpening,
  sessionStartedAt: _t0,
  lines: const <SelfReportLine>[],
  cashKrw: Decimal.parse('10000000'),
  accountAlias: 'general',
  declaredComplete: true,
  context: _ctx,
);

P0sOpsConfig _config({String a = '999990'}) =>
    P0sOpsConfig.of(P0sHumanInputs(aSymbol: a, accountByStrategy: _accounts));

void main() {
  late Directory dir;
  late Database sim;
  late _Clock clock;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('e11p3c2_');
    sim = openLocalLedger(dir.path, RunMode.simInternal, clock: () => _t0);
    clock = _Clock(_t0);
  });

  tearDown(() {
    sim.close();
    dir.deleteSync(recursive: true);
  });

  String register(Object? content) =>
      SqliteConfigVersionStore(sim, clock: clock).register(content);

  void open(String configHash) {
    final SqliteOnboardingStore s = SqliteOnboardingStore(sim, clock: clock);
    expect(s.selectOperatingMode(OperatingMode.autoTrade).ok, true);
    expect(
      s
          .declareSimOpening(
            _report(),
            accountByStrategy: _accounts,
            configHash: configHash,
          )
          .ok,
      true,
    );
  }

  String codeOf(OpsConfigRead r) => (r as OpsConfigUnavailable).code;

  test('개시 결정 없음 = NO_OPENING', () {
    expect(codeOf(currentP0sOpsConfig(sim)), OpsConfigCodes.noOpening);
  });

  test('🔴 개시 판 = 등재된 판 → 사람 값 그대로 · 지문 같음', () {
    final P0sOpsConfig want = _config();
    open(register(want.content()));
    final OpsConfigReady r = currentP0sOpsConfig(sim) as OpsConfigReady;
    expect(r.configHash, want.configHash);
    expect(r.config.configHash, want.configHash);
    expect(r.config.aSymbol, '999990');
    expect(r.config.pensionAlias, 'pension');
    expect(r.config.human.accountByStrategy, _accounts);
  });

  test('🔴 개시가 가리키는 판이 등재 안 됨 = NOT_REGISTERED(다른 판을 대신 쓰지 않는다)', () {
    register(_config().content());
    open('feedfacefeedface');
    final OpsConfigUnavailable u =
        currentP0sOpsConfig(sim) as OpsConfigUnavailable;
    expect(u.code, OpsConfigCodes.notRegistered);
    expect(u.detail, 'feedfacefeedface');
  });

  test('🔴 SPEC 판이 다르면 = DRIFT', () {
    final Map<String, Object?> c = _config().content()..['spec'] = 'v2.43';
    open(register(c));
    final OpsConfigUnavailable u =
        currentP0sOpsConfig(sim) as OpsConfigUnavailable;
    expect(u.code, OpsConfigCodes.drift);
    expect(u.detail, contains('spec v2.43'));
  });

  test('🔴 같은 사람 값이어도 한도가 다르면(코드가 바뀜) = DRIFT', () {
    final Map<String, Object?> c = _config().content();
    c['limits'] = <String, Object?>{
      ...(c['limits']! as Map<String, Object?>),
      'max_orders_per_day': 999,
    };
    open(register(c));
    final OpsConfigUnavailable u =
        currentP0sOpsConfig(sim) as OpsConfigUnavailable;
    expect(u.code, OpsConfigCodes.drift);
    expect(u.detail, contains(_config().configHash));
  });

  test('사람 값 칸이 없거나 꼴이 아니면 = CONTENT_INVALID', () {
    final Map<String, Object?> c = _config().content()
      ..remove('sleeve_a_symbol');
    open(register(c));
    expect(codeOf(currentP0sOpsConfig(sim)), OpsConfigCodes.contentInvalid);
  });

  test('A 종목이 6자리가 아니면 = CONTENT_INVALID(칸 이름)', () {
    final Map<String, Object?> c = _config().content()
      ..['sleeve_a_symbol'] = '12345';
    open(register(c));
    final OpsConfigUnavailable u =
        currentP0sOpsConfig(sim) as OpsConfigUnavailable;
    expect(u.code, OpsConfigCodes.contentInvalid);
    expect(u.detail, contains('aSymbol'));
  });

  test('계좌 대응이 넷이 아니면 = CONTENT_INVALID', () {
    final Map<String, Object?> c = _config().content();
    c['accounts'] = <String, Object?>{
      P0sStrategyIds.sleeveA: 'general',
      P0sStrategyIds.sleeveB: 'pension',
    };
    open(register(c));
    expect(codeOf(currentP0sOpsConfig(sim)), OpsConfigCodes.contentInvalid);
  });

  test('계좌 별칭이 문자열이 아니면 = CONTENT_INVALID(칸 이름)', () {
    final Map<String, Object?> c = _config().content();
    c['accounts'] = <String, Object?>{..._accounts, P0sStrategyIds.pot: 7};
    open(register(c));
    final OpsConfigUnavailable u =
        currentP0sOpsConfig(sim) as OpsConfigUnavailable;
    expect(u.code, OpsConfigCodes.contentInvalid);
    expect(u.detail, contains('accounts.${P0sStrategyIds.pot}'));
  });
}
