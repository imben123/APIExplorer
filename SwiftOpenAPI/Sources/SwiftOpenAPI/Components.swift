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

    /// An object to hold reusable Path Item Objects.
    public var pathItems: OrderedDictionary<String, Referenceable<PathItem>>?

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
        return pathItems?[name]?.resolve(in: document) as? T
      default:
        return nil
      }
    }

    mutating func updateReference(_ ref: String,
                                  newValue: Any?,
                                  useFullReferenceString: Bool = false) {
      // Normalize the reference path by removing leading "./" since our dicts don't have this prefix
      var normalizedRef = ref.hasPrefix("./") ? String(ref.dropFirst(2)) : ref

      let pathComponents = normalizedRef.split(separator: "/")
      var componentType = String(pathComponents[0])

      if componentType == "components" {
        componentType = String(pathComponents[1])
      }

      if !useFullReferenceString {
        if pathComponents.count == 2 {
          normalizedRef = String(pathComponents[1])
        } else if pathComponents.count == 3 {
          normalizedRef = String(pathComponents[2])
        }
      }

      switch componentType {
      case "schemas":
        schemas?[normalizedRef]!.value = newValue as! Schema?
      case "responses":
        responses?[normalizedRef]!.value = newValue as! Response?
      case "parameters":
        parameters?[normalizedRef]!.value = newValue as! Parameter?
      case "examples":
        examples?[normalizedRef]!.value = newValue as! Example?
      case "requestBodies":
        requestBodies?[normalizedRef]!.value = newValue as! RequestBody?
      case "headers":
        headers?[normalizedRef]!.value = newValue as! Header?
      case "securitySchemes":
        securitySchemes?[normalizedRef]!.value = newValue as! SecurityScheme?
      case "links":
        links?[normalizedRef]!.value = newValue as! Link?
      case "callbacks":
        callbacks?[normalizedRef]!.value = newValue as! Callback?
      case "pathItems":
        pathItems?[normalizedRef]!.value = newValue as! PathItem?
      default:
        fatalError()
      }
    }
  }
}
