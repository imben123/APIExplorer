import Testing
import Foundation
@testable import SwiftOpenAPI

@Test func yamlParsingTest() async throws {
  // Load the comprehensive YAML fixture
  let bundle = Bundle.module
  guard let yamlURL = bundle.url(forResource: "Resources/comprehensive-openapi", withExtension: "yaml") else {
    throw TestError.fixtureNotFound
  }
  
  let yamlData = try Data(contentsOf: yamlURL)
  
  // Test that the YAML parses without throwing
  let document = try OpenAPI.Document.parse(from: yamlData)
  
  // Basic sanity checks to ensure it parsed correctly
  #expect(document.openapi == "3.1.0")
  #expect(document.info.title == "Comprehensive Pet Store API")
  #expect(document.info.version == "1.2.3")
}

@Test func jsonParsingTest() async throws {
  // Load the comprehensive JSON fixture
  let bundle = Bundle.module
  guard let jsonURL = bundle.url(forResource: "Resources/comprehensive-openapi", withExtension: "json") else {
    throw TestError.fixtureNotFound
  }
  
  let jsonData = try Data(contentsOf: jsonURL)
  
  // Test that the JSON parses without throwing
  let document = try OpenAPI.Document.parse(from: jsonData)
  
  // Basic sanity checks to ensure it parsed correctly
  #expect(document.openapi == "3.1.0")
  #expect(document.info.title == "Comprehensive Pet Store API")
  #expect(document.info.version == "1.2.3")
}

@Test func multiFileOpenAPIDocumentParsing() throws {
  // Test parsing a multi-file OpenAPI 3.1.1 document using Document.from(fileWrapper:)
  let exampleURL = Bundle.module.url(forResource: "example", withExtension: nil, subdirectory: "Resources")!
  let fileWrapper = try FileWrapper(url: exampleURL)
  
  // Parse the document
  let document = try OpenAPI.Document.from(fileWrapper: fileWrapper)
  
  // Verify basic document properties
  #expect(document.openapi == "3.1.1")
  #expect(document.info.title == "Blackwell Data API")
  #expect(document.info.version == "1.0.0")
  
  // Verify servers are parsed correctly
  #expect(document.servers?.count == 4)
  #expect(document.servers?[0].url == "http://localhost:3000")
  #expect(document.servers?[1].url == "https://staging.data.fora.health")
  #expect(document.servers?[2].url == "https://demo.data.fora.health")
  #expect(document.servers?[3].url == "https://data.fora.health")
  
  // Verify all referenced path files are parsed into paths
  let paths = document.paths ?? [:]
  #expect(paths.count == 4)
  #expect(paths["/"] != nil)
  #expect(paths["/penguin"] != nil)
  #expect(paths["/hippo"] != nil)
  #expect(paths["/penguin/nested"] != nil)
  
  // Test ungroupedPathItems - only healthcheck should be ungrouped
  let ungroupedPaths = document.ungroupedPathItems
  #expect(ungroupedPaths.count == 1) 
  #expect(ungroupedPaths.contains("/"))
  
  // Test groupedPathItems - should have group1 and group2 with their respective paths
  let groupedPaths = document.groupedPathItems
  #expect(groupedPaths.count == 2)
  #expect(groupedPaths["group1"] != nil)
  #expect(groupedPaths["group2"] != nil)
  
  // Verify group1 contains penguin paths
  let group1 = groupedPaths["group1"]!
  #expect(group1.items["paths/group1/penguin.yaml"] != nil)
  #expect(group1.groups["nested"] != nil)
  
  // Verify nested group contains nested path
  let nestedGroup = group1.groups["nested"]!
  #expect(nestedGroup.items["paths/group1/nested/nested.yaml"] != nil)
  
  // Verify group2 contains hippo path
  let group2 = groupedPaths["group2"]!
  #expect(group2.items["paths/group2/hippo.yaml"] != nil)
  
  // Test accessing individual path items via file path subscript
  let healthcheckPath = document[filePath: "paths/healthcheck.yaml"]
  #expect(healthcheckPath.get?.summary == "Healthcheck")
  
  let penguinPath = document[filePath: "paths/group1/penguin.yaml"]
  #expect(penguinPath.get?.summary == "New operation")
  
  let hippoPath = document[filePath: "paths/group2/hippo.yaml"]
  #expect(hippoPath.get?.summary == "New operation")
  
  let nestedPath = document[filePath: "paths/group1/nested/nested.yaml"]
  #expect(nestedPath.get?.summary == "New operation")
}

enum TestError: Error {
  case fixtureNotFound
}
