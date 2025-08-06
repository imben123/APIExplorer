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
  let isIndented: Bool
  let onDeleteOperation: (String, String) -> Void
  
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
    Group {
      if let get = pathItem.get {
        OperationRow(method: .get, path: path, operation: get, isIndented: isIndented, onDelete: onDeleteOperation)
          .padding(.bottom, lastOperation == .get ? 4 : 0)
      }
      if let post = pathItem.post {
        OperationRow(method: .post, path: path, operation: post, isIndented: isIndented, onDelete: onDeleteOperation)
          .padding(.bottom, lastOperation == .post ? 4 : 0)
      }
      if let put = pathItem.put {
        OperationRow(method: .put, path: path, operation: put, isIndented: isIndented, onDelete: onDeleteOperation)
          .padding(.bottom, lastOperation == .put ? 4 : 0)
      }
      if let delete = pathItem.delete {
        OperationRow(method: .delete, path: path, operation: delete, isIndented: isIndented, onDelete: onDeleteOperation)
          .padding(.bottom, lastOperation == .delete ? 4 : 0)
      }
      if let patch = pathItem.patch {
        OperationRow(method: .patch, path: path, operation: patch, isIndented: isIndented, onDelete: onDeleteOperation)
          .padding(.bottom, lastOperation == .patch ? 4 : 0)
      }
      if let head = pathItem.head {
        OperationRow(method: .head, path: path, operation: head, isIndented: isIndented, onDelete: onDeleteOperation)
          .padding(.bottom, lastOperation == .head ? 4 : 0)
      }
      if let options = pathItem.options {
        OperationRow(method: .options, path: path, operation: options, isIndented: isIndented, onDelete: onDeleteOperation)
          .padding(.bottom, lastOperation == .options ? 4 : 0)
      }
      if let trace = pathItem.trace {
        OperationRow(method: .trace, path: path, operation: trace, isIndented: isIndented, onDelete: onDeleteOperation)
          .padding(.bottom, lastOperation == .trace ? 4 : 0)
      }
    }
  }
}
