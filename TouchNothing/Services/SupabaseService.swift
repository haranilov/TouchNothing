import Foundation
import Supabase

enum SupabaseServiceError: Error, Equatable {
    case nicknameTaken
    case invalidCredentials
    case accountLocked
    case invalidPin
    case invalidNickname
    case invalidSessionToken
    case nicknameNotRegistered
    case serverUpgradeRequired
    case notConfigured
    case networkFailure
}

final class SupabaseService {
    static let shared = SupabaseService()

    private var client: SupabaseClient?

    private init() {
        configureClientIfPossible()
    }

    private func configureClientIfPossible() {
        guard let configuration = try? SupabaseConfig.load() else { return }
        client = SupabaseClient(supabaseURL: configuration.url, supabaseKey: configuration.anonKey)
    }

    var isConfigured: Bool {
        client != nil
    }

    func registerUser(nickname: String, pin: String) async throws -> AuthSession {
        try await fetchAuthSession(
            "register_user",
            params: NicknameParams(pNickname: nickname, pPin: pin)
        )
    }

    func loginUser(nickname: String, pin: String) async throws -> AuthSession {
        try await fetchAuthSession(
            "login_user",
            params: NicknameParams(pNickname: nickname, pPin: pin)
        )
    }

    func submitSession(
        nickname: String,
        durationSeconds: Int,
        sessionToken: String
    ) async throws {
        guard durationSeconds >= AppConstants.minSessionSeconds else { return }
        try await executeVoidRPC(
            "submit_session",
            params: SessionParams(
                pNickname: nickname,
                pDuration: durationSeconds,
                pSessionToken: sessionToken
            )
        )
    }

    func fetchUserStats(nickname: String) async throws -> UserStats {
        guard let client else { throw SupabaseServiceError.notConfigured }

        let normalizedNickname = NicknameValidator.normalized(nickname)

        do {
            let stats: [UserStats] = try await fetchRPC(
                "get_user_stats",
                params: UserStatsParams(pNickname: normalizedNickname)
            )
            if let statsRow = stats.first {
                return statsRow
            }
        } catch {
            // Fall back to direct table read if RPC is unavailable.
        }

        let stats: [UserStats] = try await client
            .from("user_stats")
            .select("total_duration_seconds, session_count")
            .ilike("nickname", pattern: normalizedNickname)
            .limit(1)
            .execute()
            .value

        guard let statsRow = stats.first else {
            throw SupabaseServiceError.networkFailure
        }

        return statsRow
    }

    func fetchLeaderboard(limit: Int = AppConstants.leaderboardLimit) async throws -> [LeaderboardEntry] {
        guard let client else { throw SupabaseServiceError.notConfigured }

        let entries: [LeaderboardEntry] = try await client
            .from("records")
            .select()
            .order("duration_seconds", ascending: false)
            .limit(limit)
            .execute()
            .value

        return entries
    }

    func fetchTotalLeaderboard(limit: Int = AppConstants.leaderboardLimit) async throws -> [TotalLeaderboardEntry] {
        guard let client else { throw SupabaseServiceError.notConfigured }

        let entries: [TotalLeaderboardEntry] = try await client
            .from("user_stats")
            .select("nickname, total_duration_seconds")
            .gt("total_duration_seconds", value: 0)
            .order("total_duration_seconds", ascending: false)
            .limit(limit)
            .execute()
            .value

        return entries
    }

    private func fetchAuthSession(
        _ function: String,
        params: NicknameParams
    ) async throws -> AuthSession {
        guard let client else { throw SupabaseServiceError.notConfigured }

        do {
            let response = try await client.rpc(function, params: params).execute()
            if let session = try? JSONDecoder().decode(AuthSession.self, from: response.data) {
                return session
            }
            if let token = try? JSONDecoder().decode(String.self, from: response.data) {
                return AuthSession(
                    nickname: NicknameValidator.normalized(params.pNickname),
                    sessionToken: token
                )
            }
            throw SupabaseServiceError.serverUpgradeRequired
        } catch let postgrestError as PostgrestError {
            throw SupabaseRPCErrorMapper.map(postgrestError)
        } catch let serviceError as SupabaseServiceError {
            throw serviceError
        } catch {
            if SupabaseRPCErrorMapper.isLikelyEmptyAuthResponse(error) {
                throw SupabaseServiceError.serverUpgradeRequired
            }
            throw SupabaseRPCErrorMapper.map(error)
        }
    }

    private func executeVoidRPC(
        _ function: String,
        params: some Encodable,
        mapErrors: Bool = true
    ) async throws {
        guard let client else { throw SupabaseServiceError.notConfigured }

        do {
            try await client.rpc(function, params: params).execute()
        } catch {
            throw rpcError(from: error, mapErrors: mapErrors)
        }
    }

    private func fetchRPC<T: Decodable>(
        _ function: String,
        params: some Encodable,
        mapErrors: Bool = true
    ) async throws -> T {
        guard let client else { throw SupabaseServiceError.notConfigured }

        do {
            return try await client
                .rpc(function, params: params)
                .execute()
                .value
        } catch {
            throw rpcError(from: error, mapErrors: mapErrors)
        }
    }

    private func rpcError(from error: Error, mapErrors: Bool) -> SupabaseServiceError {
        if mapErrors {
            return SupabaseRPCErrorMapper.map(error)
        }
        return .networkFailure
    }
}
