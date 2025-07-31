//
//  OpenAPIDocument.swift
//  APIExplorer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftOpenAPI
import Yams

nonisolated struct OpenAPIDocument: FileDocument {
  var content: OpenAPI.Document

  var yamlString: String {
    try! YAMLEncoder().encode(content)
  }

  static var writableContentTypes: [UTType] { [.yaml, .json, .folder] }
  static var readableContentTypes: [UTType] { [.yaml, .json, .folder] }

  init(string: String? = nil) {
    if let string {
      self.content = try! YAMLDecoder().decode(OpenAPI.Document.self, from: string)
    } else {
      self.content = OpenAPI.Document(openapi: "3.1.1", info: .init(title: "Sample API", version: "1.0.0"))
    }
  }
  
  init(configuration: ReadConfiguration) throws {
    do {
      content = try OpenAPI.Document.from(fileWrapper: configuration.file)
    } catch {
      // If loading fails (e.g., no standard files found in folder), create a default document
      content = OpenAPI.Document(openapi: "3.1.1", info: .init(title: "Sample API", version: "1.0.0"))
    }
  }
  
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    return try content.serialize(configuration: configuration)
  }
}
