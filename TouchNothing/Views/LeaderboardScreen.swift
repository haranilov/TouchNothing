import SwiftUI

struct LeaderboardScreen: View {
    let onBack: () -> Void

    @State private var mode: LeaderboardMode = .bestSession
    @State private var leaderboardRows: [LeaderboardRow] = []
    @State private var statusMessage: String?
    @State private var isLoading = false
    @State private var loadFailed = false

    var body: some View {
        VStack(spacing: 0) {
            headerView
            modePicker
            statusBanner
            contentArea
            ScreenBackButton(action: onBack)
        }
        .background(AppColors.background)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .forceHiddenStatusBar()
        .task(id: mode) {
            await loadLeaderboard()
        }
    }

    private var headerView: some View {
        Text(LocalizationKey.leaderboardTitle.localized)
            .font(.title2)
            .foregroundStyle(AppColors.textPrimary)
            .padding(.top, 24)
            .padding(.bottom, 12)
    }

    private var modePicker: some View {
        Picker("", selection: $mode) {
            ForEach(LeaderboardMode.allCases, id: \.self) { leaderboardMode in
                Text(leaderboardMode.titleKey.localized).tag(leaderboardMode)
            }
        }
        .touchNothingSegmentedPickerStyle()
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var statusBanner: some View {
        if let statusMessage {
            Text(statusMessage)
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private var contentArea: some View {
        if isLoading, leaderboardRows.isEmpty {
            LoadingStateView()
        } else if loadFailed {
            failureView
        } else if leaderboardRows.isEmpty {
            emptyView
        } else {
            leaderboardList
        }
    }

    private var emptyView: some View {
        VStack {
            Spacer()
            Text(LocalizationKey.leaderboardEmpty.localized)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
        }
    }

    private var failureView: some View {
        VStack {
            Spacer()
            Text(LocalizationKey.leaderboardError.localized)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            Spacer()
        }
    }

    private var leaderboardList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(leaderboardRows) { row in
                    LeaderboardRowView(row: row)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(rowBackground(for: row))
                }
            }
        }
        .refreshable {
            await loadLeaderboard()
        }
    }

    private func rowBackground(for row: LeaderboardRow) -> Color {
        row.isCurrentUser ? AppColors.fieldBackground : AppColors.background
    }

    private func loadLeaderboard() async {
        isLoading = true
        loadFailed = false
        defer { isLoading = false }

        let result = await LeaderboardService.load(
            mode: mode,
            currentNickname: LocalUserStore.nickname
        )
        leaderboardRows = result.rows
        statusMessage = result.statusMessage
        loadFailed = result.rows.isEmpty && result.statusMessage == LocalizationKey.leaderboardError.localized
    }
}
