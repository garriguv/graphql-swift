import Foundation

func graphQlQuery(name: String) -> String {
  let bundle = NSBundle(forClass: LexerTests.self)
  guard let queryURL = bundle.URLForResource(name, withExtension: "graphql") else {
    fatalError("GraphQL query not found: \(name).")
  }
  return try! String(contentsOfURL: queryURL, encoding: NSUTF8StringEncoding)
}
