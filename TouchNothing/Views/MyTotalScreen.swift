import SwiftUI

struct MyTotalScreen: View {
    let onBack: () -> Void

    @State private var userStats = UserStats.empty
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var loadGeneration = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            profileHeader

            statsSection

            Spacer()

            ScreenBackButton(action: onBack)
        }
        .touchNothingScreenLayout(hidesStatusBarChrome: false)
        .task {
            await loadStats()
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 20) {
            Text(LocalizationKey.myTotalTitle.localized)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)
                .tracking(3)

            if let nickname = LocalUserStore.nickname {
                Text(nickname)
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .padding(.horizontal, 24)
                    .background(AppColors.fieldBackground)
            }
        }
    }

    private var statsSection: some View {
        VStack(spacing: 8) {
            Text(LocalizationKey.myTotalLabel.localized)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)

            ZStack {
                statsValues
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .tint(AppColors.textSecondary)
                }
            }
            .frame(minHeight: 88)
        }
        .padding(.top, 32)
    }

    @ViewBuilder
    private var statsValues: some View {
        if loadFailed {
            Text(LocalizationKey.myTotalLoadFailed.localized)
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        } else {
            VStack(spacing: 8) {
                Text(DurationFormatter.format(seconds: userStats.totalDurationSeconds))
                    .font(.system(size: 36, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .monospacedDigit()

                if userStats.sessionCount > 0 {
                    Text(sessionsLabel)
                        .font(.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                } else {
                    Text(LocalizationKey.myTotalNoSessions.localized)
                        .font(.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }

    private var sessionsLabel: String {
        String(format: LocalizationKey.myTotalSessions.localized, userStats.sessionCount)
    }

    private func loadStats() async {
        loadGeneration += 1
        let generation = loadGeneration

        isLoading = true
        loadFailed = false
        defer { isLoading = false }

        let result = await UserStatsService.load(nickname: LocalUserStore.nickname)
        guard generation == loadGeneration else { return }

        userStats = result.stats
        loadFailed = result.status != .success
    }
}
