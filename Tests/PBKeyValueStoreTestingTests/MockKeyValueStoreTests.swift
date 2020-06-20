//
//  Copyright © 2020 Peter Barclay. All rights reserved.
//

import XCTest
import PBKeyValueStoreTesting

final class MockKeyValueStoreTests: XCTestCase {
    typealias SUT = MockKeyValueStore
    
    private struct TestError: Error {}

    private let anyKey = "any-key"
    
    private var data: (String?) -> Data = { ($0 ?? "").data(using: .utf8)! }

    // MARK: - setValue
    
    func test_calls_setValue_shouldReturnCallHistory() {
        let sut = makeSUT()

        try? sut.setValue(data("1"), forKey: "key 1")
        try? sut.setValue(data("2"), forKey: "key 2")

        XCTAssertEqual(sut.calls_setValue.count, 2)
        XCTAssertEqual(sut.calls_setValue[0].data, data("1"))
        XCTAssertEqual(sut.calls_setValue[0].key, "key 1")
        XCTAssertEqual(sut.calls_setValue[1].data, data("2"))
        XCTAssertEqual(sut.calls_setValue[1].key, "key 2")
    }
    
    func test_setValue_whenNoReturnSet_shouldThrow() throws {
        let sut = makeSUT()
        
        XCTAssertThrowsError(
            try sut.setValue(Data(), forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is MockKeyValueStore.NoMockReturnValue)
        }
    }
    
    func test_setValue_whenEmptyReturnSet_shouldThrow() throws {
        let sut = makeSUT(return_setValue: [])
        
        XCTAssertThrowsError(
            try sut.setValue(Data(), forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is MockKeyValueStore.NoMockReturnValue)
        }
    }
    
    func test_setValue_whenReturnSetWithFailure_shouldThrow() throws {
        let sut = makeSUT(return_setValue: [
            Result<Void, Error>.failure(TestError())
        ])
        
        XCTAssertThrowsError(
            try sut.setValue(Data(), forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is TestError)
        }
    }

    func test_setValue_whenReturnSetWithSuccess_shouldNotThrow() throws {
        let sut = makeSUT(return_setValue: [
            Result<Void, Error>.success(())
        ])
        
        XCTAssertNoThrow(
            try sut.setValue(Data(), forKey: anyKey)
        )
    }
    
    func test_setValue_whenMultipleReturnSet() throws {
        let sut = makeSUT(return_setValue: [
            Result<Void, Error>.success(()),
            Result<Void, Error>.failure(TestError()),
            Result<Void, Error>.success(())
        ])
        
        XCTAssertNoThrow(
            try sut.setValue(Data(), forKey: anyKey)
        )
        
        XCTAssertThrowsError(
            try sut.setValue(Data(), forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is TestError)
        }

        XCTAssertNoThrow(
            try sut.setValue(Data(), forKey: anyKey)
        )
        
        XCTAssertThrowsError(
            try sut.setValue(Data(), forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is MockKeyValueStore.NoMockReturnValue)
        }
    }
    
    // MARK: - getValue
    
    func test_calls_getValue_shouldReturnCallHistory() {
        let sut = makeSUT()

        _ = try? sut.getValue(forKey: "key 1")
        _ = try? sut.getValue(forKey: "key 2")
        _ = try? sut.getValue(forKey: "key 3")

        XCTAssertEqual(sut.calls_getValue, ["key 1", "key 2", "key 3"])
    }
    
    func test_getValue_whenNoReturnSet_shouldThrow() throws {
        let sut = makeSUT()
        
        XCTAssertThrowsError(
            _ = try sut.getValue(forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is MockKeyValueStore.NoMockReturnValue)
        }
    }
    
    func test_getValue_whenEmptyReturnSet_shouldThrow() throws {
        let sut = makeSUT(return_getValue: [])
        
        XCTAssertThrowsError(
            _ = try sut.getValue(forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is MockKeyValueStore.NoMockReturnValue)
        }
    }
    
    func test_getValue_whenReturnSetWithFailure_shouldThrow() throws {
        let sut = makeSUT(return_getValue: [
            Result<Data, Error>.failure(TestError())
        ])
        
        XCTAssertThrowsError(
            _ = try sut.getValue(forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is TestError)
        }
    }

    func test_getValue_whenReturnSetWithSuccess_shouldReturnData() throws {
        let expected = data("expected data")
        let sut = makeSUT(return_getValue: [
            Result<Data, Error>.success(expected)
        ])
        
        do {
            let value = try sut.getValue(forKey: anyKey)
            XCTAssertEqual(value, expected)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_getValue_whenMultipleReturnSet() throws {
        let sut = makeSUT(return_getValue: [
            Result<Data, Error>.success(data("1")),
            Result<Data, Error>.failure(TestError()),
            Result<Data, Error>.success(data("2"))
        ])
        
        do {
            let value = try sut.getValue(forKey: anyKey)
            XCTAssertEqual(value, data("1"))
        } catch {
            XCTFail("\(error)")
        }
        
        XCTAssertThrowsError(
            _ = try sut.getValue(forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is TestError)
        }

        do {
            let value = try sut.getValue(forKey: anyKey)
            XCTAssertEqual(value, data("2"))
        } catch {
            XCTFail("\(error)")
        }

        XCTAssertThrowsError(
            try sut.getValue(forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is MockKeyValueStore.NoMockReturnValue)
        }
    }
    
    // MARK: - deleteValue
    
    func test_calls_deleteValue_shouldReturnCallHistory() {
        let sut = makeSUT()

        try? sut.deleteValue(forKey: "key 1")
        try? sut.deleteValue(forKey: "key 2")

        XCTAssertEqual(sut.calls_deleteValue, ["key 1", "key 2"])
    }
    
    func test_deleteValue_whenNoReturnSet_shouldThrow() throws {
        let sut = makeSUT()
        
        XCTAssertThrowsError(
            try sut.deleteValue(forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is MockKeyValueStore.NoMockReturnValue)
        }
    }
    
    func test_deleteValue_whenEmptyReturnSet_shouldThrow() throws {
        let sut = makeSUT(return_deleteValue: [])
        
        XCTAssertThrowsError(
            try sut.deleteValue(forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is MockKeyValueStore.NoMockReturnValue)
        }
    }
    
    func test_deleteValue_whenReturnSetWithFailure_shouldThrow() throws {
        let sut = makeSUT(return_deleteValue: [
            Result<Void, Error>.failure(TestError())
        ])
        
        XCTAssertThrowsError(
            try sut.deleteValue(forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is TestError)
        }
    }

    func test_deleteValue_whenReturnSetWithSuccess_shouldNotThrow() throws {
        let sut = makeSUT(return_deleteValue: [
            Result<Void, Error>.success(())
        ])
        
        XCTAssertNoThrow(
            try sut.deleteValue(forKey: anyKey)
        )
    }
    
    func test_deleteValue_whenMultipleReturnSet() throws {
        let sut = makeSUT(return_deleteValue: [
            Result<Void, Error>.success(()),
            Result<Void, Error>.failure(TestError()),
            Result<Void, Error>.success(())
        ])
        
        XCTAssertNoThrow(
            try sut.deleteValue(forKey: anyKey)
        )
        
        XCTAssertThrowsError(
            try sut.deleteValue(forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is TestError)
        }

        XCTAssertNoThrow(
            try sut.deleteValue(forKey: anyKey)
        )
        
        XCTAssertThrowsError(
            try sut.deleteValue(forKey: anyKey)
        ) { error in
            XCTAssertTrue(error is MockKeyValueStore.NoMockReturnValue)
        }
    }
    
    // MARK: - deleteAllValues
    
    func test_calls_deleteAllValues_shouldReturnCallHistory() {
        let sut = makeSUT()

        try? sut.deleteAllValues()
        try? sut.deleteAllValues()
        try? sut.deleteAllValues()
        try? sut.deleteAllValues()

        XCTAssertEqual(sut.calls_deleteAllValues.count, 4)
    }
    
    func test_deleteAllValues_whenNoReturnSet_shouldThrow() throws {
        let sut = makeSUT()
        
        XCTAssertThrowsError(
            try sut.deleteAllValues()
        ) { error in
            XCTAssertTrue(error is MockKeyValueStore.NoMockReturnValue)
        }
    }
    
    func test_deleteAllValues_whenEmptyReturnSet_shouldThrow() throws {
        let sut = makeSUT(return_deleteAllValues: [])
        
        XCTAssertThrowsError(
            try sut.deleteAllValues()
        ) { error in
            XCTAssertTrue(error is MockKeyValueStore.NoMockReturnValue)
        }
    }
    
    func test_deleteAllValues_whenReturnSetWithFailure_shouldThrow() throws {
        let sut = makeSUT(return_deleteAllValues: [
            Result<Void, Error>.failure(TestError())
        ])
        
        XCTAssertThrowsError(
            try sut.deleteAllValues()
        ) { error in
            XCTAssertTrue(error is TestError)
        }
    }

    func test_deleteAllValues_whenReturnSetWithSuccess_shouldNotThrow() throws {
        let sut = makeSUT(return_deleteAllValues: [
            Result<Void, Error>.success(())
        ])
        
        XCTAssertNoThrow(
            try sut.deleteAllValues()
        )
    }
    
    func test_deleteAllValues_whenMultipleReturnSet() throws {
        let sut = makeSUT(return_deleteAllValues: [
            Result<Void, Error>.success(()),
            Result<Void, Error>.failure(TestError()),
            Result<Void, Error>.success(())
        ])
        
        XCTAssertNoThrow(
            try sut.deleteAllValues()
        )
        
        XCTAssertThrowsError(
            try sut.deleteAllValues()
        ) { error in
            XCTAssertTrue(error is TestError)
        }

        XCTAssertNoThrow(
            try sut.deleteAllValues()
        )
        
        XCTAssertThrowsError(
            try sut.deleteAllValues()
        ) { error in
            XCTAssertTrue(error is MockKeyValueStore.NoMockReturnValue)
        }
    }
}

// MARK: - Helpers

extension MockKeyValueStoreTests {
    
    func makeSUT(
        return_setValue: [Result<Void, Error>]? = nil,
        return_getValue: [Result<Data, Error>]? = nil,
        return_deleteValue: [Result<Void, Error>]? = nil,
        return_deleteAllValues: [Result<Void,Error>]? = nil
    ) -> SUT {
        let sut = SUT()
        
        if let results = return_setValue {
            sut.return_setValue = results
        }
        
        if let results = return_getValue {
            sut.return_getValue = results
        }
        
        if let results = return_deleteValue {
            sut.return_deleteValue = results
        }
        
        if let results = return_deleteAllValues {
            sut.return_deleteAllValues = results
        }
        
        return sut
    }
}
