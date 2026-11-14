// 봉함 실물 — core `SealedBox` 포트의 Android 몫(E11p · 설계 e11p-map P2 · 06 M4-9 ① · 01 §12-1).
//
// Keystore 비내보내기 키(`aaq_dek_wrap_v1`)가 DEK(256비트)를 감싸 `noBackupFilesDir/aaq_dek_v1.bin` 에 둔다.
// 봉함 · 열기는 메모리의 DEK 로 한다(행마다 Keystore 를 부르지 않는다).
//
// 🔴 «잃음»일 때만 새 DEK 를 만든다 — 감싼 파일이 없음 · 감싼 키 별칭이 없음(앱 데이터 지움 · 다른 기기) ·
//    감싼 파일이 열리지 않음(판 · 태그). 그때 옛 봉함은 전부 null 로 열린다(= 의무 «새로 시작»).
// 🔴 Keystore 가 «잠시» 못 쓰는 것(예외)은 새 DEK 를 만들지 않는다 — 봉함은 실패로 던지고 열기는 null 이며,
//    다음 부름이 다시 시도한다. 일시 장애 한 번에 초안 · 큐를 버리지 않는다.

package com.billybeom.autoalphaquant.operator.security

import android.util.AtomicFile
import java.io.File
import java.io.FileNotFoundException
import java.security.SecureRandom
import javax.crypto.SecretKey
import javax.crypto.spec.SecretKeySpec

internal class DekSealedBox(
    dir: File,
    private val wrapAlias: String = WRAP_ALIAS,
) {
    private val file = AtomicFile(File(dir, DEK_FILE))
    private var dek: SecretKey? = null

    /** [plain] 을 [aad] 에 묶어 봉한다 — 🔴 실패는 던진다(채널이 `seal_failed` 로 옮긴다). */
    fun seal(plain: ByteArray, aad: ByteArray): ByteArray = AesGcm.sealWithRaw(dek(), plain, aad)

    /** 연다 — 🔴 어떤 실패도 null. */
    fun open(sealed: ByteArray, aad: ByteArray): ByteArray? =
        try {
            AesGcm.open(dek(), sealed, aad)
        } catch (e: Exception) {
            null
        }

    @Synchronized
    private fun dek(): SecretKey {
        dek?.let { return it }
        val loaded = load() ?: create()
        dek = loaded
        return loaded
    }

    /** 감싼 DEK 를 푼다 — «잃음»이면 null(새로 만든다) · 일시 장애면 던진다. */
    private fun load(): SecretKey? {
        val wrapped = try {
            file.readFully()
        } catch (e: FileNotFoundException) {
            return null
        }
        if (!KeystoreKeys.exists(wrapAlias)) return null
        val wrap = KeystoreKeys.get(wrapAlias) ?: return null
        val raw = AesGcm.open(wrap, wrapped, WRAP_AAD) ?: return null
        if (raw.size != DEK_LEN) {
            raw.fill(0)
            return null
        }
        return SecretKeySpec(raw, "AES").also { raw.fill(0) }
    }

    private fun create(): SecretKey {
        val raw = ByteArray(DEK_LEN).also { SecureRandom().nextBytes(it) }
        try {
            val wrap = KeystoreKeys.getOrCreate(wrapAlias)
            val wrapped = AesGcm.sealWithKeystore(wrap, raw, WRAP_AAD)
            val out = file.startWrite()
            try {
                out.write(wrapped)
                file.finishWrite(out)
            } catch (e: Exception) {
                file.failWrite(out)
                throw e
            }
            return SecretKeySpec(raw, "AES")
        } finally {
            raw.fill(0)
        }
    }

    companion object {
        /** 감싸는 Keystore 키 별칭. */
        const val WRAP_ALIAS = "aaq_dek_wrap_v1"

        /** 감싼 DEK 파일 이름(noBackupFilesDir 안). */
        const val DEK_FILE = "aaq_dek_v1.bin"

        private const val DEK_LEN = 32
        private val WRAP_AAD = "aaq-dek-v1".toByteArray(Charsets.UTF_8)
    }
}
