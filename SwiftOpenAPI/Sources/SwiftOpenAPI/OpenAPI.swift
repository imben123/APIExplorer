//
//  OpenAPI.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

/// Namespace for OpenAPI 3.1.1 specification models.
public enum OpenAPI {
  // This enum has no cases and serves only as a namespace
  
  /// A dynamic coding key for decoding arbitrary string keys
  public struct DynamicCodingKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?
    
    public init?(stringValue: String) {
      self.stringValue = stringValue
      self.intValue = nil
    }
    
    public init?(intValue: Int) {
      self.stringValue = String(intValue)
      self.intValue = intValue
    }
  }
}
