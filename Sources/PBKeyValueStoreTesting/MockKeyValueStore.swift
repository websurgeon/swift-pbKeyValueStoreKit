//
//  Copyright © 2020 Peter Barclay. All rights reserved.
//

import Foundation
import PBKeyValueStore

public class MockKeyValueStore: KeyValueStore {
    
    public struct NoMockReturnValue: Error {}
    
    public var calls_setValue: [(data: Data, key: String)] = []
    
    public var calls_getValue: [String] = []
    
    public var calls_deleteValue: [String] = []
    
    public var calls_deleteAllValues: [Void] = []
    
    public var return_setValue: [Result<Void, Error>] = []
    
    public var return_getValue: [Result<Data, Error>] = []
    
    public var return_deleteValue: [Result<Void, Error>] = []
    
    public var return_deleteAllValues: [Result<Void, Error>] = []
    
    public init() {}
}

// MARK: - KeyValueStore Conformance

extension MockKeyValueStore {
    
    public func setValue(_ value: Data, forKey key: String) throws {
        calls_setValue.append((value, key))
        
        guard return_setValue.isEmpty == false else {
            throw NoMockReturnValue()
        }
        
        switch return_setValue.removeFirst() {
        case let .failure(error): throw error
        case .success: break
        }
    }

    public func getValue(forKey key: String) throws -> Data {
        calls_getValue.append(key)

        guard return_getValue.isEmpty == false else {
            throw NoMockReturnValue()
        }

        switch return_getValue.removeFirst() {
        case let .failure(error): throw error
        case let .success(data): return data
        }
    }
    
    public func deleteValue(forKey key: String) throws {
        calls_deleteValue.append(key)

        guard return_deleteValue.isEmpty == false else {
            throw NoMockReturnValue()
        }

       switch return_deleteValue.removeFirst() {
       case let .failure(error): throw error
       case .success: break
       }
    }
    
    public func deleteAllValues() throws {
        calls_deleteAllValues.append(())
        
        guard return_deleteAllValues.isEmpty == false else {
            throw NoMockReturnValue()
        }
        
        switch return_deleteAllValues.removeFirst() {
        case let .failure(error): throw error
        case .success: break
        }
    }
}
