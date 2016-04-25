import Foundation

public protocol PrettyPrintable {
  func prettyPrint() -> String
}

extension Document: PrettyPrintable {
  public func prettyPrint() -> String {
    return definitions.flatMap {
      $0.prettyPrint()
    }.joinWithSeparator("\n\n") + "\n"
  }
}

extension Definition: PrettyPrintable {
  public func prettyPrint() -> String {
    switch self {
    case Definition.Operation(let operationDefinition):
      return operationDefinition.prettyPrint()
    case Definition.Fragment(let fragmentDefinition):
      return fragmentDefinition.prettyPrint()
    case Definition.Type(let typeDefinition):
      return typeDefinition.prettyPrint()
    case Definition.TypeExtension(let typeExtensionDefinition):
      return typeExtensionDefinition.prettyPrint()
    }
  }
}

extension OperationDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    let renderedVariableDefinitions = variableDefinitions.prettyPrintWithSeparator(", ").surroundWith("(", ")")
    let renderedDirectives = directives.prettyPrintWithSeparator(" ")
    if type == .query && name == nil && renderedDirectives.isEmpty && renderedVariableDefinitions.isEmpty {
      return selectionSet.prettyPrint()
    } else {
      let arr = [
        type.rawValue,
        [
          name?.prettyPrint(),
          renderedVariableDefinitions
          ].compactJoinWithSeparator(""),
        renderedDirectives,
        selectionSet.prettyPrint()
        ].compactJoinWithSeparator(" ")
      return arr
    }
  }
}

extension VariableDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    var variableString = "\(variable.prettyPrint()): \(type.prettyPrint())"
    if let defaultValue = defaultValue {
      variableString += " = \(defaultValue.prettyPrint())"
    }
    return variableString
  }
}

extension SelectionSet: PrettyPrintable {
  public func prettyPrint() -> String {
    return selections.prettyPrintBlock()
  }
}

extension Selection: PrettyPrintable {
  public func prettyPrint() -> String {
    switch self {
    case Selection.FieldSelection(let field):
      return field.prettyPrint()
    case Selection.FragmentSpreadSelection(let fragmentSpread):
      return fragmentSpread.prettyPrint()
    case Selection.InlineFragmentSelection(let inlineFragment):
      return inlineFragment.prettyPrint()
    }
  }
}

extension Field: PrettyPrintable {
  public func prettyPrint() -> String {
    return [
      alias?.prettyPrint().surroundWith("", ": "),
      name.prettyPrint(),
      arguments.prettyPrintWithSeparator(", ").surroundWith("(", ")"),
      directives.prettyPrintWithSeparator(" "),
      selectionSet?.prettyPrint()
    ].compactJoinWithSeparator(" ")
  }
}

extension Argument: PrettyPrintable {
  public func prettyPrint() -> String {
    return [name.prettyPrint(), value.prettyPrint()].compactJoinWithSeparator(": ")
  }
}

extension FragmentSpread: PrettyPrintable {
  public func prettyPrint() -> String {
    return "...\(name.prettyPrint())" + directives.prettyPrintWithSeparator(" ").surroundWith(" ", " ")
  }
}

extension InlineFragment: PrettyPrintable {
  public func prettyPrint() -> String {
    return [
      "...",
      typeCondition?.prettyPrint().surroundWith("on "),
      directives.flatMap {
        $0.prettyPrint()
      }.joinWithSeparator(" "),
      selectionSet.prettyPrint()
    ].compactJoinWithSeparator(" ")
  }
}

extension FragmentDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return [
      "fragment",
      name.prettyPrint(),
      "on",
      typeCondition.prettyPrint(),
      directives.flatMap {
        $0.prettyPrint()
      }.joinWithSeparator(" "),
      selectionSet.prettyPrint()
    ].compactJoinWithSeparator(" ")
  }
}

extension Value: PrettyPrintable {
  public func prettyPrint() -> String {
    switch self {
    case Value.IntValue(let value):
      return "\(value)"
    case Value.FloatValue(let value):
      return "\(value)"
    case Value.StringValue(let value):
      return "\"\(value)\""
    case Value.BoolValue(let value):
      return "\(value)"
    case Value.Enum(let value):
      return "\(value)"
    case Value.VariableValue(let variable):
      return variable.prettyPrint()
    case Value.List(let values):
      return "[" + values.flatMap {
        $0.prettyPrint()
      }.joinWithSeparator(", ") + "]"
    case Value.Object(let fields):
      return "{" + fields.flatMap {
        $0.prettyPrint()
      }.joinWithSeparator(", ") + "}"
    }
  }
}

extension ObjectField: PrettyPrintable {
  public func prettyPrint() -> String {
    return "\(name.prettyPrint()): \(value.prettyPrint())"
  }
}

extension Directive: PrettyPrintable {
  public func prettyPrint() -> String {
    return "@\(name.prettyPrint())" + arguments.prettyPrintWithSeparator(", ").surroundWith("(", ")")
  }
}

extension Type: PrettyPrintable {
  public func prettyPrint() -> String {
    switch self {
    case Type.List(let type):
      return "[\(type.prettyPrint())]"
    case Type.NonNull(let type):
      return "\(type.prettyPrint())!"
    case Type.Named(let name):
      return name.prettyPrint()
    }
  }
}

extension ObjectTypeDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return [
      "type",
      name.prettyPrint(),
      interfaces.prettyPrintWithSeparator(", ").surroundWith("implements "),
      fields.prettyPrintBlock()
    ].compactJoinWithSeparator(" ")
  }
}

extension FieldDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return "\(name.prettyPrint())" + arguments.prettyPrintWithSeparator(", ").surroundWith("(", ")")
  }
}

extension TypeDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    switch self {
    case Object(let definition):
      return definition.prettyPrint()
    case Interface(let definition):
      return definition.prettyPrint()
    case Union(let definition):
      return definition.prettyPrint()
    case Scalar(let definition):
      return definition.prettyPrint()
    case Enum(let definition):
      return definition.prettyPrint()
    case InputObject(let definition):
      return definition.prettyPrint()
    }
  }
}

extension InputValueDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return name.prettyPrint() + ": " + "\(type.prettyPrint())" + (defaultValue?.prettyPrint().surroundWith(" = ") ?? "")
  }
}

extension InterfaceTypeDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return "interface " + name.prettyPrint() + " " + fields.prettyPrintBlock()
  }
}

extension UnionTypeDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return "union " + name.prettyPrint() + " = " + types.prettyPrintWithSeparator(" | ")
  }
}

extension ScalarTypeDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return "scalar " + name.prettyPrint()
  }
}

extension EnumTypeDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return "enum " + name.prettyPrint() + " " + values.prettyPrintBlock()
  }
}

extension EnumValueDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return name.prettyPrint()
  }
}

extension InputObjectTypeDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return "input " + name.prettyPrint() + fields.prettyPrintBlock()
  }
}

extension TypeExtensionDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return "extend " + (definition.prettyPrint() ?? "")
  }
}

extension Variable: PrettyPrintable {
  public func prettyPrint() -> String {
    return "$\(name.prettyPrint())"
  }
}

extension Name: PrettyPrintable {
  public func prettyPrint() -> String {
    return value ?? ""
  }
}

extension SequenceType where Generator.Element == String? {
  private func compactJoinWithSeparator(separator: String) -> String {
    return self.flatMap {
      $0
    }.filter {
      !$0.isEmpty
    }.joinWithSeparator(separator) ?? ""
  }
}

extension SequenceType where Generator.Element: PrettyPrintable {
  private func prettyPrintWithSeparator(separator: String) -> String {
    return self.flatMap {
      $0.prettyPrint()
    }.filter {
      !$0.isEmpty
    }.joinWithSeparator(separator) ?? ""
  }

  private func prettyPrintBlock() -> String {
    return self.flatMap {
      $0.prettyPrint()
    }.filter {
      !$0.isEmpty
    }.block() ?? ""
  }
}

extension CollectionType where Generator.Element == String {
  private func block() -> String {
    if self.isEmpty {
      return ""
    } else {
      return ("{\n" + joinWithSeparator("\n")).indent() + "\n}"
    }
  }
}

extension String {
  private func indent() -> String {
    return stringByReplacingOccurrencesOfString("\n", withString: "\n  ")
  }

  private func surroundWith(left: String, _ right: String = "") -> String {
    if isEmpty {
      return ""
    } else {
      return left + self + right
    }
  }
}
