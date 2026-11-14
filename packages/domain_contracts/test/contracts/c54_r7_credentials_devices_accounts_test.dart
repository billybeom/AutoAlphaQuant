// C-54 증권사 키·기기·계좌 매핑 — 01 §29(🆕 계약 v1.20 · R7 선행 + 엔진 겹침 몫 ·
// 발주자 위임 2026-11-14 — 권고대로 · K1~K39).
//
// 정의: 「M9 `S02`·`S06`·`S03` 은 엔진이 완성한 VM 으로 온다 — 버튼 = 엔진이 완성한 `SettingsActionCall`(args 화이트리스트 ·
//        시크릿 값 0) · 🔒 자리 = 슬롯 이름(kind ↔ 슬롯 짝) · 키 조각·계좌 전체번호·페이로드·카운트다운 0 · 잠김 = `lockedLabel` +
//        엔진이 화면별 «비우는 칸»만 비움(K35) · 폐기 ⇔ 펼침 확인 글자 · 발급 XOR QR · 선택지 = 미리 판정(막힘 ⇒ 호출 0 ·
//        영향 ⇔ 호출) · POT 행 0 · 결과 = `headline` + `reasonCode` 만(넘김·재시도 0) — 그리고 `CredentialKindCodes` 가
//        엔진 `KisKeySet.wire` 와 같은 글자이며 전 표본의 검증 호출이 그 사전 안에 있다」.
//   ① 허용 키 ② 동작 자리·args ③ kind 사전 ④ 슬롯 ⑤ 시크릿·번호 글자 ⑥ S02 카드 ⑦ S02 잠김 ⑧ S06 기기 행
//   ⑨ S06 리스·링크 ⑩ 페어링 ⑪ S06 잠김·오래됨 ⑫ S03 계좌 행 ⑬ S03 매핑 행 ⑭ S03 잠김·미지정 ⑮ 동작 결과
//   ⑯ 사전 ⑰ 라우트 ⑱ 글자 ⑲ 받침대.
//
// 🔴 픽스처 불변식만 본다 — `ui_settings` S02·S06·S03 화면 스캔은 R7 카드 정적 묶음 몫.
// 🔴 한국어 글자 단언 0 — 상수 리터럴 = 표본 id·키 이름·코드·라우트 상수·`FixturePaths` · 예외 = ① 금지 키 목록 ·
//    ④ kind ↔ 슬롯 짝 표(사전 상수로만) · ⑤ 꼴 정규식 · ⑱ 금지 낱말 목록.

import 'dart:convert';

import 'package:domain_contracts/domain_contracts.dart';
import 'package:domain_contracts/testing.dart';
import 'package:test/test.dart';

import 'c00_support.dart';

/// S02 `CredentialListVm` 4벌.
const List<String> _s02 = <String>[
  FixturePaths.m9Credentials,
  FixturePaths.m9CredentialsSimSealed,
  FixturePaths.m9CredentialsAdvisory,
  FixturePaths.m9CredentialsLocked,
];

/// S06 `DeviceAccessVm` 5벌.
const List<String> _s06 = <String>[
  FixturePaths.m9DeviceAccess,
  FixturePaths.m9DeviceAccessTicket,
  FixturePaths.m9DeviceAccessNoViewers,
  FixturePaths.m9DeviceAccessStale,
  FixturePaths.m9DeviceAccessLocked,
];

/// S03 `AccountMappingVm` 3벌.
const List<String> _s03 = <String>[
  FixturePaths.m9AccountMapping,
  FixturePaths.m9AccountMappingUnmapped,
  FixturePaths.m9AccountMappingLocked,
];

/// R7 VM 12벌.
const List<String> _vms = <String>[..._s02, ..._s06, ..._s03];

/// R7 결과 3벌.
const List<String> _results = <String>[
  FixturePaths.m9CredentialActionResults,
  FixturePaths.m9DeviceActionResults,
  FixturePaths.m9AccountMappingActionResults,
];

/// R7 신설 15벌.
const List<String> _all = <String>[..._vms, ..._results];

/// ① `rows[0]` 아래 어디에도 오지 않는 키(키 조각 · 저장 2단 · 앱 잠금 · 페이로드 · 계좌번호 · walker 키 · 온보딩 슬롯 키).
const List<String> _forbiddenKeys = <String>[
  'masked_value',
  'masked_text',
  'register_action',
  'app_lock',
  'payload',
  'token',
  'qr_payload',
  'account_no',
  'account_number',
  'kind_code',
  'account_kind',
  'target',
  'channel',
  'actions',
  'rows',
  'secret_slot_id',
  'countdown',
  'ttl_seconds',
];

/// ④ kind ↔ 슬롯 짝(K8 · K9 · K31 — 모의 = 온보딩 슬롯 재사용).
const Map<String, String> _slotOfKind = <String, String>{
  CredentialKindCodes.kisLive: SettingsSlotIds.secretKisLive,
  CredentialKindCodes.kisIsa: SettingsSlotIds.secretKisIsa,
  CredentialKindCodes.kisPaper: OnboardingSlotIds.secretKisMock,
  CredentialKindCodes.kisReconcile: SettingsSlotIds.secretKisReconcile,
};

/// ⑤ 키 조각 꼴 · 8자리 이상 숫자 · 엔진 마스킹 꼴.
final RegExp _keyPiece = RegExp(r'[A-Za-z0-9]{4}(…|\.\.\.)[A-Za-z0-9]{4}');
final RegExp _longDigits = RegExp(r'[0-9]{8,}');
final RegExp _masked = RegExp(r'^\*{4}[0-9]{4}$');
final RegExp _numberPiece = RegExp(r'[*0-9]{4,}');

/// ⑱ 손익 낱말 · 금지어 · 범위 밖 · 카운트다운.
const List<String> _forbiddenWords = <String>[
  'DRY_RUN',
  '수익률',
  '평가액',
  '손익',
  '추천',
  '권유',
  '자문',
  '시그널',
  '매매 중단',
  '앱 잠금',
  '카운트다운',
  '남은 시간',
];
final RegExp _money = RegExp(r'[0-9][0-9,]*원');

const Set<UiLevel> _allLevels = <UiLevel>{
  UiLevel.ok,
  UiLevel.info,
  UiLevel.watch,
  UiLevel.act,
  UiLevel.blocked,
};

Map<String, Object?> _env(String path) =>
    jsonDecode(readFixture(path)) as Map<String, Object?>;

List<Map<String, Object?>> _maps(Object? list) =>
    (list! as List<Object?>).cast<Map<String, Object?>>();

List<Map<String, Object?>> _rows(String path) => _maps(_env(path)['rows']);

/// VM 1행 봉투의 VM.
Map<String, Object?> _vm(String path) {
  final List<Map<String, Object?>> rows = _rows(path);
  expect(rows, hasLength(1), reason: '$path — VM 1행 봉투가 아니다');
  return rows.single;
}

Map<String, Object?>? _map(Object? v) => v as Map<String, Object?>?;

Set<String> _keys(Map<String, Object?> m) => m.keys.toSet();

CredentialListVm _cred(String path) => CredentialListVm.fromJson(_vm(path));

DeviceAccessVm _dev(String path) => DeviceAccessVm.fromJson(_vm(path));

AccountMappingVm _acc(String path) => AccountMappingVm.fromJson(_vm(path));

/// 문자열 값 전부.
List<String> _strings(Object? node) {
  final List<String> out = <String>[];
  void visit(Object? n) {
    if (n is String) {
      out.add(n);
    } else if (n is Map) {
      n.values.forEach(visit);
    } else if (n is List) {
      n.forEach(visit);
    }
  }

  visit(node);
  return out;
}

/// 키 전부(깊이 우선).
Set<String> _allKeys(Object? node) {
  final Set<String> out = <String>{};
  void visit(Object? n) {
    if (n is Map) {
      for (final MapEntry<Object?, Object?> e in n.entries) {
        out.add(e.key! as String);
        visit(e.value);
      }
    } else if (n is List) {
      n.forEach(visit);
    }
  }

  visit(node);
  return out;
}

/// `{id, args, label}` 꼴 객체 전부(어느 키 아래든).
List<Map<String, Object?>> _calls(Object? node) {
  final List<Map<String, Object?>> out = <Map<String, Object?>>[];
  void visit(Object? n) {
    if (n is Map<String, Object?>) {
      if (_keys(n).containsAll(<String>{'id', 'args', 'label'}) &&
          n.length == 3) {
        out.add(n);
      }
      n.values.forEach(visit);
    } else if (n is List) {
      n.forEach(visit);
    }
  }

  visit(node);
  return out;
}

/// 원시 VM 에서 이름 붙은 칸을 지운 사본(«그 밖 바이트 같음» 비교용).
String _without(Object? node, bool Function(String key) drop) {
  Object? strip(Object? n) {
    if (n is Map<String, Object?>) {
      return <String, Object?>{
        for (final MapEntry<String, Object?> e in n.entries)
          if (!drop(e.key)) e.key: strip(e.value),
      };
    }
    if (n is List) {
      return n.map(strip).toList();
    }
    return n;
  }

  return jsonEncode(strip(node));
}

void _expectSameKeys(
  Map<String, Object?> raw,
  Map<String, Object?> json,
  String where,
) {
  expect(_keys(raw), _keys(json), reason: '$where — 직속 키 ≠ toJson 키');
}

/// 동작 호출 1개 — id · args 키 · 라벨.
void _expectCall(
  SettingsActionCall a,
  SettingsActionId id,
  Set<String> argKeys,
  String where,
) {
  expect(a.id, id, reason: where);
  expect(a.args.keys.toSet(), argKeys, reason: '$where — args 화이트리스트');
  expect(a.label, isNotEmpty, reason: '$where — 버튼 글자');
}

/// VM 안 레벨 전부(행·리스·계좌·매핑).
Set<UiLevel> _levels(Object vm) {
  if (vm is CredentialListVm) {
    return <UiLevel>{for (final CredentialCardVm c in vm.cards) c.level};
  }
  if (vm is DeviceAccessVm) {
    return <UiLevel>{
      vm.leaseLevel,
      for (final DeviceRow r in vm.devices) r.level,
    };
  }
  final AccountMappingVm a = vm as AccountMappingVm;
  return <UiLevel>{
    for (final AccountRow r in a.accounts) r.level,
    for (final SleeveMappingRow m in a.mappings) m.level,
  };
}

void main() {
  group('C-54 증권사 키·기기·계좌 매핑 (01 §29 · 계약 v1.20)', () {
    test(
      'C-54 ① 허용 키 — 새·추가형 DTO 의 직속 키 = toJson · 금지 키 0 · S02·S03 빈 칸 0',
      () {
        for (final String path in _s02) {
          final Map<String, Object?> raw = _vm(path);
          final CredentialListVm vm = CredentialListVm.fromJson(raw);
          _expectSameKeys(raw, vm.toJson(), '$path CredentialListVm');
          final List<Map<String, Object?>> cards = _maps(raw['cards']);
          for (int i = 0; i < cards.length; i++) {
            _expectSameKeys(
              cards[i],
              vm.cards[i].toJson(),
              '$path CredentialCardVm[$i]',
            );
          }
          expect(raw.containsKey('empty_label'), isFalse, reason: '$path K29');
        }
        for (final String path in _s06) {
          final Map<String, Object?> raw = _vm(path);
          final DeviceAccessVm vm = DeviceAccessVm.fromJson(raw);
          _expectSameKeys(raw, vm.toJson(), '$path DeviceAccessVm');
          final List<Map<String, Object?>> rows = _maps(raw['devices']);
          for (int i = 0; i < rows.length; i++) {
            _expectSameKeys(
              rows[i],
              vm.devices[i].toJson(),
              '$path DeviceRow[$i]',
            );
          }
          _expectSameKeys(
            _map(raw['pairing'])!,
            vm.pairing!.toJson(),
            '$path PairingTicketCard',
          );
        }
        for (final String path in _s03) {
          final Map<String, Object?> raw = _vm(path);
          final AccountMappingVm vm = AccountMappingVm.fromJson(raw);
          _expectSameKeys(raw, vm.toJson(), '$path AccountMappingVm');
          expect(raw.containsKey('empty_label'), isFalse, reason: '$path K29');
          final List<Map<String, Object?>> accounts = _maps(raw['accounts']);
          for (int i = 0; i < accounts.length; i++) {
            _expectSameKeys(
              accounts[i],
              vm.accounts[i].toJson(),
              '$path AccountRow[$i]',
            );
          }
          final List<Map<String, Object?>> mappings = _maps(raw['mappings']);
          for (int i = 0; i < mappings.length; i++) {
            _expectSameKeys(
              mappings[i],
              vm.mappings[i].toJson(),
              '$path SleeveMappingRow[$i]',
            );
            final List<Map<String, Object?>> options = _maps(
              mappings[i]['options'],
            );
            for (int j = 0; j < options.length; j++) {
              _expectSameKeys(
                options[j],
                vm.mappings[i].options[j].toJson(),
                '$path AccountMappingOption[$i][$j]',
              );
            }
          }
        }
        for (final String path in _all) {
          final Set<String> keys = _allKeys(_rows(path));
          for (final String bad in _forbiddenKeys) {
            expect(keys, isNot(contains(bad)), reason: '$path — 금지 키 $bad');
          }
        }
      },
    );

    test('C-54 ② 동작 자리·args — 자리마다 id·args 키 정확히 · 값 = 그 카드·행 · 등록 호출 0', () {
      for (final String path in _s02) {
        for (final CredentialCardVm c in _cred(path).cards) {
          final SettingsActionCall? a = c.verifyAction;
          if (a == null) continue;
          _expectCall(a, SettingsActionId.credentialVerify, <String>{
            'kind',
          }, '$path ${c.alias}');
          expect(a.args['kind'], c.kind, reason: '$path ${c.alias} — 다른 세트');
        }
      }
      for (final String path in _s06) {
        final DeviceAccessVm vm = _dev(path);
        for (final DeviceRow r in vm.devices) {
          final SettingsActionCall? a = r.revokeAction;
          if (a == null) continue;
          _expectCall(a, SettingsActionId.deviceTokenRevoke, <String>{
            'device_id',
          }, '$path ${r.deviceId}');
          expect(a.args['device_id'], r.deviceId, reason: '$path — 다른 기기');
        }
        final SettingsActionCall? issue = vm.pairing?.issueAction;
        if (issue != null) {
          _expectCall(
            issue,
            SettingsActionId.devicePairingTicketCreate,
            <String>{},
            '$path pairing',
          );
        }
      }
      for (final String path in _s03) {
        final AccountMappingVm vm = _acc(path);
        if (vm.verifyAction != null) {
          _expectCall(
            vm.verifyAction!,
            SettingsActionId.accountVerifyMapping,
            <String>{},
            '$path verify',
          );
        }
        for (final SleeveMappingRow m in vm.mappings) {
          for (final AccountMappingOption o in m.options) {
            final SettingsActionCall? a = o.selectAction;
            if (a == null) continue;
            _expectCall(a, SettingsActionId.accountMapSleeve, <String>{
              'sleeve',
              'account_alias',
            }, '$path ${m.sleeveLabel}');
            expect(
              <String>{'A', 'B', 'C'},
              contains(a.args['sleeve']),
              reason: '$path — POT·CASH·SAT 칸 0',
            );
            expect(a.args['account_alias'], isNotEmpty, reason: path);
          }
        }
      }
      for (final String path in FixturePaths.all) {
        for (final Map<String, Object?> c in _calls(_env(path))) {
          expect(
            c['id'],
            isNot(SettingsActionId.credentialRegister.wire),
            reason: '$path — 화면 미호출 동작(K6)',
          );
        }
      }
    });

    test('C-54 ③ kind 사전 — 전 표본 CREDENTIAL_VERIFY kind ∈ 사전 · 카드 kind 유일 · 4벌 합집합 = 전수', () {
      int verifyCalls = 0;
      for (final String path in FixturePaths.all) {
        for (final Map<String, Object?> c in _calls(_env(path))) {
          if (c['id'] != SettingsActionId.credentialVerify.wire) continue;
          verifyCalls++;
          expect(
            CredentialKindCodes.values,
            contains(_map(c['args'])!['kind']),
            reason: '$path — 사전 밖 kind',
          );
        }
      }
      expect(verifyCalls, greaterThan(0));
      final SettingsActionCall onboarding = OnboardingStepDetailVm.fromJson(
        _vm(FixturePaths.m8OnboardingStepDetailKisMock),
      ).verify!;
      expect(onboarding.args['kind'], CredentialKindCodes.kisPaper);
      final Set<String> union = <String>{};
      for (final String path in _s02) {
        final List<String> kinds = <String>[
          for (final CredentialCardVm c in _cred(path).cards) c.kind,
        ];
        expect(
          kinds.toSet(),
          hasLength(kinds.length),
          reason: '$path — 같은 세트 둘',
        );
        for (final String k in kinds) {
          expect(CredentialKindCodes.values, contains(k), reason: path);
        }
        union.addAll(kinds);
      }
      expect(union, CredentialKindCodes.values);
    });

    test('C-54 ④ 슬롯 — kind 짝 · 자리 ⇒ 버튼 · QR 자리 · 세 슬롯 사전 겹침 0', () {
      int slots = 0;
      for (final String path in _s02) {
        for (final CredentialCardVm c in _cred(path).cards) {
          final String? slot = c.credentialSlotId;
          if (slot == null) continue;
          slots++;
          expect(slot, _slotOfKind[c.kind], reason: '$path ${c.alias}');
          expect(c.verifyAction, isNotNull, reason: '$path — 버튼 없는 입력 자리');
        }
      }
      expect(slots, greaterThan(0));
      for (final String path in _s06) {
        final String? qr = _dev(path).pairing?.qrSlotId;
        if (qr != null) {
          expect(qr, SettingsSlotIds.pairingQrDisplay, reason: path);
        }
      }
      expect(
        OnboardingSlotIds.values.intersection(SettingsSlotIds.values),
        isEmpty,
      );
      expect(OpsSlotIds.values.intersection(SettingsSlotIds.values), isEmpty);
      expect(OnboardingSlotIds.values.intersection(OpsSlotIds.values), isEmpty);
      expect(
        SettingsSlotIds.values,
        isNot(contains(OnboardingSlotIds.secretKisMock)),
      );
      expect(SettingsSlotIds.values, isNot(contains('SECRET_KIS_PAPER')));
    });

    test('C-54 ⑤ 시크릿·번호 글자 — 키 조각 · 8자리 숫자 0 · 마스킹 꼴 · 기기 id 글자 0', () {
      for (final String path in _all) {
        for (final String s in _strings(_rows(path))) {
          expect(_keyPiece.hasMatch(s), isFalse, reason: '$path — 키 조각 $s');
          expect(_longDigits.hasMatch(s), isFalse, reason: '$path — 번호 $s');
        }
      }
      for (final String path in _s03) {
        final AccountMappingVm vm = _acc(path);
        for (final AccountRow a in vm.accounts) {
          expect(
            _masked.hasMatch(a.maskedNumberText),
            isTrue,
            reason: '$path — ${a.maskedNumberText}',
          );
        }
        for (final SleeveMappingRow m in vm.mappings) {
          for (final AccountMappingOption o in m.options) {
            for (final RegExpMatch p in _numberPiece.allMatches(o.label)) {
              expect(
                _masked.hasMatch(p.group(0)!),
                isTrue,
                reason: '$path — ${o.label}',
              );
            }
          }
        }
      }
      for (final String path in _s06) {
        final Map<String, Object?> raw = _vm(path);
        final Set<String> ids = <String>{
          for (final DeviceRow r in _dev(path).devices) r.deviceId,
        };
        walkJson(raw, (String p, String key, Object? value) {
          if (value is! String || key == 'device_id') return;
          for (final String id in ids) {
            expect(value.contains(id), isFalse, reason: '$path $p — 기기 id');
          }
        });
      }
    });

    test('C-54 ⑥ S02 카드 — 레벨 5값 · 회전·런북 목적지 · 봉인 · 미등록 ≠ 경고', () {
      final Set<UiLevel> levels = <UiLevel>{};
      final Set<String> runbooks = <String>{
        for (final Map<String, Object?> r in _maps(
          _vm(FixturePaths.m8RunbookIndex)['rows'],
        ))
          r['deep_link']! as String,
      };
      for (final String path in _s02) {
        final CredentialListVm vm = _cred(path);
        expect(vm.cards, isNotEmpty, reason: path);
        levels.addAll(_levels(vm));
        expect(vm.leakRunbookLink, isNotNull, reason: path);
        expect(runbooks, contains(vm.leakRunbookLink!.deepLink), reason: path);
        for (final CredentialCardVm c in vm.cards) {
          if (c.rotateLink != null) {
            expect(
              c.rotateLink!.deepLink,
              AppRoutes.m4KeyRotation,
              reason: path,
            );
          }
        }
        if (path != FixturePaths.m9CredentialsSimSealed) {
          expect(vm.modeNotice, isNull, reason: path);
        }
      }
      expect(levels, _allLevels);
      final CredentialListVm sim = _cred(FixturePaths.m9CredentialsSimSealed);
      expect(sim.modeNotice, isNotNull);
      for (final CredentialCardVm c in sim.cards) {
        if (c.kind == CredentialKindCodes.kisLive ||
            c.kind == CredentialKindCodes.kisIsa) {
          expect(c.sealLabel, isNotNull, reason: c.alias);
          expect(c.credentialSlotId, isNull, reason: c.alias);
          expect(c.verifyAction, isNull, reason: c.alias);
          expect(c.rotateLink, isNull, reason: c.alias);
        }
      }
      final CredentialListVm adv = _cred(FixturePaths.m9CredentialsAdvisory);
      const Set<UiLevel> warn = <UiLevel>{UiLevel.act, UiLevel.blocked};
      final CredentialCardVm recon = adv.cards.singleWhere(
        (CredentialCardVm c) => c.kind == CredentialKindCodes.kisReconcile,
      );
      expect(recon.usage, CredentialUse.reconcileOnly);
      expect(recon.sealLabel, isNotNull);
      expect(recon.whyLine, isNotNull);
      expect(warn, isNot(contains(recon.level)));
      final CredentialCardVm live = adv.cards.singleWhere(
        (CredentialCardVm c) => c.kind == CredentialKindCodes.kisLive,
      );
      expect(live.whyLine, isNotNull);
      expect(warn, isNot(contains(live.level)));
    });

    test('C-54 ⑦ S02 잠김 — 슬롯·검증·회전 0 · 런북 유지 · 그 밖 = 원판', () {
      final Map<String, Object?> locked = _vm(FixturePaths.m9CredentialsLocked);
      final CredentialListVm vm = CredentialListVm.fromJson(locked);
      expect(vm.lockedLabel, isNotNull);
      expect(vm.leakRunbookLink, isNotNull);
      for (final CredentialCardVm c in vm.cards) {
        expect(c.credentialSlotId, isNull, reason: c.alias);
        expect(c.verifyAction, isNull, reason: c.alias);
        expect(c.rotateLink, isNull, reason: c.alias);
      }
      bool drop(String k) => const <String>{
        'credential_slot_id',
        'verify_action',
        'rotate_link',
        'locked_label',
      }.contains(k);
      expect(
        _without(locked, drop),
        _without(_vm(FixturePaths.m9Credentials), drop),
      );
      for (final String path in _s02) {
        if (path == FixturePaths.m9CredentialsLocked) continue;
        expect(_cred(path).lockedLabel, isNull, reason: path);
      }
    });

    test('C-54 ⑧ S06 기기 행 — 폐기 ⇔ 확인 글자 · id 유일 · 이 폰 폐기 0 · 빈 줄 · 레벨 5값', () {
      final Set<UiLevel> levels = <UiLevel>{};
      for (final String path in _s06) {
        final DeviceAccessVm vm = _dev(path);
        levels.addAll(_levels(vm));
        final List<String> ids = <String>[
          for (final DeviceRow r in vm.devices) r.deviceId,
        ];
        expect(ids.toSet(), hasLength(ids.length), reason: path);
        expect(
          vm.devices.where((DeviceRow r) => r.revokeAction == null),
          isNotEmpty,
          reason: '$path — 이 폰 행',
        );
        for (final DeviceRow r in vm.devices) {
          expect(
            r.revokeAction == null,
            r.revokeConfirmText == null,
            reason: '$path ${r.deviceId} — 확인 글자 없는 폐기',
          );
        }
        if (path == FixturePaths.m9DeviceAccessNoViewers) {
          expect(vm.devices, hasLength(1));
          expect(vm.emptyLabel, isNotNull);
        } else {
          expect(vm.emptyLabel, isNull, reason: path);
        }
      }
      expect(levels, _allLevels);
    });

    test('C-54 ⑨ S06 리스·링크 — X1 목적지 · epoch 표본 · 리스 편집 칸 0', () {
      for (final String path in _s06) {
        final DeviceAccessVm vm = _dev(path);
        if (vm.migrationLink != null) {
          expect(
            vm.migrationLink!.deepLink,
            AppRoutes.x1Migration,
            reason: path,
          );
        }
        for (final String k in _allKeys(_vm(path))) {
          expect(
            k.startsWith('lease_') && k.endsWith('_action'),
            isFalse,
            reason: '$path — 리스 편집 $k',
          );
        }
      }
      expect(_dev(FixturePaths.m9DeviceAccess).leaseEpochText, isNotNull);
      expect(_dev(FixturePaths.m9DeviceAccessNoViewers).leaseEpochText, isNull);
    });

    test('C-54 ⑩ 페어링 — 잠김 밖 발급 XOR QR · QR ⇔ 유효 시각 · 티켓 = 원판에서 pairing 만', () {
      for (final String path in _s06) {
        final DeviceAccessVm vm = _dev(path);
        final PairingTicketCard? p = vm.pairing;
        if (vm.lockedLabel == null) {
          expect(p, isNotNull, reason: path);
          expect(
            (p!.issueAction != null) != (p.qrSlotId != null),
            isTrue,
            reason: '$path — 발급·QR 동시/둘 다 없음',
          );
        }
        if (p != null) {
          expect(p.qrSlotId == null, p.expiresText == null, reason: path);
        }
      }
      final PairingTicketCard ticket = _dev(FixturePaths.m9DeviceAccessTicket)
          .pairing!;
      expect(ticket.qrSlotId, SettingsSlotIds.pairingQrDisplay);
      expect(ticket.issueAction, isNull);
      expect(_dev(FixturePaths.m9DeviceAccess).pairing!.issueAction, isNotNull);
      bool drop(String k) => k == 'pairing';
      expect(
        _without(_vm(FixturePaths.m9DeviceAccessTicket), drop),
        _without(_vm(FixturePaths.m9DeviceAccess), drop),
      );
    });

    test('C-54 ⑪ S06 잠김·오래됨 — 폐기·발급·QR·X1 0 · 오래됨 = VM as_of 만', () {
      final Map<String, Object?> locked = _vm(
        FixturePaths.m9DeviceAccessLocked,
      );
      final DeviceAccessVm vm = DeviceAccessVm.fromJson(locked);
      expect(vm.lockedLabel, isNotNull);
      for (final DeviceRow r in vm.devices) {
        expect(r.revokeAction, isNull, reason: r.deviceId);
        expect(r.revokeConfirmText, isNull, reason: r.deviceId);
      }
      expect(vm.pairing!.issueAction, isNull);
      expect(vm.pairing!.qrSlotId, isNull);
      expect(vm.pairing!.expiresText, isNull);
      expect(vm.migrationLink, isNull);
      bool dropLocked(String k) => const <String>{
        'revoke_action',
        'revoke_confirm_text',
        'issue_action',
        'qr_slot_id',
        'expires_text',
        'migration_link',
        'locked_label',
      }.contains(k);
      expect(
        _without(locked, dropLocked),
        _without(_vm(FixturePaths.m9DeviceAccess), dropLocked),
      );
      for (final String path in _s06) {
        if (path == FixturePaths.m9DeviceAccessLocked) continue;
        expect(_dev(path).lockedLabel, isNull, reason: path);
      }
      final DeviceAccessVm stale = _dev(FixturePaths.m9DeviceAccessStale);
      expect(stale.asOf.staleLabel, isNotNull);
      bool dropAsOf(String k) => k == 'as_of';
      expect(
        _without(_vm(FixturePaths.m9DeviceAccessStale), dropAsOf),
        _without(_vm(FixturePaths.m9DeviceAccess), dropAsOf),
      );
      for (final String path in _s06) {
        if (path == FixturePaths.m9DeviceAccessStale) continue;
        expect(_dev(path).asOf.staleLabel, isNull, reason: path);
      }
      for (final String path in _all) {
        final Map<String, Object?> asOf = _map(_env(path)['as_of'])!;
        expect(asOf['stale_label'], isNull, reason: '$path — 봉투 as_of');
      }
    });

    test('C-54 ⑫ S03 계좌 행 — 1행 이상 · 배지 행은 선택지 밖', () {
      for (final String path in _s03) {
        final AccountMappingVm vm = _acc(path);
        expect(vm.accounts, isNotEmpty, reason: path);
        final List<AccountRow> badged = <AccountRow>[
          for (final AccountRow a in vm.accounts)
            if (a.badgeText != null) a,
        ];
        expect(badged, isNotEmpty, reason: path);
        for (final AccountRow a in badged) {
          for (final SleeveMappingRow m in vm.mappings) {
            for (final AccountMappingOption o in m.options) {
              expect(
                o.label.startsWith(a.label),
                isFalse,
                reason: '$path — 배지 계좌가 선택지로',
              );
            }
          }
        }
        for (final AccountRow a in vm.accounts) {
          expect(_allLevels, contains(a.level), reason: path);
        }
      }
    });

    test('C-54 ⑬ S03 매핑 행 — 선택 ≤ 1 · 미지정 ⇔ 선택 0 · 막힘 ⇒ 호출 0 · 영향 ⇔ 호출 · 칸 섞기 0 · POT 0 · 레벨 5값', () {
      final Set<UiLevel> levels = <UiLevel>{};
      for (final String path in _s03) {
        final AccountMappingVm vm = _acc(path);
        expect(vm.mappings, isNotEmpty, reason: path);
        levels.addAll(_levels(vm));
        final List<String> rowSleeves = <String>[];
        int subbook = 0;
        for (final SleeveMappingRow m in vm.mappings) {
          final String where = '$path ${m.sleeveLabel}';
          expect(m.sleeveLabel.contains('POT'), isFalse, reason: where);
          final int selected = m.options
              .where((AccountMappingOption o) => o.selected)
              .length;
          expect(selected, lessThanOrEqualTo(1), reason: where);
          expect(m.accountLabel == null, selected == 0, reason: where);
          if (m.accountLabel == null) {
            expect(m.statusLine, isNotNull, reason: where);
          }
          final Set<String> sleeves = <String>{};
          for (final AccountMappingOption o in m.options) {
            if (o.selected || o.blockedText != null) {
              expect(o.selectAction, isNull, reason: '$where ${o.label}');
            }
            expect(
              o.impacts.isNotEmpty,
              o.selectAction != null,
              reason: '$where ${o.label} — 영향 ⇔ 호출',
            );
            if (o.selectAction != null) {
              sleeves.add(o.selectAction!.args['sleeve']!);
            }
          }
          expect(sleeves.length, lessThanOrEqualTo(1), reason: where);
          if (sleeves.isNotEmpty) {
            rowSleeves.add(sleeves.single);
          }
          if (m.subbookLine != null) {
            subbook++;
            if (sleeves.isNotEmpty) {
              expect(sleeves.single, 'A', reason: where);
            }
          }
        }
        expect(rowSleeves.toSet(), hasLength(rowSleeves.length), reason: path);
        expect(subbook, lessThanOrEqualTo(1), reason: path);
      }
      expect(levels, _allLevels);
      final AccountMappingVm mapped = _acc(FixturePaths.m9AccountMapping);
      expect(
        mapped.mappings.expand(
          (SleeveMappingRow m) => m.options.where(
            (AccountMappingOption o) =>
                o.blockedText != null && o.blockedText!.contains('SAF-309'),
          ),
        ),
        isNotEmpty,
      );
    });

    test('C-54 ⑭ S03 잠김·미지정 — 검증·선택·영향 0 · 그 밖 = 원판 · 미지정 표본', () {
      final Map<String, Object?> locked = _vm(
        FixturePaths.m9AccountMappingLocked,
      );
      final AccountMappingVm vm = AccountMappingVm.fromJson(locked);
      expect(vm.lockedLabel, isNotNull);
      expect(vm.verifyAction, isNull);
      for (final SleeveMappingRow m in vm.mappings) {
        for (final AccountMappingOption o in m.options) {
          expect(o.selectAction, isNull, reason: m.sleeveLabel);
          expect(o.impacts, isEmpty, reason: m.sleeveLabel);
        }
      }
      bool drop(String k) => const <String>{
        'verify_action',
        'select_action',
        'impacts',
        'locked_label',
      }.contains(k);
      expect(
        _without(locked, drop),
        _without(_vm(FixturePaths.m9AccountMapping), drop),
      );
      bool unmapped(AccountMappingVm v) =>
          v.mappings.any((SleeveMappingRow m) => m.accountLabel == null);
      expect(unmapped(_acc(FixturePaths.m9AccountMappingUnmapped)), isTrue);
      expect(unmapped(_acc(FixturePaths.m9AccountMapping)), isFalse);
      for (final String path in _s03) {
        if (path == FixturePaths.m9AccountMappingLocked) continue;
        expect(_acc(path).lockedLabel, isNull, reason: path);
      }
    });

    test('C-54 ⑮ 동작 결과 — 행 수 · 레벨 5값 · id 전수 · 사전 · 넘김·재시도 0', () {
      const Map<String, int> counts = <String, int>{
        FixturePaths.m9CredentialActionResults: 6,
        FixturePaths.m9DeviceActionResults: 6,
        FixturePaths.m9AccountMappingActionResults: 8,
      };
      const Map<String, Set<SettingsActionId>> ids =
          <String, Set<SettingsActionId>>{
            FixturePaths.m9CredentialActionResults: <SettingsActionId>{
              SettingsActionId.credentialVerify,
            },
            FixturePaths.m9DeviceActionResults: <SettingsActionId>{
              SettingsActionId.devicePairingTicketCreate,
              SettingsActionId.deviceTokenRevoke,
            },
            FixturePaths.m9AccountMappingActionResults: <SettingsActionId>{
              SettingsActionId.accountMapSleeve,
              SettingsActionId.accountVerifyMapping,
            },
          };
      final Set<String> allowed = <String>{
        ...SettingsResultCodes.values,
        OnboardingResultCodes.credentialRejected,
        ...Saf309Codes.values,
      };
      final Set<String> seen = <String>{};
      for (final String path in _results) {
        final List<ActionResult> rs = <ActionResult>[
          for (final Map<String, Object?> r in _rows(path))
            ActionResult.fromJson(r),
        ];
        expect(rs, hasLength(counts[path]), reason: path);
        expect(<UiLevel>{for (final ActionResult r in rs) r.level}, _allLevels);
        expect(<SettingsActionId>{
          for (final ActionResult r in rs) r.id,
        }, ids[path]);
        for (final ActionResult r in rs) {
          expect(r.handoffRoute, isNull, reason: '$path ${r.actionRunId}');
          expect(r.retryable, isFalse, reason: '$path ${r.actionRunId}');
          if (r.reasonCode != null) {
            expect(allowed, contains(r.reasonCode), reason: path);
            seen.add(r.reasonCode!);
          }
        }
      }
      expect(seen, <String>{
        SettingsResultCodes.wrongKeySet,
        SettingsResultCodes.mappingVerifyFailed,
        SettingsResultCodes.deviceAlreadyRevoked,
        SettingsResultCodes.biometricUnavailable,
        OnboardingResultCodes.credentialRejected,
        Saf309Codes.denyTaxableAccount,
      });
    });

    test('C-54 ⑯ 사전 — 엔진 KisKeySet.wire 글자 · 등재 · 두 벌 0 · 범위 밖 id 0', () {
      expect(CredentialKindCodes.values, <String>{
        'KIS_LIVE',
        'KIS_ISA',
        'KIS_PAPER',
        'KIS_RECONCILE',
      });
      expect(SettingsSlotIds.values, hasLength(4));
      expect(
        ContractCodes.byDomain.keys,
        containsAll(<String>['credential_kind', 'settings_slot']),
      );
      expect(
        SettingsResultCodes.values,
        containsAll(<String>[
          'WRONG_KEY_SET',
          'MAPPING_VERIFY_FAILED',
          'DEVICE_ALREADY_REVOKED',
        ]),
      );
      expect(
        SettingsResultCodes.values,
        isNot(contains('CREDENTIAL_VERIFY_FAILED')),
      );
      expect(
        SettingsResultCodes.values,
        isNot(contains('CREDENTIAL_NOT_VERIFIED')),
      );
      expect(<String>[
        for (final SettingsActionId id in SettingsActionId.values) id.wire,
      ], isNot(contains('DEVICE_APP_LOCK_SET')));
    });

    test('C-54 ⑰ 라우트 — m4KeyRotation 등록 · R7 VM 링크 전부 등록', () {
      expect(AppRoutes.m4KeyRotation, 'aaq://m4/key-rotation');
      expect(AppRoutes.all, contains(AppRoutes.m4KeyRotation));
      for (final String path in _vms) {
        walkJson(_vm(path), (String p, String key, Object? value) {
          if (key != 'deep_link') return;
          expect(
            AppRoutes.isRegistered(value! as String),
            isTrue,
            reason: '$path $p',
          );
        });
      }
    });

    test('C-54 ⑱ 글자 — DRY_RUN·손익 낱말·금액·금지어·«앱 잠금»·카운트다운 0', () {
      for (final String path in _all) {
        for (final String s in _strings(_rows(path))) {
          for (final String w in _forbiddenWords) {
            expect(s.contains(w), isFalse, reason: '$path — «$w»: $s');
          }
          expect(_money.hasMatch(s), isFalse, reason: '$path — 금액: $s');
        }
      }
    });

    test('C-54 ⑲ 받침대 — watchCredentials · watchAccountMapping 은 동기로 던진다', () {
      expect(
        () => UnimplementedSettingsRepository().watchCredentials(),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => UnimplementedSettingsRepository().watchAccountMapping(),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
