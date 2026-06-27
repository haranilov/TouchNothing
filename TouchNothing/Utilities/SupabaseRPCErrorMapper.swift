import Foundation
import Supabase

enum SupabaseRPCErrorMapper {
    private static let authErrorTokens: [String: SupabaseServiceError] = [
        "nickname_taken": .nicknameTaken,
        "invalid_credentials": .invalidCredentials(),
        "account_locked": .accountLocked,
        "invalid_pin": .invalidPin,
        "invalid_nickname": .invalidNickname,
        "invalid_session_token": .invalidSessionToken,
        "nickname_not_registered": .nicknameNotRegistered
    ]

    static func mapAuthErrorToken(_ token: String?) -> SupabaseServiceError? {
        guard let token else { return nil }
        return authErrorTokens[token]
    }

    static func map(_ error: Error) -> SupabaseServiceError {
        if let postgrestError = error as? PostgrestError {
            return mapMessage(postgrestError.message.lowercased())
        }

        let message = String(describing: error).lowercased()

        if isLikelyEmptyAuthResponse(error) {
            return .serverUpgradeRequired
        }

        return mapMessage(message)
    }

    static func isLikelyEmptyAuthResponse(_ error: Error) -> Bool {
        if error is DecodingError {
            return true
        }

        let message = String(describing: error).lowercased()
        return message.contains("decoding")
            || message.contains("correct format")
            || message.contains("unexpected end of file")
    }

    private static func mapMessage(_ message: String) -> SupabaseServiceError {
        for (token, error) in authErrorTokens where message.contains(token) {
            return error
        }

        if message.contains("function"), message.contains("does not exist") {
            return .serverUpgradeRequired
        }

        return .networkFailure
    }
}
