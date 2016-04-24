import Foundation

public typealias VisitorFunction = (Node) -> ()

public func visit(node: Node, enter: VisitorFunction, leave: VisitorFunction) {
  enter(node)

  switch node {
  case let document as Document:
    document.definitions.forEach { visit($0, enter: enter, leave: leave) }
  case Definition.Operation(let operationDefinition):
    visit(operationDefinition, enter: enter, leave: leave)
  case Definition.Fragment(let fragmentDefinition):
    visit(fragmentDefinition, enter: enter, leave: leave)
  case Definition.Type(let typeDefinition):
    visit(typeDefinition, enter: enter, leave: leave)
  case Definition.TypeExtension(let typeExtensionDefinition):
    visit(typeExtensionDefinition.definition, enter: enter, leave: leave)
  case let variableDefinition as VariableDefinition:
    visit(variableDefinition.variable, enter: enter, leave: leave)
    visit(variableDefinition.type, enter: enter, leave: leave)
    if let defaulValue = variableDefinition.defaultValue {
      visit(defaulValue, enter: enter, leave: leave)
    }
  case let variable as Variable:
    visit(variable.name, enter: enter, leave: leave)
  case let selectionSet as SelectionSet:
    selectionSet.selections.forEach { visit($0, enter: enter, leave: leave) }
  case Selection.FieldSelection(let field):
    visit(field, enter: enter, leave: leave)
  case Selection.FragmentSpreadSelection(let fragmentSpread):
    visit(fragmentSpread, enter: enter, leave: leave)
  case Selection.InlineFragmentSelection(let inlineFragment):
    visit(inlineFragment, enter: enter, leave: leave)
  case let fragmentSpread as FragmentSpread:
    visit(fragmentSpread.name, enter: enter, leave: leave)
    fragmentSpread.directives.forEach { visit($0, enter: enter, leave: leave) }
  case let inlineFragment as InlineFragment:
    if let typeCondition = inlineFragment.typeCondition {
      visit(typeCondition, enter: enter, leave: leave)
    }
    inlineFragment.directives.forEach { visit($0, enter: enter, leave: leave)}
    visit(inlineFragment.selectionSet, enter: enter, leave: leave)
  case let fragmentDefinition as FragmentDefinition:
    visit(fragmentDefinition.name, enter: enter, leave: leave)
    visit(fragmentDefinition.typeCondition, enter: enter, leave: leave)
    fragmentDefinition.directives.forEach { visit($0, enter: enter, leave: leave) }
    visit(fragmentDefinition.selectionSet, enter: enter, leave: leave)
  case Value.VariableValue(let variable):
    visit(variable, enter: enter, leave: leave)
  case Value.IntValue:
    break
  case Value.FloatValue:
    break
  case Value.StringValue:
    break
  case Value.BoolValue:
    break
  case Value.Enum:
    break
  case Value.List(let values):
    values.forEach { visit($0, enter: enter, leave: leave) }
  case Value.Object(let objectFields):
    objectFields.forEach { visit($0, enter: enter, leave: leave) }
  case let objectField as ObjectField:
    visit(objectField.name, enter: enter, leave: leave)
    visit(objectField.value, enter: enter, leave: leave)
  case let directive as Directive:
    visit(directive.name, enter: enter, leave: leave)
  case Type.Named(let name):
    visit(name, enter: enter, leave: leave)
  case Type.List(let type):
    visit(type, enter: enter, leave: leave)
  case Type.NonNull(let type):
    visit(type, enter: enter, leave: leave)
  case let argument as Argument:
    visit(argument.name, enter: enter, leave: leave)
    visit(argument.value, enter: enter, leave: leave)
  case let operationDefinition as OperationDefinition:
    if let name = operationDefinition.name {
      visit(name, enter: enter, leave: leave)
    }
    operationDefinition.variableDefinitions.forEach { visit($0, enter: enter, leave: leave) }
    operationDefinition.directives.forEach { visit($0, enter: enter, leave: leave) }
    visit(operationDefinition.selectionSet, enter: enter, leave: leave)
  case is Name:
    break
  case let field as Field:
    if let alias = field.alias {
      visit(alias, enter: enter, leave: leave)
    }
    visit(field.name, enter: enter, leave: leave)
    field.arguments.forEach { visit($0, enter: enter, leave: leave) }
    field.directives.forEach { visit($0, enter: enter, leave: leave) }
    if let selectionSet = field.selectionSet {
      visit(selectionSet, enter: enter, leave: leave)
    }
  case TypeDefinition.Object(let objectTypeDefinition):
    visit(objectTypeDefinition, enter: enter, leave: leave)
  case TypeDefinition.Interface(let interfaceTypeDefinition):
    visit(interfaceTypeDefinition, enter: enter, leave: leave)
  case TypeDefinition.Union(let unionTypeDefinition):
    visit(unionTypeDefinition, enter: enter, leave: leave)
  case TypeDefinition.Scalar(let scalarTypeDefinition):
    visit(scalarTypeDefinition, enter: enter, leave: leave)
  case TypeDefinition.Enum(let enumTypeDefinition):
    visit(enumTypeDefinition, enter: enter, leave: leave)
  case TypeDefinition.InputObject(let inputObjectTypeDefinition):
    visit(inputObjectTypeDefinition, enter: enter, leave: leave)
  case let objectTypeDefinition as ObjectTypeDefinition:
    visit(objectTypeDefinition.name, enter: enter, leave: leave)
    objectTypeDefinition.interfaces.forEach { visit($0, enter: enter, leave: leave) }
    objectTypeDefinition.fields.forEach { visit($0, enter: enter, leave: leave) }
  case let fieldDefinition as FieldDefinition:
    visit(fieldDefinition.name, enter: enter, leave: leave)
    fieldDefinition.arguments.forEach { visit($0, enter: enter, leave: leave) }
    visit(fieldDefinition.type, enter: enter, leave: leave)
  case let inputValueDefinition as InputValueDefinition:
    visit(inputValueDefinition.name, enter: enter, leave: leave)
    visit(inputValueDefinition.type, enter: enter, leave: leave)
    if let defaultValue = inputValueDefinition.defaultValue {
      visit(defaultValue, enter: enter, leave: leave)
    }
  case let interfaceTypeDefinition as InterfaceTypeDefinition:
    visit(interfaceTypeDefinition.name, enter: enter, leave: leave)
    interfaceTypeDefinition.fields.forEach { visit($0, enter: enter, leave: leave) }
  case let unionTypeDefinition as UnionTypeDefinition:
    visit(unionTypeDefinition.name, enter: enter, leave: leave)
    unionTypeDefinition.types.forEach { visit($0, enter: enter, leave: leave) }
  case let scalarTypeDefinition as ScalarTypeDefinition:
    visit(scalarTypeDefinition.name, enter: enter, leave: leave)
  case let enumTypeDefinition as EnumTypeDefinition:
    visit(enumTypeDefinition.name, enter: enter, leave: leave)
    enumTypeDefinition.values.forEach { visit($0, enter: enter, leave: leave) }
  case let enumValutDefinition as EnumValueDefinition:
    visit(enumValutDefinition.name, enter: enter, leave: leave)
  case let inputObjectTypeDefinition as InputObjectTypeDefinition:
    visit(inputObjectTypeDefinition.name, enter: enter, leave: leave)
    inputObjectTypeDefinition.fields.forEach { visit($0, enter: enter, leave: leave) }
  case let typeExtensionDefinition as TypeExtensionDefinition:
    visit(typeExtensionDefinition.definition, enter: enter, leave: leave)
  default:
    break
  }

  leave(node)
}
