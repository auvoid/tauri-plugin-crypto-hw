package com.plugin.crypto

object Base58BTC {
    private const val PREFIX = 'z'
    private const val BASE = 58
    private val ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".toCharArray()
    private val INDEXES = ALPHABET.withIndex().associate { it.value to it.index }

    fun encode(data: ByteArray): String {
        // Interpret as unsigned big integer
        var intVal = java.math.BigInteger(1, data)
        val sb = StringBuilder()
        while (intVal > java.math.BigInteger.ZERO) {
            val (quotient, remainder) = intVal.divideAndRemainder(java.math.BigInteger.valueOf(BASE.toLong()))
            sb.insert(0, ALPHABET[remainder.toInt()])
            intVal = quotient
        }
        // leading-zero preservation
        data.takeWhile { it.toInt() == 0 }.forEach { sb.insert(0, '1') }
        return "$PREFIX$sb"
    }

    fun decode(str: String): ByteArray? {
        if (str.firstOrNull() != PREFIX) return null
        val body = str.drop(1)
        var intVal = java.math.BigInteger.ZERO
        for (c in body) {
            val idx = INDEXES[c] ?: return null
            intVal = intVal.multiply(java.math.BigInteger.valueOf(BASE.toLong()))
                .add(java.math.BigInteger.valueOf(idx.toLong()))
        }
        val raw = intVal.toByteArray().let {
            // strip sign byte if present
            if (it.size > 1 && it[0] == 0.toByte()) it.copyOfRange(1, it.size) else it
        }
        val leading = body.takeWhile { it == '1' }.count()
        return ByteArray(leading) + raw
    }
}
