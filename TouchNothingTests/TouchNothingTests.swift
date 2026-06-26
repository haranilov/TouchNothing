import XCTest
@testable import TouchNothing

final class PinInputTests: XCTestCase {
    func testSanitizeStripsNonDigitsAndLimitsLength() {
        XCTAssertEqual(PinInput.sanitize("12ab34567"), "1234")
        XCTAssertEqual(PinInput.sanitize("9999"), "9999")
    }

    func testIsValidRequiresFourDigits() {
        XCTAssertTrue(PinInput.isValid("1234"))
        XCTAssertFalse(PinInput.isValid("123"))
        XCTAssertFalse(PinInput.isValid("12a4"))
    }

    func testRandomPinIsAlwaysFourDigits() {
        for _ in 0..<20 {
            let pin = PinInput.randomPin()
            XCTAssertTrue(PinInput.isValid(pin))
        }
    }
}

final class GuestNicknameGeneratorTests: XCTestCase {
    func testGeneratesGuestPrefixedNickname() {
        let nickname = GuestNicknameGenerator.generate()
        XCTAssertTrue(nickname.hasPrefix("guest_"))
        XCTAssertNil(NicknameValidator.validate(nickname))
    }
}

final class AuthServiceTests: XCTestCase {
    func testValidateGuestRequiresOnlyNickname() {
        let credentials = AuthCredentials(
            mode: .guest,
            nickname: "guest_abc123",
            pin: "",
            confirmPin: ""
        )

        XCTAssertNil(AuthService.validate(credentials))
    }

    func testValidateRegisterRequiresMatchingPins() {
        let credentials = AuthCredentials(
            mode: .register,
            nickname: "player",
            pin: "1234",
            confirmPin: "5678"
        )

        XCTAssertEqual(AuthService.validate(credentials), .pinMismatch)
    }

    func testValidateSignInRequiresValidPin() {
        let credentials = AuthCredentials(
            mode: .signIn,
            nickname: "player",
            pin: "12",
            confirmPin: ""
        )

        XCTAssertEqual(AuthService.validate(credentials), .invalidPin)
    }

    func testValidateRejectsEmptyNickname() {
        let credentials = AuthCredentials(
            mode: .register,
            nickname: "   ",
            pin: "1234",
            confirmPin: "1234"
        )

        XCTAssertEqual(AuthService.validate(credentials), .nickname(.empty))
    }
}

final class NicknameValidatorTests: XCTestCase {
    func testValidateRejectsEmptyNickname() {
        XCTAssertEqual(NicknameValidator.validate("   "), .empty)
    }

    func testValidateRejectsInvalidLength() {
        XCTAssertEqual(NicknameValidator.validate("a"), .invalidLength)
        XCTAssertEqual(NicknameValidator.validate(String(repeating: "a", count: 25)), .invalidLength)
    }

    func testValidateAcceptsValidNickname() {
        XCTAssertNil(NicknameValidator.validate("Kos"))
        XCTAssertNil(NicknameValidator.validate("  Kos  "))
        XCTAssertNil(NicknameValidator.validate("player_1"))
    }

    func testValidateRejectsInvalidCharacters() {
        XCTAssertEqual(NicknameValidator.validate("bad nick"), .invalidCharacters)
        XCTAssertEqual(NicknameValidator.validate("name!"), .invalidCharacters)
    }

    func testNormalizedTrimsWhitespace() {
        XCTAssertEqual(NicknameValidator.normalized("  Kos  "), "Kos")
    }
}

final class DurationFormatterTests: XCTestCase {
    func testFormatsSecondsOnly() {
        XCTAssertEqual(DurationFormatter.format(seconds: 7), "7s")
    }

    func testFormatsMinutesAndSeconds() {
        XCTAssertEqual(DurationFormatter.format(seconds: 65), "1m 5s")
    }

    func testFormatsHoursMinutesAndSeconds() {
        XCTAssertEqual(DurationFormatter.format(seconds: 3661), "1h 1m 1s")
    }

    func testClampsNegativeValues() {
        XCTAssertEqual(DurationFormatter.format(seconds: -5), "0s")
    }
}

final class LeaderboardRowMapperTests: XCTestCase {
    func testMapsBestSessionRowsWithRank() {
        let entry = LeaderboardEntry(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            nickname: "Kos",
            durationSeconds: 39,
            createdAt: nil
        )

        let rows = LeaderboardRowMapper.map(entries: [entry], currentNickname: "Kos")

        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].rank, 1)
        XCTAssertEqual(rows[0].nickname, "Kos")
        XCTAssertTrue(rows[0].isCurrentUser)
    }

    func testMapsTotalRowsWithRank() {
        let entry = TotalLeaderboardEntry(nickname: "Kos", totalDurationSeconds: 120)

        let rows = LeaderboardRowMapper.mapTotal(entries: [entry], currentNickname: "kos")

        XCTAssertEqual(rows[0].durationSeconds, 120)
        XCTAssertTrue(rows[0].isCurrentUser)
    }
}

final class SupabaseRPCErrorMapperTests: XCTestCase {
    func testMapsKnownErrors() {
        XCTAssertEqual(
            SupabaseRPCErrorMapper.map(TestError("nickname_taken")),
            .nicknameTaken
        )
        XCTAssertEqual(
            SupabaseRPCErrorMapper.map(TestError("invalid_credentials")),
            .invalidCredentials
        )
        XCTAssertEqual(
            SupabaseRPCErrorMapper.map(TestError("account_locked")),
            .accountLocked
        )
        XCTAssertEqual(
            SupabaseRPCErrorMapper.map(TestError("invalid_session_token")),
            .invalidSessionToken
        )
    }

    func testMapsUnknownErrorsToNetworkFailure() {
        XCTAssertEqual(
            SupabaseRPCErrorMapper.map(TestError("something_else")),
            .networkFailure
        )
    }
}

final class SessionTimerTests: XCTestCase {
    func testElapsedSecondsUsesWholeSeconds() {
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 10.9)
        let timer = SessionTimer(startDate: start)

        XCTAssertEqual(timer.elapsedSeconds(at: end), 10)
    }
}

final class UserStatsDecodingTests: XCTestCase {
    func testDecodesSupabaseJSONPayload() throws {
        let json = Data(#"{"total_duration_seconds":39,"session_count":2}"#.utf8)
        let stats = try JSONDecoder().decode(UserStats.self, from: json)

        XCTAssertEqual(stats.totalDurationSeconds, 39)
        XCTAssertEqual(stats.sessionCount, 2)
    }

    func testDecodesBigIntAsString() throws {
        let json = Data(#"{"total_duration_seconds":"120","session_count":"3"}"#.utf8)
        let stats = try JSONDecoder().decode(UserStats.self, from: json)

        XCTAssertEqual(stats.totalDurationSeconds, 120)
        XCTAssertEqual(stats.sessionCount, 3)
    }
}

final class AuthSessionDecodingTests: XCTestCase {
    func testDecodesJSONAuthSession() throws {
        let json = Data(#"{"nickname":"Kos","session_token":"abc123token"}"#.utf8)
        let session = try JSONDecoder().decode(AuthSession.self, from: json)

        XCTAssertEqual(session.nickname, "Kos")
        XCTAssertEqual(session.sessionToken, "abc123token")
    }

    func testDecodesLegacyStringToken() throws {
        let json = Data(#""legacy-token-value""#.utf8)
        let token = try JSONDecoder().decode(String.self, from: json)

        XCTAssertEqual(token, "legacy-token-value")
    }
}

private struct TestError: Error, CustomStringConvertible {
    let description: String

    init(_ description: String) {
        self.description = description
    }
}
