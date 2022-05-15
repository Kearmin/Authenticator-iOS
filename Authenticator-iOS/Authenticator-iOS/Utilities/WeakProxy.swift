//
//  WeakBox.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 15..
//

import Foundation
import AddAccountView

class WeakProxy<Item: AnyObject> {
    weak var item: Item?

    init(_ item: Item?) {
        self.item = item
    }
}

extension WeakProxy: AddAccountViewDelegate where Item: AddAccountViewDelegate {
    func didFindQRCode(code: String) {
        item?.didFindQRCode(code: code)
    }

    func failedToStart() {
        item?.failedToStart()
    }
}
