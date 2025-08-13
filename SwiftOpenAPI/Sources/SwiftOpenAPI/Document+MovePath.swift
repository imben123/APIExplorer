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
  /// - Returns: True if the move was successful, false otherwise
  @discardableResult
  mutating func movePathToGroup(_ path: String, groupPath: [String], index: Int = 0) -> Bool {
    // Ensure the path exists
    guard let paths = paths,
          let pathItemRef = paths[path] else {
      return false
    }
    
    // Get the path item
    guard let pathItem = pathItemRef.resolve(in: self) else {
      return false
    }
    
    // Check if it's already a reference
    if case .reference(let existingRef) = pathItemRef {
      // Move the existing component file to the new location
      return moveComponentFile(from: existingRef, path: path, to: groupPath, index: index)
    } else {
      // It's an inline value, we need to create a new component file
      createComponentFileInGroup(path: path, pathItem: pathItem, groupPath: groupPath, index: index)
      return true
    }
  }
  
  /// Moves an existing component file to a new group location
  private mutating func moveComponentFile(from ref: String, path: String, to groupPath: [String], index: Int) -> Bool {
    // Normalize the reference
    let normalizedRef = ref.hasPrefix("./") ? String(ref.dropFirst(2)) : ref
    
    // Get the path item from the old location
    guard let pathItem = componentFiles?.pathItems?[normalizedRef]?.value else {
      return false
    }
    
    // Remove from old location
    componentFiles?.pathItems?[normalizedRef] = nil
    
    // Create new file path
    let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
    let fileName = "\(cleanPath.replacingOccurrences(of: "/", with: "_")).yaml"
    let newFilePath = (["paths"] + groupPath + [fileName]).joined(separator: "/")
    
    // Ensure the component files structure exists
    if componentFiles == nil {
      componentFiles = OpenAPI.Components()
    }
    if componentFiles?.pathItems == nil {
      componentFiles?.pathItems = OpenAPI.PathGroup()
    }
    
    // Add to new location
    componentFiles?.pathItems?[newFilePath] = .value(pathItem)
    
    // If a specific index was provided, move the item to that position within its group
    moveItemToIndexInGroup(filePath: newFilePath, toIndex: index, groupPath: groupPath)

    // Update the reference in paths
    var updatedPaths = paths ?? [:]
    updatedPaths[path] = .reference("./\(newFilePath)")
    self.paths = updatedPaths
    
    return true
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
