//
//  PathItem.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// Describes the operations available on a single path.
  struct PathItem: Model {
    /// Allows for a referenced definition of this path item.
    public let ref: String?

    /// An optional, string summary, intended to apply to all operations in this path.
    public let summary: String?

    /// An optional, string description, intended to apply to all operations in this path.
    public let description: String?

    /// A definition of a GET operation on this path.
    public let get: Operation?

    /// A definition of a PUT operation on this path.
    public let put: Operation?

    /// A definition of a POST operation on this path.
    public let post: Operation?

    /// A definition of a DELETE operation on this path.
    public let delete: Operation?

    /// A definition of a OPTIONS operation on this path.
    public let options: Operation?

    /// A definition of a HEAD operation on this path.
    public let head: Operation?

    /// A definition of a PATCH operation on this path.
    public let patch: Operation?

    /// A definition of a TRACE operation on this path.
    public let trace: Operation?

    /// An alternative server array to service operations in this path.
    public let servers: [Server]?

    /// A list of parameters that are applicable for all the operations in this path.
    public let parameters: [Parameter]?

    public init(
      ref: String? = nil,
      summary: String? = nil,
      description: String? = nil,
      get: Operation? = nil,
      put: Operation? = nil,
      post: Operation? = nil,
      delete: Operation? = nil,
      options: Operation? = nil,
      head: Operation? = nil,
      patch: Operation? = nil,
      trace: Operation? = nil,
      servers: [Server]? = nil,
      parameters: [Parameter]? = nil
    ) {
      self.ref = ref
      self.summary = summary
      self.description = description
      self.get = get
      self.put = put
      self.post = post
      self.delete = delete
      self.options = options
      self.head = head
      self.patch = patch
      self.trace = trace
      self.servers = servers
      self.parameters = parameters
    }
  }

  private enum CodingKeys: String, CodingKey {
    case ref = "$ref"
    case summary, description, get, put, post, delete, options, head, patch, trace, servers, parameters
  }
}
