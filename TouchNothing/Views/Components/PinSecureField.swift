import SwiftUI

struct PinSecureField: View {
    let placeholder: String
    @Binding var text: String
    var onTextChange: () -> Void = {}

    var body: some View {
        SecureField(placeholder, text: $text)
            .keyboardType(.numberPad)
            .formFieldStyle()
            .onChange(of: text) { newValue in
                text = PinInput.sanitize(newValue)
                onTextChange()
            }
    }
}
