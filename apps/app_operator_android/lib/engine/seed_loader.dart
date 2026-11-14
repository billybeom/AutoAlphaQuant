// 시드 자산 읽기(E11p3b-3 · 설계 13 §8 R93 · data_sync `assets/seed/` 자산 선언).
//
// 🔴 파일 목록 = data_sync `kSeedFiles`(sha256 대조는 적재가 한다 — 여기는 바이트만 읽는다).

import 'package:data_sync/data_sync.dart' show SeedFile, kSeedFiles;
import 'package:flutter/services.dart' show AssetBundle;

/// 자산 키(`packages/data_sync/assets/seed/<파일>`).
String seedAssetKey(SeedFile f) =>
    'packages/data_sync/assets/seed/${f.fileName}';

/// 시드 번들 전부(파일 이름 → gz 바이트).
Future<Map<String, List<int>>> loadSeedAssets(AssetBundle bundle) async =>
    <String, List<int>>{
      for (final SeedFile f in kSeedFiles)
        f.fileName: (await bundle.load(seedAssetKey(f))).buffer.asUint8List(),
    };
