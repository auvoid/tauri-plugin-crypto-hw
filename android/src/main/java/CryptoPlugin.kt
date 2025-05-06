package com.plugin.crypto

import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import app.tauri.BuildConfig

import app.tauri.annotation.Command
import app.tauri.annotation.InvokeArg
import app.tauri.annotation.TauriPlugin
import app.tauri.plugin.JSObject
import app.tauri.plugin.Plugin
import app.tauri.plugin.Invoke

import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature
import java.security.spec.ECGenParameterSpec


//@InvokeArg
//class PingArgs {
//    var value: String? = null
//}

@InvokeArg class IncludesIdentifier {
    var identifier: String? = null
}

@InvokeArg class SignRequest {
    var identifier: String? = null
    var payload: String? = null
}

@InvokeArg class VerifySignatureRequest {
    var identifier: String? = null
    var payload: String? = null
    var signature: String? = null
}

@TauriPlugin
class CryptoPlugin(private val activity: Activity): Plugin(activity) {
    private fun alias(id: String) = "${BuildConfig.LIBRARY_PACKAGE_NAME}.$id"

    /** Generate EC keypair in StrongBox; fail if unavailable or exists */
    private fun generateKeyPair(alias: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P ||
            !activity.packageManager.hasSystemFeature(PackageManager.FEATURE_STRONGBOX_KEYSTORE)) {
            throw Exception("StrongBox requires Android P or above")
        }
        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        if (ks.containsAlias(alias)) throw Exception("Key already exists")
        val kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore")
        val spec = KeyGenParameterSpec.Builder(
            alias,
            KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
        )
            .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
            .setDigests(KeyProperties.DIGEST_SHA256)
            .setIsStrongBoxBacked(true)              // enforce StrongBox :contentReference[oaicite:5]{index=5}
            .build()
        try {
            kpg.initialize(spec)
            kpg.generateKeyPair()
        } catch (e: Exception) {
            throw Exception("StrongBox key generation failed: ${e.message}")
        }
    }

    /** Retrieve KeyPair from AndroidKeyStore */
    private fun getKeyPair(alias: String): KeyPair {
        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        val priv = ks.getKey(alias, null) ?: throw Exception("Private key missing")
        val pub = ks.getCertificate(alias)?.publicKey ?: throw Exception("Public key missing")
        return KeyPair(pub, priv as java.security.PrivateKey)
    }

    @Command
    fun generate(invoke: Invoke) {
        val id = invoke.parseArgs(IncludesIdentifier::class.java).identifier
            ?: return invoke.reject("Missing identifier")
        try {
            generateKeyPair(alias(id))
            invoke.resolve(JSObject().apply { put("message","Key generated successfully") })
        } catch (e: Exception) {
            if (e.message?.contains("exists") == true) {
                invoke.resolve(JSObject().apply { put("message","Key already exists") })
            } else {
                invoke.reject(e.message ?: "Generation failed")
            }
        }
    }

    @Command
    fun exists(invoke: Invoke) {
        val id = invoke.parseArgs(IncludesIdentifier::class.java).identifier
            ?: return invoke.reject("Missing identifier")
        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        invoke.resolve(JSObject().apply { put("exists", ks.containsAlias(alias(id))) })
    }

    @Command
    fun getPublicKey(invoke: Invoke) {
        val id = invoke.parseArgs(IncludesIdentifier::class.java).identifier
            ?: return invoke.reject("Missing identifier")
        try {
            val pub = getKeyPair(alias(id)).public.encoded
            val hex = HexUtils.toMultibaseHex(pub)     // 0x… hex output
            invoke.resolve(JSObject().apply { put("publicKey", hex) })
        } catch (e: Exception) {
            invoke.reject("Couldn't retrieve public key")
        }
    }

    @Command
    fun signPayload(invoke: Invoke) {
        val req = invoke.parseArgs(SignRequest::class.java)
        val id = req.identifier ?: return invoke.reject("Missing identifier")
        val payload = req.payload ?: return invoke.reject("Missing payload")
        try {
            val sig = Signature.getInstance("SHA256withECDSA").apply {
                initSign(getKeyPair(alias(id)).private)
                update(payload.toByteArray())
            }.sign()
            val base58Sig = Base58BTC.encode(sig)
            invoke.resolve(JSObject().apply { put("signature", base58Sig) })
        } catch (e: Exception) {
            invoke.reject("Couldn't create signature")
        }
    }

    @Command
    fun verifySignature(invoke: Invoke) {
        val req = invoke.parseArgs(VerifySignatureRequest::class.java)
        val id = req.identifier ?: return invoke.reject("Missing identifier")
        val payload = req.payload ?: return invoke.reject("Missing payload")
        val sig = req.signature ?: return invoke.reject("Missing signature")
        try {
            val sigBytes = Base58BTC.decode(sig) ?: throw Exception("Invalid signature format")
            val verified = Signature.getInstance("SHA256withECDSA").apply {
                initVerify(getKeyPair(alias(id)).public)
                update(payload.toByteArray())
            }.verify(sigBytes)
            invoke.resolve(JSObject().apply { put("valid", verified) })
        } catch (e: Exception) {
            invoke.reject("Couldn't verify signature")
        }
    }
}
