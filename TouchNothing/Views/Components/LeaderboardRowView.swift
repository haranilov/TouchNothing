import SwiftUI

struct LeaderboardRowView: View {
    let row: LeaderboardRow

    var body: some View {
        HStack {
            Text("\(row.rank)")
                .frame(width: 36, alignment: .leading)
            Text(row.nickname)
                .lineLimit(1)
            Spacer()
            Text(DurationFormatter.format(seconds: row.durationSeconds))
        }
        .font(.body)
        .foregroundStyle(AppColors.textPrimary)
    }
}
