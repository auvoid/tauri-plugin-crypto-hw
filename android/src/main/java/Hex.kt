package com.plugin.crypto

object HexUtils {
    fun toMultibaseHex(data: ByteArray): String =
        "0x" + data.joinToString("") { "%02x".format(it) }

    fun fromMultibaseHex(str: String): ByteArray? {
        if (!str.startsWith("0x")) return null
        val hex = str.substring(2)
        if (hex.length % 2 != 0) return null
        return try {
            ByteArray(hex.length/2) { i ->
                hex.substring(2*i, 2*i+2).toInt(16).toByte()
            }
        } catch (_: NumberFormatException) { null }
    }
}