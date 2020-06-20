//
//  Copyright © 2020 Peter Barclay. All rights reserved.
//

import XCTest
@testable import PBKeyValueStoreInMemory

final class InMemoryKeyValueStoreTests: XCTestCase {
    typealias SUT = InMemoryKeyValueStore
    
    private var data: (String?) -> Data = { ($0 ?? "").data(using: .utf8)! }

    private let anyKey = "any-key"
    
    private let aKey = "a-key"
    
    private let anotherKey = "another-key"

    private var anyData: Data { data("any data") }
    
    private var someData: Data { data("some data") }
    
    private var someOtherData: Data { data("some other data") }
    
    // MARK: - setValue
    
    func test_setValue_shouldAddValueToStoreUsingKey() throws {
        let sut = makeSUT()
        
        try? sut.setValue(someData, forKey: aKey)
        
        XCTAssertEqual(sut.store[aKey], someData)
    }
    
    // MARK: - getValue
    
    func test_getValue_whenNoValueInStoreForKey_shouldThrowError() throws {
        let sut = makeSUT(store: [aKey : someData])
        
        XCTAssertThrowsError(
            _ = try sut.getValue(forKey: anotherKey)
        ) { error in
            switch error as? KeyValueStoreError {
            case let .noValueFound(key):
                XCTAssertEqual(key, anotherKey)
            default: XCTFail("\(error)")
            }
        }
    }
    
    func test_getValue_whenValueInStoreForKey_shouldReturnValueFromStore() throws {
        let sut = makeSUT(store: [
            aKey : someData,
            anotherKey : someOtherData
        ])
        
        let value = try sut.getValue(forKey: aKey)
        
        XCTAssertEqual(value, someData)
    }
    
    // MARK: - deleteValue
    
    func test_deleteValue_whenNoValueInStoreForKey_shouldThrowError() throws {
        let sut = makeSUT(store: [aKey : someData])
        
        XCTAssertThrowsError(
            try sut.deleteValue(forKey: anotherKey)
        ) { error in
            switch error as? KeyValueStoreError {
            case let .noValueFound(key):
                XCTAssertEqual(key, anotherKey)
            default: XCTFail("\(error)")
            }
        }
    }
    
    func test_deleteValue_whenValueInStoreForKey_shouldRemoveValueFromStore() throws {
        let sut = makeSUT(store: [
            aKey : someData,
            anotherKey : someOtherData
        ])
        
        try sut.deleteValue(forKey: aKey)
        
        XCTAssertEqual(sut.store, [anotherKey : someOtherData])
    }
    
    // MARK: - deleteAllValues
    
    func test_deleteAllValues_shouldRemoveAllValues() throws {
        let sut = makeSUT(store: [
            aKey : someData,
            anotherKey : someOtherData
        ])
        
        try sut.deleteAllValues()
        
        XCTAssertEqual(sut.store, [:])
    }
}

extension InMemoryKeyValueStoreTests {
    
    func makeSUT(store: [String: Data]? = nil) -> SUT {
        return InMemoryKeyValueStore(store: store)
    }
}
