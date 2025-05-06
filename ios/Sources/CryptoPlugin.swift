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
    case badPayload
    case badSignature
    case unknown
}

class IncludesIdentifier: Decodable {
    let identifier: String
}

class SignRequest: Decodable {
    let identifier: String
    let payload: String
}

class VerifySignatureRequest: Decodable {
    let identifier: String
    let payload: String
    let signature: String
}

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
        
        return publicKeyData.base64EncodedString()
    }
    
    private func _signPayload(tag: Data, payload: String) throws -> String {
        guard let data = payload.data(using: .utf8) else {
            throw CryptoPluginError.badPayload
        }
        
        let privKeyRef = try getPrivateKeyReference(tag: tag)
        var error: Unmanaged<CFError>?
        guard let signatureData = SecKeyCreateSignature(
            privKeyRef,
            .ecdsaSignatureMessageX962SHA256,
            data as CFData,
            &error
        ) as Data? else {
            throw CryptoPluginError.unknown
        }
        return signatureData.base64EncodedString()
    }
    
    private func _verifySignature(tag: Data, payload: String, signature: String) throws -> Bool {
        guard let payloadData = payload.data(using: .utf8) else {
            throw CryptoPluginError.badPayload
        }
        
        guard let signatureData = Data(base64Encoded: signature) else {
            throw CryptoPluginError.badSignature
        }
        
        let privKeyRef = try getPrivateKeyReference(tag: tag)
        var error: Unmanaged<CFError>?
        let result = SecKeyVerifySignature(
            privKeyRef,
            .ecdsaSignatureMessageX962SHA256,
            payloadData as CFData,
            signatureData as CFData,
            &error
        )
        return result
        
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
    
    @objc public func signPayload(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(SignRequest.self)
        let tag = buildKeyTag(from: args.identifier)
        if tag == nil {
            invoke.reject("Invalid identifier provided")
            return
        }
        let signature: String
        do {
            signature = try _signPayload(tag: tag!, payload: args.payload)
        } catch {
            invoke.reject("Couldn't create signature for the payload")
            return
        }
        invoke.resolve([
            "signature": signature
        ])
    }
    
    @objc public func verifySignature(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(VerifySignatureRequest.self)
        let tag = buildKeyTag(from: args.identifier)
        if tag == nil {
            invoke.reject("Invalid identifier provided")
            return
        }
        let result: Bool
        do {
            result = try _verifySignature(tag: tag!, payload: args.payload, signature: args.signature)
        } catch {
            invoke.reject("Couldn't verify payload")
            return
        }
        invoke.resolve([
            "valid": result
        ])
    }
}

@_cdecl("init_plugin_crypto")
func initPlugin() -> Plugin {
    return CryptoPlugin()
}
