//
//  LoaderStub.swift
//  Authenticator-iOSIntegrationTests
//
//  Created by Kertész Jenő Ármin on 2022. 06. 11..
//

import Combine

class LoaderStub<Output, Failure: Error> {
    private var requests: [PassthroughSubject<Output, Failure>] = []

    var requestCallCount: Int {
        return requests.count
    }

    func startRequest() -> AnyPublisher<Output, Failure> {
        let publisher = PassthroughSubject<Output, Failure>()
        requests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }

    func completeLoadingWithError(with error: Failure, at index: Int = 0) {
        requests[index].send(completion: .failure(error))
    }

    func completeLoading(with output: Output, at index: Int = 0) {
        requests[index].send(output)
        requests[index].send(completion: .finished)
    }
}
