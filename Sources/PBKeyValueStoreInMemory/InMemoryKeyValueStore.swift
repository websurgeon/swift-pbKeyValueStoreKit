//
//  Copyright © 2020 Peter Barclay. All rights reserved.
//

import Foundation
import PBKeyValueStore

public typealias KeyValueStoreError = PBKeyValueStore.KeyValueStoreError

public class InMemoryKeyValueStore: KeyValueStore {
    internal private(set) var store: [String: Data]
    
    public init(store: [String: Data]? = nil) {
        self.store = store ?? [:]
    }
}

extension InMemoryKeyValueStore {
    public func setValue(_ value: Data, forKey key: String) throws {
        store[key] = value
    }
    
    public func getValue(forKey key: String) throws -> Data {
        guard let value = store[key] else {
            throw KeyValueStoreError.noValueFound(key: key)
        }
        
        return value
    }
    
    public func deleteValue(forKey key: String) throws {
        let value = store.removeValue(forKey: key)
        
        if value == nil {
            throw KeyValueStoreError.noValueFound(key: key)
        }
    }
    
    public func deleteAllValues() throws {
        store.removeAll()
    }
}

func undefined<T>(
    _ message: String? = nil,
    inFile file: StaticString = #file,
    atLine line: UInt = #line
) -> T {
    fatalError(message ?? "implementation required", file: file, line: line)
}
