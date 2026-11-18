// 사람 값 읽기(E11p4e · 설계 13 §8 R154 · R153 발주자 결정) — data_sync 자산(`p0s_human.json`)을 앱 자산 묶음에서 읽는다.
//
// 🔴 자산 없음 · 꼴 틀림 = 던진다(포장 결함은 크게) — 실행 묶음은 그때 «정한 값 없음»으로 서고(화면은 선다),
//    실린 자산이 읽히는지는 data_sync 시험이 CI 에서 지킨다.

import 'package:data_sync/data_sync.dart'
    show P0sHumanDecision, kP0sHumanAssetKey, p0sHumanDecisionFromText;
import 'package:flutter/services.dart' show AssetBundle;

/// 🔴 발주자가 정한 사람 값을 읽는다.
Future<P0sHumanDecision> loadP0sHumanDecision(AssetBundle bundle) async =>
    p0sHumanDecisionFromText(await bundle.loadString(kP0sHumanAssetKey));
