import Foundation

public enum TokenKind {
  case EOF, Bang, Dollar, ParenL, ParenR, Spread, Colon, Equals, At, BracketL, BracketR, BraceL, BraceR, Pipe, Name, Int, Float, String
}

public struct Token {
  let kind: TokenKind
  let start: String.UnicodeScalarView.Index
  let end: String.UnicodeScalarView.Index
  let value: String?
}

extension Token: Equatable {}

public func == (lhs: Token, rhs: Token) -> Bool {
  return lhs.kind == rhs.kind && lhs.start == rhs.start && lhs.end == rhs.end && lhs.value == rhs.value
}

enum LexerError: ErrorType {
  case UnexpectedCharacter(String.UnicodeScalarView.Index, Character)
  case InvalidCharacter(String.UnicodeScalarView.Index, Character)
  case InvalidCharacterWithinString(String.UnicodeScalarView.Index, Character)
  case InvalidEscapeSequence(String.UnicodeScalarView.Index, String)
  case UnterminatedString(String.UnicodeScalarView.Index)
  case UnexpectedCharacterInNumberAfterZero(String.UnicodeScalarView.Index, Character)
  case UnexpectedCharacterInNumber(String.UnicodeScalarView.Index, Character)
}

public class Lexer {
  private let source: String.UnicodeScalarView
  private var position: String.UnicodeScalarView.Index

  init(source: String) {
    self.source = source.unicodeScalars
    self.position = source.unicodeScalars.startIndex
  }
}

extension Lexer {
  @warn_unused_result public func next() throws -> Token {
    return try readToken()
  }
}

extension Lexer {
  private func readToken() throws -> Token {
    skipWhitespace()

    if (position >= source.endIndex) {
      return Token(kind: .EOF, start: source.endIndex, end: source.endIndex, value: nil)
    }

    let scalar = source[position]
    let code = scalar.value

    if (code < 0x0020 && code != 0x0009 && code != 0x000A && code != 0x000D) {
      throw LexerError.InvalidCharacter(position, Character(source[position]))
    }

    switch code {
    // "
    case 34:
      return try readString()
    // A-Z _ a-z
    case 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 95, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122:
      return try readName();
    // - 0-9
    case 45, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57:
      return try readNumber();
    case 33: // !
      position = position.successor()
      return Token(kind: .Bang, start: position.predecessor(), end: position, value: nil)
    case 36: // $
      position = position.successor()
      return Token(kind: .Dollar, start: position.predecessor(), end: position, value: nil)
    case 40: // (
      position = position.successor()
      return Token(kind: .ParenL, start: position.predecessor(), end: position, value: nil)
    case 41: // )
      position = position.successor()
      return Token(kind: .ParenR, start: position.predecessor(), end: position, value: nil)
    case 46: // .
      if (source[position.successor()].value == 46 && source[position.successor().successor()].value == 46) {
        let start = position
        position = position.successor().successor().successor()
        return Token(kind: .Spread, start: start, end: position, value: nil)
      }
    case 58: // :
      position = position.successor()
      return Token(kind: .Colon, start: position.predecessor(), end: position, value: nil)
    case 61: // =
      position = position.successor()
      return Token(kind: .Equals, start: position.predecessor(), end: position, value: nil)
    case 64: // @
      position = position.successor()
      return Token(kind: .At, start: position.predecessor(), end: position, value: nil)
    case 91: // [
      position = position.successor()
      return Token(kind: .BracketL, start: position.predecessor(), end: position, value: nil)
    case 93: // ]
      position = position.successor()
      return Token(kind: .BracketR, start: position.predecessor(), end: position, value: nil)
    case 123: // {
      position = position.successor()
      return Token(kind: .BraceL, start: position.predecessor(), end: position, value: nil)
    case 124: // |
      position = position.successor()
      return Token(kind: .Pipe, start: position.predecessor(), end: position, value: nil)
    case 125: // }
      position = position.successor()
      return Token(kind: .BraceR, start: position.predecessor(), end: position, value: nil)
    default:
      throw LexerError.UnexpectedCharacter(position, Character(scalar))
    }
    throw LexerError.UnexpectedCharacter(position, Character(scalar))
  }

  private func readName() throws -> Token {
    let start = position
    while (position < source.endIndex) {
      let code = source[position].value
      if (!codeIsAlphanumeric(code)) {
        break
      }
      position = position.successor()
    }

    return Token(kind: .Name, start: start, end: position.predecessor(), value: String(source[start..<position]))
  }

  private func codeIsAlphanumeric(code: UInt32) -> Bool {
    return
      code >= 48 && code <= 57 || // 0-9
      code >= 65 && code <= 90 || // A-Z
      code == 95 ||               // _
      code >= 97 && code <= 122   // a-z
  }

  private func readString() throws -> Token {
    position = position.successor()
    let start = position
    var chunkStart = start
    var value = ""

    while (position < source.endIndex) {
      var code = source[position].value
      if (
        code == 0x000A || // line feed
        code == 0x000D || // carriage return
        code == 34        // "
      ) {
        break
      }

      if (code < 0x0020 && code != 0x0009) {
        throw LexerError.InvalidCharacterWithinString(position, Character(source[position]))
      }

      position = position.successor()
      if (code == 92) {  // \\
        value += String(source[chunkStart..<position.predecessor()])
        code = source[position].value
        switch (code) {
        case 34:  // "
          value.append(UnicodeScalar(34))
        case 47:  // \/
          value.append(UnicodeScalar(47))
        case 92:  // \\
          value.append(UnicodeScalar(92))
        case 110: // \n
          value.append(UnicodeScalar(0x000A))
        case 114: // \r
          value.append(UnicodeScalar(0x000D))
        case 116: // \t
          value.append(UnicodeScalar(0x0009))
        case 117: // \u
          value.append(try unicodeCharacter())
        default:
          throw LexerError.InvalidEscapeSequence(position, "\\\(source[position].escape(asASCII: true))")
        }
        position = position.successor()
        chunkStart = position
      }
    }

    if (source[position].value != 34) {
      throw LexerError.UnterminatedString(position)
    }

    value.appendContentsOf(String(source[chunkStart..<position]))
    position = position.successor()
    return Token(kind: .String, start: start.predecessor(), end: position, value: value)
  }

  private func unicodeCharacter() throws -> UnicodeScalar {
    position = position.successor()
    let substring = String(source[position...position.successor().successor().successor()])
    guard let unicodeCode = UInt32(substring, radix: 16) else {
      throw LexerError.InvalidEscapeSequence(position, "\\u\(substring)")
    }
    position = position.successor().successor().successor()
    return UnicodeScalar(unicodeCode)
  }

  private func readNumber() throws -> Token {
    let start = position
    var isFloat = false
    var code = source[position].value

    if (code == 45) { // -
      position = position.successor()
      code = source[position].value
    }

    if (code == 48) { // 0
      position = position.successor()
      code = source[position].value
      if (code >= 48 && code <= 57) {
        throw LexerError.UnexpectedCharacterInNumberAfterZero(position, Character(source[position]))
      }
    } else {
      try readDigits()
    }

    code = source[position].value
    if (code == 46) { // .
      isFloat = true

      position = position.successor()
      try readDigits()
    }

    code = source[position].value
    if (code == 69 || code == 101) { // E e
      isFloat = true
      position = position.successor()

      code = source[position].value
      if (code == 43 || code == 45) { // - +
        position = position.successor()
      }
      try readDigits()
    }

    return Token(kind: (isFloat ? .Float : .Int), start: start, end: position, value: String(source[start..<position]))
  }

  private func readDigits() throws {
    var code = source[position].value
    if (code >= 48 && code <= 57) {
      repeat {
        position = position.successor()
        code = source[position].value
      } while (position < source.endIndex && code >= 48 && code <= 57)
    } else {
      throw LexerError.UnexpectedCharacterInNumber(position, Character(source[position]))
    }
  }

  private func skipWhitespace() {
    while (position < source.endIndex) {
      let scalar = source[position]
      let code = scalar.value
      if (
        code == 0xFEFF || // zero width no brake space
        code == 0x0009 || // horizontal tabulation
        code == 0x0020 || // space
        code == 0x000A || // line feed
        code == 0x000D || // carriage return
        code == 0x002C    // comma
      ) {
        position = position.successor()
      } else if (
        code == 35 // number sign #
      ) {
        skipComment()
      } else {
        break
      }
    }
  }

  private func skipComment() {
    while (position < source.endIndex) {
      let scalar = source[position]
      let code = scalar.value
      if (
        code == 0x000A || // line feed
        code == 0x000D    // carriage return
      ) {
        break
      }
      position = position.successor()
    }
  }

}
