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
        .Operation(OperationDefinition(type: .query, name: nil, variableDefinitions: [], directives: [], selectionSet: SelectionSet(selections: [
          .FieldSelection(Field(alias: nil, name: Name(value: "node"), arguments: [Argument(name: Name(value: "id"), value: .IntValue(4))], directives: [], selectionSet: SelectionSet(selections: [
            .FieldSelection(Field(alias: nil, name: Name(value: "id"), arguments: [], directives: [], selectionSet: nil)),
            .FieldSelection(Field(alias: nil, name: Name(value: "name"), arguments: [], directives: [], selectionSet: nil))
          ])))
        ])))])
    )
  }
}
