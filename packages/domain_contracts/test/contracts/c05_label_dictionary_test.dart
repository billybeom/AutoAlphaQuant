// C-5 사유 문구 하드코딩 탐지 / 코드 사전 완결성 — 01 §7 표 C-5 · §1-5 · §3.
//
// 정의(01 §7): 「`ui_*` 에서 `lib/l10n/labels.dart` 를 제외한 전 파일의 한글 리터럴
//   0건 + §3 의 label 문자열·`'TIER '`·`'SAF-'` 리터럴 금지」.
// 🟡 그 절반(`ui_*` 스캔)은 화면 코드가 있어야 실효가 있다 — `tool/check_labels.sh`
//   가 셸에서 같은 일을 하며, 여기서는 **나머지 절반**을 고정한다:
//   «코드 → 문구» 를 화면이 지어내지 못하게 하는 근거인 **코드 사전의 완결성**이다.
//
// 🔴 이 폴더(`lib/src/labels/`)에 있는 것은 «어떤 **코드**가 오는가» 의 상수 목록이지
//    코드→문자열 매핑이 아니다(labels.dart 머리 주석). 그래서 이 검사는
//    ① 모든 코드가 사전에 등재돼 있고 ② 중복이 문서가 밝힌 것뿐이며
//    ③ 미등록 코드가 조용히 통과하지 않는지를 본다.

import 'dart:convert';
import 'dart:io';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// 01 §3 사전의 도메인 간 중복 — labels.dart 머리 주석이 밝힌 쌍(🆕 v1.24 = 일곱 쌍).
const Set<String> _documentedCrossDomainDuplicates = <String>{
  'MANUAL_ORDER',
  'PUSH_LAG',
  'RECON_MISMATCH',
  'SELF_AUDIT_DUE',
  // 🆕 v1.22(01 §31 · K12) — `flag_id` ↔ `discretion_result` · labels 머리 다섯째 쌍.
  'JOURNAL_MISSING',
  // 🆕 v1.24(01 §33 · K119) — `origin_code` ↔ `ledger_integrity_result` · `backup_result` · labels 머리 일곱 쌍.
  'CHAIN_BROKEN',
  'RESTORE_ROLLBACK',
};

/// 픽스처의 코드 필드 → 조회할 도메인(빈 값이면 전역 조회).
const Map<String, String> _fixtureCodeFields = <String, String>{
  'flag_id': 'flag_id',
  'kind_code': 'deviation_kind',
  'step_code': 'aftertax_step',
  'stale_reason_code': 'stale_reason',
  // 🆕 v1.1 R2 준비(2026-09-23) — `CommandReceipt.rejectReasonCode` 는 X7 명령(`advice_reject`)과
  //    J-3 사전 저널(`journal_draft_reject`) · 🆕 v1.7 J-4 blind 리뷰(`blind_review_reject`) **세 사전**의
  //    값을 같은 JSON 키로 싣는다 → 전역 조회(`stage_code` 선례). 사전별 대조는 C-16 이 한다 — 행의 `kind` 로
  //    사전을 정해 전 픽스처에(X7 8종 = advice_reject(🆕 v1.12 +DEFER_ADVICE_CONFIRM · 18종) · JOURNAL_DRAFT = journal_draft_reject ·
  //    BLIND_REVIEW_SCORE = blind_review_reject · 정해지지 않은 kind = 실패).
  'reject_reason_code': '',
  // 🆕 v1.12(01 §21 · K20) — `CommandReceipt.retryCode`(재제출 선택지 · X7 기록 명령 전용 · C-46 ⑧ 이 짝을 맞댄다).
  'retry_code': 'advice_retry',
  'close_reason_code': 'decision_reason',
  'cause_code': 'advice_transition_cause',
  'reason_code': '',
  // 🆕 v1.1 — `DecisionChainStep.stageCode`(체인 단계)와 `RejectTrace.stageCode`(전수 검사 층)가
  //    같은 JSON 키를 쓰므로 전역 조회다(두 도메인 어느 쪽이든 등재돼 있으면 된다).
  'stage_code': '',
  'badge_code': 'journal_badge',
  // 🆕 v1.8(01 §17) — `StopLineNormalized.tierCode`(손절선 등급 · `StopTierCodes` · C-44 ⑦ 도 같은 사전을 맞댄다).
  'tier_code': 'stop_tier',
  // 🆕 v1.16(01 §25 · K21) — 온보딩 🔒 슬롯 이름 4칸(`OnboardingSlotIds` · 화면은 이름을 빌더에 그대로 넘긴다).
  //    결과 `reason_code`(`OnboardingResultCodes`·`BrokerRawCodes`)는 위 전역 조회로 덮인다.
  'secret_slot_id': 'onboarding_slot',
  'slot_id': 'onboarding_slot',
  'login_slot_id': 'onboarding_slot',
  'scanner_slot_id': 'onboarding_slot',
  // 🆕 v1.17(01 §26 · K19) — `D-03` 긴급정지 카드 인쇄 슬롯 이름(`OpsSlotIds` · 화면은 이름을 빌더에 그대로 넘긴다).
  'print_slot_id': 'ops_slot',
  // 🆕 v1.18(01 §27 · K-n ⓗ) — `ConnectionRow.target`·동작 args 의 연결 대상 · 채널 선택 args·옵션의 채널
  //    (`ConnectionTargetCodes` · `NotifyChannelCodes` · 다른 표본의 같은 키 쓰임 0 — git grep 실측).
  'target': 'connection_target',
  'channel': 'notify_channel',
  // 🆕 v1.19(01 §28 · K21) — `SimTrialCheck` 의 항목·상태 코드(다른 표본 쓰임 0 — git grep 실측).
  'item_code': 'sim_trial_item',
  'item_state': 'sim_trial_state',
  // 🆕 v1.20(01 §29 · K31) — `S02` 카드 슬롯(`settings_slot` 3 + 모의 = `onboarding_slot` `SECRET_KIS_MOCK` 재사용 → 전역 조회 ·
  //    좁힘 = C-54 ④) · `S06` QR 자리. 🔴 `secret_slot_id` 키를 쓰지 않는다(위 온보딩 사전 고정 · C-50 ⑮).
  'credential_slot_id': '',
  'qr_slot_id': 'settings_slot',
};

/// 🔴 **사전에 없는 코드 축** — 01 §3 이 열거하지 않은 값이라 검사 대상이 아니다.
///    지우지 않고 남긴다: 「검사에서 빠졌다」와 「검사 대상이 아니다」는 다르다.
const Map<String, String> _fieldsOutsideDictionary = <String, String>{
  'failure_reason_code':
      'OnboardingStep.failureReasonCode — 01 §3 에 온보딩 실패 코드 목록이 없다'
      '(픽스처 값: CONSENT_EXPIRED·PERMISSION_DENIED · 🆕 v1.16 TOKEN_EXPIRED). 등재는 M2-8 의 일이다.',
  'status_code':
      '진단·인시던트 칸의 상태 코드(OK·LAG·TOKEN_EXPIRED) — §3 이 아니라 화면 상태 축이며 '
      '짝이 되는 status_label 이 함께 온다 · 🆕 v1.18 S07 `ConnectionRow` — `level` 이 색 근거(01 §27 K-r) · '
      '🆕 v1.19 S05 `JobRow` — `level` 이 색 근거(01 §28 K12).',
  'state_code': '워치독·진단 칸의 상태 코드 — 위와 같은 축(state_label 이 짝이다).',
  'health_code':
      '🆕 v1.20 `CredentialCardVm.healthCode` — DDL `credential_registry.health` 5 ∪ `NOT_REGISTERED` · 화면 미참조 · '
      '`level` 이 색 근거(01 §29 K11).',
};

void main() {
  group('C-5 코드 사전 완결성 (01 §7 · §3)', () {
    test('C-5 labels/ 가 선언한 모든 코드 상수가 사전에 등재돼 있다', () {
      final Map<String, List<String>> byClass = _codeConstantsByClass();
      expect(byClass, isNotEmpty, reason: '코드 상수 클래스를 하나도 못 읽었다.');

      final List<String> unregistered = <String>[];
      for (final MapEntry<String, List<String>> e in byClass.entries) {
        for (final String code in e.value) {
          if (!ContractCodes.isRegistered(code)) {
            unregistered.add('${e.key}.$code');
          }
        }
      }
      expect(
        unregistered,
        isEmpty,
        reason:
            '상수는 선언했는데 ContractCodes.byDomain 에 올리지 않았다 — '
            '전역 조회가 그 코드를 «모르는 코드»로 취급한다(labels.dart).',
      );
    });

    test('C-5 values 집합을 가진 모든 코드 클래스가 byDomain 에 등재돼 있다', () {
      final String labelsBarrel = stripComments(
        File('${libDir.path}/src/labels/labels.dart').readAsStringSync(),
      );
      final List<String> missing = <String>[];
      for (final String className in _classesWithValuesSet()) {
        if (!labelsBarrel.contains('$className.values')) {
          missing.add(className);
        }
      }
      expect(
        missing,
        isEmpty,
        reason:
            'ContractCodes.byDomain 에 빠진 코드 클래스다. 사전이 «전 목록 배럴» 이라는 '
            '약속이 깨지면 미등록 코드 조기 실패(C-15 입력)가 그 축만 통째로 건너뛴다.',
      );
    });

    test('C-5 한 도메인 안에 같은 문자열을 두 번 선언하지 않는다', () {
      final List<String> duplicates = <String>[];
      for (final MapEntry<String, List<String>> e
          in _codeConstantsByClass().entries) {
        final Set<String> seen = <String>{};
        for (final String code in e.value) {
          if (!seen.add(code)) {
            duplicates.add('${e.key}: $code');
          }
        }
      }
      expect(duplicates, isEmpty, reason: '같은 코드에 상수 이름이 둘이면 인용처가 갈린다.');
    });

    test('C-5 도메인 간 중복은 문서가 밝힌 네 쌍뿐이다', () {
      final Set<String> duplicated = <String>{
        for (final String code in ContractCodes.all)
          if (ContractCodes.domainsOf(code).length > 1) code,
      };
      expect(
        duplicated,
        _documentedCrossDomainDuplicates,
        reason:
            '같은 문자열이 여러 축에 있으면 전역 조회로는 «flag_id 자리에 알림 코드»를 '
            '못 잡는다. 새 중복이 생기면 labels.dart 머리 주석과 여기를 함께 고친다.',
      );
      // 🔴 중복이 있으므로 전역 집합의 크기는 등재 건수보다 작다(labels.dart 주석).
      final int registrations = ContractCodes.byDomain.values.fold<int>(
        0,
        (int sum, Set<String> codes) => sum + codes.length,
      );
      expect(ContractCodes.all.length, lessThan(registrations));
    });

    test('C-5 미등록 코드는 조용히 통과하지 않는다', () {
      expect(
        () => ContractCodes.requireRegistered('NOT_A_REAL_CODE'),
        throwsA(isA<UnregisteredContractCodeError>()),
      );
      expect(
        () => ContractCodes.requireRegisteredIn('flag_id', 'ADVICE_ISSUED'),
        throwsA(isA<UnregisteredContractCodeError>()),
        reason: '알림 코드가 flag_id 자리에 들어오면 실패해야 한다(도메인 지정 조회의 목적).',
      );
      expect(
        () => ContractCodes.requireRegisteredIn('no_such_domain', 'X'),
        throwsA(isA<UnregisteredContractCodeError>()),
      );
      expect(
        ContractCodes.requireRegisteredIn('flag_id', FlagIds.reconMismatch),
        FlagIds.reconMismatch,
        reason: '등재된 코드는 그대로 돌려준다(파이프라인 안에서 쓸 수 있게).',
      );
      expect(ContractCodes.hasDomain('exit_kind'), isTrue);
    });

    test('C-5 픽스처가 쓰는 코드가 전부 사전에 있다', () {
      final List<String> unknown = <String>[];
      for (final String path in FixturePaths.all) {
        walkJson(jsonDecode(readFixture(path)), (
          String jsonPath,
          String key,
          Object? value,
        ) {
          final String? domain = _fixtureCodeFields[key];
          if (domain == null || value is! String) {
            return;
          }
          final bool ok = domain.isEmpty
              ? ContractCodes.isRegistered(value)
              : ContractCodes.isRegisteredIn(domain, value);
          if (!ok) {
            unknown.add('$path $jsonPath = $value');
          }
        });
      }
      expect(
        unknown,
        isEmpty,
        reason:
            '픽스처가 사전에 없는 코드를 쓴다 — 화면이 그 코드를 보고 자기 나름의 '
            '문구·아이콘·색을 고르기 시작한다(01 §3).',
      );
    });

    test('C-5 알림 픽스처의 code 는 전부 alert_code 도메인에 있다', () {
      const List<String> alertFixtures = <String>[
        FixturePaths.alerts12,
        FixturePaths.m8AlertsAdvice9codes,
        FixturePaths.m8AlertsDigest,
        FixturePaths.m8AlertsP0Ack,
        // 🆕 v1.17(01 §26 · 엔진 D11) — `STALE_ORDERS_HELD`.
        FixturePaths.m8AlertsStaleOrdersHeld,
        // 🆕 v1.18(01 §27 · K-z) — 엔진 등재형 6코드.
        FixturePaths.m8AlertsSafetyResume,
        // 🆕 v1.27(01 §36 · K191) — 엔진 등재형 5코드.
        FixturePaths.m8AlertsEngineProposalsV127,
      ];
      for (final String path in alertFixtures) {
        final FixtureEnvelope envelope = decodeEnvelope(readFixture(path));
        for (final Map<String, Object?> row in envelope.rows) {
          final Object? code = row['code'];
          expect(
            ContractCodes.isRegisteredIn('alert_code', code! as String),
            isTrue,
            reason: '$path — 미등재 알림 코드 $code (01 §3 · 인벤토리 §6-9).',
          );
        }
      }
    });

    test('C-5 정합 픽스처의 원인 코드는 전부 origin_code 도메인에 있다', () {
      final FixtureEnvelope envelope = decodeEnvelope(
        readFixture(FixturePaths.ledgerDiffs4),
      );
      for (final Map<String, Object?> row in envelope.rows) {
        for (final Object? code
            in row['candidate_origin_codes']! as List<Object?>) {
          expect(
            ContractCodes.isRegisteredIn('origin_code', code! as String),
            isTrue,
            reason: '자유 서술 거부의 근거가 이 목록이다(01 §3-4).',
          );
        }
      }
    });

    test('C-5 사전 밖 코드 축은 사유와 함께 남아 있다', () {
      for (final MapEntry<String, String> e
          in _fieldsOutsideDictionary.entries) {
        expect(e.value, isNotEmpty, reason: '${e.key} — 제외 사유가 비어 있다.');
        expect(
          _fixtureCodeFields.containsKey(e.key),
          isFalse,
          reason: '${e.key} 가 검사 대상과 제외 목록 양쪽에 있다.',
        );
      }
    });

    test('C-5 ui_* 전 파일의 한글 리터럴 0건 + TIER·SAF- 리터럴 금지 (01 §1-5)', () {
      // ✅ 2026-09-17(C4 R1) — 정본 구현. tool/check_labels.sh 는 보조다.
      //    주석은 대상이 아니다(한국어 주석은 규약상 허용) — stripComments 뒤 «따옴표 안»만 본다.
      //    ⚠️ 여러 줄 문자열(''' / """)과 보간 안의 중첩 따옴표는 첫 줄까지만 본다(알려진 한계 — 과탐 방향).
      final List<String> offenders = <String>[];
      final RegExp literalRe = RegExp(
        r'''r?'(?:[^'\\\n]|\\.)*'|r?"(?:[^"\\\n]|\\.)*"''',
      );
      final RegExp hangul = RegExp(r'[가-힣]');
      final RegExp forbiddenCodes = RegExp(r'TIER |SAF-');
      for (final String name in uiPackageNames) {
        final Directory lib = Directory('${repoRoot.path}/packages/$name/lib');
        for (final File f in dartSourcesIn(lib)) {
          final String rel = shortPath(f).replaceAll(r'\', '/');
          final bool isLabels = rel.endsWith('/lib/l10n/labels.dart');
          final String code = stripComments(f.readAsStringSync());
          for (final RegExpMatch m in literalRe.allMatches(code)) {
            final String lit = m.group(0)!;
            if (!isLabels && hangul.hasMatch(lit)) {
              offenders.add('$rel: $lit');
            }
            if (forbiddenCodes.hasMatch(lit)) {
              offenders.add('$rel: $lit (TIER/SAF literal)');
            }
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            '화면은 사유·상태 문구를 만들지 않는다 — 한국어 리터럴은 lib/l10n/labels.dart 에만'
            '(01 §1-5 · C-5). 걸린 것이 정적 라벨이면 그 파일로 옮긴다.',
      );
    });

    test('C-5 labels.dart 전수 — «램프» 단독 사용 0건(M2-3 소유)', () {
      // ✅ 2026-09-17(C4 R1) — OpsRamp(L0~L5)와 EntryRamp(초기 진입 분할)는 다른 것이다.
      //    labels.dart 는 C-5 의 예외이므로 «램프» 접두 검사를 따로 둔다(01 §7 각주).
      final List<String> offenders = <String>[];
      for (final String name in uiPackageNames) {
        final File labels = File(
          '${repoRoot.path}/packages/$name/lib/l10n/labels.dart',
        );
        if (!labels.existsSync()) {
          continue;
        }
        final List<String> lines = stripComments(labels.readAsStringSync())
            .split('\n');
        for (int i = 0; i < lines.length; i++) {
          final String l = lines[i];
          if (l.contains('램프') &&
              !l.contains('운영 램프') &&
              !l.contains('초기 진입')) {
            offenders.add('$name/lib/l10n/labels.dart:${i + 1}: $l');
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: '«램프»는 «운영 램프» 또는 «초기 진입 램프»로 갈라 쓴다(01 §2-6).',
      );
    });
  });
}

/// `lib/src/labels/` 의 `abstract final class` → 그 안의 코드 문자열 목록.
Map<String, List<String>> _codeConstantsByClass() {
  final Map<String, List<String>> out = <String, List<String>>{};
  final RegExp classRe = RegExp(
    r'abstract final class (\w+)\s*\{(.*?)\n\}',
    dotAll: true,
  );
  final RegExp constRe = RegExp(r"static const String \w+ = '([^']*)';");
  for (final File f in dartSourcesIn(Directory('${libDir.path}/src/labels'))) {
    final String source = stripComments(f.readAsStringSync());
    for (final RegExpMatch m in classRe.allMatches(source)) {
      final List<String> codes = constRe
          .allMatches(m.group(2)!)
          .map((RegExpMatch c) => c.group(1)!)
          .toList();
      if (codes.isNotEmpty) {
        out[m.group(1)!] = codes;
      }
    }
  }
  return out;
}

/// `static const Set<String> values` 를 선언한 코드 클래스 이름.
List<String> _classesWithValuesSet() {
  final List<String> out = <String>[];
  final RegExp classRe = RegExp(
    r'abstract final class (\w+)\s*\{(.*?)\n\}',
    dotAll: true,
  );
  for (final File f in dartSourcesIn(Directory('${libDir.path}/src/labels'))) {
    final String source = stripComments(f.readAsStringSync());
    for (final RegExpMatch m in classRe.allMatches(source)) {
      if (m.group(2)!.contains('static const Set<String> values')) {
        out.add(m.group(1)!);
      }
    }
  }
  return out;
}
