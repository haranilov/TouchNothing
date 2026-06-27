import Foundation

enum SessionSaveState: Equatable {
    case idle
    case saving
    case saved
    case failed
}

@MainActor
final class SessionSaveService: ObservableObject {
    static let shared = SessionSaveService()

    @Published private(set) var state: SessionSaveState = .idle

    private var pendingSeconds = 0
    private var saveTask: Task<Void, Never>?

    private init() {}

    func queueSave(elapsedSeconds: Int) {
        guard elapsedSeconds >= AppConstants.minSessionSeconds else {
            state = .idle
            pendingSeconds = 0
            saveTask?.cancel()
            return
        }

        pendingSeconds = elapsedSeconds
        state = .saving
        startSaveTask()
    }

    func retry() {
        guard state == .failed, pendingSeconds >= AppConstants.minSessionSeconds else { return }

        state = .saving
        startSaveTask()
    }

    func resetIfNotSaving() {
        guard state != .saving else { return }
        state = .idle
        pendingSeconds = 0
    }

    private func startSaveTask() {
        saveTask?.cancel()
        saveTask = Task {
            await performSave()
        }
    }

    private func performSave(isRetryAfterReauth: Bool = false) async {
        guard !Task.isCancelled else { return }
        guard let nickname = LocalUserStore.nickname else {
            state = .failed
            return
        }
        guard let sessionToken = LocalUserStore.sessionToken else {
            state = .failed
            return
        }

        do {
            try await SupabaseService.shared.submitSession(
                nickname: nickname,
                durationSeconds: pendingSeconds,
                sessionToken: sessionToken
            )
            guard !Task.isCancelled else { return }
            LeaderboardCache.clearAll()
            state = .saved
        } catch {
            guard !Task.isCancelled else { return }
            if case SupabaseServiceError.invalidSessionToken = error,
               !isRetryAfterReauth,
               await AuthService.recoverGuestSession() {
                await performSave(isRetryAfterReauth: true)
                return
            }
            if case SupabaseServiceError.invalidSessionToken = error {
                LocalUserStore.signOut()
            }
            state = .failed
        }
    }
}
