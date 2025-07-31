//
//  Discriminator.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import Collections
import SwiftToolbox

public extension OpenAPI {
  /// When request bodies or response payloads may be one of a number of different schemas, a discriminator object can be used to aid in serialization, deserialization, and validation.
  struct Discriminator: Model {
    /// The name of the property in the payload that will hold the discriminator value.
    public let propertyName: String
    
    /// An object to hold mappings between payload values and schema names or references.
    public let mapping: OrderedDictionary<String, String>?
    
    public init(
      propertyName: String,
      mapping: OrderedDictionary<String, String>? = nil
    ) {
      self.propertyName = propertyName
      self.mapping = mapping
    }
  }
}
