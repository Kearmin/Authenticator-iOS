//
//  SystemJSONFileSystemPersistanceProvider.swift
//  FileSystemPersistentStorage
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import Foundation

public class SystemJSONFileSystemPersistanceProvider: JSONFileSystemPersistanceProvider {
    let queue: DispatchQueue

    public init(queue: DispatchQueue) {
        self.queue = queue
    }

    public func save(_ data: Data, to url: URL) throws {
        try queue.sync {
            try data.write(to: url, options: .atomic)
        }
    }

    public func read(from url: URL) throws -> Data {
        try queue.sync {
            try Data(contentsOf: url)
        }
    }
}

extension JSONFileSystemPersistance {
    public convenience init(fileName: String, fileManager: FileManager = .default, queue: DispatchQueue, version: Int) {
        self.init(
            fileName: fileName,
            fileManager: fileManager,
            provider: SystemJSONFileSystemPersistanceProvider(queue: queue),
            version: version)
    }
}
