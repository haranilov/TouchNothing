import SwiftUI

struct AuthScreen: View {
    let onContinue: () -> Void

    @State private var authMode: AuthMode = .register
    @State private var registeredNicknameInput = ""
    @State private var guestNicknameInput = ""
    @State private var pinInput = ""
    @State private var confirmPinInput = ""
    @State private var errorMessage: String?
    @State private var isSubmitting = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(LocalizationKey.appTitle.localized)
                .font(.largeTitle)
                .foregroundStyle(AppColors.textPrimary)

            Picker("", selection: $authMode) {
                ForEach(AuthMode.allCases, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .touchNothingSegmentedPickerStyle()
            .onChange(of: authMode) { newMode in
                clearErrors()
                if newMode == .guest, guestNicknameInput.isEmpty {
                    assignGuestNickname()
                }
            }

            authFields

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: submit) {
                Text(submitButtonTitle)
            }
            .buttonStyle(TouchNothingButtonStyle())
            .disabled(isSubmitting)

            Spacer()
        }
        .touchNothingScreenLayout()
        .onAppear {
            prefillNicknameIfNeeded()
        }
    }

    @ViewBuilder
    private var authFields: some View {
        switch authMode {
        case .guest:
            guestFields
        case .register, .signIn:
            registeredUserFields
        }
    }

    private var guestFields: some View {
        VStack(spacing: 16) {
            Text(LocalizationKey.authGuestNicknameLabel.localized)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            NicknameTextField(text: $guestNicknameInput) {
                errorMessage = nil
            }

            Text(LocalizationKey.authGuestWarning.localized)
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var registeredUserFields: some View {
        VStack(spacing: 16) {
            NicknameTextField(text: $registeredNicknameInput) {
                errorMessage = nil
            }

            PinSecureField(
                placeholder: LocalizationKey.authPinPlaceholder.localized,
                text: $pinInput
            ) {
                errorMessage = nil
            }

            if authMode == .register {
                PinSecureField(
                    placeholder: LocalizationKey.authConfirmPinPlaceholder.localized,
                    text: $confirmPinInput
                ) {
                    errorMessage = nil
                }
            }

            if authMode == .signIn {
                Text(LocalizationKey.authForgotPin.localized)
                    .font(.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var submitButtonTitle: String {
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

    private var activeNicknameInput: String {
        authMode.isGuest ? guestNicknameInput : registeredNicknameInput
    }

    private func prefillNicknameIfNeeded() {
        guard registeredNicknameInput.isEmpty, let savedNickname = LocalUserStore.nickname else { return }
        registeredNicknameInput = savedNickname
        authMode = .signIn
    }

    private func assignGuestNickname() {
        guestNicknameInput = GuestNicknameGenerator.generate()
    }

    private func submit() {
        let credentials = AuthCredentials(
            mode: authMode,
            nickname: activeNicknameInput,
            pin: pinInput,
            confirmPin: confirmPinInput
        )

        if let validationError = AuthService.validate(credentials) {
            errorMessage = AuthService.message(for: validationError)
            return
        }

        isSubmitting = true
        errorMessage = nil

        Task {
            await performAuth(credentials)
        }
    }

    @MainActor
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

    private func clearErrors() {
        errorMessage = nil
        confirmPinInput = ""
    }
}
