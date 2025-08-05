//
//  SecurityScheme.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// Defines a security scheme that can be used by the operations.
  struct SecurityScheme: Model, ComponentFileSerializable {
    /// The type of the security scheme.
    public let type: SecuritySchemeType
    
    /// A description for security scheme.
    public let description: String?
    
    /// The name of the header, query or cookie parameter to be used.
    public let name: String?
    
    /// The location of the API key.
    public let `in`: SecuritySchemeLocation?
    
    /// The name of the HTTP Authorization scheme to be used in the Authorization header.
    public let scheme: String?
    
    /// A hint to the client to identify how the bearer token is formatted.
    public let bearerFormat: String?
    
    /// An object containing configuration information for the flow types supported.
    public let flows: OAuthFlows?
    
    /// OpenId Connect URL to discover OAuth2 configuration values.
    public let openIdConnectUrl: String?

    var originalDataHash: String?

    public init(
      type: SecuritySchemeType,
      description: String? = nil,
      name: String? = nil,
      in: SecuritySchemeLocation? = nil,
      scheme: String? = nil,
      bearerFormat: String? = nil,
      flows: OAuthFlows? = nil,
      openIdConnectUrl: String? = nil
    ) {
      self.type = type
      self.description = description
      self.name = name
      self.in = `in`
      self.scheme = scheme
      self.bearerFormat = bearerFormat
      self.flows = flows
      self.openIdConnectUrl = openIdConnectUrl
    }

    enum CodingKeys: CodingKey {
      case type, description, name, `in`, scheme, bearerFormat, flows, openIdConnectUrl
    }
  }

  /// The type of the security scheme.
  enum SecuritySchemeType: String, Model {
    case apiKey
    case http
    case mutualTLS
    case oauth2
    case openIdConnect
  }

  /// The location of the API key.
  enum SecuritySchemeLocation: String, Model {
    case query
    case header
    case cookie
  }
}
