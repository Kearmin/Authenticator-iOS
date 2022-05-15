//
//  Threading.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 05. 14..
//

import Foundation

func onMain(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}

enum Queues {
    static let generalBackgroundQueue = DispatchQueue(label: "general.background", attributes: .concurrent)
    static let fileIOBackgroundQueue = DispatchQueue(label: "fileIO.background")
}
