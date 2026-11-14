// 엔진 한 벌(E11p2 · 설계 e11p-map P9).
//
// 🔴 프로세스에 FlutterEngine 은 **하나**다 — FGS(EngineService)와 화면(MainActivity)이 같은 엔진을 쓴다.
//    Dart isolate 가 하나라 원장(SQLite)의 쓰기 주체가 하나로 남는다(01 §1 «정본 원장 = 단일 쓰기 주체»).
//    화면이 닫혀도 엔진은 FGS 안에서 계속 돈다 · 알람 · 부팅으로 프로세스가 새로 뜨면 FGS 가 엔진을 만든다.
// 🔴 진입점 = Dart `main()` 그대로 — 조립(주입 · 엔진 호스트)은 Dart 가 한다. Kotlin 은 판정 0.
// 🔵 화면이 먼저 엔진을 만들면 Intent 의 실행 인자(flutter run · flutter test 의 VM 서비스 · start-paused 등)를 넘긴다.

package com.billybeom.autoalphaquant.operator.ops

import android.content.Context
import com.billybeom.autoalphaquant.operator.OperatorChannels
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

internal object EngineHost {
    /** 캐시 이름. */
    const val ENGINE_ID = "aaq_engine"

    /** 엔진 — 없으면 만들고 Dart `main()` 을 돌린다. 🔴 플랫폼(메인) 스레드에서만 부른다. */
    @Synchronized
    fun obtain(context: Context, shellArgs: Array<String>? = null): FlutterEngine {
        FlutterEngineCache.getInstance().get(ENGINE_ID)?.let { return it }
        val app = context.applicationContext
        val engine = FlutterEngine(app, shellArgs)
        OperatorChannels.register(app, engine.dartExecutor.binaryMessenger)
        OpsChannel.register(app, engine.dartExecutor.binaryMessenger)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        return engine
    }
}
