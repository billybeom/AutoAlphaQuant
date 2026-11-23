// 🆕 E11-viewer-223(설계 13 §8 R250 · 01 §8 미결 223) — 뷰어 읽기 창구 주입: 화면 패키지의 저장소 칸 ← `ViewerReadModels`.
//
// 🔴 이 앱은 `read_model_client` 로만 읽기 모델에 닿는다(01 §1-1 · tool/check_boundaries.sh [8]) — 엔진 · 원장 · 주문 0.
// 🔴 칸 = 운영 앱 `operatorShellOverrides` 의 저장소 칸과 같은 이름(같은 화면이 같은 창구를 본다 — 계약 3조 ①) ·
//    서지 않는 창구는 `ViewerReadModels` 가 UnsupportedError 로 낸다(빈 값 0 · 화면 = 공용 오류).
// 🔵 아직 `main.dart` 에 붙이지 않는다 — 읽기 모델 원천(Supabase 순수 Dart · RLS select · Realtime)이 E11l2 뒤
//    뷰어 앱 착수 카드 몫이라 넘길 원천이 없다(미결 223 꼬리). 시계 · 링크 열기 · 명령 칸 · 셸 라우트 = 그 카드.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:read_model_client/read_model_client.dart' show ViewerReadModels;
import 'package:ui_analytics/ui_analytics.dart'
    show
        executionGapRepositoryProvider,
        performanceRepositoryProvider,
        rebalanceRepositoryProvider,
        safetyRepositoryProvider;
import 'package:ui_journal/ui_journal.dart'
    show
        journalAdviceRepositoryProvider,
        journalConfigRepositoryProvider,
        journalHoldingsRepositoryProvider,
        journalLedgerRepositoryProvider,
        journalLedgerTrustRepositoryProvider,
        journalRebalanceRepositoryProvider,
        journalSafetyRepositoryProvider,
        journalTimelineRepositoryProvider;
import 'package:ui_settings/ui_settings.dart'
    show settingsOpsStatusRepositoryProvider, settingsRepositoryProvider;
import 'package:ui_shell/ui_shell.dart'
    show
        shellAdviceRepositoryProvider,
        shellAlertRepositoryProvider,
        shellConfigRepositoryProvider,
        shellHoldingsRepositoryProvider,
        shellLedgerTrustRepositoryProvider,
        shellOpsStatusRepositoryProvider,
        shellOpsSummaryRepositoryProvider,
        shellSafetyRepositoryProvider;

/// 화면 패키지 저장소 칸 22 ← 뷰어 읽기 창구 묶음 하나(같은 저장소 = 같은 인스턴스).
List<Override> viewerReadModelOverrides(ViewerReadModels m) => <Override>[
  // ui_shell — 홈 · 알림 · 운영 상태.
  shellConfigRepositoryProvider.overrideWithValue(m.config),
  shellAlertRepositoryProvider.overrideWithValue(m.alerts),
  shellOpsStatusRepositoryProvider.overrideWithValue(m.opsStatus),
  shellOpsSummaryRepositoryProvider.overrideWithValue(m.opsSummary),
  shellAdviceRepositoryProvider.overrideWithValue(m.advice),
  shellHoldingsRepositoryProvider.overrideWithValue(m.holdings),
  shellLedgerTrustRepositoryProvider.overrideWithValue(m.ledgerTrust),
  shellSafetyRepositoryProvider.overrideWithValue(m.safety),
  // ui_settings — 설정 보기(배분 = S04 보기 전용) · 워치독.
  settingsRepositoryProvider.overrideWithValue(m.settings),
  settingsOpsStatusRepositoryProvider.overrideWithValue(m.opsStatus),
  // ui_journal — 일지 · 안내 · 보유 · 원장 대조.
  journalTimelineRepositoryProvider.overrideWithValue(m.journal),
  journalConfigRepositoryProvider.overrideWithValue(m.config),
  journalAdviceRepositoryProvider.overrideWithValue(m.advice),
  journalHoldingsRepositoryProvider.overrideWithValue(m.holdings),
  journalRebalanceRepositoryProvider.overrideWithValue(m.rebalance),
  journalLedgerRepositoryProvider.overrideWithValue(m.ledger),
  journalLedgerTrustRepositoryProvider.overrideWithValue(m.ledgerTrust),
  journalSafetyRepositoryProvider.overrideWithValue(m.safety),
  // ui_analytics — 성과 · 리밸런싱 · 이행 갭(🔴 플래너 = operator 전용 — 01 §14-1 · TARGETS T-4 · check_boundaries [7]).
  safetyRepositoryProvider.overrideWithValue(m.safety),
  rebalanceRepositoryProvider.overrideWithValue(m.rebalance),
  performanceRepositoryProvider.overrideWithValue(m.performance),
  executionGapRepositoryProvider.overrideWithValue(m.executionGap),
];
