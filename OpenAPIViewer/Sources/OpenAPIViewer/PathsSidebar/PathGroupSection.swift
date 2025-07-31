//
//  PathGroupSection.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 30/07/2025.
//

import SwiftUI
import SwiftOpenAPI

struct PathGroupSection: View {
  let group: OpenAPI.Document.PathGroup
  let isExpanded: Bool
  let onToggle: () -> Void
  
  var body: some View {
    Group {
      if let subdirectory = group.subdirectory {
        // Directory header
        Button(action: onToggle) {
          HStack(spacing: 6) {
            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
              .font(.system(size: 10, weight: .medium))
              .foregroundColor(.secondary)
              .frame(width: 12)
            Text(subdirectory)
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
          ForEach(group.paths, id: \.0) { path, pathItem in
            PathItemSection(path: path, pathItem: pathItem, isIndented: true)
          }
        }
      } else {
        // Ungrouped paths (no subdirectory)
        ForEach(group.paths, id: \.0) { path, pathItem in
          PathItemSection(path: path, pathItem: pathItem, isIndented: false)
        }
      }
    }
  }
}
