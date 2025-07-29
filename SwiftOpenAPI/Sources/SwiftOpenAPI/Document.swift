//
//  Document.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import Foundation
import SwiftToolbox
import Yams

public extension OpenAPI {
  /// The root object of the OpenAPI specification document.
  struct Document: Model {
    /// The OpenAPI Specification version that the OpenAPI document uses.
    public let openapi: String
    
    /// Provides metadata about the API.
    public let info: Info
    
    /// The default value for the $schema keyword within Schema Objects contained within this OAS document.
    public let jsonSchemaDialect: String?
    
    /// An array of Server Objects, which provide connectivity information to a target server.
    public let servers: [Server]?
    
    /// The available paths and operations for the API.
    public let paths: [String: PathItem]?

    /// The incoming webhooks that MAY be received as part of this API and that the API consumer MAY choose to implement.
    public let webhooks: [String: PathItem]?
    
    /// An element to hold various schemas for the document.
    public let components: Components?
    
    /// A declaration of which security mechanisms can be used across the API.
    public let security: [SecurityRequirement]?
    
    /// A list of tags used by the document with additional metadata.
    public let tags: [Tag]?
    
    /// Additional external documentation.
    public let externalDocs: ExternalDocumentation?
    
    public init(
      openapi: String,
      info: Info,
      jsonSchemaDialect: String? = nil,
      servers: [Server]? = nil,
      paths: [String: PathItem]? = nil,
      webhooks: [String: PathItem]? = nil,
      components: Components? = nil,
      security: [SecurityRequirement]? = nil,
      tags: [Tag]? = nil,
      externalDocs: ExternalDocumentation? = nil
    ) {
      self.openapi = openapi
      self.info = info
      self.jsonSchemaDialect = jsonSchemaDialect
      self.servers = servers
      self.paths = paths
      self.webhooks = webhooks
      self.components = components
      self.security = security
      self.tags = tags
      self.externalDocs = externalDocs
    }
    
    /// Parses an OpenAPI Document from Data
    /// - Parameter data: The JSON or YAML data to parse
    /// - Returns: A parsed Document
    /// - Throws: DecodingError if the data cannot be parsed
    public static func parse(from data: Data) throws -> Document {
      // First try to parse as JSON
      do {
        return try JSONDecoder().decode(Document.self, from: data)
      } catch {
        // If JSON parsing fails, try YAML
        return try YAMLDecoder().decode(Document.self, from: data)
      }
    }
  }
}
