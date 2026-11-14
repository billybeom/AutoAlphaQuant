// 정확 알람 계획(E11p2 · 설계 e11p-map P7 · P8 · 06 M1-11).
//
// 🔴 Kotlin 은 계산하지 않는다 — Dart 가 잡마다 다음 회차(`nextOccurrence`)를 정해 목록 통째로 넘기고, 여기는 앞 계획을
//    전부 지운 뒤 그대로 건다(교체). 회차 판정 · 놓친 발화 판정은 Dart `wakeDecisions` 몫.
// 🔴 `setExactAndAllowWhileIdle` — Doze 에서도 울린다(앱당 약 9분 간격 제한 · 잡은 하루 몇 번뿐).
//    정확 알람 권한이 없으면 부정확 알람으로 걸고 그 사실을 돌려준다(자가진단 · 워치독이 지연을 본다).

package com.billybeom.autoalphaquant.operator.ops

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

internal object AlarmPlanner {
    /** 알람 Intent action(취소 때 같은 Intent 로 찾는다). */
    const val ACTION_ALARM = "com.billybeom.autoalphaquant.operator.ALARM"

    /** 알람 한 개. */
    data class Item(val tag: String, val atUtcMs: Long)

    private const val PREFS = "aaq_ops"
    private const val KEY_COUNT = "alarm_count"

    /** 정확 알람을 걸 수 있나. */
    fun canExact(ctx: Context): Boolean =
        Build.VERSION.SDK_INT < 31 || ctx.getSystemService(AlarmManager::class.java).canScheduleExactAlarms()

    /** 앞 계획을 지우고 [items] 를 건다 — 정확하게 걸었으면 true. */
    fun arm(ctx: Context, items: List<Item>): Boolean {
        val am = ctx.getSystemService(AlarmManager::class.java)
        val prefs = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val prev = prefs.getInt(KEY_COUNT, 0)
        for (i in 0 until maxOf(prev, items.size)) {
            pending(ctx, i, null, PendingIntent.FLAG_NO_CREATE)?.let {
                am.cancel(it)
                it.cancel()
            }
        }
        val exact = canExact(ctx)
        items.forEachIndexed { i, item ->
            val pi = pending(ctx, i, item, PendingIntent.FLAG_UPDATE_CURRENT)!!
            if (exact) {
                am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, item.atUtcMs, pi)
            } else {
                am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, item.atUtcMs, pi)
            }
        }
        prefs.edit().putInt(KEY_COUNT, items.size).apply()
        return exact
    }

    private fun pending(ctx: Context, index: Int, item: Item?, flag: Int): PendingIntent? {
        val i = Intent(ctx, AlarmReceiver::class.java).setAction(ACTION_ALARM)
        if (item != null) {
            i.putExtra(AlarmReceiver.EXTRA_TAG, item.tag).putExtra(AlarmReceiver.EXTRA_AT, item.atUtcMs)
        }
        return PendingIntent.getBroadcast(ctx, index, i, flag or PendingIntent.FLAG_IMMUTABLE)
    }
}
