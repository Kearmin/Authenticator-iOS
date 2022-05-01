//
//  WeakBox.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 02..
//

import Foundation

class WeakBox<Item: AnyObject> {
    weak var item: Item?

    init(_ item: Item?) {
        self.item = item
    }
}
