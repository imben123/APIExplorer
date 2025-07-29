//
//  Info.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// The object provides metadata about the API.
  struct Info: Model {
    /// The title of the API.
    public let title: String
    
    /// A short summary of the API.
    public let summary: String?
    
    /// A description of the API. CommonMark syntax MAY be used for rich text representation.
    public let description: String?
    
    /// A URL to the Terms of Service for the API.
    public let termsOfService: String?
    
    /// The contact information for the exposed API.
    public let contact: Contact?
    
    /// The license information for the exposed API.
    public let license: License?
    
    /// The version of the OpenAPI document.
    public let version: String
    
    public init(
      title: String,
      summary: String? = nil,
      description: String? = nil,
      termsOfService: String? = nil,
      contact: Contact? = nil,
      license: License? = nil,
      version: String
    ) {
      self.title = title
      self.summary = summary
      self.description = description
      self.termsOfService = termsOfService
      self.contact = contact
      self.license = license
      self.version = version
    }
  }
}
