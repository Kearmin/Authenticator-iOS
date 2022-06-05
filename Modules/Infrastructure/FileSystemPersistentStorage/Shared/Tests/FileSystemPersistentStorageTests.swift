// swiftlint:disable all
//  FileSystemPersistentStorageTests.swift
//  FileSystemPersistentStorageTests
//
//  Created by Kertész Jenő Ármin on 2021. 12. 23..
//

import XCTest
import FileSystemPersistentStorage

class FileSystemPersistentStorageTests: XCTestCase {

    func test_canSaveData() throws {
        let (sut, spy) = try makeSUT()
        try sut.save(MockObject(value: 0, value2: ""))
        let savedData = try XCTUnwrap(spy.saved?.0)
        let savedObject = try XCTUnwrap(try? JSONDecoder().decode(MockObject.self, from: savedData))
        XCTAssertEqual(savedObject.value, 0)
        XCTAssertEqual(savedObject.value2, "")
    }

    func test_saveURL_isCorrect() throws {
        let (sut, spy) = try makeSUT()
        try sut.save(MockObject(value: 0, value2: ""))
        let savedURL = try XCTUnwrap(spy.saved?.1)
        XCTAssertEqual("https://www.google.com/test.json", savedURL.absoluteString)
    }

    func test_canReadData() throws {
        let (sut, spy) = try makeSUT()
        spy.readResult = try? JSONEncoder().encode(MockObject(value: 0, value2: ""))
        let result = try sut.read()
        XCTAssertEqual(result.value, 0)
        XCTAssertEqual(result.value2, "")
    }

    func test_canRunEligibleMigration() throws {
        let (sut, spy) = try makeSUT(version: 0)
        spy.readResult = try? JSONEncoder().encode(MockObject(value: 0, value2: ""))
        let migration = MockMigration(version: 10)
        XCTAssertNoThrow( try sut.runMigrations([migration]))
        XCTAssertEqual(migration.prepareCalls, 1)
        XCTAssertNotNil(spy.saved)
    }

    func test_wontRunNonEligibleMigrations() throws {
        let (sut, spy) = try makeSUT(version: 10)
        spy.readResult = try? JSONEncoder().encode(MockObject(value: 0, value2: ""))
        let migration = MockMigration(version: 0)
        let migration1 = MockMigration(version: 1)
        let migration2 = MockMigration(version: 2)
        let migration3 = MockMigration(version: 3)
        XCTAssertNoThrow( try sut.runMigrations([migration, migration1, migration2, migration3]))
        XCTAssertEqual(migration.prepareCalls, 0)
        XCTAssertNil(spy.saved)
    }

    func makeSUT(version: Int = 0) throws -> (sut: JSONFileSystemPersistance<MockObject>, spy: JSONFileSystemPersistanceProviderSpy) {
        let spy = JSONFileSystemPersistanceProviderSpy()
        let fileManagerStub = FileManagerStub()
        fileManagerStub.urlToReturn = URL(string: "https://www.google.com")
        let _sut = JSONFileSystemPersistance<MockObject>(fileName: "test", fileManager: fileManagerStub, provider: spy, version: version)
        let sut = try XCTUnwrap(_sut)
        return (sut: sut, spy: spy)
    }
}

class FileManagerStub: FileManager {
    var urlToReturn: URL!
    override func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return [urlToReturn]
    }
}

class MockMigration: JSONFileSystemPersistanceMigration {
    var version: Int
    var revertCalls = 0
    var prepareCalls = 0

    init(version: Int) {
        self.version = version
    }

    func prepare(on jsonObject: Any) -> Any {
        prepareCalls += 1
        return jsonObject
    }

    func revert(on jsonObject: Any) -> Any {
        revertCalls += 1
        return jsonObject
    }
}

class JSONFileSystemPersistanceProviderSpy: JSONFileSystemPersistanceProvider {
    var saved: (Data, URL)?
    var readResult: Data?

    func save(_ data: Data, to url: URL) {
        self.saved = (data, url)
    }

    func read(from url: URL) throws -> Data {
        guard let data = readResult else {
            throw TestError()
        }
        return data
    }
}

struct TestError: Error { }

struct MockObject: Codable {
    let value: Int
    let value2: String
}
