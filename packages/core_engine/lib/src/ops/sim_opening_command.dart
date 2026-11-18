// E11p4f — 모의 개시 가상 초기금 제출 → 명령(설계 13 §8 R155 · 01 §21-3 구현 의무 · 06 M5-14 · X6-5 ⓑ · 01 §8 미결 154).
//
// 🔴 화면 검증 0(K4) — 빈칸 · 꼴 = 여기서 거부(큐 적재 없이 `INPUT_INVALID` · 글자가 어느 칸인지 말한다) ·
//    0 이하 · 원 미만 = 엔진 거부(`SimOpeningCodes` · 문구 = 엔진 — 같은 규칙을 두 곳에서 짓지 않는다).
// 🔴 맥락(`CommandContext`)은 화면이 아니라 `CommandApi` 구현이 싣는다(G-19) — 여기는 순수 변환 · 봉투.
// 🔴 자동 매매 갈래 = 금액 1칸 · 보유 줄 0(`lines` [] — 줄이 오면 로컬 거부) · 세션 밖 거부 대상 아님(와이어 주석 ①).
// 🔵 TTL = 30분(알림 확인 · 실입금 등록 선례) — 폰 안에서 바로 실행되므로 TTL 을 쓰기 전에 끝난다.

import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart'
    show
        AdviceRejectCodes,
        CommandContext,
        CommandKind,
        CommandReceipt,
        CommandState,
        SelfReportBalance,
        SelfReportLine,
        SelfReportPurpose,
        SelfReportSubmission,
        TradeDate;

import 'alert_ack_command.dart' show newCommandId;

/// 모의 개시 제출 명령 TTL.
const Duration kSimOpeningTtl = Duration(minutes: 30);

/// 로컬 거부 글자 — 금액 칸이 비었다.
const String kSimOpeningCashBlank = '가상 초기금 칸이 비어 있습니다 — 금액을 적어 주세요.';

/// 로컬 거부 글자 — 금액 칸이 숫자 꼴이 아니다.
const String kSimOpeningCashMalformed = '가상 초기금 칸은 숫자로만 적어 주세요(쉼표는 세 자리마다).';

/// 로컬 거부 글자 — 보유 종목 줄이 왔다(자동 매매 갈래 = 금액 한 칸).
const String kSimOpeningLinesGiven =
    '가상 초기금 선언은 금액 한 칸만 받습니다 — 보유 종목 줄은 넣지 않습니다.';

final RegExp _cashPattern = RegExp(r'^-?(?:\d+|\d{1,3}(?:,\d{3})+)(?:\.\d+)?$');

/// 🔴 금액 원문 → 값(꼴 틀림 = null) — 앞뒤 공백 무시 · 쉼표 = 세 자리 묶음만 · 부호 · 소수 = 통과(엔진이 0 이하 ·
/// 원 미만을 거부한다).
Decimal? cashKrwOfText(String text) {
  final String t = text.trim();
  if (!_cashPattern.hasMatch(t)) return null;
  return Decimal.parse(t.replaceAll(',', ''));
}

/// 제출 → 와이어 결과.
sealed class SimOpeningWireResult {
  const SimOpeningWireResult();
}

/// 와이어가 섰다(엔진에 넘긴다).
final class SimOpeningWireReady extends SimOpeningWireResult {
  /// 만든다.
  const SimOpeningWireReady(this.wire);

  /// 와이어.
  final SelfReportBalance wire;
}

/// 원문이 틀렸다 — 큐 적재 없이 `INPUT_INVALID`.
final class SimOpeningInputInvalid extends SimOpeningWireResult {
  /// 만든다.
  const SimOpeningInputInvalid(this.stateLabel);

  /// 어느 칸인지 말하는 글자.
  final String stateLabel;
}

/// 🔴 모의 개시 제출 → 와이어 — [submission] 은 `simOpening` 이어야 한다(아니면 [ArgumentError] · 부르는 쪽이 가른다).
///
/// 차례 = 빈칸 → 꼴 → 보유 줄. [accountAlias] · [context] · [asOfTradeDate] · [sessionStartedAt] = 구현이 싣는다 ·
/// `declaredComplete` = 제출 그대로.
SimOpeningWireResult simOpeningWireOf(
  SelfReportSubmission submission, {
  required TradeDate asOfTradeDate,
  required DateTime sessionStartedAt,
  required String accountAlias,
  required CommandContext context,
}) {
  if (submission.purpose != SelfReportPurpose.simOpening) {
    throw ArgumentError.value(submission.purpose, 'purpose', '모의 개시 제출이 아니다');
  }
  final String raw = submission.input.cashKrwText;
  if (raw.trim().isEmpty) {
    return const SimOpeningInputInvalid(kSimOpeningCashBlank);
  }
  final Decimal? cash = cashKrwOfText(raw);
  if (cash == null) {
    return const SimOpeningInputInvalid(kSimOpeningCashMalformed);
  }
  if (submission.input.lines.isNotEmpty) {
    return const SimOpeningInputInvalid(kSimOpeningLinesGiven);
  }
  return SimOpeningWireReady(
    SelfReportBalance(
      asOfTradeDate: asOfTradeDate,
      purpose: SelfReportPurpose.simOpening,
      sessionStartedAt: sessionStartedAt.toUtc(),
      lines: const <SelfReportLine>[],
      cashKrw: cash,
      accountAlias: accountAlias,
      declaredComplete: submission.declaredComplete,
      context: context,
    ),
  );
}

String _hex(Random r, int bytes) => <String>[
  for (int i = 0; i < bytes; i++)
    r.nextInt(256).toRadixString(16).padLeft(2, '0'),
].join();

/// 모의 개시 제출 명령 봉투(접수증의 id · nonce · 시각).
class SimOpeningCommand {
  /// 직접 만든다(시험 · 재구성).
  const SimOpeningCommand({
    required this.commandId,
    required this.nonce,
    required this.requestedAt,
    required this.expiresAt,
    required this.deviceId,
  });

  /// 지금 낸다 — [random] = 명령 id · nonce 원천(운영 = `Random.secure()`).
  factory SimOpeningCommand.issue({
    required String deviceId,
    required DateTime nowUtc,
    required Random random,
  }) {
    final DateTime at = nowUtc.toUtc();
    return SimOpeningCommand(
      commandId: newCommandId(random),
      nonce: _hex(random, 16),
      requestedAt: at,
      expiresAt: at.add(kSimOpeningTtl),
      deviceId: deviceId,
    );
  }

  /// 명령 id.
  final String commandId;

  /// 1회용 값.
  final String nonce;

  /// 낸 시각(UTC).
  final DateTime requestedAt;

  /// TTL 끝(UTC).
  final DateTime expiresAt;

  /// 낸 기기.
  final String deviceId;

  /// 처리 결과 → 접수증 — [stateLabel] = 엔진 글자 그대로 · 거부에는 [rejectReasonCode] 필수.
  CommandReceipt receipt({
    required bool executed,
    required String stateLabel,
    String? rejectReasonCode,
  }) {
    if (!executed && rejectReasonCode == null) {
      throw ArgumentError('거부에는 사유 코드가 있어야 한다');
    }
    return CommandReceipt(
      commandId: commandId,
      kind: CommandKind.selfReportBalance,
      state: executed ? CommandState.executed : CommandState.rejected,
      stateLabel: stateLabel,
      requestedAt: requestedAt,
      expiresAt: expiresAt,
      nonce: nonce,
      issuedByDeviceId: deviceId,
      rejectReasonCode: executed ? null : rejectReasonCode,
    );
  }

  /// 로컬 거부(원문 틀림) 접수증 — `INPUT_INVALID`.
  CommandReceipt inputInvalid(String stateLabel) => receipt(
    executed: false,
    stateLabel: stateLabel,
    rejectReasonCode: AdviceRejectCodes.inputInvalid,
  );
}
