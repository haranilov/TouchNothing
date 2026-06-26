import Foundation
import Supabase

enum SupabaseRPCErrorMapper {
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
        if message.contains("nickname_taken") {
            return .nicknameTaken
        }
        if message.contains("invalid_credentials") {
            return .invalidCredentials
        }
        if message.contains("account_locked") {
            return .accountLocked
        }
        if message.contains("invalid_pin") {
            return .invalidPin
        }
        if message.contains("invalid_nickname") {
            return .invalidNickname
        }
        if message.contains("invalid_session_token") {
            return .invalidSessionToken
        }
        if message.contains("nickname_not_registered") {
            return .nicknameNotRegistered
        }
        if message.contains("function") && message.contains("does not exist") {
            return .serverUpgradeRequired
        }

        return .networkFailure
    }
}
