// E11q-d1 — M8 D-02 런북 · D-03 긴급 카드 · B-01·B-02 핸드북 원고 번들 VM(설계 13 §8 · 06 M4-12 · 04 §6 · §8 ·
// 표본 `m8/runbook_*` · `m8/emergency_card*` · `m8/handbook_*`).
//
// 🔴 갈래마다 표본과 DTO 째로 대조 — 목록 · 상세 · 모르는 id · 빈 목록 · 인쇄 슬롯 유무 · 목차 · 뒤처짐 · 별칭 쪽(live) · 보관 쪽 ·
//    없는 쪽. 🔴 원고가 없는 칸은 지어내지 않는다 — 런북 넷 = «준비 중» · 핸드북 일곱 장 = 목차 «준비 중» · live 값 없음 = 블록째 뺌.

import 'dart:convert';
import 'dart:io';

import 'package:core_engine/core_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:domain_contracts/domain_contracts.dart';
import 'package:test/test.dart';

const String _fx = '../domain_contracts/fixtures';

Map<String, Object?> _row(String file) =>
    ((jsonDecode(File('$_fx/$file').readAsStringSync())
                    as Map<String, Object?>)['rows']!
                as List<Object?>)
            .first!
        as Map<String, Object?>;

String _metaHash(String file) =>
    ((jsonDecode(File('$_fx/$file').readAsStringSync())
                as Map<String, Object?>)['meta']!
            as Map<String, Object?>)['config_hash']!
        as String;

const String _cfg = 'cfg_fake_0000000000000000';

/// 슬리브 B 표본 쪽 — 🆕 E11q-d1b 주의 블록 = 정정한 원고 글(표본 글자 «상한에 닿으면 신규 매수가 멈춥니다» 는 SAF-308
/// 경고만 규약과 달라 원고가 고쳤다 · 표본 정정 = 계약 창 몫). 표본이 고쳐지면 이 갈래가 먼저 깨져 알린다.
HandbookPage _sleeveBFixture() {
  final HandbookPage fx = HandbookPage.fromJson(
    _row('m8/handbook_page_sleeve_b.json'),
  );
  final HandbookManuscriptBlock fixed = kHandbookManuscript.pages
      .firstWhere((HandbookManuscriptPage p) => p.anchor == 'sleeve-b')
      .blocks
      .firstWhere(
        (HandbookManuscriptBlock b) => b.kind == HandbookBlockKinds.caution,
      );
  return fx.copyWith(
    blocks: <HandbookBlock>[
      for (final HandbookBlock b in fx.blocks)
        if (b.kind == HandbookBlockKinds.caution)
          () {
            expect(b.text, '금은 상한이 있습니다. 상한에 닿으면 신규 매수가 멈춥니다.');
            return b.copyWith(text: fixed.text, deepLink: fixed.deepLink);
          }()
        else
          b,
    ],
  );
}

final String _fp = kHandbookManuscript.ruleFingerprint;

void main() {
  group('D-02 런북', () {
    test('🔴 목록 = 표본 `runbook_index` DTO 째로(여섯 행 · 차례 · 요약 · 링크)', () {
      expect(
        runbookIndexVmOf(),
        RunbookIndexVm.fromJson(_row('m8/runbook_index.json')),
      );
    });

    test('빈 번들 = 표본 `runbook_index_empty`(빈 문장)', () {
      expect(
        runbookIndexVmOf(const <RunbookEntry>[]),
        RunbookIndexVm.fromJson(_row('m8/runbook_index_empty.json')),
      );
    });

    test(
      '🔴 상세 host-lost = 표본 `runbook_host_lost` DTO 째로(번호 글자 «2-1.» 그대로)',
      () {
        expect(
          runbookVmOf('host-lost'),
          RunbookVm.fromJson(_row('m8/runbook_host_lost.json')),
        );
      },
    );

    test(
      '🔴 모르는 id = 표본 `runbook_missing`(스트림 오류 아님) · 긴급 카드 링크 행은 런북 id 가 아니다',
      () {
        final RunbookVm want = RunbookVm.fromJson(
          _row('m8/runbook_missing.json'),
        );
        for (final String id in <String>[
          'nope',
          'emergency-card',
          '',
          'HOST-LOST',
        ]) {
          expect(runbookVmOf(id), want, reason: id);
        }
      },
    );

    test('🆕 E11q-d1b — 런북 넷 원고(머리 · 번호 단계 · «준비 중» 0) · 목록 행 제목 = 상세 제목', () {
      final Map<String, String> titles = <String, String>{
        'db-corrupt': '기록이 깨졌을 때',
        'broker-outage': '증권사 연결이 오래 끊겼을 때',
        'account-access': '계좌에 접근할 수 없을 때',
        'secret-leak': '키가 새어 나갔을 때',
      };
      for (final MapEntry<String, String> e in titles.entries) {
        final RunbookVm vm = runbookVmOf(e.key);
        expect(vm.title, e.value, reason: e.key);
        expect(vm.missingLabel, isNull, reason: e.key);
        expect(vm.introText, isNotNull, reason: e.key);
        expect(vm.steps, isNotEmpty, reason: e.key);
        expect(vm.steps.first.orderText, '1.', reason: e.key);
        // 번호 글자 = «n.» · «n-m.» 꼴 · 겹침 0.
        final List<String> orders = <String>[
          for (final RunbookStep s in vm.steps) s.orderText,
        ];
        expect(orders.toSet().length, orders.length, reason: e.key);
        for (final String o in orders) {
          expect(RegExp(r'^\d+(-\d+)?\.$').hasMatch(o), true, reason: o);
        }
      }
      // 지금 번들 = 원고 없는 런북 0(긴급 카드 행은 카드로 연다).
      for (final RunbookEntry e in kRunbookCatalog) {
        final String? id = e.runbookId;
        if (id == null) continue;
        expect(runbookVmOf(id).missingLabel, isNull, reason: e.title);
      }
    });

    test(
      '🔴 목록에 있으나 원고 없는 런북 = «준비 중»(단계 0 · 머리 0 · 지어내지 않는다 · 모르는 id 문장과 다르다)',
      () {
        final List<RunbookEntry> noBody = <RunbookEntry>[
          for (final RunbookEntry e in kRunbookCatalog)
            RunbookEntry(
              title: e.title,
              summaryText: e.summaryText,
              deepLink: e.deepLink,
              runbookId: e.runbookId,
            ),
        ];
        expect(
          runbookVmOf('db-corrupt', noBody),
          const RunbookVm(
            title: '기록이 깨졌을 때',
            steps: <RunbookStep>[],
            localCheckNotice: RunbookTexts.localCheckNotice,
            missingLabel: RunbookTexts.preparingLabel,
          ),
        );
        expect(RunbookTexts.preparingLabel, isNot(RunbookTexts.missingLabel));
      },
    );

    test('🔴 런북 원고 글자에 숫자 0(번호 글자 빼고 — 계좌번호 · 앱키 · 문턱 수치를 적지 않는다)', () {
      for (final RunbookEntry e in kRunbookCatalog) {
        final RunbookBody? b = e.body;
        if (b == null) continue;
        for (final String t in <String>[
          ?b.introText,
          for (final RunbookStep s in b.steps) s.text,
        ]) {
          expect(RegExp(r'\d').hasMatch(t), false, reason: t);
        }
      }
    });

    test('🔴 계약 불변식 — missingLabel non-null ⇔ 단계 0 ∧ 머리 null · 고지 = 늘', () {
      for (final RunbookEntry e in kRunbookCatalog) {
        final RunbookVm vm = runbookVmOf(e.runbookId ?? 'x');
        expect(
          vm.missingLabel != null,
          vm.steps.isEmpty && vm.introText == null,
          reason: e.title,
        );
        expect(vm.localCheckNotice, RunbookTexts.localCheckNotice);
      }
    });

    test('🔴 행 링크 = 상세 라우트(id 한 마디) · ⑥ = 긴급 카드 라우트 · 등록된 라우트만', () {
      for (final RunbookEntry e in kRunbookCatalog) {
        final String? id = e.runbookId;
        expect(
          e.deepLink,
          id == null
              ? AppRoutes.opsEmergencyCard
              : AppRoutes.opsRunbook.replaceFirst(':runbookId', id),
        );
        expect(routePatternOf(e.deepLink), isNotNull, reason: e.deepLink);
      }
    });

    test('🔴 런북 링크(S02 유출 런북) = 원고 있음 ∧ 상세 본문 있음일 때만 · 🆕 E11q-d1b secret-leak 원고 → 표본 링크가 선다', () {
      expect(
        runbookLinkOf(
          'secret-leak',
          hasBody: (String r) => r == AppRoutes.opsRunbook,
        ),
        CredentialListVm.fromJson(_row('m9/credentials.json')).leakRunbookLink,
      );
      expect(runbookLinkOf('secret-leak', hasBody: (_) => false), isNull);
      expect(
        runbookLinkOf('host-lost', hasBody: (_) => true),
        const LinkAction(
          label: '운영 폰을 잃어버렸거나 고장 났을 때',
          deepLink: 'aaq://ops/runbooks/host-lost',
        ),
      );
      expect(runbookLinkOf('host-lost', hasBody: (_) => false), isNull);
      expect(runbookLinkOf('nope', hasBody: (_) => true), isNull);
      // 원고가 생기면 S02 표본의 링크와 같은 것이 선다.
      final List<RunbookEntry> withLeak = <RunbookEntry>[
        for (final RunbookEntry e in kRunbookCatalog)
          e.runbookId == 'secret-leak'
              ? RunbookEntry(
                  title: e.title,
                  summaryText: e.summaryText,
                  deepLink: e.deepLink,
                  runbookId: e.runbookId,
                  body: const RunbookBody(
                    steps: <RunbookStep>[
                      RunbookStep(orderText: '1.', text: '시험'),
                    ],
                  ),
                )
              : e,
      ];
      expect(
        runbookLinkOf(
          'secret-leak',
          hasBody: (String r) => r == AppRoutes.opsRunbook,
          catalog: withLeak,
        ),
        CredentialListVm.fromJson(_row('m9/credentials.json')).leakRunbookLink,
      );
    });
  });

  group('D-03 긴급 카드', () {
    test('🔴 인쇄할 수 있는 빌드 = 표본 `emergency_card`(슬롯 EMERGENCY_CARD_PRINT)', () {
      expect(
        emergencyCardVmOf(printable: true),
        EmergencyCardVm.fromJson(_row('m8/emergency_card.json')),
      );
    });

    test('🔴 인쇄할 수 없는 빌드 = 표본 `emergency_card_no_print`(슬롯 null = 버튼 부재)', () {
      expect(
        emergencyCardVmOf(printable: false),
        EmergencyCardVm.fromJson(_row('m8/emergency_card_no_print.json')),
      );
    });

    test('🔴 계좌번호 · 앱키 0 — 숫자 = 공개 대표번호와 단계 번호뿐', () {
      final EmergencyCardVm vm = emergencyCardVmOf(printable: true);
      final String all = <String>[
        vm.title,
        for (final RunbookStep s in vm.steps) s.text,
        vm.contactLine.replaceAll('1544-5000', ''),
        vm.keepOnPaperNotice,
      ].join(' ');
      expect(RegExp(r'\d').hasMatch(all), false, reason: all);
    });
  });

  group('B-01 목차', () {
    test('🔴 🆕 E11q-d1b 지금 번들 = 표본 `handbook_index` DTO 째로(⑥⑦⑧ 만 준비 중 · 설정 지문 = 봉투 meta)', () {
      expect(
        handbookIndexOf(
          configHash: _metaHash('m8/handbook_index.json'),
          ruleFingerprint: _fp,
        ),
        HandbookIndex.fromJson(_row('m8/handbook_index.json')),
      );
    });

    test('🔴 규칙 지문이 다르면 = 표본 `handbook_index_outdated`(엔진 판정 · 글자 그대로)', () {
      expect(
        handbookIndexOf(configHash: _cfg, ruleFingerprint: 'ffffffffffffffff'),
        HandbookIndex.fromJson(_row('m8/handbook_index_outdated.json')),
      );
    });

    test(
      '🔴 준비 중 = HB-1~HB-3 원고 전 세 장뿐(링크 0) — 슬리브 B 묶음 READY · 새틀라이트 ARCHIVED',
      () {
        final HandbookIndex got = handbookIndexOf(
          configHash: _cfg,
          ruleFingerprint: _fp,
        );
        final List<String> preparing = <String>[
          for (final HandbookEntry e in got.entries)
            ...<HandbookEntry>[e, ...e.children]
                .where(
                  (HandbookEntry x) => x.state == HandbookEntryState.preparing,
                )
                .map((HandbookEntry x) => x.anchor),
        ];
        expect(preparing, <String>[
          'after-tax',
          'rejected-ideas',
          'rule-value',
        ]);
      },
    );

    test('🔴 탭 가능한 항목은 전부 원고 쪽이 선다(없는 쪽 · 준비 중 쪽 0)', () {
      final HandbookIndex idx = handbookIndexOf(
        configHash: _cfg,
        ruleFingerprint: _fp,
      );
      for (final HandbookEntry e in <HandbookEntry>[
        for (final HandbookEntry x in idx.entries) ...<HandbookEntry>[
          x,
          ...x.children,
        ],
      ]) {
        final String? link = e.deepLink;
        if (link == null) continue;
        expect(link, startsWith('handbook://'));
        final HandbookPage p = handbookPageOf(
          link.substring('handbook://'.length),
          configHash: _cfg,
          ruleFingerprint: _fp,
        );
        expect(p.missingLabel, isNull, reason: link);
        expect(p.blocks, isNotEmpty, reason: link);
      }
    });
  });

  group('B-02 쪽', () {
    HandbookPage pageOf(
      String anchor, {
      String? fp,
      Map<String, HandbookLiveReading> live =
          const <String, HandbookLiveReading>{},
    }) => handbookPageOf(
      anchor,
      configHash: _cfg,
      ruleFingerprint: fp ?? _fp,
      live: live,
    );

    test('🔴 별칭 `sleeves/sleeve-b` + live 값 = 표본 `handbook_page_sleeve_b` DTO 째로(asOf = 그 값의 기준 · 주의 블록 = 정정 원고)', () {
      final HandbookPage want = _sleeveBFixture();
      final HandbookBlock liveBlock = want.blocks.firstWhere(
        (HandbookBlock b) => b.live != null,
      );
      final Map<String, HandbookLiveReading> live =
          <String, HandbookLiveReading>{
            HandbookLiveKeys.goldCap: HandbookLiveReading(
              value: liveBlock.live!,
              asOf: want.asOf!,
            ),
          };
      expect(pageOf('sleeves/sleeve-b', live: live), want);
      expect(pageOf('sleeve-b', live: live), want);
    });

    test(
      '🔴 live 값이 없으면 그 블록째 뺀다 · asOf null(지어내지 않는다 — 지금 operator = 원천 0)',
      () {
        final HandbookPage fx = _sleeveBFixture();
        expect(
          pageOf('sleeves/sleeve-b'),
          fx.copyWith(
            blocks: <HandbookBlock>[
              for (final HandbookBlock b in fx.blocks)
                if (b.live == null) b,
            ],
            asOf: null,
          ),
        );
        expect(
          pageOf('sleeve-b').blocks.where((HandbookBlock b) => b.live != null),
          isEmpty,
        );
      },
    );

    test('🔴 보관 장 = 표본 `handbook_page_archived`(뒤처짐이어도 고지 0 — 기록이다)', () {
      final HandbookPage want = HandbookPage.fromJson(
        _row('m8/handbook_page_archived.json'),
      );
      expect(pageOf('satellite'), want);
      expect(pageOf('satellite', fp: 'ffffffffffffffff'), want);
    });

    test('🔴 규칙 지문이 다르면 = 표본 `handbook_page_outdated` · 같으면 고지 null', () {
      final HandbookPage want = HandbookPage.fromJson(
        _row('m8/handbook_page_outdated.json'),
      );
      expect(pageOf('rebalance/band', fp: 'ffffffffffffffff'), want);
      expect(pageOf('rebalance/band'), want.copyWith(outdatedNotice: null));
    });

    test('🔴 모르는 앵커 = 표본 `handbook_page_missing`(받은 앵커 그대로 · 스트림 오류 아님 · 뒤처짐 고지 0)', () {
      final HandbookPage want = HandbookPage.fromJson(
        _row('m8/handbook_page_missing.json'),
      );
      expect(pageOf('rebalance/monthly'), want);
      expect(pageOf('rebalance/monthly', fp: 'ffffffffffffffff'), want);
    });

    test(
      '🔴 목차에 있으나 원고 없는 장 = «준비 중» 쪽(장 이름 · 블록 0 · 고지 0 · 없는 쪽 문장과 다르다)',
      () {
        expect(
          pageOf('after-tax', fp: 'ffffffffffffffff'),
          const HandbookPage(
            anchor: 'after-tax',
            title: '⑥ 세후 표기 규약',
            blocks: <HandbookBlock>[],
            configHash: _cfg,
            missingLabel: HandbookTexts.preparingLabel,
          ),
        );
        expect(HandbookTexts.preparingLabel, isNot(HandbookTexts.missingLabel));
      },
    );

    test('🔴 엔진이 짓는 handbook 링크 = 쪽 · 준비 중 · 없는 쪽 중 하나(던지지 않는다 · 계약 불변식)', () {
      for (final String a in <String>[
        'rebalance/monthly',
        'rebalance/band',
        'unknown/resolve',
        'plan/deposit',
        'exit/tier1b',
        'safety',
        'sleeves',
        '',
      ]) {
        final HandbookPage p = pageOf(a);
        expect(p.missingLabel != null, p.blocks.isEmpty, reason: a);
        expect(p.configHash, _cfg);
      }
    });

    test('🔴 원고 지문 = 이 판 규칙 지문 — 규칙이 코드에서 바뀌면 원고를 다시 읽고 이 값을 고친다(그 전엔 앱이 «뒤처짐»을 말한다)', () {
      expect(kHandbookManuscript.ruleFingerprint, p0sRuleFingerprint());
      expect(
        handbookIndexOf(
          configHash: _cfg,
          ruleFingerprint: p0sRuleFingerprint(),
        ).outdatedNotice,
        isNull,
      );
    });

    test('🔴 원고 글자에 숫자 리터럴 0(04 §8 — 수치는 엔진 값 · 장 번호 기호 제외)', () {
      for (final HandbookManuscriptPage p in kHandbookManuscript.pages) {
        for (final HandbookManuscriptBlock b in p.blocks) {
          expect(RegExp(r'\d').hasMatch(b.text), false, reason: b.text);
        }
      }
    });

    test(
      '🆕 E11q-d1b — 쪽 제목 = 목차 장 이름 · 블록 링크는 전부 원고 쪽으로 열린다(준비 중 · 없는 쪽 0)',
      () {
        for (final HandbookManuscriptPage p in kHandbookManuscript.pages) {
          final HandbookPage got = pageOf(p.anchor);
          expect(got.missingLabel, isNull, reason: p.anchor);
          expect(got.title, p.title, reason: p.anchor);
          for (final HandbookManuscriptBlock b in p.blocks) {
            final String? link = b.deepLink;
            if (link == null) continue;
            expect(link, startsWith('handbook://'), reason: link);
            final HandbookPage to = pageOf(
              link.substring('handbook://'.length),
            );
            expect(to.missingLabel, isNull, reason: '${p.anchor} → $link');
            expect(to.blocks, isNotEmpty, reason: '${p.anchor} → $link');
          }
        }
        // 목차의 장(보관 제외)마다 같은 이름의 쪽.
        final HandbookIndex idx = handbookIndexOf(
          configHash: _cfg,
          ruleFingerprint: _fp,
        );
        for (final HandbookEntry e in <HandbookEntry>[
          for (final HandbookEntry x in idx.entries) ...<HandbookEntry>[
            x,
            ...x.children,
          ],
        ]) {
          if (e.state != HandbookEntryState.ready) continue;
          expect(pageOf(e.anchor).title, e.title, reason: e.anchor);
        }
      },
    );
  });

  group('🆕 E11q-d1b 금 상한 «현재 상태»(SAF-308 — 경고만)', () {
    P0sExposure exposure(double gold) => P0sExposure(
      totalKrw: Decimal.fromInt(100000000),
      defensivePct: 0.4,
      goldSharePct: gold,
      usdExposurePct: 0.5,
      krwLiquidityPct: 0.05,
    );
    final DateTime now = DateTime.utc(2026, 11, 23, 3);
    const TradeDate day = TradeDate('2026-11-20');
    HandbookLiveReading readingOf(double gold) => goldCapLiveReadingOf(
      exposure: exposure(gold),
      config: p0sWarnConfig(),
      closeDate: day,
      nowUtc: now,
    );

    test('🔴 감시선 안쪽 = OK · 넘음(엄격) = WATCH · 감시선과 같으면 안쪽(일간 판정과 같은 경계)', () {
      expect(
        readingOf(0.141).value,
        const HandbookLiveValue(
          label: '금 비중 14.1% — 감시선 20% 안쪽입니다.',
          level: UiLevel.ok,
        ),
      );
      expect(
        readingOf(0.2477).value,
        const HandbookLiveValue(
          label: '금 비중 24.8% — 감시선 20%를 넘었습니다. 알림만 하고 주문은 막지 않습니다.',
          level: UiLevel.watch,
        ),
      );
      expect(readingOf(0.20).value.level, UiLevel.ok);
      for (final double g in <double>[0.0, 0.199, 0.20, 0.2001, 0.5]) {
        expect(
          readingOf(g).value.level == UiLevel.watch,
          judgeP0sDailyWarnings(exposure(g), p0sWarnConfig()).goldHigh,
          reason: '$g',
        );
      }
    });

    test('🔴 기준 = 그 종가 날 · 표본 신선도 문장 · 쪽 asOf = 그 값의 기준', () {
      final HandbookLiveReading r = readingOf(0.141);
      expect(
        r.asOf,
        AsOf(
          observedAt: now,
          tradeDate: day,
          source: AsOfSource.localSqlite,
          staleAfter: kHandbookLiveStaleAfter,
          label: '현재 상태 기준 2026-11-20 종가',
          staleLabel: kHandbookLiveStaleLabel,
        ),
      );
      expect(kHandbookLiveStaleLabel, _sleeveBFixture().asOf!.staleLabel);
      final HandbookPage p = handbookPageOf(
        'sleeves/sleeve-b',
        configHash: _cfg,
        ruleFingerprint: _fp,
        live: <String, HandbookLiveReading>{HandbookLiveKeys.goldCap: r},
      );
      expect(p.asOf, r.asOf);
      expect(
        p.blocks.where((HandbookBlock b) => b.live != null).single.live,
        r.value,
      );
    });
  });
}
