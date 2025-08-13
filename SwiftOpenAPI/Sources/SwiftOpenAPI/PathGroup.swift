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

    /// Adds a path item at the specified path components
    public mutating func addPathItem(_ item: Referenceable<PathItem>, at pathComponents: [String]) {
      guard !pathComponents.isEmpty else { return }
      
      if pathComponents.count == 1 {
        // Add to this group's items
        items[pathComponents[0]] = item
      } else {
        // Add to a subgroup
        let groupName = pathComponents[0]
        let remainingPath = Array(pathComponents.dropFirst())

        if groups[groupName] == nil {
          groups[groupName] = PathGroup()
        }
        
        groups[groupName]!.addPathItem(item, at: remainingPath)
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
  }
}
