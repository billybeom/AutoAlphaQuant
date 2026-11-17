// E11p3d-5f — M9 S07 연결 관리 VM(설계 13 §8 R140) · 표본 = domain_contracts `m9/connections*` · `m8/incident_token_expired`.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

// 2026-12-01 09:00 KST.
final DateTime _now = DateTime.utc(2026, 12, 1);

bool _all(String _) => true;
bool _none(String _) => false;

const PaperCredentialFacts _verified = PaperCredentialFacts(
  stored: true,
  lastState: StepState.verified,
  lastAtUtc: null,
);

PaperCredentialFacts _kis({
  bool stored = true,
  StepState? state = StepState.verified,
  DateTime? at,
  String? code,
}) => PaperCredentialFacts(
  stored: stored,
  lastState: state,
  lastAtUtc: at ?? DateTime.utc(2026, 11, 30, 23, 42),
  lastFailureCode: code,
);

RemoteCheck _check(RemoteCheckStatus s, {DateTime? ping}) =>
    RemoteCheck(slug: 'x', status: s, lastPingUtc: ping);

ConnectionsVm _vm({
  PaperCredentialFacts? kis,
  HealthchecksReach reach = HealthchecksReach.read,
  List<RemoteCheck>? checks,
  RunMode run = RunMode.simInternal,
  bool Function(String) hasBody = _all,
}) => connectionsVmOf(
  ConnectionsFacts(
    runMode: run,
    kis: kis ?? _kis(),
    healthchecks: reach,
    checks:
        checks ??
        <RemoteCheck>[
          _check(
            RemoteCheckStatus.up,
            ping: _now.subtract(const Duration(minutes: 2)),
          ),
        ],
    hasBody: hasBody,
  ),
  nowUtc: _now,
);

ConnectionRow _row(ConnectionsVm vm, String target) =>
    vm.rows.singleWhere((ConnectionRow r) => r.target == target);

Map<String, Object?> _fx(String path) {
  final Map<String, Object?> env = jsonDecode(
    File('../domain_contracts/fixtures/$path.json').readAsStringSync(),
  ) as Map<String, Object?>;
  return (env['rows']! as List<Object?>).first! as Map<String, Object?>;
}

void main() {
  test('🔴 행 = 증권사 → Supabase → GitHub → 생존 신호(표본 `incident_token_expired` 차례) · 알림 채널 · 캘린더 = 부재', () {
    final ConnectionsVm vm = _vm();
    expect(vm.rows.map((ConnectionRow r) => r.target).toList(), <String>[
      ConnectionTargetCodes.brokerKis,
      ConnectionTargetCodes.supabase,
      ConnectionTargetCodes.githubArchive,
      ConnectionTargetCodes.healthchecks,
    ]);
    // 받을 채널(정확히 1 선택)을 지어낼 수 없다 → 피커 0.
    expect(
      vm.rows.map((ConnectionRow r) => r.channelPicker),
      everyElement(isNull),
    );
    // operator 동작 전 = 누르면 실패하는 버튼 0.
    expect(vm.rows.expand((ConnectionRow r) => r.actions), isEmpty);
    expect(vm.lockedLabel, isNull);
  });

  test('🔴 증권사 — 저장 + 통과 = 정상 OK · 링크 = S02(본문 있을 때만)', () {
    final ConnectionRow r = _row(_vm(), ConnectionTargetCodes.brokerKis);
    expect(r.label, '증권사 연결(모의투자)');
    expect((r.statusCode, r.statusLabel, r.level), ('OK', '정상', UiLevel.ok));
    expect(r.lastOkText, '12-01 08:42 검증 통과');
    expect(r.detailLine, isNull);
    expect(r.route, AppRoutes.settingsCredentials);
    expect(
      _row(_vm(hasBody: _none), ConnectionTargetCodes.brokerKis).route,
      isNull,
    );
    expect(
      connectionKisRowOf(_verified, runMode: RunMode.simInternal).lastOkText,
      '검증 시각 모름',
    );
  });

  test('🔴 증권사 — 거절 = 검증 실패 ACT(상세 = 시각 · 코드) · 기록 없음 = WATCH · 미저장 = 모의 ACT / 실전 INFO', () {
    final ConnectionRow failed = connectionKisRowOf(
      _kis(state: StepState.failed, code: 'CREDENTIAL_REJECTED'),
      runMode: RunMode.simInternal,
    );
    expect(
      (failed.statusCode, failed.statusLabel, failed.level),
      ('FAILED', '검증 실패', UiLevel.act),
    );
    expect(failed.lastOkText, '최근 성공 기록 없음');
    expect(failed.detailLine, '12-01 08:42 검증 거절(CREDENTIAL_REJECTED)');
    // 저장 전에 거절돼도 실패(S02 와 같은 축).
    expect(
      connectionKisRowOf(
        _kis(stored: false, state: StepState.failed),
        runMode: RunMode.simInternal,
      ).detailLine,
      '12-01 08:42 검증 거절(코드 없음)',
    );
    final ConnectionRow unknown = connectionKisRowOf(
      _kis(state: null),
      runMode: RunMode.simInternal,
    );
    expect(
      (
        unknown.statusCode,
        unknown.statusLabel,
        unknown.level,
        unknown.lastOkText,
      ),
      ('UNVERIFIED', '검증 기록 없음', UiLevel.watch, '검증한 적 없음'),
    );
    final ConnectionRow none = connectionKisRowOf(
      _kis(stored: false, state: null),
      runMode: RunMode.simBroker,
    );
    expect(
      (none.statusCode, none.statusLabel, none.level, none.lastOkText),
      ('NOT_SET', '연결 안 됨', UiLevel.act, '연결한 적 없음'),
    );
    expect(
      connectionKisRowOf(
        _kis(stored: false, state: null),
        runMode: RunMode.live,
      ).level,
      UiLevel.info,
    );
    // 통과 기록이 있어도 금고에 키가 없으면 = 연결 안 됨(키를 지웠거나 기기를 옮겼다 — S02 와 같은 축).
    final ConnectionRow lost = connectionKisRowOf(
      _kis(stored: false),
      runMode: RunMode.simInternal,
    );
    expect(
      (lost.statusCode, lost.statusLabel, lost.level),
      ('NOT_SET', '연결 안 됨', UiLevel.act),
    );
  });

  test(
    '🔴 Supabase · GitHub = 연결 전 → «연결 안 됨» INFO(경보 아님) · 상세 한 줄 · 링크 · 버튼 0',
    () {
      final ConnectionsVm vm = _vm();
      final ConnectionRow s = _row(vm, ConnectionTargetCodes.supabase);
      expect(
        (s.label, s.statusCode, s.statusLabel, s.lastOkText, s.level, s.route),
        ('미러(Supabase)', 'NOT_SET', '연결 안 됨', '연결한 적 없음', UiLevel.info, null),
      );
      expect(s.detailLine, '프로젝트 연결 전 — 실전 전에 필요합니다(운영 리스 · 읽기 미러)');
      final ConnectionRow g = _row(vm, ConnectionTargetCodes.githubArchive);
      expect((g.label, g.level), ('아카이브(GitHub)', UiLevel.info));
      expect(g.detailLine, '아카이브 저장소 · 접근 토큰 등록 전');
    },
  );

  test('🔴 생존 신호 — 연결 전 INFO · 읽지 못함 WATCH · 체크 0 WATCH(조치가 다르면 다르게 말한다)', () {
    ConnectionRow at(HealthchecksReach r, [List<RemoteCheck>? c]) => _row(
      _vm(reach: r, checks: c ?? const <RemoteCheck>[]),
      ConnectionTargetCodes.healthchecks,
    );
    final ConnectionRow notSet = at(HealthchecksReach.notSet);
    expect(
      (notSet.statusCode, notSet.statusLabel, notSet.level),
      ('NOT_SET', '연결 안 됨', UiLevel.info),
    );
    expect(notSet.detailLine, '읽기 키를 넣으면 체크 상태를 여기서 봅니다');
    final ConnectionRow unreadable = at(HealthchecksReach.unreadable);
    expect(
      (unreadable.statusCode, unreadable.statusLabel, unreadable.level),
      ('UNREADABLE', '읽지 못했습니다', UiLevel.watch),
    );
    expect(unreadable.detailLine, '네트워크나 읽기 키를 확인하세요');
    final ConnectionRow empty = at(HealthchecksReach.read);
    expect(
      (empty.statusCode, empty.statusLabel, empty.level, empty.lastOkText),
      ('NO_CHECKS', '체크 없음', UiLevel.watch, '받은 적 없음'),
    );
    expect(notSet.route, AppRoutes.opsWatchdog);
    expect(
      _row(_vm(hasBody: _none), ConnectionTargetCodes.healthchecks).route,
      isNull,
    );
  });

  test('🔴 생존 신호 — 끊김(down) BLOCKED > 늦음(grace) WATCH > 첫 신호 대기 INFO > 정상 OK · 마지막 수신 = 가장 늦은 핑', () {
    final DateTime twoMin = _now.subtract(const Duration(minutes: 2));
    final DateTime threeH = _now.subtract(const Duration(hours: 3));
    ConnectionRow at(List<RemoteCheck> c) =>
        _row(_vm(checks: c), ConnectionTargetCodes.healthchecks);
    final ConnectionRow down = at(<RemoteCheck>[
      _check(RemoteCheckStatus.up, ping: threeH),
      _check(
        RemoteCheckStatus.down,
        ping: twoMin.subtract(const Duration(hours: 5)),
      ),
      _check(RemoteCheckStatus.grace),
    ]);
    expect(
      (down.statusCode, down.statusLabel, down.level),
      ('FAILED', '신호 끊김', UiLevel.blocked),
    );
    expect(down.detailLine, '체크 3개 중 1개 유예 초과');
    expect(down.lastOkText, '3시간 전에 마지막 수신');
    final ConnectionRow late = at(<RemoteCheck>[
      _check(RemoteCheckStatus.up, ping: twoMin),
      _check(RemoteCheckStatus.grace),
      _check(RemoteCheckStatus.fresh),
    ]);
    expect(
      (late.statusCode, late.statusLabel, late.level, late.detailLine),
      ('LATE', '늦음', UiLevel.watch, '체크 3개 중 1개 유예 중'),
    );
    expect(late.lastOkText, '2분 전에 수신');
    final ConnectionRow waiting = at(<RemoteCheck>[
      _check(RemoteCheckStatus.fresh),
      _check(RemoteCheckStatus.unknown),
      _check(RemoteCheckStatus.up, ping: twoMin),
    ]);
    expect(
      (waiting.statusCode, waiting.statusLabel, waiting.level),
      ('WAITING', '첫 신호 대기', UiLevel.info),
    );
    expect(waiting.detailLine, '체크 3개 중 2개 첫 신호 전');
    final ConnectionRow ok = at(<RemoteCheck>[
      _check(RemoteCheckStatus.up, ping: twoMin),
      _check(RemoteCheckStatus.up, ping: threeH),
    ]);
    expect(
      (ok.statusCode, ok.statusLabel, ok.level, ok.detailLine),
      ('OK', '정상', UiLevel.ok, '체크 2개 모두 정상'),
    );
    expect(
      at(<RemoteCheck>[
        _check(RemoteCheckStatus.up, ping: twoMin),
        _check(RemoteCheckStatus.paused),
      ]).detailLine,
      '체크 2개 정상 · 1개 일시정지',
    );
    expect(
      at(<RemoteCheck>[_check(RemoteCheckStatus.fresh)]).lastOkText,
      '받은 적 없음',
    );
  });

  test('지난 시각 글자 — 방금 · 분 · 시간 · 일(미래 = 방금)', () {
    expect(connectionAgoText(_now, _now), '방금');
    expect(connectionAgoText(_now.add(const Duration(minutes: 5)), _now), '방금');
    expect(
      connectionAgoText(_now.subtract(const Duration(seconds: 59)), _now),
      '방금',
    );
    expect(
      connectionAgoText(_now.subtract(const Duration(minutes: 1)), _now),
      '1분 전',
    );
    expect(
      connectionAgoText(_now.subtract(const Duration(minutes: 59)), _now),
      '59분 전',
    );
    expect(
      connectionAgoText(_now.subtract(const Duration(hours: 1)), _now),
      '1시간 전',
    );
    expect(
      connectionAgoText(
        _now.subtract(const Duration(hours: 23, minutes: 59)),
        _now,
      ),
      '23시간 전',
    );
    expect(
      connectionAgoText(_now.subtract(const Duration(days: 1)), _now),
      '1일 전',
    );
    expect(
      connectionAgoText(_now.subtract(const Duration(days: 3)), _now),
      '3일 전',
    );
  });

  test('기준 = 지금 · 26시간 · KST 글자', () {
    final AsOf a = _vm().asOf;
    expect(a.observedAt, _now);
    expect(a.tradeDate, const TradeDate('2026-12-01'));
    expect(a.source, AsOfSource.localSqlite);
    expect(a.staleAfter, const Duration(seconds: 93600));
    expect(a.label, '연결 기준 2026-12-01 09:00');
  });

  test('표본과 같은 꼴 — VM · 행 JSON 키가 `m9/connections` 와 같다(글자는 엔진)', () {
    final Map<String, Object?> fx = _fx('m9/connections');
    final Map<String, Object?> ours =
        jsonDecode(jsonEncode(_vm().toJson())) as Map<String, Object?>;
    expect(ours.keys.toSet(), fx.keys.toSet());
    Map<String, Object?> first(Map<String, Object?> m) =>
        (m['rows']! as List<Object?>).first! as Map<String, Object?>;
    expect(first(ours).keys.toSet(), first(fx).keys.toSet());
    // 증권사 행 꼴 = `incident_token_expired` 의 BROKER_KIS 행(라벨만 «모의투자»를 덧붙였다).
    expect((first(ours)['label']! as String).startsWith('증권사 연결'), true);
  });
}
