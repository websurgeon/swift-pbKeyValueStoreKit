//
//  Copyright © 2020 Peter Barclay. All rights reserved.
//

import XCTest

import PBKeyValueStore
import PBKeyValueStoreTesting

final class PBKeyValueStoreTests: XCTestCase {
    private let sut: KeyValueStore = StubKeyValueStore()

    private let anyKey = "any-key"
    
    // MARK: - Public Interface
    
    func test_setValue() {
        try? sut.setValue(Data(), forKey: anyKey)
    }
    
    func test_getValue() {
        _ = try? sut.getValue(forKey: anyKey)
    }
    
    func test_deleteValue() {
        try? sut.deleteValue(forKey: anyKey)
    }
    
    func test_deleteAllValues() {
        try? sut.deleteAllValues()
    }
}
