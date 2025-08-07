//
//  MediaType.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import Collections
import SwiftToolbox

public extension OpenAPI {
  /// Each Media Type Object provides schema and examples for the media type identified by its key.
  struct MediaType: Model {
    /// The schema defining the content of the request, response, or parameter.
    public let schema: Referenceable<Schema>?
    
    /// Example of the media type.
    public var example: OrderedJSONObject?
    
    /// Examples of the media type.
    public var examples: OrderedDictionary<String, Referenceable<Example>>?
    
    /// A map between a property name and its encoding information.
    public let encoding: OrderedDictionary<String, Encoding>?
    
    public init(
      schema: Referenceable<Schema>? = nil,
      example: OrderedJSONObject? = nil,
      examples: OrderedDictionary<String, Referenceable<Example>>? = nil,
      encoding: OrderedDictionary<String, Encoding>? = nil
    ) {
      self.schema = schema
      self.example = example
      self.examples = examples
      self.encoding = encoding
    }
  }
}
