// 운영 채널 `aaq/ops`(E11p2 · 설계 e11p-map P5 · P8 · P10 · P12).
//
// Dart → Kotlin: ensureChannels · postFgs · startService · arm · diagnose · ready · idle · takeLaunchLink
//                🆕 E11p3d-5(R107): setSecure · requestPermission · openUrl
// Kotlin → Dart: onWake(깨어남 한 건) · onLink(알림 탭 딥링크)
//
// 🔴 판정 0 — 깨어나면 «깨어났다»만 알린다(무엇을 돌릴지는 Dart). 자가진단은 «사실»만 보낸다(문구는 엔진).
// 🔴 Dart 가 `ready` 를 부르기 전의 깨어남 · 링크는 줄에 모았다가 그때 보낸다(콜드 스타트 · 알람으로 뜬 프로세스).
// 🆕 E11p3d-5(R107) — 화면 몫 플랫폼: FLAG_SECURE(지금 화면 · 화면이 없으면 기억했다가 붙을 때) · 권한 요청(결과 = 사실 코드 넷 ·
//    허용 여부는 `diagnose` 로 다시 읽는다) · 외부 링크(https 만 · 다른 꼴 = bad_args).

package com.billybeom.autoalphaquant.operator.ops

import android.Manifest
import android.app.Activity
import android.app.NotificationManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import java.lang.ref.WeakReference
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

    /** 🆕 R107 — 지금 보이는 화면(약한 참조 · FLAG_SECURE · 권한 대화상자). */
    private var activityRef: WeakReference<Activity>? = null

    /** 🆕 R107 — 바라는 FLAG_SECURE(화면이 없으면 기억했다가 붙을 때 건다). */
    private var secure = false

    private const val REQ_NOTIFICATIONS = 7301

    /** 화면이 앞에 왔다(MainActivity.onResume) — 바라는 FLAG_SECURE 를 건다. 🔴 메인 스레드. */
    fun attachActivity(a: Activity) {
        activityRef = WeakReference(a)
        applySecure(a)
    }

    /** 화면이 물러났다(MainActivity.onPause). */
    fun detachActivity(a: Activity) {
        if (activityRef?.get() === a) activityRef = null
    }

    private fun applySecure(a: Activity) {
        a.runOnUiThread {
            if (secure) {
                a.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
            } else {
                a.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            }
        }
    }

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
            // 🆕 R107 — 시크릿 · QR · 복구 카드 라우트(진입 on · 이탈 off · Dart 가 겹침을 센다).
            "setSecure" -> {
                secure = call.argument<Boolean>("on") ?: return r.error("bad_args", null, null)
                activityRef?.get()?.let { applySecure(it) }
                r.success(null)
            }
            "requestPermission" -> {
                val kind = call.argument<String>("kind") ?: return r.error("bad_args", null, null)
                r.success(requestPermission(ctx, kind))
            }
            "openUrl" -> {
                val url = call.argument<String>("url") ?: return r.error("bad_args", null, null)
                val uri = Uri.parse(url)
                if (uri.scheme != "https" || uri.host.isNullOrEmpty()) return r.error("bad_args", null, null)
                r.success(startView(ctx, Intent(Intent.ACTION_VIEW, uri)))
            }
            "takeLaunchLink" -> {
                r.success(pendingLink)
                pendingLink = null
            }
            else -> r.notImplemented()
        }
    }

    /**
     * 🆕 R107 — 권한 요청. 결과 = `ALREADY_GRANTED` · `REQUESTED`(시스템 화면을 띄웠다 · 허용 여부는 diagnose 로 다시) ·
     * `NO_ACTIVITY`(대화상자를 띄울 화면이 없다) · `UNSUPPORTED`(모르는 종류 · 이 판에서 불가).
     */
    private fun requestPermission(ctx: Context, kind: String): String {
        val pkg = Uri.parse("package:" + ctx.packageName)
        when (kind) {
            "notifications" -> {
                val nm = ctx.getSystemService(NotificationManager::class.java)
                val granted = Build.VERSION.SDK_INT < 33 ||
                    ctx.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
                if (granted && nm.areNotificationsEnabled()) return "ALREADY_GRANTED"
                if (!granted) {
                    val a = activityRef?.get() ?: return "NO_ACTIVITY"
                    a.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQ_NOTIFICATIONS)
                    return "REQUESTED"
                }
                val i = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, ctx.packageName)
                return if (startView(ctx, i)) "REQUESTED" else "UNSUPPORTED"
            }
            "batteryExemption" -> {
                val pm = ctx.getSystemService(PowerManager::class.java)
                if (pm.isIgnoringBatteryOptimizations(ctx.packageName)) return "ALREADY_GRANTED"
                val i = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, pkg)
                return if (startView(ctx, i)) "REQUESTED" else "UNSUPPORTED"
            }
            "exactAlarm" -> {
                if (AlarmPlanner.canExact(ctx)) return "ALREADY_GRANTED"
                if (Build.VERSION.SDK_INT < 31) return "UNSUPPORTED"
                val i = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, pkg)
                return if (startView(ctx, i)) "REQUESTED" else "UNSUPPORTED"
            }
        }
        return "UNSUPPORTED"
    }

    /** 시스템 화면 · 브라우저를 띄운다 — 화면이 있으면 그 화면에서, 없으면 새 작업으로. */
    private fun startView(ctx: Context, i: Intent): Boolean {
        val a = activityRef?.get()
        return try {
            if (a != null) {
                a.startActivity(i)
            } else {
                ctx.startActivity(i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            }
            true
        } catch (_: ActivityNotFoundException) {
            false
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
