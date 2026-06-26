import Foundation

enum AuthService {
    static func validate(_ credentials: AuthCredentials) -> AuthValidationError? {
        let normalizedNickname = NicknameValidator.normalized(credentials.nickname)

        if let nicknameError = NicknameValidator.validate(normalizedNickname) {
            return .nickname(nicknameError)
        }

        switch credentials.mode {
        case .guest:
            return nil
        case .register, .signIn:
            if !PinInput.isValid(credentials.pin) {
                return .invalidPin
            }
            if credentials.mode == .register, credentials.pin != credentials.confirmPin {
                return .pinMismatch
            }
            return nil
        }
    }

    static func message(for validationError: AuthValidationError) -> String {
        switch validationError {
        case .nickname(let nicknameError):
            return AuthErrorMessage.message(for: nicknameError)
        case .invalidPin:
            return LocalizationKey.authInvalidPin.localized
        case .pinMismatch:
            return LocalizationKey.authPinMismatch.localized
        }
    }

    static func authenticate(_ credentials: AuthCredentials) async throws {
        let nickname = NicknameValidator.normalized(credentials.nickname)

        switch credentials.mode {
        case .register:
            let session = try await SupabaseService.shared.registerUser(
                nickname: nickname,
                pin: credentials.pin
            )
            LocalUserStore.saveSession(
                nickname: session.nickname,
                sessionToken: session.sessionToken,
                isGuest: false
            )
        case .signIn:
            let session = try await SupabaseService.shared.loginUser(
                nickname: nickname,
                pin: credentials.pin
            )
            LocalUserStore.saveSession(
                nickname: session.nickname,
                sessionToken: session.sessionToken,
                isGuest: false
            )
        case .guest:
            let guestPin = PinInput.randomPin()
            let session = try await SupabaseService.shared.registerUser(
                nickname: nickname,
                pin: guestPin
            )
            LocalUserStore.saveSession(
                nickname: session.nickname,
                sessionToken: session.sessionToken,
                isGuest: true,
                guestPin: guestPin
            )
        }
    }

    static func recoverGuestSession() async -> Bool {
        guard LocalUserStore.isGuest,
              let nickname = LocalUserStore.nickname,
              let guestPin = LocalUserStore.guestPin else {
            return false
        }

        do {
            let session = try await SupabaseService.shared.loginUser(nickname: nickname, pin: guestPin)
            LocalUserStore.nickname = session.nickname
            LocalUserStore.sessionToken = session.sessionToken
            return true
        } catch {
            return false
        }
    }
}
