import Foundation
import XCTest
@testable import GraphQL

class ParserTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testCreatesAst() {
    let sut = Parser(source: "{ node(id: 4) { id, name } }")

    let ast = try! sut.parse()

    XCTAssertEqual(ast,
      Document(definitions: [
        .Operation(OperationDefinition(type: .Query, name: nil, variableDefinitions: [], directives: [], selectionSet: SelectionSet(selections: [
          .FieldSelection(Field(alias: nil, name: Name(value: "node"), arguments: [Argument(name: Name(value: "id"), value: .IntValue("4"))], directives: [], selectionSet: SelectionSet(selections: [
            .FieldSelection(Field(alias: nil, name: Name(value: "id"), arguments: [], directives: [], selectionSet: nil)),
            .FieldSelection(Field(alias: nil, name: Name(value: "name"), arguments: [], directives: [], selectionSet: nil))
          ])))
        ])))])
    )
  }

  func testUnexpectedKeywordError() {
    let sut = Parser(source: "{ ...MissingOn }\nfragment MissingOn Type\n")

    do {
      let _ = try sut.parse()
    } catch ParserError.UnexpectedKeyword(let expectedKeyword, let actualToken) {
      XCTAssertEqual(expectedKeyword, Keyword.On)
      XCTAssertEqual(actualToken.kind, TokenKind.Name)
      XCTAssertEqual(actualToken.value, "Type")
    } catch {
      XCTFail("wrong error \(error)")
    }
  }

  func testWrongTokenKindError0() {
    let sut = Parser(source: "{ field: {} }")

    do {
      let _ = try sut.parse()
    } catch ParserError.WrongTokenKind(let expectedTokenKind, let actualTokenKind) {
      XCTAssertEqual(expectedTokenKind, TokenKind.Name)
      XCTAssertEqual(actualTokenKind, TokenKind.BraceL)
    } catch {
      XCTFail("wrong error \(error)")
    }
  }

  func testWrongTokenKindError1() {
    let sut = Parser(source: "{")

    do {
      let _ = try sut.parse()
    } catch ParserError.WrongTokenKind(let expectedToken, let actualToken) {
      XCTAssertEqual(expectedToken, TokenKind.Name)
      XCTAssertEqual(actualToken, TokenKind.EOF)
    } catch {
      XCTFail("wrong error \(error)")
    }
  }

  func testUnexpectedToken0() {
    let sut = Parser(source: "notanoperation Foo { field }")

    do {
      let _ = try sut.parse()
    } catch ParserError.UnexpectedToken(let actualToken) {
      XCTAssertEqual(actualToken.kind, TokenKind.Name)
      XCTAssertEqual(actualToken.value, "notanoperation")
    } catch {
      XCTFail("wrong error \(error)")
    }
  }

  func testUnexpectedToken1() {
    let sut = Parser(source: "...")

    do {
      let _ = try sut.parse()
    } catch ParserError.UnexpectedToken(let actualToken) {
      XCTAssertEqual(actualToken.kind, TokenKind.Spread)
    } catch {
      XCTFail("wrong error \(error)")
    }
  }

  func testParsesVariableInlineValues() {
    let sut = Parser(source: "{ field(complex: { a: { b: [ $var ] } }) }")

    do {
      let _ = try sut.parse()
    } catch {
      XCTFail("should not throw any error: \(error)")
    }
  }

  func testDoesNotAcceptFragmentsNamedOn() {
    let sut = Parser(source: "fragment on on on { on }")

    do {
      let _ = try sut.parse()
    } catch ParserError.UnexpectedToken(let actualToken) {
      XCTAssertEqual(actualToken.kind, TokenKind.Name)
      XCTAssertEqual(actualToken.value, "on")
    } catch {
      XCTFail("wrong error \(error)")
    }
  }

  func testDoesNotAcceptFragmentsSpreadOfOn() {
    let sut = Parser(source: "{ ...on }")

    do {
      let _ = try sut.parse()
    } catch ParserError.WrongTokenKind(let expectedToken, let actualToken) {
      XCTAssertEqual(expectedToken, TokenKind.Name)
      XCTAssertEqual(actualToken, TokenKind.BraceR)
    } catch {
      XCTFail("wrong error \(error)")
    }
  }

  func testDoesNotAllowNullAsAValue() {
    let sut = Parser(source: "{ fieldWithNullableStringInput(input: null) }")

    do {
      let _ = try sut.parse()
    } catch ParserError.UnexpectedToken(let actualToken) {
      XCTAssertEqual(actualToken.kind, TokenKind.Name)
      XCTAssertEqual(actualToken.value, "null")
    } catch {
      XCTFail("wrong error \(error)")
    }
  }

  func testParsesKitchenSink() {
    parseWithoutError(graphQlQuery("kitchen_sink"))
  }

  func testAllowsNonKeywordAnywhereANameIsAllowed() {
    let nonKeywords = ["on", "fragment", "query", "mutation", "subscription", "true", "false"]

    nonKeywords.forEach { keyword in
      let fragmentName = keyword == "on" ? "a" : keyword
      let source = "query \(keyword) {\n ... \(fragmentName)\n ... on \(keyword) { field }\n }\n fragment \(fragmentName) on Type {\n \(keyword)(\(keyword): $\(keyword)) @\(keyword)(\(keyword): \(keyword))\n }"

      parseWithoutError(source)
    }
  }

  func testParsesAnonymousMutationOperations() {
    parseWithoutError("\n mutation {\n mutationField\n }\n")
  }

  func testParsesAnonymousSubscriptionOperations() {
    parseWithoutError("\n subscription {\n subscriptionField\n }\n")
  }

  func testParsesNamedMutationOperations() {
    parseWithoutError("\n mutation Foo {\n mutationField\n }\n")
  }

  func testParsesNamedSubscriptionOperations() {
    parseWithoutError("\n subscription Foo {\n subscriptionField\n }\n")
  }

}

extension ParserTests {

  func parseWithoutError(source: String, file: String = #file, line: UInt = #line) {
    let sut = Parser(source: source)

    do {
      try sut.parse()
    } catch {
      recordFailureWithDescription("Unexpected error: \(error)", inFile: file, atLine: line, expected: true)
    }
  }

}
