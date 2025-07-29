//
//  OAuthFlows.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// Allows configuration of the supported OAuth Flows.
  struct OAuthFlows: Model {
    /// Configuration for the OAuth Implicit flow.
    public let implicit: OAuthFlow?
    
    /// Configuration for the OAuth Resource Owner Password flow.
    public let password: OAuthFlow?
    
    /// Configuration for the OAuth Client Credentials flow.
    public let clientCredentials: OAuthFlow?
    
    /// Configuration for the OAuth Authorization Code flow.
    public let authorizationCode: OAuthFlow?
    
    public init(
      implicit: OAuthFlow? = nil,
      password: OAuthFlow? = nil,
      clientCredentials: OAuthFlow? = nil,
      authorizationCode: OAuthFlow? = nil
    ) {
      self.implicit = implicit
      self.password = password
      self.clientCredentials = clientCredentials
      self.authorizationCode = authorizationCode
    }
  }
}
