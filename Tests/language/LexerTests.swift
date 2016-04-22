import Foundation
import XCTest
@testable import GraphQL

class LexerTests: XCTestCase {

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

  func testUnterminatedShortStringError() {
    checkSyntaxError("\"", expectedMessage: "Unterminated string.")
  }

  func testUnterminatedLongStringError() {
    checkSyntaxError("\"not terminated", expectedMessage: "Unterminated string.")
  }

  func testUnescapedControlCharError() {
    checkSyntaxError("\"unescaped \u{0007} control char\"", expectedMessage: "Invalid character within String: (\\u{07}).")
  }

  func testNullByteInTheMiddleOfStringError() {
    checkSyntaxError("\"null byte \u{0000} not at end of file\"", expectedMessage: "Invalid character within String: (\\0).")
  }

  func testMultilineStringError0() {
    checkSyntaxError("\"multi\nline\"", expectedMessage: "Unterminated string.")
  }

  func testMultilineStringError1() {
    checkSyntaxError("\"multi\rline\"", expectedMessage: "Unterminated string.")
  }

  func testBadEscapeError0() {
    checkSyntaxError("\"bad \\z esc\"", expectedMessage: "Invalid escape sequence: (\\z).")
  }

  func testBadEscapeError1() {
    checkSyntaxError("\"bad \\x esc\"", expectedMessage: "Invalid escape sequence: (\\x).")
  }

  func testBadUnicodeEscapeError() {
    checkSyntaxError("\"bad \\u1 esc\"", expectedMessage: "Invalid escape sequence: (\\u1 es).")
  }

  func testBadUnicodeEscapeError1() {
    checkSyntaxError("\"bad \\u0XX1 esc\"", expectedMessage: "Invalid escape sequence: (\\u0XX1).")
  }

  func testBadUnicodeEscapeError2() {
    checkSyntaxError("\"bad \\uXXXX esc\"", expectedMessage: "Invalid escape sequence: (\\uXXXX).")
  }

  func testBadUnicodeEscapeError3() {
    checkSyntaxError("\"bad \\uFXXX esc\"", expectedMessage: "Invalid escape sequence: (\\uFXXX).")
  }

  func testBadUnicodeEscapeError4() {
    checkSyntaxError("\"bad \\uXXXF esc\"", expectedMessage: "Invalid escape sequence: (\\uXXXF).")
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

  func testLexesSpreadDigit() {
    let source = "... 123"
    let sut = Lexer(source: source)

    let firstToken = try! sut.next()
    let secondToken = try! sut.next()

    checkTokenKindAndValue(firstToken, kind: .Spread, value: nil)
    checkTokenKindAndValue(secondToken, kind: .Int, value: "123")
  }

}

extension LexerTests {
  private func firstToken(source: String) -> Token {
    return try! Lexer(source: source).next()
  }

  private func checkTokenKindAndValue(lhs: Token, kind: TokenKind, value: String?, file: String = #file, line: UInt = #line) {
    if (lhs.kind != kind || lhs.value != value) {
      let message = "checkTokenKindAndValue failed: (\(lhs.kind), \(lhs.value)) is not equal to (\(kind), \(value))"
      recordFailureWithDescription(message, inFile: file, atLine: line, expected: true)
    }
  }

  private func checkSyntaxError(source: String, expectedMessage: String, file: String = #file, line: UInt = #line) {
    let lexer = Lexer(source: source)
    do {
      let token = try lexer.next()
      let failureMessage = "checkSyntaxError failed: did not throw but returned (\(token))"
      recordFailureWithDescription(failureMessage, inFile: file, atLine: line, expected: true)
    } catch LexerError.SyntaxError(_, _, let actualMessage) {
      if (expectedMessage != actualMessage) {
        let failureMessage = "checkSyntaxError failed: (\(actualMessage)) is not equal to (\(expectedMessage))"
        recordFailureWithDescription(failureMessage, inFile: file, atLine: line, expected: true)
      }
    } catch let error {
      let failureMessage = "checkSyntaxError failed: (\(error)) is not a (LexerError.SyntaxError)"
      recordFailureWithDescription(failureMessage, inFile: file, atLine: line, expected: true)
    }
  }
}
