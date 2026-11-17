// 운영 설정 원천(설계 13 §8 R148 Z1~Z6 · SPEC 02 §4 `operations` 블록 · 🔴 전략 config_hash 밖).
//
// 🔴 값 = 자산 `assets/config/operations.json`(SPEC 02 §4 블록 그대로 · 잠정 · ⬜ 발주자 확정) — lib 리터럴 0 ·
//    등재 설정 판(`config_versions` = 전략 지문)과 섞지 않는다.
// 🔴 이 패키지는 순수 Dart — 자산 읽기(AssetBundle)는 조립 앱 · 여기는 글자 → 읽기 모델만.

import 'dart:convert' show jsonDecode;

import 'package:core_engine/core_engine.dart' show OperationsConfig;

/// 이 패키지 안 자산 경로(시험 · 도구가 파일로 읽는다).
const String kOperationsAssetPath = 'assets/config/operations.json';

/// 조립 앱 자산 키(Flutter 의 패키지 자산 규약).
const String kOperationsAssetKey = 'packages/data_sync/$kOperationsAssetPath';

/// 🔴 자산 글자 → 운영 설정(JSON 아님 · 객체 아님 = [FormatException]).
OperationsConfig operationsConfigFromText(String text) =>
    OperationsConfig.fromJson(jsonDecode(text));
