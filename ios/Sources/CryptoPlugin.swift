//
//  CryptoPlugin.swift
//  tauri-plugin-crypto
//
//  Created by SoSweetHam on 05/05/25.
//

import SwiftRs
import Tauri
import UIKit
import WebKit
import Security

let access = SecAccessControlCreateWithFlags(
    kCFAllocatorDefault,
    kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
    [.privateKeyUsage],
    nil
)!

enum CryptoPluginError: Error {
    case keyExists
    case generationFailed
    case unknown
}

class IncludesIdentifier: Decodable {
    let identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
    }
}

// enum PublicKeyExportFormat: String, Decodable {
//     case hex
//     case uint8array
//     case base64
// }

// enum GetPublicKeyOutput {
//     case hex(String)
//     case uint8array([Int])
//     case base64(String)
    
//     func toAny() -> Any {
//         switch self {
//         case .hex(let value), .base64(let value):
//             return value
//         case .uint8array(let array):
//             return array
//         }
//     }
// }

//class GetPublicKeyArgs: IncludesIdentifier {
//    var format: PublicKeyExportFormat = .base64
//}

class CryptoPlugin: Plugin {
    private func buildKeyTag(from tag: String) -> Data? {
        guard let bundleID = Bundle.main.bundleIdentifier else { return nil }
        let fullTag = "\(bundleID).\(tag)"
        return fullTag.data(using: .utf8)
    }
    
    private func keyExistsInKeychain(tag: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecReturnRef as String: false
        ]
        
        return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
    }

    private func generateSecureEnclaveKey(tag: Data) throws {
        if keyExistsInKeychain(tag: tag) {
            throw CryptoPluginError.keyExists
        }

        var error: Unmanaged<CFError>?
        let attributes: NSDictionary = [
            kSecAttrKeyType: kSecAttrKeyTypeEC,
                kSecAttrKeySizeInBits: 256,
                kSecAttrTokenID: kSecAttrTokenIDSecureEnclave,
                kSecPrivateKeyAttrs: [
                    kSecAttrIsPermanent: true,
                    kSecAttrApplicationTag: tag,
                    kSecAttrAccessControl: access
                ]
        ]
        guard SecKeyCreateRandomKey(attributes, &error) != nil else {
            throw CryptoPluginError.generationFailed
        }
    }
    
    private func getPrivateKeyReference(tag: Data) throws -> SecKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecReturnRef as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
                throw CryptoPluginError.unknown
            }
            
        return (item as! SecKey)
    }
    
    private func getPublicKey(tag: Data) throws -> String {
        let privKeyRef = try getPrivateKeyReference(tag: tag)
        guard let publicKey = SecKeyCopyPublicKey(privKeyRef) else {
            throw CryptoPluginError.unknown
        }

        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            throw CryptoPluginError.unknown
        }
        
        // switch format {
        // case .hex:
        //     return .hex(publicKeyData.map { String(format: "%02x", $0) }.joined())
        // case .uint8array:
        //        return .uint8array(publicKeyData.map { Int($0) })
        // case .base64:
        //     return .base64(publicKeyData.base64EncodedString())
        // }
//         return publicKeyData.map { Int8($0) }
        return publicKeyData.base64EncodedString()
    }

    @objc public func generate(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(IncludesIdentifier.self)
        let tag = buildKeyTag(from: args.identifier)
        if tag == nil {
            invoke.reject("Invalid identifier provided")
            return
        }
        do {
            try generateSecureEnclaveKey(tag: tag!)
            invoke.resolve(["message": "Key generated successfully"])
            return
        } catch CryptoPluginError.keyExists {
            invoke.resolve(["message": "Key already exists"])
            return
        } catch {
            invoke.reject("Key generation failed")
            return
        }
    }

    @objc public func exists(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(IncludesIdentifier.self)
        let tag = buildKeyTag(from: args.identifier)
        if tag == nil {
            invoke.reject("Invalid identifier provided")
            return
        }
        let exists = keyExistsInKeychain(tag: tag!)
        invoke.resolve(["exists": exists])
    }
    
    @objc public func getPublicKey(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(IncludesIdentifier.self)
        let tag = buildKeyTag(from: args.identifier)
        if tag == nil {
            invoke.reject("Invalid identifier provided")
            return
        }
        let publicKeyData: String
        do {
            publicKeyData = try getPublicKey(tag: tag!)
        } catch {
            invoke.reject("Couldn't retrieve public key")
            return
        }
        invoke.resolve([
            "publicKey": publicKeyData,
        ])
    }
}

@_cdecl("init_plugin_crypto")
func initPlugin() -> Plugin {
    return CryptoPlugin()
}
