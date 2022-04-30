//
//  JSONFileSystemPersistanceProvider.swift
//  FileSystemPersistentStorage
//
//  Created by Kertész Jenő Ármin on 2022. 04. 22..
//

import Foundation

public protocol JSONFileSystemPersistanceProvider {
    func save(_ data: Data, to url: URL) throws
    func read(from url: URL) throws -> Data
}
