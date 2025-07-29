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
  
  /// Represents a JSON value that can be any valid JSON type
  public enum JSONObject: Codable, Hashable, Sendable {
    case string(String)
    case number(Double)
    case integer(Int)
    case boolean(Bool)
    case array([JSONObject])
    case object([String: JSONObject])
    case null
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      
      if container.decodeNil() {
        self = .null
      } else if let bool = try? container.decode(Bool.self) {
        self = .boolean(bool)
      } else if let int = try? container.decode(Int.self) {
        self = .integer(int)
      } else if let double = try? container.decode(Double.self) {
        self = .number(double)
      } else if let string = try? container.decode(String.self) {
        self = .string(string)
      } else if let array = try? container.decode([JSONObject].self) {
        self = .array(array)
      } else if let object = try? container.decode([String: JSONObject].self) {
        self = .object(object)
      } else {
        throw DecodingError.typeMismatch(JSONObject.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid JSON value"))
      }
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      
      switch self {
      case .null:
        try container.encodeNil()
      case .boolean(let bool):
        try container.encode(bool)
      case .integer(let int):
        try container.encode(int)
      case .number(let double):
        try container.encode(double)
      case .string(let string):
        try container.encode(string)
      case .array(let array):
        try container.encode(array)
      case .object(let object):
        try container.encode(object)
      }
    }
  }
}
