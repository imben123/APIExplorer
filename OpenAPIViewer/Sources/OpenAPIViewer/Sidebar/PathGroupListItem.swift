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
  let document: OpenAPI.Document
  let onDeleteOperation: (String, String) -> Void

  @State private var isExpanded: Bool = true

  var body: some View {
    // Directory header
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
      .contentShape(Rectangle())
    }
    .buttonStyle(PlainButtonStyle())

    // Directory contents (if expanded)
    if isExpanded {
      ForEach(group.items.keys, id: \.self) { path in
        PathItemSection(path: path,
                        pathItem: document[path: path],
                        isIndented: true,
                        onDeleteOperation: onDeleteOperation)
      }

      ForEach(group.groups.keys, id: \.self) { name in
        PathGroupListItem(name: name,
                          group: group.groups[name]!,
                          document: document,
                          onDeleteOperation: onDeleteOperation)
      }
    }
  }

  private func onToggle() {
    isExpanded.toggle()
  }
}
