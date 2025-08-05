//
//  PathsList.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 05/08/2025.
//

import SwiftUI
import SwiftOpenAPI

struct PathsList: View {
  let document: OpenAPI.Document
  @Binding var selectedPath: String?
  @Binding var selectedOperation: String?
  @State private var collapsedDirectories: Set<String> = []
  
  typealias PathGroup = OpenAPI.Document.PathGroup
  
  var body: some View {
    List(selection: Binding(
      get: { selectedPath.map { "\($0)|\(selectedOperation ?? "")" } },
      set: { value in
        if let value = value {
          let components = value.split(separator: "|", maxSplits: 1)
          selectedPath = String(components[0])
          selectedOperation = components.count > 1 ? String(components[1]) : nil
        }
      }
    )) {
      let groups = document.groupedPaths
      if groups.isEmpty {
        EmptyPathsView()
      } else {
        ForEach(Array(groups.enumerated()), id: \.offset) { index, group in
          PathGroupSection(
            group: group,
            isExpanded: isGroupExpanded(group: group),
            onToggle: {
              toggleDirectory(group: group)
            }
          )
        }
      }
    }
    .listStyle(.sidebar)
  }
  
  private func isGroupExpanded(group: OpenAPI.Document.PathGroup) -> Bool {
    return group.subdirectory == nil || !collapsedDirectories.contains(group.subdirectory ?? "")
  }
  
  private func toggleDirectory(group: OpenAPI.Document.PathGroup) {
    guard let subdirectory = group.subdirectory else {
      return
    }
    if collapsedDirectories.contains(subdirectory) {
      collapsedDirectories.remove(subdirectory)
    } else {
      collapsedDirectories.insert(subdirectory)
    }
  }
}

#Preview {
  PathsList(
    document: sampleDocument,
    selectedPath: .constant(nil),
    selectedOperation: .constant(nil)
  )
  .frame(width: 300)
}