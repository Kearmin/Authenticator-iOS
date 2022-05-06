//
//  TestHelpers.swift
//  Authenticator-iOSTests
//
//  Created by Kertész Jenő Ármin on 2022. 05. 04..
//

import Foundation
import XCTest

struct SomeError: Error, Equatable { }

extension Array {
    subscript(_ index: Int, onError: @autoclosure () -> Void) -> Element! {
        guard indices.contains(index) else {
            onError()
            return nil
        }
        return self[index]
    }
}
