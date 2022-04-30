//
//  Queues.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import Foundation

enum Queues {
    static let generalBackgroundQueue = DispatchQueue(label: "app.general.background")
    static let fileIOBackgroundQueue = DispatchQueue(label: "app.fileIO.background")
}

func onMain(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}
