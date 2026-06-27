import SwiftUI

struct TouchNothingScreenLayout: ViewModifier {
    var hidesStatusBarChrome: Bool = true

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 32)
            .background(AppColors.background)
            .modifier(ConditionalStatusBarChrome(hidden: hidesStatusBarChrome))
    }
}

private struct ConditionalStatusBarChrome: ViewModifier {
    let hidden: Bool

    func body(content: Content) -> some View {
        if hidden {
            content.hiddenStatusBarChrome()
        } else {
            content
        }
    }
}

extension View {
    func touchNothingScreenLayout(hidesStatusBarChrome: Bool = true) -> some View {
        modifier(TouchNothingScreenLayout(hidesStatusBarChrome: hidesStatusBarChrome))
    }
}
