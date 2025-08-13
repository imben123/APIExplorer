//
//  PathDragItem.swift
//  OpenAPIViewer
//
//  Created by Ben Davis on 13/08/2025.
//

import SwiftUI
import SwiftOpenAPI

/// Data model for dragging paths in the sidebar
struct OperationDragItem: Codable, Transferable {
  let path: String
  let operation: HTTPMethod

  static var transferRepresentation: some TransferRepresentation {
    CodableRepresentation(contentType: .data)
  }
}
