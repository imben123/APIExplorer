import Testing
import Foundation
@testable import SwiftOpenAPI

@Test func addPathToGroupTest() throws {
  var document = OpenAPI.Document(
    openapi: "3.1.0",
    info: OpenAPI.Info(title: "Test API", version: "1.0.0")
  )
  
  // Test adding a path to a group with default placeholder PathItem
  document.addPath("/users", toGroup: ["group1"])
  
  // Verify the path was added to document.paths
  #expect(document.paths?["/users"] != nil)
  
  // Verify the path reference points to the correct file location
  let pathRef = document.paths?["/users"]?.ref
  #expect(pathRef == "./paths/group1/users.yaml")
  
  // Verify the PathItem was added to componentFiles.pathItems
  #expect(document.componentFiles?.pathItems != nil)
  let pathItem = document.componentFiles?.pathItems?["paths/group1/users.yaml"]
  #expect(pathItem != nil)
  
  // Verify it's a placeholder PathItem with default values
  if case .value(let item) = pathItem {
    #expect(item.get?.summary == "New operation")
    #expect(item.get?.description == "Description for the new operation")
  } else {
    Issue.record("Expected value PathItem, got reference")
  }
}

@Test func addPathToNestedGroupTest() throws {
  var document = OpenAPI.Document(
    openapi: "3.1.0",
    info: OpenAPI.Info(title: "Test API", version: "1.0.0")
  )
  
  // Test adding a path to a nested group
  document.addPath("/orders", toGroup: ["group1", "nested"])
  
  // Verify the path was added
  #expect(document.paths?["/orders"] != nil)
  
  // Verify the reference points to nested location
  let pathRef = document.paths?["/orders"]?.ref
  #expect(pathRef == "./paths/group1/nested/orders.yaml")
  
  // Verify the PathItem was added to componentFiles.pathItems
  #expect(document.componentFiles?.pathItems != nil)
  let pathItem = document.componentFiles?.pathItems?["paths/group1/nested/orders.yaml"]
  #expect(pathItem != nil)
}

@Test func addPathWithCustomPathItemTest() throws {
  var document = OpenAPI.Document(
    openapi: "3.1.0",
    info: OpenAPI.Info(title: "Test API", version: "1.0.0")
  )
  
  // Create a custom PathItem
  let customOperation = OpenAPI.Operation(
    summary: "Custom operation",
    description: "Custom description"
  )
  let customPathItem = OpenAPI.PathItem(post: customOperation)
  
  // Test adding a path with custom PathItem
  document.addPath("/products", toGroup: ["api"], pathItem: customPathItem)
  
  // Verify the custom PathItem was used
  let pathItem = document.componentFiles?.pathItems?["paths/api/products.yaml"]
  if case .value(let item) = pathItem {
    #expect(item.post?.summary == "Custom operation")
    #expect(item.post?.description == "Custom description")
    #expect(item.get == nil) // Should not have GET operation
  } else {
    Issue.record("Expected value PathItem, got reference")
  }
}

@Test func addPathWithLeadingSlashTest() throws {
  var document = OpenAPI.Document(
    openapi: "3.1.0",
    info: OpenAPI.Info(title: "Test API", version: "1.0.0")
  )
  
  // Test that leading slash is handled correctly
  document.addPath("/users", toGroup: ["group1"])
  
  // Verify path is stored with leading slash
  #expect(document.paths?["/users"] != nil)
  
  // Verify file path doesn't have leading slash
  let pathRef = document.paths?["/users"]?.ref
  #expect(pathRef == "./paths/group1/users.yaml")
}

@Test func addPathWithoutLeadingSlashTest() throws {
  var document = OpenAPI.Document(
    openapi: "3.1.0",
    info: OpenAPI.Info(title: "Test API", version: "1.0.0")
  )
  
  // Test path without leading slash
  document.addPath("users", toGroup: ["group1"])
  
  // Verify path is stored with leading slash added
  #expect(document.paths?["/users"] != nil)
  
  // Verify file path is correct
  let pathRef = document.paths?["/users"]?.ref
  #expect(pathRef == "./paths/group1/users.yaml")
}

@Test func generateUniquePathNameTest() throws {
  var document = OpenAPI.Document(
    openapi: "3.1.0",
    info: OpenAPI.Info(title: "Test API", version: "1.0.0")
  )
  
  // Add some existing paths to a group
  document.addPath("/panda", toGroup: ["group1"])
  document.addPath("/elephant", toGroup: ["group1"])
  
  // Multiple calls might generate the same name (since it's random)
  // but they should all be valid unique names
  for _ in 0..<100 {
    let path = document.generateUniquePathName(in: ["group1"])
    #expect(path.hasPrefix("/"))
    #expect(path != "/panda")
    #expect(path != "/elephant")
  }
}

@Test func generateUniquePathNameWithCollisionTest() throws {
  var document = OpenAPI.Document(
    openapi: "3.1.0",
    info: OpenAPI.Info(title: "Test API", version: "1.0.0")
  )
  
  // Pre-populate with many common animal names to force counter usage
  let commonAnimals = ["panda", "elephant", "tiger", "dolphin", "penguin", "koala", "giraffe", "butterfly", "rabbit", "falcon", "turtle", "fox", "wolf", "bear", "deer"]
  
  for animal in commonAnimals {
    document.addPath("/\(animal)", toGroup: ["group1"])
  }
  
  // Generate a unique name - should use counter since many animals are taken
  let uniquePath = document.generateUniquePathName(in: ["group1"])
  #expect(uniquePath.hasPrefix("/"))
  
  // Should not conflict with existing paths
  let existingPaths = commonAnimals.map { "/\($0)" }
  #expect(!existingPaths.contains(uniquePath))
}

@Test func placeholderPathItemTest() throws {
  let placeholder = OpenAPI.Document.placeholderPathItem()
  
  // Verify placeholder has expected default values
  #expect(placeholder.get?.summary == "New operation")
  #expect(placeholder.get?.description == "Description for the new operation")
  
  // Verify other HTTP methods are nil
  #expect(placeholder.post == nil)
  #expect(placeholder.put == nil)
  #expect(placeholder.delete == nil)
  #expect(placeholder.patch == nil)
  #expect(placeholder.head == nil)
  #expect(placeholder.options == nil)
  #expect(placeholder.trace == nil)
}
