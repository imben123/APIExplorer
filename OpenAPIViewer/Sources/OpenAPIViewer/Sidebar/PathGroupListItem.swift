//
//  PathGroupListItem.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 08/08/2025.
//

import Foundation
import SwiftUI
import SwiftOpenAPI
import Collections

struct PathGroupListItem: View {
  let name: String
  let group: OpenAPI.PathGroup
  var pathPrefix: String = ""
  var indentLevel: Int = 0
  @Binding var document: OpenAPI.Document
  let onDeleteOperation: (String, String) -> Void

  @State private var isExpanded: Bool = true
  @Environment(\.editMode) private var isEditMode

  var body: some View {
    // Directory header
    HStack(spacing: 0) {
      Button(action: onToggle) {
        HStack(spacing: 6) {
          Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.secondary)
            .frame(width: 12)
          Text(name)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.primary)
          Spacer()
        }
        .padding(.vertical, 4)
        .padding(.leading, CGFloat(indentLevel * 8))
        .contentShape(Rectangle())
      }
      .buttonStyle(PlainButtonStyle())
      
      if isEditMode {
        Button(action: { addPathToGroup() }) {
          Image(systemName: "plus")
            .font(.system(size: 11))
            .foregroundColor(.secondary)
            .frame(width: 20, height: 20)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.trailing, 8)
      }
    }

    // Directory contents (if expanded)
    if isExpanded {
      ForEach(group.items.keys, id: \.self) { filePath in
        if let path = document.path(for: filePath) {
          PathItemSection(path: path,
                          pathItem: document[filePath: filePath],
                          indentLevel: indentLevel + 1,
                          onDeleteOperation: onDeleteOperation)
        }
      }

      ForEach(group.groups.keys, id: \.self) { groupName in
        PathGroupListItem(name: groupName,
                          group: group.groups[groupName]!,
                          pathPrefix: pathPrefix.isEmpty ? name : "\(pathPrefix)/\(name)",
                          indentLevel: indentLevel + 1,
                          document: $document,
                          onDeleteOperation: onDeleteOperation)
      }
    }
  }

  private func onToggle() {
    isExpanded.toggle()
  }
  
  private func addPathToGroup() {
    let newPath = generateRandomPath()
    let newOperation = OpenAPI.Operation(
      summary: "New operation",
      description: "Description for the new operation"
    )
    let newPathItem = OpenAPI.PathItem(get: newOperation)
    
    // Ensure componentFiles exists
    if document.componentFiles == nil {
      document.componentFiles = OpenAPI.Components()
    }
    
    // Ensure pathItems exists
    if document.componentFiles?.pathItems == nil {
      document.componentFiles?.pathItems = OpenAPI.PathGroup()
    }
    
    // Build the path components for the group hierarchy
    // pathPrefix contains parent groups separated by "/", we need to add current group name
    let pathComponents = pathPrefix.isEmpty ? [name] : pathPrefix.split(separator: "/").map(String.init) + [name]
    
    // Add the file name to the path components
    let fileName = "\(newPath).yaml"
    let fullPathComponents = ["paths"] + pathComponents + [fileName]

    // Use the subscript to add the path item to the correct nested group
    let filePath = fullPathComponents.joined(separator: "/")
    document.componentFiles!.pathItems![filePath] = .value(newPathItem)

    // Also add a reference to it in document.paths
    var paths = document.paths ?? [:]
    paths["/\(newPath)"] = .reference("./\(filePath)")
    document.paths = paths
  }
  
  private func generateRandomPath() -> String {
    let randomNoun = getRandomNoun()
    let basePath = randomNoun
    
    // Check existing paths in the current group
    let existingPathsInGroup = getAllPathsInGroup()
    
    if !existingPathsInGroup.contains(basePath) {
      return basePath
    }
    
    var counter = 1
    while existingPathsInGroup.contains("\(basePath)\(counter)") {
      counter += 1
    }
    return "\(basePath)\(counter)"
  }
  
  private func getAllPathsInGroup() -> Set<String> {
    // Get all existing paths in the current group
    guard let pathItems = document.componentFiles?.pathItems else { return [] }
    
    // Build the path components for the current group
    let pathComponents = pathPrefix.isEmpty ? [name] : pathPrefix.split(separator: "/").map(String.init) + [name]
    
    // Navigate to the current group
    var currentGroup = pathItems
    for component in pathComponents {
      guard let subgroup = currentGroup.groups[component] else { return [] }
      currentGroup = subgroup
    }
    
    return Set(currentGroup.items.keys)
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
