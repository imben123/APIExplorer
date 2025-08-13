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
  @Binding var selectedOperation: HTTPMethod?
  @State private var collapsedDirectories: Set<String> = []
  @State private var showingDeleteConfirmation = false
  @State private var isRootDropTargeted = false
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
        get: { selectedPath.map { "\($0)|\(selectedOperation?.rawValue ?? "")" } },
        set: { value in
          if let value = value {
            let components = value.split(separator: "|", maxSplits: 1)
            selectedPath = String(components[0])
            selectedOperation = components.count > 1 ? HTTPMethod(rawValue: String(components[1])) : nil
            isListFocused = true
          }
        }
      )) {
        if document.paths?.isEmpty != false {
          EmptyPathsView()
        } else {
          // Root level paths section with drop support
          VStack(spacing: 0) {
            if !document.ungroupedPathItems.isEmpty || isRootDropTargeted {
              VStack(spacing: 0) {
                ForEach(document.ungroupedPathItems, id: \.self) { path in
                  PathItemSection(
                    path: path,
                    pathItem: document[path: path],
                    indentLevel: 0,
                    onDeleteOperation: deleteOperation
                  )
                }
                if isRootDropTargeted && document.ungroupedPathItems.isEmpty {
                  HStack {
                    Text("Drop here to move to root")
                      .font(.caption)
                      .foregroundColor(.secondary)
                    Spacer()
                  }
                  .padding(.horizontal)
                  .padding(.vertical, 8)
                }
              }
              .background(isRootDropTargeted ? Color.blue.opacity(0.1) : Color.clear)
              .dropDestination(for: OperationDragItem.self) { items, location in
                handleRootDrop(items: items)
              } isTargeted: { isTargeted in
                isRootDropTargeted = isTargeted
              }
            }
          }

          ForEach(document.groupedPathItems.keys, id: \.self) { groupName in
            PathGroupListItem(name: groupName,
                              group: document.groupedPathItems[groupName]!,
                              document: $document,
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
    // Generate a unique path name and add it to the group
    let uniquePath = document.generateUniquePathName(in: [])
    document.addPath(uniquePath)

    selectedPath = uniquePath
    selectedOperation = .get
  }
  
  private func handleRootDrop(items: [OperationDragItem]) -> Bool {
    guard let draggedItem = items.first else { return false }

    // Move the path to root (empty group path)
    document.movePathToGroup(draggedItem.path, groupPath: [])

    return true
  }

  private func deleteOperation(path: String, operation: HTTPMethod) {
    // Clear selection first if it matches what we're deleting
    if selectedPath == path && selectedOperation == operation {
      selectedPath = nil
      selectedOperation = nil
    }

    // Dispatch after clearing the operation to ensure SwiftUI doesn't
    // attempt to look up the path after it's been deleted.
    Task { @MainActor in
      // Use the Document's deleteOperation method
      document.deleteOperation(path: path, operation: operation)
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
