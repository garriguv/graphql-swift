import Foundation

public func print(node: Node) -> String {
  return _print(node) ?? ""
}

private func _print(node: Node?) -> String {
  guard let node = node else {
    return ""
  }
  switch node {
  case let document as Document:
    return document.definitions.flatMap { _print($0) }.joinWithSeparator("\n\n") + "\n"
  case Definition.Operation(let operationDefinition):
    return _print(operationDefinition)
  case Definition.Fragment(let fragmentDefinition):
    return _print(fragmentDefinition)
  case Definition.Type(let typeDefinition):
    return _print(typeDefinition)
  case Definition.TypeExtension(let typeExtensionDefinition):
    return _print(typeExtensionDefinition)
  case let operationDefinition as OperationDefinition:
    let variableDefinitions = "(" + operationDefinition.variableDefinitions.flatMap { _print($0) }.joinWithSeparator(", ") + ")"
    let directives = operationDefinition.directives.flatMap { _print($0) }.joinWithSeparator(" ")
    if operationDefinition.type == .query && operationDefinition.name == nil && operationDefinition.directives.isEmpty && operationDefinition.variableDefinitions.isEmpty {
      return _print(operationDefinition.selectionSet)
    } else {
      return [
        operationDefinition.type.rawValue,
        [
          _print(operationDefinition.name),
          variableDefinitions
        ].compactJoinWithSeparator(""),
        directives,
        _print(operationDefinition.selectionSet)
      ].compactJoinWithSeparator(" ")
    }
  case let variableDefinition as VariableDefinition:
    var variableString = "\(_print(variableDefinition.variable)): \(_print(variableDefinition.type))"
    if let defaultValue = variableDefinition.defaultValue {
      variableString += " = \(_print(defaultValue))"
    }
    return variableString
  case let selectionSet as SelectionSet:
    return _block(selectionSet.selections.flatMap { _print($0) })
  case Selection.FieldSelection(let field):
    return _print(field)
  case Selection.FragmentSpreadSelection(let fragmentSpread):
    return _print(fragmentSpread)
  case Selection.InlineFragmentSelection(let inlineFragment):
    return _print(inlineFragment)
  case let field as Field:
    return [
      _wrap("", _print(field.alias), ": "),
      _print(field.name),
      _wrap("(", _join(field.arguments, ", "),")"),
      _join(field.directives, " "),
      _print(field.selectionSet)
    ].compactJoinWithSeparator(" ")
  case let argument as Argument:
    return [_print(argument.name), _print(argument.value)].compactJoinWithSeparator(": ")
  case let fragmentSpread as FragmentSpread:
    return "...\(_print(fragmentSpread.name))" + _wrap(" ", fragmentSpread.directives.flatMap { _print($0) }.joinWithSeparator(" "), " ")
  case let inlineFragment as InlineFragment:
    return [
      "...",
      _wrap("on ", _print(inlineFragment.typeCondition)),
      inlineFragment.directives.flatMap { _print($0) }.joinWithSeparator(" "),
      _print(inlineFragment.selectionSet)
      ].compactJoinWithSeparator(" ")
  case let fragmentDefinition as FragmentDefinition:
    return [
      "fragment",
      _print(fragmentDefinition.name),
      "on",
      _print(fragmentDefinition.typeCondition),
      fragmentDefinition.directives.flatMap { _print($0) }.joinWithSeparator(" "),
      _print(fragmentDefinition.selectionSet)
      ].compactJoinWithSeparator(" ")
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
    return "$\(_print(variable.name))"
  case Value.List(let values):
    return "[" + values.flatMap { _print($0) }.joinWithSeparator(", ") + "]"
  case Value.Object(let fields):
    return "{" + fields.flatMap { _print($0) }.joinWithSeparator(", ") + "}"
  case let objectField as ObjectField:
    return "\(_print(objectField.name)): \(_print(objectField.value))"
  case let directive as Directive:
    return "@\(_print(directive.name))" + _wrap("(", directive.arguments.flatMap { _print($0) }.joinWithSeparator(", "), ")")
  case Type.List(let type):
    return "[\(_print(type))]"
  case Type.NonNull(let type):
    return "\(_print(type))!"
  case Type.Named(let name):
    return _print(name)
  case let objectTypeDefinition as ObjectTypeDefinition:
    return [
      "type",
      _print(objectTypeDefinition.name),
      _wrap("implements ", objectTypeDefinition.interfaces.flatMap { _print($0) }.joinWithSeparator(", ")),
      _block(objectTypeDefinition.fields.flatMap { _print($0) })
      ].compactJoinWithSeparator(" ")
  case let fieldDefinition as FieldDefinition:
    return "\(_print(fieldDefinition.name))" + _wrap("(", _join(fieldDefinition.arguments, ", "), ")")
  case let inputValueDefinition as InputValueDefinition:
    return _print(inputValueDefinition.name) +
      ": " +
      "\(_print(inputValueDefinition.type))" +
      _wrap(" = ", _print(inputValueDefinition.defaultValue))
  case let interfaceTypeDefinition as InterfaceTypeDefinition:
    return "interface " + _print(interfaceTypeDefinition.name) + " " + _block(interfaceTypeDefinition.fields.flatMap { _print($0) })
  case let unionTypeDefinition as UnionTypeDefinition:
    return "union " + _print(unionTypeDefinition.name) + " = " + _join(unionTypeDefinition.types, " | ")
  case let scalarTypeDefinition as ScalarTypeDefinition:
    return "scalar " + _print(scalarTypeDefinition.name)
  case let enumTypeDefinition as EnumTypeDefinition:
    return "enum " + _print(enumTypeDefinition.name) + " " + _block(enumTypeDefinition.values.flatMap { _print($0) })
  case let enumValueDefinition as EnumValueDefinition:
    return _print(enumValueDefinition.name)
  case let inputObjectTypeDefinition as InputObjectTypeDefinition:
    return "input " + _print(inputObjectTypeDefinition.name) + _block(inputObjectTypeDefinition.fields.flatMap { _print($0) })
  case let typeExtensionDefinition as TypeExtensionDefinition:
    return "extend " + (_print(typeExtensionDefinition.definition) ?? "")
  case let variable as Variable:
    return "$\(_print(variable.name))"
  case let name as Name:
    return name.value ?? ""
  default:
    return "NOT IMPLEMENTED \(node)"
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

private func _join<T: CollectionType>(elements: T, _ separator: String = "") -> String {
  if elements.isEmpty {
    return ""
  } else {
    return elements.flatMap { $0 as? Node}.flatMap { _print($0) }.joinWithSeparator(separator)
  }
}

extension SequenceType where Generator.Element == String? {
  private func compactJoinWithSeparator(separator: String) -> String {
    return self.flatMap { $0 }.filter { !$0.isEmpty }.joinWithSeparator(separator) ?? ""
  }
}

extension SequenceType where Generator.Element == Node? {
  private func _printWithSeparator(separator: String) -> String {
    return self.flatMap { _print($0) }.filter { !$0.isEmpty }.joinWithSeparator(separator) ?? ""
  }
}

private func _indent(string: String) -> String {
  return string.stringByReplacingOccurrencesOfString("\n", withString: "\n  ")
}
