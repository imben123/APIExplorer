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
    public var schemas: OrderedDictionary<String, Referenceable<Schema>>?

    /// An object to hold reusable Response Objects.
    public var responses: OrderedDictionary<String, Referenceable<Response>>?

    /// An object to hold reusable Parameter Objects.
    public var parameters: OrderedDictionary<String, Referenceable<Parameter>>?

    /// An object to hold reusable Example Objects.
    public var examples: OrderedDictionary<String, Referenceable<Example>>?

    /// An object to hold reusable Request Body Objects.
    public var requestBodies: OrderedDictionary<String, Referenceable<RequestBody>>?

    /// An object to hold reusable Header Objects.
    public var headers: OrderedDictionary<String, Referenceable<Header>>?

    /// An object to hold reusable Security Scheme Objects.
    public var securitySchemes: OrderedDictionary<String, Referenceable<SecurityScheme>>?

    /// An object to hold reusable Link Objects.
    public var links: OrderedDictionary<String, Referenceable<Link>>?

    /// An object to hold reusable Callback Objects.
    public var callbacks: OrderedDictionary<String, Referenceable<Callback>>?

    /// A nested structure to hold reusable Path Item Objects with support for grouping.
    public var pathItems: PathGroup?

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
      pathItems: PathGroup? = nil
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

    /// Resolves a component reference from the document's components
    func resolveComponent<T>(type: String, name: String, in document: Document) -> T? {
      switch type {
      case "schemas":
        return schemas?[name]?.resolve(in: document) as? T
      case "responses":
        return responses?[name]?.resolve(in: document) as? T
      case "parameters":
        return parameters?[name]?.resolve(in: document) as? T
      case "examples":
        return examples?[name]?.resolve(in: document) as? T
      case "requestBodies":
        return requestBodies?[name]?.resolve(in: document) as? T
      case "headers":
        return headers?[name]?.resolve(in: document) as? T
      case "securitySchemes":
        return securitySchemes?[name]?.resolve(in: document) as? T
      case "links":
        return links?[name]?.resolve(in: document) as? T
      case "callbacks":
        return callbacks?[name]?.resolve(in: document) as? T
      case "pathItems":
        // For pathItems, we need to search through the nested structure
        if let allItems = pathItems?.allPathItems() {
          return allItems[name]?.resolve(in: document) as? T
        }
        return nil
      default:
        return nil
      }
    }

    mutating func updateReference(_ ref: String, newValue: Any?) {
      // Normalize the reference path by removing leading "./" since our dicts don't have this prefix
      let normalizedRef = ref.hasPrefix("./") ? String(ref.dropFirst(2)) : ref

      var pathComponents = normalizedRef.split(separator: "/").map { String($0) }
      if pathComponents[0] == "components" {
        pathComponents = Array(pathComponents.dropFirst())
      }

      let componentType = String(pathComponents[0])
      let remainingPathComponents = Array(pathComponents.dropFirst().dropLast())
      guard let componentName = remainingPathComponents.last else {
        return
      }

      switch componentType {
      case "schemas":
        schemas?[componentName]!.value = newValue as! Schema?
      case "responses":
        responses?[componentName]!.value = newValue as! Response?
      case "parameters":
        parameters?[componentName]!.value = newValue as! Parameter?
      case "examples":
        examples?[componentName]!.value = newValue as! Example?
      case "requestBodies":
        requestBodies?[componentName]!.value = newValue as! RequestBody?
      case "headers":
        headers?[componentName]!.value = newValue as! Header?
      case "securitySchemes":
        securitySchemes?[componentName]!.value = newValue as! SecurityScheme?
      case "links":
        links?[componentName]!.value = newValue as! Link?
      case "callbacks":
        callbacks?[componentName]!.value = newValue as! Callback?
      case "pathItems", "paths":
        if pathItems == nil {
          pathItems = PathGroup()
        }
        pathItems?.updateItem(in: remainingPathComponents,
                              name: componentName,
                              updatedItem: .value(newValue as! PathItem))
      default:
        fatalError()
      }
    }
  }
}
