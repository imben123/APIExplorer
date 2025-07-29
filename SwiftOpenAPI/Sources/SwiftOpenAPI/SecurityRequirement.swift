//
//  SecurityRequirement.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// Lists the required security schemes to execute this operation.
  struct SecurityRequirement: Model {
    /// Each name MUST correspond to a security scheme which is declared in the Security Schemes under the Components Object.
    public let requirements: [String: [String]]
    
    public init(requirements: [String: [String]]) {
      self.requirements = requirements
    }
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: OpenAPI.DynamicCodingKey.self)
      var requirements: [String: [String]] = [:]
      
      for key in container.allKeys {
        requirements[key.stringValue] = try container.decode([String].self, forKey: key)
      }
      
      self.requirements = requirements
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: OpenAPI.DynamicCodingKey.self)
      
      for (key, value) in requirements {
        try container.encode(value, forKey: OpenAPI.DynamicCodingKey(stringValue: key)!)
      }
    }
  }
}
