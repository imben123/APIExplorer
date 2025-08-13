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
  let onDeleteOperation: (String, HTTPMethod) -> Void

  @State private var isExpanded: Bool = true
  @State private var isDropTargeted: Bool = false
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
    .background(isDropTargeted ? Color.blue.opacity(0.1) : Color.clear)
    .dropDestination(for: OperationDragItem.self) { items, location in
      handleDrop(items: items)
    } isTargeted: { isTargeted in
      isDropTargeted = isTargeted
    }

    // Directory contents (if expanded)
    if isExpanded {
      ForEach(Array(group.items.keys.enumerated()), id: \.element) { index, filePath in
        if let path = document.path(for: filePath) {
          // Build group path for this nested group
          let currentGroupPath = pathPrefix.isEmpty ? [name] : pathPrefix.split(separator: "/").map(String.init) + [name]
          
          PathItemSection(path: path,
                          pathItem: document[filePath: filePath],
                          indentLevel: indentLevel + 1,
                          onDeleteOperation: onDeleteOperation,
                          document: $document,
                          groupPath: currentGroupPath,
                          indexInGroup: index)
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
    // Build the path components for the group hierarchy
    let pathComponents = pathPrefix.isEmpty ? [name] : pathPrefix.split(separator: "/").map(String.init) + [name]
    
    // Generate a unique path name and add it to the group
    let uniquePath = document.generateUniquePathName(in: pathComponents)
    document.addPath(uniquePath, toGroup: pathComponents)
  }
  
  private func handleDrop(items: [OperationDragItem]) -> Bool {
    guard let draggedItem = items.first else { return false }
    
    // Build the path components for the target group
    let targetGroupPath = pathPrefix.isEmpty ? [name] : pathPrefix.split(separator: "/").map(String.init) + [name]
    
    // Move the path to this group
    document.movePathToGroup(draggedItem.path, groupPath: targetGroupPath)
    
    return true
  }
}
