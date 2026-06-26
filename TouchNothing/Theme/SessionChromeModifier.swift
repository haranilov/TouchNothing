import SwiftUI

struct SessionChromeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .ignoresSafeArea(.all)
            .statusBarHidden(true)
            .persistentSystemOverlays(.hidden)
            .forceHiddenStatusBar()
    }
}

extension View {
    func sessionChrome() -> some View {
        modifier(SessionChromeModifier())
    }
}
