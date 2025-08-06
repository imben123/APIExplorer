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
  struct RequestBody: Model, ComponentFileSerializable {
    /// A brief description of the request body.
    public var description: String?
    
    /// The content of the request body.
    public var content: OrderedDictionary<String, MediaType>
    
    /// Determines if the request body is required in the request.
    public let required: Bool?

    var originalDataHash: String?

    public init(
      description: String? = nil,
      content: OrderedDictionary<String, MediaType>,
      required: Bool? = nil
    ) {
      self.description = description
      self.content = content
      self.required = required
    }

    enum CodingKeys: CodingKey {
      case description, content, required
    }
  }
}
