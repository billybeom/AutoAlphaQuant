// 운영 설정 읽기(설계 13 §8 R148 Z6) — data_sync 자산(SPEC 02 §4 `operations` 블록)을 앱 자산 묶음에서 읽는다.
//
// 🔴 자산 없음 · 꼴 틀림 = 던진다(포장 결함은 크게) · 판정 · 배선(창 깨어남 = E16t3b)은 부르는 쪽.

import 'package:core_engine/core_engine.dart' show OperationsConfig;
import 'package:data_sync/data_sync.dart'
    show kOperationsAssetKey, operationsConfigFromText;
import 'package:flutter/services.dart' show AssetBundle;

/// 🔴 운영 설정을 읽는다.
Future<OperationsConfig> loadOperationsConfig(AssetBundle bundle) async =>
    operationsConfigFromText(await bundle.loadString(kOperationsAssetKey));
