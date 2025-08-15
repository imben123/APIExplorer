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
        return getItem(in: subdirectories, key: String(ref.dropPrefix("./")))
      }
      set {
        let normalizedRef = ref.dropPrefix("./").dropPrefix("components/").dropPrefix("pathItems/").dropPrefix("paths/")
        let subdirectories = normalizedRef.split(separator: "/").dropLast().map { String($0) }
        updateItem(in: subdirectories, filePath: String(ref.dropPrefix("./")), updatedItem: newValue)
      }
    }

    public subscript(group pathComponents: [String]) -> PathGroup? {
      get {
        return getGroup(pathComponents)
      }
      set {
        setGroup(newValue, subdirectories: pathComponents)
      }
    }

    public mutating func addGroups(forPath path: String) {
      let normalizedPath = path.dropPrefix("./").dropPrefix("components/").dropPrefix("pathItems/").dropPrefix("paths/")
      let subdirectories = normalizedPath.split(separator: "/").map { String($0) }
      setGroup(PathGroup(), subdirectories: subdirectories)
    }

    private mutating func setGroup(_ group: PathGroup?, subdirectories: [String]) {
      var subdirectories = subdirectories
      let item = subdirectories.removeFirst()
      if subdirectories.isEmpty {
        if let group {
          groups[item] = group
        } else {
          groups.removeValue(forKey: item)
        }
      } else {
        var intermediateGroup = groups[item] ?? PathGroup()
        intermediateGroup.setGroup(group, subdirectories: subdirectories)
        groups[item] = intermediateGroup
      }
    }

    func getItem(in pathComponents: [String], key: String) -> Referenceable<PathItem>? {
      guard pathComponents.isEmpty else {
        var pathComponents = pathComponents
        let groupName = pathComponents.removeFirst()
        return groups[groupName]?.getItem(in: pathComponents, key: key)
      }
      return items[key]
    }

    mutating func removeItem(in pathComponents: [String], key: String) -> Referenceable<PathItem>? {
      guard pathComponents.isEmpty else {
        var pathComponents = pathComponents
        let groupName = pathComponents.removeFirst()
        return groups[groupName]?.removeItem(in: pathComponents, key: key)
      }
      return items.removeValue(forKey: key)
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
      // Normalize file path
      let filePath = filePath.removingPrefix("./")

      // Convert to array for easy manipulation
      var itemsArray = Array(items)

      // Get current index
      guard let currentIndex = itemsArray.firstIndex(where: { $0.key == filePath }) else { return }

      // Move the item
      let item = itemsArray.remove(at: currentIndex)
      itemsArray.insert(item, at: max(0, min(toIndex, itemsArray.count)))

      // Convert back to dictionary
      items = OrderedDictionary(uniqueKeysWithValues: itemsArray)
    }
    
    /// Moves a subgroup to a specific index within the groups collection
    /// - Parameters:
    ///   - groupName: The name of the group to move
    ///   - toIndex: The target index (clamped to valid range)
    mutating func moveGroup(groupName: String, toIndex: Int) {
      // Convert to array for easy manipulation
      var groupsArray = Array(groups)

      // Get current index
      guard let currentIndex = groupsArray.firstIndex(where: { $0.key == groupName }) else {
        return
      }

      // Move the group
      let group = groupsArray.remove(at: currentIndex)
      groupsArray.insert(group, at: max(0, min(toIndex, groupsArray.count)))

      // Convert back to dictionary
      groups = OrderedDictionary(uniqueKeysWithValues: groupsArray)
    }
  }
}
