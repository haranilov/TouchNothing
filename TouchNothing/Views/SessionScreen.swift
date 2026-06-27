import SwiftUI

struct SessionScreen: View {
    let onFinish: (Int) -> Void

    @Environment(\.scenePhase) private var scenePhase
    @State private var sessionTimer = SessionTimer()
    @State private var sessionEnded = false

    var body: some View {
        AppColors.background
            .sessionChrome()
            .contentShape(Rectangle())
            .onTapGesture {
                endSessionIfNeeded()
            }
            .onAppear {
                sessionTimer = SessionTimer()
                sessionEnded = false
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .background {
                    endSessionIfNeeded()
                }
            }
    }

    private func endSessionIfNeeded() {
        if sessionEnded { return }
        sessionEnded = true
        onFinish(sessionTimer.elapsedSeconds())
    }
}
