//
//  Components.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// Holds a set of reusable objects for different aspects of the OAS.
  struct Components: Model {
    /// An object to hold reusable Schema Objects.
    public let schemas: [String: Referenceable<Schema>]?

    /// An object to hold reusable Response Objects.
    public let responses: [String: Referenceable<Response>]?

    /// An object to hold reusable Parameter Objects.
    public let parameters: [String: Referenceable<Parameter>]?

    /// An object to hold reusable Example Objects.
    public let examples: [String: Referenceable<Example>]?

    /// An object to hold reusable Request Body Objects.
    public let requestBodies: [String: Referenceable<RequestBody>]?

    /// An object to hold reusable Header Objects.
    public let headers: [String: Referenceable<Header>]?
    
    /// An object to hold reusable Security Scheme Objects.
    public let securitySchemes: [String: Referenceable<SecurityScheme>]?

    /// An object to hold reusable Link Objects.
    public let links: [String: Referenceable<Link>]?

    /// An object to hold reusable Callback Objects.
    public let callbacks: [String: Referenceable<Callback>]?

    /// An object to hold reusable Path Item Objects.
    public let pathItems: [String: Referenceable<PathItem>]?

    public init(
      schemas: [String: Referenceable<Schema>]? = nil,
      responses: [String: Referenceable<Response>]? = nil,
      parameters: [String: Referenceable<Parameter>]? = nil,
      examples: [String: Referenceable<Example>]? = nil,
      requestBodies: [String: Referenceable<RequestBody>]? = nil,
      headers: [String: Referenceable<Header>]? = nil,
      securitySchemes: [String: Referenceable<SecurityScheme>]? = nil,
      links: [String: Referenceable<Link>]? = nil,
      callbacks: [String: Referenceable<Callback>]? = nil,
      pathItems: [String: Referenceable<PathItem>]? = nil
    ) {
      self.schemas = schemas
      self.responses = responses
      self.parameters = parameters
      self.examples = examples
      self.requestBodies = requestBodies
      self.headers = headers
      self.securitySchemes = securitySchemes
      self.links = links
      self.callbacks = callbacks
      self.pathItems = pathItems
    }
  }
}
