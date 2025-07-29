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
    public let schemas: [String: Schema]?

    /// An object to hold reusable Response Objects.
    public let responses: [String: Response]?

    /// An object to hold reusable Parameter Objects.
    public let parameters: [String: Parameter]?

    /// An object to hold reusable Example Objects.
    public let examples: [String: Example]?

    /// An object to hold reusable Request Body Objects.
    public let requestBodies: [String: RequestBody]?

    /// An object to hold reusable Header Objects.
    public let headers: [String: Header]?
    
    /// An object to hold reusable Security Scheme Objects.
    public let securitySchemes: [String: SecurityScheme]?

    /// An object to hold reusable Link Objects.
    public let links: [String: Link]?

    /// An object to hold reusable Callback Objects.
    public let callbacks: [String: Callback]?

    /// An object to hold reusable Path Item Objects.
    public let pathItems: [String: PathItem]?

    public init(
      schemas: [String: Schema]? = nil,
      responses: [String: Response]? = nil,
      parameters: [String: Parameter]? = nil,
      examples: [String: Example]? = nil,
      requestBodies: [String: RequestBody]? = nil,
      headers: [String: Header]? = nil,
      securitySchemes: [String: SecurityScheme]? = nil,
      links: [String: Link]? = nil,
      callbacks: [String: Callback]? = nil,
      pathItems: [String: PathItem]? = nil
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
