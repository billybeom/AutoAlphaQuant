// E11p4f — 모의 개시 가상 초기금 제출 → 명령(설계 13 §8 R155 · 01 §21-3 · 06 M5-14).

import 'dart:math';

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _dev = '3f2b8c1e-9a4d-4b6f-8e2a-1c5d7f9b0a3e';

const CommandContext _ctx = CommandContext(
  runMode: RunMode.simInternal,
  operatingMode: OperatingMode.autoTrade,
  leaseEpoch: 3,
  deviceId: _dev,
);

final DateTime _now = DateTime.utc(2026, 12, 1, 0, 5);

SelfReportSubmission _sub(
  String cash, {
  List<SelfReportLineInput> lines = const <SelfReportLineInput>[],
  bool complete = true,
  SelfReportPurpose purpose = SelfReportPurpose.simOpening,
}) => SelfReportSubmission(
  purpose: purpose,
  input: SelfReportInput(cashKrwText: cash, lines: lines),
  declaredComplete: complete,
);

SimOpeningWireResult _wire(SelfReportSubmission s) => simOpeningWireOf(
  s,
  asOfTradeDate: const TradeDate('2026-12-01'),
  sessionStartedAt: _now,
  accountAlias: 'KIS_PAPER',
  context: _ctx,
);

final RegExp _uuid4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  test(
    '🔴 금액 원문 → 값 — 공백 무시 · 쉼표 = 세 자리 묶음만 · 부호 · 소수 통과(엔진 거부) · 그 밖 = null',
    () {
      final Map<String, String> ok = <String, String>{
        '10000000': '10000000',
        '10,000,000': '10000000',
        ' 5000 ': '5000',
        '999': '999',
        '1,000': '1000',
        '0': '0',
        '-1': '-1',
        '1000.5': '1000.5',
        '1,234.50': '1234.5',
      };
      for (final MapEntry<String, String> e in ok.entries) {
        expect(cashKrwOfText(e.key), Decimal.parse(e.value), reason: e.key);
      }
      for (final String bad in <String>[
        '',
        '   ',
        'abc',
        '1,0000',
        '10,000,00',
        ',100',
        '100,',
        '1e6',
        '+100',
        '1 000',
        '１０００',
        '100원',
        '1.',
        '.5',
        '--1',
      ]) {
        expect(cashKrwOfText(bad), isNull, reason: bad);
      }
    },
  );

  test('🔴 와이어 = 모의 개시 · 줄 0 · 금액 · 별칭 · 맥락 · 기준일 · 세션 시각 · 확인값 그대로', () {
    final SimOpeningWireReady r =
        _wire(_sub('10,000,000')) as SimOpeningWireReady;
    expect(
      r.wire,
      SelfReportBalance(
        asOfTradeDate: const TradeDate('2026-12-01'),
        purpose: SelfReportPurpose.simOpening,
        sessionStartedAt: _now,
        lines: const <SelfReportLine>[],
        cashKrw: Decimal.parse('10000000'),
        accountAlias: 'KIS_PAPER',
        declaredComplete: true,
        context: _ctx,
      ),
    );
    final SimOpeningWireReady f =
        _wire(_sub('0', complete: false)) as SimOpeningWireReady;
    expect(f.wire.declaredComplete, isFalse);
    expect(f.wire.cashKrw, Decimal.zero);
  });

  test('🔴 로컬 거부 차례 = 빈칸 → 꼴 → 보유 줄(글자가 어느 칸인지 말한다)', () {
    const List<SelfReportLineInput> line = <SelfReportLineInput>[
      SelfReportLineInput(symbol: '229200', quantityText: '1'),
    ];
    String label(SimOpeningWireResult r) =>
        (r as SimOpeningInputInvalid).stateLabel;
    expect(label(_wire(_sub(''))), kSimOpeningCashBlank);
    expect(label(_wire(_sub('  '))), kSimOpeningCashBlank);
    expect(label(_wire(_sub('', lines: line))), kSimOpeningCashBlank);
    expect(label(_wire(_sub('1만'))), kSimOpeningCashMalformed);
    expect(label(_wire(_sub('1만', lines: line))), kSimOpeningCashMalformed);
    expect(label(_wire(_sub('1000', lines: line))), kSimOpeningLinesGiven);
    expect(kSimOpeningCashBlank, contains('가상 초기금'));
    expect(kSimOpeningCashMalformed, contains('숫자'));
  });

  test('🔴 정기 실사 제출 = ArgumentError(부르는 쪽이 가른다)', () {
    expect(
      () => _wire(_sub('1000', purpose: SelfReportPurpose.periodicAudit)),
      throwsArgumentError,
    );
  });

  test(
    '🔴 봉투 = 명령 id(UUID v4) · nonce 16바이트 · TTL 30분 · 접수증 종류 = 실사 · 발행 기기',
    () {
      final SimOpeningCommand c = SimOpeningCommand.issue(
        deviceId: _dev,
        nowUtc: _now,
        random: Random(7),
      );
      expect(_uuid4.hasMatch(c.commandId), isTrue, reason: c.commandId);
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(c.nonce), isTrue);
      expect(c.requestedAt, _now);
      expect(c.expiresAt, _now.add(const Duration(minutes: 30)));
      expect(kSimOpeningTtl, const Duration(minutes: 30));
      final CommandReceipt ok = c.receipt(executed: true, stateLabel: '넣었습니다');
      expect(ok.kind, CommandKind.selfReportBalance);
      expect(ok.state, CommandState.executed);
      expect(ok.stateLabel, '넣었습니다');
      expect(ok.commandId, c.commandId);
      expect(ok.nonce, c.nonce);
      expect(ok.issuedByDeviceId, _dev);
      expect(ok.requestedAt, _now);
      expect(ok.expiresAt, c.expiresAt);
      expect(ok.rejectReasonCode, isNull);
      final CommandReceipt no = c.receipt(
        executed: false,
        stateLabel: '아니요',
        rejectReasonCode: 'X',
      );
      expect(no.state, CommandState.rejected);
      expect(no.rejectReasonCode, 'X');
      expect(
        () => c.receipt(executed: false, stateLabel: '아니요'),
        throwsArgumentError,
      );
      final CommandReceipt bad = c.inputInvalid(kSimOpeningCashBlank);
      expect(bad.state, CommandState.rejected);
      expect(bad.rejectReasonCode, AdviceRejectCodes.inputInvalid);
      expect(bad.stateLabel, kSimOpeningCashBlank);
      expect(
        SimOpeningCommand.issue(
          deviceId: _dev,
          nowUtc: _now,
          random: Random(8),
        ).commandId,
        isNot(c.commandId),
      );
    },
  );
}
