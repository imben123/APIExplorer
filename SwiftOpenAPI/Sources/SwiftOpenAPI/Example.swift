//
//  Example.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// An object to hold data for example usages.
  struct Example: Model, ComponentFileSerializable {
    /// Short description for the example.
    public let summary: String?
    
    /// Long description for the example.
    public let description: String?
    
    /// Embedded literal example.
    public var value: OrderedJSONValue?

    /// A URI that points to the literal example.
    public let externalValue: String?

    var originalDataHash: String?

    public init(
      summary: String? = nil,
      description: String? = nil,
      value: OrderedJSONValue? = nil,
      externalValue: String? = nil
    ) {
      self.summary = summary
      self.description = description
      self.value = value
      self.externalValue = externalValue
    }

    private enum CodingKeys: String, CodingKey {
      case summary, description, value, externalValue
    }
  }
}
