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
    let renderedVariableDefinitions = _wrap("(", _join(variableDefinitions, ", "), ")")
    let renderedDirectives = _join(directives, " ")
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
    return _block(selections.map {
      $0.prettyPrint()
    })
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
      _wrap("", alias?.prettyPrint(), ": "),
      name.prettyPrint(),
      _wrap("(", _join(arguments, ", "), ")"),
      _join(directives, " "),
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
    return "...\(name.prettyPrint())" + _wrap(" ", directives.flatMap {
      $0.prettyPrint()
    }.joinWithSeparator(" "), " ")
  }
}

extension InlineFragment: PrettyPrintable {
  public func prettyPrint() -> String {
    return [
      "...",
      _wrap("on ", typeCondition?.prettyPrint()),
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
    return "@\(name.prettyPrint())" + _wrap("(", arguments.flatMap {
      $0.prettyPrint()
    }.joinWithSeparator(", "), ")")
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
      _wrap("implements ", interfaces.flatMap {
        $0.prettyPrint()
      }.joinWithSeparator(", ")),
      _block(fields.flatMap {
        $0.prettyPrint()
      })
    ].compactJoinWithSeparator(" ")
  }
}

extension FieldDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return "\(name.prettyPrint())" + _wrap("(", _join(arguments, ", "), ")")
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
    return name.prettyPrint() +
      ": " +
      "\(type.prettyPrint())" +
      _wrap(" = ", defaultValue?.prettyPrint())
  }
}

extension InterfaceTypeDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return "interface " + name.prettyPrint() + " " + _block(fields.flatMap {
      $0.prettyPrint()
    })
  }
}

extension UnionTypeDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return "union " + name.prettyPrint() + " = " + _join(types, " | ")
  }
}

extension ScalarTypeDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return "scalar " + name.prettyPrint()
  }
}

extension EnumTypeDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return "enum " + name.prettyPrint() + " " + _block(values.flatMap {
      $0.prettyPrint()
    })
  }
}

extension EnumValueDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return name.prettyPrint()
  }
}

extension InputObjectTypeDefinition: PrettyPrintable {
  public func prettyPrint() -> String {
    return "input " + name.prettyPrint() + _block(fields.flatMap {
      $0.prettyPrint()
    })
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

private func _block(array: [String]) -> String {
  return array.isEmpty ? "" : _indent("{\n" + array.joinWithSeparator("\n")) + "\n}"
}

private func _wrap(start: String, _ string: String?, _ end: String = "") -> String {
  if let string = string where !string.isEmpty {
    return start + string + end
  } else {
    return ""
  }
}

private func _join<T:CollectionType>(elements: T, _ separator: String = "") -> String {
  if elements.isEmpty {
    return ""
  } else {
    return elements.flatMap {
      $0 as? PrettyPrintable
    }.map {
      $0.prettyPrint()
    }.joinWithSeparator(separator)
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
  private func _printWithSeparator(separator: String) -> String {
    return self.flatMap {
      $0.prettyPrint()
    }.filter {
      !$0.isEmpty
    }.joinWithSeparator(separator) ?? ""
  }
}

private func _indent(string: String) -> String {
  return string.stringByReplacingOccurrencesOfString("\n", withString: "\n  ")
}
