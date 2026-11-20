// C-6 결정 8 게이트(손익 타입 격리) — 01 §7 표 C-6 · 인벤토리 §9(🟡 부분).
//
// 정의: 「홈·알림·위젯 위젯트리에 `HoldingPnl`·`PerformanceSeries` 타입 참조 금지」.
// 잡는 것: **홈 손익 노출**.
//
// 🟡 위젯트리 검사는 `ui_*` 선행이다. 여기서는 그보다 **앞의 방벽**을 고정한다 —
//    홈·알림 DTO 가 애초에 손익 타입을 **필드로 갖지 않는다**. 계약이 손익을 홈까지
//    실어 보내지 않으면 화면은 그릴 수가 없다.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// 결정 8 이 홈에서 막는 타입.
const List<String> _pnlTypes = <String>['HoldingPnl', 'PerformanceSeries'];

/// 홈·알림·셸 계열 DTO — 「위젯트리」의 계약 쪽 대응물.
const List<String> _homeTypes = <String>[
  'OpsDailySummary',
  'OpsRhythmRow',
  'ShellVm',
  'ShellChip',
  'AlertItem',
  'AckState',
  'FeatureFlags',
];

/// 손익으로 읽히는 JSON 키.
const List<String> _pnlJsonKeys = <String>[
  'pnl',
  'unrealized_pnl',
  'realized_pnl',
  'pnl_pct',
  'return_pct',
];

void main() {
  group('C-6 결정 8 게이트 (01 §7)', () {
    test('C-6 홈·알림·셸 DTO 가 손익 타입을 필드로 갖지 않는다', () {
      final Map<String, String> bodies = _freezedBodies();
      for (final String type in _homeTypes) {
        final String? body = bodies[type];
        expect(body, isNotNull, reason: '$type 이 계약에 없다 — 이름을 확인한다.');
        for (final String pnl in _pnlTypes) {
          expect(
            RegExp('\\b$pnl\\b').hasMatch(body!),
            isFalse,
            reason: '$type 이 $pnl 을 싣는다 — 홈이 손익을 그릴 수 있게 된다(결정 8).',
          );
        }
      }
    });

    test('C-6 홈 픽스처에 손익 키가 0건이다', () {
      const List<String> homeFixtures = <String>[
        FixturePaths.m8OpsHomeNormal,
        FixturePaths.m8OpsHomeBlocked,
        FixturePaths.m8OpsHomeAdviceOpen,
        FixturePaths.m8OpsHomeAdviceSuppressedDue,
        FixturePaths.m8OpsHomeAdviceZero,
        FixturePaths.m8OpsHomeResumeGap7,
        FixturePaths.alerts12,
        FixturePaths.m8AlertsDigest,
        FixturePaths.m8AlertsP0Ack,
        FixturePaths.m8AlertsAdvice9codes,
        // 🆕 v1.15(01 §24) — 알림 센터 5 · 상세 3(접수증 = 명령이라 뺀다).
        FixturePaths.m8AlertCenterP0Ack,
        FixturePaths.m8AlertCenterDigest,
        FixturePaths.m8AlertCenterEmpty,
        FixturePaths.m8AlertCenterP0Only,
        FixturePaths.m8AlertCenterP0AckReordered,
        FixturePaths.m8AlertDetailFull,
        FixturePaths.m8AlertDetailNoLink,
        FixturePaths.m8AlertDetailMissing,
        // 🆕 v1.16(01 §25) — 온보딩 VM 29(O-00·O-00b·O-01·O-02·O-04·R-01·V-01 · 결과 3 = 명령 결과라 뺀다).
        FixturePaths.m8OnboardingStart,
        FixturePaths.m8OnboardingStartNoViewer,
        FixturePaths.m8OnboardingModeUnselected,
        FixturePaths.m8OnboardingModeAuto,
        FixturePaths.m8OnboardingModeAdvisory,
        FixturePaths.m8OnboardingModeLocked,
        FixturePaths.m8OnboardingStepsFresh,
        FixturePaths.m8OnboardingStepsAdvisory,
        FixturePaths.m8OnboardingStepsFinishReady,
        FixturePaths.m8OnboardingStepsFinishReadyWarn,
        FixturePaths.m8OnboardingStepsAllVerifiedLocked,
        FixturePaths.m8OnboardingStepsEmpty,
        FixturePaths.m8OnboardingStepDetailKisMock,
        FixturePaths.m8OnboardingStepDetailNoVerify,
        FixturePaths.m8OnboardingStepDetailMissing,
        FixturePaths.m8OnboardingFinishAuto,
        FixturePaths.m8OnboardingFinishAutoReady,
        FixturePaths.m8OnboardingFinishAutoDeclared,
        FixturePaths.m8OnboardingFinishAdvisory,
        FixturePaths.m8OnboardingFinishAdvisoryDeclared,
        FixturePaths.m8OnboardingFinishNoExpectation,
        FixturePaths.m8OnboardingFinishDone,
        FixturePaths.m8RestartVmLostPhone,
        FixturePaths.m8RestartVmLoggedOut,
        FixturePaths.m8RestartVmGap7,
        FixturePaths.m8RestartVmUnknown,
        FixturePaths.m8PairingWaiting,
        FixturePaths.m8PairingOk,
        FixturePaths.m8PairingFail,
        // 🆕 v1.17(01 §26) — 배너 6 · 런북 4 · 카드 2 · 핸드북 6 · 기기 2 · 알림 1.
        FixturePaths.m8IncidentBannerTokenExpired,
        FixturePaths.m8IncidentBannerOrderRejected,
        FixturePaths.m8IncidentBannerNetworkDown,
        FixturePaths.m8IncidentBannerPhoneDown,
        FixturePaths.m8IncidentBannerOther,
        FixturePaths.m8IncidentBannerNone,
        FixturePaths.m8RunbookIndex,
        FixturePaths.m8RunbookIndexEmpty,
        FixturePaths.m8RunbookHostLost,
        FixturePaths.m8RunbookMissing,
        FixturePaths.m8EmergencyCard,
        FixturePaths.m8EmergencyCardNoPrint,
        FixturePaths.m8HandbookIndex,
        FixturePaths.m8HandbookIndexOutdated,
        FixturePaths.m8HandbookPageSleeveB,
        FixturePaths.m8HandbookPageOutdated,
        FixturePaths.m8HandbookPageMissing,
        FixturePaths.m8HandbookPageArchived,
        FixturePaths.m8DeviceRiskItems,
        FixturePaths.m8DeviceRiskEmpty,
        FixturePaths.m8AlertsStaleOrdersHeld,
        // 🆕 v1.18(01 §27) — S01 3 · S07 3 · 결과 1 · 알림 1.
        FixturePaths.m9SettingsHome,
        FixturePaths.m9SettingsHomeNoReview,
        FixturePaths.m9SettingsHomeViewer,
        FixturePaths.m9Connections,
        FixturePaths.m9ConnectionsTelegram,
        FixturePaths.m9ConnectionsLocked,
        FixturePaths.m9SettingsActionResults,
        FixturePaths.m8AlertsSafetyResume,
        // 🆕 v1.27(01 §36) — 엔진 등재형 알림 5.
        FixturePaths.m8AlertsEngineProposalsV127,
        // 🆕 v1.19(01 §28) — S05 7 · 결과 1.
        FixturePaths.m9OperationsSimAuto,
        FixturePaths.m9OperationsSimComplete,
        FixturePaths.m9OperationsLiveObserve,
        FixturePaths.m9OperationsLivePromotable,
        FixturePaths.m9OperationsLiveHoldKeys,
        FixturePaths.m9OperationsAdvisory,
        FixturePaths.m9OperationsLocked,
        FixturePaths.m9OperationsActionResults,
        // 🆕 v1.20(01 §29) — S02 4 · S06 5 · S03 3 · 결과 3.
        FixturePaths.m9Credentials,
        FixturePaths.m9CredentialsSimSealed,
        FixturePaths.m9CredentialsAdvisory,
        FixturePaths.m9CredentialsLocked,
        FixturePaths.m9CredentialActionResults,
        FixturePaths.m9DeviceAccess,
        FixturePaths.m9DeviceAccessTicket,
        FixturePaths.m9DeviceAccessNoViewers,
        FixturePaths.m9DeviceAccessStale,
        FixturePaths.m9DeviceAccessLocked,
        FixturePaths.m9DeviceActionResults,
        FixturePaths.m9AccountMapping,
        FixturePaths.m9AccountMappingUnmapped,
        FixturePaths.m9AccountMappingLocked,
        FixturePaths.m9AccountMappingActionResults,
        // 🆕 v1.21(01 §30) — 게이트 7 · 서약 3 · 결과 1 · 접수증 1.
        FixturePaths.m5KillResumeGateNotConfirmed,
        FixturePaths.m5KillResumeGateWaiting,
        FixturePaths.m5KillResumeGateTimeUnknown,
        FixturePaths.m5KillResumeGateReady,
        FixturePaths.m5KillResumeGateInProgress,
        FixturePaths.m5KillResumeGateConditionUnmet,
        FixturePaths.m5KillResumeGateLocked,
        FixturePaths.m5PledgeWritten,
        FixturePaths.m5PledgeNotWritten,
        FixturePaths.m5PledgeEditWindow,
        FixturePaths.m5SafetyActionResults,
        FixturePaths.m5KillChecklistReceipts,
        // 🆕 v1.22(01 §31) — 신설 15(사다리 2 · E13 결과 · simToAuto 계획 4 · 위저드 결과 · 게이트 4 · 리포트 2 · J-1 모의 거부).
        FixturePaths.m5BreakerLadderNormal,
        FixturePaths.m5BreakerLadderStopped,
        FixturePaths.m5SafetyActionResultsE13,
        FixturePaths.m5HandoverSimToAutoReady,
        FixturePaths.m5HandoverSimToAutoS3Blocked,
        FixturePaths.m5HandoverSimToAutoCooling,
        FixturePaths.m5HandoverSimToAutoFatePending,
        FixturePaths.m5HandoverSimToAutoActionResults,
        FixturePaths.x2ResumeGateSeasonalPending,
        FixturePaths.x2ResumeGateConservativeDefer,
        FixturePaths.x2ResumeGateReevaluationFailed,
        FixturePaths.x2ResumeGateLocked,
        FixturePaths.x2ResumeReportRecoveryFull,
        FixturePaths.x2ResumeReportNormal,
        FixturePaths.m6JournalSimBrokerReject,
        // 🆕 v1.23(01 §32) — 신설 7(S13 VM 6 · 결과 1).
        FixturePaths.m9MonthlyContribution,
        FixturePaths.m9MonthlyContributionPending,
        FixturePaths.m9MonthlyContributionNoRecord,
        FixturePaths.m9MonthlyContributionNoLimitNote,
        FixturePaths.m9MonthlyContributionLocked,
        FixturePaths.m9MonthlyContributionStale,
        FixturePaths.m9ContributionActionResults,
        // 🆕 v1.24(01 §33) — 신설 17(S09 VM 6 · 결과 1 · S10 VM 5 · 결과 1 · S12 VM 4).
        FixturePaths.m9Backup,
        FixturePaths.m9BackupAgeWarn,
        FixturePaths.m9BackupEmpty,
        FixturePaths.m9BackupSim,
        FixturePaths.m9BackupLocked,
        FixturePaths.m9BackupStale,
        FixturePaths.m9BackupActionResults,
        FixturePaths.m9DiagnosticsScreen,
        FixturePaths.m9DiagnosticsScreenDiff,
        FixturePaths.m9DiagnosticsScreenRunning,
        FixturePaths.m9DiagnosticsScreenLocked,
        FixturePaths.m9DiagnosticsScreenStale,
        FixturePaths.m9SelftestActionResults,
        FixturePaths.m9AnnualReviewIndexOpen,
        FixturePaths.m9AnnualReviewIndexClosed,
        FixturePaths.m9AnnualReviewIndexFirstYear,
        FixturePaths.m9AnnualReviewIndexStale,
        // 🆕 v1.25(01 §34) — 신설 17(킬스위치 화면 7 · 발동 접수증 1 · 게이트 꺼짐 1 · 보드 4 · 리포트 감싸개 3 · X2 게이트 1).
        FixturePaths.m5KillSwitchOff,
        FixturePaths.m5KillSwitchActiveUnrecorded,
        FixturePaths.m5KillSwitchCancelReadFailed,
        FixturePaths.m5KillSwitchRecordedWaiting,
        FixturePaths.m5KillSwitchRecordedReady,
        FixturePaths.m5KillSwitchLocked,
        FixturePaths.m5KillSwitchActiveLocked,
        FixturePaths.m5KillSwitchActivateReceipts,
        FixturePaths.m5KillResumeGateOff,
        FixturePaths.m5BlockBoardClear,
        FixturePaths.m5BlockBoardKillActive,
        FixturePaths.m5BlockBoardResumeIncomplete,
        FixturePaths.m5BlockBoardStopped,
        FixturePaths.x2ResumeReportScreenNormal,
        FixturePaths.x2ResumeReportScreenRecoveryFull,
        FixturePaths.x2ResumeReportScreenEmpty,
        FixturePaths.x2ResumeGateClear,
        // 🆕 v1.26(01 §35) — 신설 20(위저드 12 · 규칙 변경 게이트 5 · 결과 2 · 보드 RECON 1).
        FixturePaths.m5HandoverWizardTrialIncomplete,
        FixturePaths.m5HandoverWizardS3Blocked,
        FixturePaths.m5HandoverWizardFatePending,
        FixturePaths.m5HandoverWizardStartReady,
        FixturePaths.m5HandoverWizardCooling,
        FixturePaths.m5HandoverWizardCommitReady,
        FixturePaths.m5HandoverWizardWindowBlocked,
        FixturePaths.m5HandoverWizardExpired,
        FixturePaths.m5HandoverWizardTimeUnknown,
        FixturePaths.m5HandoverWizardNotApplicable,
        FixturePaths.m5HandoverWizardCommitted,
        FixturePaths.m5HandoverWizardLocked,
        FixturePaths.m5RuleChangeGateFirstCandidate,
        FixturePaths.m5RuleChangeGateCooling,
        FixturePaths.m5RuleChangeGateApprovable,
        FixturePaths.m5RuleChangeGateEmpty,
        FixturePaths.m5RuleChangeGateLocked,
        FixturePaths.m5RuleChangeRequestResults,
        FixturePaths.m5BlockBoardReconMismatch,
        FixturePaths.m5ReconClearResults,
        // 🆕 v1.28(01 §37) — S04 첫 판 2(백테스트 한 줄 = 05 원칙 3 예외 · 손익·금액 키 0).
        FixturePaths.m9AllocationEditor,
        FixturePaths.m9AllocationEditorStale,
      ];
      final List<String> offenders = <String>[];
      for (final String path in homeFixtures) {
        walkJson(jsonDecode(readFixture(path)), (
          String jsonPath,
          String key,
          Object? value,
        ) {
          if (_pnlJsonKeys.contains(key) && value != null) {
            offenders.add('$path $jsonPath');
          }
        });
      }
      expect(
        offenders,
        isEmpty,
        reason: '홈·알림 픽스처가 손익을 싣는다 — 계약이 이미 결정 8 을 어긴 것이다.',
      );
    });

    test('C-6 손익은 보유현황에서 «요청한 행»에만 실린다', () {
      // 인벤토리 §8-2 — holdings_6.json 은 6행 중 `pnl` 이 **3건만** 있다.
      // 🔴 「전 행에 실려 오는데 화면이 가린다」가 아니라 「엔진이 주지 않는다」가
      //    결정 8 의 형태다.
      final FixtureEnvelope envelope = decodeEnvelope(
        readFixture(FixturePaths.holdings6),
      );
      final List<HoldingRow> rows = envelope.rows
          .map(HoldingRow.fromJson)
          .toList();
      expect(rows, hasLength(6));
      final int withPnl = rows.where((HoldingRow r) => r.pnl != null).length;
      expect(withPnl, 3, reason: '보유현황 픽스처의 손익 건수가 인벤토리 §8-2(3건)와 다르다.');
      expect(
        rows.where((HoldingRow r) => r.pnl == null),
        isNotEmpty,
        reason: 'pnl 은 nullable 이어야 한다 — 없는 것을 0 으로 만들지 않는다.',
      );
    });

    test('C-6 손익 타입은 여전히 계약에 있다(격리이지 삭제가 아니다)', () {
      final Map<String, String> bodies = _freezedBodies();
      for (final String type in _pnlTypes) {
        expect(
          bodies.containsKey(type),
          isTrue,
          reason: '$type 이 계약에서 사라졌다 — C-6 은 «홈에서 격리»이지 «삭제»가 아니다.',
        );
      }
      // 손익을 싣는 자리는 보유현황 상세와 성과 화면이다.
      expect(bodies['HoldingRow'], contains('HoldingPnl'));
    });

    test(
      'C-6 홈·알림·위젯 위젯트리의 타입 참조 검사',
      () {},
      skip:
          'ui_shell·홈 위젯이 아직 없다. 계약 쪽 방벽(위 4건)은 «엔진이 안 준다»를 '
          '고정하고, 위젯트리 검사는 화면이 들어오는 PR 에서 채운다 — 둘 다 필요하다'
          '(화면은 다른 화면의 DTO 를 import 할 수 있다).',
    );
  });
}

Map<String, String> _freezedBodies() {
  final Map<String, String> out = <String, String>{};
  final RegExp re = RegExp(
    r'abstract class (\w+)\s+with _\$\w+[^{]*\{(.*?)\n\}',
    dotAll: true,
  );
  for (final File f in dartSourcesIn(libDir)) {
    final String source = stripComments(f.readAsStringSync());
    for (final RegExpMatch m in re.allMatches(source)) {
      out[m.group(1)!] = m.group(2)!;
    }
  }
  return out;
}
