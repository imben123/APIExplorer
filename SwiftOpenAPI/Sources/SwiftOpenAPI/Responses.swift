//
//  Responses.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// A container for the expected responses of an operation.
  struct Responses: Model {
    /// The documentation of responses other than the ones declared for specific HTTP response codes.
    public let `default`: Referenceable<Response>?
    
    /// Any HTTP status codes can be used as the property name, but only one property per code, to describe the expected response for that HTTP status code.
    public let responses: [String: Referenceable<Response>]
    
    public init(
      default: Referenceable<Response>? = nil,
      responses: [String: Referenceable<Response>]
    ) {
      self.default = `default`
      self.responses = responses
    }
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: OpenAPI.DynamicCodingKey.self)
      
      var responses: [String: Referenceable<Response>] = [:]
      var defaultResponse: Referenceable<Response>?
      
      for key in container.allKeys {
        if key.stringValue == "default" {
          defaultResponse = try container.decode(Referenceable<Response>.self, forKey: key)
        } else {
          responses[key.stringValue] = try container.decode(Referenceable<Response>.self, forKey: key)
        }
      }
      
      self.default = defaultResponse
      self.responses = responses
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: OpenAPI.DynamicCodingKey.self)
      
      if let defaultResponse = `default` {
        try container.encode(defaultResponse, forKey: OpenAPI.DynamicCodingKey(stringValue: "default")!)
      }
      
      for (key, response) in responses {
        try container.encode(response, forKey: OpenAPI.DynamicCodingKey(stringValue: key)!)
      }
    }
  }
}
