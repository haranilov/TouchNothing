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
            .overlay {
                if configuration.isPressed {
                    Color.black.opacity(0.25)
                }
            }
            .contentShape(Rectangle())
            .animation(nil, value: configuration.isPressed)
    }
}

struct TouchNothingTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1)
            .animation(nil, value: configuration.isPressed)
    }
}
