// 🔴 debug 빌드 전용 — 실측 스크립트(`tool/measure_survival.sh`)가 «시험 알람 하나»를 건다(E11p2 · P13 ③).
//
//   adb shell am broadcast -n com.billybeom.autoalphaquant.operator/.ops.ProbeReceiver --el delayMs 70000
//
// 엔진 알람 계획(요청 코드 0..n)과 겹치지 않는 요청 코드를 쓰고 · 같은 AlarmReceiver 로 울린다(꼬리표 `probe`).
// release 빌드에는 이 파일 · 이 수신기 선언이 없다(src/debug 소스 세트).

package com.billybeom.autoalphaquant.operator.ops

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ProbeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val at = System.currentTimeMillis() + intent.getLongExtra("delayMs", 70_000L)
        val i = Intent(context, AlarmReceiver::class.java).setAction(AlarmPlanner.ACTION_ALARM)
            .putExtra(AlarmReceiver.EXTRA_TAG, "probe")
            .putExtra(AlarmReceiver.EXTRA_AT, at)
        val pi = PendingIntent.getBroadcast(
            context,
            PROBE_REQUEST,
            i,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val am = context.getSystemService(AlarmManager::class.java)
        if (AlarmPlanner.canExact(context)) {
            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pi)
        } else {
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pi)
        }
    }

    companion object {
        private const val PROBE_REQUEST = 9_999
    }
}
