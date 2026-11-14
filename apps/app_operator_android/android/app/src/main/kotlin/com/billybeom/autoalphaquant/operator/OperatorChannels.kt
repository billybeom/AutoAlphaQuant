// 플랫폼 채널 등록(E11p · 설계 e11p-map P5).
//
// 채널 이름은 Dart `OperatorChannelNames` 와 같은 글자다. 🔴 바꾸면 양쪽을 한 커밋에서 바꾼다.
// 🔴 암호 · 파일 일은 직렬 스레드 하나에서 한다 — 같은 칸의 write 뒤 read 순서를 지키고, 플랫폼(UI) 스레드를
//    막지 않는다. 답(`Result`)은 플랫폼 스레드로 돌려보낸다.
// 🔴 오류는 코드만 보낸다(message · details = null) — 값 · 경로 · 예외 글이 Dart 로 건너가지 않는다.
// 🔵 금고 · 봉함 객체는 프로세스에 하나다 — E11p2 에서 FGS 가 엔진을 소유해도 같은 DEK 캐시 · 같은 직렬 스레드를 쓴다.

package com.billybeom.autoalphaquant.operator

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.billybeom.autoalphaquant.operator.security.DekSealedBox
import com.billybeom.autoalphaquant.operator.security.KeystoreVault
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

internal object OperatorChannels {
    /** 금고 채널. */
    const val VAULT = "aaq/vault"

    /** 봉함 채널. */
    const val SEALED_BOX = "aaq/sealed_box"

    private const val CODE_BAD_ARGS = "bad_args"
    private const val CODE_SEAL_FAILED = "seal_failed"

    private val main = Handler(Looper.getMainLooper())
    private val io: ExecutorService = Executors.newSingleThreadExecutor { r -> Thread(r, "aaq-secure-io") }

    private var vault: KeystoreVault? = null
    private var box: DekSealedBox? = null

    /** [messenger] 에 채널 둘을 단다. */
    @Synchronized
    fun register(context: Context, messenger: BinaryMessenger) {
        val app = context.applicationContext
        val v = vault ?: KeystoreVault(File(app.noBackupFilesDir, KeystoreVault.DIR)).also { vault = it }
        val b = box ?: DekSealedBox(app.noBackupFilesDir).also { box = it }
        MethodChannel(messenger, VAULT).setMethodCallHandler { call, result ->
            io.execute { onVault(v, call, Reply(result)) }
        }
        MethodChannel(messenger, SEALED_BOX).setMethodCallHandler { call, result ->
            io.execute { onSealedBox(b, call, Reply(result)) }
        }
    }

    private fun onVault(v: KeystoreVault, call: MethodCall, r: Reply) {
        try {
            when (call.method) {
                "read" -> r.ok(v.read(call.str("id") ?: return r.err(CODE_BAD_ARGS)))
                "write" -> {
                    val id = call.str("id") ?: return r.err(CODE_BAD_ARGS)
                    val value = call.str("value") ?: return r.err(CODE_BAD_ARGS)
                    v.write(id, value)
                    r.ok(null)
                }
                "delete" -> {
                    v.delete(call.str("id") ?: return r.err(CODE_BAD_ARGS))
                    r.ok(null)
                }
                "ids" -> r.ok(ArrayList(v.ids()))
                else -> r.notImplemented()
            }
        } catch (e: KeystoreVault.VaultException) {
            r.err(e.code)
        } catch (e: Exception) {
            r.err(KeystoreVault.CODE_UNAVAILABLE)
        }
    }

    private fun onSealedBox(b: DekSealedBox, call: MethodCall, r: Reply) {
        when (call.method) {
            "seal" -> {
                val plain = call.bytes("plain") ?: return r.err(CODE_BAD_ARGS)
                val aad = call.str("aad") ?: return r.err(CODE_BAD_ARGS)
                try {
                    r.ok(b.seal(plain, aad.toByteArray(Charsets.UTF_8)))
                } catch (e: Exception) {
                    r.err(CODE_SEAL_FAILED)
                }
            }
            // 🔴 열기는 어떤 실패도 null(포트 약속) — 인자 꼴이 틀려도 null.
            "open" -> {
                val sealed = call.bytes("sealed")
                val aad = call.str("aad")
                r.ok(if (sealed == null || aad == null) null else b.open(sealed, aad.toByteArray(Charsets.UTF_8)))
            }
            else -> r.notImplemented()
        }
    }

    private fun MethodCall.str(key: String): String? = argument<Any?>(key) as? String

    private fun MethodCall.bytes(key: String): ByteArray? = argument<Any?>(key) as? ByteArray

    /** 답을 플랫폼 스레드로 돌려보낸다 — 한 번만. */
    private class Reply(private val result: MethodChannel.Result) {
        fun ok(value: Any?) {
            main.post { result.success(value) }
        }

        fun err(code: String) {
            main.post { result.error(code, null, null) }
        }

        fun notImplemented() {
            main.post { result.notImplemented() }
        }
    }
}
