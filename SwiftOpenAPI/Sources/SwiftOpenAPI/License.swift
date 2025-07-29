//
//  License.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// License information for the exposed API.
  struct License: Model {
    /// The license name used for the API.
    public let name: String
    
    /// An SPDX license expression for the API.
    public let identifier: String?
    
    /// A URL to the license used for the API.
    public let url: String?
    
    public init(
      name: String,
      identifier: String? = nil,
      url: String? = nil
    ) {
      self.name = name
      self.identifier = identifier
      self.url = url
    }
  }
}
