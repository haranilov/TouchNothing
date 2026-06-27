import SwiftUI

struct MainMenuScreen: View {
    let onStart: () -> Void
    let onLeaderboard: () -> Void
    let onMyTotal: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(LocalizationKey.appTitle.localized)
                .font(.largeTitle)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            VStack(spacing: 16) {
                Button(action: onStart) {
                    Text(LocalizationKey.menuStart.localized)
                }
                .buttonStyle(TouchNothingButtonStyle())

                Button(action: onLeaderboard) {
                    Text(LocalizationKey.menuLeaderboard.localized)
                }
                .buttonStyle(TouchNothingButtonStyle())

                Button(action: onMyTotal) {
                    Text(LocalizationKey.menuMyTotal.localized)
                }
                .buttonStyle(TouchNothingButtonStyle())
            }

            Button(action: onSignOut) {
                Text(LocalizationKey.menuSignOut.localized)
                    .font(.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .buttonStyle(TouchNothingTextButtonStyle())
            .padding(.top, 8)

            Spacer()
        }
        .touchNothingScreenLayout(hidesStatusBarChrome: false)
    }
}
