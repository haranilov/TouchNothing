import SwiftUI

struct NicknameTextField: View {
    @Binding var text: String
    var onTextChange: () -> Void = {}

    var body: some View {
        TextField(LocalizationKey.nicknamePlaceholder.localized, text: $text)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .formFieldStyle()
            .onChange(of: text) { _ in
                onTextChange()
            }
    }
}
