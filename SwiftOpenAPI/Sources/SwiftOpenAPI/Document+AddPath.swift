//
//  Document+AddPath.swift
//  SwiftOpenAPI
//
//  Created by Ben Davis on 13/08/2025.
//

import Foundation
import Collections

public extension OpenAPI.Document {
  mutating func addPath(_ path: String,
                        toGroup pathComponents: [String] = [],
                        pathItem: OpenAPI.PathItem = placeholderPathItem()) {
    // Ensure componentFiles exists
    if componentFiles == nil {
      componentFiles = OpenAPI.Components()
    }
    
    // Ensure pathItems exists
    if componentFiles?.pathItems == nil {
      componentFiles?.pathItems = OpenAPI.PathGroup()
    }
    
    // Clean the path (remove leading slash if present)
    let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
    
    // Build the file path components
    let fileName = "\(cleanPath).yaml"
    let fullPathComponents = ["paths"] + pathComponents + [fileName]
    
    // Add the path item to the correct nested group
    let filePath = fullPathComponents.joined(separator: "/")
    componentFiles!.pathItems![filePath] = .value(pathItem)

    // Also add a reference to it in document.paths
    var paths = self.paths ?? [:]
    paths["/\(cleanPath)"] = .reference("./\(filePath)")
    self.paths = paths
  }

  func generateUniquePathName(in pathComponents: [String]) -> String {
    let randomNoun = getRandomNoun()
    let basePath = "/\(randomNoun)"

    // Get all existing paths in the specified group
    let existingPathsInGroup = getAllPathsInGroup(pathComponents: pathComponents)
    
    if !existingPathsInGroup.contains(basePath) {
      return basePath
    }
    
    var counter = 1
    while existingPathsInGroup.contains("\(basePath)\(counter)") {
      counter += 1
    }
    return "\(basePath)\(counter)"
  }

  static func placeholderPathItem() -> OpenAPI.PathItem {
    let operation = OpenAPI.Operation(
      summary: "New operation",
      description: "Description for the new operation"
    )
    return OpenAPI.PathItem(get: operation)
  }

  private func getAllPathsInGroup(pathComponents: [String]) -> Set<String> {
    guard let rootGroup = componentFiles?.pathItems,
          let group = rootGroup.getGroup(pathComponents) else {
      return []
    }

    return Set(group.items.keys.compactMap { path(for: $0) })
  }

  private func getRandomNoun() -> String {
    let commonNouns = [
      "panda", "elephant", "tiger", "dolphin", "penguin", "koala", "giraffe",
      "butterfly", "rabbit", "falcon", "turtle", "fox", "wolf", "bear", "deer",
      "mountain", "river", "forest", "ocean", "desert", "valley", "lake",
      "cloud", "rainbow", "thunder", "lightning", "sunrise", "sunset",
      "apple", "banana", "orange", "grape", "cherry", "peach", "lemon",
      "book", "pencil", "paper", "table", "chair", "window", "door",
      "music", "song", "dance", "art", "story", "poem", "dream"
    ]
    
    return commonNouns.randomElement() ?? "item"
  }
}
