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
  /// - Returns: True if the move was successful, false otherwise
  @discardableResult
  mutating func movePathToGroup(_ path: String, groupPath: [String]) -> Bool {
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
      return moveComponentFile(from: existingRef, path: path, to: groupPath)
    } else {
      // It's an inline value, we need to create a new component file
      createComponentFileInGroup(path: path, pathItem: pathItem, groupPath: groupPath)
      return true
    }
  }
  
  /// Moves an existing component file to a new group location
  private mutating func moveComponentFile(from ref: String, path: String, to groupPath: [String]) -> Bool {
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
    
    // Update the reference in paths
    var updatedPaths = paths ?? [:]
    updatedPaths[path] = .reference("./\(newFilePath)")
    self.paths = updatedPaths
    
    return true
  }
  
  /// Creates a new component file in the specified group for an inline path item
  private mutating func createComponentFileInGroup(path: String,
                                                   pathItem: OpenAPI.PathItem,
                                                   groupPath: [String]) {
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
    
    // Update paths to use a reference instead of inline value
    var updatedPaths = paths ?? [:]
    updatedPaths[path] = .reference("./\(filePath)")
    self.paths = updatedPaths
  }
}
