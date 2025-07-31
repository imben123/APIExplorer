//
//  Components.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox
import Collections

public extension OpenAPI {
  /// Holds a set of reusable objects for different aspects of the OAS.
  struct Components: Model {
    /// An object to hold reusable Schema Objects.
    public let schemas: OrderedDictionary<String, Referenceable<Schema>>?

    /// An object to hold reusable Response Objects.
    public let responses: OrderedDictionary<String, Referenceable<Response>>?

    /// An object to hold reusable Parameter Objects.
    public let parameters: OrderedDictionary<String, Referenceable<Parameter>>?

    /// An object to hold reusable Example Objects.
    public let examples: OrderedDictionary<String, Referenceable<Example>>?

    /// An object to hold reusable Request Body Objects.
    public let requestBodies: OrderedDictionary<String, Referenceable<RequestBody>>?

    /// An object to hold reusable Header Objects.
    public let headers: OrderedDictionary<String, Referenceable<Header>>?
    
    /// An object to hold reusable Security Scheme Objects.
    public let securitySchemes: OrderedDictionary<String, Referenceable<SecurityScheme>>?

    /// An object to hold reusable Link Objects.
    public let links: OrderedDictionary<String, Referenceable<Link>>?

    /// An object to hold reusable Callback Objects.
    public let callbacks: OrderedDictionary<String, Referenceable<Callback>>?

    /// An object to hold reusable Path Item Objects.
    public let pathItems: OrderedDictionary<String, Referenceable<PathItem>>?

    public init(
      schemas: OrderedDictionary<String, Referenceable<Schema>>? = nil,
      responses: OrderedDictionary<String, Referenceable<Response>>? = nil,
      parameters: OrderedDictionary<String, Referenceable<Parameter>>? = nil,
      examples: OrderedDictionary<String, Referenceable<Example>>? = nil,
      requestBodies: OrderedDictionary<String, Referenceable<RequestBody>>? = nil,
      headers: OrderedDictionary<String, Referenceable<Header>>? = nil,
      securitySchemes: OrderedDictionary<String, Referenceable<SecurityScheme>>? = nil,
      links: OrderedDictionary<String, Referenceable<Link>>? = nil,
      callbacks: OrderedDictionary<String, Referenceable<Callback>>? = nil,
      pathItems: OrderedDictionary<String, Referenceable<PathItem>>? = nil
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
