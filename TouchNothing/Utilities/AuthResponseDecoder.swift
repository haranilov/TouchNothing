import Foundation

enum AuthResponseDecoder {
    static func decodeSession(from data: Data, fallbackNickname: String) throws -> AuthSession {
        if let payload = try? JSONDecoder().decode(AuthRPCResponse.self, from: data) {
            if let serviceError = payload.serviceError {
                throw serviceError
            }
            if let session = payload.authSession {
                return session
            }
        }

        if let session = try? JSONDecoder().decode(AuthSession.self, from: data) {
            return session
        }

        if let token = try? JSONDecoder().decode(String.self, from: data) {
            return AuthSession(
                nickname: NicknameValidator.normalized(fallbackNickname),
                sessionToken: token
            )
        }

        throw SupabaseServiceError.serverUpgradeRequired
    }
}
