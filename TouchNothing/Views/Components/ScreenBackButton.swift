import SwiftUI

struct ScreenBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(LocalizationKey.resultBack.localized)
        }
        .buttonStyle(TouchNothingButtonStyle())
        .padding(16)
    }
}
