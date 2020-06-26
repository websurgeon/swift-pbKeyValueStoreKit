//
//  Copyright © 2020 Peter Barclay. All rights reserved.
//

import XCTest
@testable import PBKeyValueStoreKeychain

final class KeychainKeyValueStoreTests: XCTestCase {
    typealias SUT = KeychainKeyValueStore
    
    private var data: (String?) -> Data = { ($0 ?? "").data(using: .utf8)! }

    private let anyKey = "any-key"
    
    private let aKey = "a-key"
    
    private let anotherKey = "another-key"

    private var anyData: Data { data("any data") }
    
    private var someData: Data { data("some data") }
    
    private var someOtherData: Data { data("some other data") }
    
    // MARK: - setValue
    
    func test_setValue_shouldAddValueToKeychainAsGenericPassword() throws {
        let (sut, keychain) = makeSUT()
        
        try? sut.setValue(someData, forKey: aKey)
        
        XCTAssertEqual(keychain.calls_secItemAdd.count, 1)
        XCTAssertEqual(keychain.calls_secItemAdd.first?.attributes, [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: aKey,
            kSecValueData: someData
        ] as CFDictionary)
    }
    
    // MARK: - getValue
    
    func test_getValue_shouldCopyMatchingValueFromKeychain() throws {
        let (sut, keychain) = makeSUT()
        keychain.return_secItemCopyMatching = [(noErr, someData)]

        _ = try sut.getValue(forKey: aKey)

        XCTAssertEqual(keychain.calls_secItemCopyMatching.count, 1)
        XCTAssertEqual(keychain.calls_secItemCopyMatching.first?.query, [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: aKey,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary)
    }
    
    func test_getValue_whenNoValueInKeychainForKey_shouldThrowError() throws {
        let (sut, keychain) = makeSUT()
        keychain.return_secItemCopyMatching = [(123, nil)]
        
        XCTAssertThrowsError(
            _ = try sut.getValue(forKey: aKey)
        ) { error in
            switch error as? KeyValueStoreError {
            case let .noValueFound(key):
                XCTAssertEqual(key, aKey)
            default: XCTFail("\(error)")
            }
        }
    }

    func test_getValue_whenValueInKeychainForKey_shouldReturnValueFromStore() throws {
        let (sut, keychain) = makeSUT()
        keychain.return_secItemCopyMatching = [(noErr, someData)]

        let value = try sut.getValue(forKey: anyKey)

        XCTAssertEqual(value, someData)
    }

    // MARK: - deleteValue

    func test_deleteValue_whenNoValueInKeychainForKey_shouldThrowError() throws {
        let (sut, keychain) = makeSUT()
        keychain.return_secItemDelete = [123]

        XCTAssertThrowsError(
            try sut.deleteValue(forKey: aKey)
        ) { error in
            switch error as? KeyValueStoreError {
            case let .noValueFound(key):
                XCTAssertEqual(key, aKey)
            default: XCTFail("\(error)")
            }
        }
    }

    func test_deleteValue_whenValueInKeychainForKey_shouldRemoveValueFromKeychain() throws {
        let (sut, keychain) = makeSUT()

        try sut.deleteValue(forKey: aKey)

        XCTAssertEqual(keychain.calls_secItemDelete.count, 1)
        XCTAssertEqual(keychain.calls_secItemDelete.first, [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: aKey
        ] as CFDictionary)
    }

    // MARK: - deleteAllValues

    func test_deleteAllValues_shouldRemoveAllValues() throws {
        let (sut, keychain) = makeSUT()

        try sut.deleteAllValues()

        XCTAssertEqual(keychain.calls_secItemDelete.count, 1)
        XCTAssertEqual(keychain.calls_secItemDelete.first, [
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary)
    }
    
    // MARK: - Real Keychain Tests
    
    func test_shouldUseRealKeychainByDefault() throws {
        let sut = KeychainKeyValueStore()
        
        XCTAssertNotNil(sut.keychain as? RealKeychain)
    }
    
    func test_realKeychainStorageWorks() throws {
        let sut = KeychainKeyValueStore()

        let key1 = "test.exampleKey1"
        let key2 = "test.exampleKey2"
        let key3 = "test.exampleKey3"

        addTeardownBlock {
            let store = KeychainKeyValueStore()
            try? store.deleteValue(forKey: key1)
            try? store.deleteValue(forKey: key2)
            try? store.deleteValue(forKey: key3)
        }
        
        do {
            _ = try sut.getValue(forKey: key1)
        } catch {
            switch error as? KeyValueStoreError {
            case let .noValueFound(key):
                XCTAssertEqual(key, key1)
            default: XCTFail("\(error)")
            }
        }

        try sut.setValue(someData, forKey: key1)
        try sut.setValue(someOtherData, forKey: key2)
        
        let value1 = try sut.getValue(forKey: key1)
        let value2 = try sut.getValue(forKey: key2)

        XCTAssertEqual(value1, someData)
        XCTAssertEqual(value2, someOtherData)
        
        try sut.setValue(data("changed data"), forKey: key1)
        let changedValue1 = try sut.getValue(forKey: key1)
        
        XCTAssertEqual(changedValue1, data("changed data"))
        XCTAssertEqual(value2, someOtherData)

        do {
            _ = try sut.deleteValue(forKey: key3)
        } catch {
          switch error as? KeyValueStoreError {
          case let .noValueFound(key):
              XCTAssertEqual(key, key3)
          default: XCTFail("\(error)")
          }
        }

        try sut.deleteValue(forKey: key1)
        try sut.deleteValue(forKey: key2)
    }
}

extension KeychainKeyValueStoreTests {
    
    func makeSUT(store: [String: Data]? = nil) -> (SUT, MockKeychain) {
        let keychain = MockKeychain()
        
        return (KeychainKeyValueStore(keychain: keychain), keychain)
    }
}

public class MockKeychain: KeychainProtocol {
    public var calls_secItemAdd: [(
        attributes: CFDictionary,
        result: UnsafeMutablePointer<CFTypeRef?>?
    )] = []
    
    public var calls_secItemDelete: [CFDictionary] = []
    
    public var calls_secItemCopyMatching: [(
        query: CFDictionary,
        result: UnsafeMutablePointer<CFTypeRef?>?
    )] = []

    public var return_secItemAdd: [OSStatus] = []

    public var return_secItemDelete: [OSStatus] = []
    
    public var return_secItemCopyMatching: [(OSStatus, Data?)] = []

    public init() {}
    
    public func secItemAdd(
        _ attributes: CFDictionary,
        _ result: UnsafeMutablePointer<CFTypeRef?>?
    ) -> OSStatus {
        calls_secItemAdd.append((attributes, result))
        
        return return_secItemAdd.isEmpty ? noErr : return_secItemAdd.removeFirst()
    }
    
    public func secItemDelete(_ query: CFDictionary) -> OSStatus {
        calls_secItemDelete.append(query)

        return return_secItemDelete.isEmpty ? noErr : return_secItemDelete.removeFirst()
    }
    
    public func secItemCopyMatching(
        _ query: CFDictionary,
        _ result: UnsafeMutablePointer<CFTypeRef?>?
    ) -> OSStatus {
        calls_secItemCopyMatching.append((query, result))
        
        let (status, data) = return_secItemCopyMatching.isEmpty ? (noErr, nil) : return_secItemCopyMatching.removeFirst()
        
        if let value = data {
            result?.pointee = value as CFTypeRef
        }
        
        return status
    }
}
