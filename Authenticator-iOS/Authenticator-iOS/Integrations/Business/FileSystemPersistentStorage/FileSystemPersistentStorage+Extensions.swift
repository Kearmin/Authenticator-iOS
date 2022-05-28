//
//  FileSystemPersistentStorage+Extensions.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import FileSystemPersistentStorage
import AccountRepository
import Foundation

extension JSONFileSystemPersistance: RepositoryProvider where T == [Account] {
    public typealias Item = Account

    public func save(items: [Account]) throws {
        try save(items)
    }

    public func readItems() throws -> [Account] {
        try read()
    }
}

class AddFavouriteMigration: JSONFileSystemPersistanceMigration {
    var version: Int = 1
    func prepare(on jsonObject: Any) -> Any {
        guard var jsonArray = jsonObject as? [[String: Any]] else { return jsonObject }
        for i in jsonArray.indices {
            jsonArray[i]["isFavourite"] = false
        }
        return jsonArray
    }

    func revert(on jsonObject: Any) -> Any {
        guard var jsonArray = jsonObject as? [[String: Any]] else { return jsonObject }
        for i in jsonArray.indices {
            jsonArray[i].removeValue(forKey: "isFavourite")
        }
        return jsonArray
    }
}
