// 키 금고 실물 — core `SecretVault` 포트의 Android 몫(E11p · 설계 e11p-map P3 · 06 M4-4 · 04_안전장치 SAF-901~906).
//
// 칸마다 파일 `noBackupFilesDir/aaq_vault/<이름>.bin` · Keystore 키 `aaq_vault_v1` 로 봉한다(aad = 이름 —
// 다른 칸의 파일을 옮겨 붙이면 열리지 않는다).
//
// 🔴 «없음»(파일 없음) = null · «못 엶»(키 소실 · 변조 · 판) = 오류 `unreadable`. 둘을 가르는 까닭: 시크릿 스캔
//    (`readAllSecretValues`)이 못 연 칸을 «없음»으로 건너뛰면 그 값이 스캔에서 빠진 채 «통과»가 된다.
// 🔴 오류 코드만 Dart 로 간다 — 예외 메시지 · 경로 · 값은 채널을 건너지 않는다.

package com.billybeom.autoalphaquant.operator.security

import android.util.AtomicFile
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException

internal class KeystoreVault(
    private val dir: File,
    private val alias: String = ALIAS,
) {
    /** 금고 실패 — [code] 는 채널 오류 코드(값 0). */
    class VaultException(val code: String) : Exception(code)

    /** [id] 의 값 — 파일이 없으면 null · 못 열면 `unreadable`. */
    fun read(id: String): String? {
        val f = fileOf(id)
        val sealed = try {
            f.readFully()
        } catch (e: FileNotFoundException) {
            return null
        } catch (e: IOException) {
            throw VaultException(CODE_IO)
        }
        val key = KeystoreKeys.get(alias) ?: throw VaultException(CODE_UNREADABLE)
        val plain = try {
            AesGcm.open(key, sealed, aad(id))
        } catch (e: Exception) {
            throw VaultException(CODE_UNAVAILABLE)
        } ?: throw VaultException(CODE_UNREADABLE)
        return try {
            String(plain, Charsets.UTF_8)
        } finally {
            plain.fill(0)
        }
    }

    /** [id] 에 [value] 를 둔다(덮어쓴다 · 원자적). */
    fun write(id: String, value: String) {
        val f = fileOf(id)
        if (!dir.isDirectory && !dir.mkdirs()) throw VaultException(CODE_IO)
        val plain = value.toByteArray(Charsets.UTF_8)
        val sealed = try {
            AesGcm.sealWithKeystore(KeystoreKeys.getOrCreate(alias), plain, aad(id))
        } catch (e: Exception) {
            throw VaultException(CODE_UNAVAILABLE)
        } finally {
            plain.fill(0)
        }
        val out = try {
            f.startWrite()
        } catch (e: IOException) {
            throw VaultException(CODE_IO)
        }
        try {
            out.write(sealed)
            f.finishWrite(out)
        } catch (e: IOException) {
            f.failWrite(out)
            throw VaultException(CODE_IO)
        }
    }

    /** [id] 를 지운다(없어도 성공). */
    fun delete(id: String) {
        fileOf(id).delete()
    }

    /** 저장된 이름 전부(이름 순). */
    fun ids(): List<String> =
        (dir.listFiles() ?: emptyArray())
            .asSequence()
            .filter { it.isFile && it.name.endsWith(SUFFIX) }
            .map { it.name.removeSuffix(SUFFIX) }
            .filter { ID.matches(it) }
            .sorted()
            .toList()

    private fun fileOf(id: String): AtomicFile {
        if (!ID.matches(id)) throw VaultException(CODE_BAD_ID)
        return AtomicFile(File(dir, id + SUFFIX))
    }

    private fun aad(id: String): ByteArray = "aaq-vault-v1:$id".toByteArray(Charsets.UTF_8)

    companion object {
        /** 금고 Keystore 키 별칭. */
        const val ALIAS = "aaq_vault_v1"

        /** 금고 폴더 이름(noBackupFilesDir 안). */
        const val DIR = "aaq_vault"

        /** 이름 꼴 — Dart `SecretId` 와 같은 글자(경로 넘김 차단 겸). */
        val ID = Regex("^[a-z0-9][a-z0-9._-]{0,63}$")

        const val CODE_BAD_ID = "bad_id"
        const val CODE_UNREADABLE = "unreadable"
        const val CODE_UNAVAILABLE = "unavailable"
        const val CODE_IO = "io"

        private const val SUFFIX = ".bin"
    }
}
