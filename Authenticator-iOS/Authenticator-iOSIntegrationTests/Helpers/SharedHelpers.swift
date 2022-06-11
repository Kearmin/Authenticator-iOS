//
//  SharedHelpers.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 11..
//

import Foundation
import XCTest

struct SomeError: Error {
    let message: String
}

func anError() -> NSError {
    .init(domain: "an error", code: 0)
}

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
