import SwiftUI

struct AuthScreen: View {
    @StateObject private var viewModel: AuthViewModel

    init(onContinue: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(onContinue: onContinue))
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(LocalizationKey.appTitle.localized)
                .font(.largeTitle)
                .foregroundStyle(AppColors.textPrimary)

            Picker("", selection: $viewModel.authMode) {
                ForEach(AuthMode.allCases, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .touchNothingSegmentedPickerStyle()
            .onChange(of: viewModel.authMode) { newMode in
                viewModel.handleModeChange(newMode)
            }

            authFields

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: viewModel.submit) {
                Text(viewModel.submitButtonTitle)
            }
            .buttonStyle(TouchNothingButtonStyle())
            .disabled(viewModel.isSubmitting)

            Spacer()
        }
        .touchNothingScreenLayout()
        .onAppear {
            viewModel.prefillNicknameIfNeeded()
        }
    }

    @ViewBuilder
    private var authFields: some View {
        switch viewModel.authMode {
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

            NicknameTextField(text: $viewModel.guestNicknameInput) {
                viewModel.clearFieldError()
            }

            Text(LocalizationKey.authGuestWarning.localized)
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var registeredUserFields: some View {
        VStack(spacing: 16) {
            NicknameTextField(text: $viewModel.registeredNicknameInput) {
                viewModel.clearFieldError()
            }

            PinSecureField(
                placeholder: LocalizationKey.authPinPlaceholder.localized,
                text: $viewModel.pinInput
            ) {
                viewModel.clearFieldError()
            }

            if viewModel.authMode == .register {
                PinSecureField(
                    placeholder: LocalizationKey.authConfirmPinPlaceholder.localized,
                    text: $viewModel.confirmPinInput
                ) {
                    viewModel.clearFieldError()
                }
            }

            if viewModel.authMode == .signIn {
                Text(LocalizationKey.authForgotPin.localized)
                    .font(.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
