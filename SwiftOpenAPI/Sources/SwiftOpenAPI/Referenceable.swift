//
//  Referenceable.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 29/07/2025.
//

import SwiftToolbox

public extension OpenAPI {
  /// A generic enum that can contain either a reference to a component or the actual component value.
  indirect enum Referenceable<T: Model>: Model {
    case reference(String)
    case value(T)
    
    /// Returns the reference string if this is a reference, nil otherwise.
    public var ref: String? {
      switch self {
      case .reference(let ref):
        return ref
      case .value:
        return nil
      }
    }
    
    /// Returns the actual value if this contains a value, nil if it's a reference.
    public var value: T? {
      get {
        switch self {
        case .reference:
          return nil
        case .value(let val):
          return val
        }
      }
      set {
        if let newValue {
          self = .value(newValue)
        }
      }
    }

    /// Resolves this referenceable to its concrete instance by looking it up in the document.
    /// - Parameter document: The OpenAPI document to resolve references against
    /// - Returns: The concrete instance, or nil if the reference cannot be resolved
    public func resolve(in document: Document) -> T? {
      switch self {
      case .value(let val):
        return val
      case .reference(let ref):
        // Parse the reference path (e.g., "#/components/schemas/Pet")
        guard ref.hasPrefix("#/components/") else {
          // Handle external references or other formats
          return resolveExternalReference(ref, in: document)
        }

        let pathComponents = ref.dropFirst("#/components/".count).split(separator: "/")
        guard pathComponents.count == 2 else { return nil }

        let componentType = String(pathComponents[0])
        let componentName = String(pathComponents[1])

        return document.components?.resolveComponent(
          type: componentType,
          name: componentName,
          in: document
        )
      }
    }

    /// Resolves this referenceable to its concrete instance by looking it up in the document.
    /// - Parameter document: The OpenAPI document to resolve references against
    /// - Returns: The concrete instance, or nil if the reference cannot be resolved
    public mutating func update(in document: inout Document, newValue: T) {
      switch self {
      case .value:
        self.value = newValue
      case .reference(let ref):
        // Parse the reference path (e.g., "#/components/schemas/Pet")
        guard ref.hasPrefix("#/components/") else {
          // Handle external references or other formats
          document.componentFiles?.updateReference(
            ref,
            newValue: newValue,
            useFullReferenceString: true
          )
          return
        }

        let pathComponents = ref.dropFirst("#/components/".count).split(separator: "/")
        guard pathComponents.count == 2 else { return }

        let componentType = String(pathComponents[0])
        let componentName = String(pathComponents[1])

        document.components?.updateReference(
          "\(componentType)/\(componentName)",
          newValue: newValue
        )
      }
    }

    /// Resolves external references (files, URLs, etc.)
    private func resolveExternalReference(_ ref: String, in document: Document) -> T? {
      // Check if it's a file reference that we have in componentFiles
      guard let componentFiles = document.componentFiles else { return nil }

      // Normalize the reference path by removing leading "./" since our dicts don't have this prefix
      let normalizedRef = ref.hasPrefix("./") ? String(ref.dropFirst(2)) : ref

      // Handle different component types from external files
      if let schemas = componentFiles.schemas, let schema = schemas[normalizedRef]?.resolve(in: document) as? T {
        return schema
      }
      if let responses = componentFiles.responses, let response = responses[normalizedRef]?.resolve(in: document) as? T {
        return response
      }
      if let parameters = componentFiles.parameters, let parameter = parameters[normalizedRef]?.resolve(in: document) as? T {
        return parameter
      }
      if let examples = componentFiles.examples, let example = examples[normalizedRef]?.resolve(in: document) as? T {
        return example
      }
      if let requestBodies = componentFiles.requestBodies, let requestBody = requestBodies[normalizedRef]?.resolve(in: document) as? T {
        return requestBody
      }
      if let headers = componentFiles.headers, let header = headers[normalizedRef]?.resolve(in: document) as? T {
        return header
      }
      if let securitySchemes = componentFiles.securitySchemes, let securityScheme = securitySchemes[normalizedRef]?.resolve(in: document) as? T {
        return securityScheme
      }
      if let links = componentFiles.links, let link = links[normalizedRef]?.resolve(in: document) as? T {
        return link
      }
      if let callbacks = componentFiles.callbacks, let callback = callbacks[normalizedRef]?.resolve(in: document) as? T {
        return callback
      }
      if let pathItems = componentFiles.pathItems, let pathItem = pathItems[normalizedRef]?.resolve(in: document) as? T {
        return pathItem
      }

      return nil
    }

    /// Resolves external references (files, URLs, etc.)
    private func updateExternalReference(_ ref: String, newValue: Any?, in document: inout Document) {
      // Normalize the reference path by removing leading "./" since our dicts don't have this prefix
      let normalizedRef = ref.hasPrefix("./") ? String(ref.dropFirst(2)) : ref

      let pathComponents = normalizedRef.split(separator: "/")
      let componentType = String(pathComponents[0])

      // Use type erasure to handle different component types
      switch componentType {
      case "schemas":
        document.componentFiles!.schemas?[normalizedRef]!.value = newValue as! Schema?
      case "responses":
        document.componentFiles!.responses?[normalizedRef]!.value = newValue as! Response?
      case "parameters":
        document.componentFiles!.parameters?[normalizedRef]!.value = newValue as! Parameter?
      case "examples":
        document.componentFiles!.examples?[normalizedRef]!.value = newValue as! Example?
      case "requestBodies":
        document.componentFiles!.requestBodies?[normalizedRef]!.value = newValue as! RequestBody?
      case "headers":
        document.componentFiles!.headers?[normalizedRef]!.value = newValue as! Header?
      case "securitySchemes":
        document.componentFiles!.securitySchemes?[normalizedRef]!.value = newValue as! SecurityScheme?
      case "links":
        document.componentFiles!.links?[normalizedRef]!.value = newValue as! Link?
      case "callbacks":
        document.componentFiles!.callbacks?[normalizedRef]!.value = newValue as! Callback?
      case "pathItems":
        document.componentFiles!.pathItems?[normalizedRef]!.value = newValue as! PathItem?
      default:
        fatalError()
      }
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      if let ref = try container.decodeIfPresent(String.self, forKey: .ref) {
        self = .reference(ref)
      } else {
        let value = try T(from: decoder)
        self = .value(value)
      }
    }
    
    public func encode(to encoder: Encoder) throws {
      switch self {
      case .reference(let ref):
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ref, forKey: .ref)
      case .value(let val):
        try val.encode(to: encoder)
      }
    }
    
    private enum CodingKeys: String, CodingKey {
      case ref = "$ref"
    }
  }
}
