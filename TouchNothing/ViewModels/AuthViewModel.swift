import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var authMode: AuthMode = .register
    @Published var registeredNicknameInput = ""
    @Published var guestNicknameInput = ""
    @Published var pinInput = ""
    @Published var confirmPinInput = ""
    @Published var errorMessage: String?
    @Published var isSubmitting = false

    private let onContinue: () -> Void

    init(onContinue: @escaping () -> Void) {
        self.onContinue = onContinue
    }

    var submitButtonTitle: String {
        if isSubmitting {
            switch authMode {
            case .register:
                return LocalizationKey.authCreating.localized
            case .signIn:
                return LocalizationKey.authSigningIn.localized
            case .guest:
                return LocalizationKey.authGuestCreating.localized
            }
        }

        switch authMode {
        case .guest:
            return LocalizationKey.authGuestContinue.localized
        case .register, .signIn:
            return LocalizationKey.nicknameContinue.localized
        }
    }

    func prefillNicknameIfNeeded() {
        guard registeredNicknameInput.isEmpty, let savedNickname = LocalUserStore.nickname else { return }
        registeredNicknameInput = savedNickname
        authMode = .signIn
    }

    func handleModeChange(_ newMode: AuthMode) {
        clearErrors()
        if newMode == .guest, guestNicknameInput.isEmpty {
            assignGuestNickname()
        }
    }

    func clearFieldError() {
        errorMessage = nil
    }

    func submit() {
        let credentials = AuthCredentials(
            mode: authMode,
            nickname: activeNicknameInput,
            pin: pinInput,
            confirmPin: confirmPinInput
        )

        if let validationError = AuthService.validate(credentials) {
            errorMessage = AuthErrorMessage.message(for: validationError)
            return
        }

        isSubmitting = true
        errorMessage = nil

        Task {
            await performAuth(credentials)
        }
    }

    private var activeNicknameInput: String {
        authMode.isGuest ? guestNicknameInput : registeredNicknameInput
    }

    private func performAuth(_ credentials: AuthCredentials) async {
        defer { isSubmitting = false }

        do {
            try await AuthService.authenticate(credentials)
            pinInput = ""
            confirmPinInput = ""
            onContinue()
        } catch let serviceError as SupabaseServiceError {
            errorMessage = AuthErrorMessage.message(for: serviceError)
            if credentials.mode == .guest, serviceError == .nicknameTaken {
                assignGuestNickname()
            }
        } catch {
            errorMessage = LocalizationKey.nicknameNetworkError.localized
        }
    }

    private func assignGuestNickname() {
        guestNicknameInput = GuestNicknameGenerator.generate()
    }

    private func clearErrors() {
        errorMessage = nil
        confirmPinInput = ""
    }
}
