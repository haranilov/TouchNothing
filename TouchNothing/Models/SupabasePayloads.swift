import Foundation

struct AuthSession: Decodable {
    let nickname: String
    let sessionToken: String

    enum CodingKeys: String, CodingKey {
        case nickname
        case sessionToken = "session_token"
    }
}

struct AuthRPCResponse: Decodable {
    let ok: Bool?
    let error: String?
    let nickname: String?
    let sessionToken: String?
    let remainingAttempts: Int?

    enum CodingKeys: String, CodingKey {
        case ok, error, nickname
        case sessionToken = "session_token"
        case remainingAttempts = "remaining_attempts"
    }

    var authSession: AuthSession? {
        guard ok != false,
              let nickname,
              let sessionToken else {
            return nil
        }
        return AuthSession(nickname: nickname, sessionToken: sessionToken)
    }

    var serviceError: SupabaseServiceError? {
        guard ok == false else { return nil }

        if error == "invalid_credentials" {
            return .invalidCredentials(remainingAttempts: remainingAttempts)
        }

        return SupabaseRPCErrorMapper.mapAuthErrorToken(error) ?? .networkFailure
    }
}

struct NicknameParams: Codable {
    let pNickname: String
    let pPin: String

    enum CodingKeys: String, CodingKey {
        case pNickname = "p_nickname"
        case pPin = "p_pin"
    }
}

struct SessionParams: Codable {
    let pNickname: String
    let pDuration: Int
    let pSessionToken: String

    enum CodingKeys: String, CodingKey {
        case pNickname = "p_nickname"
        case pDuration = "p_duration"
        case pSessionToken = "p_session_token"
    }
}

struct UserStatsParams: Codable {
    let pNickname: String

    enum CodingKeys: String, CodingKey {
        case pNickname = "p_nickname"
    }
}
