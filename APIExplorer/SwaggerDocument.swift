//
//  SwaggerDocument.swift
//  APIExplorer
//
//  Created by Ben Davis on 28/07/2025.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftOpenAPI
import Yams

nonisolated struct SwaggerDocument: FileDocument {
  var content: OpenAPI.Document

  var yamlString: String {
    try! YAMLEncoder().encode(content)
  }

  static var writableContentTypes: [UTType] { [.yaml, .json] }
  static var readableContentTypes: [UTType] { [.yaml, .json] }

  init(string: String? = nil) {
    if let string {
      self.content = try! YAMLDecoder().decode(OpenAPI.Document.self, from: string)
    } else {
      self.content = OpenAPI.Document(openapi: "3.1.1", info: .init(title: "Sample API", version: "1.0.0"))
    }
  }
  
  init(configuration: ReadConfiguration) throws {
    guard let data = configuration.file.regularFileContents else {
      throw CocoaError(.fileReadCorruptFile)
    }
    content = try! OpenAPI.Document.parse(from: data)
  }
  
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    let data = try JSONEncoder().encode(content)
    return .init(regularFileWithContents: data)
  }
}
