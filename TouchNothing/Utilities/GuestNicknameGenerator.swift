import Foundation

enum GuestNicknameGenerator {
    private static let prefix = "guest_"
    private static let suffixLength = 6
    private static let charset = Array("abcdefghijklmnopqrstuvwxyz0123456789")

    static func generate() -> String {
        let suffix = (0..<suffixLength).map { _ in
            String(charset.randomElement() ?? "a")
        }.joined()
        return prefix + suffix
    }
}
