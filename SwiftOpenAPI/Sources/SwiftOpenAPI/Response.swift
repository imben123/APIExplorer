//
//  Response.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox
import Collections

public extension OpenAPI {
  /// Describes a single response from an API Operation.
  struct Response: Model, ComponentFileSerializable {
    /// A description of the response.
    public var description: String
    
    /// Maps a header name to its definition.
    public let headers: OrderedDictionary<String, Referenceable<Header>>?
    
    /// A map containing descriptions of potential response payloads.
    public let content: OrderedDictionary<String, MediaType>?
    
    /// A map of operations links that can be followed from the response.
    public let links: OrderedDictionary<String, Referenceable<Link>>?

    var originalDataHash: String?

    public init(
      description: String,
      headers: OrderedDictionary<String, Referenceable<Header>>? = nil,
      content: OrderedDictionary<String, MediaType>? = nil,
      links: OrderedDictionary<String, Referenceable<Link>>? = nil
    ) {
      self.description = description
      self.headers = headers
      self.content = content
      self.links = links
    }

    enum CodingKeys: CodingKey {
      case description, headers, content, links
    }
  }
}
