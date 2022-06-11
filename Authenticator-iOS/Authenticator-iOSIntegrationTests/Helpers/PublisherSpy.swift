//
//  PublisherSpy.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 11..
//

import Combine
import XCTest

class PublisherSpy<Output, Failure: Error> {
    private var cancellable: AnyCancellable?
    var results: [Result<Output, Failure>] = []

    var values: [Output] {
        results.compactMap { result in
            try? result.get()
        }
    }

    var resultCount: Int {
        results.count
    }

    init(_ publisher: AnyPublisher<Output, Failure>, expectation: XCTestExpectation? = nil) {
        cancellable = publisher
            .sink(receiveCompletion: { [unowned self] completion in
                switch completion {
                case .failure(let error):
                    results.append(.failure(error))
                default:
                    break
                }
            }, receiveValue: { [unowned self] output in
                self.results.append(.success(output))
                expectation?.fulfill()
            })
    }
}
