//
//  Document+MovePath.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 13/08/2025.
//

import Foundation
import Collections

public extension OpenAPI.Document {
  /// Moves a path to a different group in the document structure.
  /// - Parameters:
  ///   - path: The path string to move (e.g., "/users")
  ///   - groupPath: The target group path components (e.g., ["v1", "resources"] for paths/v1/resources/)
  ///   - index: The index within the target group to place the path (defaults to end if not specified)
  mutating func movePathToGroup(_ path: String, groupPath: [String], index: Int = 0) {
    _movePathToGroup(path, groupPath: groupPath, index: index)
    sortDocumentPaths()
  }

  private mutating func _movePathToGroup(_ path: String, groupPath: [String], index: Int) {
    // Ensure the path exists
    guard let paths = paths,
          let pathItemRef = paths[path] else {
      return
    }

    switch pathItemRef {
    case .reference(let existingRef):
      moveComponent(from: existingRef, path: path, to: groupPath, index: index)
    case .value(let pathItem):
      createComponentFileInGroup(path: path, pathItem: pathItem, groupPath: groupPath, index: index)
    }
  }

  /// Moves an existing component file to a new group location
  private mutating func moveComponent(from ref: String,
                                      path: String,
                                      to groupPath: [String],
                                      index: Int) {
    let existingGroupPath = ref.convertReferenceToPathItemGroups()
    var adjustedIndex = index
    if existingGroupPath == groupPath {
      // In same group
      let filePath = paths![path]!.ref!.removingPrefix("./")
      let currentIndex = componentFiles?.pathItems?[group: groupPath]?.items.index(forKey: filePath) ?? Int.max
      if currentIndex < index {
        adjustedIndex -= 1
      }
    } else {
      // Move to correct group
      guard let pathItem = removePathItem(from: ref) else {
        return
      }
      addPath(path, toGroup: groupPath, pathItem: pathItem)
    }
    guard let filePath = paths?[path]?.ref else {
      return
    }
    if groupPath.isEmpty {
      var rootGroup = componentFiles!.pathItems!
      rootGroup.moveItem(filePath: filePath, toIndex: adjustedIndex)
      componentFiles!.pathItems = rootGroup
    } else {
      componentFiles!
        .pathItems![group: groupPath]!
        .moveItem(filePath: filePath, toIndex: adjustedIndex)
    }
  }

  mutating func removePathItem(from ref: String) -> OpenAPI.PathItem? {
    if ref.hasPrefix("#/components/") {
      var pathComponents = ref.convertReferenceToPathItemGroups()
      let key = pathComponents.removeLast()
      guard let ref = components?.pathItems?.removeItem(in: pathComponents, key: key) else {
        return nil
      }
      switch ref {
      case .reference(let newReference):
        return removePathItem(from: newReference)
      case .value(let pathItem):
        return pathItem
      }
    } else {
      let filePath = ref.removingPrefix("./")
      let pathComponents = ref.convertReferenceToPathItemGroups()
      return componentFiles?.pathItems?.removeItem(in: pathComponents, key: filePath)?.value
    }
  }

  /// Creates a new component file in the specified group for an inline path item
  private mutating func createComponentFileInGroup(path: String,
                                                   pathItem: OpenAPI.PathItem,
                                                   groupPath: [String],
                                                   index: Int) {
    // Create file path
    let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
    let fileName = "\(cleanPath.replacingOccurrences(of: "/", with: "_")).yaml"
    let filePath = (["paths"] + groupPath + [fileName]).joined(separator: "/")
    
    // Ensure the component files structure exists
    if componentFiles == nil {
      componentFiles = OpenAPI.Components()
    }
    if componentFiles?.pathItems == nil {
      componentFiles?.pathItems = OpenAPI.PathGroup()
    }
    
    // Add the path item to component files
    componentFiles?.pathItems?[filePath] = .value(pathItem)
    
    // If a specific index was provided, move the item to that position within its group
    moveItemToIndexInGroup(filePath: filePath, toIndex: index, groupPath: groupPath)
    
    // Update paths to use a reference instead of inline value
    var updatedPaths = paths ?? [:]
    updatedPaths[path] = .reference("./\(filePath)")
    self.paths = updatedPaths
  }
  
  /// Moves an item to a specific index within its group
  private mutating func moveItemToIndexInGroup(filePath: String, toIndex: Int, groupPath: [String]) {
    guard var pathItems = componentFiles?.pathItems else { return }
    
    // Find the target group and move the item
    if groupPath.isEmpty {
      // Item is in root group
      pathItems.moveItem(filePath: filePath, toIndex: toIndex)
    } else {
      // Navigate to the nested group
      var currentGroup: OpenAPI.PathGroup? = pathItems
      for groupName in groupPath {
        currentGroup = currentGroup?.groups[groupName]
      }
      
      if var targetGroup = currentGroup {
        targetGroup.moveItem(filePath: filePath, toIndex: toIndex)
        // Update the nested group back in the hierarchy
        updateNestedGroup(in: &pathItems, groupPath: groupPath, updatedGroup: targetGroup)
      }
    }
    
    componentFiles?.pathItems = pathItems
  }
  
  /// Helper to update a nested group in the hierarchy
  private func updateNestedGroup(in rootGroup: inout OpenAPI.PathGroup, groupPath: [String], updatedGroup: OpenAPI.PathGroup) {
    if groupPath.isEmpty {
      rootGroup = updatedGroup
      return
    }
    
    if groupPath.count == 1 {
      rootGroup.groups[groupPath[0]] = updatedGroup
      return
    }
    
    let firstGroup = groupPath[0]
    let remainingPath = Array(groupPath.dropFirst())
    
    if var subGroup = rootGroup.groups[firstGroup] {
      updateNestedGroup(in: &subGroup, groupPath: remainingPath, updatedGroup: updatedGroup)
      rootGroup.groups[firstGroup] = subGroup
    }
  }
}
