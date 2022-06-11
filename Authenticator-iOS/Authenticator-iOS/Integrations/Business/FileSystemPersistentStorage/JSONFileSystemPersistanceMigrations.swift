//
//  JSONFileSystemPersistanceMigrations.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 06. 11..
//

import FileSystemPersistentStorage

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

class AddTimeStampMigration: JSONFileSystemPersistanceMigration {
    var version: Int = 3

    var timestamp = Date().timeIntervalSince1970

    func prepare(on jsonObject: Any) -> Any {
        guard var jsonArray = jsonObject as? [[String: Any]] else { return jsonObject }
        for i in jsonArray.indices {
            jsonArray[i]["createdAt"] = timestamp
        }
        return jsonArray
    }

    func revert(on jsonObject: Any) -> Any {
        guard var jsonArray = jsonObject as? [[String: Any]] else { return jsonObject }
        for i in jsonArray.indices {
            jsonArray[i].removeValue(forKey: "createdAt")
        }
        return jsonArray
    }
}
