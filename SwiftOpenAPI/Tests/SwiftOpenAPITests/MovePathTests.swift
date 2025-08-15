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
  
  // MARK: - Same Group Move Optimization Tests (Bug Fix Tests)
  
  @Test("Move path within same group - forward move")
  func movePathWithinSameGroupForward() throws {
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    // Set up a group with multiple items
    document.componentFiles = OpenAPI.Components()
    var rootPathItems = OpenAPI.PathGroup()
    var groupV1 = OpenAPI.PathGroup()
    
    groupV1.items["paths/v1/first.yaml"] = .value(OpenAPI.PathItem())
    groupV1.items["paths/v1/second.yaml"] = .value(OpenAPI.PathItem())
    groupV1.items["paths/v1/third.yaml"] = .value(OpenAPI.PathItem())
    groupV1.items["paths/v1/fourth.yaml"] = .value(OpenAPI.PathItem())
    
    rootPathItems.groups["v1"] = groupV1
    document.componentFiles?.pathItems = rootPathItems
    
    // Set up paths with references to existing items
    document.paths = [
      "/first": .reference("./paths/v1/first.yaml"),
      "/second": .reference("./paths/v1/second.yaml"), 
      "/third": .reference("./paths/v1/third.yaml"),
      "/fourth": .reference("./paths/v1/fourth.yaml")
    ]
    
    // Move the first item (index 0) to index 2 within the same group
    let success = document.movePathToGroup("/first", groupPath: ["v1"], index: 2)
    
    // Verify the move was successful
    #expect(success == true)
    
    // Verify the reference didn't change (same group optimization)
    if case .reference(let ref) = document.paths?["/first"] {
      #expect(ref == "./paths/v1/first.yaml")
    } else {
      Issue.record("Path should still be a reference with same filename")
    }
    
    // Verify the ordering changed within the group
    let v1GroupItems = Array(document.componentFiles?.pathItems?.groups["v1"]?.items.keys ?? [])
    #expect(v1GroupItems == ["paths/v1/second.yaml", "paths/v1/third.yaml", "paths/v1/first.yaml", "paths/v1/fourth.yaml"])
  }
  
  @Test("Move path within same group - backward move")
  func movePathWithinSameGroupBackward() throws {
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    // Set up a group with multiple items
    document.componentFiles = OpenAPI.Components()
    var rootPathItems = OpenAPI.PathGroup()
    var groupApi = OpenAPI.PathGroup()
    
    groupApi.items["paths/api/users.yaml"] = .value(OpenAPI.PathItem())
    groupApi.items["paths/api/posts.yaml"] = .value(OpenAPI.PathItem())
    groupApi.items["paths/api/comments.yaml"] = .value(OpenAPI.PathItem())
    groupApi.items["paths/api/likes.yaml"] = .value(OpenAPI.PathItem())
    
    rootPathItems.groups["api"] = groupApi
    document.componentFiles?.pathItems = rootPathItems
    
    // Set up paths
    document.paths = [
      "/users": .reference("./paths/api/users.yaml"),
      "/posts": .reference("./paths/api/posts.yaml"), 
      "/comments": .reference("./paths/api/comments.yaml"),
      "/likes": .reference("./paths/api/likes.yaml")
    ]
    
    // Move the last item (likes) to index 1
    let success = document.movePathToGroup("/likes", groupPath: ["api"], index: 1)
    
    // Verify the move was successful
    #expect(success == true)
    
    // Verify the reference didn't change (same group optimization)
    if case .reference(let ref) = document.paths?["/likes"] {
      #expect(ref == "./paths/api/likes.yaml")
    } else {
      Issue.record("Path should still be a reference with same filename")
    }
    
    // Verify the ordering changed within the group
    let apiGroupItems = Array(document.componentFiles?.pathItems?.groups["api"]?.items.keys ?? [])
    #expect(apiGroupItems == ["paths/api/users.yaml", "paths/api/likes.yaml", "paths/api/posts.yaml", "paths/api/comments.yaml"])
  }
  
  @Test("Move path within same group - to beginning")
  func movePathWithinSameGroupToBeginning() throws {
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    // Set up root group with items
    document.componentFiles = OpenAPI.Components()
    var rootPathItems = OpenAPI.PathGroup()
    
    rootPathItems.items["paths/alpha.yaml"] = .value(OpenAPI.PathItem())
    rootPathItems.items["paths/beta.yaml"] = .value(OpenAPI.PathItem())
    rootPathItems.items["paths/gamma.yaml"] = .value(OpenAPI.PathItem())
    
    document.componentFiles?.pathItems = rootPathItems
    
    // Set up paths
    document.paths = [
      "/alpha": .reference("./paths/alpha.yaml"),
      "/beta": .reference("./paths/beta.yaml"), 
      "/gamma": .reference("./paths/gamma.yaml")
    ]
    
    // Move gamma (last) to index 0 (first) within root group
    let success = document.movePathToGroup("/gamma", groupPath: [], index: 0)
    
    // Verify the move was successful
    #expect(success == true)
    
    // Verify the reference didn't change (same group optimization)
    if case .reference(let ref) = document.paths?["/gamma"] {
      #expect(ref == "./paths/gamma.yaml")
    } else {
      Issue.record("Path should still be a reference with same filename")
    }
    
    // Verify the ordering changed within the root group
    let rootItems = Array(document.componentFiles?.pathItems?.items.keys ?? [])
    #expect(rootItems == ["paths/gamma.yaml", "paths/alpha.yaml", "paths/beta.yaml"])
  }
  
  @Test("Move path within same nested group")
  func movePathWithinSameNestedGroup() throws {
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    // Set up nested groups
    document.componentFiles = OpenAPI.Components()
    var rootPathItems = OpenAPI.PathGroup()
    var groupV1 = OpenAPI.PathGroup()
    var nestedGroup = OpenAPI.PathGroup()
    
    nestedGroup.items["paths/v1/nested/item1.yaml"] = .value(OpenAPI.PathItem())
    nestedGroup.items["paths/v1/nested/item2.yaml"] = .value(OpenAPI.PathItem())
    nestedGroup.items["paths/v1/nested/item3.yaml"] = .value(OpenAPI.PathItem())
    
    groupV1.groups["nested"] = nestedGroup
    rootPathItems.groups["v1"] = groupV1
    document.componentFiles?.pathItems = rootPathItems
    
    // Set up paths
    document.paths = [
      "/item1": .reference("./paths/v1/nested/item1.yaml"),
      "/item2": .reference("./paths/v1/nested/item2.yaml"), 
      "/item3": .reference("./paths/v1/nested/item3.yaml")
    ]
    
    // Move item2 (middle) to index 0 (first) within the nested group
    let success = document.movePathToGroup("/item2", groupPath: ["v1", "nested"], index: 0)
    
    // Verify the move was successful
    #expect(success == true)
    
    // Verify the reference didn't change (same group optimization)
    if case .reference(let ref) = document.paths?["/item2"] {
      #expect(ref == "./paths/v1/nested/item2.yaml")
    } else {
      Issue.record("Path should still be a reference with same filename")
    }
    
    // Verify the ordering changed within the nested group
    let nestedItems = Array(document.componentFiles?.pathItems?.groups["v1"]?.groups["nested"]?.items.keys ?? [])
    #expect(nestedItems == ["paths/v1/nested/item2.yaml", "paths/v1/nested/item1.yaml", "paths/v1/nested/item3.yaml"])
  }
  
  @Test("Move path to different group still works normally")
  func movePathToDifferentGroupStillWorksNormally() throws {
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    // Set up two different groups
    document.componentFiles = OpenAPI.Components()
    var rootPathItems = OpenAPI.PathGroup()
    var groupV1 = OpenAPI.PathGroup()
    var groupV2 = OpenAPI.PathGroup()
    
    groupV1.items["paths/v1/item.yaml"] = .value(OpenAPI.PathItem(summary: "V1 item"))
    groupV2.items["paths/v2/other.yaml"] = .value(OpenAPI.PathItem())
    
    rootPathItems.groups["v1"] = groupV1
    rootPathItems.groups["v2"] = groupV2
    document.componentFiles?.pathItems = rootPathItems
    
    // Set up paths
    document.paths = [
      "/item": .reference("./paths/v1/item.yaml"),
      "/other": .reference("./paths/v2/other.yaml")
    ]
    
    // Move item from v1 group to v2 group
    let success = document.movePathToGroup("/item", groupPath: ["v2"], index: 0)
    
    // Verify the move was successful
    #expect(success == true)
    
    // Verify the reference changed (different group - not optimized)
    if case .reference(let ref) = document.paths?["/item"] {
      #expect(ref == "./paths/v2/item.yaml")
    } else {
      Issue.record("Path should be a reference with new filename")
    }
    
    // Verify the old file was removed
    #expect(document.componentFiles?.pathItems?.groups["v1"]?.items["paths/v1/item.yaml"] == nil)
    
    // Verify the new file was created
    #expect(document.componentFiles?.pathItems?.groups["v2"]?.items["paths/v2/item.yaml"] != nil)
    
    // Verify content was preserved
    let movedItem = document.componentFiles?.pathItems?.groups["v2"]?.items["paths/v2/item.yaml"]?.value
    #expect(movedItem?.summary == "V1 item")
  }
}
