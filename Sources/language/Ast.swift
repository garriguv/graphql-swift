import Foundation

public struct Document {
  let definitions: [Definition]
}

public enum Definition {
  case Operation(OperationDefinition)
  case Fragment(FragmentDefinition)
}

public enum OperationType {
  case query, mutation
}

public struct OperationDefinition {
  let type: OperationType
  let name: String?
  let variableDefinitions: [VariableDefinition]
  let directives: [Directive]
  let selectionSet: SelectionSet
}

public struct SelectionSet {
  let selections: [Selection]
}

public struct FragmentDefinition {
  let name: String
  let typeCondition: Type
  let directives: [Directive]
  let selectionSet: SelectionSet
}

public struct Directive {
  let name: String
  let arguments: [Argument]
}

public enum Selection {
  case FieldSelection(Field)
  case FragmentSpreadSelection(FragmentSpread)
  case InlineFragmentSelection(InlineFragment)
}

public struct Field {
  let alias: String?
  let name: String
  let arguments: [Argument]
  let directives: [Directive]
  let selectionSet: SelectionSet?
}

public struct FragmentSpread {
  let name: String
  let directives: [Directive]
}

public struct InlineFragment {
  let typeCondition: Type
  let directives: [Directive]
  let selectionSet: SelectionSet
}

public struct Argument {
  let name: String
  let value: Value
}

public indirect enum Value {
  case IntValue(Int)
  case FloatValue(Float)
  case StringValue(String)
  case BoolValue(Bool)
  case Enum(String)
  case List([Value])
  case Object([ObjectField])
}

public struct ObjectField {
  let name: String
  let value: Value
}

public indirect enum Type {
  case Named(String)
  case List([Type])
  case NonNull(Type)
}

public struct VariableDefinition {
  let name: String
  let type: Type
  let defaultValue: Value?
}

extension Document: Equatable {}

public func == (lhs: Document, rhs: Document) -> Bool {
  return lhs.definitions == rhs.definitions
}

extension Definition: Equatable {}

public func == (lhs: Definition, rhs: Definition) -> Bool {
  switch (lhs, rhs) {
  case (.Operation(let lhsOperation), .Operation(let rhsOperation)):
    return lhsOperation == rhsOperation
  case (.Fragment(let lhsFragment), .Fragment(let rhsFragment)):
    return lhsFragment == rhsFragment
  default:
    return false
  }
}

extension OperationDefinition: Equatable {}

public func == (lhs: OperationDefinition, rhs: OperationDefinition) -> Bool {
  return lhs.type == rhs.type &&
    lhs.name == rhs.name &&
    lhs.variableDefinitions == rhs.variableDefinitions &&
    lhs.directives == rhs.directives &&
    lhs.selectionSet == rhs.selectionSet
}

extension SelectionSet: Equatable {}

public func == (lhs: SelectionSet, rhs: SelectionSet) -> Bool {
  return lhs.selections == rhs.selections
}

extension FragmentDefinition: Equatable {}

public func == (lhs: FragmentDefinition, rhs: FragmentDefinition) -> Bool {
  return lhs.name == rhs.name &&
    lhs.typeCondition == rhs.typeCondition &&
    lhs.directives == rhs.directives &&
    lhs.selectionSet == rhs.selectionSet
}

extension Directive: Equatable {}

public func == (lhs: Directive, rhs: Directive) -> Bool {
  return lhs.name == rhs.name &&
    lhs.arguments == rhs.arguments
}

extension Selection: Equatable {}

public func == (lhs: Selection, rhs: Selection) -> Bool {
  switch (lhs, rhs) {
  case (.FieldSelection(let lhsField), .FieldSelection(let rhsField)):
    return lhsField == rhsField
  case (.FragmentSpreadSelection(let lhsFragmentSpread), .FragmentSpreadSelection(let rhsFragmentSpread)):
    return lhsFragmentSpread == rhsFragmentSpread
  case (.InlineFragmentSelection(let lhsInlineFragment), .InlineFragmentSelection(let rhsInlineFragment)):
    return lhsInlineFragment == rhsInlineFragment
  default:
    return false
  }
}

extension Field: Equatable {}

public func == (lhs: Field, rhs: Field) -> Bool {
  return lhs.alias == rhs.alias &&
    lhs.name == rhs.name &&
    lhs.arguments == rhs.arguments &&
    lhs.directives == rhs.directives &&
    lhs.selectionSet == rhs.selectionSet
}

extension FragmentSpread: Equatable {}

public func == (lhs: FragmentSpread, rhs: FragmentSpread) -> Bool {
  return lhs.name == rhs.name &&
    lhs.directives == rhs.directives
}

extension InlineFragment: Equatable {}

public func == (lhs: InlineFragment, rhs: InlineFragment) -> Bool {
  return lhs.typeCondition == rhs.typeCondition &&
    lhs.directives == rhs.directives &&
    lhs.selectionSet == rhs.selectionSet
}

extension Argument: Equatable {}

public func == (lhs: Argument, rhs: Argument) -> Bool {
  return lhs.name == rhs.name &&
    lhs.value == rhs.value
}

extension Value: Equatable {}

public func == (lhs: Value, rhs: Value) -> Bool {
  switch (lhs, rhs) {
  case (.IntValue(let lhsValue), .IntValue(let rhsValue)):
    return lhsValue == rhsValue
  case (.FloatValue(let lhsValue), .FloatValue(let rhsValue)):
    return lhsValue == rhsValue
  case (.StringValue(let lhsValue), .StringValue(let rhsValue)):
    return lhsValue == rhsValue
  case (.BoolValue(let lhsValue), .BoolValue(let rhsValue)):
    return lhsValue == rhsValue
  case (.Enum(let lhsValue), .Enum(let rhsValue)):
    return lhsValue == rhsValue
  case (.List(let lhsValue), .List(let rhsValue)):
    return lhsValue == rhsValue
  case (.Object(let lhsValue), .Object(let rhsValue)):
    return lhsValue == rhsValue
  default:
    return false
  }
}

extension ObjectField: Equatable {}

public func == (lhs: ObjectField, rhs: ObjectField) -> Bool {
  return lhs.name == rhs.name &&
    lhs.value == rhs.value
}

extension Type: Equatable {}

public func == (lhs: Type, rhs: Type) -> Bool {
  switch (lhs, rhs) {
  case (.Named(let lhsName), .Named(let rhsName)):
    return lhsName == rhsName
  case (.List(let lhsList), .List(let rhsList)):
    return lhsList == rhsList
  case (.NonNull(let lhsType), .NonNull(let rhsType)):
    return lhsType == rhsType
  default:
    return false
  }
}

extension VariableDefinition: Equatable {}

public func == (lhs: VariableDefinition, rhs: VariableDefinition) -> Bool {
  return lhs.name == rhs.name &&
    lhs.type == rhs.type &&
    lhs.defaultValue == rhs.defaultValue
}

