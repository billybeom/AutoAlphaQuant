// 기기 id(E11p3d-5g · 설계 13 §8 R142 · R141 E16t2b 선행 — X1 «이 기기» 판정 재료).
//
// 🔴 백업 제외 자리(`noBackupFilesDir` — 앱 백업 차단과 이중) — 자동 백업 · 기기 간 이전으로 새 폰에 옮겨지면
//    «이 기기» 필터(R132 N6 · R137 N2)가 깨진다.
// 🔴 처음 한 번 만든다(UUID v4 · 임시 파일 → 이름 바꾸기) · 있으면 그대로 돌려준다.
// 🔴 있는 파일은 절대 덮어쓰지 않는다 — 깨진 값도 그대로 돌려주고 Dart 가 꼴을 보고 거부한다(정체성을 몰래 바꾸지 않는다).
// 🔴 한 프로세스 · 한 엔진(FGS 소유) — @Synchronized 로 첫 생성 경합을 막는다.

package com.billybeom.autoalphaquant.operator.ops

import android.content.Context
import java.io.File
import java.util.UUID

internal object DeviceId {
    /** 파일 이름(`noBackupFilesDir` 안). */
    const val FILE = "aaq_device_id"

    /** 지금 기기 id — 없으면 만든다. */
    @Synchronized
    fun get(ctx: Context): String {
        val dir = ctx.noBackupFilesDir
        val f = File(dir, FILE)
        if (f.exists()) return f.readText().trim()
        val id = UUID.randomUUID().toString()
        val tmp = File(dir, "$FILE.tmp")
        tmp.writeText(id)
        if (!tmp.renameTo(f)) {
            tmp.delete()
            throw IllegalStateException("DEVICE_ID_RENAME_FAILED")
        }
        return id
    }
}
