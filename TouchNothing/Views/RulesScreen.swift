import SwiftUI

struct RulesScreen: View {
    let onStart: () -> Void

    @State private var hideRulesNextTime = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(LocalizationKey.rulesBody.localized)
                .font(.body)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Toggle(isOn: $hideRulesNextTime) {
                Text(LocalizationKey.rulesDontShow.localized)
                    .foregroundStyle(AppColors.textPrimary)
            }
            .padding(.top, 8)

            Button(action: confirmRules) {
                Text(LocalizationKey.rulesStart.localized)
            }
            .buttonStyle(TouchNothingButtonStyle())

            Spacer()
        }
        .touchNothingScreenLayout()
    }

    private func confirmRules() {
        if hideRulesNextTime {
            LocalUserStore.rulesHidden = true
        }
        onStart()
    }
}
