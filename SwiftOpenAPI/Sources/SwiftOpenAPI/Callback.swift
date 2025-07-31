//
//  Callback.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// A map of possible out-of band callbacks related to the parent operation.
  struct Callback: Model {
    /// A Path Item Object, or a reference to one, used to define a callback request and expected responses.
    public let expressions: [String: Referenceable<PathItem>]
    
    public init(expressions: [String: Referenceable<PathItem>]) {
      self.expressions = expressions
    }
  }
}
