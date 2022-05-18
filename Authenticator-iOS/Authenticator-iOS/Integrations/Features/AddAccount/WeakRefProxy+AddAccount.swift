//
//  WeakRefProxy+AddAccount.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 18..
//

import AddAccountView

extension WeakRefProxy: AddAccountViewDelegate where Item: AddAccountViewDelegate {
    func didFindQRCode(code: String) {
        item?.didFindQRCode(code: code)
    }

    func failedToStart() {
        item?.failedToStart()
    }
}
