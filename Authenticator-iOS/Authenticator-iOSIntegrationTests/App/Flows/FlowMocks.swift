//
//  FlowMocks.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 17..
//

import Foundation
@testable import Authenticator_iOS
import UIKit

class ShowErrorFlowSpy: ShowErrorFlow {
    var capturedContext: ErrorContext?
    var capturedSource: UIViewController?

    override func start(context: ErrorContext, source: UIViewController?) {
        capturedSource = source
        capturedContext = context
    }
}
