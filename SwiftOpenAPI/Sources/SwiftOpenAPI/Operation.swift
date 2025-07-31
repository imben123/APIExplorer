//
//  Operation.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// Describes a single API operation on a path.
  struct Operation: Model {
    /// A list of tags for API documentation control.
    public let tags: [String]?
    
    /// A short summary of what the operation does.
    public let summary: String?
    
    /// A verbose explanation of the operation behavior.
    public let description: String?
    
    /// Additional external documentation for this operation.
    public let externalDocs: ExternalDocumentation?
    
    /// Unique string used to identify the operation.
    public let operationId: String?
    
    /// A list of parameters that are applicable for this operation.
    public let parameters: [Referenceable<Parameter>]?
    
    /// The request body applicable for this operation.
    public let requestBody: Referenceable<RequestBody>?
    
    /// The list of possible responses as they are returned from executing this operation.
    public let responses: Responses?
    
    /// A map of possible out-of band callbacks related to the parent operation.
    public let callbacks: [String: Referenceable<Callback>]?
    
    /// Declares this operation to be deprecated.
    public let deprecated: Bool?
    
    /// A declaration of which security mechanisms can be used for this operation.
    public let security: [SecurityRequirement]?
    
    /// An alternative server array to service operations in this path.
    public let servers: [Server]?
    
    public init(
      tags: [String]? = nil,
      summary: String? = nil,
      description: String? = nil,
      externalDocs: ExternalDocumentation? = nil,
      operationId: String? = nil,
      parameters: [Referenceable<Parameter>]? = nil,
      requestBody: Referenceable<RequestBody>? = nil,
      responses: Responses? = nil,
      callbacks: [String: Referenceable<Callback>]? = nil,
      deprecated: Bool? = nil,
      security: [SecurityRequirement]? = nil,
      servers: [Server]? = nil
    ) {
      self.tags = tags
      self.summary = summary
      self.description = description
      self.externalDocs = externalDocs
      self.operationId = operationId
      self.parameters = parameters
      self.requestBody = requestBody
      self.responses = responses
      self.callbacks = callbacks
      self.deprecated = deprecated
      self.security = security
      self.servers = servers
    }
  }
}
