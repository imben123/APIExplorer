//
//  Parameter.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import Collections
import SwiftToolbox

public extension OpenAPI {
  /// Describes a single operation parameter.
  struct Parameter: Model, ComponentFileSerializable {
    /// The name of the parameter.
    public let name: String
    
    /// The location of the parameter.
    public let `in`: ParameterLocation
    
    /// A brief description of the parameter.
    public var description: String?
    
    /// Determines whether this parameter is mandatory.
    public let required: Bool?
    
    /// Specifies that a parameter is deprecated and SHOULD be transitioned out of usage.
    public let deprecated: Bool?
    
    /// Sets the ability to pass empty-valued parameters.
    public let allowEmptyValue: Bool?
    
    /// Describes how the parameter value will be serialized depending on the type of the parameter value.
    public let style: ParameterStyle?
    
    /// When this is true, parameter values of type array or object generate separate parameters for each value of the array or key-value pair of the map.
    public let explode: Bool?
    
    /// Determines whether the parameter value SHOULD allow reserved characters, as defined by RFC3986.
    public let allowReserved: Bool?
    
    /// The schema defining the type used for the parameter.
    public let schema: Referenceable<Schema>?
    
    /// Example of the parameter's potential value.
    public let example: OrderedJSONValue?
    
    /// Examples of the parameter's potential value.
    public let examples: OrderedDictionary<String, Referenceable<Example>>?
    
    /// A map containing the representations for the parameter.
    public let content: OrderedDictionary<String, MediaType>?

    var originalDataHash: String?

    public init(
      name: String,
      in: ParameterLocation,
      description: String? = nil,
      required: Bool? = nil,
      deprecated: Bool? = nil,
      allowEmptyValue: Bool? = nil,
      style: ParameterStyle? = nil,
      explode: Bool? = nil,
      allowReserved: Bool? = nil,
      schema: Referenceable<Schema>? = nil,
      example: OrderedJSONValue? = nil,
      examples: OrderedDictionary<String, Referenceable<Example>>? = nil,
      content: OrderedDictionary<String, MediaType>? = nil
    ) {
      self.name = name
      self.in = `in`
      self.description = description
      self.required = required
      self.deprecated = deprecated
      self.allowEmptyValue = allowEmptyValue
      self.style = style
      self.explode = explode
      self.allowReserved = allowReserved
      self.schema = schema
      self.example = example
      self.examples = examples
      self.content = content
    }

    enum CodingKeys: CodingKey {
      case name, `in`, description, required, deprecated, allowEmptyValue, style,
           explode, allowReserved, schema, example, examples, content
    }
  }

  /// The location of the parameter.
  enum ParameterLocation: String, Model {
    case query
    case header
    case path
    case cookie
  }

  /// Describes how the parameter value will be serialized.
  enum ParameterStyle: String, Model {
    case matrix
    case label
    case form
    case simple
    case spaceDelimited
    case pipeDelimited
    case deepObject
  }
}
