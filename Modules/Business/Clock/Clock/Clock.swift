//
//  Clock.swift
//  Authenticator-iOS
//
//  Created by Kertész Jenő Ármin on 2022. 04. 24..
//

import Foundation

public protocol ClockObserver: AnyObject {
    func handle(currentDate: Date)
}

public final class Clock {
    private var timer: Timer?
    private var observers: [ClockObserver] = []

    public init(timeInterval: TimeInterval = 1) {
        self.timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] _ in
            self?.notifyObservers(currentDate: Date())
        }
        RunLoop.main.add(self.timer!, forMode: .common) // swiftlint:disable:this force_unwrapping
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    public func notifyObservers(currentDate: Date) {
        observers.forEach { $0.handle(currentDate: currentDate) }
    }

    public func addObserver(_ observer: ClockObserver) {
        observers.append(observer)
        observer.handle(currentDate: Date())
    }

    public func removeObserver(_ observer: ClockObserver) {
        observers.removeAll { $0 === observer }
    }

    public func containsObserver(_ observer: ClockObserver) -> Bool {
        observers.contains { $0 === observer }
    }
}
