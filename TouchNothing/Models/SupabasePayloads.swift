import Foundation

struct AuthSession: Decodable {
    let nickname: String
    let sessionToken: String

    enum CodingKeys: String, CodingKey {
        case nickname
        case sessionToken = "session_token"
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
