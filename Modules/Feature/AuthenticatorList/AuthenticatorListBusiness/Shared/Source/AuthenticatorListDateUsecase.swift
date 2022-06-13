//
//  AuthenticatorListDateUsecase.swift
//  AuthenticatorListBusiness
//
//  Created by Kertész Jenő Ármin on 2022. 06. 13..
//

import Foundation

class AuthenticatorListDateUsecase {
    struct UpdateDateResult {
        let countDown: Int
        let needsRefresh: Bool
    }

    private(set) var latestDate: Date?
    let cycleLength: Int

    init(cycleLength: Int) {
        self.cycleLength = cycleLength
    }

    func needsRefresh(date: Date = Date()) -> Bool {
        guard let latestDate = latestDate else { return false }
        let countDown = latestDate.countDownValue(cycleLength: cycleLength)
        if latestDate.timeIntervalSince1970 + Double(countDown) > date.timeIntervalSince1970 { return false }
        self.latestDate = date
        return true
    }

    func update(currentDate date: Date) -> UpdateDateResult {
        latestDate = date
        let countDown = date.countDownValue(cycleLength: cycleLength)
        return .init(
            countDown: countDown,
            needsRefresh: countDown == cycleLength)
    }

    var currentCountDown: Int? {
        guard let latestDate = latestDate else { return nil }
        return latestDate.countDownValue(cycleLength: cycleLength)
    }
}

private extension Date {
    func countDownValue(cycleLength: Int) -> Int {
        cycleLength - (Int(self.timeIntervalSince1970) % cycleLength)
    }
}
