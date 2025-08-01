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
    /// An optional, string summary, intended to apply to all operations in this path.
    public let summary: String?

    /// An optional, string description, intended to apply to all operations in this path.
    public var description: String?

    /// A definition of a GET operation on this path.
    public var get: Operation?

    /// A definition of a PUT operation on this path.
    public var put: Operation?

    /// A definition of a POST operation on this path.
    public var post: Operation?

    /// A definition of a DELETE operation on this path.
    public var delete: Operation?

    /// A definition of a OPTIONS operation on this path.
    public var options: Operation?

    /// A definition of a HEAD operation on this path.
    public var head: Operation?

    /// A definition of a PATCH operation on this path.
    public var patch: Operation?

    /// A definition of a TRACE operation on this path.
    public var trace: Operation?

    /// An alternative server array to service operations in this path.
    public let servers: [Server]?

    /// A list of parameters that are applicable for all the operations in this path.
    public let parameters: [Referenceable<Parameter>]?

    /// An array of subdirectory components for organizing paths from referenced files.
    /// This property is not encoded/decoded and is used for preserving file organization.
    public let subdirectories: [String]?

    public init(
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
      parameters: [Referenceable<Parameter>]? = nil,
      subdirectories: [String]? = nil
    ) {
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
      self.subdirectories = subdirectories
    }
  }

  private enum CodingKeys: String, CodingKey {
    case summary, description, get, put, post, delete, options, head, patch, trace, servers, parameters
  }
}
