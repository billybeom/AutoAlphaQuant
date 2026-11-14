package com.billybeom.autoalphaquant.operator

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * operator 앱 화면 진입점(E11p1).
 *
 * 🔴 여기는 채널을 다는 일만 한다 — 판정 · 문구 · 계산은 Dart 엔진 몫이다.
 * 🔵 E11p2 에서 FGS 가 엔진을 소유하면 이 액티비티는 그 캐시 엔진에 붙는다(설계 e11p-map P9).
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        OperatorChannels.register(this, flutterEngine.dartExecutor.binaryMessenger)
    }
}
