//
//  Response.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// Describes a single response from an API Operation.
  struct Response: Model {
    /// A description of the response.
    public let description: String
    
    /// Maps a header name to its definition.
    public let headers: [String: Referenceable<Header>]?
    
    /// A map containing descriptions of potential response payloads.
    public let content: [String: MediaType]?
    
    /// A map of operations links that can be followed from the response.
    public let links: [String: Referenceable<Link>]?
    
    public init(
      description: String,
      headers: [String: Referenceable<Header>]? = nil,
      content: [String: MediaType]? = nil,
      links: [String: Referenceable<Link>]? = nil
    ) {
      self.description = description
      self.headers = headers
      self.content = content
      self.links = links
    }
  }
}
