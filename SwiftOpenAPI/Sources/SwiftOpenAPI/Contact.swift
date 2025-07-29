//
//  Contact.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// Contact information for the exposed API.
  struct Contact: Model {
    /// The identifying name of the contact person/organization.
    public let name: String?
    
    /// The URL pointing to the contact information.
    public let url: String?
    
    /// The email address of the contact person/organization.
    public let email: String?
    
    public init(
      name: String? = nil,
      url: String? = nil,
      email: String? = nil
    ) {
      self.name = name
      self.url = url
      self.email = email
    }
  }
}
