//
//  OpenAPI.PathGroupMoveTests.swift
//  SwiftOpenAPITests
//
//  Created by Ben Davis on 13/08/2025.
//

import Testing
@testable import SwiftOpenAPI
import Collections

@Suite("PathGroup Move Tests")
struct PathGroupMoveTests {
  
  @Test("Move item to specific index")
  func moveItemToSpecificIndex() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    // Add items in initial order
    pathGroup.items["item1.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["item2.yaml"] = .value(OpenAPI.PathItem()) 
    pathGroup.items["item3.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["item4.yaml"] = .value(OpenAPI.PathItem())
    
    // Move item2 to index 0 (beginning)
    pathGroup.moveItem(filePath: "item2.yaml", toIndex: 0)
    
    let keys = Array(pathGroup.items.keys)
    #expect(keys == ["item2.yaml", "item1.yaml", "item3.yaml", "item4.yaml"])
  }
  
  @Test("Move item to end with large index")
  func moveItemToEndWithLargeIndex() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    pathGroup.items["item1.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["item2.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["item3.yaml"] = .value(OpenAPI.PathItem())
    
    // Move item1 to index 999 (should clamp to end)
    pathGroup.moveItem(filePath: "item1.yaml", toIndex: 999)
    
    let keys = Array(pathGroup.items.keys)
    #expect(keys == ["item2.yaml", "item3.yaml", "item1.yaml"])
  }
  
  @Test("Move item to beginning with negative index")
  func moveItemToBeginningWithNegativeIndex() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    pathGroup.items["item1.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["item2.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["item3.yaml"] = .value(OpenAPI.PathItem())
    
    // Move item3 to index -5 (should clamp to 0)
    pathGroup.moveItem(filePath: "item3.yaml", toIndex: -5)
    
    let keys = Array(pathGroup.items.keys)
    #expect(keys == ["item3.yaml", "item1.yaml", "item2.yaml"])
  }
  
  @Test("Move item to middle index")
  func moveItemToMiddleIndex() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    pathGroup.items["item1.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["item2.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["item3.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["item4.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["item5.yaml"] = .value(OpenAPI.PathItem())
    
    // Move item5 to index 2 (middle)
    pathGroup.moveItem(filePath: "item5.yaml", toIndex: 2)
    
    let keys = Array(pathGroup.items.keys)
    #expect(keys == ["item1.yaml", "item2.yaml", "item5.yaml", "item3.yaml", "item4.yaml"])
  }
  
  @Test("Move non-existent item does nothing")
  func moveNonExistentItemDoesNothing() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    pathGroup.items["item1.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["item2.yaml"] = .value(OpenAPI.PathItem())
    
    let originalKeys = Array(pathGroup.items.keys)
    
    // Try to move non-existent item
    pathGroup.moveItem(filePath: "nonexistent.yaml", toIndex: 0)
    
    let keysAfter = Array(pathGroup.items.keys)
    #expect(keysAfter == originalKeys)
  }
  
  @Test("Move group to specific index")
  func moveGroupToSpecificIndex() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    // Add groups in initial order
    pathGroup.groups["groupA"] = OpenAPI.PathGroup()
    pathGroup.groups["groupB"] = OpenAPI.PathGroup()
    pathGroup.groups["groupC"] = OpenAPI.PathGroup()
    pathGroup.groups["groupD"] = OpenAPI.PathGroup()
    
    // Move groupC to index 0 (beginning)
    pathGroup.moveGroup(groupName: "groupC", toIndex: 0)
    
    let keys = Array(pathGroup.groups.keys)
    #expect(keys == ["groupC", "groupA", "groupB", "groupD"])
  }
  
  @Test("Move group to end with large index")
  func moveGroupToEndWithLargeIndex() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    pathGroup.groups["groupA"] = OpenAPI.PathGroup()
    pathGroup.groups["groupB"] = OpenAPI.PathGroup()
    pathGroup.groups["groupC"] = OpenAPI.PathGroup()
    
    // Move groupA to index 999 (should clamp to end)
    pathGroup.moveGroup(groupName: "groupA", toIndex: 999)
    
    let keys = Array(pathGroup.groups.keys)
    #expect(keys == ["groupB", "groupC", "groupA"])
  }
  
  @Test("Move group to beginning with negative index")
  func moveGroupToBeginningWithNegativeIndex() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    pathGroup.groups["groupA"] = OpenAPI.PathGroup()
    pathGroup.groups["groupB"] = OpenAPI.PathGroup()
    pathGroup.groups["groupC"] = OpenAPI.PathGroup()
    
    // Move groupC to index -10 (should clamp to 0)
    pathGroup.moveGroup(groupName: "groupC", toIndex: -10)
    
    let keys = Array(pathGroup.groups.keys)
    #expect(keys == ["groupC", "groupA", "groupB"])
  }
  
  @Test("Move non-existent group does nothing")
  func moveNonExistentGroupDoesNothing() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    pathGroup.groups["groupA"] = OpenAPI.PathGroup()
    pathGroup.groups["groupB"] = OpenAPI.PathGroup()
    
    let originalKeys = Array(pathGroup.groups.keys)
    
    // Try to move non-existent group
    pathGroup.moveGroup(groupName: "nonexistent", toIndex: 0)
    
    let keysAfter = Array(pathGroup.groups.keys)
    #expect(keysAfter == originalKeys)
  }
  
  @Test("Move item in single item collection")
  func moveItemInSingleItemCollection() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    pathGroup.items["onlyItem.yaml"] = .value(OpenAPI.PathItem())
    
    // Move the only item to any index should keep it in place
    pathGroup.moveItem(filePath: "onlyItem.yaml", toIndex: 5)
    
    let keys = Array(pathGroup.items.keys)
    #expect(keys == ["onlyItem.yaml"])
    #expect(pathGroup.items.count == 1)
  }
  
  @Test("Move group in single group collection")
  func moveGroupInSingleGroupCollection() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    pathGroup.groups["onlyGroup"] = OpenAPI.PathGroup()
    
    // Move the only group to any index should keep it in place
    pathGroup.moveGroup(groupName: "onlyGroup", toIndex: -5)
    
    let keys = Array(pathGroup.groups.keys)
    #expect(keys == ["onlyGroup"])
    #expect(pathGroup.groups.count == 1)
  }
  
  @Test("Move preserves item content")
  func movePreservesItemContent() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    let operation = OpenAPI.Operation(summary: "Test operation")
    let pathItem = OpenAPI.PathItem(get: operation)
    
    pathGroup.items["item1.yaml"] = .value(pathItem)
    pathGroup.items["item2.yaml"] = .value(OpenAPI.PathItem())
    
    // Move item1 to end
    pathGroup.moveItem(filePath: "item1.yaml", toIndex: 1)
    
    // Verify content is preserved
    if case .value(let movedItem) = pathGroup.items["item1.yaml"] {
      #expect(movedItem.get?.summary == "Test operation")
    } else {
      Issue.record("Item content was not preserved during move")
    }
  }
  
  @Test("Complex reordering scenario")
  func complexReorderingScenario() throws {
    var pathGroup = OpenAPI.PathGroup()
    
    // Set up complex scenario with both items and groups
    pathGroup.items["item1.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["item2.yaml"] = .value(OpenAPI.PathItem())
    pathGroup.items["item3.yaml"] = .value(OpenAPI.PathItem())
    
    pathGroup.groups["groupA"] = OpenAPI.PathGroup()
    pathGroup.groups["groupB"] = OpenAPI.PathGroup()
    
    // Perform multiple moves
    pathGroup.moveItem(filePath: "item3.yaml", toIndex: 0)  // Move item3 to start: [item3, item1, item2]
    pathGroup.moveGroup(groupName: "groupB", toIndex: 0)   // Move groupB to start: groups = [groupB, groupA]
    pathGroup.moveItem(filePath: "item1.yaml", toIndex: 2) // Move item1 to end (index 2 >= remaining count): [item3, item2, item1]
    
    let itemKeys = Array(pathGroup.items.keys)
    let groupKeys = Array(pathGroup.groups.keys)
    
    #expect(itemKeys == ["item3.yaml", "item2.yaml", "item1.yaml"])
    #expect(groupKeys == ["groupB", "groupA"])
  }
}