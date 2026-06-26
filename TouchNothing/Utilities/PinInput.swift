import Foundation

enum PinInput {
    static func sanitize(_ value: String) -> String {
        String(value.filter(\.isNumber).prefix(AppConstants.pinLength))
    }

    static func isValid(_ value: String) -> Bool {
        value.count == AppConstants.pinLength && value.allSatisfy(\.isNumber)
    }

    static func randomPin() -> String {
        String(format: "%04d", Int.random(in: 0...9_999))
    }
}
