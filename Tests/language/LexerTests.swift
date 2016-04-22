import Foundation
import XCTest
@testable import GraphQL

class LexerTests: XCTestCase {

  func testAcceptsBOMHeader() {
    checkTokenKindAndValue(lexOne("\u{FEFF} foo"), kind: .Name, value: "foo")
  }

  func testSkipsWhitespace() {
    checkTokenKindAndValue(lexOne("   \n  foo\n    \n"), kind: .Name, value: "foo")
  }

  func testSkipsComments() {
    checkTokenKindAndValue(lexOne("\n#comment\nfoo#comment"), kind: .Name, value: "foo")
  }

  func testSkipsCommas() {
    checkTokenKindAndValue(lexOne(",,,foo,,,"), kind: .Name, value: "foo")
  }

  func testLexesSimpleString() {
    checkTokenKindAndValue(lexOne("\"simple\""), kind: .String, value: "simple")
  }

  func testLexesWhiteSpaceString() {
    checkTokenKindAndValue(lexOne("\" white space \""), kind: .String, value: " white space ")
  }

  func testLexesQuote() {
    checkTokenKindAndValue(lexOne("\"escaped \\\"\""), kind: .String, value: "escaped \"")
  }

  func testLexesEscapedChars() {
    checkTokenKindAndValue(lexOne("\"escaped \\n\\r\\t\""), kind: .String, value: "escaped \n\r\t")
  }

  func testLexesSlashes() {
    checkTokenKindAndValue(lexOne("\"slashes \\\\ \\/\""), kind: .String, value: "slashes \\ /")
  }

  func testLexesUnicode() {
    checkTokenKindAndValue(lexOne("\"unicode \\u1234\\u5678\\u90AB\\uCDEF\""), kind: .String, value: "unicode \u{1234}\u{5678}\u{90AB}\u{CDEF}")
  }

  func testLexesZero() {
    checkTokenKindAndValue(lexOne("0"), kind: .Int, value: "0")
  }

  func testLexesInt() {
    checkTokenKindAndValue(lexOne("42"), kind: .Int, value: "42")
  }

  func testLexesNegativeInt() {
    checkTokenKindAndValue(lexOne("-9"), kind: .Int, value: "-9")
  }

  func testLexesFloat() {
    checkTokenKindAndValue(lexOne("1.234"), kind: .Float, value: "1.234")
  }

  func testLexesNegativeFloat() {
    checkTokenKindAndValue(lexOne("-1.234"), kind: .Float, value: "-1.234")
  }

  func testLexesSmallFloat() {
    checkTokenKindAndValue(lexOne("0.234"), kind: .Float, value: "0.234")
  }

  func testLexesSmallExponents() {
    checkTokenKindAndValue(lexOne("123e4"), kind: .Float, value: "123e4")
  }

  func testLexesBigExponents() {
    checkTokenKindAndValue(lexOne("123E4"), kind: .Float, value: "123E4")
  }

  func testLexesSmallNegativeExponents() {
    checkTokenKindAndValue(lexOne("123e-4"), kind: .Float, value: "123e-4")
  }

  func testLexesBigNegativeExponents() {
    checkTokenKindAndValue(lexOne("123E-4"), kind: .Float, value: "123E-4")
  }

  func testLexesNegativeSmallExponents() {
    checkTokenKindAndValue(lexOne("-123e4"), kind: .Float, value: "-123e4")
  }

  func testLexesNegativeBigExponents() {
    checkTokenKindAndValue(lexOne("-123E4"), kind: .Float, value: "-123E4")
  }

  func testLexesNegativeSmallNegativeExponents() {
    checkTokenKindAndValue(lexOne("-123e-4"), kind: .Float, value: "-123e-4")
  }

  func testLexesNegativeBigNegativeExponents() {
    checkTokenKindAndValue(lexOne("-123E-4"), kind: .Float, value: "-123E-4")
  }

  func testLexesDecimalSmallExponents() {
    checkTokenKindAndValue(lexOne("1.23e4"), kind: .Float, value: "1.23e4")
  }

  func testLexesDecimalBigExponents() {
    checkTokenKindAndValue(lexOne("1.23E4"), kind: .Float, value: "1.23E4")
  }

  func testLexesDecimalSmallNegativeExponents() {
    checkTokenKindAndValue(lexOne("1.23e-4"), kind: .Float, value: "1.23e-4")
  }

  func testLexesDecimalBigNegativeExponents() {
    checkTokenKindAndValue(lexOne("1.23E-4"), kind: .Float, value: "1.23E-4")
  }

  func testLexesDecimalNegativeSmallExponents() {
    checkTokenKindAndValue(lexOne("-1.23e4"), kind: .Float, value: "-1.23e4")
  }

  func testLexesDecimalNegativeBigExponents() {
    checkTokenKindAndValue(lexOne("-1.23E4"), kind: .Float, value: "-1.23E4")
  }

  func testLexesDecimalNegativeSmallNegativeExponents() {
    checkTokenKindAndValue(lexOne("-1.23e-4"), kind: .Float, value: "-1.23e-4")
  }

  func testLexesDecimalNegativeBigNegativeExponents() {
    checkTokenKindAndValue(lexOne("-1.23E-4"), kind: .Float, value: "-1.23E-4")
  }

  func testLexesBang() {
    checkTokenKindAndValue(lexOne("!"), kind: .Bang, value: nil)
  }

  func testLexesDollar() {
    checkTokenKindAndValue(lexOne("$"), kind: .Dollar, value: nil)
  }

  func testLexesParenL() {
    checkTokenKindAndValue(lexOne("("), kind: .ParenL, value: nil)
  }

  func testLexesParenR() {
    checkTokenKindAndValue(lexOne(")"), kind: .ParenR, value: nil)
  }

  func testLexesSpread() {
    checkTokenKindAndValue(lexOne("..."), kind: .Spread, value: nil)
  }

  func testLexesColon() {
    checkTokenKindAndValue(lexOne(":"), kind: .Colon, value: nil)
  }

  func testLexesEquals() {
    checkTokenKindAndValue(lexOne("="), kind: .Equals, value: nil)
  }

  func testLexesAt() {
    checkTokenKindAndValue(lexOne("@"), kind: .At, value: nil)
  }

  func testLexesBracketL() {
    checkTokenKindAndValue(lexOne("["), kind: .BracketL, value: nil)
  }

  func testLexesBracketR() {
    checkTokenKindAndValue(lexOne("]"), kind: .BracketR, value: nil)
  }

  func testLexesBraceL() {
    checkTokenKindAndValue(lexOne("{"), kind: .BraceL, value: nil)
  }

  func testLexesBraceR() {
    checkTokenKindAndValue(lexOne("}"), kind: .BraceR, value: nil)
  }

  func testLexesPipe() {
    checkTokenKindAndValue(lexOne("|"), kind: .Pipe, value: nil)
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
  private func lexOne(source: String) -> Token {
    return try! Lexer(source: source).next()
  }

  private func checkTokenKindAndValue(lhs: Token, kind: TokenKind, value: String?, file: String = #file, line: UInt = #line) {
    if (lhs.kind != kind || lhs.value != value) {
      let message = "checkTokenKindAndValue failed: (\(lhs.kind), \(lhs.value)) is not equal to (\(kind), \(value))"
      recordFailureWithDescription(message, inFile: file, atLine: line, expected: true)
    }
  }
}
