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
    public var paths: OrderedDictionary<String, Referenceable<PathItem>>?

    /// The incoming webhooks that MAY be received as part of this API and that the API consumer MAY choose to implement.
    public let webhooks: OrderedDictionary<String, Referenceable<PathItem>>?

    /// An element to hold various schemas for the document.
    public let components: Components?
    
    /// A declaration of which security mechanisms can be used across the API.
    public let security: [SecurityRequirement]?
    
    /// A list of tags used by the document with additional metadata.
    public let tags: [Tag]?
    
    /// Additional external documentation.
    public let externalDocs: ExternalDocumentation?
    
    /// A map of external component files, keyed by file path.
    /// Used for resolving external component references.
    public var componentFiles: Components?

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
      // componentFiles is intentionally excluded from Codable - it's not part of OpenAPI spec
    }

    public subscript(path ref: String) -> PathItem {
      get {
        paths![ref]!.resolve(in: self)!
      }
      set {
        if let ref = paths![ref]!.ref {
          let normalizedRef = ref.hasPrefix("./") ? String(ref.dropFirst(2)) : ref
          componentFiles!.pathItems![normalizedRef]!.value = newValue
        } else {
          paths![ref]!.value = newValue
        }
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
      externalDocs: ExternalDocumentation? = nil,
      componentFiles: Components? = nil
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
      self.componentFiles = componentFiles
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
      
      // componentFiles is not decoded from the specification data
      componentFiles = nil
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
      
      // componentFiles is not encoded to the specification data
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
        return try parse(from: data)
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
      var pathItems: OrderedDictionary<String, PathItem> = [:]
      
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
                
                // Extract subdirectory components (everything between "paths" and the filename)
                let subdirectories = Array(pathComponents[1..<pathComponents.count-1])
                
                // Create a new PathItem with subdirectories if there are any
                if !subdirectories.isEmpty {
                  pathItem = PathItem(
                    summary: pathItem.summary,
                    description: pathItem.description,
                    get: pathItem.get,
                    put: pathItem.put,
                    post: pathItem.post,
                    delete: pathItem.delete,
                    options: pathItem.options,
                    head: pathItem.head,
                    patch: pathItem.patch,
                    trace: pathItem.trace,
                    servers: pathItem.servers,
                    parameters: pathItem.parameters,
                    subdirectories: subdirectories
                  )
                }
                
                pathItems[filePath] = pathItem
              }
              // Handle components directories (allow subdirectories)
              else if pathComponents.count >= 3 && pathComponents[0] == "components" {
                let componentType = pathComponents[1]
                
                switch componentType {
                case "schemas":
                  let schema = try parseFile(Schema.self, from: data, fileName: fileName)
                  schemas[filePath] = schema
                case "responses":
                  let response = try parseFile(Response.self, from: data, fileName: fileName)
                  responses[filePath] = response
                case "parameters":
                  let parameter = try parseFile(Parameter.self, from: data, fileName: fileName)
                  parameters[filePath] = parameter
                case "examples":
                  let example = try parseFile(Example.self, from: data, fileName: fileName)
                  examples[filePath] = example
                case "requestBodies":
                  let requestBody = try parseFile(RequestBody.self, from: data, fileName: fileName)
                  requestBodies[filePath] = requestBody
                case "headers":
                  let header = try parseFile(Header.self, from: data, fileName: fileName)
                  headers[filePath] = header
                case "securitySchemes":
                  let securityScheme = try parseFile(SecurityScheme.self, from: data, fileName: fileName)
                  securitySchemes[filePath] = securityScheme
                case "links":
                  let link = try parseFile(Link.self, from: data, fileName: fileName)
                  links[filePath] = link
                case "callbacks":
                  let callback = try parseFile(Callback.self, from: data, fileName: fileName)
                  callbacks[filePath] = callback
                case "pathItems":
                  var pathItem = try parseFile(PathItem.self, from: data, fileName: fileName)
                  
                  // Extract subdirectory components (everything between "components/pathItems" and the filename)
                  let subdirectories = Array(pathComponents[2..<pathComponents.count-1])
                  
                  // Create a new PathItem with subdirectories if there are any
                  if !subdirectories.isEmpty {
                    pathItem = PathItem(
                      summary: pathItem.summary,
                      description: pathItem.description,
                      get: pathItem.get,
                      put: pathItem.put,
                      post: pathItem.post,
                      delete: pathItem.delete,
                      options: pathItem.options,
                      head: pathItem.head,
                      patch: pathItem.patch,
                      trace: pathItem.trace,
                      servers: pathItem.servers,
                      parameters: pathItem.parameters,
                      subdirectories: subdirectories
                    )
                  }
                  
                  pathItems[filePath] = pathItem
                default:
                  // Skip unsupported component types
                  continue
                }
              }
              // Skip files not in the correct directory structure
            } catch {
              // If parsing fails, skip this file
              continue
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
              pathItems: pathItems.isEmpty ? nil : pathItems.mapValues { .value($0) }
            )
          }

          document.componentFiles = componentFiles
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
        let encoder = YAMLEncoder()
        encoder.orderedDictionaryCodingStrategy = .keyedContainer
        return try encoder.encode(self).data(using: .utf8)!
      }
    }

    /// Serializes the Document to a FileWrapper based on WriteConfiguration
    /// - Parameter configuration: The write configuration containing content type information
    /// - Returns: A FileWrapper containing the serialized document
    /// - Throws: Error if serialization fails
    public func serialize(configuration: FileDocument.WriteConfiguration) throws -> FileWrapper {
      // Check if we should write as a directory
      guard configuration.contentType == .folder else {
        // Write as a single file
        let format: SerializationFormat = configuration.contentType == .json ? .json : .yaml
        let data = try serialize(format: format)
        return FileWrapper(regularFileWithContents: data)
      }

      // Create directory wrapper
      let directoryWrapper = FileWrapper(directoryWithFileWrappers: [:])

      // Determine the main file format - prefer YAML for directories
      let mainFileName = "openapi.yaml"
      let mainFileData = try serialize(format: .yaml)
      directoryWrapper.addRegularFile(withContents: mainFileData, preferredFilename: mainFileName)

      // Add component files if available
      if let componentFiles = componentFiles {
        func addComponentFiles<T: Encodable>(_ files: OrderedDictionary<String, T>?) {
          guard let files = files else { return }

          for (filePath, component) in files {
            // Skip the main OpenAPI file to avoid duplication
            if filePath == mainFileName {
              continue
            }

            let encoder = YAMLEncoder()
            encoder.orderedDictionaryCodingStrategy = .keyedContainer
            let data = try! encoder.encode(component).data(using: .utf8)!

            // Create nested directory structure if needed
            let pathComponents = filePath.split(separator: "/").map(String.init)
            var currentWrapper = directoryWrapper

            // Navigate/create directory structure
            for (index, component) in pathComponents.enumerated() {
              if index == pathComponents.count - 1 {
                // Last component is the file
                currentWrapper.addRegularFile(withContents: data, preferredFilename: component)
              } else {
                // Directory component
                if let existingDir = currentWrapper.fileWrappers?[component] {
                  currentWrapper = existingDir
                } else {
                  let newDir = FileWrapper(directoryWithFileWrappers: [:])
                  newDir.preferredFilename = component
                  currentWrapper.addFileWrapper(newDir)
                  currentWrapper = newDir
                }
              }
            }
          }
        }

        func addPathItemFiles(_ files: OrderedDictionary<String, Referenceable<PathItem>>?) {
          guard let files = files else { return }

          for (filePath, referenceablePathItem) in files {
            // Skip the main OpenAPI file to avoid duplication
            if filePath == mainFileName {
              continue
            }

            // Extract the PathItem from the Referenceable
            guard case let .value(pathItem) = referenceablePathItem else {
              continue // Skip references, only handle direct values
            }

            let encoder = YAMLEncoder()
            encoder.orderedDictionaryCodingStrategy = .keyedContainer
            let data = try! encoder.encode(pathItem).data(using: .utf8)!

            // Use subdirectories from PathItem if available, otherwise use original filePath
            let pathComponents: [String]
            if let subdirectories = pathItem.subdirectories, !subdirectories.isEmpty {
              // Reconstruct path using subdirectories
              let fileName = (filePath as NSString).lastPathComponent
              pathComponents = ["paths"] + subdirectories + [fileName]
            } else {
              // Use original filePath
              pathComponents = filePath.split(separator: "/").map(String.init)
            }

            var currentWrapper = directoryWrapper

            // Navigate/create directory structure
            for (index, component) in pathComponents.enumerated() {
              if index == pathComponents.count - 1 {
                // Last component is the file
                currentWrapper.addRegularFile(withContents: data, preferredFilename: component)
              } else {
                // Directory component
                if let existingDir = currentWrapper.fileWrappers?[component] {
                  currentWrapper = existingDir
                } else {
                  let newDir = FileWrapper(directoryWithFileWrappers: [:])
                  newDir.preferredFilename = component
                  currentWrapper.addFileWrapper(newDir)
                  currentWrapper = newDir
                }
              }
            }
          }
        }

        // Add all component types
        addComponentFiles(componentFiles.schemas)
        addComponentFiles(componentFiles.responses)
        addComponentFiles(componentFiles.parameters)
        addComponentFiles(componentFiles.examples)
        addComponentFiles(componentFiles.requestBodies)
        addComponentFiles(componentFiles.headers)
        addComponentFiles(componentFiles.securitySchemes)
        addComponentFiles(componentFiles.links)
        addComponentFiles(componentFiles.callbacks)
        addPathItemFiles(componentFiles.pathItems)
      }

      return directoryWrapper
    }
  }
}
