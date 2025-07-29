//
//  Server.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// An object representing a Server.
  struct Server: Model {
    /// A URL to the target host.
    public let url: String
    
    /// An optional string describing the host designated by the URL.
    public let description: String?
    
    /// A map between a variable name and its value.
    public let variables: [String: ServerVariable]?
    
    public init(
      url: String,
      description: String? = nil,
      variables: [String: ServerVariable]? = nil
    ) {
      self.url = url
      self.description = description
      self.variables = variables
    }
  }
}
