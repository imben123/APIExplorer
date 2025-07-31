//
//  Encoding.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// A single encoding definition applied to a single schema property.
  struct Encoding: Model {
    /// The Content-Type for encoding a specific property.
    public let contentType: String?
    
    /// A map allowing additional information to be provided as headers.
    public let headers: [String: Referenceable<Header>]?
    
    /// Describes how a specific property value will be serialized depending on its type.
    public let style: ParameterStyle?
    
    /// When this is true, property values of type array or object generate separate parameters for each value of the array, or key-value-pair of the map.
    public let explode: Bool?
    
    /// Determines whether the parameter value SHOULD allow reserved characters, as defined by RFC3986.
    public let allowReserved: Bool?
    
    public init(
      contentType: String? = nil,
      headers: [String: Referenceable<Header>]? = nil,
      style: ParameterStyle? = nil,
      explode: Bool? = nil,
      allowReserved: Bool? = nil
    ) {
      self.contentType = contentType
      self.headers = headers
      self.style = style
      self.explode = explode
      self.allowReserved = allowReserved
    }
  }
}
