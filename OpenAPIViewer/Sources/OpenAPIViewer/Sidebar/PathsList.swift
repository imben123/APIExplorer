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
  @State private var viewModel = PathsListViewModel()
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
          ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
            pathListItemView(for: item, at: index)
          }
          .onMove { source, destination in
            handleMove(from: source, to: destination)
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
        viewModel.update(from: document)
      }
      .onChange(of: document) { _, newDocument in
        viewModel.update(from: newDocument)
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
  
  @ViewBuilder
  private func pathListItemView(for item: PathListItem, at index: Int) -> some View {
    switch item {
    case .group(let name, let level, let groupPath):
      HStack(spacing: 0) {
        Button(action: {
          viewModel.toggleGroup(groupPath, name: name)
          viewModel.update(from: document)
        }) {
          HStack(spacing: 6) {
            Image(systemName: viewModel.isGroupCollapsed(groupPath, name: name) ? "chevron.right" : "chevron.down")
              .font(.system(size: 10, weight: .medium))
              .foregroundColor(.secondary)
              .frame(width: 12)
            Text(name)
              .font(.system(size: 13, weight: .medium))
              .foregroundColor(.primary)
            Spacer()
          }
          .padding(.vertical, 4)
          .padding(.leading, CGFloat(level * 16))
          .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        
        if isEditMode {
          Button(action: { 
            addPathToGroup(groupPath + [name]) 
          }) {
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
      
    case .operation(let path, let method, let level, _):
      if let referenceable = document.paths?[path],
         let pathItem = referenceable.resolve(in: document),
         let operation = getOperation(from: pathItem, method: method) {
        OperationRow(
          method: method,
          path: path,
          operation: operation,
          indentLevel: level,
          onDelete: deleteOperation
        )
      }
    }
  }
  
  private func getOperation(from pathItem: OpenAPI.PathItem, method: HTTPMethod) -> OpenAPI.Operation? {
    switch method {
    case .get: return pathItem.get
    case .post: return pathItem.post
    case .put: return pathItem.put
    case .delete: return pathItem.delete
    case .patch: return pathItem.patch
    case .head: return pathItem.head
    case .options: return pathItem.options
    case .trace: return pathItem.trace
    }
  }
  
  private func handleMove(from source: IndexSet, to destination: Int) {
    guard let sourceIndex = source.first else { return }
    
    if let (groupPath, index) = viewModel.calculateMoveIndex(from: sourceIndex, to: destination) {
      if case .operation(let path, _, _, _) = viewModel.items[sourceIndex] {
        document.movePathToGroup(path, groupPath: groupPath, index: index)
        viewModel.update(from: document)
      }
    }
  }
  
  private func addNewPath() {
    // Generate a unique path name and add it to the group
    let uniquePath = document.generateUniquePathName(in: [])
    document.addPath(uniquePath)

    selectedPath = uniquePath
    selectedOperation = .get
    viewModel.update(from: document)
  }
  
  private func addPathToGroup(_ groupPath: [String]) {
    // Generate a unique path name and add it to the group
    let uniquePath = document.generateUniquePathName(in: groupPath)
    document.addPath(uniquePath, toGroup: groupPath)
    viewModel.update(from: document)
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
      viewModel.update(from: document)
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
