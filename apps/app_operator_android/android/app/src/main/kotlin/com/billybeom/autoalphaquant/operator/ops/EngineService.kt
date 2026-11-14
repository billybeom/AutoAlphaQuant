// 엔진 FGS(E11p2 · 설계 e11p-map P6 · P9 · 06 M1-11 · 앱 README §3).
//
// 🔴 타입 = specialUse — dataSync 는 Android 15 에서 24h 중 6h 한도 + BOOT_COMPLETED 시작 금지라 상시 FGS 가 될 수 없다.
// 🔴 상시 알림은 사양이다(앱 04 §5-6) — ongoing · 스와이프 불가 · 끄는 버튼 없음.
// 🔴 이 서비스가 엔진(FlutterEngine)을 소유한다(EngineHost) — 화면이 닫혀도 Dart 가 산다.
// 🔵 깨어남을 처리하는 동안은 부분 wakelock(최대 10분) — Dart 가 `idle` 을 부르면 놓는다.

package com.billybeom.autoalphaquant.operator.ops

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

class EngineService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        running = true
        goForeground()
        EngineHost.obtain(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        goForeground()
        if (intent?.action == ACTION_WAKE) {
            OpsChannel.deliverWake(
                this,
                Wake(
                    reason = intent.getStringExtra(X_REASON) ?: Wake.START,
                    tag = intent.getStringExtra(X_TAG),
                    scheduledAtMs = intent.getLongExtra(X_SCHEDULED, 0L).takeIf { it > 0L },
                    firedAtMs = intent.getLongExtra(X_FIRED, System.currentTimeMillis()),
                ),
            )
        }
        return START_STICKY
    }

    override fun onDestroy() {
        running = false
        super.onDestroy()
    }

    private fun goForeground() {
        OpsNotifications.ensureExisting(this)
        val n = OpsNotifications.build(this, OpsNotifications.last(this))
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(OpsNotifications.FGS_ID, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(OpsNotifications.FGS_ID, n)
        }
    }

    companion object {
        private const val ACTION_WAKE = "com.billybeom.autoalphaquant.operator.WAKE"
        private const val X_REASON = "reason"
        private const val X_TAG = "tag"
        private const val X_SCHEDULED = "scheduledAtMs"
        private const val X_FIRED = "firedAtMs"
        private const val PREFS = "aaq_ops"
        private const val KEY_DENIED = "fgs_start_denied"

        /** 실행 중인가(자가진단). */
        @Volatile
        var running: Boolean = false
            private set

        /** 화면이 떴을 때 — 아직 안 돌면 띄운다(포그라운드라 시작 제한이 없다). */
        internal fun startFromForeground(ctx: Context) {
            if (!running) wake(ctx, Wake(Wake.START, null, null, System.currentTimeMillis()))
        }

        /** 서비스를 깨워 [w] 를 Dart 로 보낸다 — 먼저 실측 기록에 적고, 시작이 막히면 횟수를 센다(자가진단 · 실측). */
        internal fun wake(ctx: Context, w: Wake) {
            WakeLog.append(ctx, w)
            val i = Intent(ctx, EngineService::class.java).setAction(ACTION_WAKE)
                .putExtra(X_REASON, w.reason)
                .putExtra(X_TAG, w.tag)
                .putExtra(X_SCHEDULED, w.scheduledAtMs ?: 0L)
                .putExtra(X_FIRED, w.firedAtMs)
            try {
                if (Build.VERSION.SDK_INT >= 26) ctx.startForegroundService(i) else ctx.startService(i)
            } catch (e: IllegalStateException) {
                // ForegroundServiceStartNotAllowedException(31+) 포함 — 던지지 않고 센다.
                val p = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                p.edit().putInt(KEY_DENIED, p.getInt(KEY_DENIED, 0) + 1).apply()
            }
        }

        /** 시작이 막힌 횟수. */
        internal fun deniedCount(ctx: Context): Int =
            ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getInt(KEY_DENIED, 0)
    }
}
