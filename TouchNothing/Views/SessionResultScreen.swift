import SwiftUI

struct SessionResultScreen: View {
    let elapsedSeconds: Int
    let onBack: () -> Void

    @ObservedObject private var saveService = SessionSaveService.shared

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(resultMessage)
                .font(.title2)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            if elapsedSeconds < AppConstants.minSessionSeconds {
                Text(LocalizationKey.resultTooShort.localized)
                    .font(.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            } else {
                saveStatusView
            }

            if saveService.state == .failed {
                Button(action: saveService.retry) {
                    Text(LocalizationKey.resultRetrySave.localized)
                }
                .buttonStyle(TouchNothingButtonStyle())
            }

            Button(action: onBack) {
                Text(LocalizationKey.resultBack.localized)
            }
            .buttonStyle(TouchNothingButtonStyle())

            Spacer()
        }
        .touchNothingScreenLayout()
    }

    private var resultMessage: String {
        let formattedDuration = DurationFormatter.format(seconds: elapsedSeconds)
        return String(format: LocalizationKey.resultTitle.localized, formattedDuration)
    }

    @ViewBuilder
    private var saveStatusView: some View {
        switch saveService.state {
        case .idle, .saving:
            Text(LocalizationKey.resultSaving.localized)
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        case .saved:
            Text(LocalizationKey.resultSaved.localized)
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        case .failed:
            Text(LocalizationKey.resultSaveFailed.localized)
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}
