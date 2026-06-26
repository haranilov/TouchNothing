import SwiftUI

struct TouchNothingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .foregroundStyle(AppColors.textPrimary)
            .padding(.vertical, 14)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            .background(AppColors.fieldBackground)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(Rectangle())
            .animation(nil, value: configuration.isPressed)
    }
}
