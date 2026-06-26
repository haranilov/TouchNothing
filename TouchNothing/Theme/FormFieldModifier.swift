import SwiftUI

struct FormFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppColors.fieldBackground)
            .foregroundStyle(AppColors.textPrimary)
    }
}

extension View {
    func formFieldStyle() -> some View {
        modifier(FormFieldModifier())
    }

    func touchNothingSegmentedPickerStyle() -> some View {
        pickerStyle(.segmented)
            .tint(AppColors.fieldBackground)
    }
}
