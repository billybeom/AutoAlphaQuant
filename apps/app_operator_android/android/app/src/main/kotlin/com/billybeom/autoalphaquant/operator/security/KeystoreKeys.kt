// Android Keystore 비내보내기 AES 키(E11p · 설계 e11p-map P2 · P3).
//
// 🔴 사용자 인증(생체 · 화면 잠금)을 키에 묶지 않는다 — 엔진이 백그라운드(FGS · 알람)에서 금고를 읽고,
//    명령 큐 ⓑ 가 백그라운드로 전송되어야 한다(06 M4-9 ① «생체 결속 없음»). 생체 열람은 화면(M9 S02) 몫이다.
// 🔴 키 바이트는 이 프로세스로도 나오지 않는다(Keystore 가 연산만 해 준다).

package com.billybeom.autoalphaquant.operator.security

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyStore
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey

internal object KeystoreKeys {
    private const val PROVIDER = "AndroidKeyStore"

    /** [alias] 키가 있나. */
    fun exists(alias: String): Boolean = keyStore().containsAlias(alias)

    /** [alias] 키(없으면 null). */
    fun get(alias: String): SecretKey? = keyStore().getKey(alias, null) as? SecretKey

    /** [alias] 키 — 없으면 만든다(AES-256 · GCM · 패딩 없음 · nonce 무작위 강제). */
    @Synchronized
    fun getOrCreate(alias: String): SecretKey {
        get(alias)?.let { return it }
        val gen = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, PROVIDER)
        gen.init(
            KeyGenParameterSpec.Builder(
                alias,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(256)
                .setRandomizedEncryptionRequired(true)
                .build(),
        )
        return gen.generateKey()
    }

    private fun keyStore(): KeyStore = KeyStore.getInstance(PROVIDER).apply { load(null) }
}
