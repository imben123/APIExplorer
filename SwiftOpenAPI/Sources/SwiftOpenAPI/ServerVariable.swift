//
//  ServerVariable.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// An object representing a Server Variable for server URL template substitution.
  struct ServerVariable: Model {
    /// An enumeration of string values to be used if the substitution options are from a limited set.
    public let `enum`: [String]?
    
    /// The default value to use for substitution, which SHALL be sent if an alternate value is not supplied.
    public let `default`: String
    
    /// An optional description for the server variable.
    public let description: String?
    
    public init(
      enum: [String]? = nil,
      default: String,
      description: String? = nil
    ) {
      self.enum = `enum`
      self.default = `default`
      self.description = description
    }
  }
}
