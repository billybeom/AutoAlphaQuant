// E11q-c4 — M5-5 RECON 해제 폼 · 판정 · 결과 글자(설계 13 §8 R189 · 01 §35 K180~K182 · 미결 206 RECON 몫).
//
// 🔴 폼 = 표본 `m5/block_board_recon_mismatch` RECON 행 그대로(선택지 차례 · 글자 · 고지 «(합성)» 뗌) · 선택지 ⊆ 쓰기 화이트리스트 ·
//    해제 원인 코드 · 브로커 계열(X7 · 파생 · 옛 코드 0) · 결과 = 표본 `m5/recon_clear_results` 6행 글자 같음 · 판정 차례 = 상태 먼저.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

List<Map<String, Object?>> _rows(String f) => <Map<String, Object?>>[
  for (final Object? r
      in (jsonDecode(
            File('../domain_contracts/fixtures/m5/$f.json').readAsStringSync(),
          ) as Map<String, Object?>)['rows']!
          as List<Object?>)
    r! as Map<String, Object?>,
];

String _plain(String s) => s.replaceFirst('(합성) ', '');

String? _reject({
  bool blocked = true,
  String originCode = OriginCodes.fillLag,
  String rationaleBefore = '체결 보고가 늦게 왔다',
  String expectedOutcome = '다음 대사에서 맞는다',
  String ruleCited = '04 §3-5 ②',
  bool journalIdTaken = false,
}) => reconClearRejectCode(
  blocked: blocked,
  originCode: originCode,
  rationaleBefore: rationaleBefore,
  expectedOutcome: expectedOutcome,
  ruleCited: ruleCited,
  journalIdTaken: journalIdTaken,
);

void main() {
  group('폼', () {
    test('= 표본 block_board_recon_mismatch RECON 행(선택지 차례 · 글자 · 고지)', () {
      final BlockBoardVm fx = BlockBoardVm.fromJson(
        _rows('block_board_recon_mismatch').single,
      );
      final ReconClearForm want = fx.rows
          .singleWhere((BlockBoardRow r) => r.rowId == FlagIds.reconMismatch)
          .reconClear!;
      final ReconClearForm got = reconClearFormOf();
      expect(got.choices, want.choices);
      expect(got.noticeText, _plain(want.noticeText!));
      expect(got.noticeText, ReconClearTexts.notice);
    });

    test('🔴 선택지 = 브로커 계열 6 · 쓰기 화이트리스트 ∩ 해제 원인 코드 · X7 · 파생 · 옛 코드 0', () {
      final List<String> codes = <String>[
        for (final ReconOriginChoice c in reconClearFormOf().choices)
          c.originCode,
      ];
      expect(codes, kReconClearChoiceCodes);
      expect(codes, <String>[
        OriginCodes.fillLag,
        OriginCodes.manualOrder,
        OriginCodes.dbError,
        OriginCodes.brokerError,
        OriginCodes.externalCashflow,
        OriginCodes.corporateAction,
      ]);
      expect(codes.toSet(), hasLength(codes.length));
      for (final String c in codes) {
        expect(OriginCodes.writable, contains(c), reason: c);
        expect(
          writableOriginCodesFor(LedgerPair.canonBroker),
          contains(c),
          reason: c,
        );
        expect(kReconClearOriginCodes, contains(c), reason: c);
        expect(OriginCodes.broker, contains(c), reason: c);
        expect(OriginCodes.x7, isNot(contains(c)), reason: c);
        expect(OriginCodes.derived, isNot(contains(c)), reason: c);
      }
      expect(codes, isNot(contains(OriginCodes.corpActionLegacy)));
      for (final ReconOriginChoice c in reconClearFormOf().choices) {
        expect(c.label, kOriginLabels[c.originCode], reason: c.originCode);
      }
    });
  });

  group('판정', () {
    test('다 채움 = null(푼다)', () {
      expect(_reject(), isNull);
      for (final String c in kReconClearChoiceCodes) {
        expect(_reject(originCode: c), isNull, reason: c);
      }
    });

    test('🔴 차례 = 막힘 없음 → 원인 코드 → 저널 세 칸 → 저널 id 겹침', () {
      expect(
        _reject(
          blocked: false,
          originCode: 'NOPE',
          rationaleBefore: '',
          journalIdTaken: true,
        ),
        ReconClearResultCodes.notBlocked,
      );
      expect(
        _reject(originCode: 'NOPE', rationaleBefore: '', journalIdTaken: true),
        ReconClearResultCodes.originNotAllowed,
      );
      expect(
        _reject(rationaleBefore: '', journalIdTaken: true),
        ReconClearResultCodes.journalMissing,
      );
      expect(
        _reject(journalIdTaken: true),
        SafetyCommonResultCodes.journalIdTaken,
      );
    });

    test('🔴 선택지 밖 원인 코드 = 거부(옛 코드 · X7 · 파생 · 빈 글자 · 소문자)', () {
      for (final String c in <String>[
        OriginCodes.corpActionLegacy,
        ...OriginCodes.x7,
        ...OriginCodes.derived,
        '',
        'fill_lag',
        ' ${OriginCodes.fillLag}',
      ]) {
        expect(
          _reject(originCode: c),
          ReconClearResultCodes.originNotAllowed,
          reason: c,
        );
      }
    });

    test('🔴 저널 세 칸 — 하나라도 비거나 공백뿐 = 거부', () {
      for (final String blank in <String>['', '   ', '\n\t']) {
        expect(
          _reject(rationaleBefore: blank),
          ReconClearResultCodes.journalMissing,
        );
        expect(
          _reject(expectedOutcome: blank),
          ReconClearResultCodes.journalMissing,
        );
        expect(_reject(ruleCited: blank), ReconClearResultCodes.journalMissing);
      }
    });
  });

  group('결과 글자', () {
    test('= 표본 recon_clear_results 6행(수준 · 글자 «(합성)» 뗌 · 코드 · 재시도 0 · id)', () {
      final List<Map<String, Object?>> rows = _rows('recon_clear_results');
      expect(rows, hasLength(6));
      for (final Map<String, Object?> row in rows) {
        final SafetyActionResult fx = SafetyActionResult.fromJson(row);
        final SafetyActionResult got = reconClearActionResultOf(
          actionRunId: fx.actionRunId,
          code: fx.reasonCode,
        );
        expect(
          (got.id, got.level, got.headline, got.reasonCode, got.retryable),
          (fx.id, fx.level, _plain(fx.headline), fx.reasonCode, fx.retryable),
          reason: '${fx.reasonCode}',
        );
        expect(got.actionRunId, fx.actionRunId);
        expect(got.handoffRoute, isNull);
      }
    });

    test(
      '표본 safety_action_results_e13 RECON 거부 행도 같다(성공 행 = v1.26 표본이 정본)',
      () {
        int n = 0;
        for (final Map<String, Object?> row in _rows(
          'safety_action_results_e13',
        )) {
          final SafetyActionResult fx = SafetyActionResult.fromJson(row);
          // 🔵 R189 — e13(v1.22) 성공 글자 «…풀었습니다.» 는 v1.26 `recon_clear_results` 성공 글자로 갈음(저널을 함께 쓴다).
          if (fx.id != SafetyActionId.reconClear || fx.reasonCode == null) {
            continue;
          }
          final SafetyActionResult got = reconClearActionResultOf(
            actionRunId: fx.actionRunId,
            code: fx.reasonCode,
          );
          expect(
            (got.level, got.headline, got.reasonCode),
            (fx.level, _plain(fx.headline), fx.reasonCode),
          );
          n++;
        }
        expect(n, greaterThan(0));
      },
    );

    test('🔴 사전 = 계약 RECON 코드 3 ∪ 저널 id 겹침 ∪ 생체 · 모르는 코드 = 오류', () {
      for (final String c in <String>{
        ...ReconClearResultCodes.values,
        SafetyCommonResultCodes.journalIdTaken,
        SettingsResultCodes.biometricUnavailable,
      }) {
        final SafetyActionResult r = reconClearActionResultOf(
          actionRunId: 'r',
          code: c,
        );
        expect(r.reasonCode, c);
        expect(r.level, isNot(UiLevel.ok), reason: c);
      }
      expect(reconClearActionResultOf(actionRunId: 'r').level, UiLevel.ok);
      expect(
        () => reconClearActionResultOf(actionRunId: 'r', code: 'NOPE'),
        throwsArgumentError,
      );
      expect(
        () => reconClearActionResultOf(
          actionRunId: 'r',
          code: SafetyCommonResultCodes.trustedTimeUnknown,
        ),
        throwsArgumentError,
      );
    });
  });
}
