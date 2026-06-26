import SwiftUI

struct LoadingStateView: View {
    var body: some View {
        VStack {
            Spacer()
            Text(LocalizationKey.commonLoading.localized)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
        }
    }
}
