//
//  PathsListViewModel.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 15/08/2025.
//

import SwiftUI
import SwiftOpenAPI
import Collections

/// Represents an item in the flattened path list
enum PathListItem: Identifiable, Equatable {
  case group(name: String, level: Int, groupPath: [String])
  case operation(path: String, method: HTTPMethod, level: Int, groupPath: [String])
  
  var id: String {
    switch self {
    case .group(let name, let level, let groupPath):
      return "group:\(groupPath.joined(separator: "/"))/\(name):\(level)"
    case .operation(let path, let method, let level, _):
      return "op:\(path):\(method.rawValue):\(level)"
    }
  }
  
  var indentLevel: Int {
    switch self {
    case .group(_, let level, _), .operation(_, _, let level, _):
      return level
    }
  }
}

/// View model that provides a flattened list of all paths and groups
@Observable
class PathsListViewModel {
  private(set) var items: [PathListItem] = []
  private var collapsedGroups: Set<String> = []
  
  func update(from document: OpenAPI.Document) {
    var result: [PathListItem] = []
    
    // Add ungrouped paths at the root level
    for path in document.ungroupedPathItems {
      if let referenceable = document.paths?[path] {
        // Add all operations for this path
        addOperations(for: path, referenceable: referenceable, to: &result, level: 0, groupPath: [], document: document)
      }
    }
    
    // Add grouped paths recursively
    for (groupName, group) in document.groupedPathItems {
      addGroup(name: groupName, group: group, to: &result, level: 0, groupPath: [], document: document)
    }
    
    self.items = result
  }
  
  private func addOperations(for path: String, referenceable: OpenAPI.Referenceable<OpenAPI.PathItem>, to result: inout [PathListItem], level: Int, groupPath: [String], document: OpenAPI.Document) {
    // Resolve the reference to get the actual PathItem
    guard let pathItem = referenceable.resolve(in: document) else { return }
    // Add operations in a consistent order
    if pathItem.get != nil {
      result.append(.operation(path: path, method: .get, level: level, groupPath: groupPath))
    }
    if pathItem.post != nil {
      result.append(.operation(path: path, method: .post, level: level, groupPath: groupPath))
    }
    if pathItem.put != nil {
      result.append(.operation(path: path, method: .put, level: level, groupPath: groupPath))
    }
    if pathItem.delete != nil {
      result.append(.operation(path: path, method: .delete, level: level, groupPath: groupPath))
    }
    if pathItem.patch != nil {
      result.append(.operation(path: path, method: .patch, level: level, groupPath: groupPath))
    }
    if pathItem.head != nil {
      result.append(.operation(path: path, method: .head, level: level, groupPath: groupPath))
    }
    if pathItem.options != nil {
      result.append(.operation(path: path, method: .options, level: level, groupPath: groupPath))
    }
    if pathItem.trace != nil {
      result.append(.operation(path: path, method: .trace, level: level, groupPath: groupPath))
    }
  }
  
  private func addGroup(name: String, group: OpenAPI.PathGroup, to result: inout [PathListItem], level: Int, groupPath: [String], document: OpenAPI.Document) {
    let currentGroupPath = groupPath + [name]
    let groupId = currentGroupPath.joined(separator: "/")
    
    // Add the group header
    result.append(.group(name: name, level: level, groupPath: groupPath))
    
    // Only add children if the group is expanded
    if !collapsedGroups.contains(groupId) {
      // Add items in this group
      for filePath in group.items.keys {
        if let path = document.path(for: filePath),
           let referenceable = document.paths?[path] {
          addOperations(for: path, referenceable: referenceable, to: &result, level: level + 1, groupPath: currentGroupPath, document: document)
        }
      }
      
      // Add nested groups
      for (nestedGroupName, nestedGroup) in group.groups {
        addGroup(name: nestedGroupName, group: nestedGroup, to: &result, level: level + 1, groupPath: currentGroupPath, document: document)
      }
    }
  }
  
  func toggleGroup(_ groupPath: [String], name: String) {
    let groupId = (groupPath + [name]).joined(separator: "/")
    if collapsedGroups.contains(groupId) {
      collapsedGroups.remove(groupId)
    } else {
      collapsedGroups.insert(groupId)
    }
  }
  
  func isGroupCollapsed(_ groupPath: [String], name: String) -> Bool {
    let groupId = (groupPath + [name]).joined(separator: "/")
    return collapsedGroups.contains(groupId)
  }
  
  /// Calculates the target index in the document for a move operation
  func calculateMoveIndex(from sourceIndex: Int, to destinationIndex: Int) -> (groupPath: [String], index: Int)? {
    guard sourceIndex >= 0 && sourceIndex < items.count else { return nil }
    
    // If moving to the beginning
    if destinationIndex == 0 {
      return ([], 0)
    }
    
    // Look at the item just before the destination
    let adjustedDestination = min(destinationIndex, items.count)
    if adjustedDestination > 0 {
      let previousItem = items[adjustedDestination - 1]
      
      switch previousItem {
      case .group(let name, _, let groupPath):
        // Inserting after a group header means adding as first item IN that group
        let targetGroupPath = groupPath + [name]
        return (targetGroupPath, 0)
        
      case .operation(_, _, _, let groupPath):
        // If we're at the end or the next item is in a different group,
        // add to the end of the current group
        if adjustedDestination >= items.count {
          // Adding at the very end
          var indexInGroup = 0
          for item in items {
            if case .operation(_, _, _, let itemGroupPath) = item,
               itemGroupPath == groupPath {
              indexInGroup += 1
            }
          }
          return (groupPath, indexInGroup)
        } else {
          // Check what comes next to determine insertion point
          let nextItem = items[adjustedDestination]
          switch nextItem {
          case .group:
            // Next is a group, so we're adding at the end of current group
            var indexInGroup = 0
            for i in 0..<adjustedDestination {
              if case .operation(_, _, _, let itemGroupPath) = items[i],
                 itemGroupPath == groupPath {
                indexInGroup += 1
              }
            }
            return (groupPath, indexInGroup)
            
          case .operation(_, _, _, let nextGroupPath):
            if nextGroupPath == groupPath {
              // Same group, find position within group
              var indexInGroup = 0
              for i in 0..<adjustedDestination {
                if case .operation(_, _, _, let itemGroupPath) = items[i],
                   itemGroupPath == groupPath {
                  indexInGroup += 1
                }
              }
              return (groupPath, indexInGroup)
            } else {
              // Different group, add at end of current group
              var indexInGroup = 0
              for i in 0..<adjustedDestination {
                if case .operation(_, _, _, let itemGroupPath) = items[i],
                   itemGroupPath == groupPath {
                  indexInGroup += 1
                }
              }
              return (groupPath, indexInGroup)
            }
          }
        }
      }
    }
    
    return ([], 0)
  }
}