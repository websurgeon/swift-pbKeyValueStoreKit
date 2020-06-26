//
//  Copyright © 2020 Peter Barclay. All rights reserved.
//

import Foundation
import Security
import PBKeyValueStore

public typealias KeyValueStoreError = PBKeyValueStore.KeyValueStoreError

public class KeychainKeyValueStore: KeyValueStore {
    internal let keychain: KeychainProtocol
    
    internal init(keychain: KeychainProtocol) {
        self.keychain = keychain
    }

    public convenience init() {
        self.init(keychain: RealKeychain())
    }
}

extension KeychainKeyValueStore {
    public func setValue(_ value: Data, forKey key: String) throws {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: value
        ] as CFDictionary
        
        _ = try? deleteValue(forKey: key)
        
        guard keychain.secItemAdd(query, nil) == noErr else {
            throw KeyValueStoreError.noValueFound(key: key)
        }
    }
    
    public func getValue(forKey key: String) throws -> Data {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var result: AnyObject?
        let status = keychain.secItemCopyMatching(query, &result)
        
        guard status == noErr, let value = result as? Data else {
            throw KeyValueStoreError.noValueFound(key: key)
        }

        return value
    }
    
    public func deleteValue(forKey key: String) throws {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
        ] as CFDictionary
        
        let status = keychain.secItemDelete(query)
        
        guard status == noErr else {
            throw KeyValueStoreError.noValueFound(key: key)
        }
    }
    
    public func deleteAllValues() throws {
        let query = [
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        let status = keychain.secItemDelete(query)
        
        guard status == noErr else {
            throw KeyValueStoreError.unhandled
        }
    }
}

internal protocol KeychainProtocol {
    func secItemAdd(
        _ attributes: CFDictionary,
        _ result: UnsafeMutablePointer<CFTypeRef?>?
    ) -> OSStatus
    
    func secItemDelete(_ query: CFDictionary) -> OSStatus
    
    func secItemCopyMatching(_ query: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus
}

internal struct RealKeychain: KeychainProtocol {
    public init() {}
    
    public func secItemAdd(
        _ attributes: CFDictionary,
        _ result: UnsafeMutablePointer<CFTypeRef?>?
    ) -> OSStatus {
        return SecItemAdd(attributes, result)
    }
    
    public func secItemDelete(_ query: CFDictionary) -> OSStatus {
        return SecItemDelete(query)
    }
    
    public func secItemCopyMatching(
        _ query: CFDictionary,
        _ result: UnsafeMutablePointer<CFTypeRef?>?
    ) -> OSStatus {
        return SecItemCopyMatching(query, result)
    }
}
