//
//  XML.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// A metadata object that allows for more fine-tuned XML model definitions.
  struct XML: Model {
    /// Replaces the name of the element/attribute used for the described schema property.
    public let name: String?

    /// The URI of the namespace definition.
    public let namespace: String?

    /// The prefix to be used for the name.
    public let prefix: String?

    /// Declares whether the property definition translates to an attribute instead of an element.
    public let attribute: Bool?

    /// MAY be used only for an array definition.
    public let wrapped: Bool?

    public init(
      name: String? = nil,
      namespace: String? = nil,
      prefix: String? = nil,
      attribute: Bool? = nil,
      wrapped: Bool? = nil
    ) {
      self.name = name
      self.namespace = namespace
      self.prefix = prefix
      self.attribute = attribute
      self.wrapped = wrapped
    }
  }
}
