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
}