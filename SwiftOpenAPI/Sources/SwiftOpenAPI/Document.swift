//
//  Document.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 28/07/2025.
//

import Foundation
import SwiftToolbox
import Yams
import SwiftUI
import UniformTypeIdentifiers
import Collections
import CryptoKit

public extension OpenAPI {
  /// The root object of the OpenAPI specification document.
  struct Document: Model, ComponentFileSerializable {
    /// The OpenAPI Specification version that the OpenAPI document uses.
    public let openapi: String
    
    /// Provides metadata about the API.
    public let info: Info
    
    /// The default value for the $schema keyword within Schema Objects contained within this OAS document.
    public let jsonSchemaDialect: String?
    
    /// An array of Server Objects, which provide connectivity information to a target server.
    public var servers: [Server]?
    
    /// The available paths and operations for the API.
    public var paths: OrderedDictionary<String, Referenceable<PathItem>>?

    /// The incoming webhooks that MAY be received as part of this API and that the API consumer MAY choose to implement.
    public let webhooks: OrderedDictionary<String, Referenceable<PathItem>>?

    /// An element to hold various schemas for the document.
    public var components: Components?
    
    /// A declaration of which security mechanisms can be used across the API.
    public let security: [SecurityRequirement]?
    
    /// A list of tags used by the document with additional metadata.
    public let tags: [Tag]?
    
    /// Additional external documentation.
    public let externalDocs: ExternalDocumentation?
    
    /// A map of external component files, keyed by file path.
    /// Used for resolving external component references.
    public var componentFiles: Components?
    
    /// SHA256 hash of the original serialized data for change detection.
    /// This property is excluded from Codable to prevent it from being serialized.
    /// Wrapped in Box to allow mutation during serialization.
    internal var _originalDataHash: Box<String?> = Box(nil)
    
    public var originalDataHash: String? {
      get { _originalDataHash.value }
      set { _originalDataHash.value = newValue }
    }
    
    /// A dictionary of other files that are not part of the OpenAPI specification.
    /// Keyed by file path relative to the root directory, storing unparsed file data.
    /// This property is excluded from Codable to prevent it from being serialized.
    public var otherFiles: OrderedDictionary<String, Data>?

    private enum CodingKeys: String, CodingKey {
      case openapi
      case info
      case jsonSchemaDialect
      case servers
      case paths
      case webhooks
      case components
      case security
      case tags
      case externalDocs
      // componentFiles, originalDataHash, and otherFiles are intentionally excluded from Codable - they're not part of OpenAPI spec
    }

    public subscript(path pathString: String) -> PathItem {
      get {
        guard let result = paths?[pathString]?.resolve(in: self) else {
          return PathItem()
        }
        return result
      }
      set {
        if case .reference = paths?[pathString] {
          var updatedReference = paths![pathString]!
          updatedReference.update(in: &self, newValue: newValue)
          paths![pathString]! = updatedReference
        } else {
          if paths == nil {
            paths = [:]
          }
          paths![pathString] = .value(newValue)
        }
      }
    }

    public subscript(requestBody args: OperationReference) -> RequestBody {
      get {
        guard let result = self[path: args.path][method: args.method].requestBody?.resolve(in: self) else {
          return .init(content: [:])
        }
        return result
      }
      set {
        var ref = self[path: args.path][method: args.method].requestBody ?? .value(newValue)
        ref.update(in: &self, newValue: newValue)
        self[path: args.path][method: args.method].requestBody = ref
      }
    }

    public init(
      openapi: String,
      info: Info,
      jsonSchemaDialect: String? = nil,
      servers: [Server]? = nil,
      paths: OrderedDictionary<String, Referenceable<PathItem>>? = nil,
      webhooks: OrderedDictionary<String, Referenceable<PathItem>>? = nil,
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
      self.componentFiles = nil
      self.otherFiles = nil
    }
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      openapi = try container.decode(String.self, forKey: .openapi)
      info = try container.decode(Info.self, forKey: .info)
      jsonSchemaDialect = try container.decodeIfPresent(String.self, forKey: .jsonSchemaDialect)
      servers = try container.decodeIfPresent([Server].self, forKey: .servers)
      paths = try container.decodeIfPresent(OrderedDictionary<String, Referenceable<PathItem>>.self, forKey: .paths)
      webhooks = try container.decodeIfPresent(OrderedDictionary<String, Referenceable<PathItem>>.self, forKey: .webhooks)
      components = try container.decodeIfPresent(Components.self, forKey: .components)
      security = try container.decodeIfPresent([SecurityRequirement].self, forKey: .security)
      tags = try container.decodeIfPresent([Tag].self, forKey: .tags)
      externalDocs = try container.decodeIfPresent(ExternalDocumentation.self, forKey: .externalDocs)
      
      // componentFiles, and otherFiles are not decoded from the specification data
      componentFiles = nil
      otherFiles = nil
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      try container.encode(openapi, forKey: .openapi)
      try container.encode(info, forKey: .info)
      try container.encodeIfPresent(jsonSchemaDialect, forKey: .jsonSchemaDialect)
      try container.encodeIfPresent(servers, forKey: .servers)
      try container.encodeIfPresent(paths, forKey: .paths)
      try container.encodeIfPresent(webhooks, forKey: .webhooks)
      try container.encodeIfPresent(components, forKey: .components)
      try container.encodeIfPresent(security, forKey: .security)
      try container.encodeIfPresent(tags, forKey: .tags)
      try container.encodeIfPresent(externalDocs, forKey: .externalDocs)
      
      // componentFiles, originalDataHash, and otherFiles are not encoded to the specification data
    }
    
    /// Creates a Document from a FileWrapper (file or folder)
    /// - Parameter fileWrapper: The FileWrapper containing OpenAPI specification files
    /// - Returns: A parsed Document with external files parsed and categorized
    /// - Throws: DecodingError if no valid OpenAPI file is found or cannot be parsed
    public static func from(fileWrapper: FileWrapper) throws -> Document {
      guard fileWrapper.isDirectory else {
        // Handle regular file
        guard let data = fileWrapper.regularFileContents else {
          throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "FileWrapper has no content"))
        }
        var document = try parse(from: data)
        // Serialize the parsed document and hash that data for semantic comparison
        let reserializedData = try document.serialize(format: .yaml)
        document.originalDataHash = reserializedData.calculateHash()
        return document
      }
      
      // Initialize component collections
      var schemas: OrderedDictionary<String, Schema> = [:]
      var responses: OrderedDictionary<String, Response> = [:]
      var parameters: OrderedDictionary<String, Parameter> = [:]
      var examples: OrderedDictionary<String, Example> = [:]
      var requestBodies: OrderedDictionary<String, RequestBody> = [:]
      var headers: OrderedDictionary<String, Header> = [:]
      var securitySchemes: OrderedDictionary<String, SecurityScheme> = [:]
      var links: OrderedDictionary<String, Link> = [:]
      var callbacks: OrderedDictionary<String, Callback> = [:]
      var pathItems = OpenAPI.PathGroup()

      var otherFiles: OrderedDictionary<String, Data> = [:]
      
      func parseFile<T: Decodable>(_ type: T.Type, from data: Data, fileName: String) throws -> T {
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        
        switch fileExtension {
        case "json":
          return try OrderedJSONDecoder().decode(type, from: data)
        case "yaml", "yml":
          let decoder = YAMLDecoder()
          decoder.orderedDictionaryCodingStrategy = .keyedContainer
          return try decoder.decode(type, from: data)
        default:
          // Try YAML first as it's more common for OpenAPI
          do {
            let decoder = YAMLDecoder()
            decoder.orderedDictionaryCodingStrategy = .keyedContainer
            return try decoder.decode(type, from: data)
          } catch {
            // If YAML fails, try JSON
            return try OrderedJSONDecoder().decode(type, from: data)
          }
        }
      }
      
      func collectFiles(from wrapper: FileWrapper, basePath: String = "") {
        guard let fileWrappers = wrapper.fileWrappers else { return }

        let isPathsDirectory = basePath.hasPrefix("paths/") || basePath.hasPrefix("components/pathItems")
        if fileWrappers.isEmpty && isPathsDirectory {
          pathItems.addGroups(forPath: basePath)
        }

        for (fileName, fileWrapper) in fileWrappers {
          let filePath = basePath.isEmpty ? fileName : "\(basePath)/\(fileName)"
          
          if fileWrapper.isDirectory {
            collectFiles(from: fileWrapper, basePath: filePath)
          } else if let data = fileWrapper.regularFileContents {
            // Determine component type based on directory structure
            let pathComponents = filePath.split(separator: "/").map(String.init)
            
            // Skip hidden files and main OpenAPI files
            if fileName.hasPrefix(".") {
              continue
            }
            
            do {
              // Handle paths directory - pathItems should be in ./paths/**/* (allow subdirectories)
              if pathComponents.count >= 2 && pathComponents[0] == "paths" {
                var pathItem = try parseFile(PathItem.self, from: data, fileName: fileName)
                
                // Calculate hash for the parsed PathItem
                let encoder = YAMLEncoder.default
                encoder.orderedDictionaryCodingStrategy = .keyedContainer
                let reserializedData = try encoder.encode(pathItem).data(using: .utf8)!
                let hash = reserializedData.calculateHash()
                
                // Set hash on PathItem
                pathItem.originalDataHash = hash
                
                pathItems[filePath] = .value(pathItem)
              }
              // Handle components directories (allow subdirectories)
              else if pathComponents.count >= 3 && pathComponents[0] == "components" {
                let componentType = pathComponents[1]
                
                switch componentType {
                case "schemas":
                  var schema = try parseFile(Schema.self, from: data, fileName: fileName)
                  // Calculate and set hash for the parsed Schema
                  let encoder = YAMLEncoder.default
                  encoder.orderedDictionaryCodingStrategy = .keyedContainer
                  let reserializedData = try encoder.encode(schema).data(using: .utf8)!
                  schema.originalDataHash = reserializedData.calculateHash()
                  schemas[filePath] = schema
                case "responses":
                  var response = try parseFile(Response.self, from: data, fileName: fileName)
                  // Calculate and set hash for the parsed Response
                  let encoder = YAMLEncoder.default
                  encoder.orderedDictionaryCodingStrategy = .keyedContainer
                  let reserializedData = try encoder.encode(response).data(using: .utf8)!
                  response.originalDataHash = reserializedData.calculateHash()
                  responses[filePath] = response
                case "parameters":
                  var parameter = try parseFile(Parameter.self, from: data, fileName: fileName)
                  // Calculate and set hash for the parsed Parameter
                  let encoder = YAMLEncoder.default
                  encoder.orderedDictionaryCodingStrategy = .keyedContainer
                  let reserializedData = try encoder.encode(parameter).data(using: .utf8)!
                  parameter.originalDataHash = reserializedData.calculateHash()
                  parameters[filePath] = parameter
                case "examples":
                  var example = try parseFile(Example.self, from: data, fileName: fileName)
                  // Calculate and set hash for the parsed Example
                  let encoder = YAMLEncoder.default
                  encoder.orderedDictionaryCodingStrategy = .keyedContainer
                  let reserializedData = try encoder.encode(example).data(using: .utf8)!
                  example.originalDataHash = reserializedData.calculateHash()
                  examples[filePath] = example
                case "requestBodies":
                  var requestBody = try parseFile(RequestBody.self, from: data, fileName: fileName)
                  // Calculate and set hash for the parsed RequestBody
                  let encoder = YAMLEncoder.default
                  encoder.orderedDictionaryCodingStrategy = .keyedContainer
                  let reserializedData = try encoder.encode(requestBody).data(using: .utf8)!
                  requestBody.originalDataHash = reserializedData.calculateHash()
                  requestBodies[filePath] = requestBody
                case "headers":
                  var header = try parseFile(Header.self, from: data, fileName: fileName)
                  // Calculate and set hash for the parsed Header
                  let encoder = YAMLEncoder.default
                  encoder.orderedDictionaryCodingStrategy = .keyedContainer
                  let reserializedData = try encoder.encode(header).data(using: .utf8)!
                  header.originalDataHash = reserializedData.calculateHash()
                  headers[filePath] = header
                case "securitySchemes":
                  var securityScheme = try parseFile(SecurityScheme.self, from: data, fileName: fileName)
                  // Calculate and set hash for the parsed SecurityScheme
                  let encoder = YAMLEncoder.default
                  encoder.orderedDictionaryCodingStrategy = .keyedContainer
                  let reserializedData = try encoder.encode(securityScheme).data(using: .utf8)!
                  securityScheme.originalDataHash = reserializedData.calculateHash()
                  securitySchemes[filePath] = securityScheme
                case "links":
                  var link = try parseFile(Link.self, from: data, fileName: fileName)
                  // Calculate and set hash for the parsed Link
                  let encoder = YAMLEncoder.default
                  encoder.orderedDictionaryCodingStrategy = .keyedContainer
                  let reserializedData = try encoder.encode(link).data(using: .utf8)!
                  link.originalDataHash = reserializedData.calculateHash()
                  links[filePath] = link
                case "callbacks":
                  var callback = try parseFile(Callback.self, from: data, fileName: fileName)
                  // Calculate and set hash for the parsed Callback
                  let encoder = YAMLEncoder.default
                  encoder.orderedDictionaryCodingStrategy = .keyedContainer
                  let reserializedData = try encoder.encode(callback).data(using: .utf8)!
                  callback.originalDataHash = reserializedData.calculateHash()
                  callbacks[filePath] = callback
                case "pathItems":
                  var pathItem = try parseFile(PathItem.self, from: data, fileName: fileName)
                  
                  // Calculate hash for the parsed PathItem
                  let encoder = YAMLEncoder.default
                  encoder.orderedDictionaryCodingStrategy = .keyedContainer
                  let reserializedData = try encoder.encode(pathItem).data(using: .utf8)!
                  let hash = reserializedData.calculateHash()
                  
                  // Set hash on PathItem
                  pathItem.originalDataHash = hash
                  
                  pathItems[filePath] = .value(pathItem)
                default:
                  // Skip unsupported component types
                  continue
                }
              }
              // Store files not in the correct directory structure as otherFiles
              else {
                otherFiles[filePath] = data
              }
            } catch {
              // If parsing fails, store as otherFiles
              otherFiles[filePath] = data
            }
          }
        }
      }
      
      collectFiles(from: fileWrapper)

      // Look for common OpenAPI files
      let commonFiles = ["openapi.yaml", "openapi.yml", "openapi.json", "swagger.yaml", "swagger.yml", "swagger.json"]
      
      for fileName in commonFiles {
        if let fileWrapper = fileWrapper.fileWrappers?[fileName],
           let data = fileWrapper.regularFileContents {
          var document = try parse(from: data)
          // Serialize the parsed document and hash that data for semantic comparison
          let reserializedData = try document.serialize(format: .yaml)
          document.originalDataHash = reserializedData.calculateHash()

          // Create Components if we have any external files
          var componentFiles: Components? = nil
          if !schemas.isEmpty || !responses.isEmpty || !parameters.isEmpty || !examples.isEmpty ||
             !requestBodies.isEmpty || !headers.isEmpty || !securitySchemes.isEmpty ||
             !links.isEmpty || !callbacks.isEmpty || !pathItems.isEmpty {
            componentFiles = Components(
              schemas: schemas.isEmpty ? nil : schemas.mapValues { .value($0) },
              responses: responses.isEmpty ? nil : responses.mapValues { .value($0) },
              parameters: parameters.isEmpty ? nil : parameters.mapValues { .value($0) },
              examples: examples.isEmpty ? nil : examples.mapValues { .value($0) },
              requestBodies: requestBodies.isEmpty ? nil : requestBodies.mapValues { .value($0) },
              headers: headers.isEmpty ? nil : headers.mapValues { .value($0) },
              securitySchemes: securitySchemes.isEmpty ? nil : securitySchemes.mapValues { .value($0) },
              links: links.isEmpty ? nil : links.mapValues { .value($0) },
              callbacks: callbacks.isEmpty ? nil : callbacks.mapValues { .value($0) },
              pathItems: pathItems
            )
          }

          document.componentFiles = componentFiles
          document.otherFiles = otherFiles.isEmpty ? nil : otherFiles
          
          // Sort pathItems to match the order in document.paths
          if let paths = document.paths, var pathItems = document.componentFiles?.pathItems {
            pathItems.sortByPathOrder(pathOrder: paths)
            document.componentFiles?.pathItems = pathItems
          }
          
          // Re-sort document.paths in the specified order
          document.sortDocumentPaths()
          
          return document
        }
      }
      
      // If no standard files found, throw an error
      throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "No OpenAPI specification file found in directory"))
    }

    /// Parses an OpenAPI Document from Data
    /// - Parameter data: The JSON or YAML data to parse
    /// - Returns: A parsed Document
    /// - Throws: DecodingError if the data cannot be parsed
    public static func parse(from data: Data) throws -> Document {
      // First try to parse as JSON
      do {
        return try OrderedJSONDecoder().decode(Document.self, from: data)
      } catch {
        // If JSON parsing fails, try YAML
        let decoder = YAMLDecoder()
        decoder.orderedDictionaryCodingStrategy = .keyedContainer
        return try decoder.decode(Document.self, from: data)
      }
    }
    
    /// Format options for serializing the document
    public enum SerializationFormat {
      case json
      case yaml
    }
    
    /// Serializes the Document to Data in the specified format
    /// - Parameter format: The format to serialize to (JSON or YAML)
    /// - Returns: The serialized data
    /// - Throws: EncodingError if the document cannot be serialized
    public func serialize(format: SerializationFormat) throws -> Data {
      switch format {
      case .json:
        let encoder = OrderedJSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
      case .yaml:
        let encoder = YAMLEncoder.default
        encoder.orderedDictionaryCodingStrategy = .keyedContainer
        return try encoder.encode(self).data(using: .utf8)!
      }
    }

  }
}
