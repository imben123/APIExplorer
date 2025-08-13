//
//  PathSortingTests.swift
//  SwiftOpenAPITests
//
//  Created by Ben Davis on 13/08/2025.
//

import Testing
@testable import SwiftOpenAPI
import Collections

@Suite("Path Sorting Tests")
struct PathSortingTests {
  
  @Test("Sort paths within groups by document order")
  func sortPathsWithinGroups() throws {
    // Create a PathGroup with items in random order
    var pathGroup = OpenAPI.PathGroup()
    
    // Add items in a different order than they appear in document.paths
    pathGroup.items["paths/group1/zebra.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["paths/group1/alpha.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["paths/group1/beta.yaml"] = .value(OpenAPI.PathItem())
    
    // Create document.paths in a specific order
    let documentPaths: OrderedDictionary<String, OpenAPI.Referenceable<OpenAPI.PathItem>> = [
      "/alpha": .reference("./paths/group1/alpha.yaml"),
      "/zebra": .reference("./paths/group1/zebra.yaml"), 
      "/beta": .reference("./paths/group1/beta.yaml")
    ]
    
    // Sort the PathGroup
    pathGroup.sortByPathOrder(pathOrder: documentPaths)
    
    // Verify the items are now in the correct order
    let sortedKeys = Array(pathGroup.items.keys)
    #expect(sortedKeys == [
      "paths/group1/alpha.yaml",
      "paths/group1/zebra.yaml", 
      "paths/group1/beta.yaml"
    ])
  }
  
  @Test("Sort groups by first path appearance")
  func sortGroupsByFirstPathAppearance() throws {
    // Create a PathGroup with nested groups
    var rootGroup = OpenAPI.PathGroup()
    
    var groupA = OpenAPI.PathGroup()
    groupA.items["paths/a/item2.yaml"] = .value(OpenAPI.PathItem())
    groupA.items["paths/a/item4.yaml"] = .value(OpenAPI.PathItem())
    
    var groupB = OpenAPI.PathGroup()
    groupB.items["paths/b/item1.yaml"] = .value(OpenAPI.PathItem())
    groupB.items["paths/b/item3.yaml"] = .value(OpenAPI.PathItem())
    
    // Add groups in reverse alphabetical order
    rootGroup.groups["a"] = groupA
    rootGroup.groups["b"] = groupB
    
    // Create document.paths where group B's first path appears before group A's
    let documentPaths: OrderedDictionary<String, OpenAPI.Referenceable<OpenAPI.PathItem>> = [
      "/item1": .reference("./paths/b/item1.yaml"), // First from group B
      "/item2": .reference("./paths/a/item2.yaml"), // First from group A  
      "/item3": .reference("./paths/b/item3.yaml"),
      "/item4": .reference("./paths/a/item4.yaml")
    ]
    
    // Sort the PathGroup
    rootGroup.sortByPathOrder(pathOrder: documentPaths)
    
    // Verify groups are ordered by first appearance (B before A)
    let sortedGroupKeys = Array(rootGroup.groups.keys)
    #expect(sortedGroupKeys == ["b", "a"])
    
    // Verify items within each group are also sorted
    let groupBItems = Array(rootGroup.groups["b"]!.items.keys)
    #expect(groupBItems == [
      "paths/b/item1.yaml",
      "paths/b/item3.yaml"
    ])
    
    let groupAItems = Array(rootGroup.groups["a"]!.items.keys)
    #expect(groupAItems == [
      "paths/a/item2.yaml", 
      "paths/a/item4.yaml"
    ])
  }
  
  @Test("Handle mixed references and inline paths")
  func handleMixedReferencesAndInline() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    // Add some referenced paths
    pathGroup.items["paths/users.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["paths/products.yaml"] = .value(OpenAPI.PathItem())
    
    // Create document.paths with mixed references and inline values
    let documentPaths: OrderedDictionary<String, OpenAPI.Referenceable<OpenAPI.PathItem>> = [
      "/inline1": .value(OpenAPI.PathItem()), // Inline - should not affect sorting
      "/products": .reference("./paths/products.yaml"), // Referenced - should be sorted
      "/inline2": .value(OpenAPI.PathItem()), // Inline
      "/users": .reference("./paths/users.yaml") // Referenced - should be sorted
    ]
    
    // Sort the PathGroup
    pathGroup.sortByPathOrder(pathOrder: documentPaths)
    
    // Verify referenced items are sorted by their document order
    let sortedKeys = Array(pathGroup.items.keys)
    #expect(sortedKeys == [
      "paths/products.yaml",
      "paths/users.yaml"
    ])
  }
  
  @Test("Empty groups and paths handled correctly")
  func handleEmptyGroupsAndPaths() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    // Empty document paths
    let documentPaths: OrderedDictionary<String, OpenAPI.Referenceable<OpenAPI.PathItem>> = [:]
    
    // Sort should not crash
    pathGroup.sortByPathOrder(pathOrder: documentPaths)
    
    // Should remain empty
    #expect(pathGroup.items.isEmpty)
    #expect(pathGroup.groups.isEmpty)
  }
  
  @Test("Recursive sorting of nested groups")
  func recursiveSortingOfNestedGroups() throws {
    // Create deeply nested structure
    var rootGroup = OpenAPI.PathGroup()
    
    var levelOne = OpenAPI.PathGroup()
    var levelTwo = OpenAPI.PathGroup()
    
    // Add items in reverse order
    levelTwo.items["paths/a/b/zebra.yaml"] = .value(OpenAPI.PathItem())
    levelTwo.items["paths/a/b/alpha.yaml"] = .value(OpenAPI.PathItem())
    
    levelOne.groups["b"] = levelTwo
    rootGroup.groups["a"] = levelOne
    
    // Document paths in specific order
    let documentPaths: OrderedDictionary<String, OpenAPI.Referenceable<OpenAPI.PathItem>> = [
      "/alpha": .reference("./paths/a/b/alpha.yaml"),
      "/zebra": .reference("./paths/a/b/zebra.yaml")
    ]
    
    // Sort recursively
    rootGroup.sortByPathOrder(pathOrder: documentPaths)
    
    // Verify deep nesting is sorted correctly
    let deepItems = Array(rootGroup.groups["a"]!.groups["b"]!.items.keys)
    #expect(deepItems == [
      "paths/a/b/alpha.yaml",
      "paths/a/b/zebra.yaml"
    ])
  }
}