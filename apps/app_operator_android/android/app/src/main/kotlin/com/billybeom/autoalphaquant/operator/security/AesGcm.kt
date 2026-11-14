// AES-GCM 봉투 꼴(E11p · 설계 e11p-map P2 · P3).
//
// 봉투 = [판 1바이트][nonce 12바이트][암호문 + 태그 16바이트].
// 🔴 열기 실패(길이 · 판 · 태그 · aad)는 null — 데이터 문제는 «없음»으로 보고한다(01 §12-1 «해독 실패 = load null»).
// 🔴 키 접근 실패(Keystore 가 잠시 못 씀 등)는 그대로 던진다 — 부르는 쪽이 «키를 잃었다»와 «잠시 못 쓴다»를
//    가른다. 둘을 한데 null 로 뭉개면 일시 장애 한 번에 초안 · 큐 전부를 버리게 된다.

package com.billybeom.autoalphaquant.operator.security

import java.security.SecureRandom
import javax.crypto.BadPaddingException
import javax.crypto.Cipher
import javax.crypto.IllegalBlockSizeException
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

internal object AesGcm {
    /** 봉투 판 — 바꾸면 옛 봉투는 null 로 열린다(새로 시작). */
    const val VERSION: Byte = 1

    private const val IV_LEN = 12
    private const val TAG_BITS = 128
    private const val TAG_LEN = TAG_BITS / 8
    private const val TRANSFORM = "AES/GCM/NoPadding"

    private val random = SecureRandom()

    /** 봉투의 가장 짧은 길이(빈 평문). */
    const val MIN_LEN = 1 + IV_LEN + TAG_LEN

    /**
     * Keystore 키로 봉한다 — nonce 는 Keystore 가 고른다(randomized encryption required 키는
     * 바깥 nonce 를 받지 않는다).
     */
    fun sealWithKeystore(key: SecretKey, plain: ByteArray, aad: ByteArray): ByteArray {
        val c = Cipher.getInstance(TRANSFORM)
        c.init(Cipher.ENCRYPT_MODE, key)
        c.updateAAD(aad)
        val body = c.doFinal(plain)
        val iv = c.iv ?: throw IllegalStateException("nonce 없음")
        check(iv.size == IV_LEN) { "nonce 길이" }
        return frame(iv, body)
    }

    /** 메모리 키(DEK)로 봉한다 — nonce = SecureRandom 12바이트. */
    fun sealWithRaw(key: SecretKey, plain: ByteArray, aad: ByteArray): ByteArray {
        val iv = ByteArray(IV_LEN).also { random.nextBytes(it) }
        val c = Cipher.getInstance(TRANSFORM)
        c.init(Cipher.ENCRYPT_MODE, key, GCMParameterSpec(TAG_BITS, iv))
        c.updateAAD(aad)
        return frame(iv, c.doFinal(plain))
    }

    /**
     * 연다 — 길이 · 판 · 태그 · aad 가 어긋나면 null.
     * 🔴 `init` 의 키 오류는 던진다(위 머리 주석).
     */
    fun open(key: SecretKey, sealed: ByteArray, aad: ByteArray): ByteArray? {
        if (sealed.size < MIN_LEN) return null
        if (sealed[0] != VERSION) return null
        val iv = sealed.copyOfRange(1, 1 + IV_LEN)
        val c = Cipher.getInstance(TRANSFORM)
        c.init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(TAG_BITS, iv))
        c.updateAAD(aad)
        return try {
            c.doFinal(sealed, 1 + IV_LEN, sealed.size - 1 - IV_LEN)
        } catch (e: BadPaddingException) {
            null // AEADBadTagException 포함 — 변조 · aad 다름 · 다른 키
        } catch (e: IllegalBlockSizeException) {
            null
        }
    }

    private fun frame(iv: ByteArray, body: ByteArray): ByteArray {
        val out = ByteArray(1 + iv.size + body.size)
        out[0] = VERSION
        System.arraycopy(iv, 0, out, 1, iv.size)
        System.arraycopy(body, 0, out, 1 + iv.size, body.size)
        return out
    }
}
