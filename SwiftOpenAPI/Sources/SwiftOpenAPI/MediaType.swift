//
//  MediaType.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// Each Media Type Object provides schema and examples for the media type identified by its key.
  struct MediaType: Model {
    /// The schema defining the content of the request, response, or parameter.
    public let schema: Schema?
    
    /// Example of the media type.
    public let example: JSONObject?
    
    /// Examples of the media type.
    public let examples: [String: Example]?
    
    /// A map between a property name and its encoding information.
    public let encoding: [String: Encoding]?
    
    public init(
      schema: Schema? = nil,
      example: JSONObject? = nil,
      examples: [String: Example]? = nil,
      encoding: [String: Encoding]? = nil
    ) {
      self.schema = schema
      self.example = example
      self.examples = examples
      self.encoding = encoding
    }
  }
}
