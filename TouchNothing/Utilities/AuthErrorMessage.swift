import Foundation

enum AuthErrorMessage {
    static func message(for validationError: AuthValidationError) -> String {
        switch validationError {
        case .nickname(let nicknameError):
            return message(for: nicknameError)
        case .invalidPin:
            return LocalizationKey.authInvalidPin.localized
        case .pinMismatch:
            return LocalizationKey.authPinMismatch.localized
        }
    }

    static func message(for validationError: NicknameValidationError) -> String {
        switch validationError {
        case .empty:
            return LocalizationKey.nicknameEmpty.localized
        case .invalidLength:
            return LocalizationKey.nicknameInvalidLength.localized
        case .invalidCharacters:
            return LocalizationKey.nicknameInvalidCharacters.localized
        }
    }

    static func message(for serviceError: SupabaseServiceError) -> String {
        switch serviceError {
        case .nicknameTaken:
            return LocalizationKey.nicknameTaken.localized
        case .invalidCredentials:
            return LocalizationKey.authInvalidCredentials.localized
        case .accountLocked:
            return LocalizationKey.authAccountLocked.localized
        case .invalidPin:
            return LocalizationKey.authInvalidPin.localized
        case .invalidNickname:
            return LocalizationKey.nicknameInvalidLength.localized
        case .invalidSessionToken:
            return LocalizationKey.authSessionExpired.localized
        case .nicknameNotRegistered:
            return LocalizationKey.authInvalidCredentials.localized
        case .serverUpgradeRequired:
            return LocalizationKey.authServerUpgradeRequired.localized
        case .notConfigured, .networkFailure:
            return LocalizationKey.nicknameNetworkError.localized
        }
    }
}
