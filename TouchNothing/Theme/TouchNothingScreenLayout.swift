import SwiftUI

struct TouchNothingScreenLayout: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 32)
            .background(AppColors.background)
            .statusBarHidden(true)
            .persistentSystemOverlays(.hidden)
            .forceHiddenStatusBar()
    }
}

extension View {
    func touchNothingScreenLayout() -> some View {
        modifier(TouchNothingScreenLayout())
    }
}
