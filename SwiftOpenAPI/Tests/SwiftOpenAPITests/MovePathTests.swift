//
//  MovePathTests.swift
//  SwiftOpenAPITests
//
//  Created by Ben Davis on 13/08/2025.
//

import Testing
@testable import SwiftOpenAPI
import Collections

@Suite("Move Path Tests")
struct MovePathTests {
  
  @Test("Move inline path to group")
  func moveInlinePathToGroup() throws {
    // Create a document with an inline path
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    let testOperation = OpenAPI.Operation(
      summary: "Test operation",
      description: "Test description"
    )
    let testPathItem = OpenAPI.PathItem(get: testOperation)
    
    // Add an inline path
    document.paths = [
      "/users": .value(testPathItem)
    ]
    
    // Move the path to a group
    let success = document.movePathToGroup("/users", groupPath: ["v1", "resources"])
    
    // Verify the move was successful
    #expect(success == true)
    
    // Verify the path still exists but as a reference
    #expect(document.paths?["/users"] != nil)
    if case .reference(let ref) = document.paths?["/users"] {
      #expect(ref == "./paths/v1/resources/users.yaml")
    } else {
      Issue.record("Path should be a reference after moving to group")
    }
    
    // Verify the component file was created
    #expect(document.componentFiles?.pathItems?["paths/v1/resources/users.yaml"] != nil)
    
    // Verify the path item content is preserved
    let movedPathItem = document.componentFiles?.pathItems?["paths/v1/resources/users.yaml"]?.value
    #expect(movedPathItem?.get?.summary == "Test operation")
    #expect(movedPathItem?.get?.description == "Test description")
  }
  
  @Test("Move referenced path to different group")
  func moveReferencedPathToDifferentGroup() throws {
    // Create a document with a referenced path
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    let testOperation = OpenAPI.Operation(
      summary: "Test operation",
      description: "Test description"
    )
    let testPathItem = OpenAPI.PathItem(post: testOperation)
    
    // Set up component files
    document.componentFiles = OpenAPI.Components()
    document.componentFiles?.pathItems = OpenAPI.PathGroup()
    document.componentFiles?.pathItems?["paths/old/location/users.yaml"] = .value(testPathItem)
    
    // Add a referenced path
    document.paths = [
      "/users": .reference("./paths/old/location/users.yaml")
    ]
    
    // Move the path to a new group
    let success = document.movePathToGroup("/users", groupPath: ["v2", "api"])
    
    // Verify the move was successful
    #expect(success == true)
    
    // Verify the path reference was updated
    if case .reference(let ref) = document.paths?["/users"] {
      #expect(ref == "./paths/v2/api/users.yaml")
    } else {
      Issue.record("Path should still be a reference after moving")
    }
    
    // Verify the old component file was removed
    #expect(document.componentFiles?.pathItems?["paths/old/location/users.yaml"] == nil)
    
    // Verify the new component file was created
    #expect(document.componentFiles?.pathItems?["paths/v2/api/users.yaml"] != nil)
    
    // Verify the path item content is preserved
    let movedPathItem = document.componentFiles?.pathItems?["paths/v2/api/users.yaml"]?.value
    #expect(movedPathItem?.post?.summary == "Test operation")
    #expect(movedPathItem?.post?.description == "Test description")
  }
  
  @Test("Move non-existent path returns false")
  func moveNonExistentPath() throws {
    // Create an empty document
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    // Try to move a non-existent path
    let success = document.movePathToGroup("/nonexistent", groupPath: ["v1"])
    
    // Verify the move failed
    #expect(success == false)
  }
  
  @Test("Move path to root group")
  func movePathToRootGroup() throws {
    // Create a document with a path in a nested group
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    let testOperation = OpenAPI.Operation(summary: "Test")
    let testPathItem = OpenAPI.PathItem(get: testOperation)
    
    // Set up component files in a nested location
    document.componentFiles = OpenAPI.Components()
    document.componentFiles?.pathItems = OpenAPI.PathGroup()
    document.componentFiles?.pathItems?["paths/nested/deep/products.yaml"] = .value(testPathItem)
    
    // Add a referenced path
    document.paths = [
      "/products": .reference("./paths/nested/deep/products.yaml")
    ]
    
    // Move the path to root group (empty array)
    let success = document.movePathToGroup("/products", groupPath: [])
    
    // Verify the move was successful
    #expect(success == true)
    
    // Verify the path reference was updated to root
    if case .reference(let ref) = document.paths?["/products"] {
      #expect(ref == "./paths/products.yaml")
    } else {
      Issue.record("Path should be a reference at root level")
    }
    
    // Verify the component file is at root level
    #expect(document.componentFiles?.pathItems?["paths/products.yaml"] != nil)
    #expect(document.componentFiles?.pathItems?["paths/nested/deep/products.yaml"] == nil)
  }
  
  @Test("Move path with complex name")
  func movePathWithComplexName() throws {
    // Create a document with a path that has slashes in its name
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    let testOperation = OpenAPI.Operation(summary: "Test")
    let testPathItem = OpenAPI.PathItem(delete: testOperation)
    
    // Add a path with slashes
    document.paths = [
      "/users/{id}/posts": .value(testPathItem)
    ]
    
    // Move the path to a group
    let success = document.movePathToGroup("/users/{id}/posts", groupPath: ["v1"])
    
    // Verify the move was successful
    #expect(success == true)
    
    // Verify the file name properly escapes slashes
    if case .reference(let ref) = document.paths?["/users/{id}/posts"] {
      #expect(ref == "./paths/v1/users_{id}_posts.yaml")
    } else {
      Issue.record("Path should be a reference with escaped slashes")
    }
    
    // Verify the component file was created with escaped name
    #expect(document.componentFiles?.pathItems?["paths/v1/users_{id}_posts.yaml"] != nil)
  }
  
  @Test("Move path to specific index in group")
  func movePathToSpecificIndexInGroup() throws {
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    // Create a group with existing items
    document.componentFiles = OpenAPI.Components()
    var rootPathItems = OpenAPI.PathGroup()
    
    var groupV1 = OpenAPI.PathGroup()
    groupV1.items["paths/v1/first.yaml"] = .value(OpenAPI.PathItem())
    groupV1.items["paths/v1/second.yaml"] = .value(OpenAPI.PathItem())
    groupV1.items["paths/v1/third.yaml"] = .value(OpenAPI.PathItem())
    
    rootPathItems.groups["v1"] = groupV1
    document.componentFiles?.pathItems = rootPathItems
    
    // Set up paths
    document.paths = [
      "/first": .reference("./paths/v1/first.yaml"),
      "/second": .reference("./paths/v1/second.yaml"), 
      "/third": .reference("./paths/v1/third.yaml"),
      "/new-path": .value(OpenAPI.PathItem())
    ]
    
    // Move the inline path to index 1 in the v1 group
    let success = document.movePathToGroup("/new-path", groupPath: ["v1"], index: 1)
    
    // Verify the move was successful
    #expect(success == true)
    
    // Check that the path is now a reference
    if case .reference = document.paths?["/new-path"] {
      // Good
    } else {
      Issue.record("Path should be a reference after moving to group")
    }
    
    // Verify the ordering in the group
    let v1GroupItems = Array(document.componentFiles?.pathItems?.groups["v1"]?.items.keys ?? [])
    #expect(v1GroupItems.count == 4)
    
    // The new path should be at index 1
    #expect(v1GroupItems[1].contains("new-path") || v1GroupItems[1].contains("new_path"))
  }
  
  @Test("Move path to index 0 in root group")
  func movePathToIndex0InRootGroup() throws {
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    // Create root items
    document.componentFiles = OpenAPI.Components()
    var rootPathItems = OpenAPI.PathGroup()
    rootPathItems.items["paths/existing1.yaml"] = .value(OpenAPI.PathItem())
    rootPathItems.items["paths/existing2.yaml"] = .value(OpenAPI.PathItem())
    document.componentFiles?.pathItems = rootPathItems
    
    // Set up paths
    document.paths = [
      "/existing1": .reference("./paths/existing1.yaml"),
      "/existing2": .reference("./paths/existing2.yaml"),
      "/new-item": .value(OpenAPI.PathItem())
    ]
    
    // Move the new item to index 0 in root group
    let success = document.movePathToGroup("/new-item", groupPath: [], index: 0)
    
    // Verify the move was successful
    #expect(success == true)
    
    // Verify the ordering in root group
    let rootItems = Array(document.componentFiles?.pathItems?.items.keys ?? [])
    #expect(rootItems.count == 3)
    
    // The new item should be at index 0
    #expect(rootItems[0].contains("new-item") || rootItems[0].contains("new_item"))
  }
}
