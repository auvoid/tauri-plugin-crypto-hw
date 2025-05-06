//
//  Utils.swift
//  tauri-plugin-crypto
//
//  Created by SoSweetHam on 06/05/25.
//

import Foundation
import BigInt

// Base58BTC alphabet (Bitcoin alphabet)
private let base58Alphabet = Array("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
private let base58Map: [Character: Int] = {
    var dict = [Character: Int]()
    for (i, c) in base58Alphabet.enumerated() {
        dict[c] = i
    }
    return dict
}()

// MARK: - Encoding

func base58btcMultibaseEncode(_ data: Data) -> String {
    var intVal = BigUInt(data)

    var result = ""
    while intVal > 0 {
        let (quotient, remainder) = intVal.quotientAndRemainder(dividingBy: 58)
        result.insert(base58Alphabet[Int(remainder)], at: result.startIndex)
        intVal = quotient
    }

    // Preserve leading zero bytes
    for byte in data {
        if byte == 0 {
            result.insert("1", at: result.startIndex)
        } else {
            break
        }
    }

    return "z" + result
}

// MARK: - Decoding

func base58btcMultibaseDecode(_ base58: String) -> Data? {
    guard base58.first == "z" else { return nil }
    let base58Str = base58.dropFirst()

    var intVal = BigUInt(0)
    for char in base58Str {
        guard let digit = base58Map[char] else { return nil }
        intVal = intVal * 58 + BigUInt(digit)
    }

    var bytes = intVal.serialize()

    // Add leading zeros
    let leadingOnes = base58Str.prefix { $0 == "1" }.count
    if leadingOnes > 0 {
        bytes = Data(repeating: 0, count: leadingOnes) + bytes
    }

    return bytes
}


