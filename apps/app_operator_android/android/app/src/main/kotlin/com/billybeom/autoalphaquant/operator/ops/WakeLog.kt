// 깨어남 실측 기록(E11p2 · 설계 e11p-map P13 ③ · 13 D11 · D22).
//
// 수신기가 받는 순간 Kotlin 이 바로 적는다 — Dart 엔진이 늦게 뜨거나 죽어도 «OS 가 언제 깨웠나»는 남는다.
// 실측 스크립트(`tool/measure_survival.sh`)가 `adb shell run-as … cat files/aaq_wake_log.jsonl` 로 읽는다.
// 🔴 값 · 키 · 금액 0(까닭 · 꼬리표 · 시각 · Doze 여부뿐) · 256KB 넘으면 뒤 절반만 남긴다.

package com.billybeom.autoalphaquant.operator.ops

import android.content.Context
import android.os.PowerManager
import org.json.JSONObject
import java.io.File

internal object WakeLog {
    /** 파일 이름(filesDir 안). */
    const val FILE = "aaq_wake_log.jsonl"

    private const val MAX_BYTES = 256 * 1024

    /** 한 줄 적는다 — 🔴 실패해도 던지지 않는다(실측이 잡을 막지 않게). */
    @Synchronized
    fun append(ctx: Context, w: Wake) {
        try {
            val pm = ctx.getSystemService(PowerManager::class.java)
            val line = JSONObject()
                .put("reason", w.reason)
                .put("tag", w.tag ?: JSONObject.NULL)
                .put("scheduledAtMs", w.scheduledAtMs ?: JSONObject.NULL)
                .put("firedAtMs", w.firedAtMs)
                .put("deviceIdle", pm.isDeviceIdleMode)
                .put("interactive", pm.isInteractive)
                .toString()
            val f = File(ctx.filesDir, FILE)
            if (f.length() > MAX_BYTES) {
                val keep = f.readLines().let { it.drop(it.size / 2) }
                f.writeText(keep.joinToString("\n", postfix = "\n"))
            }
            f.appendText(line + "\n")
        } catch (e: Exception) {
            // 무시 — 실측 기록일 뿐이다.
        }
    }
}
