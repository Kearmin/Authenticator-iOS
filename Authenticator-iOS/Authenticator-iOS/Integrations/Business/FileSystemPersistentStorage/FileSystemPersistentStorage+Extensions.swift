//
//  FileSystemPersistentStorage+Extensions.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import FileSystemPersistentStorage
import AccountRepository
import Foundation
import AuthenticatorListBusiness

extension JSONFileSystemPersistance: RepositoryProvider where T == [AuthenticatorAccountModel] {
    public typealias Item = AuthenticatorAccountModel

    public func save(items: [AuthenticatorAccountModel]) throws {
        try save(items)
    }

    public func readItems() throws -> [AuthenticatorAccountModel] {
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
