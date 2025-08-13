//
//  Document+DeleteOperation.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 13/08/2025.
//

import Foundation
import Collections

public extension OpenAPI.Document {
  /// Deletes an operation from a path. If no operations remain, the entire path is deleted.
  /// - Parameters:
  ///   - path: The path string (e.g., "/users")
  ///   - operation: The HTTP operation to delete
  mutating func deleteOperation(path: String, operation: HTTPMethod) {
    guard var paths = paths else { return }
    guard let pathItemRef = paths[path] else { return }
    
    // Resolve the path item safely
    guard var pathItem = pathItemRef.resolve(in: self) else { return }
    
    // Remove the specific operation
    switch operation {
    case .get: pathItem.get = nil
    case .post: pathItem.post = nil
    case .put: pathItem.put = nil
    case .delete: pathItem.delete = nil
    case .patch: pathItem.patch = nil
    case .head: pathItem.head = nil
    case .options: pathItem.options = nil
    case .trace: pathItem.trace = nil
    }
    
    // Check if any operations remain
    let hasRemainingOperations = pathItem.get != nil || pathItem.post != nil ||
      pathItem.put != nil || pathItem.delete != nil ||
      pathItem.patch != nil || pathItem.head != nil ||
      pathItem.options != nil || pathItem.trace != nil
    
    if hasRemainingOperations {
      // Update the path item with the operation removed
      if case .reference = pathItemRef {
        // Update the referenced component file
        var mutableRef = pathItemRef
        mutableRef.update(in: &self, newValue: pathItem)
        paths[path] = mutableRef
      } else {
        // Update the inline path item
        paths[path] = .value(pathItem)
      }
    } else {
      // Remove the entire path if no operations remain
      paths.removeValue(forKey: path)
      
      // Also remove from componentFiles if it exists there
      if case .reference(let ref) = pathItemRef {
        deleteComponentFile(ref)
      }
    }
    
    // Update the document paths
    self.paths = paths.isEmpty ? nil : paths
  }
  
  /// Removes a component file reference from the document
  /// - Parameter ref: The reference string to the component file
  private mutating func deleteComponentFile(_ ref: String) {
    // Normalize the reference path by removing leading "./"
    let normalizedRef = ref.hasPrefix("./") ? String(ref.dropFirst(2)) : ref
    
    // Check if this is a path reference in componentFiles
    if normalizedRef.hasPrefix("paths/") || normalizedRef.hasPrefix("components/pathItems/") {
      // Remove from pathItems in componentFiles
      componentFiles?.pathItems?[normalizedRef] = nil
    }
  }
}