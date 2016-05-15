import Foundation

public protocol GraphQLType {

}

public protocol GraphQLInputType: GraphQLType {

}

public protocol GraphQLOutputType: GraphQLType {

}

public protocol GraphQLLeafType: GraphQLType {

}

public protocol GraphQLCompositeType: GraphQLType {

}

public protocol GraphQLAbstractType: GraphQLType {

}

//public indirect enum GraphQLType {
//  case Scalar(GraphQLScalarType)
//  case Object(GraphQLObjectType)
//  case Interface
//  case Union
//  case Enum
//  case InputObject
//  case List
//  case NonNull
//}

extension GraphQLType {
  public func isInputType() -> Bool {
    switch self {
    case .Scalar, .Enum, .InputObject:
      return true
    default:
      return false
    }
  }

  public func isOutputType() -> Bool {
    switch self {
    case .Scalar, .Object, .Interface, .Union, .Enum:
      return true
    default:
      return false
    }
  }

  public func isLeafType() -> Bool {
    switch self {
    case .Scalar, .Enum:
      return true
    default:
      return false
    }
  }

  public func isCompositeType() -> Bool {
    switch self {
    case .Object, .Interface, .Union:
      return true
    default:
      return false
    }
  }

  public func isAbstractType() -> Bool {
    switch self {
    case .Interface, .Union:
      return true
    default:
      return false
    }
  }
}

public struct GraphQLScalarType: GraphQLType, GraphQLInputType {
  let name: String
  let description: String?
}

public struct GraphQLObjectType: GraphQLType {
  let name: String
  let description: String?
  let fields: [GraphQLFieldConfig]
}

public struct GraphQLInterfaceType: GraphQLType {
}

public struct GraphQLUnionType: GraphQLType {
}

public struct GraphQLEnumType: GraphQLType, GraphQLInputType {
}

public struct GraphQLInputObjectType: GraphQLType, GraphQLInputType {
}

public struct GraphQLListType: GraphQLType {
}

public struct GraphQLNonNullType: GraphQLType {
}

public struct GraphQLFieldConfig: GraphQLType {
  let type: GraphQLType // isOutputType()

}
