import SwiftUI

struct SessionChromeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .ignoresSafeArea(.all)
            .hiddenStatusBarChrome()
    }
}

extension View {
    func sessionChrome() -> some View {
        modifier(SessionChromeModifier())
    }
}
