//
//  PathItemSection.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 30/07/2025.
//

import SwiftUI
import SwiftOpenAPI

struct PathItemSection: View {
  let path: String
  let pathItem: OpenAPI.PathItem
  let indentLevel: Int
  let onDeleteOperation: (String, HTTPMethod) -> Void
  @Binding var document: OpenAPI.Document
  var groupPath: [String] = []
  var indexInGroup: Int = 0
  var includeRootDropIndicator: Bool = false

  @State private var isDropTargeted: Bool = false

  private var lastOperation: HTTPMethod? {
    // Check operations in reverse order to find the last one present
    if pathItem.trace != nil { return .trace }
    if pathItem.options != nil { return .options }
    if pathItem.head != nil { return .head }
    if pathItem.patch != nil { return .patch }
    if pathItem.delete != nil { return .delete }
    if pathItem.put != nil { return .put }
    if pathItem.post != nil { return .post }
    if pathItem.get != nil { return .get }
    return nil
  }
  
  var body: some View {
    if let get = pathItem.get {
      OperationRow(method: .get,
                   path: path,
                   operation: get,
                   indentLevel: indentLevel,
                   onDelete: onDeleteOperation,
                   includeDropIndicator: lastOperation == .get && isDropTargeted,
                   includeRootDropDestination: includeRootDropIndicator)
        .operationItemDraggable(path, operation: .get)
        .padding(.bottom, lastOperation == .get ? 4 : 0)
        .dropDestination(for: OperationDragItem.self) { items, location in
          handleDrop(items: items, atIndex: indexInGroup + 1)
        } isTargeted: { isTargeted in
          isDropTargeted = isTargeted
        }
    }
    if let post = pathItem.post {
      OperationRow(method: .post,
                   path: path,
                   operation: post,
                   indentLevel: indentLevel,
                   onDelete: onDeleteOperation,
                   includeDropIndicator: lastOperation == .post && isDropTargeted)
        .operationItemDraggable(path, operation: .post)
        .padding(.bottom, lastOperation == .post ? 4 : 0)
        .dropDestination(for: OperationDragItem.self) { items, location in
          handleDrop(items: items, atIndex: indexInGroup + 1)
        } isTargeted: { isTargeted in
          isDropTargeted = isTargeted
        }
    }
    if let put = pathItem.put {
      OperationRow(method: .put,
                   path: path,
                   operation: put,
                   indentLevel: indentLevel,
                   onDelete: onDeleteOperation,
                   includeDropIndicator: lastOperation == .put && isDropTargeted)
        .operationItemDraggable(path, operation: .put)
        .padding(.bottom, lastOperation == .put ? 4 : 0)
        .dropDestination(for: OperationDragItem.self) { items, location in
          handleDrop(items: items, atIndex: indexInGroup + 1)
        } isTargeted: { isTargeted in
          isDropTargeted = isTargeted
        }
    }
    if let delete = pathItem.delete {
      OperationRow(method: .delete,
                   path: path,
                   operation: delete,
                   indentLevel: indentLevel,
                   onDelete: onDeleteOperation,
                   includeDropIndicator: lastOperation == .delete && isDropTargeted)
        .operationItemDraggable(path, operation: .delete)
        .padding(.bottom, lastOperation == .delete ? 4 : 0)
        .dropDestination(for: OperationDragItem.self) { items, location in
          handleDrop(items: items, atIndex: indexInGroup + 1)
        } isTargeted: { isTargeted in
          isDropTargeted = isTargeted
        }
    }
    if let patch = pathItem.patch {
      OperationRow(method: .patch,
                   path: path,
                   operation: patch,
                   indentLevel: indentLevel,
                   onDelete: onDeleteOperation,
                   includeDropIndicator: lastOperation == .patch && isDropTargeted)
        .operationItemDraggable(path, operation: .patch)
        .padding(.bottom, lastOperation == .patch ? 4 : 0)
        .dropDestination(for: OperationDragItem.self) { items, location in
          handleDrop(items: items, atIndex: indexInGroup + 1)
        } isTargeted: { isTargeted in
          isDropTargeted = isTargeted
        }
    }
    if let head = pathItem.head {
      OperationRow(method: .head,
                   path: path,
                   operation: head,
                   indentLevel: indentLevel,
                   onDelete: onDeleteOperation,
                   includeDropIndicator: lastOperation == .head && isDropTargeted)
        .operationItemDraggable(path, operation: .head)
        .padding(.bottom, lastOperation == .head ? 4 : 0)
        .dropDestination(for: OperationDragItem.self) { items, location in
          handleDrop(items: items, atIndex: indexInGroup + 1)
        } isTargeted: { isTargeted in
          isDropTargeted = isTargeted
        }
    }
    if let options = pathItem.options {
      OperationRow(method: .options,
                   path: path,
                   operation: options,
                   indentLevel: indentLevel,
                   onDelete: onDeleteOperation,
                   includeDropIndicator: lastOperation == .options && isDropTargeted)
        .operationItemDraggable(path, operation: .options)
        .padding(.bottom, lastOperation == .options ? 4 : 0)
        .dropDestination(for: OperationDragItem.self) { items, location in
          handleDrop(items: items, atIndex: indexInGroup + 1)
        } isTargeted: { isTargeted in
          isDropTargeted = isTargeted
        }
    }
    if let trace = pathItem.trace {
      OperationRow(method: .trace,
                   path: path,
                   operation: trace,
                   indentLevel: indentLevel,
                   onDelete: onDeleteOperation,
                   includeDropIndicator: lastOperation == .trace && isDropTargeted)
        .operationItemDraggable(path, operation: .trace)
        .padding(.bottom, lastOperation == .trace ? 4 : 0)
        .dropDestination(for: OperationDragItem.self) { items, location in
          handleDrop(items: items, atIndex: indexInGroup + 1)
        } isTargeted: { isTargeted in
          isDropTargeted = isTargeted
        }
    }
  }
  
  private func handleDrop(items: [OperationDragItem], atIndex index: Int) -> Bool {
    guard let draggedItem = items.first else { return false }
    
    // Move the path to this group at the specified index
    return document.movePathToGroup(draggedItem.path, groupPath: groupPath, index: index)
  }
}

private extension View {
  func operationItemDraggable(_ path: String, operation: HTTPMethod) -> some View {
    self.draggable(OperationDragItem(path: path, operation: operation)) {
      ZStack(alignment: .leading) {
        self
        RoundedRectangle(cornerRadius: 5).foregroundStyle(Color.green)
      }
    }
  }
}
