import SwiftUI

struct SessionScreen: View {
    let onFinish: (Int) -> Void

    @Environment(\.scenePhase) private var scenePhase
    @State private var sessionTimer = SessionTimer()
    @State private var sessionEnded = false
    @State private var callMonitor = SessionCallMonitor()

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
                callMonitor.onPhoneCall = endSessionIfNeeded
                callMonitor.endSessionIfPhoneCallIsActive()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase != .active {
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
