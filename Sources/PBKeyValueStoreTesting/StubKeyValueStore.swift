//
//  Copyright © 2020 Peter Barclay. All rights reserved.
//

import Foundation
import PBKeyValueStore

public struct StubKeyValueStore: KeyValueStore {
    public func setValue(_ value: Data, forKey key: String) throws {}
    
    public func getValue(forKey key: String) throws -> Data { Data() }
    
    public func deleteValue(forKey key: String) throws {}
    
    public func deleteAllValues() throws {}
    
    public init() {}
}
