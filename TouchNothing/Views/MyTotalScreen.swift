import SwiftUI

struct MyTotalScreen: View {
    let onBack: () -> Void

    @State private var userStats = UserStats.empty
    @State private var isLoading = false
    @State private var loadFailed = false
    @State private var loadGeneration = 0

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            profileHeader

            statsSection

            Button(action: onBack) {
                Text(LocalizationKey.resultBack.localized)
            }
            .buttonStyle(TouchNothingButtonStyle())

            Spacer()
        }
        .touchNothingScreenLayout()
        .refreshable {
            await loadStats()
        }
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

            if isLoading {
                Text(LocalizationKey.commonLoading.localized)
                    .font(.largeTitle)
                    .foregroundStyle(AppColors.textPrimary)
            }

            if loadFailed {
                Text(LocalizationKey.myTotalLoadFailed.localized)
                    .font(.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if !isLoading, !loadFailed {
                Text(DurationFormatter.format(seconds: userStats.totalDurationSeconds))
                    .font(.system(size: 36, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .monospacedDigit()

                if userStats.sessionCount > 0 {
                    Text(sessionsLabel)
                        .font(.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }

                if userStats.sessionCount == 0 {
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
        guard let nickname = LocalUserStore.nickname else {
            loadFailed = true
            return
        }

        loadGeneration += 1
        let generation = loadGeneration

        isLoading = true
        loadFailed = false
        defer { isLoading = false }

        do {
            let stats = try await SupabaseService.shared.fetchUserStats(nickname: nickname)
            guard generation == loadGeneration else { return }
            userStats = stats
            loadFailed = false
        } catch {
            guard generation == loadGeneration else { return }
            loadFailed = true
        }
    }
}
