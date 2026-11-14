// 알람 · 부팅 수신기(E11p2 · 설계 e11p-map P8 · P11 · 06 M1-11).
//
// 🔴 받으면 FGS 를 깨워 Dart 에 «깨어남»만 알린다 — 무엇을 돌릴지는 Dart `wakeDecisions` 가 정한다.
// 🔵 정확 알람 · 부팅 · 패키지 교체 · 시각/시간대 변경은 Android 12+ 백그라운드 FGS 시작 금지의 예외다.

package com.billybeom.autoalphaquant.operator.ops

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** 정확 알람 수신. */
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        EngineService.wake(
            context,
            Wake(
                reason = Wake.ALARM,
                tag = intent.getStringExtra(EXTRA_TAG),
                scheduledAtMs = intent.getLongExtra(EXTRA_AT, 0L).takeIf { it > 0L },
                firedAtMs = System.currentTimeMillis(),
            ),
        )
    }

    companion object {
        const val EXTRA_TAG = "tag"
        const val EXTRA_AT = "at"
    }
}

/** 부팅 · 패키지 교체 · 시각 변경 수신 — 알람은 재부팅에 사라지므로 Dart 가 다시 건다. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val reason = when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED -> Wake.BOOT
            Intent.ACTION_MY_PACKAGE_REPLACED -> Wake.PACKAGE_REPLACED
            Intent.ACTION_TIME_CHANGED -> Wake.TIME_SET
            Intent.ACTION_TIMEZONE_CHANGED -> Wake.TIMEZONE
            else -> return
        }
        EngineService.wake(context, Wake(reason, null, null, System.currentTimeMillis()))
    }
}

/** 깨어남 한 건(Dart `onWake` 의 와이어). */
internal data class Wake(val reason: String, val tag: String?, val scheduledAtMs: Long?, val firedAtMs: Long) {
    fun toMap(): Map<String, Any?> = mapOf(
        "reason" to reason,
        "tag" to tag,
        "scheduledAtMs" to scheduledAtMs,
        "firedAtMs" to firedAtMs,
    )

    companion object {
        const val ALARM = "alarm"
        const val BOOT = "boot"
        const val PACKAGE_REPLACED = "package_replaced"
        const val TIME_SET = "time_set"
        const val TIMEZONE = "timezone"
        const val START = "start"
    }
}
