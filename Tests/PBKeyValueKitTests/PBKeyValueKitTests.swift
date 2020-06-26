//
//  Copyright © 2020 Peter Barclay. All rights reserved.
//

import XCTest
import PBKeyValueKit

final class PBKeyValueKitTests: XCTestCase {
    
    func test_KeyValueStore_isPublic() {
        typealias Store = KeyValueStore
    }
    
    func test_KeyValueStoreError_isPublic() {
        typealias StoreError = KeyValueStoreError
    }
    
    func test_InMemoryKeyValueStore_isPublic() {
        typealias Store = InMemoryKeyValueStore
    }
    
    func test_KeychainKeyValueStore_isPublic() {
        typealias Store = KeychainKeyValueStore
    }
}
