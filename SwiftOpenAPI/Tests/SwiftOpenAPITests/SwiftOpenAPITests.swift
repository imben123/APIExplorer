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

enum TestError: Error {
  case fixtureNotFound
}
