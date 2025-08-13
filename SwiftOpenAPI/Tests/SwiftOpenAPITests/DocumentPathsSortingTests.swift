//
//  DocumentPathsSortingTests.swift
//  SwiftOpenAPITests
//
//  Created by Ben Davis on 13/08/2025.
//

import Testing
@testable import SwiftOpenAPI
import Collections

typealias Referenceable = OpenAPI.Referenceable
typealias PathItem = OpenAPI.PathItem
typealias PathGroup = OpenAPI.PathGroup

@Suite("Document Paths Sorting Tests")
struct DocumentPathsSortingTests {
  
  @Test("Sort paths in correct order: values, internal refs, top-level external refs, grouped")
  func sortPathsInCorrectOrder() throws {
    // Create a document with mixed path types
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    // Create paths in random order with different types
    document.paths = [
      "/grouped-b": .reference("./paths/groupB/item1.yaml"), // Group B
      "/value-path-2": .value(PathItem()), // Value path
      "/internal-ref": .reference("#/components/pathItems/internal"), // Internal ref
      "/top-level": .reference("./paths/toplevel.yaml"), // Top-level external ref
      "/grouped-a": .reference("./paths/groupA/item1.yaml"), // Group A
      "/value-path-1": .value(PathItem()) // Value path
    ]
    
    // Set up component files structure
    document.componentFiles = OpenAPI.Components()
    var rootPathItems = PathGroup()
    
    // Top-level external reference
    rootPathItems.items["paths/toplevel.yaml"] = .value(PathItem())
    
    // Create groups (in specific order after sorting)
    var groupA = PathGroup()
    groupA.items["paths/groupA/item1.yaml"] = .value(PathItem())
    
    var groupB = PathGroup()
    groupB.items["paths/groupB/item1.yaml"] = .value(PathItem())
    
    rootPathItems.groups["groupA"] = groupA
    rootPathItems.groups["groupB"] = groupB
    
    document.componentFiles?.pathItems = rootPathItems
    
    // Sort the document paths
    document.sortDocumentPaths()
    
    // Verify the order is correct
    let sortedKeys = Array(document.paths!.keys)
    #expect(sortedKeys == [
      "/value-path-2",    // 1. Value paths (original order)
      "/value-path-1",
      "/internal-ref",    // 2. Internal references
      "/top-level",       // 3. Top-level external references
      "/grouped-a",       // 4. Group A paths
      "/grouped-b"        // 4. Group B paths
    ])
  }
  
  @Test("Handle nested groups in correct order")
  func handleNestedGroupsInOrder() throws {
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    // Paths in random order
    document.paths = [
      "/deep-nested": .reference("./paths/a/b/deep.yaml"),
      "/top-a": .reference("./paths/a/top.yaml"),
      "/value-path": .value(PathItem()),
      "/mid-level": .reference("./paths/a/mid.yaml")
    ]
    
    // Set up nested component structure
    document.componentFiles = OpenAPI.Components()
    var rootPathItems = PathGroup()
    
    var groupA = PathGroup()
    groupA.items["paths/a/top.yaml"] = .value(PathItem())
    groupA.items["paths/a/mid.yaml"] = .value(PathItem())
    
    var nestedGroupB = PathGroup()
    nestedGroupB.items["paths/a/b/deep.yaml"] = .value(PathItem())
    
    groupA.groups["b"] = nestedGroupB
    rootPathItems.groups["a"] = groupA
    
    document.componentFiles?.pathItems = rootPathItems
    
    // Sort the document paths
    document.sortDocumentPaths()
    
    // Verify nested groups are processed in order
    let sortedKeys = Array(document.paths!.keys)
    #expect(sortedKeys == [
      "/value-path",    // Value paths first
      "/top-a",         // Group A items first
      "/mid-level",     // Then other Group A items
      "/deep-nested"    // Then nested group B items
    ])
  }
  
  @Test("Handle empty groups and missing paths")
  func handleEmptyGroupsAndMissingPaths() throws {
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    document.paths = [
      "/value-path": .value(PathItem()),
      "/missing-ref": .reference("./paths/nonexistent.yaml") // This file doesn't exist in componentFiles
    ]
    
    // Set up empty component structure
    document.componentFiles = OpenAPI.Components()
    document.componentFiles?.pathItems = PathGroup()
    
    // Sort should not crash
    document.sortDocumentPaths()
    
    // Should preserve existing paths even if files don't exist
    #expect(document.paths!.keys.contains("/value-path"))
    #expect(document.paths!.keys.contains("/missing-ref"))
  }
  
  @Test("Preserve original order within each category")
  func preserveOriginalOrderWithinCategories() throws {
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    // Multiple paths of same type in specific order
    document.paths = [
      "/value-zebra": .value(PathItem()),
      "/value-alpha": .value(PathItem()),
      "/value-beta": .value(PathItem()),
      "/internal-zebra": .reference("#/components/pathItems/zebra"),
      "/internal-alpha": .reference("#/components/pathItems/alpha")
    ]
    
    document.componentFiles = OpenAPI.Components()
    document.componentFiles?.pathItems = PathGroup()
    
    // Sort the document paths
    document.sortDocumentPaths()
    
    // Verify order is preserved within each category
    let sortedKeys = Array(document.paths!.keys)
    #expect(sortedKeys == [
      "/value-zebra",     // Value paths in original order
      "/value-alpha",
      "/value-beta",
      "/internal-zebra",  // Internal refs in original order
      "/internal-alpha"
    ])
  }
  
  @Test("Handle complex group hierarchy with multiple levels")
  func handleComplexGroupHierarchy() throws {
    var document = OpenAPI.Document(
      openapi: "3.0.0",
      info: OpenAPI.Info(title: "Test API", version: "1.0.0")
    )
    
    // Complex path structure
    document.paths = [
      "/group2-item": .reference("./paths/group2/item.yaml"),
      "/group1-nested-item": .reference("./paths/group1/nested/item.yaml"),
      "/group1-item": .reference("./paths/group1/item.yaml"),
      "/value-item": .value(PathItem())
    ]
    
    // Create complex hierarchy
    document.componentFiles = OpenAPI.Components()
    var rootPathItems = PathGroup()
    
    // Group 1 with nested subgroup
    var group1 = PathGroup()
    group1.items["paths/group1/item.yaml"] = .value(PathItem())
    
    var nested = PathGroup()
    nested.items["paths/group1/nested/item.yaml"] = .value(PathItem())
    group1.groups["nested"] = nested
    
    // Group 2 
    var group2 = PathGroup()
    group2.items["paths/group2/item.yaml"] = .value(PathItem())
    
    rootPathItems.groups["group1"] = group1
    rootPathItems.groups["group2"] = group2
    
    document.componentFiles?.pathItems = rootPathItems
    
    // Sort the document paths
    document.sortDocumentPaths()
    
    // Verify complex hierarchy is handled correctly
    let sortedKeys = Array(document.paths!.keys)
    #expect(sortedKeys == [
      "/value-item",         // Value paths first
      "/group1-item",        // Group 1 items
      "/group1-nested-item", // Group 1 nested items
      "/group2-item"         // Group 2 items
    ])
  }
}
