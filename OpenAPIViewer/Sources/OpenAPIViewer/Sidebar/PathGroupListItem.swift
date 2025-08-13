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
    // Build the path components for the group hierarchy
    let pathComponents = pathPrefix.isEmpty ? [name] : pathPrefix.split(separator: "/").map(String.init) + [name]
    
    // Generate a unique path name and add it to the group
    let uniquePath = document.generateUniquePathName(in: pathComponents)
    document.addPath(uniquePath, toGroup: pathComponents)
  }
}
