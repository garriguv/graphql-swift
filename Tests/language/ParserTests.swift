import Foundation
import XCTest
@testable import GraphQL

class ParserTests: XCTestCase {

  var sut: Parser!

  override func setUp() {
    super.setUp()

    sut = Parser()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testCreatesAst() {
    let source = "{ node(id: 4) { id, name } }"

    let ast = sut.parse(source)

    XCTAssertEqual(ast,
      Document(definitions: [
        .Operation(OperationDefinition(type: .query, name: nil, variableDefinitions: [], directives: [], selectionSet: SelectionSet(selections: [
          .FieldSelection(Field(alias: nil, name: "node", arguments: [Argument(name: "id", value: .IntValue(4))], directives: [], selectionSet: SelectionSet(selections: [
            .FieldSelection(Field(alias: nil, name: "id", arguments: [], directives: [], selectionSet: nil)),
            .FieldSelection(Field(alias: nil, name: "name", arguments: [], directives: [], selectionSet: nil))
          ])))
        ])))])
    )
  }
}
