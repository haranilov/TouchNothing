import Foundation

enum NicknameValidationError {
    case empty
    case invalidLength
    case invalidCharacters
}

enum NicknameValidator {
    private static let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))

    static func validate(_ nickname: String) -> NicknameValidationError? {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return .empty
        }
        if trimmed.count < AppConstants.minNicknameLength || trimmed.count > AppConstants.maxNicknameLength {
            return .invalidLength
        }
        if trimmed.unicodeScalars.contains(where: { !allowedCharacters.contains($0) }) {
            return .invalidCharacters
        }
        return nil
    }

    static func normalized(_ nickname: String) -> String {
        nickname.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
