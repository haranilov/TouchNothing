import Foundation

enum AuthMode: String, CaseIterable {
    case register
    case signIn
    case guest

    var title: String {
        switch self {
        case .register:
            return LocalizationKey.authModeRegister.localized
        case .signIn:
            return LocalizationKey.authModeSignIn.localized
        case .guest:
            return LocalizationKey.authModeGuest.localized
        }
    }

    var isGuest: Bool {
        self == .guest
    }
}
