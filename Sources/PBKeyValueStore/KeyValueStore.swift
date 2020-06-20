//
//  Copyright © 2020 Peter Barclay. All rights reserved.
//

import Foundation

public protocol KeyValueStore {
    
    func setValue(_ value: Data, forKey key: String) throws

    func getValue(forKey key: String) throws -> Data
    
    func deleteValue(forKey key: String) throws
    
    func deleteAllValues() throws
}

public enum KeyValueStoreError: Error {
    case noValueFound(key: String)
}
