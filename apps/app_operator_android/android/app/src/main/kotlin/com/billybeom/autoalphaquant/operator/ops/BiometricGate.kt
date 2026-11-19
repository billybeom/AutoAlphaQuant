package com.billybeom.autoalphaquant.operator.ops

import android.app.Activity
import android.hardware.biometrics.BiometricManager
import android.hardware.biometrics.BiometricPrompt
import android.os.Build
import android.os.CancellationSignal
import java.util.concurrent.atomic.AtomicBoolean

/**
 * 🆕 E11p4j(R159) — O-04 ③ 생체 서명의 플랫폼 몫. 결과 = `OK` · `CANCELED` · `UNAVAILABLE`(세 값뿐).
 *
 * 🔴 프레임워크 BiometricPrompt(Android 9+) — 새 의존성 0 · 화면(Activity) 그대로.
 * 🔴 강한 생체만(Android 11+ = BIOMETRIC_STRONG) · 기기 암호(PIN · 패턴) 대체 0(05 §63).
 * 🔴 미등록 · 하드웨어 없음 · 잠금(실패 반복) · 화면 없음 · Android 9 미만 = UNAVAILABLE.
 * 🔴 대화상자 글자 = Dart(엔진) 가 넘긴 그대로 — 여기서 문장을 짓지 않는다.
 */
internal object BiometricGate {
    const val OK = "OK"
    const val CANCELED = "CANCELED"
    const val UNAVAILABLE = "UNAVAILABLE"

    fun authenticate(
        a: Activity?,
        title: String,
        subtitle: String,
        cancel: String,
        done: (String) -> Unit,
    ) {
        if (a == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            done(UNAVAILABLE)
            return
        }
        if (!enrolled(a)) {
            done(UNAVAILABLE)
            return
        }
        val once = AtomicBoolean(false)
        fun finish(code: String) {
            if (once.compareAndSet(false, true)) done(code)
        }
        val exec = a.mainExecutor
        val b = BiometricPrompt.Builder(a)
            .setTitle(title)
            .setSubtitle(subtitle)
            .setNegativeButton(cancel, exec) { _, _ -> finish(CANCELED) }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            b.setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG)
        }
        try {
            b.build().authenticate(
                CancellationSignal(),
                exec,
                object : BiometricPrompt.AuthenticationCallback() {
                    override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult?) {
                        finish(OK)
                    }

                    override fun onAuthenticationError(code: Int, message: CharSequence?) {
                        finish(
                            if (code == BiometricPrompt.BIOMETRIC_ERROR_USER_CANCELED ||
                                code == BiometricPrompt.BIOMETRIC_ERROR_CANCELED
                            ) CANCELED else UNAVAILABLE,
                        )
                    }
                },
            )
        } catch (e: RuntimeException) {
            finish(UNAVAILABLE)
        }
    }

    /** 강한 생체가 등록돼 쓸 수 있나(Android 10 = 기본 판정 · 9 = 대화상자가 판정한다). */
    private fun enrolled(a: Activity): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return true
        val m = a.getSystemService(BiometricManager::class.java) ?: return false
        val r = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            m.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)
        } else {
            @Suppress("DEPRECATION")
            m.canAuthenticate()
        }
        return r == BiometricManager.BIOMETRIC_SUCCESS
    }
}
