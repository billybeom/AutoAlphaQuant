// 로컬 원장 두 파일과 SIM 판 파생 규칙 — 01 §6-0 · §9-2 · 설계 13 §8 R19 E9-2 · R20 Q1.
//
// 🔴 **파일이 경계다.** `ledger.sqlite`(LIVE)와 `ledger_sim.sqlite`(SIM 계열)는 같은 전체 스키마를 갖고,
//    다른 것은 `ddl/*.sql` 에서 줄 끝에 `-- @sim <종류>` 가 붙은 CHECK 뿐이다. 이 파일이 그 치환의
//    **코드 정본**이다(ddl/README «두 파일» 표와 같은 값 · C-15 가 대조한다).
// 🔴 열 때는 `PRAGMA application_id` 를 [LedgerFile.applicationId] 와 대조한다 — `mode` 칸이 없는
//    표까지 한 번에 덮는 파일 식별이다(R20 Q1). 대조는 로컬 러너(data_sync · E9c) 몫이다.
// 🔴 SQL 을 실행하지 않는다 — 문자열만 바꾼다(이 패키지는 DB 를 의존하지 않는다 · 01 §1-1).
// 🔵 열거형(enum)이 아니라 상수 클래스다 — 이 값들은 JSON 으로 오가지 않으므로 `@JsonValue`·`wire`
//    규약(C-12 · 01 §1-2)의 대상이 아니다.

import '../enums/mode.dart';

/// 로컬 원장 파일 — 01 §9-2(파일 분리 = 경계).
final class LedgerFile {
  const LedgerFile._(this.fileName, this.applicationId);

  /// 실계좌(`RunMode.live`). `application_id` = 'AAQL'.
  static const LedgerFile live = LedgerFile._('ledger.sqlite', 0x4141514C);

  /// 모의 계열(`RunMode.simInternal`·`RunMode.simBroker`). `application_id` = 'AAQS'.
  static const LedgerFile sim = LedgerFile._('ledger_sim.sqlite', 0x41415153);

  /// 두 파일 전부.
  static const List<LedgerFile> values = <LedgerFile>[live, sim];

  /// 기기 안 파일 이름.
  final String fileName;

  /// `PRAGMA application_id` 값 — 열 때 대조한다.
  final int applicationId;

  /// [mode] 가 쓰는 파일. 🔴 판정은 [RunModeIsSim.isSim] 하나로만 한다.
  static LedgerFile of(RunMode mode) => mode.isSim ? sim : live;

  @override
  String toString() => 'LedgerFile($fileName)';
}

/// `-- @sim <종류>` 태그의 종류 — LIVE 판 식과 SIM 판 식(ddl/README «두 파일»).
final class LedgerModeCheck {
  const LedgerModeCheck._(this.tag, this.liveExpr, this.simExpr);

  /// 결정 → 주문 → 체결 → 성과 사슬(`decision_log`·`order_intents`·`trades`·`equity_snapshot`·`rebalance_event`).
  static const LedgerModeCheck ledger = LedgerModeCheck._(
    'ledger',
    "mode = 'LIVE'",
    "mode IN ('SIM_INTERNAL','SIM_BROKER')",
  );

  /// 안내(`advice_batch`·`advice`) — `simBroker × advisory` 는 정의 모순이라 SIM 판도 `SIM_INTERNAL` 만.
  static const LedgerModeCheck advice = LedgerModeCheck._(
    'advice',
    "mode = 'LIVE'",
    "mode = 'SIM_INTERNAL'",
  );

  /// 캘린더 앵커(`calendar_link`·`calendar_sync_state`) — 계열 2값(G-32).
  static const LedgerModeCheck calendar = LedgerModeCheck._(
    'calendar',
    "mode = 'LIVE'",
    "mode = 'SIM'",
  );

  /// `order_intents.operating_mode` — SIM 판에서 `simBroker × advisory` 를 막는다(C8).
  static const LedgerModeCheck intentOperatingMode = LedgerModeCheck._(
    'intent-operating-mode',
    "operating_mode IN ('AUTO_TRADE','ADVISORY')",
    "operating_mode IN ('AUTO_TRADE','ADVISORY') AND "
        "(operating_mode = 'AUTO_TRADE' OR mode = 'SIM_INTERNAL')",
  );

  /// 🆕 v1.22(01 §31 · K61 · SPEC 02 :731 v2.44) — `executions.fill_origin`(배치 F) · 🔴 실계좌 파일은 `SIMULATED`(엔진 내부
  /// 가상 체결 · ds `order_ledger.dart:509-510`)를 받지 않는다. ⏸ `ddl/batch_f_x7_advisory.sql` 의 태그 줄 = **엔진 재생성 PR**
  /// (data_sync 배치 사본이 원문과 바이트 대조 — 같은 커밋에서만 움직인다 · v1 동결 12-21 전 · 01 §8 미결 189) · 그 전에는
  /// 두 파일이 같은 4값 CHECK 를 갖는다(C-56 ⑮ 두 상태 허용).
  static const LedgerModeCheck fillOrigin = LedgerModeCheck._(
    'fill-origin',
    "fill_origin IN ('BROKER','MANUAL','BROKER_RECOVERED')",
    "fill_origin IN ('BROKER','MANUAL','SIMULATED','BROKER_RECOVERED')",
  );

  /// 다섯 종류 전부(🆕 v1.22 +[fillOrigin]).
  static const List<LedgerModeCheck> values = <LedgerModeCheck>[
    ledger,
    advice,
    calendar,
    intentOperatingMode,
    fillOrigin,
  ];

  /// `-- @sim` 뒤에 오는 이름.
  final String tag;

  /// LIVE 판(`ddl/*.sql` 에 적힌 그대로)의 식.
  final String liveExpr;

  /// SIM 판의 식.
  final String simExpr;

  /// [file] 판의 식.
  String exprFor(LedgerFile file) =>
      identical(file, LedgerFile.sim) ? simExpr : liveExpr;

  @override
  String toString() => 'LedgerModeCheck($tag)';
}

/// 코드가 있는 줄의 **끝**에 붙은 태그만 태그다 — 설명 주석의 `@sim` 낱말을 태그로 읽지 않는다.
final RegExp _tagAtEnd = RegExp(r'^(.*\S.*?)\s*--\s*@sim\s+([A-Za-z-]+)\s*$');

/// LIVE 판 SQL [liveSql] 에서 [file] 판을 만든다.
///
/// 태그가 붙은 줄은 그 종류의 LIVE 식을 **정확히 한 번** 담아야 하고, SIM 판에서는 그것을 SIM 식으로
/// 바꾼다. 모르는 종류 · 식이 없거나 두 번 이상인 줄은 [FormatException] — 치환이 조용히 빠지면
/// 모의 파일이 LIVE 행만 받거나(전부 거부) 반대로 실계좌 파일이 SIM 행을 받는다.
String ledgerDdlFor(LedgerFile file, String liveSql) {
  final List<String> lines = liveSql.split('\n');
  for (int i = 0; i < lines.length; i++) {
    final RegExpMatch? m = _tagAtEnd.firstMatch(lines[i]);
    if (m == null || m.group(1)!.trimLeft().startsWith('--')) continue;
    final String name = m.group(2)!;
    final LedgerModeCheck kind = LedgerModeCheck.values.firstWhere(
      (LedgerModeCheck k) => k.tag == name,
      orElse: () =>
          throw FormatException('모르는 @sim 종류 «$name»', lines[i], i + 1),
    );
    final int n = kind.liveExpr.allMatches(lines[i]).length;
    if (n != 1) {
      throw FormatException(
        '@sim ${kind.tag} 줄에 «${kind.liveExpr}» 가 $n번 있다(정확히 1번이어야 한다)',
        lines[i],
        i + 1,
      );
    }
    lines[i] = lines[i].replaceFirst(kind.liveExpr, kind.exprFor(file));
  }
  return lines.join('\n');
}
