//
//  Header.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// The Header Object follows the structure of the Parameter Object.
  struct Header: Model {
    /// A brief description of the header.
    public let description: String?
    
    /// Determines whether this header is mandatory.
    public let required: Bool?
    
    /// Specifies that a header is deprecated and SHOULD be transitioned out of usage.
    public let deprecated: Bool?
    
    /// Sets the ability to pass empty-valued headers.
    public let allowEmptyValue: Bool?
    
    /// Describes how the header value will be serialized.
    public let style: ParameterStyle?
    
    /// When this is true, header values of type array or object generate separate parameters for each value of the array or key-value pair of the map.
    public let explode: Bool?
    
    /// Determines whether the header value SHOULD allow reserved characters.
    public let allowReserved: Bool?
    
    /// The schema defining the type used for the header.
    public let schema: Schema?
    
    /// Example of the header's potential value.
    public let example: JSONObject?
    
    /// Examples of the header's potential value.
    public let examples: [String: Example]?
    
    /// A map containing the representations for the header.
    public let content: [String: MediaType]?
    
    public init(
      description: String? = nil,
      required: Bool? = nil,
      deprecated: Bool? = nil,
      allowEmptyValue: Bool? = nil,
      style: ParameterStyle? = nil,
      explode: Bool? = nil,
      allowReserved: Bool? = nil,
      schema: Schema? = nil,
      example: JSONObject? = nil,
      examples: [String: Example]? = nil,
      content: [String: MediaType]? = nil
    ) {
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
  }
}
