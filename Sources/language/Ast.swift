import Foundation

public protocol Node {}

public struct Document: Node {
  let definitions: [Definition]
}

extension Document: Equatable {}

public func == (lhs: Document, rhs: Document) -> Bool {
  return lhs.definitions == rhs.definitions
}

public enum Definition: Node {
  case Operation(OperationDefinition)
  case Fragment(FragmentDefinition)
  case Type(TypeDefinition)
  case TypeExtension(TypeExtensionDefinition)
}

extension Definition: Equatable {}

public func == (lhs: Definition, rhs: Definition) -> Bool {
  switch (lhs, rhs) {
  case (.Operation(let lhsOperation), .Operation(let rhsOperation)):
    return lhsOperation == rhsOperation
  case (.Fragment(let lhsFragment), .Fragment(let rhsFragment)):
    return lhsFragment == rhsFragment
  case (.Type(let lhsType), .Type(let rhsType)):
    return lhsType == rhsType
  case (.TypeExtension(let lhsTypeExtension), .TypeExtension(let rhsTypeExtension)):
    return lhsTypeExtension == rhsTypeExtension
  default:
    return false
  }
}

public struct VariableDefinition: Node {
  let variable: Variable
  let type: Type
  let defaultValue: Value?
}

extension VariableDefinition: Equatable {}

public func == (lhs: VariableDefinition, rhs: VariableDefinition) -> Bool {
  return lhs.variable == rhs.variable &&
    lhs.type == rhs.type &&
    lhs.defaultValue == rhs.defaultValue
}

public struct Variable: Node {
  let name: Name
}

extension Variable: Equatable {}

public func == (lhs: Variable, rhs: Variable) -> Bool {
  return lhs.name == rhs.name
}

public struct SelectionSet: Node {
  let selections: [Selection]
}

extension SelectionSet: Equatable {}

public func == (lhs: SelectionSet, rhs: SelectionSet) -> Bool {
  return lhs.selections == rhs.selections
}

public enum Selection: Node {
  case FieldSelection(Field)
  case FragmentSpreadSelection(FragmentSpread)
  case InlineFragmentSelection(InlineFragment)
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

public struct FragmentSpread: Node {
  let name: Name
  let directives: [Directive]
}

extension FragmentSpread: Equatable {}

public func == (lhs: FragmentSpread, rhs: FragmentSpread) -> Bool {
  return lhs.name == rhs.name &&
    lhs.directives == rhs.directives
}

public struct InlineFragment: Node {
  let typeCondition: Type?
  let directives: [Directive]
  let selectionSet: SelectionSet
}

extension InlineFragment: Equatable {}

public func == (lhs: InlineFragment, rhs: InlineFragment) -> Bool {
  return lhs.typeCondition == rhs.typeCondition &&
    lhs.directives == rhs.directives &&
    lhs.selectionSet == rhs.selectionSet
}

public struct FragmentDefinition: Node {
  let name: Name
  let typeCondition: Type
  let directives: [Directive]
  let selectionSet: SelectionSet
}

extension FragmentDefinition: Equatable {}

public func == (lhs: FragmentDefinition, rhs: FragmentDefinition) -> Bool {
  return lhs.name == rhs.name &&
    lhs.typeCondition == rhs.typeCondition &&
    lhs.directives == rhs.directives &&
    lhs.selectionSet == rhs.selectionSet
}

public indirect enum Value: Node {
  case VariableValue(Variable)
  case IntValue(Int)
  case FloatValue(Float)
  case StringValue(String)
  case BoolValue(Bool)
  case Enum(String)
  case List([Value])
  case Object([ObjectField])
}

extension Value: Equatable {}

public func == (lhs: Value, rhs: Value) -> Bool {
  switch (lhs, rhs) {
  case (.VariableValue(let lhsValue), .VariableValue(let rhsValue)):
    return lhsValue == rhsValue
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

public struct ObjectField: Node {
  let name: Name
  let value: Value
}

extension ObjectField: Equatable {}

public func == (lhs: ObjectField, rhs: ObjectField) -> Bool {
  return lhs.name == rhs.name &&
    lhs.value == rhs.value
}

public struct Directive: Node {
  let name: Name
  let arguments: [Argument]
}

extension Directive: Equatable {}

public func == (lhs: Directive, rhs: Directive) -> Bool {
  return lhs.name == rhs.name &&
    lhs.arguments == rhs.arguments
}

public indirect enum Type: Node {
  case Named(Name)
  case List(Type)
  case NonNull(Type)
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

public struct Argument: Node {
  let name: Name
  let value: Value
}

extension Argument: Equatable {}

public func == (lhs: Argument, rhs: Argument) -> Bool {
  return lhs.name == rhs.name &&
    lhs.value == rhs.value
}

public enum OperationType: String {
  case query, mutation, subscription
}

public struct OperationDefinition: Node {
  let type: OperationType
  let name: Name?
  let variableDefinitions: [VariableDefinition]
  let directives: [Directive]
  let selectionSet: SelectionSet
}

extension OperationDefinition: Equatable {}

public func == (lhs: OperationDefinition, rhs: OperationDefinition) -> Bool {
  return lhs.type == rhs.type &&
    lhs.name == rhs.name &&
    lhs.variableDefinitions == rhs.variableDefinitions &&
    lhs.directives == rhs.directives &&
    lhs.selectionSet == rhs.selectionSet
}

public struct Name: Node {
  let value: String?
}

extension Name: Equatable {}

public func == (lhs: Name, rhs: Name) -> Bool {
  return lhs.value == rhs.value
}

public struct Field: Node {
  let alias: Name?
  let name: Name
  let arguments: [Argument]
  let directives: [Directive]
  let selectionSet: SelectionSet?
}

extension Field: Equatable {}

public func == (lhs: Field, rhs: Field) -> Bool {
  return lhs.alias == rhs.alias &&
    lhs.name == rhs.name &&
    lhs.arguments == rhs.arguments &&
    lhs.directives == rhs.directives &&
    lhs.selectionSet == rhs.selectionSet
}

public enum TypeDefinition: Node {
  case Object(ObjectTypeDefinition)
  case Interface(InterfaceTypeDefinition)
  case Union(UnionTypeDefinition)
  case Scalar(ScalarTypeDefinition)
  case Enum(EnumTypeDefinition)
  case InputObject(InputObjectTypeDefinition)
}

extension TypeDefinition: Equatable {}

public func == (lhs: TypeDefinition, rhs: TypeDefinition) -> Bool {
  switch (lhs, rhs) {
  case (.Object(let rhsObject), .Object(let lhsObject)):
    return rhsObject == lhsObject
  case (.Interface(let rhsInterface), .Interface(let lhsInterface)):
    return rhsInterface == lhsInterface
  case (.Union(let rhsUnion), .Union(let lhsUnion)):
    return rhsUnion == lhsUnion
  case (.Scalar(let rhsScalar), .Scalar(let lhsScalar)):
    return rhsScalar == lhsScalar
  case (.Enum(let rhsEnum), .Enum(let lhsEnum)):
    return rhsEnum == lhsEnum
  case (.InputObject(let rhsInputObject), .InputObject(let lhsInputObject)):
    return rhsInputObject == lhsInputObject
  default:
    return false
  }
}

public struct ObjectTypeDefinition: Node {
  let name: Name
  let interfaces: [Type]
  let fields: [FieldDefinition]
}

extension ObjectTypeDefinition: Equatable {}

public func == (lhs: ObjectTypeDefinition, rhs: ObjectTypeDefinition) -> Bool {
  return lhs.name == rhs.name &&
    lhs.interfaces == rhs.interfaces &&
    lhs.fields == rhs.fields
}

public struct FieldDefinition: Node {
  let name: Name
  let arguments: [InputValueDefinition]
  let type: Type
}

extension FieldDefinition: Equatable {}

public func == (lhs: FieldDefinition, rhs: FieldDefinition) -> Bool {
  return lhs.name == rhs.name &&
    lhs.arguments == rhs.arguments &&
    lhs.type == rhs.type
}

public struct InputValueDefinition: Node {
  let name: Name
  let type: Type
  let defaultValue: Value?
}

extension InputValueDefinition: Equatable {}

public func == (lhs: InputValueDefinition, rhs: InputValueDefinition) -> Bool {
  return lhs.name == rhs.name &&
    lhs.type == rhs.type &&
    lhs.defaultValue == rhs.defaultValue
}

public struct InterfaceTypeDefinition: Node {
  let name: Name
  let fields: [FieldDefinition]
}

extension InterfaceTypeDefinition: Equatable {}

public func == (lhs: InterfaceTypeDefinition, rhs: InterfaceTypeDefinition) -> Bool {
  return lhs.name == rhs.name &&
    lhs.fields == rhs.fields
}

public struct UnionTypeDefinition: Node {
  let name: Name
  let types: [Type]
}

extension UnionTypeDefinition: Equatable {}

public func == (lhs: UnionTypeDefinition, rhs: UnionTypeDefinition) -> Bool {
  return lhs.name == rhs.name &&
    lhs.types == rhs.types
}

public struct ScalarTypeDefinition: Node {
  let name: Name
}

extension ScalarTypeDefinition: Equatable {}

public func == (lhs: ScalarTypeDefinition, rhs: ScalarTypeDefinition) -> Bool {
  return lhs.name == rhs.name
}

public struct EnumTypeDefinition: Node {
  let name: Name
  let values: [EnumValueDefinition]
}

extension EnumTypeDefinition: Equatable {}

public func == (lhs: EnumTypeDefinition, rhs: EnumTypeDefinition) -> Bool {
  return lhs.name == rhs.name &&
    lhs.values == rhs.values
}

public struct EnumValueDefinition: Node {
  let name: Name
}

extension  EnumValueDefinition: Equatable {}

public func == (lhs: EnumValueDefinition, rhs: EnumValueDefinition) -> Bool {
  return lhs.name == rhs.name
}

public struct InputObjectTypeDefinition: Node {
  let name: Name
  let fields: [InputValueDefinition]
}

extension InputObjectTypeDefinition: Equatable {}

public func == (lhs: InputObjectTypeDefinition, rhs: InputObjectTypeDefinition) -> Bool {
  return lhs.name == rhs.name &&
    lhs.fields == rhs.fields
}

public struct TypeExtensionDefinition: Node {
  let definition: ObjectTypeDefinition
}

extension TypeExtensionDefinition: Equatable {}

public func == (lhs: TypeExtensionDefinition, rhs: TypeExtensionDefinition) -> Bool {
  return lhs.definition == rhs.definition
}
