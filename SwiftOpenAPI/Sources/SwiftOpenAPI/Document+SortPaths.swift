//
//  Document+SortPaths.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 13/08/2025.
//

import Foundation
import Collections

typealias Referenceable = OpenAPI.Referenceable
typealias PathItem = OpenAPI.PathItem
typealias PathGroup = OpenAPI.PathGroup

public extension OpenAPI.Document {
  /// Re-sorts document.paths in the specified order:
  /// 1. Value paths (in original order)
  /// 2. Internal reference paths (in original order) 
  /// 3. Top-level external reference paths (from componentFiles.pathItems.items)
  /// 4. Grouped paths (in group order, then nested groups)
  mutating func sortDocumentPaths() {
    guard let paths = paths else { return }
    
    var sortedPaths = OrderedDictionary<String, Referenceable<PathItem>>()
    var processedPaths = Set<String>()
    
    // 1. Value paths (in original order)
    for (pathString, pathItemRef) in paths {
      if case .value = pathItemRef {
        sortedPaths[pathString] = pathItemRef
        processedPaths.insert(pathString)
      }
    }
    
    // 2. Internal reference paths (in original order)
    for (pathString, pathItemRef) in paths {
      if case .reference(let ref) = pathItemRef,
         ref.hasPrefix("#") { // Internal references start with #
        sortedPaths[pathString] = pathItemRef
        processedPaths.insert(pathString)
      }
    }
    
    // 3. Top-level external reference paths
    if let rootPathItems = componentFiles?.pathItems {
      for (filePath, _) in rootPathItems.items {
        if let pathString = path(for: filePath),
           !processedPaths.contains(pathString) {
          sortedPaths[pathString] = paths[pathString]
          processedPaths.insert(pathString)
        }
      }
    }
    
    // 4. Grouped paths (in group order, then nested groups)
    if let rootPathItems = componentFiles?.pathItems {
      addGroupedPaths(
        from: rootPathItems.groups,
        to: &sortedPaths,
        originalPaths: paths,
        processedPaths: &processedPaths
      )
    }
    
    // 5. Add any remaining paths that weren't processed (to preserve all paths)
    for (pathString, pathItemRef) in paths {
      if !processedPaths.contains(pathString) {
        sortedPaths[pathString] = pathItemRef
      }
    }
    
    self.paths = sortedPaths
  }
  
  /// Recursively adds paths from groups in order
  private mutating func addGroupedPaths(
    from groups: OrderedDictionary<String, PathGroup>,
    to sortedPaths: inout OrderedDictionary<String, Referenceable<PathItem>>,
    originalPaths: OrderedDictionary<String, Referenceable<PathItem>>,
    processedPaths: inout Set<String>
  ) {
    for (_, group) in groups {
      // First add items in this group
      for (filePath, _) in group.items {
        if let pathString = path(for: filePath),
           !processedPaths.contains(pathString),
           let pathItemRef = originalPaths[pathString] {
          sortedPaths[pathString] = pathItemRef
          processedPaths.insert(pathString)
        }
      }
      
      // Then recursively add nested groups
      addGroupedPaths(
        from: group.groups,
        to: &sortedPaths,
        originalPaths: originalPaths,
        processedPaths: &processedPaths
      )
    }
  }
}
