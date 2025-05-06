//
//  Hex.swift
//  tauri-plugin-crypto
//
//  Created by SoSweetHam on 06/05/25.
//
import Foundation

// MARK: - Convert Data → Multibase Hex String
func dataToMultibaseHex(_ data: Data) -> String {
    let hexString = data.map { String(format: "%02x", $0) }.joined()
    return "0x" + hexString // Multibase prefix for hex
}

// MARK: - Convert Multibase Hex String → Data
func multibaseHexToData(_ multibase: String) -> Data? {
    guard multibase.hasPrefix("0x") else { return nil }
    let hex = String(multibase.dropFirst(2))
    return Data(hexString: hex)
}

// MARK: - Helper: Hex String → Data
extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var index = hexString.startIndex

        for _ in 0..<len {
            let nextIndex = hexString.index(index, offsetBy: 2)
            guard nextIndex <= hexString.endIndex else { return nil }
            let byteString = hexString[index..<nextIndex]
            guard let byte = UInt8(byteString, radix: 16) else { return nil }
            data.append(byte)
            index = nextIndex
        }

        self = data
    }
}
