//
//  ExternalDocumentation.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// Allows referencing an external resource for extended documentation.
  struct ExternalDocumentation: Model {
    /// A description of the target documentation.
    public let description: String?
    
    /// The URL for the target documentation.
    public let url: String
    
    public init(
      description: String? = nil,
      url: String
    ) {
      self.description = description
      self.url = url
    }
  }
}
