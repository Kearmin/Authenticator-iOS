//
//  ImagesTests.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 15..
//

import XCTest
@testable import Authenticator_iOS

class ImagesTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_ImagesExist() {
        Images.allCases.forEach { imageCase in
            XCTAssertNotNil(imageCase.image)
        }
    }
}
