import Foundation

enum LocalUserStore {
    static var nickname: String? {
        get {
            guard let raw = UserDefaults.standard.string(forKey: StorageKeys.nickname) else {
                return nil
            }
            let normalized = NicknameValidator.normalized(raw)
            return normalized.isEmpty ? nil : normalized
        }
        set { UserDefaults.standard.set(newValue, forKey: StorageKeys.nickname) }
    }

    static var sessionToken: String? {
        get {
            guard let token = UserDefaults.standard.string(forKey: StorageKeys.sessionToken) else {
                return nil
            }
            return token.isEmpty ? nil : token
        }
        set { UserDefaults.standard.set(newValue, forKey: StorageKeys.sessionToken) }
    }

    static var isGuest: Bool {
        get { UserDefaults.standard.bool(forKey: StorageKeys.isGuest) }
        set { UserDefaults.standard.set(newValue, forKey: StorageKeys.isGuest) }
    }

    static var guestPin: String? {
        get {
            guard let pin = UserDefaults.standard.string(forKey: StorageKeys.guestPin) else {
                return nil
            }
            return PinInput.isValid(pin) ? pin : nil
        }
        set { UserDefaults.standard.set(newValue, forKey: StorageKeys.guestPin) }
    }

    static var rulesHidden: Bool {
        get { UserDefaults.standard.bool(forKey: StorageKeys.rulesHidden) }
        set { UserDefaults.standard.set(newValue, forKey: StorageKeys.rulesHidden) }
    }

    static var hasNickname: Bool {
        guard let nickname else { return false }
        return !nickname.isEmpty
    }

    static var hasActiveSession: Bool {
        hasNickname && sessionToken != nil
    }

    static func saveSession(nickname: String, sessionToken: String, isGuest: Bool = false, guestPin: String? = nil) {
        self.nickname = nickname
        self.sessionToken = sessionToken
        self.isGuest = isGuest
        self.guestPin = isGuest ? guestPin : nil
    }

    static func signOut() {
        nickname = nil
        sessionToken = nil
        isGuest = false
        guestPin = nil
        LeaderboardCache.clearAll()
    }
}
