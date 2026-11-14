// 운영 채널 `aaq/ops`(E11p2 · 설계 e11p-map P5 · P8 · P10 · P12).
//
// Dart → Kotlin: ensureChannels · postFgs · startService · arm · diagnose · ready · idle · takeLaunchLink
// Kotlin → Dart: onWake(깨어남 한 건) · onLink(알림 탭 딥링크)
//
// 🔴 판정 0 — 깨어나면 «깨어났다»만 알린다(무엇을 돌릴지는 Dart). 자가진단은 «사실»만 보낸다(문구는 엔진).
// 🔴 Dart 가 `ready` 를 부르기 전의 깨어남 · 링크는 줄에 모았다가 그때 보낸다(콜드 스타트 · 알람으로 뜬 프로세스).

package com.billybeom.autoalphaquant.operator.ops

import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.PowerManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal object OpsChannel {
    /** 채널 이름 — Dart `OperatorChannelNames.ops` 와 같은 글자. */
    const val OPS = "aaq/ops"

    private const val WAKELOCK_MS = 10 * 60 * 1000L

    private var channel: MethodChannel? = null
    private var ready = false
    private val pendingWakes = ArrayList<Map<String, Any?>>()
    private var pendingLink: String? = null
    private var wakeLock: PowerManager.WakeLock? = null

    /** [messenger] 에 단다(엔진 하나에 한 번). */
    fun register(ctx: Context, messenger: BinaryMessenger) {
        val app = ctx.applicationContext
        val ch = MethodChannel(messenger, OPS)
        ch.setMethodCallHandler { call, result -> handle(app, call, result) }
        channel = ch
        ready = false
    }

    /** 깨어남을 Dart 로(아직이면 줄에) — 처리하는 동안 CPU 를 붙잡는다. 🔴 메인 스레드. */
    fun deliverWake(ctx: Context, w: Wake) {
        holdWakeLock(ctx)
        val m = w.toMap()
        val ch = channel
        if (ready && ch != null) ch.invokeMethod("onWake", m) else pendingWakes.add(m)
    }

    /** 알림 탭 딥링크를 Dart 로(아직이면 기억). 🔴 메인 스레드. */
    fun deliverLink(link: String) {
        val ch = channel
        if (ready && ch != null) ch.invokeMethod("onLink", link) else pendingLink = link
    }

    private fun handle(ctx: Context, call: MethodCall, r: MethodChannel.Result) {
        when (call.method) {
            "ensureChannels" -> {
                @Suppress("UNCHECKED_CAST")
                val names = (call.argument<Any?>("names") as? Map<String, String>) ?: emptyMap()
                OpsNotifications.ensureChannels(ctx, names)
                r.success(null)
            }
            "postFgs" -> {
                val n = OpsNotifications.Notice(
                    channel = call.argument<String>("channel") ?: return r.error("bad_args", null, null),
                    text = call.argument<String>("text") ?: return r.error("bad_args", null, null),
                    level = call.argument<String>("level") ?: return r.error("bad_args", null, null),
                    link = call.argument<String>("link") ?: return r.error("bad_args", null, null),
                )
                OpsNotifications.remember(ctx, n)
                OpsNotifications.ensureExisting(ctx)
                if (EngineService.running) {
                    ctx.getSystemService(NotificationManager::class.java)
                        .notify(OpsNotifications.FGS_ID, OpsNotifications.build(ctx, n))
                } else {
                    EngineService.wake(ctx, Wake(Wake.START, null, null, System.currentTimeMillis()))
                }
                r.success(null)
            }
            "startService" -> {
                if (!EngineService.running) {
                    EngineService.wake(ctx, Wake(Wake.START, null, null, System.currentTimeMillis()))
                }
                r.success(null)
            }
            "arm" -> {
                val raw = call.argument<List<Map<String, Any?>>>("items") ?: return r.error("bad_args", null, null)
                val items = raw.map {
                    AlarmPlanner.Item(
                        tag = it["tag"] as? String ?: return r.error("bad_args", null, null),
                        atUtcMs = (it["atMs"] as? Number)?.toLong() ?: return r.error("bad_args", null, null),
                    )
                }
                r.success(AlarmPlanner.arm(ctx, items))
            }
            "diagnose" -> r.success(diagnose(ctx))
            "ready" -> {
                ready = true
                val ch = channel
                if (ch != null) {
                    pendingWakes.forEach { ch.invokeMethod("onWake", it) }
                    pendingLink?.let { ch.invokeMethod("onLink", it) }
                }
                pendingWakes.clear()
                pendingLink = null
                r.success(null)
            }
            "idle" -> {
                releaseWakeLock()
                r.success(null)
            }
            // E11p3a(Q1) — 앱 전용 폴더(엔진 원장 = noBackup 아래 · 백업 차단 이중).
            "paths" -> r.success(
                mapOf(
                    "files" to ctx.filesDir.absolutePath,
                    "noBackup" to ctx.noBackupFilesDir.absolutePath,
                ),
            )
            "takeLaunchLink" -> {
                r.success(pendingLink)
                pendingLink = null
            }
            else -> r.notImplemented()
        }
    }

    /** 자가진단 사실 5 + 시작 막힘 횟수(06 M1-15 «Android 생존 자가진단»). */
    private fun diagnose(ctx: Context): Map<String, Any?> {
        val nm = ctx.getSystemService(NotificationManager::class.java)
        val pm = ctx.getSystemService(PowerManager::class.java)
        val p0Bypass = if (Build.VERSION.SDK_INT >= 26) nm.getNotificationChannel(OpsNotifications.P0)?.canBypassDnd() ?: false else false
        return mapOf(
            "notificationsEnabled" to nm.areNotificationsEnabled(),
            "exactAlarm" to AlarmPlanner.canExact(ctx),
            "batteryExempt" to pm.isIgnoringBatteryOptimizations(ctx.packageName),
            "p0BypassDnd" to p0Bypass,
            "fgsRunning" to EngineService.running,
            "fgsStartDenied" to EngineService.deniedCount(ctx),
        )
    }

    private fun holdWakeLock(ctx: Context) {
        val wl = wakeLock ?: ctx.getSystemService(PowerManager::class.java)
            .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "aaq:wake")
            .also {
                it.setReferenceCounted(false)
                wakeLock = it
            }
        wl.acquire(WAKELOCK_MS)
    }

    private fun releaseWakeLock() {
        wakeLock?.let { if (it.isHeld) it.release() }
    }
}
