//
//  PathGroup.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 08/08/2025.
//

import Collections
import SwiftToolbox

public extension OpenAPI {
  /// A group that can contain path items and nested subgroups
  struct PathGroup: Model {
    /// Path items directly in this group
    public var items: OrderedDictionary<String, Referenceable<PathItem>>
    
    /// Nested subgroups
    public var groups: OrderedDictionary<String, PathGroup>
    
    public init(
      items: OrderedDictionary<String, Referenceable<PathItem>> = [:],
      groups: OrderedDictionary<String, PathGroup> = [:]
    ) {
      self.items = items
      self.groups = groups
    }
    
    /// Returns true if this group is empty (no items and no subgroups)
    public var isEmpty: Bool {
      let hasNoItems = items.isEmpty
      let hasNoGroups = groups.isEmpty
      return hasNoItems && hasNoGroups
    }
    
    /// Recursively collects all path items from this group and its subgroups
    public func allPathItems() -> OrderedDictionary<String, Referenceable<PathItem>> {
      var result = OrderedDictionary<String, Referenceable<PathItem>>()
      
      // Add items from this group
      for (key, value) in items {
        result[key] = value
      }
      
      // Recursively add items from subgroups
      for (groupName, group) in groups {
        let subItems = group.allPathItems()
        for (key, value) in subItems {
          // Prefix the key with the group name for uniqueness
          let prefixedKey = "\(groupName)/\(key)"
          result[prefixedKey] = value
        }
      }
      
      return result
    }

    public subscript(ref: String) -> Referenceable<PathItem>? {
      get {
        let normalizedRef = ref.dropPrefix("./").dropPrefix("components/").dropPrefix("pathItems/").dropPrefix("paths/")
        let subdirectories = normalizedRef.split(separator: "/").dropLast().map { String($0) }
        return getItem(in: subdirectories, filePath: String(ref.dropPrefix("./")))
      }
      set {
        let normalizedRef = ref.dropPrefix("./").dropPrefix("components/").dropPrefix("pathItems/").dropPrefix("paths/")
        let subdirectories = normalizedRef.split(separator: "/").dropLast().map { String($0) }
        updateItem(in: subdirectories, filePath: String(ref.dropPrefix("./")), updatedItem: newValue)
      }
    }

    public mutating func addGroups(forPath path: String) {
      let normalizedPath = path.dropPrefix("./").dropPrefix("components/").dropPrefix("pathItems/").dropPrefix("paths/")
      let subdirectories = normalizedPath.split(separator: "/").map { String($0) }
      addGroups(subdirectories)
    }

    private mutating func addGroups(_ subdirectories: [String]) {
      var subdirectories = subdirectories
      let item = subdirectories.removeFirst()
      groups[item] = PathGroup()
      if !subdirectories.isEmpty {
        groups[item]!.addGroups(subdirectories)
      }
    }

    func getItem(in subdirectories: [String], filePath: String) -> Referenceable<PathItem>? {
      guard subdirectories.isEmpty else {
        var subdirectories = subdirectories
        let groupName = subdirectories.removeFirst()
        return groups[groupName]!.getItem(in: subdirectories, filePath: filePath)
      }
      return items[filePath]
    }

    func getGroup(_ pathComponents: [String]) -> PathGroup? {
      guard pathComponents.isEmpty else {
        var pathComponents = pathComponents
        let groupName = pathComponents.removeFirst()
        return groups[groupName]!.getGroup(pathComponents)
      }
      return self
    }

    mutating func updateItem(in subdirectories: [String], filePath: String, updatedItem: Referenceable<PathItem>?) {
      guard subdirectories.isEmpty else {
        var subdirectories = subdirectories
        let groupName = subdirectories.removeFirst()
        if groups[groupName] == nil {
          groups[groupName] = PathGroup()
        }
        return groups[groupName]!.updateItem(in: subdirectories, filePath: filePath, updatedItem: updatedItem)
      }
      if let updatedItem {
        items[filePath] = updatedItem
      } else {
        items.removeValue(forKey: filePath)
      }
    }
    
    /// Sort paths and groups based on their order in document.paths
    mutating func sortByPathOrder(pathOrder: OrderedDictionary<String, Referenceable<PathItem>>) {
      // Create a mapping from file path to path string for ordering
      var filePathToPath: [String: String] = [:]
      var pathToIndex: [String: Int] = [:]
      
      for (index, (pathString, pathItemRef)) in pathOrder.enumerated() {
        pathToIndex[pathString] = index
        
        if case .reference(let ref) = pathItemRef {
          let normalizedRef = ref.hasPrefix("./") ? String(ref.dropFirst(2)) : ref
          filePathToPath[normalizedRef] = pathString
        }
      }
      
      // Sort items by their path order
      let sortedItems = items.sorted { (lhs, rhs) in
        let lhsPath = filePathToPath[lhs.key]
        let rhsPath = filePathToPath[rhs.key]
        
        let lhsIndex = lhsPath.flatMap { pathToIndex[$0] } ?? Int.max
        let rhsIndex = rhsPath.flatMap { pathToIndex[$0] } ?? Int.max
        
        return lhsIndex < rhsIndex
      }
      
      // Rebuild the items dictionary in sorted order
      var newItems = OrderedDictionary<String, Referenceable<PathItem>>()
      for (key, value) in sortedItems {
        newItems[key] = value
      }
      items = newItems
      
      // Sort groups by the first appearance of their paths
      let sortedGroups = groups.sorted { (lhs, rhs) in
        let lhsFirstIndex = getFirstPathIndex(in: lhs.value, filePathToPath: filePathToPath, pathToIndex: pathToIndex)
        let rhsFirstIndex = getFirstPathIndex(in: rhs.value, filePathToPath: filePathToPath, pathToIndex: pathToIndex)
        
        return lhsFirstIndex < rhsFirstIndex
      }
      
      // Rebuild the groups dictionary in sorted order
      var newGroups = OrderedDictionary<String, PathGroup>()
      for (key, var value) in sortedGroups {
        // Recursively sort subgroups
        value.sortByPathOrder(pathOrder: pathOrder)
        newGroups[key] = value
      }
      groups = newGroups
    }
    
    /// Get the index of the first path that appears in this group (recursively)
    private func getFirstPathIndex(in group: PathGroup, filePathToPath: [String: String], pathToIndex: [String: Int]) -> Int {
      var minIndex = Int.max
      
      // Check items in this group
      for (filePath, _) in group.items {
        if let pathString = filePathToPath[filePath],
           let index = pathToIndex[pathString] {
          minIndex = min(minIndex, index)
        }
      }
      
      // Recursively check subgroups
      for (_, subgroup) in group.groups {
        let subgroupMinIndex = getFirstPathIndex(in: subgroup, filePathToPath: filePathToPath, pathToIndex: pathToIndex)
        minIndex = min(minIndex, subgroupMinIndex)
      }
      
      return minIndex
    }
    
    /// Moves an item to a specific index within the items collection
    /// - Parameters:
    ///   - filePath: The file path of the item to move
    ///   - toIndex: The target index (clamped to valid range)
    mutating func moveItem(filePath: String, toIndex: Int) {
      guard let item = items[filePath] else { return }
      
      // Remove the item from its current position
      items.removeValue(forKey: filePath)
      
      // Clamp the target index to valid range
      let itemsArray = Array(items)
      let clampedIndex = max(0, min(toIndex, itemsArray.count))
      
      // Rebuild the ordered dictionary with the item at the new position
      var newItems = OrderedDictionary<String, Referenceable<PathItem>>()
      
      for (index, (key, value)) in itemsArray.enumerated() {
        if index == clampedIndex {
          // Insert the moved item at this position
          newItems[filePath] = item
        }
        newItems[key] = value
      }
      
      // If the target index is at or beyond the end, append the item
      if clampedIndex >= itemsArray.count {
        newItems[filePath] = item
      }
      
      items = newItems
    }
    
    /// Moves a subgroup to a specific index within the groups collection
    /// - Parameters:
    ///   - groupName: The name of the group to move
    ///   - toIndex: The target index (clamped to valid range)
    mutating func moveGroup(groupName: String, toIndex: Int) {
      guard let group = groups[groupName] else { return }
      
      // Remove the group from its current position
      groups.removeValue(forKey: groupName)
      
      // Clamp the target index to valid range
      let groupsArray = Array(groups)
      let clampedIndex = max(0, min(toIndex, groupsArray.count))
      
      // Rebuild the ordered dictionary with the group at the new position
      var newGroups = OrderedDictionary<String, PathGroup>()
      
      for (index, (key, value)) in groupsArray.enumerated() {
        if index == clampedIndex {
          // Insert the moved group at this position
          newGroups[groupName] = group
        }
        newGroups[key] = value
      }
      
      // If the target index is at or beyond the end, append the group
      if clampedIndex >= groupsArray.count {
        newGroups[groupName] = group
      }
      
      groups = newGroups
    }
  }
}
