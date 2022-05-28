//
//  JSONFileSystemPersistance.swift
//  FileSystemPersistentStorage iOS
//
//  Created by Kertész Jenő Ármin on 2021. 12. 23..
//

import Foundation

public protocol JSONFileSystemPersistanceMigration {
    var version: Int { get }
    func prepare(on jsonObject: Any) -> Any
    func revert(on jsonObject: Any) -> Any
}

public final class JSONFileSystemPersistance<T: Codable> {
    public let url: URL
    public let provider: JSONFileSystemPersistanceProvider
    private let fileManager: FileManager
    private let version: Int
    private lazy var jsonEncoder = JSONEncoder()
    private lazy var jsonDecoder = JSONDecoder()

    public init(
        fileName: String,
        fileManager: FileManager = .default,
        provider: JSONFileSystemPersistanceProvider,
        version: Int
    ) {
        self.fileManager = fileManager
        self.url = Self.makeURL(from: fileName, with: fileManager)! // swiftlint:disable:this force_unwrapping
        self.provider = provider
        self.version = version
    }

    public func runMigrations(_ migrations: [JSONFileSystemPersistanceMigration]) throws -> Int {
        let eligibleMigrations = migrations.filter { $0.version > self.version }
        guard !eligibleMigrations.isEmpty else { return 0 }
        let data = try provider.read(from: url)
        var jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        eligibleMigrations.forEach { migration in
            jsonObject = migration.prepare(on: jsonObject)
        }
        let newData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        try provider.save(newData, to: url)
        return eligibleMigrations.count
    }

    public func save(_ object: T) throws {
        let data = try jsonEncoder.encode(object)
        try provider.save(data, to: url)
    }

    public func read() throws -> T {
        let data = try provider.read(from: url)
        return try jsonDecoder.decode(T.self, from: data)
    }

    private static func makeURL(from name: String, with fileManager: FileManager) -> URL? {
        let documentsDirectories = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first
        return documentDirectory?.appendingPathComponent("\(name).json")
    }
}
