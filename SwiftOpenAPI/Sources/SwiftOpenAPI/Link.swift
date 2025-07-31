//
//  Link.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// The Link object represents a possible design-time link for a response.
  struct Link: Model {
    /// A relative or absolute URI reference to an OAS operation.
    public let operationRef: String?
    
    /// The name of an existing, resolvable OAS operation, as defined with a unique operationId.
    public let operationId: String?
    
    /// A map representing parameters to pass to an operation as specified with operationId or identified via operationRef.
    public let parameters: [String: OrderedJSONValue]?
    
    /// A literal value or expression to use as a request body when calling the target operation.
    public let requestBody: OrderedJSONValue?
    
    /// A description of the link.
    public let description: String?
    
    /// A server object to be used by the target operation.
    public let server: Server?
    
    public init(
      operationRef: String? = nil,
      operationId: String? = nil,
      parameters: [String: OrderedJSONValue]? = nil,
      requestBody: OrderedJSONValue? = nil,
      description: String? = nil,
      server: Server? = nil
    ) {
      self.operationRef = operationRef
      self.operationId = operationId
      self.parameters = parameters
      self.requestBody = requestBody
      self.description = description
      self.server = server
    }
  }
}
