//
//  Tag.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// Adds metadata to a single tag that is used by the Operation Object.
  struct Tag: Model {
    /// The name of the tag.
    public let name: String
    
    /// A description for the tag.
    public let description: String?
    
    /// Additional external documentation for this tag.
    public let externalDocs: ExternalDocumentation?
    
    public init(
      name: String,
      description: String? = nil,
      externalDocs: ExternalDocumentation? = nil
    ) {
      self.name = name
      self.description = description
      self.externalDocs = externalDocs
    }
  }
}
