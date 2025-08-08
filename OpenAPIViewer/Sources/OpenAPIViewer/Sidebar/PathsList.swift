//
//  PathsList.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 05/08/2025.
//

import SwiftUI
import SwiftOpenAPI
import Collections
import Foundation

struct PathsList: View {
  @Binding var document: OpenAPI.Document
  @Binding var selectedPath: String?
  @Binding var selectedOperation: String?
  @State private var collapsedDirectories: Set<String> = []
  @State private var showingDeleteConfirmation = false
  @FocusState private var isListFocused: Bool
  @Environment(\.editMode) private var isEditMode
  
  var body: some View {
    VStack(spacing: 0) {
      if isEditMode {
        HStack {
          Button {
            addNewPath()
          } label: {
            HStack {
              Image(systemName: "plus")
              Text("Add Path")
            }
          }
          .buttonStyle(.bordered)
          Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        
        Divider()
      }
      
      List(selection: Binding(
        get: { selectedPath.map { "\($0)|\(selectedOperation ?? "")" } },
        set: { value in
          if let value = value {
            let components = value.split(separator: "|", maxSplits: 1)
            selectedPath = String(components[0])
            selectedOperation = components.count > 1 ? String(components[1]) : nil
            isListFocused = true
          }
        }
      )) {
        if document.paths?.isEmpty != false {
          EmptyPathsView()
        } else {
          ForEach(document.ungroupedPathItems, id: \.self) { path in
            PathItemSection(
              path: path,
              pathItem: document[path: path],
              isIndented: false,
              onDeleteOperation: deleteOperation
            )
          }

          ForEach(document.groupedPathItems.keys, id: \.self) { groupName in
            PathGroupListItem(name: groupName,
                              group: document.groupedPathItems[groupName]!,
                              document: document,
                              onDeleteOperation: deleteOperation)
          }
        }
      }
      .onDeleteCommand {
        if selectedPath != nil && selectedOperation != nil {
          showingDeleteConfirmation = true
        }
      }
      .listStyle(.sidebar)
      .padding(.top, 8)
      .onAppear {
        isListFocused = true
      }
      .alert("Delete Operation", isPresented: $showingDeleteConfirmation) {
        Button("Cancel", role: .cancel) { }
        Button("Delete", role: .destructive) {
          if let selectedPath = selectedPath, let selectedOperation = selectedOperation {
            deleteOperation(path: selectedPath, operation: selectedOperation)
          }
        }
      } message: {
        Text("Are you sure you want to delete this operation? This action cannot be undone.")
      }
    }
  }
  
  private func addNewPath() {
    let newPath = generateRandomPath()
    let newOperation = OpenAPI.Operation(
      summary: "New operation",
      description: "Description for the new operation"
    )
    let newPathItem = OpenAPI.PathItem(get: newOperation)
    
    var paths = document.paths ?? [:]
    paths[newPath] = .value(newPathItem)
    document.paths = paths
    
    selectedPath = newPath
    selectedOperation = "get"
  }
  
  private func generateRandomPath() -> String {
    let randomNoun = getRandomNoun()
    let basePath = "/\(randomNoun)"
    
    let existingPaths = document.paths?.keys ?? []
    if !existingPaths.contains(basePath) {
      return basePath
    }
    
    var counter = 1
    while existingPaths.contains("\(basePath)\(counter)") {
      counter += 1
    }
    return "\(basePath)\(counter)"
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
  
  private func deleteOperation(path: String, operation: String) {
    guard var paths = document.paths else { return }
    guard let pathItemRef = paths[path] else { return }
    
    // Clear selection first if it matches what we're deleting
    if selectedPath == path && selectedOperation == operation {
      selectedPath = nil
      selectedOperation = nil
    }

    // Dispatch after clearing the operation to ensure SwiftUI doesn't
    // attempt to look up the path after it's been deleted.
    Task { @MainActor in
      // Resolve the path item safely
      guard var pathItem = pathItemRef.resolve(in: document) else { return }

      // Remove the specific operation
      switch operation.lowercased() {
      case "get": pathItem.get = nil
      case "post": pathItem.post = nil
      case "put": pathItem.put = nil
      case "delete": pathItem.delete = nil
      case "patch": pathItem.patch = nil
      case "head": pathItem.head = nil
      case "options": pathItem.options = nil
      case "trace": pathItem.trace = nil
      default: return
      }

      // Check if any operations remain
      let hasRemainingOperations = pathItem.get != nil || pathItem.post != nil ||
      pathItem.put != nil || pathItem.delete != nil ||
      pathItem.patch != nil || pathItem.head != nil ||
      pathItem.options != nil || pathItem.trace != nil

      if hasRemainingOperations {
        // Update the path item with the operation removed
        paths[path] = .value(pathItem)
      } else {
        // Remove the entire path if no operations remain
        paths.removeValue(forKey: path)
      }

      // Update the document
      document.paths = paths.isEmpty ? nil : paths
    }
  }
}

#Preview {
  PathsList(
    document: .constant(sampleDocument),
    selectedPath: .constant(nil),
    selectedOperation: .constant(nil)
  )
  .frame(width: 300)
}
