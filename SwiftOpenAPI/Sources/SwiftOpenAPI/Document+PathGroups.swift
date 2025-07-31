//
//  Document+PathGroups.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 30/07/2025.
//

import Foundation

public extension OpenAPI.Document {
  struct PathGroup {
    public let subdirectory: String?
    public let paths: [(String, OpenAPI.PathItem)]
    
    public init(subdirectory: String?, paths: [(String, OpenAPI.PathItem)]) {
      self.subdirectory = subdirectory
      self.paths = paths
    }
  }
  
  var groupedPaths: [PathGroup] {
    guard let paths = self.paths else { return [] }
    
    var groups: [String?: [(String, OpenAPI.PathItem)]] = [:]
    
    for (path, referenceablePathItem) in paths {
      guard let pathItem = referenceablePathItem.resolve(in: self) else { continue }
      
      let subdirectoryKey = pathItem.subdirectories?.joined(separator: "/")
      
      if groups[subdirectoryKey] == nil {
        groups[subdirectoryKey] = []
      }
      groups[subdirectoryKey]?.append((path, pathItem))
    }
    
    // Sort paths within each group
    for key in groups.keys {
      groups[key]?.sort { $0.0 < $1.0 }
    }
    
    // Create PathGroups, with ungrouped paths first
    var result: [PathGroup] = []
    
    // Add ungrouped paths first (subdirectory = nil)
    if let ungroupedPaths = groups[nil] {
      result.append(PathGroup(subdirectory: nil, paths: ungroupedPaths))
    }
    
    // Add grouped paths, sorted by subdirectory name
    let sortedGroupKeys = groups.keys.compactMap { $0 }.sorted()
    for subdirectory in sortedGroupKeys {
      if let groupPaths = groups[subdirectory] {
        result.append(PathGroup(subdirectory: subdirectory, paths: groupPaths))
      }
    }
    
    return result
  }
}