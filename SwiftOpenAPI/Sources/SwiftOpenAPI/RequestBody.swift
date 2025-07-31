//
//  RequestBody.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import Collections
import SwiftToolbox

public extension OpenAPI {
  /// Describes a single request body.
  struct RequestBody: Model {
    /// A brief description of the request body.
    public let description: String?
    
    /// The content of the request body.
    public let content: OrderedDictionary<String, MediaType>
    
    /// Determines if the request body is required in the request.
    public let required: Bool?
    
    public init(
      description: String? = nil,
      content: OrderedDictionary<String, MediaType>,
      required: Bool? = nil
    ) {
      self.description = description
      self.content = content
      self.required = required
    }
  }
}
