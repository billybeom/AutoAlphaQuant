// FGS 상시 알림 · 채널 2(E11p2 · 설계 e11p-map P10 · 06 M1-15 · 앱 04 §5-6 `F-01`).
//
// 🔴 문구는 Dart 엔진(`buildFgsNotice`)이 만든 완성 문자열 1개 그대로 — 여기서 잇거나 고치지 않는다.
//    Kotlin 은 레벨 → 색 · 아이콘, 링크 → 탭 Intent 만 정한다(판정 0 · 문구 0).
// 🔴 갱신은 Dart 가 «전이 때만» 부른다(`shouldRepostFgs`) — 여기는 받은 대로 띄울 뿐 주기 재발행을 하지 않는다.
// 🔴 엔진이 아직 아무것도 보내지 않은 첫 기동(콜드 스타트)에는 마지막으로 받은 알림을 다시 띄우고, 그것도 없으면
//    앱 이름만 띄운다 — Kotlin 이 한국어 상태 문장을 지어내지 않는다.

package com.billybeom.autoalphaquant.operator.ops

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Build
import com.billybeom.autoalphaquant.operator.MainActivity
import com.billybeom.autoalphaquant.operator.R

internal object OpsNotifications {
    /** 상시 채널 — `FgsChannel.opsStatus.id` 와 같은 글자. */
    const val STATUS = "ops_status"

    /** P0 채널 — `FgsChannel.opsP0.id` 와 같은 글자. */
    const val P0 = "ops_p0"

    /** FGS 알림 id. */
    const val FGS_ID = 1

    private const val PREFS = "aaq_ops"

    /** 받은 알림 한 벌(Dart `FgsNotice` 의 와이어). */
    data class Notice(val channel: String, val text: String, val level: String, val link: String)

    /**
     * 🔴 FGS 를 올리기 직전에 부른다 — 채널이 없으면 `startForeground` 가 «Bad notification» 으로 앱을 죽인다
     * (에뮬레이터 실측 2026-11-14: 화면이 뜨자마자 FGS 가 Dart 의 `ensureChannels` 보다 먼저 온다).
     * 이름 = Dart 가 지난번에 준 표시 이름 · 처음이면 채널 id 글자(Kotlin 이 한국어 이름을 짓지 않는다 —
     * Dart 가 `ensureChannels` 를 부르면 OS 가 이름을 갱신한다).
     */
    fun ensureExisting(ctx: Context) {
        val p = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        ensureChannels(ctx, mapOf(STATUS to (p.getString("name_$STATUS", null) ?: STATUS), P0 to (p.getString("name_$P0", null) ?: P0)), remember = false)
    }

    /** 채널 둘을 만든다(이미 있으면 OS 가 이름만 갱신한다). [names] = Dart 가 준 표시 이름(기억해 둔다). */
    fun ensureChannels(ctx: Context, names: Map<String, String>, remember: Boolean = true) {
        if (remember) {
            ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().apply {
                names[STATUS]?.let { putString("name_$STATUS", it) }
                names[P0]?.let { putString("name_$P0", it) }
            }.apply()
        }
        if (Build.VERSION.SDK_INT < 26) return
        val nm = ctx.getSystemService(NotificationManager::class.java)
        nm.createNotificationChannel(
            NotificationChannel(STATUS, names[STATUS] ?: STATUS, NotificationManager.IMPORTANCE_LOW).apply {
                setSound(null, null)
                enableVibration(false)
                setShowBadge(false)
            },
        )
        nm.createNotificationChannel(
            NotificationChannel(P0, names[P0] ?: P0, NotificationManager.IMPORTANCE_HIGH).apply {
                // 🔴 방해금지 관통 — 앱이 켜도 OS 가 받아들이지 않을 수 있다 → 자가진단(`p0BypassDnd`)이 실제 값을 본다.
                setBypassDnd(true)
                enableVibration(true)
                setShowBadge(true)
            },
        )
    }

    /** 받은 알림을 기억한다(콜드 스타트 때 다시 띄운다). */
    fun remember(ctx: Context, n: Notice) {
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putString("fgs_channel", n.channel)
            .putString("fgs_text", n.text)
            .putString("fgs_level", n.level)
            .putString("fgs_link", n.link)
            .apply()
    }

    /** 마지막으로 받은 알림(없으면 null). */
    fun last(ctx: Context): Notice? {
        val p = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val ch = p.getString("fgs_channel", null) ?: return null
        return Notice(
            ch,
            p.getString("fgs_text", null) ?: return null,
            p.getString("fgs_level", null) ?: return null,
            p.getString("fgs_link", null) ?: return null,
        )
    }

    /** 띄울 Notification 을 만든다 — [n] 이 null 이면 앱 이름만. */
    fun build(ctx: Context, n: Notice?): Notification {
        val channel = if (n?.channel == P0) P0 else STATUS
        val b = if (Build.VERSION.SDK_INT >= 26) {
            Notification.Builder(ctx, channel)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(ctx)
        }
        b.setSmallIcon(if (n == null || n.level == "OK" || n.level == "INFO") R.drawable.ic_stat_ok else R.drawable.ic_stat_alert)
            .setContentTitle(ctx.applicationInfo.loadLabel(ctx.packageManager))
            .setOngoing(true)
            .setOnlyAlertOnce(channel == STATUS)
            .setShowWhen(false)
            .setCategory(if (channel == P0) Notification.CATEGORY_ALARM else Notification.CATEGORY_SERVICE)
            .setContentIntent(tapIntent(ctx, n?.link))
        levelColor(n?.level)?.let { b.setColor(it) }
        if (n != null) {
            b.setContentText(n.text).setStyle(Notification.BigTextStyle().bigText(n.text))
        }
        if (Build.VERSION.SDK_INT >= 31) {
            b.setForegroundServiceBehavior(Notification.FOREGROUND_SERVICE_IMMEDIATE)
        }
        return b.build()
    }

    /** 레벨 → 색(🔵 표시만 · 판정 0). */
    fun levelColor(level: String?): Int? = when (level) {
        "OK" -> Color.parseColor("#2E7D32")
        "INFO" -> Color.parseColor("#1565C0")
        "WATCH" -> Color.parseColor("#F9A825")
        "ACT" -> Color.parseColor("#EF6C00")
        "BLOCKED" -> Color.parseColor("#C62828")
        else -> null
    }

    private fun tapIntent(ctx: Context, link: String?): PendingIntent {
        val i = Intent(ctx, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        if (link != null && link.startsWith("aaq://")) {
            i.action = Intent.ACTION_VIEW
            i.data = Uri.parse(link)
        }
        return PendingIntent.getActivity(ctx, 0, i, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
    }
}
