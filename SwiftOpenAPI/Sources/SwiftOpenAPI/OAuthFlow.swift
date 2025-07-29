//
//  OAuthFlow.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// Configuration details for a supported OAuth Flow.
  struct OAuthFlow: Model {
    /// The authorization URL to be used for this flow.
    public let authorizationUrl: String?
    
    /// The token URL to be used for this flow.
    public let tokenUrl: String?
    
    /// The URL to be used for obtaining refresh tokens.
    public let refreshUrl: String?
    
    /// The available scopes for the OAuth2 security scheme.
    public let scopes: [String: String]
    
    public init(
      authorizationUrl: String? = nil,
      tokenUrl: String? = nil,
      refreshUrl: String? = nil,
      scopes: [String: String]
    ) {
      self.authorizationUrl = authorizationUrl
      self.tokenUrl = tokenUrl
      self.refreshUrl = refreshUrl
      self.scopes = scopes
    }
  }
}
