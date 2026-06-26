import Foundation

struct SessionTimer {
    let startDate: Date

    init(startDate: Date = Date()) {
        self.startDate = startDate
    }

    func elapsedSeconds(at endDate: Date = Date()) -> Int {
        let interval = endDate.timeIntervalSince(startDate)
        return max(0, Int(interval.rounded(.down)))
    }
}
