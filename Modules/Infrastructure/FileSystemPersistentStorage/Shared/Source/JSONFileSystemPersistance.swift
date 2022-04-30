//
//  JSONFileSystemPersistance.swift
//  FileSystemPersistentStorage iOS
//
//  Created by Kertész Jenő Ármin on 2021. 12. 23..
//

import Foundation

public final class JSONFileSystemPersistance<T: Codable> {
    public let url: URL
    private let fileManager: FileManager
    private let provider: JSONFileSystemPersistanceProvider
    private lazy var jsonEncoder = JSONEncoder()
    private lazy var jsonDecoder = JSONDecoder()

    public init(fileName: String, fileManager: FileManager = .default, provider: JSONFileSystemPersistanceProvider) {
        self.fileManager = fileManager
        self.url = Self.makeURL(from: fileName, with: fileManager)!
        self.provider = provider
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
