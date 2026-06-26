import Foundation

enum AuthValidationError: Equatable {
    case nickname(NicknameValidationError)
    case invalidPin
    case pinMismatch
}
