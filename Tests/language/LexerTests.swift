import Foundation
import XCTest
@testable import GraphQL

class LexerTests: XCTestCase {
  private let _idx = "".unicodeScalars.startIndex

  func testAcceptsBOMHeader() {
    checkTokenKindAndValue(firstToken("\u{FEFF} foo"), kind: .Name, value: "foo")
  }

  func testSkipsWhitespace() {
    checkTokenKindAndValue(firstToken("   \n  foo\n    \n"), kind: .Name, value: "foo")
  }

  func testSkipsComments() {
    checkTokenKindAndValue(firstToken("\n#comment\nfoo#comment"), kind: .Name, value: "foo")
  }

  func testSkipsCommas() {
    checkTokenKindAndValue(firstToken(",,,foo,,,"), kind: .Name, value: "foo")
  }

  func testLexesSimpleString() {
    checkTokenKindAndValue(firstToken("\"simple\""), kind: .String, value: "simple")
  }

  func testLexesWhiteSpaceString() {
    checkTokenKindAndValue(firstToken("\" white space \""), kind: .String, value: " white space ")
  }

  func testLexesQuote() {
    checkTokenKindAndValue(firstToken("\"escaped \\\"\""), kind: .String, value: "escaped \"")
  }

  func testLexesEscapedChars() {
    checkTokenKindAndValue(firstToken("\"escaped \\n\\r\\t\""), kind: .String, value: "escaped \n\r\t")
  }

  func testLexesSlashes() {
    checkTokenKindAndValue(firstToken("\"slashes \\\\ \\/\""), kind: .String, value: "slashes \\ /")
  }

  func testLexesUnicode() {
    checkTokenKindAndValue(firstToken("\"unicode \\u1234\\u5678\\u90AB\\uCDEF\""), kind: .String, value: "unicode \u{1234}\u{5678}\u{90AB}\u{CDEF}")
  }

  func testLexesMultibyteCharacters() {
    let sut = Lexer(source: "# This comment has a \u{0A0A} multi-byte character.\n{ field(arg: \"Has a \u{0A0A} multi-byte character.\") }")

    do {
      var token: Token
      repeat {
        token = try sut.next()
      } while (token.kind != .EOF)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testUnterminatedShortStringError() {
    checkError("\"", expectedError: .UnterminatedString(_idx))
  }

  func testUnterminatedLongStringError() {
    checkError("\"not terminated", expectedError: .UnterminatedString(_idx))
  }

  func testUnescapedControlCharError() {
    checkError("\"unescaped \u{0007} control char\"", expectedError: .InvalidCharacterWithinString(_idx, Character(UnicodeScalar(0x07))))
  }

  func testNullByteInTheMiddleOfStringError() {
    checkError("\"null byte \u{0000} not at end of file\"", expectedError: .InvalidCharacterWithinString(_idx, Character(UnicodeScalar(0x0))))
  }

  func testMultilineStringError0() {
    checkError("\"multi\nline\"", expectedError: .UnterminatedString(_idx))
  }

  func testMultilineStringError1() {
    checkError("\"multi\rline\"", expectedError: .UnterminatedString(_idx))
  }

  func testBadEscapeError0() {
    checkError("\"bad \\z esc\"", expectedError: .InvalidEscapeSequence(_idx, "\\z"))
  }

  func testBadEscapeError1() {
    checkError("\"bad \\x esc\"", expectedError: .InvalidEscapeSequence(_idx, "\\x"))
  }

  func testBadUnicodeEscapeError() {
    checkError("\"bad \\u1 esc\"", expectedError: .InvalidEscapeSequence(_idx, "\\u1 es"))
  }

  func testBadUnicodeEscapeError1() {
    checkError("\"bad \\u0XX1 esc\"", expectedError: .InvalidEscapeSequence(_idx, "\\u0XX1"))
  }

  func testBadUnicodeEscapeError2() {
    checkError("\"bad \\uXXXX esc\"", expectedError: .InvalidEscapeSequence(_idx, "\\uXXXX"))
  }

  func testBadUnicodeEscapeError3() {
    checkError("\"bad \\uFXXX esc\"", expectedError: .InvalidEscapeSequence(_idx, "\\uFXXX"))
  }

  func testBadUnicodeEscapeError4() {
    checkError("\"bad \\uXXXF esc\"", expectedError: .InvalidEscapeSequence(_idx, "\\uXXXF"))
  }

  func testLexesZero() {
    checkTokenKindAndValue(firstToken("0"), kind: .Int, value: "0")
  }

  func testLexesInt() {
    checkTokenKindAndValue(firstToken("42"), kind: .Int, value: "42")
  }

  func testLexesNegativeInt() {
    checkTokenKindAndValue(firstToken("-9"), kind: .Int, value: "-9")
  }

  func testLexesFloat() {
    checkTokenKindAndValue(firstToken("1.234"), kind: .Float, value: "1.234")
  }

  func testLexesNegativeFloat() {
    checkTokenKindAndValue(firstToken("-1.234"), kind: .Float, value: "-1.234")
  }

  func testLexesSmallFloat() {
    checkTokenKindAndValue(firstToken("0.234"), kind: .Float, value: "0.234")
  }

  func testLexesSmallExponents() {
    checkTokenKindAndValue(firstToken("123e4"), kind: .Float, value: "123e4")
  }

  func testLexesBigExponents() {
    checkTokenKindAndValue(firstToken("123E4"), kind: .Float, value: "123E4")
  }

  func testLexesSmallNegativeExponents() {
    checkTokenKindAndValue(firstToken("123e-4"), kind: .Float, value: "123e-4")
  }

  func testLexesBigNegativeExponents() {
    checkTokenKindAndValue(firstToken("123E-4"), kind: .Float, value: "123E-4")
  }

  func testLexesNegativeSmallExponents() {
    checkTokenKindAndValue(firstToken("-123e4"), kind: .Float, value: "-123e4")
  }

  func testLexesNegativeBigExponents() {
    checkTokenKindAndValue(firstToken("-123E4"), kind: .Float, value: "-123E4")
  }

  func testLexesNegativeSmallNegativeExponents() {
    checkTokenKindAndValue(firstToken("-123e-4"), kind: .Float, value: "-123e-4")
  }

  func testLexesNegativeBigNegativeExponents() {
    checkTokenKindAndValue(firstToken("-123E-4"), kind: .Float, value: "-123E-4")
  }

  func testLexesDecimalSmallExponents() {
    checkTokenKindAndValue(firstToken("1.23e4"), kind: .Float, value: "1.23e4")
  }

  func testLexesDecimalBigExponents() {
    checkTokenKindAndValue(firstToken("1.23E4"), kind: .Float, value: "1.23E4")
  }

  func testLexesDecimalSmallNegativeExponents() {
    checkTokenKindAndValue(firstToken("1.23e-4"), kind: .Float, value: "1.23e-4")
  }

  func testLexesDecimalBigNegativeExponents() {
    checkTokenKindAndValue(firstToken("1.23E-4"), kind: .Float, value: "1.23E-4")
  }

  func testLexesDecimalNegativeSmallExponents() {
    checkTokenKindAndValue(firstToken("-1.23e4"), kind: .Float, value: "-1.23e4")
  }

  func testLexesDecimalNegativeBigExponents() {
    checkTokenKindAndValue(firstToken("-1.23E4"), kind: .Float, value: "-1.23E4")
  }

  func testLexesDecimalNegativeSmallNegativeExponents() {
    checkTokenKindAndValue(firstToken("-1.23e-4"), kind: .Float, value: "-1.23e-4")
  }

  func testLexesDecimalNegativeBigNegativeExponents() {
    checkTokenKindAndValue(firstToken("-1.23E-4"), kind: .Float, value: "-1.23E-4")
  }

  func testNumberZeroError() {
    checkError("00", expectedError: .UnexpectedCharacterInNumberAfterZero(_idx, "0"))
  }

  func testNumberPlusError() {
    checkError("+1", expectedError: .UnexpectedCharacter(_idx, "+"))
  }

  func testNumberInvalidDotNotationError0() {
    checkError("123.", expectedError: .UnexpectedCharacterInNumber(_idx, Character(UnicodeScalar(0xFFFD))))
  }

  func testNumberInvalidDotNotationError1() {
    checkError(".123", expectedError: .UnexpectedCharacter(_idx, Character(".")))
  }

  func testNumberInvalidDotNotationError2() {
    checkError("1.A", expectedError: .UnexpectedCharacterInNumber(_idx, Character("A")))
  }

  func testNumberInvalidNegativeError() {
    checkError("-A", expectedError: .UnexpectedCharacterInNumber(_idx, Character("A")))
  }

  func testNumberInvalidExponentError0() {
    checkError("1.0e", expectedError: .UnexpectedCharacterInNumber(_idx, Character(UnicodeScalar(0xFFFD))))
  }

  func testNumberInvalidExponentError1() {
    checkError("1.0eA", expectedError: .UnexpectedCharacterInNumber(_idx, Character("A")))
  }

  func testLexesBang() {
    checkTokenKindAndValue(firstToken("!"), kind: .Bang, value: nil)
  }

  func testLexesDollar() {
    checkTokenKindAndValue(firstToken("$"), kind: .Dollar, value: nil)
  }

  func testLexesParenL() {
    checkTokenKindAndValue(firstToken("("), kind: .ParenL, value: nil)
  }

  func testLexesParenR() {
    checkTokenKindAndValue(firstToken(")"), kind: .ParenR, value: nil)
  }

  func testLexesSpread() {
    checkTokenKindAndValue(firstToken("..."), kind: .Spread, value: nil)
  }

  func testLexesColon() {
    checkTokenKindAndValue(firstToken(":"), kind: .Colon, value: nil)
  }

  func testLexesEquals() {
    checkTokenKindAndValue(firstToken("="), kind: .Equals, value: nil)
  }

  func testLexesAt() {
    checkTokenKindAndValue(firstToken("@"), kind: .At, value: nil)
  }

  func testLexesBracketL() {
    checkTokenKindAndValue(firstToken("["), kind: .BracketL, value: nil)
  }

  func testLexesBracketR() {
    checkTokenKindAndValue(firstToken("]"), kind: .BracketR, value: nil)
  }

  func testLexesBraceL() {
    checkTokenKindAndValue(firstToken("{"), kind: .BraceL, value: nil)
  }

  func testLexesBraceR() {
    checkTokenKindAndValue(firstToken("}"), kind: .BraceR, value: nil)
  }

  func testLexesPipe() {
    checkTokenKindAndValue(firstToken("|"), kind: .Pipe, value: nil)
  }

  func testUnexpectedCharacterError0() {
    checkError("?", expectedError: .UnexpectedCharacter(_idx, "?"))
  }

  func testUnexpectedCharacterError1() {
    checkError("..", expectedError: .UnexpectedCharacter(_idx, "."))
  }

  func testUnexpectedCharacterError2() {
    checkError("\u{203B}", expectedError: .UnexpectedCharacter(_idx, Character(UnicodeScalar(0x203B))))
  }

  func testUnexpectedCharacterError3() {
    checkError("\u{200b}", expectedError: .UnexpectedCharacter(_idx, Character(UnicodeScalar(0x200B))))
  }

  func testDashesInNames() {
    let source = "a-b"
    let sut = Lexer(source: source)

    checkTokenKindAndValue(try! sut.next(), kind: .Name, value: "a")

    do {
      let _ = try sut.next()
    } catch LexerError.UnexpectedCharacterInNumber(_, let character) {
      XCTAssertEqual(character, Character("b"))
    } catch {
      XCTFail("Unexpected error: \(error).")
    }
  }

  func testLexesSpreadDigit() {
    let sut = Lexer(source: "... 123")

    let firstToken = try! sut.next()
    let secondToken = try! sut.next()
    let thirdToken = try! sut.next()

    checkTokenKindAndValue(firstToken, kind: .Spread, value: nil)
    checkTokenKindAndValue(secondToken, kind: .Int, value: "123")
    checkTokenKindAndValue(thirdToken, kind: .EOF, value: nil)
  }

  func testLexesKitchenSink() {
    let sut = Lexer(source: graphQlQuery("kitchen_sink"))

    do {
      var token: Token
      repeat {
        token = try sut.next()
      } while (token.kind != .EOF)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
}

extension LexerError: Equatable {}

func == (lhs: LexerError, rhs: LexerError) -> Bool {
  switch (lhs, rhs) {
  case (.UnexpectedCharacter(_, let lhsCharacter), .UnexpectedCharacter(_, let rhsCharacter)):
    return lhsCharacter == rhsCharacter
  case (.InvalidCharacter(_, let lhsCharacter), .InvalidCharacter(_, let rhsCharacter)):
    return lhsCharacter == rhsCharacter
  case (.InvalidCharacterWithinString(_, let lhsCharacter), .InvalidCharacterWithinString(_, let rhsCharacter)):
    return lhsCharacter == rhsCharacter
  case (.InvalidEscapeSequence(_, let lhsCharacter), .InvalidEscapeSequence(_, let rhsCharacter)):
    return lhsCharacter == rhsCharacter
  case (.UnterminatedString, .UnterminatedString):
    return true
  case (.UnexpectedCharacterInNumberAfterZero(_, let lhsCharacter), .UnexpectedCharacterInNumberAfterZero(_, let rhsCharacter)):
    return lhsCharacter == rhsCharacter
  case (.UnexpectedCharacterInNumber(_, let lhsCharacter), .UnexpectedCharacterInNumber(_, let rhsCharacter)):
    return lhsCharacter == rhsCharacter
  default:
    return false
  }
}

extension LexerTests {
  private func firstToken(source: String) -> Token {
    return try! Lexer(source: source).next()
  }

  private func checkError(source: String, expectedError: LexerError, file: String = #file, line: UInt = #line) {
    let sut = Lexer(source: source)

    do {
      let token = try sut.next()
      let failureMessage = "checkError failed: did not throw but returned (\(token))"
      recordFailureWithDescription(failureMessage, inFile: file, atLine: line, expected: true)
    } catch let error as LexerError {
      XCTAssertEqual(error, expectedError)
      if (error != expectedError) {
        recordFailureWithDescription("checkError failed: \(error) is not equal to \(expectedError)", inFile: file, atLine: line, expected: true)
      }
    } catch {
      recordFailureWithDescription("checkError failed: \(error) is not a LexerError", inFile: file, atLine: line, expected: true)
    }
  }

  private func checkTokenKindAndValue(lhs: Token, kind: TokenKind, value: String?, file: String = #file, line: UInt = #line) {
    if (lhs.kind != kind || lhs.value != value) {
      let message = "checkTokenKindAndValue failed: (\(lhs.kind), \(lhs.value)) is not equal to (\(kind), \(value))"
      recordFailureWithDescription(message, inFile: file, atLine: line, expected: true)
    }
  }
}
