package com.billybeom.autoalphaquant.operator

import android.content.Context
import android.content.Intent
import android.os.Bundle
import com.billybeom.autoalphaquant.operator.ops.EngineHost
import com.billybeom.autoalphaquant.operator.ops.EngineService
import com.billybeom.autoalphaquant.operator.ops.OpsChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterShellArgs

/**
 * operator 앱 화면 진입점(E11p1 · E11p2).
 *
 * 🔴 판정 · 문구 · 계산 0 — 엔진을 빌려 붙고(EngineHost · 설계 e11p-map P9), FGS 를 띄우고, 알림 탭 링크를 넘길 뿐이다.
 * 🔴 화면을 닫아도 엔진을 부수지 않는다 — FGS 가 계속 돌린다.
 */
class MainActivity : FlutterActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine =
        EngineHost.obtain(context, FlutterShellArgs.fromIntent(intent).toArray())

    override fun shouldDestroyEngineWithHost(): Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        EngineService.startFromForeground(this)
        forwardLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        forwardLink(intent)
    }

    private fun forwardLink(i: Intent?) {
        val data = i?.data ?: return
        if (data.scheme == "aaq") OpsChannel.deliverLink(data.toString())
    }
}
